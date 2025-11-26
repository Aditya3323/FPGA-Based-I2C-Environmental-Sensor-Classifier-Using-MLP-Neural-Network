module classifier_top(
    input  [15:0] temp,     
    input  [15:0] light,
    input  [15:0] voc,
    input  [15:0] press,
    output [2:0]  class_id,
    output [4:0]  class 
);

    // ==========================================
    // 1. Hidden Layer (8 Neurons)
    // ==========================================

    wire signed [15:0] h [0:7];

    genvar i;
    generate
        for(i = 0; i < 8; i = i + 1) begin : HIDDEN_LAYER
            neuron_h H (
                .in1(temp),
                .in2(light),
                .in3(voc),
                .in4(press),
                .addr(i),      // select correct row from W1_ROM + B1_ROM
                .out(h[i])
            );
        end
    endgenerate


    // ==========================================
    // 2. Output Layer (5 Neurons)
    // ==========================================

    wire signed [15:0] y [0:4];

    genvar j;
    generate
        for(j = 0; j < 5; j = j + 1) begin : OUTPUT_LAYER
            neuron_o O (
                .h1(h[0]),
                .h2(h[1]),
                .h3(h[2]),
                .h4(h[3]),
                .h5(h[4]),
                .h6(h[5]),
                .h7(h[6]),
                .h8(h[7]),
                .addr(j),     // selects W2_ROM row + B2_ROM
                .out(y[j])
            );
        end
    endgenerate


    // ==========================================
    // 3. Class Selection (argmax of 5 outputs)
    // ==========================================

    reg [2:0] max_index;
    reg signed [15:0] max_value;

    always @(*) begin
        max_value = y[0];
        max_index = 0;

        if(y[1] > max_value) begin max_value = y[1]; max_index = 1; end
        if(y[2] > max_value) begin max_value = y[2]; max_index = 2; end
        if(y[3] > max_value) begin max_value = y[3]; max_index = 3; end
        if(y[4] > max_value) begin max_value = y[4]; max_index = 4; end
    end

    assign class_id = max_index;

    // One-hot output
    assign class_onehot = (max_index == 0) ? 5'b00001 :
                          (max_index == 1) ? 5'b00010 :
                          (max_index == 2) ? 5'b00100 :
                          (max_index == 3) ? 5'b01000 :
                                             5'b10000;

endmodule
