//By: Cosmo  
//QQ:38598813
//2025.4.30

`timescale 1ns / 1ps
`include "pcileech_header.svh"


module pcileech_bar_impl_1394(
    input               rst,
    input               clk,
    // incoming BAR writes:
    input [31:0]        wr_addr,
    input [3:0]         wr_be,
    input [31:0]        wr_data,
    input               wr_valid,
    // incoming BAR reads:
    input  [87:0]       rd_req_ctx,
    input  [31:0]       rd_req_addr,
    input               rd_req_valid,
    input  [31:0]       base_address_register,
    // outgoing BAR read replies:
    output reg [87:0]   rd_rsp_ctx,
    output reg [31:0]   rd_rsp_data,
    output reg          rd_rsp_valid
);

    reg [87:0]      drd_req_ctx;
    reg [31:0]      drd_req_addr;
    reg             drd_req_valid;

    reg [31:0]      dwr_addr;
    reg [31:0]      dwr_data;
    reg             dwr_valid;
    reg [31:0]      data_0050;
    reg [31:0]      data_00ec;
    reg [31:0]      data_000c;
    reg [31:0]      data_0014;

    always @ (posedge clk) begin
        if (rst)begin
            data_000c <= 32'h3f;


        end else begin
            number          <= number + 1;
        drd_req_ctx     <= rd_req_ctx;
        drd_req_valid   <= rd_req_valid;
        dwr_valid       <= wr_valid;
        drd_req_addr    <= rd_req_addr;
        rd_rsp_ctx      <= drd_req_ctx;
        rd_rsp_valid    <= drd_req_valid;
        dwr_addr        <= wr_addr;
        dwr_data        <= wr_data;

		if (drd_req_valid) begin
            case (({drd_req_addr[31:24], drd_req_addr[23:16], drd_req_addr[15:08], drd_req_addr[07:00]} - (base_address_register & ~32'h4)) & 32'h7FF)
				16'h00a8 : rd_rsp_data <= 32'hf;
                16'h0098 : rd_rsp_data <= 32'hff;
                16'h0020 : rd_rsp_data <= 32'hf000a222;
                16'h0024 : rd_rsp_data <= 32'h110666;
                16'h0028 : rd_rsp_data <= 32'h554589e2;
                16'h0050 : begin
                    rd_rsp_data <= data_0050;
                    if (data_0050 == 32'h10000) begin
                        data_0050 <= 32'h00000000;
                    end
                end    
                16'h0000 : rd_rsp_data <= 32'h1010000;
                16'h00dc : rd_rsp_data <= 32'h3f;
                16'h0084 : rd_rsp_data <= 32'h10010;
                16'h00ec : rd_rsp_data <= data_00ec;
                16'h00e8 : rd_rsp_data <= 32'hc800ffc0;
                16'h0068 : rd_rsp_data <= 32'h1000c;
                16'h00f0 : rd_rsp_data <= 32'h1b79e203;//多值，可轮询
                16'h000c : begin
                    rd_rsp_data <= data_000c;
                    if (data_000c == 32'h3f) begin
                        data_000c <= 32'hffffffff;
                    end
                end
                16'h0014 : rd_rsp_data <= data_0014;



            default: rd_rsp_data <= 32'h00000000;
			endcase
                
        end else if (dwr_valid) begin
            case (({dwr_addr[31:24], dwr_addr[23:16], dwr_addr[15:08], dwr_addr[07:00]} - (base_address_register & ~32'h4)) & 32'h7FF) 
                16'h0050 : data_0050 <= dwr_data;
                16'h00ec : begin
                    if (dwr_data[11:8] == 4'h4) data_00ec <= {4'h8,dwr_data[11:8],12'h010,dwr_data[11:0]};
                    if (dwr_data[11:8] == 4'h5) data_00ec <= {4'h8,dwr_data[11:8],12'h000,dwr_data[11:0]};
                    if (dwr_data[11:8] == 4'h1) data_00ec <= {4'h8,dwr_data[11:8],12'h3f0,dwr_data[11:0]};
                end
                16'h0014 : data_0014 <= {28'h88000000,dwr_data[3:0]};
            endcase
			end
		end
	end
endmodule