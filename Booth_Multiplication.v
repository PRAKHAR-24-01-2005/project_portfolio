module Boothmultip (clk,reset,start,x,y,result,valid);

    //Declaring the inputs
    input [31:0] x,y;        // x <= Multiplier , y <= Multiplicand
    input clk,reset,start;

    //Declaring the outputs
    output reg [63:0] result;
    output valid;

    //Defining internals
    reg [63:0] result_next,result_temp;
    reg [1:0] temp,next_temp;      //last 2 bits Q0 and Q-1 for deciding the logic
    reg [4:0] count,next_count;    //indexes to access updated Q0 and Q-1 bits.
    reg next_state, pres_state;
    reg valid,next_valid;


    //Defining the parameters
    parameter IDLE = 1'b0;
    parameter START = 1'b1;

    //design logic
    always @ (posedge clk or posedge reset) begin
      if (reset)
        begin
          result = 64'b0;
          temp = 2'b0;
          count = 5'b0;
          pres_state = 0;
          valid = 0;
        end

    else
        begin
          result     <= result_next;
          valid      <= next_valid;
          pres_state <= next_state;
          temp       <= next_temp;
          count      <= next_count;
        end
    end

    always @ (*) begin
      case (pres_state)
        IDLE :
          begin
            next_count = 5'b0;
            next_valid = 1'b0;
            if (start)
              begin
                next_state = START;
                next_temp = {x[0],1'b0};
                result_next = {32'b0,x};
              end
            else
              begin
                next_state = pres_state;
                next_temp = 2'b0;
                result_next = 64'b0;
              end
          end
        
        START:
          begin
            
            case (temp)
              2'b01 : result_temp = {result[63:32]+y,result[31:0]};
              2'b10 : result_temp = {result[63:32]-y,result[31:0]};
              default : result_temp = result;
            endcase

            next_temp  = {x[count+1],x[count]};
            next_count = count + 5'b00001;
            result_next = {result_temp[63], result_temp[63:1]};
            next_valid = (count == 5'd31) ? 1'b1 : 1'b0; 
            next_state = (count == 5'd31) ? IDLE : pres_state;	

          end

      endcase

    end

endmodule