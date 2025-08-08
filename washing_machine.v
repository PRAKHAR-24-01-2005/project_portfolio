module washing_machine (clk,reset,start,lid_closed,water_filled,detergent_added,wash_timeout,rinse_timeout,spin_timeout,
                        lid_locked,water_fill_valve_on,motor_on,drain_valve,done,state_dbg);

    //input port declarations
    input clk,reset;
    input start,lid_closed,water_filled,detergent_added,wash_timeout,rinse_timeout,spin_timeout;

    //output port declarations
    output reg lid_locked,water_fill_valve_on,motor_on,drain_valve,done;
    output reg [2:0] state_dbg;

    //internal register, parameter and wire declarations
    parameter check_door = 3'b000;
    parameter add_water = 3'b001;
    parameter add_detergent = 3'b010;
    parameter wash = 3'b011;
    parameter rinse = 3'b100;
    parameter spin = 3'b101;
    reg [2:0] pres_state,next_state;
    reg start_prev;
    wire start_edge;

    always @(posedge clk or posedge reset) begin
        if (reset)
            start_prev <= 0;
        else
            start_prev <= start;
    end

    assign start_edge = start & ~start_prev;  // Rising edge of start


    always @ (posedge clk or posedge reset) begin
        if (reset)
            begin
                pres_state <= check_door;
            end

        else
            begin
                pres_state <= next_state;
            end
    end

    always @ (*) begin

        // Defaults
        lid_locked          = 1'b0;
        water_fill_valve_on = 1'b0;
        motor_on            = 1'b0;
        drain_valve         = 1'b0;
        done                = 1'b0;
        next_state = pres_state;
        state_dbg = pres_state;

        case (pres_state)
    
            check_door :
                begin
                  if (start_edge && lid_closed)
                    begin
                      next_state = add_water;
                      lid_locked = 1'b1;
                    end
                end

            add_water : 
                begin
                    lid_locked = 1'b1;
                  if (water_filled == 1)
                    begin
                        next_state = add_detergent;                       
                    end
                  else
                    begin
                      water_fill_valve_on = 1'b1;
                    end
                end

            add_detergent :
                begin
                    lid_locked = 1'b1;
                    if (detergent_added)
                        begin
                            next_state = wash;
                        end
                end
    
            wash :
                begin
                    lid_locked = 1'b1;
                    if (wash_timeout)
                        begin
                            next_state = rinse;      
                            drain_valve = 1'b1;
                        end

                    else
                        begin
                            motor_on = 1'b1;                              
                        end
                end

            rinse :
                begin
                    lid_locked = 1'b1;
                    if (rinse_timeout)
                        begin
                            next_state = spin;   
                            drain_valve = 1'b1;                          
                        end

                    else
                        begin
                            water_fill_valve_on = 1'b1;
                            motor_on = 1'b1;    
                            drain_valve = 1'b1;                           
                        end
                end

            spin :
                begin
                    if (spin_timeout)
                        begin
                            lid_locked = 1'b0; 
                            next_state = check_door;
                            drain_valve = 1'b0;
                            done = 1'b1;
                        end

                    else
                        begin
                            lid_locked = 1'b1; 
                            motor_on = 1'b1;    
                            drain_valve = 1'b1;                             
                        end
                end

            default:
				next_state = check_door;

        endcase


    end

        
endmodule