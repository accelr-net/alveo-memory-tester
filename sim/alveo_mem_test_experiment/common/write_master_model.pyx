# distutils: language = c++

from libc.stdint cimport (uint8_t, uint32_t, uint64_t)
from libc.stdlib cimport (malloc, free)
from write_master cimport write_master

cdef class PyWriteMaster:
    cdef write_master wm 

    def __cinit__(self):
        self.wm = write_master()

    def execute(self,
            start,
            address,
            size,
            data_py,
            data_valid           
        ):

        cdef uint8_t        done
        cdef uint8_t        data[32]
        for i in range(32):
            data[i] =   data_py[i]
        cdef uint8_t        write_ready
        self.wm.execute(
                start,
                address,
                size,
                data,
                data_valid,
                &done,
                &write_ready
            )
        return [
                done,
                write_ready
            ]

    def get_ddr_memory(self,
            size
        ):
        cdef uint8_t* mem   = <uint8_t*>malloc(size*sizeof(uint8_t))
        self.wm.get_ddr_memory(mem,size)
        mem_py              = [0]*size
        for i in range(size):
            mem_py[i]       = mem[i]
        free(mem)
        return mem_py