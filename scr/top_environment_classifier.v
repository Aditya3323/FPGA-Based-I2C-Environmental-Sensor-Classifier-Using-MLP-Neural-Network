
module top_environment_classifier(
    input  wire clk,
    input  wire rst,
    inout  wire sda,
    output wire scl,
    
    output [4:0] classification
    );
    
     wire [15:0] in1_temp;
     wire [15:0] in2_humidity;
     wire [15:0] in3_pressure;
     wire [15:0] in4_light;
     
     wire  [2:0]  class_id;
     wire  [4:0]  class; 
    
    i2c_4sensor_top I2C_TOP (
        .clk(clk),
        .rst(rst),
        .sda(sda),
        .scl(scl),
        .in1_temp(in1_temp),
        .in2_airq(in2_airq),
        .in3_pressure(in3_pressure),
        .in4_light(in4_light)
    );
    
    classifier_top TOP_CLASSIFIER(
        .temp(in1_temp),     
        .light(in4_light),
        .voc(in2_humidity),
        .press(in3_pressure),
        .class_id(class_id),
        .class(class) 
    );
    
    assign classification = class ;
    
endmodule
