from libc.stdint cimport (uint8_t, uint32_t, uint64_t)

cdef extern from "../src/mem_read_write.cpp":
    pass

# Declare the class with cdef
cdef extern from "mem_read_write.h":
    cdef cppclass mem_read_write:
        mem_read_write() except +
        void execute(
            uint8_t     start, #system start signal
            #read input part
            uint64_t    read_data_base_addr,
            uint32_t    read_addr_increment,
            uint64_t    read_mem_max_addr,
            #AXI4 read master interface
            uint8_t*    read_data,
            uint8_t     read_data_valid, #(1)
            uint8_t*    start_reading_data, #(1)
            uint64_t*   read_addr,
            uint32_t*   read_data_size,
            uint8_t     data_read_done, #(1)
            uint8_t*    read_data_ready, #(1)

            uint64_t    write_data_base_addr, #input 64
            uint32_t    write_addr_increment,
            uint64_t    write_mem_max_addr,
            #AXI4 write master interface
            uint8_t*    start_writing_data, #(1) #output 1
            uint64_t*   write_addr, #output 64
            uint32_t*   write_data_size, #output 32
            uint8_t*    write_data_valid, #(1) #output 1
            uint8_t     write_data_ready, #(1) #input 1
            uint8_t     data_write_done,
            uint8_t*    write_data, #output 256
            uint8_t*    done #system process done signal
        )
