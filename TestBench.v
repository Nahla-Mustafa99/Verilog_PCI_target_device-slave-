module PCIvirtualMaster_TB();
reg reset;
wire trdy,devsel;
reg irdy;
reg frame;
reg[3:0] cbe;
wire[31:0] x;
reg [31:0] AD;
reg drive_bus;
wire stop;
//reg Write_op,Read_op;
assign x = (drive_bus)? AD:32'hzzzzzzzz;
initial begin
reset = 1;
frame = 1;
irdy = 1;
drive_bus = 0;
cbe = 0;


#3 reset = 0;
#4 reset = 1;
//TestCase1 : Writing 4 Words starting from location 0
#8 
frame = 0;
AD = 4'b1000;
cbe = 4'b0111;
drive_bus = 1;

#30 irdy = 0;
AD = 32'hffffffff;
cbe = 4'b1111;


#30 AD = 32'haaaaaaaa;
cbe = 4'b0011;


#30 AD = 32'hbbbbbbbb;
cbe = 4'b1110;



#30 frame = 1;
AD = 32'hcccccccc;
cbe = 4'b0111;


#30 irdy = 1;
drive_bus = 0;
cbe = 0;




//Reading the Words in the previous transaction in the buffer
#30 frame = 0;
drive_bus = 1;
AD = 4'b1000;
cbe = 4'b0110;


#30 irdy = 0;
     drive_bus = 0;
     cbe = 4'b0111;

#30 cbe = 4'b1110;
#30 cbe = 4'b0111;
#30 cbe = 4'b1111;
#30 frame = 1; 

#30 irdy = 1;
cbe = 0;





//TestCase 2: Writing 5 Words Starting from location 0

#30
drive_bus = 1;
frame = 0;
AD = 4'b1000;
cbe = 4'b0111;


#30
AD = 32'h55555555;
cbe = 4'b0001;
irdy = 0;


#30 AD = 32'h66666666;
cbe = 4'b1000;


#30 AD = 32'h77777777;
cbe = 4'b1101;


#30 AD = 32'h11111111;


#30 AD = 32'h44444444;
frame = 1;

#60 irdy = 1;
drive_bus = 0;
cbe = 0;

//Reading the words in the buffer starting from location 0
#30 frame = 0;
AD = 4'b1000;
cbe = 4'b0110;
drive_bus = 1;

#30 drive_bus = 0;
irdy = 0;
#120 frame = 1;
#30 irdy = 1;
cbe = 0;


//TestCase: 3 Writing 3 words in the buffer starting from the second location

#30 frame = 0;
AD = 4'b1001;
cbe = 4'b0111;
drive_bus = 1;


#30
AD = 32'hcccccccc;
cbe = 4'b0111;
irdy = 0;

#30 AD = 32'h99999999;
cbe = 4'b1110;


#30 AD = 32'h55115511;
cbe = 4'b0100;


#30 AD = 32'heeeeeeee;
cbe = 4'b1111;

#60 AD = 32'h66666666;
cbe = 4'b0001;

#30 AD = 32'h11111111;
cbe = 4'b1111;

#30 AD = 32'h0000aaaa;
cbe = 4'b0110;

#30 AD = 32'h69696969;
cbe = 4'b1111;

#30 AD = 32'hffff9999;
cbe = 4'b0001;
frame = 1;

#30 irdy = 1;
drive_bus = 0;
cbe = 0;



//TestCase 4: Trying to write in the device with wrong address

#30 frame = 0;
AD = 0;
cbe = 4'b0111;
drive_bus = 1;


#30 AD = 32'hb13131313;
cbe = 4'b1101;
irdy = 0;

#30 AD = 32'h22222222;
cbe = 4'b1110;
frame = 1;

#30 irdy = 1;
drive_bus = 0;
cbe = 0;

end

PCI_Target TargetA (.TRDY(trdy),.DEVSEL(devsel),.AD(x),.framein(frame),.CBEin(cbe),.IRDY(irdy),.reset(reset),.stop(stop),.clock(clock));
ClockGen C (clock);
endmodule
module ClockGen(clock);
output clock;
reg clock;
initial
begin
clock = 1;
end
always
begin
#15 clock = ~clock;
end
endmodule



