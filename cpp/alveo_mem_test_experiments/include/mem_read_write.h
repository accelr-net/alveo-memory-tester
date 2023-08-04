#ifndef MEM_READ_WRITE_H
#define MEM_READ_WRITE_H

#include <stdint.h>
#include <string.h>


//mem read parameters

#define IN_DATA_SIZE                    32
#define READ_BASE_ADDRESS_WIDTH         64
#define READ_ADDRESS_INCREMENT_SIZE     32
#define READ_MEM_MAX_ADDR_SIZE          32
#define READ_MEM_ADDR_SIZE              32

//mem write parameters

#define OUT_DATA_SIZE                   32
#define WRITE_BASE_ADDRESS_WIDTH        64
#define WRITE_ADDRESS_INCREMENT_SIZE    32
#define WRITE_MEM_MAX_ADDR_SIZE         32
#define WRITE_MEM_ADDR_SIZE             32

//common parameters
#define MEM_DATA_COUNT           1024
#define MEM_DATA_ADDR_SIZE       8
#define C_AXIS_TDATA_WIDTH       256
#define WR_PTR_SIZE              32
#define WIRE_INCR                32

class mem_read_write
{
public:
    mem_read_write(/* args */);
public: 
    virtual ~mem_read_write();
protected:
    enum READ_WRITE_STATE{
        IDLE,
        FETCH_WAIT,
        READ_DATA,
        SET_READ_PARA,
        SET_WRITE_PARA,
        WRITE_WAIT,
        WRITE_DATA,
        READ_DATA_FROM_DDR,
        PROCESS_DATA,
        WRITE_DATA_TO_DDR
    };

    const char* read_write_state_table[10] = {
        "IDLE",
        "FETCH_WAIT",
        "READ_DATA",
        "SET_READ_PARA",
        "SET_WRITE_PARA",
        "WRITE_WAIT",
        "WRITE_DATA",
        "READ_DATA_FROM_DDR",
        "PROCESS_DATA",
        "WRITE_DATA_TO_DDR"
    };

    //read flags
    uint8_t             read_address_set_done;
    uint8_t             read_done;
    READ_WRITE_STATE    read_state = IDLE;
    
    //write flags
    uint8_t             write_address_set_done;
    uint8_t             write_done;
    READ_WRITE_STATE    write_state = IDLE;

    //common internal signals
    uint8_t             read_start;
    uint8_t             write_start;
    READ_WRITE_STATE    read_write_state = IDLE;
    uint32_t            mem_addr;
    uint32_t            wr_ptr;
    uint32_t            transfer_ctr;
    uint8_t             mem_data[MEM_DATA_COUNT] = {0};
    uint8_t             processed_mem_data[MEM_DATA_COUNT] = {0};

private:
    void read_execute(
        //input signals
        uint8_t  start,
        uint64_t read_data_base_addr,
        uint32_t read_addr_increment,
        uint64_t read_mem_max_addr,
        uint8_t* done,
        //AXI4 read master interface
        uint8_t*  read_data,
        uint8_t   read_data_valid, //(1)
        uint8_t*  start_reading_data, //(1)
        uint64_t* read_addr,
        uint32_t* read_data_size,
        uint8_t   data_read_done, //(1)
        uint8_t*  read_data_ready //(1)
    );

    void write_execute(
        //input signals
        uint8_t   start,
        uint64_t write_data_base_addr, //input 64
        uint32_t write_addr_increment,
        uint64_t write_mem_max_addr,
        //output signals
        uint8_t*  done,
        //AXI4 write master interface
        uint8_t*  start_writing_data, //(1) //output 1
        uint64_t* write_addr, //output 64
        uint32_t* write_data_size, //output 32
        uint8_t*  write_data_valid, //(1) //output 1
        uint8_t   write_data_ready, //(1) //input 1
        uint8_t   data_write_done,
        uint8_t*  write_data //output 256
    );
public:
    void execute(
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
    );

};

#endif // MEM_READ_WRITE_H