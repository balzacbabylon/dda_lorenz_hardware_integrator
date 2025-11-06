`timescale 1ns/1ns


module testbench();

	localparam SIZE = 64;
	localparam PNT = 48;
	localparam FACTOR = 8;
	localparam FAC_SIZE = $clog2(FACTOR);


	logic clk_50, reset;
	
	logic signed [SIZE-1:0] testx_out;
   logic signed [SIZE-1:0] testy_out;
   logic signed [SIZE-1:0] testz_out;
	
	function automatic longint rl_to_lngnt(input real x);
		 longint result;
		 if (x >= 0.0)
			  result = longint'(x);        // truncates toward 0 for positive
		 else
			  result = -1*longint'(-1*x);      // preserves sign (same as floor toward 0)
		 return result;
	endfunction
	
	function automatic logic signed [SIZE-1:0] to_fixed
	(
		 input real val
	);
		 // local constants
		 real scale;
		 real max_val, min_val;
		 longint temp; // intermediate 64-bit integer for scaling

		 begin
			  scale = 2.0 ** (PNT);
			  max_val = (2.0 ** (SIZE-1)) - 1.0;
			  min_val = -1.0 * (2.0 ** (SIZE-1));
			  $display("scale was calculated to be %f",scale);
			  $display("max_val was calculated to be %f",max_val);
			  $display("min_val was calculated to be %f",min_val);

			  // scale and round toward zero
			  temp = rl_to_lngnt(val * scale);
			  $display("temp was calculated to be %H",temp);

			  // saturate to representable range
			  //if (temp > max_val)
				//	temp = max_val;
			  //else if (temp < min_val)
				//	temp = min_val;

			  //to_fixed = logic'(temp[SIZE-1:0]); // truncate to SIZE bits
			  return temp;
		 end
	endfunction
	
	
	logic signed [SIZE-1:0] x_0     = to_fixed(.val(-1.0));		//-1.0 - 7f_00000
   logic signed [SIZE-1:0] y_0     = to_fixed(.val(0.1)); 		//0.1000003814697265625 - 00_1999A
   logic signed [SIZE-1:0] z_0     = to_fixed(.val(25.0)); 		//25 - 19_00000
   logic signed [SIZE-1:0] sigma   = to_fixed(.val(10)); 		//10 - 0A_00000
   logic signed [SIZE-1:0] beta    = to_fixed(.val(2.6666)); 	//2.6666 - 02_AAAAA
   logic signed [SIZE-1:0] rho     = to_fixed(.val(28.0)); 		//28 - 1C_00000
	
	logic unsigned [FAC_SIZE:0] factor = FACTOR;
	
	initial begin

		clk_50 = 1'b0; 

   end

   always begin

		#10
      clk_50 = !clk_50;
      #10
      clk_50 = !clk_50;

   end
	
	
	initial begin

		reset = 1'b0;
		#10
		reset = 1'b0;
		#30
		reset = 1'b1;

	end
	
	lorenz #(.SIZE(SIZE),.FAC_SIZE(FAC_SIZE),.PNT(PNT)) DUT(
	
		.clock(clk_50),
		.reset(reset),
		.x0(x_0),
		.y0(y_0),
		.z0(z_0),
		.sigma(sigma),
		.rho(rho),
		.beta(beta),
		.factor(factor),
		.x(testx_out),
		.y(testy_out),
		.z(testz_out)
	);


endmodule