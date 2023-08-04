# distutils: language = c++

from libc.stdint cimport (uint8_t, uint32_t, uint64_t)
from libc.stdlib cimport (malloc, free)
from mem_write cimport mem_write

cdef class PyMemWrite:
    cdef mem_write mw

    def __cinit__(self):
        self.mw = mem_write()

    def execute(self,
        start,
        out_data_base_addr, #input 64
        addr_increment,
        mem_max_addr,
        out_data_ready, #(1) #input 1
        write_done
    ):

        # output signals
        cdef uint8_t  done
        # AXI4 write master interface outputs
        cdef uint8_t  write_out_data #(1) #output 1
        cdef uint64_t write_addr #output 64
        cdef uint32_t out_data_size #output 32
        cdef uint8_t  out_data_valid #(1) #output 1
        cdef uint8_t  out_data[32]

        self.mw.execute(
            #input signals
            start,
            out_data_base_addr,
            addr_increment,
            mem_max_addr,
            #output signals
            &done,
            #AXI4 write master interface
            &write_out_data, 
            &write_addr, 
            &out_data_size, 
            &out_data_valid, 
            out_data_ready,
            write_done, 
            out_data
        )

        out_data_py   = [out_data[i] for i in range(32)]

        return [
            done,
            write_out_data, #(1) #output 1
            write_addr, #output 64
            out_data_size, #output 32
            out_data_valid, #(1) #output 1
            out_data_py #output 256
        ]
        
    def check_mem_data(self,
        size
        ):
        cdef uint8_t* mem  = <uint8_t*>malloc(size*sizeof(uint8_t))
        self.mr.check_mem_data(mem,size)
        mem_py              = [0]*size
        for i in range (size):
           mem_py[i]       = mem[i]
        free(mem)
        return mem_py