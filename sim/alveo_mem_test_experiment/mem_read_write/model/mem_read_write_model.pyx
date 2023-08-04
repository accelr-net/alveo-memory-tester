# distutils: language = c++

from libc.stdint cimport (uint8_t, uint32_t, uint64_t)
from libc.stdlib cimport (malloc, free)
from mem_read_write cimport mem_read_write

cdef class PyMemReadWrite:
    cdef mem_read_write mrw

    def __cinit__(self):
        self.mrw = mem_read_write()

    def execute(self,
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
        ):

        cdef uint8_t  read_data[32]
        for i in range(32):
            read_data[i] = read_data_py[i]

        # output signals
        cdef uint8_t  done
        # AXI4 read master interface outputs
        cdef uint8_t  start_reading_data
        cdef uint64_t read_addr
        cdef uint32_t read_data_size
        cdef uint8_t  read_data_ready
        # AXI4 write master interface outputs
        cdef uint8_t  start_writing_data #(1) #output 1
        cdef uint64_t write_addr #output 64
        cdef uint32_t write_data_size #output 32
        cdef uint8_t  write_data_valid #(1) #output 1
        cdef uint8_t  write_data[32]

        self.mrw.execute(
            start, #system start signal
            #read input part
            read_data_base_addr,
            read_addr_increment,
            read_mem_max_addr,
            #AXI4 read master interface
            read_data,
            read_data_valid, #(1)
            &start_reading_data, #(1)
            &read_addr,
            &read_data_size,
            data_read_done, #(1)
            &read_data_ready, #(1)

            write_data_base_addr, #input 64
            write_addr_increment,
            write_mem_max_addr,
            #AXI4 write master interface
            &start_writing_data, #(1) #output 1
            &write_addr, #output 64
            &write_data_size, #output 32
            &write_data_valid, #(1) #output 1
            write_data_ready, #(1) #input 1
            data_write_done,
            write_data, #output 256
            &done #system process done signal
        )

        write_data_py   = [write_data[i] for i in range(32)]

        return [
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
        ]