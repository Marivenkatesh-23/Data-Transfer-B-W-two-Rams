module ram_dp_async
        #(parameter DEPTH = 16,
          parameter WIDTH = 8,
          parameter DEPTH_LOG = $clog2(DEPTH))
          (
            input clk,
            input wr_en,
            input [DEPTH_LOG-1:0] addr_wr,
            input [DEPTH_LOG-1:0] addr_rd,
            input [WIDTH-1:0] data_wr,
            output [WIDTH-1:0] data_rd
          );

          reg [WIDTH-1:0] ram [0:DEPTH-1];

          always @(posedge clk ) begin

            if(wr_en) begin
                ram[addr_wr] <= data_wr;
            end

          end

          assign data_rd = ram[addr_rd];

endmodule