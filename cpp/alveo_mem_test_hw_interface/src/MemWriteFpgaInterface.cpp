#include <iostream>
#include <fstream>
#include <algorithm>
#include "MemWriteFpgaInterface.h"

MemWriteFpgaInterface::MemWriteFpgaInterface(){
}

MemWriteFpgaInterface::~MemWriteFpgaInterface() {
  queue->enqueueUnmapMemObject(*buffer_out_data , out_data_ptr);
  queue->finish();
}

void MemWriteFpgaInterface::initFpga(std::string xclbin)
{
  std::cout << "INFO: Initializing FPGA..." << std::endl;
  const char* xclbinFilename = xclbin.c_str();

  std::vector<cl::Device> devices;
  cl::Device device;
  std::vector<cl::Platform> platforms;
  bool found_device = false;

  //traversing all Platforms To find Xilinx Platform and targeted
  //Device in Xilinx Platform
  cl::Platform::get(&platforms);
  for(size_t i = 0; (i < platforms.size() ) & (found_device == false) ;i++){
      cl::Platform platform = platforms[i];
      std::string platformName = platform.getInfo<CL_PLATFORM_NAME>();
      if ( platformName == "Xilinx"){
          devices.clear();
          platform.getDevices(CL_DEVICE_TYPE_ACCELERATOR, &devices);
          if (devices.size()){
              device = devices[0];
              found_device = true;
              break;
          }
      }
  }
  if (found_device == false){
     std::cout << "Error: Unable to find Target Device "
         << device.getInfo<CL_DEVICE_NAME>() << std::endl;
     exit(1);
  }

  // Creating Context and Command Queue for selected device
  cl::Context context(device);
  queue = new cl::CommandQueue(context, device, CL_QUEUE_PROFILING_ENABLE);

  // Load xclbin
  std::cout << "Loading: '" << xclbinFilename << "'\n";
  std::ifstream bin_file(xclbinFilename, std::ifstream::binary);
  bin_file.seekg (0, bin_file.end);
  unsigned nb = bin_file.tellg();
  bin_file.seekg (0, bin_file.beg);
  char *buf = new char [nb];
  bin_file.read(buf, nb);

  // Creating Program from Binary File
  cl::Program::Binaries bins;
  bins.push_back({buf,nb});
  devices.resize(1);
  cl::Program program(context, devices, bins);

  // This call will get the kernel object from program. A kernel is an
  // OpenCL function that is executed on the FPGA.
  krnl_upper_filter = new cl::Kernel(program,"mem_write_accelerator");


  // These commands will allocate memory on the Device. The cl::Buffer objects can
  // be used to reference the memory locations on the device.
  buffer_out_data   = new cl::Buffer(context, CL_MEM_WRITE_ONLY, BUFF_SIZE*sizeof(uint8_t)); //write only purpose kernel buffer def
  
//  addr_increment = 32;
//  mem_max_addr = 256;
//  std::cout<<"data_out_size = 64 \n";
//  std::cout<<"mem_data_length = 1024 \n";
//
  std::cout<<"Enter addr_increment: ";
  std::cin>>addr_increment;

  std::cout<<"Enter mem_max_addr: ";
  std::cin>>mem_max_addr;

  //set the kernel Arguments
  krnl_upper_filter->setArg(0,addr_increment);
  krnl_upper_filter->setArg(1,mem_max_addr);
  krnl_upper_filter->setArg(2,*buffer_out_data);

  //We then need to map our OpenCL buffers to get the pointers
  out_data_ptr   = (uint8_t *) queue->enqueueMapBuffer (*buffer_out_data , CL_TRUE , CL_MAP_READ , 0, BUFF_SIZE*sizeof(uint8_t)); //read only purpose host ptr def

//  wait_for_enter("\nPress ENTER to continue after setting up ILA trigger...");
  
}

void MemWriteFpgaInterface::wait_for_enter(const std::string& msg){
  std::cout << msg << std::endl;
  std::cin.ignore(std::numeric_limits<std::streamsize>::max(), '\n');
}

void MemWriteFpgaInterface::runMemTest(){
  //Launch the Kernel
  queue->enqueueTask(*krnl_upper_filter);

  //Data will be migrated to kernel space
  queue->enqueueMigrateMemObjects({*buffer_out_data},CL_MIGRATE_MEM_OBJECT_HOST/* CL_MIGRATE_MEM_OBJECT_HOST means from fpga*/);


  //Wait for complete
  queue->finish();

}

void MemWriteFpgaInterface::ReadFromFpga()
{
  std::memcpy(buffData,out_data_ptr,BUFF_SIZE*sizeof(uint8_t));

  for(int i=0; i<BUFF_SIZE; i++){
    std::cout<<"buffData["<<i<<"] = "<<(uint32_t)buffData[i]<<std::endl;

  }



}

//For testing in the Xilinx Vitis setup
int main(int argc, char* argv[]){
  //TARGET_DEVICE macro needs to be passed from gcc command line
  if(argc != 2) {
      std::cout << "Usage: " << argv[0] <<" <xclbin>" << std::endl;
      return EXIT_FAILURE;
  }

  MemWriteFpgaInterface *dfi = new MemWriteFpgaInterface();
  std::string xclbin(argv[1]);
  dfi->initFpga(xclbin);
  dfi->runMemTest();
  dfi->ReadFromFpga();
}
