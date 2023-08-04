#ifndef READ_MASTER_H
#define READ_MASTER_H

#include <stdint.h>
#include <iostream>
#include <random>

#define DDR_READ_DELAY 45

class read_master
{
public:
  read_master();

public:
  virtual ~read_master();

protected:
  enum STATE
  {
    WAIT_READ,
    READ_DATA
  };

  std::string state_table[2] = {
    "WAIT_READ",
    "READ_DATA"
  };
  
  uint8_t* ddr_memory;

  uint32_t state = WAIT_READ;
  uint64_t read_address = 0;
  uint32_t read_size = 0;
  uint32_t read_counter = 0;

  uint32_t delay_counter = 0;
  

public:
  void execute(
    uint8_t*  data,
    uint8_t*  data_valid, //(1)
    uint8_t   start, //(1)
    uint64_t  address,
    uint32_t  size,
    uint8_t*  done, //(1)
    uint8_t   read_ready, //(1)
    uint8_t*  data_last //(1)
  );
  void set_ddr_memory(uint8_t* mem, uint32_t size);
};

#endif //READ_MASTER_H