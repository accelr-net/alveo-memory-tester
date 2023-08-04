from libc.stdint cimport (uint8_t, uint32_t, uint64_t)

cdef extern from "../src/mem_read.cpp":
    pass

# Declare the class with cdef
cdef extern from "mem_read.h":
    cdef cppclass mem_read:
        mem_read() except +
        void execute(
            # input signals
            uint8_t start,
            uint64_t base_address,
            uint32_t addr_increment,
            uint64_t mem_max_addr,
            # output signals
            uint8_t* done,
            # AXI4 read master interface
            uint8_t*  data_in,
            uint8_t   data_valid, #(1)
            uint8_t*  fetch_data, #(1)
            uint64_t* data_rd_addr,
            uint32_t* data_rd_size,
            uint8_t   data_read_done, #(1)
            uint8_t*  data_read_ready #(1)
        )
        void check_mem_data(uint8_t* data, uint32_t size)
