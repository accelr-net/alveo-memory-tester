import cocotb
from cocotb.triggers import Timer
from cocotb.clock import Clock
from cocotb.triggers import RisingEdge, ReadWrite

import mem_read_write_model
import read_master_model
import write_master_model

import os

DEBUG = os.getenv('DEBUG').lower() in ('true')

mrw = mem_read_write_model.PyMemReadWrite()
rm  = read_master_model.PyReadMaster()
wm  = write_master_model.PyWriteMaster()

# rm_rtl  = read_master_model.PyReadMaster()
# wm_rtl  = write_master_model.PyWriteMaster()

success = False
in_mem_size = 1024
in_memory = [0]*in_mem_size

for i in range (in_mem_size):
      if (i<256):
        in_memory[i]=i
      else:
        in_memory[i]=i%256
    
rm.set_ddr_memory(in_memory,len(in_memory))
# rm_rtl.set_ddr_memory(in_memory,len(in_memory))
out_mem_size = 1024
out_memory = [0]*out_mem_size
mem_data_copy = [0]*1024

@cocotb.test()
async def mem_read_write_test(dut):
    
    # Initial values for dut
    start = 1 
    # #read input part
    read_data_base_addr = 0           
    read_addr_increment = 32           
    read_mem_max_addr   = 1024            
    # #AXI4 read master interface
    read_data_py    = [0]*32
    read_data_valid = 0 
    read_data_ready = 0
    data_read_done  = 0               
    
    write_data_base_addr    = 0                
    write_addr_increment    = 32             
    write_mem_max_addr      = 1024          
    # #AXI4 write master interface
    write_data_py       = [0]*32
    write_data_ready    = 0                 
    data_write_done     = 0
    data_last           = 0
    
    done = 0

    #RTL probes
    read_data_py_rtl        = [0]*32
    done_rtl                = 0
    start_reading_data_rtl  = 0
    read_data_size_rtl      = 0
    read_addr_rtl           = 0
    read_data_ready_rtl     = 0
    data_read_done_rtl      = 0
    write_data_py_rtl       = [0]*32
    data_write_done_rtl     = 0
    write_data_ready_rtl    = 0
    start_writing_data_rtl  = 0
    write_addr_rtl          = 0
    write_data_size_rtl     = 0
    write_data_valid_rtl    = 0
    data_write_done_rtl     = 0

    success                 = False

    #set clock
    cocotb.start_soon(Clock(dut.clk, 10, units="ns").start())

    # Initial values for dut
    dut.start.value                 = start#system start signal
    #read input part
    dut.read_data_base_addr.value   = read_data_base_addr
    dut.read_addr_increment.value   = read_addr_increment
    dut.read_mem_max_addr.value     = read_mem_max_addr
    #AXI4 read master interface
    dut.read_data.value             = int.from_bytes(bytearray(read_data_py), "little")
    dut.read_data_valid.value       = read_data_valid#(1)
    dut.data_read_done.value        = data_read_done#(1)

    dut.write_data_base_addr.value  = write_data_base_addr#input 64
    dut.write_addr_increment.value  = write_addr_increment
    dut.write_mem_max_addr.value    = write_mem_max_addr
    #AXI4 write master interface
    dut.write_data_ready.value      = write_data_ready#(1) #input 1
    dut.data_write_done.value       = data_write_done #system process done signal


    # Reset DUT
    dut.reset.value = 1
    for i in range(3):
        await RisingEdge(dut.clk)
    dut.reset.value = 0 

    i = 0
    while True:
        # if(DEBUG): print(f"========== CYCLE #{str(i)} ==========")
        i+=1

        # Initial values for dut
        dut.start.value                 = start#system start signal
        #read input part
        dut.read_data_base_addr.value   = read_data_base_addr
        dut.read_addr_increment.value   = read_addr_increment
        dut.read_mem_max_addr.value     = read_mem_max_addr
        #AXI4 read master interface
        dut.read_data.value             = int.from_bytes(bytearray(read_data_py), "little")
        dut.read_data_valid.value       = read_data_valid#(1)
        dut.data_read_done.value        = data_read_done#(1)

        dut.write_data_base_addr.value  = write_data_base_addr#input 64
        dut.write_addr_increment.value  = write_addr_increment
        dut.write_mem_max_addr.value    = write_mem_max_addr
        #AXI4 write master interface
        dut.write_data_ready.value      = write_data_ready#(1) #input 1
        dut.data_write_done.value       = data_write_done #system process done signal

        # advancing clock
        await RisingEdge(dut.clk)
        await ReadWrite()

        start_reading_data              = dut.start_reading_data.value
        read_addr                       = dut.read_addr.value
        read_data_size                  = dut.read_data_size.value
        read_data_ready                 = dut.read_data_ready.value  

        start_writing_data_rtl          = dut.start_writing_data.value            
        write_addr_rtl                  = dut.write_addr.value                
        write_data_size_rtl             = dut.write_data_size.value
        write_data                      = dut.write_data.value
        write_data_masked               = str(write_data).replace('x', '0')
        write_data_py_rtl               = int(write_data_masked, 2).to_bytes(32, "little")
        write_data_valid_rtl            = dut.write_data_valid.value              

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
            start_writing_data_rtl,
            write_addr_rtl,
            write_data_size_rtl,
            write_data_py_rtl,
            write_data_valid_rtl
        )

        done_rtl    = dut.done.value

        
        # check output out_memory
        if (done_rtl):
            mem_data = dut.mem_read_inst.mem_data
            print("\ndut.mem_write_inst.mem_data : ")
            for i in range (len(mem_data)):
                if(i<256):
                    if(mem_data[i] == i):
                        success = True
                    else:
                        success = False
                        print("\nmem_data mismatch!!!")
                        break
                else:
                    if(mem_data[i] == i%256):
                        success = True
                    else:
                        success = False
                        print("\nmem_data mismatch!!!")
                        break
                if(DEBUG): print(int(mem_data[i]))
            break
        
        if(~done_rtl):
            success = False

        if(i>3350):
            print("\n\n\nloop expired!")
            # break

    print("RESULT (mem_read_write) : ", "PASS" if success else "FAIL")