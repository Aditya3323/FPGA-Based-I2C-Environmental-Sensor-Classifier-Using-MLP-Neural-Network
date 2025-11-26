module B1_ROM (
    input  [2:0] addr, 
    output reg signed [15:0] data
);

always @(*) begin
    case (addr)
        0: data = -7876;
        1: data = 3147;
        2: data = -2385;
        3: data = -12180;
        4: data = -11202;
        5: data = -15634;
        6: data = -5337;
        7: data = -6153;
        default: data = 16'd0;
    endcase
end

endmodule
