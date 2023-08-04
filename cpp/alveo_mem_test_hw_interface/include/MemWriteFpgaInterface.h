#ifndef MEMREADFPGAINTERFACE_H
#define MEMREADFPGAINTERFACE_H

#define CL_HPP_CL_1_2_DEFAULT_BUILD
#define CL_HPP_TARGET_OPENCL_VERSION 120
#define CL_HPP_MINIMUM_OPENCL_VERSION 120
#define CL_HPP_ENABLE_PROGRAM_CONSTRUCTION_FROM_ARRAY_COMPATIBILITY 1

#include <byteswap.h>
#include <CL/cl2.hpp>
#include <locale>
#include <string>
#include <iostream>
#include <fstream>
#include <sys/stat.h>

#define BUFF_SIZE 2048


class MemWriteFpgaInterface{
public:
  MemWriteFpgaInterface();

public:
  virtual ~MemWriteFpgaInterface();

protected:

//  uint64_t BUFF_SIZE = 1024;

  uint8_t buffData[BUFF_SIZE];

  cl::CommandQueue *queue;
  cl::Kernel *krnl_upper_filter;
  cl::Buffer *buffer_out_data;
  
  uint8_t *out_data_ptr;
  uint32_t addr_increment;
  uint32_t mem_max_addr;

public:
  void initFpga(std::string xclbin);
  void ReadFromFpga();
  void runMemTest();
      
private:

void wait_for_enter(const std::string& msg);

  //Customized buffer allocation for 4K boundary alignment
  template <typename T>
  struct aligned_allocator
  {
    using value_type = T;
    T* allocate(std::size_t num)
    {
      void* ptr = nullptr;
      if (posix_memalign(&ptr,4096,num*sizeof(T)))
        throw std::bad_alloc();
      return reinterpret_cast<T*>(ptr);
    }
    void deallocate(T* p, std::size_t num)
    {
      free(p);
    }
  };
};

#endif // MEMREADFPGAINTERFACE_H
