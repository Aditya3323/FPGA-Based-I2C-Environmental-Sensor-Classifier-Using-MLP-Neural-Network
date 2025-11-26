module neuron_o(
    input  signed [15:0] h1,     // Hidden layer neuron outputs (Q1.15)
    input  signed [15:0] h2,
    input  signed [15:0] h3,
    input  signed [15:0] h4,
    input  signed [15:0] h5,
    input  signed [15:0] h6,
    input  signed [15:0] h7,
    input  signed [15:0] h8,
    input  [2:0]  addr,          // ROM address (output neuron index)
    output signed [15:0] out
);

    // ---------- Weight & Bias ROM ----------
    wire signed [15:0] w1, w2, w3, w4, w5, w6, w7, w8;
    wire signed [15:0] b;

    W2_ROM myW2(
        .addr(addr),
        .w1(w1), .w2(w2), .w3(w3), .w4(w4),
        .w5(w5), .w6(w6), .w7(w7), .w8(w8)
    );

    B2_ROM myB2(
        .addr(addr),
        .data(b)
    );

    // ---------- Multiply (Q1.15 × Q1.15 = Q2.30) ----------
    wire signed [31:0] p1 = h1 * w1;
    wire signed [31:0] p2 = h2 * w2;
    wire signed [31:0] p3 = h3 * w3;
    wire signed [31:0] p4 = h4 * w4;
    wire signed [31:0] p5 = h5 * w5;
    wire signed [31:0] p6 = h6 * w6;
    wire signed [31:0] p7 = h7 * w7;
    wire signed [31:0] p8 = h8 * w8;

    // ---------- Bias Q1.15 → Q2.30 ----------
    wire signed [31:0] b32 = b <<< 15;

    // ---------- Accumulate ----------
    wire signed [31:0] sum32 =
        p1 + p2 + p3 + p4 +
        p5 + p6 + p7 + p8 +
        b32;

    // ---------- Back to Q1.15 ----------
    wire signed [15:0] sum16 = sum32[30:15];

	assign out = (sum16 > 0) ? sum16 : 16'd0;

endmodule
