#ifndef MEM_READ_H
#define MEM_READ_H

#include <stdint.h>
#include <string.h>

//parameters
#define MEM_DATA_COUNT           1024
#define FETCH_SIZE               32
#define BASE_ADDRESS_WIDTH       64
#define ADDRESS_INCREMENT_SIZE   32
#define MEM_MAX_ADDR_SIZE        32
#define MEM_ADDR_SIZE            32
#define WR_PTR_SIZE              32
#define C_AXIS_TDATA_WIDTH       256
#define MEM_DATA_ADDR_SIZE       8
#define WIRE_INCR                32

class mem_read
{
public:
    mem_read(/* args */);
public: 
    virtual ~mem_read();
protected:
    enum STATE{
        IDLE,
        FETCH_DATA,
        FETCH_WAIT,
        READ_DATA
    };

    const char* state_table[5] = {
        "IDLE",
        "FETCH_DATA",
        "FETCH_WAIT",
        "READ_DATA"
    };

    //flags
    uint8_t     fetch_done;
    uint8_t     read_done;
    //internal signals
    uint8_t     state = IDLE;
    uint32_t    mem_addr=0;
    uint32_t    wr_ptr = 0;
    uint32_t    transfer_ctr;
    uint8_t     mem_data[MEM_DATA_COUNT] = {0};


public:
    void execute(
        //input signals
        uint8_t start,
        uint64_t base_address,
        uint32_t addr_increment,
        uint64_t mem_max_addr,
        uint8_t* done,
        //AXI4 read master interface
        uint8_t*  data_in,
        uint8_t   data_valid, //(1)
        uint8_t*  fetch_data, //(1)
        uint64_t* data_rd_addr,
        uint32_t* data_rd_size,
        uint8_t   data_read_done, //(1)
        uint8_t*  data_read_ready //(1)
    );
    void check_mem_data(uint8_t* data, uint32_t size);
};

#endif // MEM_READ_H