#ifndef WRITE_MASTER_H
#define WRITE_MASTER_H

#include <stdint.h>

class write_master
{
public:
  write_master();
public:
  virtual ~write_master();

protected:
  enum STATE
  {
    WAIT_WRITE,
    WRITE_DATA
  };

  std::string state_table[2] = {
    "WAIT_WRITE",
    "WRITE_DATA"
  };
  
  uint8_t ddr_memory[8192] = {0};

  uint32_t state = WAIT_WRITE;
  uint64_t write_address = 0;
  uint32_t write_size = 0;
  uint32_t write_counter = 0;
  uint8_t   write_ready_reg = 0;

public:
  void execute(
    uint8_t  start,
    uint64_t  address,
    uint32_t  size,
    uint8_t* data,
    uint8_t  data_valid,
    uint8_t* done,
    uint8_t* write_ready
  );

  void get_ddr_memory(uint8_t* mem, uint32_t size);
};


#endif //WRITE_MASTER_H