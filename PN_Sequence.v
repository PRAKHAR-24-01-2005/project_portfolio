module pn_sequence #(parameter N = 4, parameter TAP_MASK = 4'b1100)(
    input clk,
    input reset,
    output reg [N-1:0] pn_out
);
    wire feedback;
    assign feedback = ^(pn_out & TAP_MASK); // XOR of tapped bits

    always @(posedge clk or posedge reset) begin
        if (reset)
            pn_out <= {N{1'b1}}; // initial seed
        else
            pn_out <= {pn_out[N-2:0], feedback}; // shift + feedback
    end
endmodule
