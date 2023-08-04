#include <iostream>
#include <cstring>
#include <iomanip>
#include "mem_write.h"

#define RED "\033[31m"
#define CYAN "\033[36m"
#define RESET "\033[0m"

mem_write::mem_write(){}

mem_write::~mem_write(){}

void mem_write::execute(
    //input signals
    uint8_t start,
    uint64_t out_data_base_addr, //input 64
    uint32_t addr_increment,
    uint64_t mem_max_addr,
    //output signals
    uint8_t* done,
    //AXI4 write master interface
    uint8_t*  write_out_data, //(1) //output 1
    uint64_t* write_addr, //output 64
    uint32_t* out_data_size, //output 32
    uint8_t*  out_data_valid, //(1) //output 1
    uint8_t   out_data_ready, //(1) //input 1
    uint8_t   write_done,
    uint8_t*  out_data //output 256
)
{
    if(DEBUG) std::cout << CYAN << "mem_write -> Current state: " << state_table[state] << RESET << std::endl;
    
    // *write_out_data         = 0;
    // *write_addr             = 0;
    // *out_data_size          = 0;
    // *out_data_valid         = 0;
    // *out_data               = 0;
    // mem_addr                = 0;
    // *done                   = 0;

    switch (state)
    {
    case IDLE:
        *write_out_data         = 0;
        *write_addr             = 0;
        *out_data_size          = 0;
        *out_data_valid         = 0;
        *out_data               = 0;
        mem_addr                = 0;
        *done                   = 0;
        wr_ptr                  = 0;
        transfer_ctr            = 0;
        for (int i = 0; i < MEM_DATA_COUNT; i++)
        {
            mem_data[i]=(i<256)?i:i%256;
        }
        if (start)
        {
            state = SET_WRITE_PARA;
        }
        
        break;
    case SET_WRITE_PARA:
        if(addr_increment + mem_addr>mem_max_addr) {
            *done    = 1;
            state    = IDLE;
        }
        else {
            *write_addr     = out_data_base_addr + mem_addr;
            *out_data_size  = OUT_DATA_SIZE;
            mem_addr        = addr_increment + mem_addr;
            *write_out_data = 1;
            state           = WRITE_DATA;
        }
        break;

    case WRITE_DATA:
        *write_out_data = 0;
        if (out_data_ready) {
            if (transfer_ctr >= OUT_DATA_SIZE) {
                state           = WRITE_WAIT;
                transfer_ctr    = 0;
                *out_data_valid = 0;
            }
            else {
                for (int i=0; i<WIRE_INCR; i++) {
                    out_data[i] = mem_data[wr_ptr+i];
                }
                *out_data_valid = 1;
                if (wr_ptr +WIRE_INCR > MEM_DATA_COUNT) {
                    wr_ptr  = 0;
                }
                else {
                    wr_ptr          = wr_ptr + WIRE_INCR;
                    transfer_ctr    = transfer_ctr + WIRE_INCR;
                }
            }
        }
        break;

    case WRITE_WAIT:
        if(write_done) {
            state           = SET_WRITE_PARA;
        }
        break;
    
    default:
        state = IDLE;
        break;
    }
}

void mem_write::check_mem_data(uint8_t* data, uint32_t size){   
    std::memcpy(data, mem_data, size*sizeof(uint8_t));
}