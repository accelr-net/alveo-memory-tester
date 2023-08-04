#include <iostream>
#include <fstream>
#include <sys/stat.h>
#include "mem_read.h"
#include "read_master.h"



int main(int argc, char const *argv[]){

    mem_read *mr = new mem_read();
    read_master *rm     = new read_master();

    //settings values
    //input signals
    uint8_t     start = 1;
    uint64_t    base_address = 0; //to be entered
    uint32_t    addr_increment = 32;
    uint64_t    mem_max_addr = 1024;
    uint8_t     done;
    //AXI4 read master interface
    uint8_t     data_in[32];
    uint8_t     data_valid; //(1)
    uint8_t     fetch_data; //(1)
    uint64_t    data_rd_addr;
    uint32_t    data_rd_size;
    uint8_t     data_read_done; //(1)
    uint8_t     data_read_ready;//(1)
    uint8_t     data_last;

    uint32_t    mem_size = 1024;
    uint8_t     memory[mem_size];
    uint8_t     check_mem[mem_size];
    bool        SUCCESS;

    for (int i = 0; i < 1024; i++)
    {
        memory[i]=(i<256)?i:i%256;
    }
    
    rm->set_ddr_memory(memory, mem_size);

    int i = 0;
    while(true){
        if(DEBUG) std::cout << "========== CYCLE #" << std::dec << i << "==========" << std::endl;
        i++;

        mr -> execute(
            //input signals
            start,
            base_address,
            addr_increment,
            mem_max_addr,
            //output signals
            &done,
            //AXI4 read master interface
            data_in,
            data_valid, //(1)
            &fetch_data, //(1)
            &data_rd_addr,
            &data_rd_size,
            data_read_done, //(1)
            &data_read_ready //(1)
        );

        if(fetch_data){
            if(DEBUG) std::cout << std::dec << "data_rd_addr: " << data_rd_addr << std::endl;
            if(DEBUG) std::cout << std::dec << "data_rd_size: " << data_rd_size << std::endl;
        }

        rm-> execute(
          data_in,
          &data_valid,
          fetch_data,
          data_rd_addr,
          data_rd_size,
          &data_read_done,
          data_read_ready,
          &data_last
        );

        if(done){
            
            mr->check_mem_data(check_mem, mem_size);
            for (int i = 0; i < mem_size; i++)
            {
                if (check_mem[i]==memory[i])
                {
                    SUCCESS = true;
                }
                else
                {
                    SUCCESS = false;
                    break;
                }
            }
            
            std::cout << "RESULT (mem_read_test) : " << std::dec << (SUCCESS ? "PASS" : "FAIL") << std::endl;
            break;
        }

    }

    return 0;
}