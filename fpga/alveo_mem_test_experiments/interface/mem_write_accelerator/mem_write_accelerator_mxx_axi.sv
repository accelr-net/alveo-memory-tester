// This is a generated file. Use and modify at your own risk.
////////////////////////////////////////////////////////////////////////////////
// default_nettype of none prevents implicit wire declaration.
`default_nettype none

module mem_write_accelerator_mxx_axi #(
  parameter integer C_M_AXI_ADDR_WIDTH       = 64,
  parameter integer C_M_AXI_DATA_WIDTH       = 256,
  parameter integer C_XFER_SIZE_WIDTH        = 32,
  parameter integer C_ADDER_BIT_WIDTH        = 32,
  parameter integer ADDRESS_INCREMENT_SIZE   = 32,
  parameter integer MEM_ADDR_SIZE            = 32
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
  input wire [C_XFER_SIZE_WIDTH-1:0]            ctrl_xfer_size_in_bytes,
  input wire [C_ADDER_BIT_WIDTH-1:0]            ctrl_constant       ,
  input wire [ADDRESS_INCREMENT_SIZE-1:0]       addr_increment      ,
  input wire [MEM_ADDR_SIZE-1:0]                mem_max_addr
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
  
  // AXI write master stage
  logic                          write_done;
  logic                          write_out_data;    
  logic [C_M_AXI_ADDR_WIDTH-1:0] write_addr;
  logic [C_XFER_SIZE_WIDTH-1:0]  out_data_size;
  logic                          out_data_valid; //(1)
  logic                          out_data_ready; //(1)
  logic [C_M_AXI_DATA_WIDTH-1:0] out_data;
  
  ///////////////////////////////////////////////////////////////////////////////
  // Begin RTL
  ///////////////////////////////////////////////////////////////////////////////
  
  // AXI4 Read Master, output format is an AXI4-Stream master, one stream per thread.
  
  mem_write #(
      .C_AXIS_TDATA_WIDTH (C_M_AXI_DATA_WIDTH),
      .C_M_AXI_ADDR_WIDTH (C_M_AXI_ADDR_WIDTH),
      .C_XFER_SIZE_WIDTH  (C_XFER_SIZE_WIDTH ) 
  )
  inst_mem_write(
      //input signals
      .clk                (aclk               ),
      .reset              (areset             ),
      .start              (ap_start           ),
      .addr_increment     (addr_increment     ), //scalar input
      .mem_max_addr       (mem_max_addr       ), //scalar input
      .done               (ap_done            ),
      .out_data_base_addr (ctrl_addr_offset   ), //from m_axi, locate the start addr  
      //AXI4 read master interface
      .write_out_data     (write_out_data     ),
      .write_addr         (write_addr         ), //(1)
      .out_data_size      (out_data_size      ), //(1)
      .out_data_valid     (out_data_valid     ),
      .out_data_ready     (out_data_ready     ),
      .write_done         (write_done         ),
      .out_data           (out_data           )
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
    .ctrl_xfer_size_in_bytes ( out_data_size           ) ,
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
    .s_axis_aclk             ( aclk                    ) ,
    .s_axis_areset           ( areset                  ) ,
    .s_axis_tvalid           ( out_data_valid          ) ,
    .s_axis_tready           ( out_data_ready          ) ,
    .s_axis_tdata            ( out_data                )
  );
  
  // assign ap_done = write_done;
  
endmodule : mem_write_accelerator_mxx_axi
`default_nettype wire
