import cocotb
from cocotb.triggers import Timer
from cocotb.clock import Clock
from cocotb.triggers import RisingEdge, ReadWrite

import mem_read_model
import read_master_model

import os

DEBUG = os.getenv('DEBUG').lower() in ('true')

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

@cocotb.test()
async def mem_read_test(dut):
    
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

    data_read_done = 0

   

    success              = False

    #set clock
    cocotb.start_soon(Clock(dut.clk, 10, units="ns").start())

    # Initial values for dut
    dut.start.value          = start
    dut.base_address.value   = base_address
    dut.addr_increment.value = addr_increment
    dut.mem_max_addr.value   = mem_max_addr
    dut.data_in.value        = int.from_bytes(bytearray(data_in), "little")
    dut.data_valid.value     = data_valid
    dut.data_read_done.value = data_read_done

    # Reset DUT
    dut.reset.value = 1
    for i in range(3):
        await RisingEdge(dut.clk)
    dut.reset.value = 0 

    i = 0
    while True:
        print(f"========== CYCLE #{str(i)} ==========")
        i+=1

        # set input values to dut
        dut.start.value                 = start
        dut.base_address.value          = base_address
        dut.addr_increment.value        = addr_increment
        dut.mem_max_addr.value          = mem_max_addr
        dut.data_in.value               = int.from_bytes(bytearray(data_in), "little")
        dut.data_valid.value            = data_valid
        dut.data_read_done.value        = data_read_done
        await RisingEdge(dut.clk)
        await ReadWrite()

        fetch_data                      = dut.fetch_data.value
        data_rd_addr                    = dut.data_rd_addr.value
        data_rd_size                    = dut.data_rd_size.value
        data_read_ready                 = dut.data_read_ready.value

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

        
        if (dut.done.value):
            mem_data = dut.mem_data
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


        # if i > 2000: break

    print("RESULT (read next doc) : ", "PASS" if success else "FAIL")
    # assert success