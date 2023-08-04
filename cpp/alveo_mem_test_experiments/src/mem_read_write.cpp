#include <iostream>
#include <cstring>
#include <iomanip>
#include "mem_read_write.h"

#define RED "\033[31m"
#define CYAN "\033[36m"
#define RESET "\033[0m"

mem_read_write::mem_read_write(){}

mem_read_write::~mem_read_write(){}

void mem_read_write::read_execute(
    // input signals
    uint8_t  start,
    uint64_t read_data_base_addr,
    uint32_t read_addr_increment,
    uint64_t read_mem_max_addr,
    uint8_t* read_done,
    //AXI4 read master interface
    uint8_t*  read_data,
    uint8_t   read_data_valid, //(1)
    uint8_t*  start_reading_data, //(1)
    uint64_t* read_addr,
    uint32_t* read_data_size,
    uint8_t   data_read_done, //(1)
    uint8_t*  read_data_ready //(1)
)
{
    if(DEBUG) std::cout << CYAN << "mem_read -> Current mem_read_state: " << read_write_state_table[read_state] << RESET << std::endl;
        *start_reading_data = 0;
        *read_addr          = 0;
        *read_data_size     = 0;
        *read_data_ready    = 0;
        *read_done          = 0;
    
    switch (read_state)
    {
    case IDLE:
        *start_reading_data = 0;
        *read_addr          = 0;
        *read_data_size     = 0;
        *read_data_ready    = 0;
        *read_done          = 0;
        mem_addr            = 0;
        transfer_ctr        = 0;

        if (start)
        {
            read_state = SET_READ_PARA;
        }
        
        break;
    case SET_READ_PARA:
        if (mem_addr + read_addr_increment > read_mem_max_addr) {
            *read_done       = 1;
            read_state       = IDLE;
        } else {
            *read_addr = read_data_base_addr + mem_addr;
            *read_data_size = IN_DATA_SIZE;
            mem_addr     += read_addr_increment;
            *read_data_ready = 1;
            *start_reading_data = 1;
            read_state         = FETCH_WAIT;
        }
        break;
    case READ_DATA:
        *start_reading_data      = 0;
        if (transfer_ctr >= IN_DATA_SIZE){
            transfer_ctr     = 0;
            *read_data_ready = 0;
            read_state           = SET_READ_PARA;
        }else {
            if (read_data_valid) {
                for (int i=0; i<WIRE_INCR; i++) {
                    mem_data[wr_ptr+i] = read_data[i];
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
        // *read_data_ready = 0;
        // *start_reading_data = 0;
        read_state       = READ_DATA;
        break;
    default:
        read_state = IDLE;
        break;
    }
}

void mem_read_write::write_execute(
    //input signals
    uint8_t start,
    uint64_t write_data_base_addr, //input 64
    uint32_t write_addr_increment,
    uint64_t write_mem_max_addr,
    //output signals
    uint8_t* write_done,
    //AXI4 write master interface
    uint8_t*  start_writing_data, //(1) //output 1
    uint64_t* write_addr, //output 64
    uint32_t* write_data_size, //output 32
    uint8_t*  write_data_valid, //(1) //output 1
    uint8_t   write_data_ready, //(1) //input 1
    uint8_t   data_write_done,
    uint8_t*  write_data //output 256
)
{
    if(DEBUG) std::cout << CYAN << "mem_write -> Current read_state: " << read_write_state_table[write_state] << RESET << std::endl;
    
        *write_addr             = 0;
        *write_data_size        = 0;
        *write_data_valid       = 0;
        *start_writing_data     = 0;
        *write_data             = 0;
        *write_done             = 0;

    switch (write_state)
    {
    case IDLE:
        *write_addr             = 0;
        *write_data_size        = 0;
        *write_data_valid       = 0;
        *write_data             = 0;
        mem_addr                = 0;
        wr_ptr                  = 0;
        transfer_ctr            = 0;

        if (start)
        {
            write_state = SET_WRITE_PARA;
        }
        
        break;
    case SET_WRITE_PARA:
        if(write_addr_increment + mem_addr>write_mem_max_addr) {
            *write_done    = 1;
            write_state    = IDLE;
        }
        else {
            *write_addr     = write_data_base_addr + mem_addr;
            *write_data_size  = OUT_DATA_SIZE;
            mem_addr        = write_addr_increment + mem_addr;
            *start_writing_data = 1;
            write_state           = WRITE_DATA;
        }
        break;

    case WRITE_DATA:
        *start_writing_data = 0;
        if (write_data_ready) {
            
            if (transfer_ctr >= OUT_DATA_SIZE) {
                write_state           = WRITE_WAIT;
                transfer_ctr    = 0;
                *write_data_valid = 0;
            }
            else {
                for (int i=0; i<WIRE_INCR; i++) {
                    write_data[i] = mem_data[wr_ptr+i];
                }
                *write_data_valid = 1;
                transfer_ctr    = transfer_ctr + WIRE_INCR;
                if (wr_ptr +WIRE_INCR > MEM_DATA_COUNT) {
                    wr_ptr  = 0;
                }
                else {
                    wr_ptr          = wr_ptr + WIRE_INCR;
                }
            }
        }
        break;

    case WRITE_WAIT:
        if(data_write_done) {
            write_state           = SET_WRITE_PARA;
        }
        break;
    
    default:
        write_state = IDLE;
        break;
    }
}

void mem_read_write::execute(
    uint8_t     start, //system start signal
    //read input part
    uint64_t    read_data_base_addr,
    uint32_t    read_addr_increment,
    uint64_t    read_mem_max_addr,
    //AXI4 read master interface
    uint8_t*    read_data,
    uint8_t     read_data_valid, //(1)
    uint8_t*    start_reading_data, //(1)
    uint64_t*   read_addr,
    uint32_t*   read_data_size,
    uint8_t     data_read_done, //(1)
    uint8_t*    read_data_ready, //(1)

    uint64_t    write_data_base_addr, //input 64
    uint32_t    write_addr_increment,
    uint64_t    write_mem_max_addr,
    //AXI4 write master interface
    uint8_t*    start_writing_data, //(1) //output 1
    uint64_t*   write_addr, //output 64
    uint32_t*   write_data_size, //output 32
    uint8_t*    write_data_valid, //(1) //output 1
    uint8_t     write_data_ready, //(1) //input 1
    uint8_t     data_write_done,
    uint8_t*    write_data, //output 256
    uint8_t*    done //system process done signal
)
{
    

    if(DEBUG) std::cout << CYAN << "mem_read_write -> Current read_write_state: " << read_write_state_table[read_write_state] << RESET << std::endl;
    

        *start_reading_data = 0;
        *read_addr          = 0;
        *read_data_size     = 0;
        *read_data_ready    = 0;
        *start_writing_data = 0;
        *write_addr         = 0;
        *write_data_size    = 0;
        *write_data_valid   = 0;
        *write_data         = 0;
        
    switch (read_write_state)
    {
    case IDLE:
        *start_reading_data = 0;
        *read_addr          = 0;
        *read_data_size     = 0;
        *read_data_ready    = 0;
        mem_addr            = 0;
        transfer_ctr        = 0;
        *start_writing_data = 0;
        *write_addr         = 0;
        *write_data_size    = 0;
        *write_data_valid   = 0;
        *write_data         = 0;
        wr_ptr              = 0;
        read_start          = 0;
        write_start         = 0;

        if (start)
        {
            read_write_state = READ_DATA_FROM_DDR;
            read_start = 1;
        }

        break;
    case READ_DATA_FROM_DDR:
        read_execute(
            //input signals
            read_start,
            read_data_base_addr,
            read_addr_increment,
            read_mem_max_addr,
            &read_done,
            //AXI4 read master interface
            read_data,
            read_data_valid, //(1)
            start_reading_data, //(1)
            read_addr,
            read_data_size,
            data_read_done, //(1)
            read_data_ready //(1)
        );
        if (read_done)
        {
            read_write_state = PROCESS_DATA;
            read_start = 0;
        }
        
        break;

    case PROCESS_DATA:
        for (int i = 0; i < MEM_DATA_COUNT; i++)
        {
            processed_mem_data[i] = mem_data[i];
        }
        
        for (int d = 0; d < MEM_DATA_COUNT; d++)
        {
            mem_data[d] = processed_mem_data[d];
        }
        read_write_state = WRITE_DATA_TO_DDR;
        write_start = 1;
        break;

    case WRITE_DATA_TO_DDR:
        write_execute(
            //input signals
            write_start,
            write_data_base_addr, //input 64
            write_addr_increment,
            write_mem_max_addr,
            //output signals
            &write_done,
            //AXI4 write master interface
            start_writing_data, //(1) //output 1
            write_addr, //output 64
            write_data_size, //output 32
            write_data_valid, //(1) //output 1
            write_data_ready, //(1) //input 1
            data_write_done,
            write_data //output 256
        );
        if (write_done)
        {
            read_write_state = IDLE;
            *done      = 1;
        }
        
        break;
    
    default:
        read_write_state = IDLE;
        break;
    }
}