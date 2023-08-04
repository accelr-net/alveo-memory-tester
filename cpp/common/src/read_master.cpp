#include <iostream>
#include <cstring>
#include "read_master.h"

read_master::read_master(){}

read_master::~read_master(){}

void read_master::execute(
  uint8_t*  data,
  uint8_t*  data_valid, //(1)
  uint8_t   start, //(1)
  uint64_t  address,
  uint32_t  size,
  uint8_t*  done, //(1)
  uint8_t   read_ready, //(1)
  uint8_t*  data_last //(1)
){
  if(DEBUG) std::cout << "read_master -> Current state: " << state_table[state] << std::endl;
  *data_valid = 0;
  *done       = 0;
  *data_last  = 0;
  switch(state){
    case(WAIT_READ):
      *data_valid = 0;
      *done = 0;
      if(start && read_ready){
        read_address = address;
        read_size = size;
        delay_counter = 0;
        state = READ_DATA;
      }
      break;
    case(READ_DATA):
      if(delay_counter < DDR_READ_DELAY){
        delay_counter++;
      }
      else if(read_counter >= read_size){
        read_counter = 0;
        *done = 1;
        *data_valid = 0;
        state = WAIT_READ;
      }
      else{
        std::random_device rd;
        std::mt19937 gen(rd());
        auto dis = std::uniform_int_distribution<uint32_t>(0,1);
        int b = dis(gen);
        if(b > 0) {
          for(int i=0; i<32; i++){
            data[i] = ddr_memory[read_counter+read_address+i];
          }
          *data_valid = 1;
          read_counter += 32;
          if(read_counter >= read_size){
            read_counter = 0;
            *data_last = 1;
            *done = 1;
            state = WAIT_READ;
          }
          else{
            *data_last = 0;
          }
        }
        else{
          *data_valid = 0;
        }
      }
      
      break;
    default:
      state = WAIT_READ;
  }
}

void read_master::set_ddr_memory(uint8_t* mem, uint32_t size){
  ddr_memory = (uint8_t*)malloc(sizeof(uint8_t)*size);
  std::memcpy(ddr_memory, mem, size*sizeof(uint8_t));
}
