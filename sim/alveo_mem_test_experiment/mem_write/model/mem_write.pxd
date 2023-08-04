from libc.stdint cimport (uint8_t, uint32_t, uint64_t)

cdef extern from "../src/mem_write.cpp":
    pass

# Declare the class with cdef
cdef extern from "mem_write.h":
    cdef cppclass mem_write:
        mem_write() except +
        void execute(
            #input signals
            uint8_t start,
            uint64_t out_data_base_addr, #input 64
            uint32_t addr_increment,
            uint64_t mem_max_addr,
            #output signals
            uint8_t* done,
            #AXI4 write master interface
            uint8_t*  write_out_data, #(1) #output 1
            uint64_t* write_addr, #output 64
            uint32_t* out_data_size, #output 32
            uint8_t*  out_data_valid, #(1) #output 1
            uint8_t   out_data_ready, #(1) #input 1
            uint8_t   write_done,
            uint8_t*  out_data #output 256
        )
        void check_mem_data(uint8_t* data, uint32_t size)
