from libc.stdint cimport (uint8_t, uint32_t, uint64_t)

cdef extern from "../src/write_master.cpp":
    pass

# Declare the class with cdef
cdef extern from "write_master.h":
    cdef cppclass write_master:
        write_master() except +
        void execute(
            uint8_t     start,
            uint64_t    address,
            uint32_t    size,
            uint8_t*    data,
            uint8_t     data_valid,
            uint8_t*    done,
            uint8_t*    write_ready
        )
        void get_ddr_memory(uint8_t* mem, uint32_t size)
