module B2_ROM (
    input  [2:0] addr,      // 0–4
    output reg signed [15:0] data
);

always @(*) begin
    case (addr)
        0: data = 14483;
        1: data = 24745;
        2: data = -5303;
        3: data = -9328;
        4: data = 20248;
        default: data = 16'd0;
    endcase
end

endmodule
