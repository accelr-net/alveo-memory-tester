`timescale 1ns/1ps

module mem_write #(
    parameter C_AXIS_TDATA_WIDTH              = 256,
    parameter C_M_AXI_ADDR_WIDTH              = 64,
    parameter C_XFER_SIZE_WIDTH               = 32,

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
    //input signals
    clk,
    reset,
    start,
    out_data_base_addr,
    addr_increment, //scalar input
    mem_max_addr, //scalar input
    done,
    //AXI4 read master interface
    write_out_data,
    write_addr, //(1)
    out_data_size, //(1)
    out_data_valid,
    out_data_ready,
    write_done,
    out_data, //(1) AXI data argument
    mem_data
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
    
    localparam PTR_INCR     = C_AXIS_TDATA_WIDTH/MEM_DATA_ADDR_SIZE;
    localparam WIRE_INCR    = (PTR_INCR<MEM_DATA_COUNT)?PTR_INCR:MEM_DATA_COUNT;
    
    //---------------------------------------------------------------------------------------------------------------------
    // type definitions
    //---------------------------------------------------------------------------------------------------------------------
    
    typedef enum logic [3:0] { 
        IDLE,
        SET_WRITE_PARA,
        WRITE_DATA,
        WRITE_WAIT
    } state_t;
    
    //---------------------------------------------------------------------------------------------------------------------
    // I/O signals
    //---------------------------------------------------------------------------------------------------------------------
    
    //input signals
    input   logic                                       clk;
    input   logic                                       reset;
    input   logic                                       start;
    input   logic [WRITE_BASE_ADDRESS_WIDTH-1:0]        out_data_base_addr;
    input   logic [WRITE_ADDRESS_INCREMENT_SIZE-1:0]    addr_increment;
    input   logic [WRITE_MEM_MAX_ADDR_SIZE-1:0]         mem_max_addr;
    //output signals
    output  logic                                       done;
    //AXI4 write master interface
    output  logic                                       write_out_data;    
    output  logic [C_M_AXI_ADDR_WIDTH-1:0]              write_addr;
    output  logic [C_XFER_SIZE_WIDTH-1:0]               out_data_size;
    output  logic                                       out_data_valid; //(1)
    input   logic                                       out_data_ready; //(1)
    input   logic                                       write_done;
    output  logic [C_AXIS_TDATA_WIDTH-1:0]              out_data;
    input   logic [MEM_DATA_ADDR_SIZE-1:0]              mem_data[0:MEM_DATA_COUNT-1];
    
    
    //---------------------------------------------------------------------------------------------------------------------
    // Internal signals
    //---------------------------------------------------------------------------------------------------------------------
    
    state_t state = IDLE;

    logic                           fetch_done;
    logic [WRITE_MEM_ADDR_SIZE-1:0] mem_addr;
    logic [WR_PTR_SIZE-1:0]         wr_ptr = 0;
    logic [WR_PTR_SIZE-1:0]         transfer_ctr;
    
    //---------------------------------------------------------------------------------------------------------------------
    // Implementation
    //---------------------------------------------------------------------------------------------------------------------
    
    //uncomment the below for mem_write COCOTB simulation and comment for HW Emulation and Run in Hardware and mem_read_write COCTB test
    for (genvar t=0; t<MEM_DATA_COUNT; t++) begin
        assign mem_data[t] = (t<256)?t:t%256;
    end
    // ----------------------------------------------------------------------------------------
    

    always_ff @( posedge clk ) begin : FETCH_WRITE_FSM
        if(reset) begin
            write_out_data      <= 0;
            write_addr          <= 0;
            out_data_size       <= 0;
            out_data_valid      <= 0;
            out_data            <= 0;
            mem_addr            <= 0;
            done                <= 0;
            wr_ptr              <= 0;
            transfer_ctr        <= 0;
            state               <= IDLE;
        end else begin
            unique case (state)
                IDLE: begin
                    write_out_data  <= 0;
                    write_addr      <= 0;
                    out_data_size   <= 0;
                    out_data_valid  <= 0;
                    out_data        <= 0;
                    mem_addr        <= 0;
                    done            <= 0;
                    wr_ptr          <= 0;
                    transfer_ctr    <= 0;
                    if (start) begin
                        state   <= SET_WRITE_PARA;
                    end
                    else begin
                        state   <= IDLE;
                    end
                end
                SET_WRITE_PARA: begin
                    if(addr_increment + mem_addr>mem_max_addr) begin
                        done    <= 1;
                        state   <= IDLE;
                    end
                    else if (mem_max_addr == 0 || addr_increment == 0) begin
                        done    <= 1;
                        state   <= IDLE;
                    end
                    else begin
                        write_addr      <= out_data_base_addr + mem_addr;
                        out_data_size   <= WRITE_DATA_SIZE;
                        mem_addr        <= addr_increment + mem_addr;
                        write_out_data  <= 1;
                        state           <= WRITE_DATA;
                    end
                end
                WRITE_DATA: begin
                    write_out_data <= 0;
                    if (out_data_ready) begin
                        if (transfer_ctr >= WRITE_DATA_SIZE) begin
                            state           <= WRITE_WAIT;
                            transfer_ctr    <= 0;
                            out_data_valid  <= 0;
                        end
                        else begin
                            for (int i=0; i<WIRE_INCR; i++) begin
                                out_data[i*MEM_DATA_ADDR_SIZE+:MEM_DATA_ADDR_SIZE] <= mem_data[wr_ptr+i];
                            end
                            
                            out_data_valid  <= 1;
                            transfer_ctr    <= transfer_ctr + WIRE_INCR;
                            state           <= WRITE_DATA;
                            
                            if (wr_ptr +WIRE_INCR > MEM_DATA_COUNT) begin
                                wr_ptr  <= 0;
                            end
                            else begin
                                wr_ptr          <= wr_ptr + WIRE_INCR;
                            end
                        end
                    end
                end
                WRITE_WAIT:begin
                    if(write_done) begin
                        state           <= SET_WRITE_PARA;
                    end
                    else begin
                        state           <= WRITE_WAIT; 
                    end
                end
                default: begin
                    state <= IDLE;
                end 
            endcase
        end
    end
    
endmodule