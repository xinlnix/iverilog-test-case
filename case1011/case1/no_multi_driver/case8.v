/**
	【例 11.5】交通灯控制器
*/

module traffic(CLK,EN,LAMPA,LAMPB,ACOUNT,BCOUNT);
output[7:0] ACOUNT,BCOUNT;
output[3:0] LAMPA,LAMPB;
input CLK,EN;
reg[7:0] numa,numb;
reg tempa,tempb;
reg[2:0] counta,countb;
reg[7:0] ared,ayellow,agreen,aleft,bred,byellow,bgreen,bleft;
reg[3:0] LAMPA,LAMPB;

always @(EN)
	if(!EN)
	begin //设置各种灯的计数器的预置数
		ared <=8'd55; //55 秒
		ayellow <=8'd5; //5 秒
		agreen <=8'd40; //40 秒
		aleft <=8'd15; //15 秒
		bred <=8'd65; //65 秒
		byellow <=8'd5; //5 秒
		bleft <=8'd15; //15 秒
		bgreen <=8'd30; //30 秒
	end

	assign ACOUNT=numa;
	assign BCOUNT=numb;

	always @(posedge CLK) //该进程控制 A 方向的四种灯
 		begin
			if(EN)
			begin
				if(!tempa)
				begin
				tempa<=1;
					case(counta) //控制亮灯的顺序
					0: begin numa<=agreen; LAMPA<=2; counta<=1; end
					1: begin numa<=ayellow; LAMPA<=4; counta<=2; end
					2: begin numa<=aleft; LAMPA<=1; counta<=3; end
					3: begin numa<=ayellow; LAMPA<=4; counta<=4; end
					4: begin numa<=ared; LAMPA<=8; counta<=0; end
					default: LAMPA<=8;

					endcase
				end
				else begin //倒计时
					if(numa>1)
						if(numa[3:0]==0) begin
									numa[3:0]<=4'b1001;
									numa[7:4]<=numa[7:4]-1;
									end
						else 			numa[3:0]<=numa[3:0]-1;
					if (numa==2) tempa<=0;
				end
			end
			else begin
				LAMPA<=4'b1000;
				counta<=0; tempa<=0;
			end
		end

		always @(posedge CLK) //该进程控制 B 方向的四种灯
			begin
	 			if (EN)
 				begin
					if(!tempb)
					begin
						tempb<=1;
						case (countb) //控制亮灯的顺序
							0: begin numb<=bred; LAMPB<=8; countb<=1; end
							1: begin numb<=bgreen; LAMPB<=2; countb<=2; end
							2: begin numb<=byellow; LAMPB<=4; countb<=3; end
							3: begin numb<=bleft; LAMPB<=1; countb<=4; end
							4: begin numb<=byellow; LAMPB<=4; countb<=0; end
							default: LAMPB<=8;
						endcase
					end
					else
					begin //倒计时
						if(numb>1)
							if(!numb[3:0]) begin
								numb[3:0]<=9;
								numb[7:4]<=numb[7:4]-1;
							end
						else numb[3:0]<=numb[3:0]-1;
						if(numb==2) tempb<=0;
					end
				end
			else begin
				LAMPB<=4'b1000;
				tempb<=0; countb<=0;
			end
	end
endmodule