module PCI_Target(TRDY,DEVSEL,AD,framein,CBEin,IRDY,reset,stop,clock);

// The Device Addresses
parameter device_address0 = 4'b1000;
parameter device_address1 = 4'b1001;
parameter device_address2 = 4'b1010;
parameter device_address3 = 4'b1011;


reg addressread = 0;    //This Register becomes 1 if the address is read in the postive edge at the begining of the transaction 
inout [31:0] AD;                   
input framein,IRDY;
output reg DEVSEL;
input [3:0] CBEin;
output reg TRDY;
input clock;
reg [7:0]counter = 0;   //This Register is used to count the number of postive and negative edges at the begining of the transaction when it equals 2 DEVSEL and TRDY becomes 0
reg DEVSELflag = 0;     //This Register becomes one when the address is read then at the next negative edge it becomes zero and the counter increases by one
reg not_drive_bus = 1;   //This Register is one if the target doesn't drive the bus and zero if the target drives the bus
reg setIRDY = 1;          //This Register becomes zero at the negative edge of IRDY   
reg setTARDY = 1;         //This Register becomes zero at the negative edge of TRDY
input reset; 
reg [2:0]saved;           //This Register saves the begining location when the address is read
output reg stop = 1;

reg [31:0] memory[0:3]; 
reg start_transaction = 0;   //This Register becomes one at the negative edge of the frame 
reg [9:0] address_pointer;   //This Register points to the reading/writing location 
reg [2:0]count_of_writed_data=3'b000;  //This Register counts the number of data written 
reg [31:0] bigger_buffer[0:9]; 
reg [1:0]backup_done=2'b00;    //This Register becomes 0 when the data is transfered to the bigger buffer
reg[3:0]buffer_pointer=0;      //This Register points to the bigger buffer location
reg read_op = 0;                //This Register becomes 1 if the operation is read operation
reg write_op = 0;               //This Register becomes 1 if the operation is write operation
reg true_address = 0;

assign AD = (!not_drive_bus)? memory[address_pointer]:32'hzzzzzzzz;


                         
                         always@(negedge framein)
                          begin 
                           start_transaction<=1;               //For Read and Write Operation
                          end // STILL I DO NOT KNOW THE OPERATION  
                           

                          always @(posedge framein)
                            begin
                              setTARDY <= 0;   //For Read Operation
                            end


                          always @(negedge IRDY)
                                  begin
                                   setIRDY <= 0;     //For Read Operation
                                  end


                          always @(posedge IRDY)
                             begin
                              setIRDY <= 1;        //For Read Operation
                             end
                          always@(negedge reset)  
                            begin
                                TRDY <= 1;
                                DEVSEL <= 1;
                                setIRDY <= 1;
                                setTARDY <= 1;
                            end   
                          always@(posedge clock)
                           begin // READ OR WRITE OPERATION?   
                             if(start_transaction==1) 
                               begin 
                                  if(CBEin==4'b0110) 
                                     begin              //Read Operation
                                       read_op<=1; 
                                       start_transaction<=0;
                                       counter <= 0;
                                       DEVSELflag <= 1; 
                                      end      //start_transaction becomes 0 because we want to enter this block once in a transaction because we want to know the operation and the buffer location at first

                                  if(CBEin==4'b0111) 
                                      begin          //write operation
                                       write_op<=1; 
                                       start_transaction<=0;   
                                      end //start_transaction becomes 0 because we want to enter this block once in a transaction because we want to know the operation and the buffer location at first

                              case(AD)
                                device_address0: begin
                                                address_pointer<=0;  //address_pointer = 0 because we will read or write in the first location
                                                addressread<=1;      //addressread = 1 because we read the address
                                                true_address <= 1;           


                                             //The following statement is used in Read Operation Onlyyyy and Writing in the bigger buffer
                                                saved <= 0;
                                                 end
                                 device_address1: begin
                                                address_pointer<=1;  //address_pointer = 1 because we will read or write in the second location
                                                addressread<=1;      //addressread = 1 because we read the address
                                                true_address <= 1;  

                                               //The following statement is used in Read Operation Onlyyyy and Writing in the bigger buffer
                                                saved <= 1;
                                                 end
                                 device_address2: begin
                                                address_pointer<=2;  //address_pointer = 2 because we will read or write in the third location
                                                addressread<=1;      //addressread = 1 because we read the address
                                                true_address <= 1;  
           

                                                 //The following statement is used in Read Operation Onlyyyy and Writing in the bigger buffer
                                                saved <= 2;
                                                 end
                                 device_address3: begin
                                                address_pointer<=3;   //address_pointer = 3 because we will read or write in the third location
                                                addressread<=1;       //address_pointer = 1 because we will read or write in the second location
                                                true_address <= 1;  



                                                  //The following statement is used in Read Operation Onlyyyy and Writing in the bigger buffer
                                                 saved <= 3;
                                                 end
                                             endcase
                                 end
                                 if(write_op && true_address == 1)
                                               begin // if of write_op is true 
                                              if(TRDY==0) // if target is ready
                                                begin // if TRDY
                                                 if(IRDY==0) 
                                                   begin // if IRDY
                                                     memory[address_pointer]= AD & {{8{CBEin[3]}},{8{CBEin[2]}},{8{CBEin[1]}},{8{CBEin[0]}}};         
                                                     address_pointer=address_pointer+1 ;                      //increase the address_pointer by one to write in the next location
                                                     count_of_writed_data=count_of_writed_data+1;             
                                                   end // IF IRDY
                                                 end // if TRDY
                                     if(count_of_writed_data > (4 - saved))           //if saved = 0,that means that we start writing in the first location then count_of_writed_data must be > 4 to transfer the data to the bigger buffer 
                                      begin                                          //if saved = 1,that means that we start writing in the second location then count_of_writed_data must be > 3 to transfer the data to the bigger buffer
                                          address_pointer=address_pointer-count_of_writed_data+1; //Making the address_pointer = the location we started writing in it
                                         if(buffer_pointer < 10 && address_pointer != 4) begin      //if the bigger buffer isn't full and the address_pointer != 4
                                                                                                    //in this case address_pointer can't be = address_pointer + 1
                                                                                                    //because we have only 4 locations from memory[0] to memory[3] there is no memory[4] or memory[5]
                                         bigger_buffer[buffer_pointer]=memory[address_pointer] ; // backup[0]=memory[0] if buffer_pointer=0 and address_pointer=0
                                         address_pointer=address_pointer+1;// if address_pointer=0 : it will be  address_pointer=1
                                         buffer_pointer=buffer_pointer+1;//  if buffer_pointer=0:  it will be if buffer_pointer=1
                                          end 
                                         if(buffer_pointer < 10 && address_pointer != 4) begin
                                         bigger_buffer[buffer_pointer]=memory[address_pointer];// backup[buffer_pointer]<=memory[address_pointer]    backup[1]<=memory[1]    
                                         address_pointer=address_pointer+1;//:it will be  address_pointer=2
                                         buffer_pointer=buffer_pointer+1;//: it will be if buffer_pointer=2
                                         end
                                         if(buffer_pointer < 10 && address_pointer != 4) begin
                                        bigger_buffer[buffer_pointer]=memory[address_pointer] ;// : backup[2]<=memory[2]
                                        address_pointer=address_pointer+1;// : it will be  address_pointer=3
                                        buffer_pointer=buffer_pointer+1;//: it will be if buffer_pointer=3
                                          end
                                         if(buffer_pointer < 10 && address_pointer != 4) begin
                                        bigger_buffer[buffer_pointer]=memory[address_pointer] ;// backup[buffer_pointer]<=memory[address_pointer] backup[3]<=memory[3]
                              
                                        buffer_pointer=buffer_pointer+1;//buffer pointer increases by 1 because if we want to transfer data again from the smaller buffer to the bigger buffer
                                                                        //we need to write in the next location
                                        end
                                         backup_done = 2'b01;
                                         count_of_writed_data = 3'b000;
                                         address_pointer=0;
                                         saved = 0;
                                         end   
                                    if(backup_done==2'b01)
                                       begin  
                                         backup_done=2'b10;
                                        end
                                    end // end if(write_op==1)



                              end //end of always

                          always@(negedge clock)
                              begin //:start of always block
                               if(write_op && true_address == 1) 
                                  begin  // begin if of write_op
                                   if(addressread==1) 
                                    begin 
                                     DEVSEL=0;
                                     TRDY=0; 
                                     addressread=0;  
                                   end 
                                   // if write_op ?
                                  if(framein==1) 
                                    begin // if frame=1?
                                      if(IRDY==1) begin
                                      TRDY<=1;
                                      DEVSEL<=1;
                                      stop <= 1;
                                      count_of_writed_data<=3'b000;
                                      write_op <=0;
                                      true_address = 0;  
                                        end // IRDY IF
                                  end // if frame=1?
                                  if(4 - saved - count_of_writed_data == 0)  //if saved = 0 that means we start writing at location 0 so count_of_writed_data must equal 4 in order to enter the if condition
                                     begin                                   //if saved = 1 that means we start writing at location 1 so count_of_writed_data must equal 3 in order to enter the if condition
                                      TRDY <= 1;                             //that means we enter this block if the smaller buffer is full
                                                                             //TRDY becomes one if the master decided to end the transaction or to write more than the allowed number of words
                                       count_of_writed_data = count_of_writed_data + 1;    
                                        if((buffer_pointer + count_of_writed_data) > 11)     //if this condition is true that means that the bigger buffer is full and we can't transfer data from the smaller buffer to the bigger one
                                               begin
                                                 stop = 0;                       //the stop signal = 0 to make the master stop writing
                                               end
                                     end
                                 if(backup_done==2'b10 && stop != 0)   //if the data is transfered from the smaller buffer to the bigger buffer and the bigger buffer wasn't full 
                                   begin
                                          TRDY=0;                           
                                        backup_done=2'b00;
                                        count_of_writed_data = 0;
                                   end
                                 
                                 end  // if write_op ?






                        /////////////////////////Read Code///////////////////////
                            
                           end // end of always 


endmodule

