module lorenz

	#(
		parameter SIZE = 64,
		parameter FAC_SIZE = 3,
		parameter PNT = 48
		)
	(

	input logic clock, reset,

	input logic signed [SIZE-1:0] x0,
	input logic signed [SIZE-1:0] y0,
	input logic signed [SIZE-1:0] z0,
	input logic signed [SIZE-1:0] sigma,
	input logic signed [SIZE-1:0] rho,
	input logic signed [SIZE-1:0] beta,
	input logic unsigned [FAC_SIZE:0] factor,
	
	output logic signed [SIZE-1:0] x,
	output logic signed [SIZE-1:0] y,
	output logic signed [SIZE-1:0] z
	
	);
	
	logic signed [SIZE-1:0] dxdt, dydt, dzdt;
   logic signed [SIZE-1:0] dx, dy, dz;
	
   dxdtm #(.SIZE(SIZE),.PNT(PNT)) dxdtm0 ( .sigma(sigma), .x(x), .y(y), .dxdt(dxdt));
   dydtm #(.SIZE(SIZE),.PNT(PNT)) dydtm1 ( .rho(rho), .x(x), .y(y), .z(z), .dydt(dydt));
   dzdtm #(.SIZE(SIZE),.PNT(PNT)) dzdtm2 ( .beta(beta), .x(x), .y(y), .z(z), .dzdt(dzdt));

   dtmult #(.SIZE(SIZE),.FAC_SIZE(FAC_SIZE)) dtmx ( .func(dxdt), .factor(factor), .funct(dx));
   dtmult #(.SIZE(SIZE),.FAC_SIZE(FAC_SIZE)) dtmy ( .func(dydt), .factor(factor), .funct(dy));
   dtmult #(.SIZE(SIZE),.FAC_SIZE(FAC_SIZE)) dtmz ( .func(dzdt), .factor(factor), .funct(dz));
	
	integrator #(.SIZE(SIZE)) ix( .out(x), .funct(dx), .InitialOut(x0), .clk(clock), .reset(reset));
	integrator #(.SIZE(SIZE)) iy( .out(y), .funct(dy), .InitialOut(y0), .clk(clock), .reset(reset));
	integrator #(.SIZE(SIZE)) iz( .out(z), .funct(dz), .InitialOut(z0), .clk(clock), .reset(reset));
	
endmodule
	

module integrator #(parameter SIZE = 64)(out, funct, InitialOut, clk, reset);

	

	output logic signed [SIZE-1:0] out; 	//the state variable V
	input logic signed [SIZE-1:0] funct;          //the dV/dt function
	input logic clk, reset;
	input logic signed [SIZE-1:0] InitialOut;     //the initial state variable V
	
	logic signed	[SIZE-1:0] v1new;
	logic signed	[SIZE-1:0] v1;
	
	always @ (posedge clk) 
	begin
		if (reset==0) //reset	
			v1 <= InitialOut ; // 
		else 
			v1 <= v1new ;	
	end
	assign v1new = v1 + funct;
	assign out = v1 ;

endmodule

module dxdtm #(parameter SIZE = 64, parameter PNT = 48)( 

    input logic signed [SIZE-1:0] sigma,
	 input logic signed [SIZE-1:0] x,
	 input logic signed [SIZE-1:0] y,
	 output logic signed [SIZE-1:0] dxdt
);



	/*
	logic signed [26:0] sx,sy;
	
	signed_mult sm0(.out(sx),.a(x),.b(sigma));
	signed_mult sm1(.out(sy),.a(y),.b(sigma));
	
	assign dxdt = sy - sx;
	*/
	
	logic signed [SIZE-1:0] diff;
	
	assign diff = y - x;
	
	signed_mult #(.SIZE(SIZE),.PNT(PNT)) sm0(.out(dxdt),.a(sigma),.b(diff));

endmodule

module dydtm #(parameter SIZE = 64, parameter PNT = 48)( 

    input logic signed [SIZE-1:0] rho,
	 input logic signed [SIZE-1:0] x,
	 input logic signed [SIZE-1:0] y,
	 input logic signed [SIZE-1:0] z,
	 output logic signed [SIZE-1:0] dydt
);


	/*
	logic signed [26:0] rx,xz;
	
	signed_mult sm0(.out(rx),.a(x),.b(rho));
	signed_mult sm1(.out(xz),.a(x),.b(z));

	
	assign dydt = rx - xz - y;
	*/
	
	logic signed [SIZE-1:0] dpz,xdpz;
	
	assign dpz = rho - z;
	
	signed_mult #(.SIZE(SIZE),.PNT(PNT)) sm0(.out(xdpz),.a(x),.b(dpz));
	
	assign dydt = xdpz - y;
	

endmodule


module dzdtm #(parameter SIZE = 64, parameter PNT = 48)( 

    input logic signed [SIZE-1:0] beta,
	 input logic signed [SIZE-1:0] x,
	 input logic signed [SIZE-1:0] y,
	 input logic signed [SIZE-1:0] z,
	 output logic signed [SIZE-1:0] dzdt
);


	logic signed [SIZE-1:0] xy,bz;
	
	signed_mult #(.SIZE(SIZE),.PNT(PNT)) sm0(.out(xy),.a(x),.b(y));
	signed_mult #(.SIZE(SIZE),.PNT(PNT)) sm1(.out(bz),.a(beta),.b(z));

	
	assign dzdt = xy - bz;


endmodule


module dtmult #(parameter SIZE = 64, parameter FAC_SIZE = 3)(
    
    input logic signed [SIZE-1:0] func,
    input logic unsigned [FAC_SIZE:0] factor,
    output logic signed [SIZE-1:0] funct

);

	assign funct = func >>> factor;


endmodule

//////////////////////////////////////////////////
//// signed mult of 7.20 format 2'comp////////////
//////////////////////////////////////////////////

module signed_mult #(parameter SIZE = 64, parameter PNT = 48)(out, a, b);

	output logic signed  [SIZE-1:0]	out;
	input logic signed	[SIZE-1:0] 	a;
	input logic signed	[SIZE-1:0] 	b;
	// intermediate full bit length
	logic 	signed	[2*SIZE-1:0]	mult_out;
	assign mult_out = a * b;
	// select bits for 7.20 fixed point
	//assign out = mult_out[46:20];
	assign out = {mult_out[2*SIZE-1], mult_out[SIZE+PNT-2:PNT]};

endmodule
//////////////////////////////////////////////////
