#include <iostream>
#include <fstream>
#include <sys/stat.h>
#include "mem_write.h"
#include "write_master.h"



int main(int argc, char const *argv[]){

    mem_write    *mw = new mem_write();
    write_master *wm = new write_master();

    //settings values
    bool SUCCESS=1;
    //input signals
    uint8_t     start = 1;
    uint64_t    out_data_base_addr = 0; //to be entered
    uint32_t    addr_increment = 32;
    uint64_t    mem_max_addr = 1024;
    uint8_t     done =0;
    
    //AXI4 write master interface
    uint8_t   write_out_data; //(1) //output 1
    uint64_t  write_addr; //output 64
    uint32_t  out_data_size; //output 32
    uint8_t   out_data_valid; //(1) //output 1
    uint8_t   out_data_ready; //(1) //input 1
    uint8_t   out_data[32]; //output 256

    uint32_t    mem_size = 1024;
    uint8_t     check_mem[mem_size];

    uint8_t write_done  = 0;
    int i = 0;
    while(true){
        if(DEBUG) std::cout << "========== CYCLE #" << std::dec << i << "==========" << std::endl;
        i++;

        mw->execute(
            //input signals
            start,
            out_data_base_addr,
            addr_increment,
            mem_max_addr,
            //output signals
            &done,
            //AXI4 write master interface
            &write_out_data, 
            &write_addr, 
            &out_data_size, 
            &out_data_valid, 
            out_data_ready,
            write_done, 
            out_data
        );

        wm->execute(
          write_out_data,
          write_addr,
          out_data_size,
          out_data,
          out_data_valid,
          &write_done,
          &out_data_ready
        );

        if(write_done){
            wm->get_ddr_memory(check_mem, mem_size);
            std::cout<<"write_done\n";
            //break;
        }

        if(done){
            for (int i = 0; i < mem_size; i++)
            {
                std::cout<<"check_mem["<<i<<"]="<<(uint32_t)check_mem[i]<<"\n";
            }
            std::cout<<"done\n";
            std::cout << "RESULT (mem_write_test) : " << std::dec << (SUCCESS ? "PASS" : "FAIL") << std::endl;
            break;
        }

        if (i>2500)
        {
            SUCCESS = 0;
            std::cout << "RESULT (mem_write_test) : " << std::dec << (SUCCESS ? "PASS" : "FAIL") << std::endl;
            break;
        }
        

    }

    return 0;
}