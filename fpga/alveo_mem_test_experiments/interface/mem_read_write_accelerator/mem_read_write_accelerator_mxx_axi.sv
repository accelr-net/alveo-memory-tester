// This is a generated file. Use and modify at your own risk.
////////////////////////////////////////////////////////////////////////////////
// default_nettype of none prevents implicit wire declaration.
`default_nettype none

module mem_read_write_accelerator_mxx_axi #(
  parameter integer C_M_AXI_ADDR_WIDTH       = 64 ,
  parameter integer C_M_AXI_DATA_WIDTH       = 512,
  parameter integer C_XFER_SIZE_WIDTH        = 32,
  parameter integer C_ADDER_BIT_WIDTH        = 32
)
(
  // System Signals
  input wire                                    aclk               ,
  input wire                                    areset             ,
  // Extra clocks
  input wire                                    kernel_clk         ,
  input wire                                    kernel_rst         ,
  // AXI4 master interface
  output wire                                   m_axi_awvalid      ,
  input wire                                    m_axi_awready      ,
  output wire [C_M_AXI_ADDR_WIDTH-1:0]          m_axi_awaddr       ,
  output wire [8-1:0]                           m_axi_awlen        ,
  output wire                                   m_axi_wvalid       ,
  input wire                                    m_axi_wready       ,
  output wire [C_M_AXI_DATA_WIDTH-1:0]          m_axi_wdata        ,
  output wire [C_M_AXI_DATA_WIDTH/8-1:0]        m_axi_wstrb        ,
  output wire                                   m_axi_wlast        ,
  output wire                                   m_axi_arvalid      ,
  input wire                                    m_axi_arready      ,
  output wire [C_M_AXI_ADDR_WIDTH-1:0]          m_axi_araddr       ,
  output wire [8-1:0]                           m_axi_arlen        ,
  input wire                                    m_axi_rvalid       ,
  output wire                                   m_axi_rready       ,
  input wire [C_M_AXI_DATA_WIDTH-1:0]           m_axi_rdata        ,
  input wire                                    m_axi_rlast        ,
  input wire                                    m_axi_bvalid       ,
  output wire                                   m_axi_bready       ,
  input wire                                    ap_start           ,
  output wire                                   ap_done            ,
  input wire [32-1:0]                           addr_increment     ,
  input wire [32-1:0]                           mem_max_addr       ,           
  input wire [C_M_AXI_ADDR_WIDTH-1:0]           ctrl_addr_offset_read,   
  input wire [C_M_AXI_ADDR_WIDTH-1:0]           ctrl_addr_offset_write, 
  input wire [C_XFER_SIZE_WIDTH-1:0]            ctrl_xfer_size_in_bytes,
  input wire [C_ADDER_BIT_WIDTH-1:0]            ctrl_constant
);

timeunit 1ps;
timeprecision 1ps;


///////////////////////////////////////////////////////////////////////////////
// Local Parameters
///////////////////////////////////////////////////////////////////////////////
localparam integer LP_DW_BYTES             = C_M_AXI_DATA_WIDTH/8;
localparam integer LP_AXI_BURST_LEN        = 4096/LP_DW_BYTES < 256 ? 4096/LP_DW_BYTES : 256;
localparam integer LP_LOG_BURST_LEN        = $clog2(LP_AXI_BURST_LEN);
localparam integer LP_BRAM_DEPTH           = 512;
localparam integer LP_RD_MAX_OUTSTANDING   = LP_BRAM_DEPTH / LP_AXI_BURST_LEN;
localparam integer LP_WR_MAX_OUTSTANDING   = 32;

///////////////////////////////////////////////////////////////////////////////
// Wires and Variables
///////////////////////////////////////////////////////////////////////////////

// Control logic
logic                          done = 1'b0;
// AXI read master stage
logic [C_M_AXI_ADDR_WIDTH-1:0] read_addr;
logic                          start_reading;
logic [C_XFER_SIZE_WIDTH-1:0 ] read_data_size;
logic                          read_done;
logic                          rd_tvalid;
logic                          rd_tready;
logic                          rd_tlast;
logic [C_M_AXI_DATA_WIDTH-1:0] rd_tdata;
// Adder stage
logic                          adder_tvalid;
logic                          adder_tready;

// AXI write master stage
logic                          write_done;
logic                          write_out_data;    
logic [C_M_AXI_ADDR_WIDTH-1:0] write_addr;
logic [C_XFER_SIZE_WIDTH-1:0]  write_data_size;
logic                          out_data_valid; //(1)
logic                          out_data_ready; //(1)
logic [C_M_AXI_DATA_WIDTH-1:0] out_data;

///////////////////////////////////////////////////////////////////////////////
// Begin RTL
///////////////////////////////////////////////////////////////////////////////

// AXI4 Read Master, output format is an AXI4-Stream master, one stream per thread.
axi_read_master #(
  .C_M_AXI_ADDR_WIDTH  ( C_M_AXI_ADDR_WIDTH    ) ,
  .C_M_AXI_DATA_WIDTH  ( C_M_AXI_DATA_WIDTH    ) ,
  .C_XFER_SIZE_WIDTH   ( C_XFER_SIZE_WIDTH     ) ,
  .C_MAX_OUTSTANDING   ( LP_RD_MAX_OUTSTANDING ) ,
  .C_INCLUDE_DATA_FIFO ( 1                     )
)
inst_axi_read_master (
  .aclk                    ( aclk                    ) ,
  .areset                  ( areset                  ) ,
  .ctrl_start              ( start_reading           ) ,
  .ctrl_done               ( read_done               ) ,
  .ctrl_addr_offset        ( read_addr               ) ,
  .ctrl_xfer_size_in_bytes ( read_data_size          ) ,
  .m_axi_arvalid           ( m_axi_arvalid           ) ,
  .m_axi_arready           ( m_axi_arready           ) ,
  .m_axi_araddr            ( m_axi_araddr            ) ,
  .m_axi_arlen             ( m_axi_arlen             ) ,
  .m_axi_rvalid            ( m_axi_rvalid            ) ,
  .m_axi_rready            ( m_axi_rready            ) ,
  .m_axi_rdata             ( m_axi_rdata             ) ,
  .m_axi_rlast             ( m_axi_rlast             ) ,
  .m_axis_aclk             ( kernel_clk              ) ,
  .m_axis_areset           ( kernel_rst              ) ,
  .m_axis_tvalid           ( rd_tvalid               ) ,
  .m_axis_tready           ( rd_tready               ) ,
  .m_axis_tlast            ( rd_tlast                ) ,
  .m_axis_tdata            ( rd_tdata                )
);

mem_read_write #(
    //mem read parameters

    .READ_DATA_SIZE (),
    .READ_BASE_ADDRESS_WIDTH (),
    .READ_ADDRESS_INCREMENT_SIZE (),
    .READ_MEM_MAX_ADDR_SIZE (),
    .READ_MEM_ADDR_SIZE  (),

    //mem write parameters

    .WRITE_DATA_SIZE (),
    .WRITE_BASE_ADDRESS_WIDTH (),
    .WRITE_ADDRESS_INCREMENT_SIZE (),
    .WRITE_MEM_MAX_ADDR_SIZE (),
    .WRITE_MEM_ADDR_SIZE (),

    //common parameters
    .MEM_DATA_COUNT (),
    .MEM_DATA_ADDR_SIZE (),
    .C_AXIS_TDATA_WIDTH  (C_M_AXI_DATA_WIDTH),
    .C_M_AXI_ADDR_WIDTH (C_M_AXI_ADDR_WIDTH),
    .C_XFER_SIZE_WIDTH  (C_XFER_SIZE_WIDTH ),
    .WR_PTR_SIZE (),
    .WIRE_INCR  ()
  ) inst_mem_read_write
  (
      .clk                  (aclk               ),
      .reset                (areset             ),
      .start                (ap_start           ), //system start signal
      //read input part
      .read_data_base_addr   (ctrl_addr_offset_read),
      .read_addr_increment   (addr_increment     ),
      .read_mem_max_addr     (mem_max_addr),
      //AXI4 read master interface
      .read_data             (rd_tdata),
      .read_data_valid       (rd_tvalid), //(1)
      .start_reading_data    (start_reading), //(1)
      .read_addr             (read_addr),
      .read_data_size        (read_data_size),
      .data_read_done        (read_done), //(1)
      .read_data_ready       (rd_tready), //(1)

      .write_data_base_addr  (ctrl_addr_offset_write), //input 64
      .write_addr_increment  (addr_increment),
      .write_mem_max_addr    (mem_max_addr),
      //AXI4 write master interface
      .start_writing_data    (write_out_data), //(1) //output 1
      .write_addr            (write_addr), //output 64
      .write_data_size       (write_data_size), //output 32
      .write_data_valid      (out_data_valid), //(1) //output 1
      .write_data_ready      (out_data_ready), //(1) //input 1
      .data_write_done       (write_done),
      .write_data            (out_data), //output 256
      .done                  (ap_done) //system process done signal
  );

// AXI4 Write Master
axi_write_master #(
  .C_M_AXI_ADDR_WIDTH  ( C_M_AXI_ADDR_WIDTH    ) ,
  .C_M_AXI_DATA_WIDTH  ( C_M_AXI_DATA_WIDTH    ) ,
  .C_XFER_SIZE_WIDTH   ( C_XFER_SIZE_WIDTH     ) ,
  .C_MAX_OUTSTANDING   ( LP_WR_MAX_OUTSTANDING ) ,
  .C_INCLUDE_DATA_FIFO ( 1                     )
)
inst_axi_write_master (
  .aclk                    ( aclk                    ) ,
  .areset                  ( areset                  ) ,
  .ctrl_start              ( write_out_data          ) ,
  .ctrl_done               ( write_done              ) ,
  .ctrl_addr_offset        ( write_addr              ) ,
  .ctrl_xfer_size_in_bytes ( write_data_size         ) ,
  .m_axi_awvalid           ( m_axi_awvalid           ) ,
  .m_axi_awready           ( m_axi_awready           ) ,
  .m_axi_awaddr            ( m_axi_awaddr            ) ,
  .m_axi_awlen             ( m_axi_awlen             ) ,
  .m_axi_wvalid            ( m_axi_wvalid            ) ,
  .m_axi_wready            ( m_axi_wready            ) ,
  .m_axi_wdata             ( m_axi_wdata             ) ,
  .m_axi_wstrb             ( m_axi_wstrb             ) ,
  .m_axi_wlast             ( m_axi_wlast             ) ,
  .m_axi_bvalid            ( m_axi_bvalid            ) ,
  .m_axi_bready            ( m_axi_bready            ) ,
  .s_axis_aclk             ( kernel_clk              ) ,
  .s_axis_areset           ( kernel_rst              ) ,
  .s_axis_tvalid           ( out_data_valid          ) ,
  .s_axis_tready           ( out_data_ready          ) ,
  .s_axis_tdata            ( out_data                )
);

//assign ap_done = write_done;

endmodule : mem_read_write_accelerator_mxx_axi
`default_nettype wire

