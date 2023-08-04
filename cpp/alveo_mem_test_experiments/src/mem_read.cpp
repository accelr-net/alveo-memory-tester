#include <iostream>
#include <cstring>
#include <iomanip>
#include "mem_read.h"

#define RED "\033[31m"
#define CYAN "\033[36m"
#define RESET "\033[0m"

mem_read::mem_read(){}

mem_read::~mem_read(){}

void mem_read::execute(
    //input signals
    uint8_t start,
    uint64_t base_address,
    uint32_t addr_increment,
    uint64_t mem_max_addr,
    //output signals
    uint8_t* done,
    //AXI4 read master interface
    uint8_t*  data_in,
    uint8_t   data_valid, //(1)
    uint8_t*  fetch_data, //(1)
    uint64_t* data_rd_addr,
    uint32_t* data_rd_size,
    uint8_t   data_read_done, //(1)
    uint8_t*  data_read_ready //(1)
)
{
    if(DEBUG) std::cout << CYAN << "mem_read -> Current state: " << state_table[state] << RESET << std::endl;
    
   

    switch (state)
    {
    case IDLE:
        *fetch_data         = 0;
        *data_rd_addr       = 0;
        *data_rd_size       = 0;
        *data_read_ready    = 0;
        *done               = 0;
        mem_addr            = 0;
        transfer_ctr        = 0;

        if (start)
        {
            state = FETCH_DATA;
        }
        
        break;
    case FETCH_DATA:
        if (mem_addr + addr_increment > mem_max_addr) {
            *done       = 1;
            state       = IDLE;
        } else {
            *data_rd_addr = base_address + mem_addr;
            *data_rd_size = FETCH_SIZE;
            mem_addr     += addr_increment;
            *fetch_data   = 1;
            state         = FETCH_WAIT;
        }
        break;
    case READ_DATA:
        *fetch_data      = 0;
        if (transfer_ctr >= FETCH_SIZE){
            transfer_ctr     = 0;
            *data_read_ready = 0;
            state           = FETCH_DATA;
        }else {
            if (data_valid) {
                for (int i=0; i<WIRE_INCR; i++) {
                    mem_data[wr_ptr+i] = data_in[i];
                }
                transfer_ctr    = transfer_ctr +WIRE_INCR;
                if(wr_ptr + WIRE_INCR < MEM_DATA_COUNT) {
                    wr_ptr  = wr_ptr + WIRE_INCR;
                }
                else {
                    wr_ptr  = 0;
                }
            }
        }       
        break;
    case FETCH_WAIT: 
        *data_read_ready = 1;
        state           = READ_DATA;
        break;
    default:
        state = IDLE;
        break;
    }
}

void mem_read::check_mem_data(uint8_t* data, uint32_t size){   
    std::memcpy(data, mem_data, size*sizeof(uint8_t));
}