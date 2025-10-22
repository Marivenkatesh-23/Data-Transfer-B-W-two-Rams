`include "ram_dp_async.v"

module data_transfer_fsm(
    input clk,
    input rset,
    //signal for input sram
    input ram_in_we,
    input [4:0] ram_in_addr_wr,
    input [7:0] ram_in_data_wr,
    //signal for output sram
    input [3:0] ram_out_addr_rd,
    output [15:0] ram_out_data_rd,
    //fsm control signals
    input opmode_in,
    output reg done_out
);

    parameter [3:0] IDLE = 4'b0001,
                    READ_BY0 = 4'b0010,
                    READ_BY1 = 4'b0100,
                    WRITE_BY12 = 4'b1000;

    //fsm state logic
    reg [3:0] state,next_state;

    //used to read from ram_in and write in ram_out
    reg [4:0] ram_pointer;

    reg [4:0] fsm_mem_in_addr_rd;
    wire [7:0] fsm_mem_in_data_rd;
    reg [7:0] read_byte0_buffer,read_byte1_buffer;

    reg [3:0] fsm_mem_out_addr_wr;
    reg ram_out_we;

    //instantiate the RAM modules
    ram_dp_async #(.WIDTH(8),.DEPTH(32))
            RAM_IN(
                .clk(clk),
                .wr_en(ram_in_we),
                .addr_wr(ram_in_addr_wr),
                .data_wr(ram_in_data_wr),
                .addr_rd(fsm_mem_in_addr_rd),
                .data_rd(fsm_mem_in_data_rd)
            );

    ram_dp_async #(.WIDTH(16),.DEPTH(16))
            RAM_OUT(
                .clk(clk),
                .wr_en(ram_out_we),
                .addr_wr(fsm_mem_out_addr_wr),
                .data_wr({read_byte0_buffer,read_byte1_buffer}),
                .addr_rd(ram_out_addr_rd),
                .data_rd(ram_out_data_rd)
            );

    always @(*) begin
    next_state = IDLE;
    fsm_mem_in_addr_rd = 0;
    ram_out_we = 0;
    case(state)
        IDLE:
            if (opmode_in) next_state = READ_BY0;
        READ_BY0: begin
            fsm_mem_in_addr_rd = ram_pointer;
            next_state = READ_BY1;
        end
        READ_BY1: begin
            fsm_mem_in_addr_rd = ram_pointer;
            next_state = WRITE_BY12;
        end
        WRITE_BY12: begin
            ram_out_we = 1;
            next_state = (done_out ? IDLE : READ_BY0);
        end
        default: next_state = IDLE;
    endcase
end

    always @(posedge clk or negedge rset) begin
        if(!rset)
            state <= IDLE;
        else
            state <= next_state;
    end

    always @(posedge clk or negedge rset) begin
        if(!rset)
            ram_pointer <= 0;
        else if((state == READ_BY0) || (state == READ_BY1))
            ram_pointer <= ram_pointer + 1'b1;
    end

    always @(posedge clk or negedge rset) begin
        if(!rset)
            fsm_mem_out_addr_wr <= 0;
        else if (state == READ_BY0)
            fsm_mem_out_addr_wr <= (ram_pointer >> 1);
    end

    always @(posedge clk or negedge rset) begin
        if(!rset)
            done_out <= 0;
        else if (opmode_in ==  1)
            done_out <= 0;
        else if (ram_pointer == 5'd31)
            done_out <= 1;
    end

    always @(posedge clk or negedge rset) begin
        if(!rset) begin
            read_byte0_buffer <= 0;
            read_byte1_buffer <= 0;
        end else begin
            read_byte0_buffer <= fsm_mem_in_data_rd;
            read_byte1_buffer <= read_byte0_buffer;
        end
    end

endmodule