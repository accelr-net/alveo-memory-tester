# distutils: language = c++

from libc.stdint cimport (uint8_t, uint32_t, uint64_t)
from libc.stdlib cimport (malloc, free)
from read_master cimport read_master

cdef class PyReadMaster:
    cdef read_master rm

    def __cinit__(self):
        self.rm = read_master()

    def execute(self,
            start,
            address,
            size,
            read_ready
        ):
        cdef uint8_t data[32]       
        cdef uint8_t data_valid 
        cdef uint8_t done       
        cdef uint8_t data_last  
        self.rm.execute(
                data,
                &data_valid,
                start,
                address,
                size,
                &done,
                read_ready,
                &data_last
            )
        data_py = [data[i] for i in range(32)]
        return [
                data_py,
                data_valid,
                done,
                data_last
            ]

    def set_ddr_memory(self,
            mem_py,
            size
        ):
        cdef uint8_t* mem = <uint8_t*>malloc(size*sizeof(uint8_t))
        for i in range(size):
            mem[i] = mem_py[i]
        self.rm.set_ddr_memory(mem,size)
        free(mem)