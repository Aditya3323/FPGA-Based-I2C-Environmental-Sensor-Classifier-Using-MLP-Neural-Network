module neuron_h(
    input  [15:0] in1,      // UNSIGNED Q1.15 input
    input  [15:0] in2,
    input  [15:0] in3,
    input  [15:0] in4,
    input  [2:0]  addr,     // ROM address
    output signed [15:0] out
);

    // ---------- Weight & Bias ROM ----------
    wire signed [15:0] w1, w2, w3, w4;
    wire signed [15:0] b;

    W1_ROM myW1(.addr(addr), .w1(w1), .w2(w2), .w3(w3), .w4(w4));
    B1_ROM myB1(.addr(addr), .data(b));

    // ---------- Cast UNSIGNED input → SIGNED before multiply ----------
    wire signed [15:0] s_in1 = $signed(in1);
    wire signed [15:0] s_in2 = $signed(in2);
    wire signed [15:0] s_in3 = $signed(in3);
    wire signed [15:0] s_in4 = $signed(in4);

    // ---------- Multiply (Q1.15 × Q1.15 = Q2.30) ----------
    wire signed [31:0] p1 = s_in1 * w1;
    wire signed [31:0] p2 = s_in2 * w2;
    wire signed [31:0] p3 = s_in3 * w3;
    wire signed [31:0] p4 = s_in4 * w4;

    // ---------- Bias in Q1.15 → shift left 15 for Q2.30 ----------
    wire signed [31:0] b32 = b <<< 15;

    // ---------- Accumulate ----------
    wire signed [31:0] sum32 = p1 + p2 + p3 + p4 + b32;

    // ---------- Back to Q1.15 ----------
    wire signed [15:0] sum16 = sum32[30:15];

    // ---------- ReLU Activation ----------
    assign out = (sum16 > 0) ? sum16 : 16'd0;

endmodule
