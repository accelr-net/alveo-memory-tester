#include <iostream>
#include <cstring>
#include "write_master.h"

write_master::write_master(){}

write_master::~write_master(){}

void write_master::execute(
    uint8_t  start,
    uint64_t  address,
    uint32_t  size,
    uint8_t* data,
    uint8_t  data_valid,
    uint8_t* done,
    uint8_t* write_ready
)
{
  if(DEBUG) std::cout << "write_master -> Current state: " << state_table[state] << std::endl;
  *done = 0;
  switch(state){
    case WAIT_WRITE:
      write_ready_reg = 0;
      *done = 0;
      if(start){
        write_ready_reg = 1;
        write_address = address;
        write_size = size;
        state = WRITE_DATA;
      }
      break;
    case WRITE_DATA:
      if(write_counter >= write_size){
        write_counter = 0;
        *done = 1;
        state = WAIT_WRITE;
      }
      if(data_valid){
        for(int i=0; i<32; i++){
          ddr_memory[write_address+write_counter+i] = data[i];
        }
        write_counter += 32;
      }
      break;
    default:
      state = WAIT_WRITE;
  }
  *write_ready = write_ready_reg;

  if(DEBUG) std::cout << "write_master -> Next state   : " << state_table[state] << std::endl;
}

void write_master::get_ddr_memory(uint8_t* mem, uint32_t size){
  std::memcpy(mem, ddr_memory, size*sizeof(uint8_t));
}