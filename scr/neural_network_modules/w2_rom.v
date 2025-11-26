module W2_ROM (
    input  [2:0] addr,       // 0–39 (8 neurons × 5 weights)
    output reg signed [15:0] w1,
    output reg signed [15:0] w2,
    output reg signed [15:0] w3,
    output reg signed [15:0] w4,
    output reg signed [15:0] w5,
    output reg signed [15:0] w6,
    output reg signed [15:0] w7,
    output reg signed [15:0] w8
);

always @(*) begin
    
    // ---------------------- W1 ----------------------
    case (addr)
        0: w1 = -32768;
        1: w1 = -32768;
        2: w1 = -9008;
        3: w1 = 15868;
        4: w1 = 24784;
        default: w1 = 16'd0;
    endcase

    // ---------------------- W2 ----------------------
    case (addr)
        0: w2 = 17285;
        1: w2 = -22252;
        2: w2 = -5503;
        3: w2 = -17145;
        4: w2 = -23877;
        default: w2 = 16'd0;
    endcase

    // ---------------------- W3 ----------------------
    case (addr)
        0: w3 = -32768;
        1: w3 = 32767;
        2: w3 = 5431;
        3: w3 = 10671;
        4: w3 = -27083;
        default: w3 = 16'd0;
    endcase

    // ---------------------- W4 ----------------------
    case (addr)
        0: w4 = 11975;
        1: w4 = -22501;
        2: w4 = 18892;
        3: w4 = -17128;
        4: w4 = -11147;
        default: w4 = 16'd0;
    endcase

    // ---------------------- W5 ----------------------
    case (addr)
        0: w5 = 4189;
        1: w5 = -31134;
        2: w5 = 11857;
        3: w5 = -10470;
        4: w5 = -8822;
        default: w5 = 16'd0;
    endcase

    // ---------------------- W6 ----------------------
    case (addr)
        0: w6 = 32767;
        1: w6 = -13402;
        2: w6 = -20437;
        3: w6 = -4169;
        4: w6 = -15521;
        default: w6 = 16'd0;
    endcase

    // ---------------------- W7 ----------------------
    case (addr)
        0: w7 = -6003;
        1: w7 = -13031;
        2: w7 = 11901;
        3: w7 = 20237;
        4: w7 = -32768;
        default: w7 = 16'd0;
    endcase

    // ---------------------- W8 ----------------------
    case (addr)
        0: w8 = 19220;
        1: w8 = -18830;
        2: w8 = -1417;
        3: w8 = 10260;
        4: w8 = -1514;
        default: w8 = 16'd0;
    endcase

end

endmodule
