`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////

//////////////////////////////////////////////////////////////////////////////////
module Vending_Machine(
input clock,
input clk_pb, //btn center
input [1:0] mode,
input [7:0] SW8_15,
input [1:0] flag,
input [2:0] SW567, // 25 cent
output reg [1:0] LED_12=2'd0, // mode output
output reg [1:0] LED_34=2'd0, // status output
output reg [7:0] LED_8_15=8'd0, // balance output
output reg [2:0] LED_567=3'd0, // coins recieved output
output [3:0] an, 
output [3:0] seg 
    );
wire [3:0] Product_added=SW8_15[7:4];
wire [6:0] New_Product_Price=SW8_15[6:0];
wire clk;
wire [2:0] money_rec,Product;
reg [6:0] return_change=7'd0;
wire [3:0] digit0=return_change%10;
wire [3:0] digit1=return_change/10;

debouncer clk_debouncer (
    .clk(clock), 
    .pb_in(clk_pb), 
    .pb_debounced(clk)
    );

sevenseg_driver sevenseg_driver_unit (
    .clk(clock), 
    .in0(digit0), 
    .in1(digit1), 
    .an(an), 
    .segment1(seg)
    );
	 
reg [6:0] Product_price0=7'd10, Product_price1=7'd10;
reg [6:0] Product_price2=7'd25, Product_price3=7'd40;
reg [6:0] Product_price4=7'd50, Product_price5=7'd75;
reg [6:0] Product_price6=7'd90, Product_price7=7'd100;	 

reg [4:0] Product0=4'd3, Product1=4'd2;
reg [4:0] Product2=4'd2, Product3=4'd1;
reg [4:0] Product4=4'd4, Product5=4'd3;
reg [4:0] Product6=4'd5, Product7=4'd2;

reg [6:0] Balance=7'd0;
reg [6:0] Product_price=7'd0;
reg [3:0] Product_inv=4'd0;
//assign money_rec={quarter,dime,nickel};
assign money_rec=SW567;
assign Product=SW567;


always @(posedge clock)
begin

if (clk)
begin

LED_12<=mode;
if (mode==2'b00)
begin
LED_8_15<=Balance;
LED_567<=money_rec;
LED_34<=(Balance>8'd100)? 2'b01:(money_rec==3'b000)? 2'b10:(Product_inv==0)? 2'b11:2'b00;
end

else if (mode==2'b01)
begin
LED_8_15<=Balance;
LED_567<=Product;
LED_34<=(Balance>8'd100)? 2'b01:(money_rec==3'b000)? 2'b10:(Product_inv==0)? 2'b11:2'b00;
end

else if (mode==2'b10)
begin
LED_8_15<=Balance;
LED_567<=3'b0;
LED_34<=(Balance>8'd100)? 2'b01:(money_rec==3'b000)? 2'b10:(Product_inv==0)? 2'b11:2'b00;
end

else if (mode==2'b11)
begin
	if (flag==2'b01) begin
	LED_8_15[3:0]<=Product_inv;
	LED_8_15[7:4]<=Product_added;
	end

	else if (flag==2'b10) begin
	LED_8_15<=New_Product_Price;
	end

	else
	LED_8_15<=8'd0;

LED_567<=(flag==2'b00)? 3'b000:Product;
LED_34<=flag;
end
end

case(Product)
3'b000: begin Product_price<=Product_price0 ; Product_inv<=Product0[3:0] ;  end
3'b001: begin Product_price<=Product_price1 ; Product_inv<=Product1[3:0] ;  end
3'b010: begin Product_price<=Product_price2 ; Product_inv<=Product2[3:0] ;  end
3'b011: begin Product_price<=Product_price3 ; Product_inv<=Product3[3:0] ;  end
3'b100: begin Product_price<=Product_price4 ; Product_inv<=Product4[3:0] ;  end
3'b101: begin Product_price<=Product_price5 ; Product_inv<=Product5[3:0] ;  end
3'b110: begin Product_price<=Product_price6 ; Product_inv<=Product6[3:0] ;  end
3'b111: begin Product_price<=Product_price7 ; Product_inv<=Product7[3:0] ;  end
endcase
end

always @(posedge clk)
begin



if (mode==2'b00) begin
if (Balance>7'd100)
Balance<=7'd100;
else
begin
case(money_rec)
3'b000: Balance<=Balance;
3'b001: Balance<=(Balance>94)? 7'd100 : Balance + 7'd5;
3'b010: Balance<=(Balance>89)? 7'd100 : Balance + 7'd10;
3'b011: Balance<=(Balance>84)? 7'd100 : Balance + 7'd15;
3'b100: Balance<=(Balance>74)? 7'd100 : Balance + 7'd25;
3'b101: Balance<=(Balance>69)? 7'd100 : Balance + 7'd30;
3'b110: Balance<=(Balance>64)? 7'd100 : Balance + 7'd35;
3'b111: Balance<=(Balance>59)? 7'd100 : Balance + 7'd40;
endcase
end
end

else if (mode==2'b01) begin
if ((Balance<Product_price) ||  (Product_inv==0))
Balance<=Balance;
else
begin
case(Product)
3'b000: begin Balance<=Balance - Product_price; Product0 <= Product0 - 4'd1; end
3'b001: begin Balance<=Balance - Product_price; Product1 <= Product1 - 4'd1; end
3'b010: begin Balance<=Balance - Product_price; Product2 <= Product2 - 4'd1; end 
3'b011: begin Balance<=Balance - Product_price; Product3 <= Product3 - 4'd1; end
3'b100: begin Balance<=Balance - Product_price; Product4 <= Product4 - 4'd1; end
3'b101: begin Balance<=Balance - Product_price; Product5 <= Product5 - 4'd1; end
3'b110: begin Balance<=Balance - Product_price; Product6 <= Product6 - 4'd1; end
3'b111: begin Balance<=Balance - Product_price; Product7 <= Product7 - 4'd1; end
endcase

end
end

else if (mode==2'b10) begin
return_change<=Balance;
Balance<=8'd0;
end

else begin
if (flag==2'b00)
begin
Balance<=8'd0;

Product_price0<=7'd10;
Product_price1<=7'd10;
Product_price2<=7'd25;
Product_price3<=7'd40;
Product_price4<=7'd50;
Product_price5<=7'd75;
Product_price6<=7'd90;
Product_price7<=7'd100;

Product0<=4'd3;
Product1<=4'd2;
Product2<=4'd2;
Product3<=4'd1;
Product4<=4'd4;
Product5<=4'd3;
Product6<=4'd5;
Product7<=4'd2;

end

else if (flag==2'b10)
begin

case(Product)
3'b000: Product_price0<=(New_Product_Price>=7'd100)? 7'd100: New_Product_Price;
3'b001: Product_price1<=(New_Product_Price>=7'd100)? 7'd100: New_Product_Price;
3'b010: Product_price2<=(New_Product_Price>=7'd100)? 7'd100: New_Product_Price;
3'b011: Product_price3<=(New_Product_Price>=7'd100)? 7'd100: New_Product_Price;
3'b100: Product_price4<=(New_Product_Price>=7'd100)? 7'd100: New_Product_Price;
3'b101: Product_price5<=(New_Product_Price>=7'd100)? 7'd100: New_Product_Price;
3'b110: Product_price6<=(New_Product_Price>=7'd100)? 7'd100: New_Product_Price;
3'b111: Product_price7<=(New_Product_Price>=7'd100)? 7'd100: New_Product_Price;
endcase
end

else if (flag==2'b01)
begin

case(Product)
3'b000: Product0<=(Product0>=5'd15)? 5'd15: Product0 + Product_added;
3'b001: Product1<=(Product1>=5'd15)? 5'd15: Product1 + Product_added;
3'b010: Product2<=(Product2>=5'd15)? 5'd15: Product2 + Product_added;
3'b011: Product3<=(Product3>=5'd15)? 5'd15: Product3 + Product_added;
3'b100: Product4<=(Product4>=5'd15)? 5'd15: Product4 + Product_added;
3'b101: Product5<=(Product5>=5'd15)? 5'd15: Product5 + Product_added;
3'b110: Product6<=(Product6>=5'd15)? 5'd15: Product6 + Product_added;
3'b111: Product7<=(Product7>=5'd15)? 5'd15: Product7 + Product_added;
endcase
end
end
end


endmodule


`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////

//////////////////////////////////////////////////////////////////////////////////


module sevenseg_driver(
    input clk,       		
    input [3:0] in0,		
    input [3:0] in1,				
    output reg [3:0] an=4'b1111,
    output reg [6:0] segment1=7'b1111111
    
    );
    
    wire [6:0] seg0, seg1;
    reg [13:0] segclk=14'd0; 
    reg  state=1'd0;

	 
    //instantiating the seven segment decoder four times
     Decoder_7_segment disp0(in0,seg0);
     Decoder_7_segment disp1(in1,seg1);

       
    
    always @(posedge clk)
	begin
    segclk<= segclk+1'b1; //counter goes up by 1
	end
	
    always @(posedge segclk[13])
    begin
        case(state)
        
        1'd0: begin
                segment1<=seg0;
                an<=4'b1110;
                state<=1'b1;
                end
                
        1'd1: begin
            segment1<=seg1;
            an<=4'b1101;
            state<=1'b0;
                end

         endcase

    
    end
        
   
endmodule


//////////////////////////////////////////////////////////////////////////////////


module Decoder_7_segment(
    input [3:0] in, //4 bits going into the segment
    output reg [6:0] seg //display the the BCD number on a 7-segment
    );
    
    always @(in)
    begin
    case(in)
				4'b0000: seg=7'b0000001;//active low logic here, this displays zero on the seven segment
				4'b0001: seg=7'b1001111;//"1"
				4'b0010: seg=7'b0010010;//"2"
				4'b0011: seg=7'b0000110;//3
				4'b0100: seg=7'b1001100;//4
				4'b0101: seg=7'b0100100;//5
				4'b0110: seg=7'b0100000;//6
				4'b0111: seg=7'b0001111;//7
				4'b1000: seg=7'b0000000;//8
				4'b1001: seg=7'b0001100;//9
				4'b1010: seg=7'b0001000;//A
				4'b1011: seg=7'b0000011;//B
				4'b1100: seg=7'b1000110;//C
				4'b1101: seg=7'b0100001;//D
				4'b1110: seg=7'b0000110;//E
				4'b1111: seg=7'b0001110;//F
       endcase
     end
                    
     
endmodule

`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////

//////////////////////////////////////////////////////////////////////////////////


module debouncer(
    input clk,
    input pb_in,
    output reg pb_debounced=0
    );

    reg [15:0] debounce_window;

    always@(posedge clk )
            debounce_window <= {debounce_window[14:0], pb_in};
            

    
    always@(posedge clk ) begin
        if (debounce_window == 16'h00FF)
        pb_debounced <= 1'b1;
		  else
		  pb_debounced <= 1'b0;
        end
endmodule

