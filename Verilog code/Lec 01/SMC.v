//Main module
module SMC(
		   W_0, V_GS_0, V_DS_0,
		   W_1, V_GS_1, V_DS_1,
		   W_2, V_GS_2, V_DS_2,
		   W_3, V_GS_3, V_DS_3,
		   W_4, V_GS_4, V_DS_4,
		   W_5, V_GS_5, V_DS_5,
		   mode,
		   out_n
			);


//Set the in/output
input [2:0] W_0, V_GS_0, V_DS_0;
input [2:0] W_1, V_GS_1, V_DS_1;
input [2:0] W_2, V_GS_2, V_DS_2;
input [2:0] W_3, V_GS_3, V_DS_3;
input [2:0] W_4, V_GS_4, V_DS_4;
input [2:0] W_5, V_GS_5, V_DS_5;
input [1:0] mode;
output [9:0] out_n;

//Declare design item
genvar i;
parameter MAX = 5;
//
wire [2:0] W[0:MAX], V_GS[0:MAX], V_DS[0:MAX];
wire [3:0] ID_tri_A[0:MAX], ID_tri_B[0:MAX], ID_tri_C[0:MAX];
wire [3:0] gm_tri_A[0:MAX], gm_tri_B[0:MAX], gm_tri_C[0:MAX];
wire [3:0] ID_sat_A[0:MAX], ID_sat_B[0:MAX], ID_sat_C[0:MAX];
wire [3:0] gm_sat_A[0:MAX], gm_sat_B[0:MAX], gm_sat_C[0:MAX];
//
wire [3:0] ID_A[0:MAX], ID_B[0:MAX], ID_C[0:MAX];
wire [3:0] gm_A[0:MAX], gm_B[0:MAX], gm_C[0:MAX];
//wire [3:0] A[0:MAX], B[0:MAX], C[0:MAX];
//
wire is_tri[0:MAX];
//
wire [9:0] ID[0:MAX];
wire [9:0] gm[0:MAX];
//
wire [9:0] cal[0:MAX];
wire [9:0] n[0:MAX];
wire [9:0] n_sel[0:2];
wire [9:0] out_n0, out_n1, out_n2;


//Assign the input into the array
assign W[0] = W_0;
assign W[1] = W_1;
assign W[2] = W_2;
assign W[3] = W_3;
assign W[4] = W_4; 
assign W[5] = W_5;
assign V_GS[0] = V_GS_0;
assign V_GS[1] = V_GS_1;
assign V_GS[2] = V_GS_2;
assign V_GS[3] = V_GS_3;
assign V_GS[4] = V_GS_4;
assign V_GS[5] = V_GS_5;
assign V_DS[0] = V_DS_0;
assign V_DS[1] = V_DS_1;
assign V_DS[2] = V_DS_2;
assign V_DS[3] = V_DS_3;
assign V_DS[4] = V_DS_4;
assign V_DS[5] = V_DS_5;

/*Design*/
//Sperate the part of term to covinet after caculation
generate
	for(i=0; i<=MAX; i=i+1)begin
		//Part of ID_tri
		assign ID_tri_A[i] = W[i];
		assign ID_tri_B[i] = V_DS[i];
		assign ID_tri_C[i] = 2*(V_GS[i] - 1) - ID_tri_B[i];
		
		//Part of gm_tri
		assign gm_tri_A[i] = 2;
		assign gm_tri_B[i] = W[i];
		assign gm_tri_C[i] = V_DS[i];
		
		//Part of ID_sat
		assign ID_sat_A[i] = W[i];
		assign ID_sat_B[i] = V_GS[i] - 1;
		assign ID_sat_C[i] = V_GS[i] - 1;
		
		//Part of gm_sat
		assign gm_sat_A[i] = 2;
		assign gm_sat_B[i] = W[i];		
		assign gm_sat_C[i] = V_GS[i] - 1;
		end
endgenerate

//is_tri decide block
generate
	for(i=0; i<=MAX; i=i+1) begin
		assign is_tri[i] = (V_GS[i] - 1 > V_DS[i]) ? 1'b1:1'b0; 
	end
endgenerate

//ID_tri and ID_sat decide block
generate
	for(i=0; i<=MAX; i=i+1) begin
		assign ID_A[i] = (is_tri[i] == 1'b1) ? ID_tri_A[i]:ID_sat_A[i];
		assign ID_B[i] = (is_tri[i] == 1'b1) ? ID_tri_B[i]:ID_sat_B[i];
		assign ID_C[i] = (is_tri[i] == 1'b1) ? ID_tri_C[i]:ID_sat_C[i];
		assign gm_A[i] = (is_tri[i] == 1'b1) ? gm_tri_A[i]:gm_sat_A[i];
		assign gm_B[i] = (is_tri[i] == 1'b1) ? gm_tri_B[i]:gm_sat_B[i];
		assign gm_C[i] = (is_tri[i] == 1'b1) ? gm_tri_C[i]:gm_sat_C[i];
	end
endgenerate

//Caculation ID and gm
generate
	for(i=0; i<=MAX; i=i+1) begin
		assign ID[i] = (ID_A[i] * ID_B[i] * ID_C[i]) / 3;
		assign gm[i] = (gm_A[i] * gm_B[i] * gm_C[i]) / 3;
	end
endgenerate

//According to the mode[0] status, select ID or gm
generate
	for(i=0; i<=MAX; i=i+1) begin
		assign cal[i] = (mode[0] == 1'b1) ? ID[i]:gm[i];
	end
endgenerate

//Sroting the array
Sort cal_sorting(.in0(cal[0]), .in1(cal[1]), .in2(cal[2]), .in3(cal[3]), .in4(cal[4]), .in5(cal[5]),
				 .out0(n[0]), .out1(n[1]), .out2(n[2]), .out3(n[3]), .out4(n[4]), .out5(n[5]));

//According to the mode[1] status, decide chosing maximum or minimum
assign n_sel[0] = (mode[1] == 1'b1) ? n[0]:n[3];
assign n_sel[1] = (mode[1] == 1'b1) ? n[1]:n[4];
assign n_sel[2] = (mode[1] == 1'b1) ? n[2]:n[5];

//According to the mode[0] status, decide how to caculate the total value
assign out_n0 = (mode[0] == 1'b0) ? n_sel[0]:(n_sel[0]<<1)+n_sel[0];
assign out_n1 = (mode[0] == 1'b0) ? n_sel[1]:(n_sel[1]<<2);
assign out_n2 = (mode[0] == 1'b0) ? n_sel[2]:(n_sel[2]<<2)+n_sel[2];

//output
assign out_n = out_n0 + out_n1 + out_n2;

endmodule


/*Sub module for sorting*/
//Sort module
module Sort(in0, in1, in2, in3, in4, in5,
			out0, out1, out2, out3, out4, out5
			);
	//Define sub module in/out
	input [9:0] in0, in1, in2, in3, in4, in5;
	output [9:0] out0, out1, out2, out3, out4, out5;
	
	//Declare wire in submodule for design
	wire [9:0] a[0:3], b[0:2], c[0:3], d[0:2], e[0:5], f[0:3], g[0:1];
	
	/*Sub module design (Merge sort)*/
	//in0 to in2 sorting
	assign a[0] = (in0>in1) ? in0:in1;
	assign a[1] = (in0>in1) ? in1:in0;
	assign a[2] = (a[1]>in2) ? a[1]:in2;
	assign a[3] = (a[1]>in2) ? in2:a[1];
	assign b[0] = (a[0]>a[2]) ? a[0]:a[2];
	assign b[1] = (a[0]>a[2]) ? a[2]:a[0];
	assign b[2] = a[3];
	
	//in3 to in5 sorting
	assign c[0] = (in3>in4) ? in3:in4;
	assign c[1] = (in3>in4) ? in4:in3; 
	assign c[2] = (c[1]>in5) ? c[1]:in5;
	assign c[3] = (c[1]>in5) ? in5:c[1];
	assign d[0] = (c[0]>c[2]) ? c[0]:c[2];
	assign d[1] = (c[0]>c[2]) ? c[2]:c[0];
	assign d[2] = c[3];
	
	//Compare two sorted arry and merge
	assign e[0] = (b[0]>d[0]) ? b[0]:d[0];
	assign e[1] = (b[0]>d[0]) ? d[0]:b[0];
	assign e[2] = (b[1]>d[1]) ? b[1]:d[1];
	assign e[3] = (b[1]>d[1]) ? d[1]:b[1];
	assign e[4] = (b[2]>d[2]) ? b[2]:d[2];
	assign e[5] = (b[2]>d[2]) ? d[2]:b[2];
	//find out the minimum and maxmum elemnet
	assign out0 = e[0];
	assign out5 = e[5];
	
	//Keep comparing left elemnet
	assign f[0] = (e[1]>e[2]) ? e[1]:e[2];
	assign f[1] = (e[1]>e[2]) ? e[2]:e[1];
	assign f[2] = (e[3]>e[4]) ? e[3]:e[4];
	assign f[3] = (e[3]>e[4]) ? e[4]:e[3];
	//find out the 2nd minimum and maxmum elemnet
	assign out1 = f[0];
	assign out4 = f[3];
	
	//last turn to comparing size
	assign g[0] = (f[1]>f[2]) ? f[1]:f[2];
	assign g[1] = (f[1]>f[2]) ? f[2]:f[1];
	//find out the last elemnet size
	assign out2 = g[0];
	assign out3 = g[1];
	
endmodule