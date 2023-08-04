#ifndef MEM_WRITE_H
#define MEM_WRITE_H

#include <stdint.h>
#include <string.h>

//parameters
#define MEM_DATA_COUNT         1024
#define BASE_ADDRESS_WIDTH     64
#define ADDRESS_INCREMENT_SIZE 64
#define MEM_MAX_ADDR_SIZE      32
#define MEM_ADDR_SIZE          32
#define MEM_DATA_ADDR_SIZE     8
#define WR_PTR_SIZE            32
#define C_AXIS_TDATA_WIDTH     256
#define WIRE_INCR              32
#define OUT_DATA_SIZE          32

class mem_write
{
public:
    mem_write(/* args */);
public: 
    virtual ~mem_write();
protected:
    enum STATE{
        IDLE,
        SET_WRITE_PARA,
        WRITE_DATA,
        WRITE_WAIT
    };

    const char* state_table[4] = {
        "IDLE",
        "SET_WRITE_PARA",
        "WRITE_DATA",
        "WRITE_WAIT"
    };

    //flags
    uint8_t fetch_done;
    uint8_t write_done;
    //internal signals
    uint8_t state = IDLE;
    uint32_t mem_addr;
    uint32_t transfer_ctr;
    uint32_t wr_ptr = 0;
    uint8_t mem_data[MEM_DATA_COUNT] = {0};
    

public:
    void execute(
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
        uint8_t  write_done,
        uint8_t*  out_data //output 256
    );
    void check_mem_data(uint8_t* data, uint32_t size);
};

#endif // MEM_WRITE_H