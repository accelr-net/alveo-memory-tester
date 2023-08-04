from struct import unpack, pack
import mem_write_model
import write_master_model

import os

CPP_MODEL_HOME        = os.getenv('CPP_MODEL_HOME')
DEBUG                 = os.getenv('DEBUG').lower() in ('true')

mw = mem_write_model.PyMemWrite()
wm  = write_master_model.PyWriteMaster()

mem_size = 1024
check_mem = [0]*mem_size

#settings values
#input signals
start = 1
out_data_base_addr = 0 #to be entered
addr_increment = 32
mem_max_addr = 1024
done =0
    
#AXI4 write master interface
out_data_ready = 0 #(1) #input 1
write_done = 0

i = 0
while True:
    print(f"========== CYCLE #{str(i)} ==========")
    i+=1

    [
        done,
        write_out_data,
        write_addr,
        out_data_size,
        out_data_valid,
        out_data
    ] = mw.execute(
        #input signals
        start,
        out_data_base_addr,
        addr_increment,
        mem_max_addr,
        #AXI4 read master interface
        write_done,
        out_data_ready #(1)

    )

    # if write_out_data:
      # if (DEBUG):
        # print(f"write_addr: {str(write_addr)}")
        # print(f"out_data_size: {str(out_data_size)}")

    [
        out_data_ready,
        write_done        
    ] = wm.execute(
        write_out_data,
        write_addr,
        out_data_size,
        out_data,
        out_data_valid
    )

    #check output check_mem
    if write_done:
        success = True
        check_mem = wm.get_ddr_memory(mem_size)
        

    if(~done):
      success = False
    if done:
      if (DEBUG):
        print("output check_mem: ")
        for r in range(mem_size) :
          print("check_mem[",r,"]=",check_mem[r])
      success = True
      break
    
    if (i>2500):
       success = False
       break


print("RESULT (mem_write) : ", "PASS" if success else "FAIL")