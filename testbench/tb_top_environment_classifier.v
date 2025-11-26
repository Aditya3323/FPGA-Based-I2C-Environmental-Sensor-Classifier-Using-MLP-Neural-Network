`timescale 1ns/1ps

module tb_top_environment_classifier;

    reg clk;
    reg rst;

    wire sda;
    wire scl;
    wire [4:0] classification;

    // I2C pullups
    pullup(sda);
    pullup(scl);

    // DUT
    top_environment_classifier DUT (
        .clk(clk),
        .rst(rst),
        .sda(sda),
        .scl(scl),
        .classification(classification)
    );

    // -----------------------------------------
    // Sensor Models on Same I2C Bus
    // -----------------------------------------
    i2c_sensor_model #(.I2C_ADDR(7'h44)) SHT31  (sda, scl); // Temp
    i2c_sensor_model #(.I2C_ADDR(7'h5A)) CCS811 (sda, scl); // Air
    i2c_sensor_model #(.I2C_ADDR(7'h5C)) LPS22  (sda, scl); // Pressure
    i2c_sensor_model #(.I2C_ADDR(7'h23)) BH1750 (sda, scl); // Light

    // -----------------------------------------
    // Clock (100 MHz)
    // -----------------------------------------
    always #5 clk = ~clk;

    // -----------------------------------------
    // Simulation Control
    // -----------------------------------------
    initial begin
        clk = 0;
        rst = 1;
        #50 rst = 0;

        #20000;   // allow several I2C scan cycles
        $stop;
    end

    // -----------------------------------------
    // Monitor Output
    // -----------------------------------------
    initial begin
        $monitor("T=%0t | CLASS=%b", $time, classification);
    end

    // -----------------------------------------
    // Waveform Dump
    // -----------------------------------------
    initial begin
        $dumpfile("env_classifier_i2c.vcd");
        $dumpvars(0, tb_top_environment_classifier_i2c);
    end

endmodule
