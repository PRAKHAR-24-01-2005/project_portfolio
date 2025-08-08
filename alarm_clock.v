`include "clock_divider.v"

//Module defination and port declaration
module Aclock #(parameter clk_freq = 50_000_000)(
    input reset,
    input clk,
    input [1:0] H_in1,
    input [3:0] H_in0,
    input [3:0] M_in1,
    input [3:0] M_in0,
    input LD_time,
    input LD_alarm,
    input STOP_al,
    output reg alarm,
    output [1:0] H_out1,
    output [3:0] H_out0,
    output [3:0] M_out1,
    output [3:0] M_out0,
    output [3:0] S_out1,
    output [3:0] S_out0);

    // Declaring internal registers
    wire clk_1s;                                      // output of 1 sec clock generator
    reg AL_ON;                                        // Alarm on off flag
    reg [5:0] temp_hour, temp_minute, temp_second;    // Stores the current hour, minutes and seconds in the binary format
    reg [1:0] c_hour1,a_hour1;                        // Stores the current hour, minutes and seconds in the BCD format and a's reg are for alarm and c's are for clock's output.
    reg [3:0] c_hour0,a_hour0;
    reg [3:0] c_min1,a_min1;
    reg [3:0] c_min0,a_min0;
    reg [3:0] c_sec1;
    reg [3:0] c_sec0;

    // instantiating the 1 sec clock pulse generator
    clk_div #(.DIVISOR(clk_freq)) clk_1sec_gen (
        .clk(clk),
        .reset(reset),
        .clk_out(clk_1s)
    );

    //Mod 10 function
    function [3:0] mod_10;
    input [5:0] number;
        begin
            mod_10 = (number >=50) ? 5 : ((number >= 40)? 4 :((number >= 30)? 3 :((number >= 20)? 2 :((number >= 10)? 1 :0))));
        end
    endfunction

    always @ (posedge clk_1s or posedge reset) begin
        if (reset)
            begin
            a_hour0 <= 4'b0000;
            a_hour1 <= 2'b00;
            a_min0 <= 4'b0000;
            a_min1 <= 4'b0000;
            AL_ON <= 1'b0;
            alarm <= 0;
            temp_second <= 6'b0;
            temp_minute <= (M_in1 * 10) + M_in0;
            temp_hour <= (H_in1 * 10) + H_in0;
            end

        else 
            begin
            if (LD_alarm)
                begin
                    a_hour0 <= H_in0;
                    a_hour1 <= H_in1;
                    a_min0 <= M_in0;
                    a_min1 <= M_in1;
                    AL_ON <= 1'b1;                    
                end

            if (LD_time)
                begin
                    temp_second <= 6'b0;
                    temp_minute <= (M_in1 * 10) + M_in0;
                    temp_hour <= (H_in1 * 10) + H_in0;
                end

            else begin
                if (temp_second == 6'd59) 
                    begin
                        temp_second <= 6'b0;
                        if (temp_minute == 6'd59)
                            begin
                                temp_minute <= 6'b0;
                                if (temp_hour == 6'd23)
                                    temp_hour <= 6'b0;
                                else
                                    temp_hour <= temp_hour + 1;
                            end
                        else 
                            begin
                                temp_minute <= temp_minute + 1;
                            end
                    end 
                else begin
                    temp_second <= temp_second + 1;
                end
            end

        end

            // Binary to BCD conversion of clock time
            c_hour1 = mod_10(temp_hour);
            c_hour0 = temp_hour - c_hour1*10; 
            c_min1 = mod_10(temp_minute); 
            c_min0 = temp_minute - c_min1*10;
            c_sec1 = mod_10(temp_second);
            c_sec0 = temp_second - c_sec1*10; 

            if (AL_ON && !STOP_al)
                begin
                if ({a_hour1,a_hour0,a_min1,a_min0}=={c_hour1,c_hour0,c_min1,c_min0}) 
                    alarm <= 1;
                end
            else 
                alarm <= 0;

            if (STOP_al) AL_ON <= 0;

        end




    assign H_out1 = c_hour1;                // assigning the current time in BCD format to the clock output.
    assign H_out0 = c_hour0; 
    assign M_out1 = c_min1; 
    assign M_out0 = c_min0; 
    assign S_out1 = c_sec1;
    assign S_out0 = c_sec0;

endmodule