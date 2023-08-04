from libc.stdint cimport (uint8_t, uint32_t, uint64_t)

cdef extern from "../src/read_master.cpp":
    pass

# Declare the class with cdef
cdef extern from "read_master.h":
    cdef cppclass read_master:
        read_master() except +
        void execute(
            uint8_t*  data,
            uint8_t*  data_valid, #(1)
            uint8_t   start, #(1)
            uint64_t  address,
            uint32_t  size,
            uint8_t*  done, #(1)
            uint8_t   read_ready, #(1)
            uint8_t*  data_last #(1)
        )
        void set_ddr_memory(uint8_t* mem, uint32_t size)