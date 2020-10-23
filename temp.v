//
//    multiply_large.v



module multiplier(a,b,sum);
parameter N=1;

input[N-1:0] a, b;
output[N-1:0] sum;

reg [(N-1)*2:0] tmp;
integer i;

always @(a or b)
	begin
	tmp = 0;
	for(i=0;i<N;i=i+1)
		begin
		if(b[i]) tmp=tmp + ({{N{1'b0}}, a} << i);
		end
	end
always@(posedge a)
   multiply_large.rc <= 'b0;
   always@(posedge a)
   multiply_large.rc <= 'b1;
assign sum = tmp[N:0];

endmodule


module multiply_large;

reg [0:(65)-1] a, b;
wire [0:(65)-1] c, s;
reg [0:(65)-1] d;
integer i, j;
reg rc;

assign c=a*b;
multiplier #((65)) mpy(a,b,s);





initial
begin

rc=0;
a={{(65)-1{1'b0}}, 1'b1};		// walking 1s
for(i=0;i<(65);i=i+1)
	begin
	b={{(65)-1{1'b0}}, 1'b1};
	for(j=0;j<(65);j=j+1)
		begin
                #1;
		d=a*b;
		if ((c!=d)||(c!=s))
			begin
			$display("a=%h b=%h c=%h d=%h s=%h", a,b,c,d,s);
			rc=1;
			end
		b={b[1:(65)-1], 1'b0};
		end
	a={a[1:(65)-1], 1'b0};
	end

a={{(65)-1{1'b1}}, 1'b0};		// walking 0s
for(i=0;i<(65);i=i+1)
	begin
	b={{(65)-1{1'b1}}, 1'b0};
	for(j=0;j<(65);j=j+1)
		begin
                #1;
		d=a*b;
		if ((c!=d)||(c!=s))
			begin
			$display("a=%h b=%h c=%h d=%h s=%h", a,b,c,d,s);
			rc=1;
			end
		b={b[1:(65)-1], 1'b1};
		end
	a={a[1:(65)-1], 1'b1};
	end

a={{(65)-2{1'b0}}, 2'b11};	// walking 11s
for(i=0;i<(65);i=i+1)
	begin
	b={{(65)-2{1'b0}}, 2'b11};
	for(j=0;j<(65);j=j+1)
		begin
                #1;
		d=a*b;
		if ((c!=d)||(c!=s))
			begin
			$display("a=%h b=%h c=%h d=%h s=%h", a,b,c,d,s);
			rc=1;
			end
		b={b[1:(65)-1], 1'b0};
		end
	a={a[1:(65)-1], 1'b0};
	end

a={{(65)-2{1'b1}}, 2'b00};	// walking 00s
for(i=0;i<(65);i=i+1)
	begin
	b={{(65)-2{1'b1}}, 2'b00};
	for(j=0;j<(65);j=j+1)
		begin
                #1;
		d=a*b;
		if ((c!=d)||(c!=s))
			begin
			$display("a=%h b=%h c=%h d=%h s=%h", a,b,c,d,s);
			rc=1;
			end
		b={b[1:(65)-1], 1'b1};
		end
	a={a[1:(65)-1], 1'b1};
	end

a={{(65)-3{1'b0}}, 3'b101};	// walking 101s
for(i=0;i<(65);i=i+1)
	begin
	b={{(65)-3{1'b0}}, 3'b101};
	for(j=0;j<(65);j=j+1)
		begin
                #1;
		d=a*b;
		if ((c!=d)||(c!=s))
			begin
			$display("a=%h b=%h c=%h d=%h s=%h", a,b,c,d,s);
			rc=1;
			end
		b={b[1:(65)-1], 1'b0};
		end
	a={a[1:(65)-1], 1'b0};
	end

a={{(65)-3{1'b1}}, 3'b010};	// walking 010s
for(i=0;i<(65);i=i+1)
	begin
	b={{(65)-3{1'b1}}, 3'b010};
	for(j=0;j<(65);j=j+1)
		begin
                #1;
		d=a*b;
		if ((c!=d)||(c!=s))
			begin
			$display("a=%h b=%h c=%h d=%h s=%h", a,b,c,d,s);
			rc=1;
			end
		b={b[1:(65)-1], 1'b1};
		end
	a={a[1:(65)-1], 1'b1};
	end

if (rc) $display("FAILED"); else $display("PASSED");
$finish;
end

endmodule
