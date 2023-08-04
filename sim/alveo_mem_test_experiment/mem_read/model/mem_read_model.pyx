# distutils: language = c++

from libc.stdint cimport (uint8_t, uint32_t, uint64_t)
from libc.stdlib cimport (malloc, free)
from mem_read cimport mem_read

cdef class PyMemRead:
    cdef mem_read mr

    def __cinit__(self):
        self.mr = mem_read()

    def execute(self,
        # input signals
        start,
        base_address,
        addr_increment,
        mem_max_addr,
        # AXI4 read master interface
        data_in_py,
        data_valid, #(1)
        data_read_done #(1)
    ):

        cdef uint8_t  data_in[32]
        for i in range(32):
            data_in[i] = data_in_py[i]

        # output signals
        cdef uint8_t  done
        # AXI4 read master interface outputs
        cdef uint8_t  fetch_data
        cdef uint64_t data_rd_addr
        cdef uint32_t data_rd_size
        cdef uint8_t  data_read_ready

        self.mr.execute(
            #input signals
            start,
            base_address,
            addr_increment,
            mem_max_addr,
            # output signals
            &done,
            #AXI4 read master interface
            data_in,
            data_valid, #(1)
            &fetch_data, #(1)
            &data_rd_addr,
            &data_rd_size,
            data_read_done, #(1)
            &data_read_ready #(1)
        )

        return [
            done,
            fetch_data,
            data_rd_addr,
            data_rd_size,
            data_read_ready
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