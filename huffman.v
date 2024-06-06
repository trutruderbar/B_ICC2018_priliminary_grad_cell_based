module huffman(clk, reset, gray_data, gray_valid, CNT_valid, CNT1, CNT2, CNT3, CNT4, CNT5, CNT6,
    code_valid, HC1, HC2, HC3, HC4, HC5, HC6, M1, M2, M3, M4, M5, M6);

input clk;
input reset;
input gray_valid;
input [7:0] gray_data;
output CNT_valid;
output [7:0] CNT1, CNT2, CNT3, CNT4, CNT5, CNT6;
output code_valid;
output [7:0] HC1, HC2, HC3, HC4, HC5, HC6;
output [7:0] M1, M2, M3, M4, M5, M6;
//====================================================================
//===========================================================================//parameter
//=================================================//assign element
reg CNT_valid_;
reg code_valid_;
reg [7:0] CNT[0:5];
reg [7:0] HC[0:5];
reg [7:0] M[0:5];
assign CNT_valid = CNT_valid_;
assign code_valid = code_valid_;
assign CNT1 = CNT[0];
assign CNT2 = CNT[1];
assign CNT3 = CNT[2];
assign CNT4 = CNT[3];
assign CNT5 = CNT[4];
assign CNT6 = CNT[5];
assign HC1 = HC[0];
assign HC2 = HC[1];
assign HC3 = HC[2];
assign HC4 = HC[3];
assign HC5 = HC[4];
assign HC6 = HC[5];
assign M1 = M[0];
assign M2 = M[1];
assign M3 = M[2];
assign M4 = M[3];
assign M5 = M[4];
assign M6 = M[5];
//=================================================//state parameter
parameter	WAIT = 3'd0,
			COUNTING = 3'd1,
			INIT = 3'd2,
			SORT = 3'd3,
			MERGE = 3'd4,
			FINAL = 3'd5,
			FINISH = 3'd6;
reg [2:0] state;
reg [2:0] n_state;
//=================================================//value
reg [5:0] t;
reg [2:0] loc;
reg [2:0] item;
reg [2:0] i;
reg [2:0] j;
//=================================================//vector
reg [5:0] item_inside [0:5];
reg [7:0] item_CNT [0:5];
reg [2:0] M_num [0:5];
//===========================================================================//state register
always@(posedge clk, posedge reset)
	begin
	if(reset)
		state <= WAIT;
	else
		state <= n_state;
	end
//===========================================================================//next state logic
always@(*)
	begin
	case(state)
		default:
			begin
			n_state <= WAIT;
			end
		WAIT:
			begin
			if(gray_valid)
				n_state <= COUNTING;
			else
				n_state <= WAIT;
			end
		COUNTING:
			begin
			if(gray_valid)
				n_state <= COUNTING;
			else
				n_state <= INIT;
			end
		INIT:
			begin
			n_state <= SORT;
			end
		SORT:
			begin
			if(t <= (item - 3'd1)*(item - 3'd1))
				n_state <= SORT;
			else
				n_state <= MERGE;
			end
		MERGE:
			begin
			if(item == 3'd3)
				begin
				n_state <= FINAL;
				end
			else
				begin
				n_state <= SORT;
				end
			end
		FINAL:
			begin
			n_state <= FINISH;
			end
		FINISH:
			begin
			n_state <= FINISH;
			end
	endcase
	end
//===========================================================================//output logic
always@(posedge clk)
	begin
	case(state)
		default:
			begin
			t <= 6'd0;
			loc <= 3'd0;
			item <= 3'd6;
			for(i = 3'd0; i < 3'd6; i = i + 3'd1)
				begin
				HC[i] <= 8'd0;
				M[i] <= 8'd0;
				end
			for(i = 3'd0; i < 3'd6; i = i + 3'd1)
				begin
				if(gray_data == {5'd0, i + 3'd1})
					CNT[i] <= 8'd1;
				else
					CNT[i] <= 8'd0;
				end
			end
		COUNTING:
			begin
			for(i = 3'd0; i < 3'd6; i = i + 3'd1)
				begin
				if(gray_data == {5'd0, i + 3'd1})
					CNT[i] <= CNT[i] + 8'd1;
				else
					CNT[i] <= CNT[i];
				end
			end
		INIT:
			begin
			for(i = 3'd0; i < 3'd6; i = i + 3'd1)
				begin
				for(j = 3'd0; j < 3'd6; j = j + 3'd1)
					begin
					if(i == j)
						item_inside[i][j] <= 1'd1;
					else
						item_inside[i][j] <= 1'd0;
					end
				M_num[i] <= 4'd1;
				item_CNT[i] <= CNT[i];
				end
			CNT_valid_ <= 1'd1;
			end
		SORT:
			begin
			if(loc < item - 3'd2)
				loc <= loc + 3'd1;
			else
				loc <= 3'd0;
			t <= t + 6'd1;
			if(item_CNT[loc] < item_CNT[loc + 3'd1])
				begin
				item_inside[loc] <= item_inside[loc + 3'd1];
				item_inside[loc + 3'd1] <= item_inside[loc];
				item_CNT[loc] <= item_CNT[loc + 3'd1];
				item_CNT[loc + 3'd1] <= item_CNT[loc];
				end
			else
				begin
				item_inside[loc] <= item_inside[loc];
				item_inside[loc + 3'd1] <= item_inside[loc + 3'd1];
				item_CNT[loc] <= item_CNT[loc];
				item_CNT[loc + 3'd1] <= item_CNT[loc + 3'd1];
				end
			end
		MERGE:
			begin
			item_inside[item - 3'd2] <= item_inside[item - 3'd2] + item_inside[item - 3'd1];
			item_inside[item - 3'd1] <= 6'd0;
			item_CNT[item - 3'd2] <= item_CNT[item - 3'd2] + item_CNT[item - 3'd1];
			item_CNT[item - 3'd1] <= 8'd0;
			item <= item - 3'd1;
			t <= 6'd0;
			loc <= 3'd0;
			for(i = 3'd0; i < 3'd6; i = i + 3'd1)
				begin
				if(item_inside[item - 3'd1][i] == 1'd1)
					begin
					HC[i] <= HC[i] + (8'd1 << {5'd0, M_num[i]});
					M[i] <= M[i] + (8'd1 << {5'd0, M_num[i]});
					M_num[i] <= M_num[i] + 3'd1;
					end
				else if(item_inside[item - 3'd2][i] == 1'd1)
					begin
					HC[i] <= HC[i];
					M[i] <= M[i] + (8'd1 << {5'd0, M_num[i]});
					M_num[i] <= M_num[i] + 3'd1;
					end
				else
					begin
					HC[i] <= HC[i];
					M[i] <= M[i];
					M_num[i] <= M_num[i];
					end
				end
			end
		FINAL:
			begin
			if(item_CNT[0] >= item_CNT[1])
				begin
				for(i = 3'd0; i < 3'd6; i = i + 3'd1)
					begin
					if(item_inside[item - 3'd1][i] == 1'd1)
						begin
						HC[i] <= HC[i] + (8'd1 << {5'd0, M_num[i]});
						M[i] <= M[i] + (8'd1 << {5'd0, M_num[i]});
						M_num[i] <= M_num[i] + 3'd1;
						end
					else if(item_inside[item - 3'd2][i] == 1'd1)
						begin
						HC[i] <= HC[i];
						M[i] <= M[i] + (8'd1 << {5'd0, M_num[i]});
						M_num[i] <= M_num[i] + 3'd1;
						end
					else
						begin
						HC[i] <= HC[i];
						M[i] <= M[i];
						M_num[i] <= M_num[i];
						end
					end
				end
			else
				begin
				for(i = 3'd0; i < 3'd6; i = i + 3'd1)
					begin
					if(item_inside[item - 3'd2][i] == 1'd1)
						begin
						HC[i] <= HC[i] + (8'd1 << {5'd0, M_num[i]});
						M[i] <= M[i] + (8'd1 << {5'd0, M_num[i]});
						M_num[i] <= M_num[i] + 3'd1;
						end
					else if(item_inside[item - 3'd1][i] == 1'd1)
						begin
						HC[i] <= HC[i];
						M[i] <= M[i] + (8'd1 << {5'd0, M_num[i]});
						M_num[i] <= M_num[i] + 3'd1;
						end
					else
						begin
						HC[i] <= HC[i];
						M[i] <= M[i];
						M_num[i] <= M_num[i];
						end
					end
				end
			end
		FINISH:
			begin
			code_valid_ <= 1'd1;
			for(i = 3'd0; i < 3'd6; i = i + 3'd1)
				begin
				M[i] <= M[i]>>1;
				HC[i] <= HC[i]>>1;
				end
			end
	endcase
	end
//====================================================================
endmodule