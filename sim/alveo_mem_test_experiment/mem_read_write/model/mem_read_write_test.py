from struct import unpack, pack
import mem_read_write_model
import read_master_model
import write_master_model

import os
debug_value = os.getenv('DEBUG','false')
DEBUG=debug_value.lower()== 'true'

mrw = mem_read_write_model.PyMemReadWrite()
rm  = read_master_model.PyReadMaster()
wm  = write_master_model.PyWriteMaster()





success = True

in_mem_size = 1024
in_memory = [0]*in_mem_size


for i in range (in_mem_size):
  if (i<256):
    in_memory[i]=i
  else:
    in_memory[i]=i%256
  

rm.set_ddr_memory(in_memory,in_mem_size)

out_mem_size = 1024
out_memory = [0]*out_mem_size



#settings values
#input signals
# Initial values for dut
start = 1 
# #read input part
read_data_base_addr = 0           
read_addr_increment = 32           
read_mem_max_addr = 1024            
# #AXI4 read master interface
read_data_py = [0]*32
# read_addr = 0
read_data_size = 0    
start_reading_data = 0                     
read_data_valid = 0                
read_data_ready = 0                
data_read_done = 0                
write_data_base_addr = 0                
write_addr_increment = 32             
write_mem_max_addr = 1024          
# #AXI4 write master interface
write_data_py = [0]*32
write_addr = 0           
write_data_size = 0           
start_writing_data = 0
write_data_valid = 0                  
write_data_ready = 0                 
data_write_done = 0
  
done = 0

i = 0
while True:
  print(f"========== CYCLE #{str(i)} ==========")
  i+=1

  [
  done,
  start_reading_data,
  read_addr,
  read_data_size,
  read_data_ready,
  start_writing_data,
  write_addr,
  write_data_size,
  write_data_valid,
  write_data_py
  ] = mrw.execute(
      start, #system start signal
      #read input part
      read_data_base_addr,
      read_addr_increment,
      read_mem_max_addr,
      #AXI4 read master interface
      read_data_valid, #(1)
      data_read_done, #(1)
      read_data_py,
      write_data_base_addr, #input 64
      write_addr_increment,
      write_mem_max_addr,
      #AXI4 write master interface
      write_data_ready, #(1) #input 1
      data_write_done,
  )

  if read_data_valid:
    if (DEBUG):
      print(f"read_data_py: {str(read_data_py)}")
  if start_reading_data:
    if (DEBUG):
      print(f"read_addr: {str(read_addr)}")
      print(f"read_data_size: {str(read_data_size)}")
  if write_data_valid:
    if (DEBUG):
      print(f"write_data_py: {str(write_data_py)}")
  if start_writing_data:
    if (DEBUG):
      print(f"write_addr: {str(write_addr)}")
      print(f"write_data_size: {str(write_data_size)}")

  [
      read_data_py,
      read_data_valid,
      data_read_done,
      data_last        
  ] = rm.execute(
      start_reading_data,
      read_addr,
      read_data_size,
      read_data_ready
  )

  
  [
      data_write_done,        
      write_data_ready
  ] = wm.execute(
      start_writing_data,
      write_addr,
      write_data_size,
      write_data_py,
      write_data_valid
  )

  if done:
    out_memory = wm.get_ddr_memory(out_mem_size)
    for r in range(out_mem_size) :
        if(out_memory[r]==in_memory[r]):
           success = 1
        else:
           success = 0
    if (DEBUG):
      print("memory stored!")
      for k in range(in_mem_size):
             print(f"{int(in_memory[k])} ", end=' ')
      print("output out_memory: ")
      for k in range(out_mem_size):
             print(f"{int(out_memory[k])} ", end=' ')
    
    success = True
    break
    
  
  if(~done):
      success = False
  
  if(i>2500):
       print("loop expired!")
       break

print("\nRESULT (mem_read_write) : ", "PASS" if success else "FAIL")