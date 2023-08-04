import mem_read_model
import read_master_model

import os

debug_value = os.getenv('DEBUG','false')
DEBUG=debug_value.lower()== 'true'

mr = mem_read_model.PyMemRead()
rm  = read_master_model.PyReadMaster()

mem_size = 1024
memory = [0]*mem_size
check_mem = [0]*mem_size

for i in range (mem_size):
  if (i<256):
    memory[i]=i
  else:
    memory[i]=i%256
  

rm.set_ddr_memory(memory, len(memory))

#settings values
#input signals
start = 1
base_address = 0 #to be entered
addr_increment = 32
mem_max_addr = 1024
done = 0
#AXI4 read master interface
data_in = [0]*32
data_valid = 0 #(1)
data_read_done =0
success = True



i = 0
while True:
    print(f"========== CYCLE #{str(i)} ==========")
    i+=1

    [
        done,
        fetch_data,
        data_rd_addr,
        data_rd_size,
        data_read_ready
    ] = mr.execute(
        #input signals
        start,
        base_address,
        addr_increment,
        mem_max_addr,
        #AXI4 read master interface
        data_in,
        data_valid, #(1)
        data_read_done, #(1)
    )

    if fetch_data:
      if (DEBUG):
        print(f"data_rd_addr: {str(data_rd_addr)}")
        print(f"data_rd_size: {str(data_rd_size)}")

    [
        data_in,
        data_valid,
        data_read_done,
        data_last        
    ] = rm.execute(
        fetch_data,
        data_rd_addr,
        data_rd_size,
        data_read_ready
    )

    if done:
      check_mem = mr.check_mem_data(mem_size)
      for r in range(mem_size) :
        if(check_mem[r] == memory[r]):
          success = True
          print(check_mem)
        else:
          success = False
          break
        
      
    if(done):
      break

print("RESULT (mem read) : ", "PASS" if success else "FAIL")
