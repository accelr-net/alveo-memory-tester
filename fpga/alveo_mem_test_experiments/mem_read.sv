`timescale 1ns/1ps

module mem_read #(
    parameter C_AXIS_TDATA_WIDTH            = 256,
    parameter C_M_AXI_ADDR_WIDTH            = 64,
    parameter C_XFER_SIZE_WIDTH             = 32,

    //mem read parameters

    parameter READ_DATA_SIZE                = 32,
    parameter READ_BASE_ADDRESS_WIDTH       = 64,
    parameter READ_ADDRESS_INCREMENT_SIZE   = 32,
    parameter READ_MEM_MAX_ADDR_SIZE        = 32,
    parameter READ_MEM_ADDR_SIZE            = 32,

    //common parameters
    parameter MEM_DATA_COUNT                = 1024,
    parameter MEM_DATA_ADDR_SIZE            = 8,
    parameter WR_PTR_SIZE                   = 32
)
(
    //input signals
    clk,
    reset,
    start,
    base_address,
    addr_increment,
    mem_max_addr,
    //output signals
    done,
    //AXI4 read master interface
    data_in,
    data_valid, //(1)
    fetch_data, //(1)
    data_rd_addr,
    data_rd_size,
    data_read_done, //(1)
    data_read_ready, //(1)
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
    
    localparam  PTR_INCR    = C_AXIS_TDATA_WIDTH/MEM_DATA_ADDR_SIZE;
    localparam  WIRE_INCR   = (PTR_INCR<MEM_DATA_COUNT)?PTR_INCR:MEM_DATA_COUNT;
    
    //---------------------------------------------------------------------------------------------------------------------
    // type definitions
    //---------------------------------------------------------------------------------------------------------------------
    
    typedef enum logic [3:0] { 
        IDLE,
        FETCH_DATA,
        FETCH_WAIT,
        READ_DATA
    } state_t;
    
    //---------------------------------------------------------------------------------------------------------------------
    // I/O signals
    //---------------------------------------------------------------------------------------------------------------------
    
    //input signals
    input   logic                                   clk;
    input   logic                                   reset;
    input   logic                                   start;
    input   logic [READ_BASE_ADDRESS_WIDTH-1:0]     base_address;
    input   logic [READ_ADDRESS_INCREMENT_SIZE-1:0] addr_increment;
    input   logic [READ_MEM_MAX_ADDR_SIZE-1:0]      mem_max_addr;
    //output signals
    output   logic                                  done;
    //AXI4 read master interface
    input   logic [C_AXIS_TDATA_WIDTH-1:0]          data_in;
    input   logic                                   data_valid; //(1)
    output  logic                                   fetch_data; //(1)
    output  logic [C_M_AXI_ADDR_WIDTH-1:0]          data_rd_addr;
    output  logic [C_XFER_SIZE_WIDTH-1:0]           data_rd_size;
    input   logic                                   data_read_done; //(1)
    output  logic                                   data_read_ready; //(1)
    output  logic [MEM_DATA_ADDR_SIZE-1:0]          mem_data[0:MEM_DATA_COUNT-1];
    
    //---------------------------------------------------------------------------------------------------------------------
    // Internal signals
    //---------------------------------------------------------------------------------------------------------------------
    
    state_t state = IDLE;
    
    logic                               first_run;
    logic [READ_MEM_ADDR_SIZE-1:0]      mem_addr;
    logic [WR_PTR_SIZE-1:0]             wr_ptr = 0;
    logic [WR_PTR_SIZE-1:0]             transfer_ctr;
    
    //---------------------------------------------------------------------------------------------------------------------
    // Implementation
    //---------------------------------------------------------------------------------------------------------------------
    
    always_ff @( posedge clk ) begin : FETCH_READ_FSM
        if(reset) begin
            fetch_data      <= 0;
            data_rd_addr    <= 0;
            data_rd_size    <= 0;
            data_read_ready <= 0;
            mem_addr        <= 0;
            transfer_ctr    <= 0;
            wr_ptr          <= 0;
            first_run       <= 1;
            done            <= 0;
            for (int i=0; i<MEM_DATA_COUNT; i++) begin
                mem_data[i] <= {MEM_DATA_ADDR_SIZE{1'b0}};
            end
            state           <= IDLE;
        end else begin
            unique case (state)
                IDLE: begin
                    fetch_data      <= 0;
                    data_rd_addr    <= 0;
                    data_rd_size    <= 0;
                    data_read_ready <= 1;
                    mem_addr        <= 0;
                    transfer_ctr    <= 0;
                    wr_ptr          <= 0;
                    done            <= 0;
                    if (start) begin
                        state       <= FETCH_DATA;
                        for (int i=0; i<MEM_DATA_COUNT; i++) begin
                            mem_data[i] <= {MEM_DATA_ADDR_SIZE{1'b0}};
                        end
                    end
                    else begin
                        state       <= IDLE;
                    end
                end
                FETCH_DATA: begin
                    if (mem_addr + addr_increment > mem_max_addr) begin
                        done    <= 1;
                        state   <= IDLE;
                    end
                    else if (mem_max_addr == 0 || addr_increment == 0) begin
                        done    <= 1;
                        state   <= IDLE;
                    end
                    else begin
                        data_rd_addr    <= base_address + mem_addr;
                        data_rd_size    <= READ_DATA_SIZE;
                        mem_addr        <= mem_addr + addr_increment;
                        fetch_data      <= 1;
                        state           <= FETCH_WAIT;
                    end
                end
                READ_DATA: begin
                    if (transfer_ctr >= READ_DATA_SIZE) begin
                        transfer_ctr    <= 0;
                        state           <= FETCH_DATA;
                    end else begin
                        if (data_valid) begin
                            for (int i=0; i<WIRE_INCR; i++) begin
                                mem_data[wr_ptr+i] <= data_in[i*8+:8];
                            end
                            transfer_ctr    <= transfer_ctr +WIRE_INCR;
                            if(wr_ptr + WIRE_INCR < MEM_DATA_COUNT) begin
                                wr_ptr  <= wr_ptr + WIRE_INCR;
                            end
                            else begin
                                wr_ptr  <= 0;
                            end
                        end
                        else begin
                            for (int i=0; i<WIRE_INCR; i++) begin
                                mem_data[i] <= mem_data[i];
                            end
                            transfer_ctr    <= transfer_ctr;
                            wr_ptr  <= wr_ptr;
                        end
                    end
                end
                FETCH_WAIT: begin
                    fetch_data  <= 0;
                    // //comment the below for COCOTB simulation and uncomment for HW Emulation and Run in Hardware
                    // if (data_read_done) begin
                    //     state           <= READ_DATA;
                    //     data_read_ready <= 1;
                    // end
                    // else begin
                    //     state           <= FETCH_WAIT;
                    //     data_read_ready <= data_read_ready;
                    // end
                    // //----------------------------------------------------------------------------------------
                    // //uncomment the below for COCOTB simulation and comment for HW Emulation and Run in Hardware
                    state           <= READ_DATA;
                    data_read_ready <= 1;
                    // //----------------------------------------------------------------------------------------
                end
                default: state <= IDLE;
            endcase
        end
    end
    
endmodule