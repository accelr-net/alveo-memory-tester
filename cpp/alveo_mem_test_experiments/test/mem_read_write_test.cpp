#include <iostream>
#include <fstream>
#include <sys/stat.h>
#include "mem_read_write.h"
#include "read_master.h"
#include "write_master.h"

int main(int argc, char const *argv[]){
    read_master     *rm     =   new read_master();
    write_master    *wm     =   new write_master();
    mem_read_write  *mrw    =   new mem_read_write();


    //settings values for input
    //input signals
    uint8_t     start = 1;
    uint64_t    read_data_base_addr = 0; //to be entered
    uint32_t    read_addr_increment = 32;
    uint64_t    read_mem_max_addr = 1024;
    //AXI4 read master interface
    uint8_t     read_data[32] = {0};
    uint8_t     read_data_valid = 0; //(1)
    uint8_t     start_reading_data = 0; //(1)
    uint64_t    read_addr = 0;
    uint32_t    read_data_size = 0;
    uint8_t     data_read_done = 0; //(1)
    uint8_t     read_data_ready = 0;//(1)
    uint32_t    in_mem_size = 1024;
    uint8_t     in_memory[in_mem_size] = {0};

    for (int i = 0; i < in_mem_size; i++)
    {
        in_memory[i]=(i<256)?i:i%256;
    }

    rm->set_ddr_memory(in_memory, in_mem_size);

    //settings values for output
    //input signals
    uint64_t    write_data_base_addr = 0; //to be entered
    uint32_t    write_addr_increment = 32;
    uint64_t    write_mem_max_addr = 1024;
    //AXI4 write master interface
    uint8_t     start_writing_data = 0; //(1) //output 1
    uint64_t    write_addr = 0; //output 64
    uint32_t    write_data_size = 0; //output 32
    uint8_t     write_data_valid = 0; //(1) //output 1
    uint8_t     write_data_ready = 0; //(1) //input 1
    uint8_t     data_write_done = 0;
    uint8_t     write_data[32] = {0}; //output 256
    uint8_t     data_last = 0;

    uint32_t    out_mem_size = 1024;
    uint8_t     out_memory[out_mem_size] = {0};
    uint8_t     done = 0;

    bool        SUCCESS;

    int i = 0;
    while(true){
        if(DEBUG) std::cout << "========== CYCLE #" << std::dec << i << "==========" << std::endl;
        i++;

        mrw->execute(
            start, //system start signal
            //read input part
            read_data_base_addr,
            read_addr_increment,
            read_mem_max_addr,
            //AXI4 read master interface
            read_data,
            read_data_valid, //(1)
            &start_reading_data, //(1)
            &read_addr,
            &read_data_size,
            data_read_done, //(1)
            &read_data_ready, //(1)

            write_data_base_addr, //input 64
            write_addr_increment,
            write_mem_max_addr,
            //AXI4 write master interface
            &start_writing_data, //(1) //output 1
            &write_addr, //output 64
            &write_data_size, //output 32
            &write_data_valid, //(1) //output 1
            write_data_ready, //(1) //input 1
            data_write_done,
            write_data, //output 256
            &done //system process done signal
        );

        rm-> execute(
          read_data,
          &read_data_valid,
          start_reading_data,
          read_addr,
          read_data_size,
          &data_read_done,
          read_data_ready,
          &data_last
        );

        wm->execute(
          start_writing_data,
          write_addr,
          write_data_size,
          write_data,
          write_data_valid,
          &data_write_done,
          &write_data_ready
        );

        if(data_write_done){
            std::cout<<"write_done!\n";
        }

        if(done){
            wm->get_ddr_memory(out_memory, out_mem_size);
            std::cout<<"\n";
            std::cout<<"write_done!\n";
            for (int i = 0; i < out_mem_size; i++)
            {
                std::cout<<"out_memory["<<i<<"]="<<(uint32_t)out_memory[i]<<"\n";
                if (out_memory[i]==in_memory[i])
                {
                    SUCCESS=true;
                    
                }
                else
                {
                    SUCCESS=false;
                    break;
                }
            }
            // break;
            if(SUCCESS){
                std::cout<<"done!!\n";
                std::cout<<"test passed!!\n";
            }
            else{
                std::cout<<"done!!\n";
                std::cout<<"test failed!!\n";
            }
            break;
        }

        if (i>2500)
        {
            // break;
        }
        

    }

    std::cout << "RESULT (mem_read_write_test) : " << std::dec << (SUCCESS ? "PASS" : "FAIL") << std::endl;

    return 0;
}