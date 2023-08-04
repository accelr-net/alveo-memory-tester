// ************************************************************************************************************************
//
// Copyright(C) 2022 ACCELR
// All rights reserved.
//
// THIS IS UNPUBLISHED PROPRIETARY SOURCE CODE OF
// ACCELER LOGIC (PVT) LTD, SRI LANKA.
//
// This copy of the Source Code is intended for ACCELR's internal use only and is
// intended for view by persons duly authorized by the management of ACCELR. No
// part of this file may be reproduced or distributed in any form or by any
// means without the written approval of the Management of ACCELR.
//
// ACCELR, Sri Lanka            https://accelr.lk
// No 175/95, John Rodrigo Mw,  info@accelr.net
// Katubedda, Sri Lanka         +94 77 3166850
//
// ************************************************************************************************************************
//
// PROJECT      :   Daax_Experiment
// PRODUCT      :   mem_read_write
// FILE         :   mem_read_write.sv
// AUTHOR       :   Sachith_Rathnayake
// DESCRIPTION  :   testing
//
// ************************************************************************************************************************
//
// REVISIONS:
//
//  Date           Developer               Description
//  -----------    --------------------    -----------
//  25-Jun-2023    Sachith Rathnayake      Creation
//
//
//*************************************************************************************************************************
`timescale 1ns/1ps

module mem_read_write #(
    parameter C_AXIS_TDATA_WIDTH              = 256,
    parameter C_M_AXI_ADDR_WIDTH              = 64,
    parameter C_XFER_SIZE_WIDTH               = 32,
    
    //mem read parameters

    parameter READ_DATA_SIZE                  = 32,
    parameter READ_BASE_ADDRESS_WIDTH         = 64,
    parameter READ_ADDRESS_INCREMENT_SIZE     = 32,
    parameter READ_MEM_MAX_ADDR_SIZE          = 32,
    parameter READ_MEM_ADDR_SIZE              = 32,

    //mem write parameters

    parameter WRITE_DATA_SIZE                 = 32,
    parameter WRITE_BASE_ADDRESS_WIDTH        = 64,
    parameter WRITE_ADDRESS_INCREMENT_SIZE    = 32,
    parameter WRITE_MEM_MAX_ADDR_SIZE         = 32,
    parameter WRITE_MEM_ADDR_SIZE             = 32,

    //common parameters
    parameter MEM_DATA_COUNT                  = 1024,
    parameter MEM_DATA_ADDR_SIZE              = 8,
    parameter WR_PTR_SIZE                     = 32
)
(
    clk,
    reset,
    start, //system start signal
    //read input part
    read_data_base_addr,
    read_addr_increment,
    read_mem_max_addr,
    //AXI4 read master interface
    read_data,
    read_data_valid, //(1)
    start_reading_data, //(1)
    read_addr,
    read_data_size,
    data_read_done, //(1)
    read_data_ready, //(1)

    write_data_base_addr, //input 64
    write_addr_increment,
    write_mem_max_addr,
    //AXI4 write master interface
    start_writing_data, //(1) //output 1
    write_addr, //output 64
    write_data_size, //output 32
    write_data_valid, //(1) //output 1
    write_data_ready, //(1) //input 1
    data_write_done,
    write_data, //output 256
    done //system process done signal
);

    //---------------------------------------------------------------------------------------------------------------------
    // Global constant headers
    //---------------------------------------------------------------------------------------------------------------------
    
    
    
    //---------------------------------------------------------------------------------------------------------------------
    // parameter definitions
    //---------------------------------------------------------------------------------------------------------------------
    
    
    
    //---------------------------------------------------------------------------------------------------------------------
    // localparam definitions
    //---------------------------------------------------------------------------------------------------------------------
    
    
    
    //---------------------------------------------------------------------------------------------------------------------
    // type definitions
    //---------------------------------------------------------------------------------------------------------------------
    
    typedef enum logic [3:0] {
        IDLE,
        READ_DATA_FROM_DDR,
        PROCESS_DATA,
        WRITE_DATA_TO_DDR
    } READ_WRITE_STATE;
    
    //---------------------------------------------------------------------------------------------------------------------
    // I/O signals
    //---------------------------------------------------------------------------------------------------------------------
    
    input  logic                                         clk;
    input  logic                                         reset;
    input  logic                                         start; //system start signal
    //read input part
    input  logic     [READ_BASE_ADDRESS_WIDTH-1:0     ]  read_data_base_addr;
    input  logic     [READ_ADDRESS_INCREMENT_SIZE-1:0 ]  read_addr_increment;
    input  logic     [READ_MEM_MAX_ADDR_SIZE-1:0      ]  read_mem_max_addr;
    //AXI4 read master interface
    input  logic     [C_AXIS_TDATA_WIDTH-1:0          ]  read_data;
    input  logic                                         read_data_valid; //(1)
    output logic                                         start_reading_data; //(1)
    output logic     [C_M_AXI_ADDR_WIDTH-1:0          ]  read_addr;
    output logic     [C_XFER_SIZE_WIDTH-1:0           ]  read_data_size;
    input  logic                                         data_read_done; //(1)
    output logic                                         read_data_ready; //(1)

    input  logic     [WRITE_BASE_ADDRESS_WIDTH-1:0    ]  write_data_base_addr; //input 64
    input  logic     [WRITE_ADDRESS_INCREMENT_SIZE-1:0]  write_addr_increment;
    input  logic     [WRITE_MEM_MAX_ADDR_SIZE-1:0     ]  write_mem_max_addr;
    //AXI4 write master interface
    output logic                                         start_writing_data; //(1) //output 1
    output logic     [C_M_AXI_ADDR_WIDTH-1:0          ]  write_addr; //output 64
    output logic     [C_XFER_SIZE_WIDTH-1:0           ]  write_data_size; //output 32
    output logic                                         write_data_valid; //(1) //output 1
    input  logic                                         write_data_ready; //(1) //input 1
    input  logic                                         data_write_done;
    output logic     [C_AXIS_TDATA_WIDTH-1:0          ]  write_data; //output 256
    output logic                                         done; //system process done signal
    
    //---------------------------------------------------------------------------------------------------------------------
    // Internal signals
    //---------------------------------------------------------------------------------------------------------------------
    
    //read flags
    logic                                   read_done;
    
    //write flags
    logic                                   write_done;

    //mem_read_write flags and memories
    logic                                   read_start;
    logic                                   write_start;
    READ_WRITE_STATE                        read_write_state;
    logic       [WR_PTR_SIZE-1:0]           mem_addr;
    logic       [WR_PTR_SIZE-1:0]           wr_ptr;
    logic       [WR_PTR_SIZE-1:0]           transfer_ctr;
    logic       [MEM_DATA_ADDR_SIZE-1:0]    mem_data_copy       [0:MEM_DATA_COUNT-1];
    logic       [MEM_DATA_ADDR_SIZE-1:0]    processed_mem_data  [0:MEM_DATA_COUNT-1];
    logic       [MEM_DATA_ADDR_SIZE-1:0]    memory              [0:MEM_DATA_COUNT-1];
    
    //---------------------------------------------------------------------------------------------------------------------
    // Implementation
    //---------------------------------------------------------------------------------------------------------------------
    
    always_ff @( posedge clk ) begin : mem_read_write_fsm
        if (reset) begin
            done               <= 0;
            mem_addr           <= 0;
            wr_ptr             <= 0;
            transfer_ctr       <= 0;
            read_write_state   <= IDLE;

        end else begin
            unique case (read_write_state)
                IDLE: begin
                    done               <= 0;
                    mem_addr           <= 0;
                    wr_ptr             <= 0;
                    transfer_ctr       <= 0;
                    write_start        <= 0;
                    read_start         <= 0;
                    for(int i = 0; i < MEM_DATA_COUNT; i++) begin
                        memory[i]               <=  {MEM_DATA_ADDR_SIZE{1'b0}};
                    end
                    if (start) begin
                        read_write_state <= READ_DATA_FROM_DDR;
                        read_start       <= 1;
                    end
                    else begin
                        read_write_state <= IDLE;
                    end
                end
                READ_DATA_FROM_DDR: begin
                    read_start  <= 0;
                    if (read_done) begin
                        read_write_state <= PROCESS_DATA;
                    end
                    else begin
                        read_write_state <= READ_DATA_FROM_DDR;
                    end
                end
                PROCESS_DATA: begin
                    for(int i = 0; i < MEM_DATA_COUNT; i++) begin
                        memory[i] <=  mem_data_copy[i];
                    end
                    
                    
                    write_start         <= 1;
                    read_write_state    <= WRITE_DATA_TO_DDR;
                end
                WRITE_DATA_TO_DDR: begin
                    write_start         <= 0;
                    if (write_done) begin
                        done    <= 1;
                        read_write_state <= IDLE;
                    end
                    else begin
                        read_write_state <= WRITE_DATA_TO_DDR;
                    end
                end
                default: begin
                    read_write_state <= IDLE;
                end 
            endcase
        end
    end
    
    assign processed_mem_data = memory;
    
    mem_read #(
        .C_AXIS_TDATA_WIDTH ( C_AXIS_TDATA_WIDTH ),
        .C_M_AXI_ADDR_WIDTH ( C_M_AXI_ADDR_WIDTH ),
        .C_XFER_SIZE_WIDTH  ( C_XFER_SIZE_WIDTH  ),

        .READ_DATA_SIZE(READ_DATA_SIZE),              
        .READ_BASE_ADDRESS_WIDTH(READ_BASE_ADDRESS_WIDTH),     
        .READ_ADDRESS_INCREMENT_SIZE(READ_ADDRESS_INCREMENT_SIZE), 
        .READ_MEM_MAX_ADDR_SIZE(READ_MEM_MAX_ADDR_SIZE),      
        .READ_MEM_ADDR_SIZE(READ_MEM_ADDR_SIZE),          
        
        .MEM_DATA_COUNT(MEM_DATA_COUNT),              
        .MEM_DATA_ADDR_SIZE(MEM_DATA_ADDR_SIZE),          
        .WR_PTR_SIZE(WR_PTR_SIZE)
    )
    mem_read_inst(
        //input signals
        .clk(clk),
        .reset(reset),
        .start(read_start),
        .base_address(read_data_base_addr),
        .addr_increment(read_addr_increment), //scalar input
        .mem_max_addr(read_mem_max_addr), //scalar input
        //output signals
        .done(read_done),
        //AXI4 read master interface
        .data_in(read_data),
        .data_valid(read_data_valid), 
        .fetch_data(start_reading_data), 
        .data_rd_addr(read_addr),
        .data_rd_size(read_data_size),
        .data_read_done(data_read_done), 
        .data_read_ready(read_data_ready), 
        .mem_data(mem_data_copy)
    );

    mem_write #(
        .C_AXIS_TDATA_WIDTH ( C_AXIS_TDATA_WIDTH ),
        .C_M_AXI_ADDR_WIDTH ( C_M_AXI_ADDR_WIDTH ),
        .C_XFER_SIZE_WIDTH  ( C_XFER_SIZE_WIDTH  ),

        .WRITE_DATA_SIZE(WRITE_DATA_SIZE),             
        .WRITE_BASE_ADDRESS_WIDTH(WRITE_BASE_ADDRESS_WIDTH),    
        .WRITE_ADDRESS_INCREMENT_SIZE(WRITE_ADDRESS_INCREMENT_SIZE),
        .WRITE_MEM_MAX_ADDR_SIZE(WRITE_MEM_MAX_ADDR_SIZE),     
        .WRITE_MEM_ADDR_SIZE(WRITE_MEM_ADDR_SIZE),         
        
        .MEM_DATA_COUNT(MEM_DATA_COUNT),              
        .MEM_DATA_ADDR_SIZE(MEM_DATA_ADDR_SIZE),          
        .WR_PTR_SIZE(WR_PTR_SIZE)
    ) 
    mem_write_inst (
        //input signals
        .clk(clk),
        .reset(reset),
        .start(write_start),
        .out_data_base_addr(write_data_base_addr),
        .addr_increment(write_addr_increment), //scalar input
        .mem_max_addr(write_mem_max_addr), //scalar input
        .done(write_done),
        //AXI4 read master interface
        .write_out_data(start_writing_data),
        .write_addr(write_addr), 
        .out_data_size(write_data_size), 
        .out_data_valid(write_data_valid),
        .out_data_ready(write_data_ready),
        .write_done(data_write_done),
        .out_data(write_data),
        .mem_data(processed_mem_data)
    );
    
endmodule