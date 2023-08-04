// This is a generated file. Use and modify at your own risk.
////////////////////////////////////////////////////////////////////////////////
// default_nettype of none prevents implicit wire declaration.
`default_nettype none

module mem_read_accelerator_mxx_axi #(
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
  input wire [C_M_AXI_ADDR_WIDTH-1:0]           ctrl_addr_offset   ,
  input  wire [32-1:0]                          addr_incr          ,
  input  wire [32-1:0]                          mem_max_addr
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
logic                          read_done;
logic                          rd_tvalid;
logic                          rd_tready;
logic                          rd_tlast;
logic [C_M_AXI_DATA_WIDTH-1:0] rd_tdata;
// Adder stage
logic                          adder_tvalid;
logic                          adder_tready;
logic [C_M_AXI_DATA_WIDTH-1:0] adder_tdata;

// AXI write master stage
logic                          write_done;

// wires for interconnections

logic                          fetch_to_start;
logic [C_M_AXI_ADDR_WIDTH-1:0] data_rd_addr_to_cao;
logic [C_XFER_SIZE_WIDTH-1:0]  data_rd_size_to_cxsib;

///////////////////////////////////////////////////////////////////////////////
// Begin RTL
///////////////////////////////////////////////////////////////////////////////

// AXI4 Read Master, output format is an AXI4-Stream master, one stream per thread.
axi_read_master #(
  .C_M_AXI_ADDR_WIDTH      ( C_M_AXI_ADDR_WIDTH      ) ,
  .C_M_AXI_DATA_WIDTH      ( C_M_AXI_DATA_WIDTH      ) ,
  .C_XFER_SIZE_WIDTH       ( C_XFER_SIZE_WIDTH       ) ,
  .C_MAX_OUTSTANDING       ( LP_RD_MAX_OUTSTANDING   ) ,
  .C_INCLUDE_DATA_FIFO     ( 1                       )
)
inst_axi_read_master (
  .aclk                    ( aclk                    ) ,
  .areset                  ( areset                  ) ,
  .ctrl_start              ( fetch_to_start          ) ,
  .ctrl_done               ( read_done               ) ,
  .ctrl_addr_offset        ( data_rd_addr_to_cao     ) ,
  .ctrl_xfer_size_in_bytes ( data_rd_size_to_cxsib   ) ,
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


mem_read #( 
  .C_AXIS_TDATA_WIDTH ( C_M_AXI_DATA_WIDTH ),
  .C_M_AXI_ADDR_WIDTH ( C_M_AXI_ADDR_WIDTH ),
  .C_XFER_SIZE_WIDTH  ( C_XFER_SIZE_WIDTH  )
) inst_mem_read
(
  //input signals
  .clk                ( kernel_clk         ),
  .reset              ( kernel_rst         ),
  .start              ( ap_start           ),
  .base_address       ( ctrl_addr_offset   ),
  .addr_increment     ( addr_incr          ),
  .mem_max_addr       ( mem_max_addr       ),
  .done               ( ap_done            ),
  //AXI4 read master interface
  .data_in            ( rd_tdata              ),
  .data_valid         ( rd_tvalid             ), //(1)
  .fetch_data         ( fetch_to_start        ), //(1)
  .data_rd_addr       ( data_rd_addr_to_cao   ),
  .data_rd_size       ( data_rd_size_to_cxsib ),
  .data_read_done     ( read_done             ), //(1)
  .data_read_ready    ( rd_tready             ) //(1)
);

// AXI4 Write Master
// axi_write_master #(
//   .C_M_AXI_ADDR_WIDTH  ( C_M_AXI_ADDR_WIDTH    ) ,
//   .C_M_AXI_DATA_WIDTH  ( C_M_AXI_DATA_WIDTH    ) ,
//   .C_XFER_SIZE_WIDTH   ( C_XFER_SIZE_WIDTH     ) ,
//   .C_MAX_OUTSTANDING   ( LP_WR_MAX_OUTSTANDING ) ,
//   .C_INCLUDE_DATA_FIFO ( 1                     )
// )
// inst_axi_write_master (
//   .aclk                    ( aclk                    ) ,
//   .areset                  ( areset                  ) ,
//   .ctrl_start              ( ap_start                ) ,
//   .ctrl_done               ( write_done              ) ,
//   .ctrl_addr_offset        ( ctrl_addr_offset        ) ,
//   .ctrl_xfer_size_in_bytes ( ctrl_xfer_size_in_bytes ) ,
//   .m_axi_awvalid           ( m_axi_awvalid           ) ,
//   .m_axi_awready           ( m_axi_awready           ) ,
//   .m_axi_awaddr            ( m_axi_awaddr            ) ,
//   .m_axi_awlen             ( m_axi_awlen             ) ,
//   .m_axi_wvalid            ( m_axi_wvalid            ) ,
//   .m_axi_wready            ( m_axi_wready            ) ,
//   .m_axi_wdata             ( m_axi_wdata             ) ,
//   .m_axi_wstrb             ( m_axi_wstrb             ) ,
//   .m_axi_wlast             ( m_axi_wlast             ) ,
//   .m_axi_bvalid            ( m_axi_bvalid            ) ,
//   .m_axi_bready            ( m_axi_bready            ) ,
//   .s_axis_aclk             ( kernel_clk              ) ,
//   .s_axis_areset           ( kernel_rst              ) ,
//   .s_axis_tvalid           ( adder_tvalid            ) ,
//   .s_axis_tready           ( adder_tready            ) ,
//   .s_axis_tdata            ( adder_tdata             )
// );

endmodule : mem_read_accelerator_mxx_axi
`default_nettype wire

