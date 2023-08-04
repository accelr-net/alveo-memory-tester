import  cocotb
from    cocotb.triggers import Timer
from    cocotb.clock import Clock
from    cocotb.triggers import RisingEdge, ReadWrite

import mem_write_model
import write_master_model

import os

CPP_MODEL_HOME        = os.getenv('CPP_MODEL_HOME')
DEBUG = os.getenv('DEBUG').lower() in ('true')

mw      = mem_write_model   .PyMemWrite()
wm_h    = write_master_model.PyWriteMaster()

@cocotb.test()
async def mem_write_test(dut):
    
    start = 0
    out_data_base_addr = 0
    addr_increment = 32
    mem_max_addr = 1024
    write_out_data_h = 0
    write_addr_h = 0
    out_data_size_h =32
    out_data_valid_h = 0
    out_data_ready = 0
    out_data_ready_h = 0
    write_done = 0
    write_done_h =0
    out_data = [0]*32
    out_data_h = [0]*32
    
    success              = False
    

    #set clock
    cocotb.start_soon(Clock(dut.clk, 10, units="ns").start())
    

    # Initial values for dut
    dut.start.value                 = start
    dut.out_data_base_addr.value    = out_data_base_addr
    dut.addr_increment.value        = addr_increment
    dut.mem_max_addr.value          = mem_max_addr
    dut.write_done.value            = write_done
    dut.out_data_ready.value        = out_data_ready

    # Reset DUT
    dut.reset.value = 1
    for i in range(3):
        await RisingEdge(dut.clk)
    dut.reset.value = 0 

    i = 0
    while True:
        print(f"========== CYCLE #{str(i)} ==========")
        i+=1

        dut.start.value                 = 1
        dut.out_data_base_addr.value    = out_data_base_addr
        dut.addr_increment.value        = addr_increment
        dut.mem_max_addr.value          = mem_max_addr
        dut.write_done.value            = write_done_h
        dut.out_data_ready.value        = out_data_ready_h
        await RisingEdge(dut.clk)
        await ReadWrite()

        write_out_data_h    = dut.write_out_data.value
        write_addr_h        = dut.write_addr.value
        out_data_size_h     = dut.out_data_size.value
        out_data            = dut.out_data.value  #output 256
        out_data_h_masked   = str(out_data).replace('z', '0')
        out_data_h          = int(out_data_h_masked, 2).to_bytes(32, "little")
        out_data_valid_h    = dut.out_data_valid.value

        [
            write_done_h,
            out_data_ready_h
        ] = wm_h.execute(
            write_out_data_h,
            write_addr_h,
            out_data_size_h,
            out_data_h,
            out_data_valid_h,
        )

        if(dut.done.value):
            mem_data = dut.mem_data.value
            print("\ndut.mem_data: ")
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
                print(int(mem_data[i]))
            break

        # if i > 2500: break

    print("RESULT (mem_write) : ", "PASS" if success else "FAIL")