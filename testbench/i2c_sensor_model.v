module i2c_sensor_model #(
    parameter [6:0] I2C_ADDR = 7'h44
)(
    inout wire sda,
    input wire scl
);

    reg sda_drive;
    assign sda = (sda_drive) ? 1'b0 : 1'bz;

    reg [7:0] shift_reg;
    reg [3:0] bit_cnt;
    reg [7:0] reg_addr;
    reg [15:0] sensor_data;

    reg rw;
    reg active;

    // ---------------------------------------------------
    // START Condition Detection
    // ---------------------------------------------------
    always @(negedge sda) begin
        if (scl) begin
            active    <= 1;
            bit_cnt  <= 0;
        end
    end

    // ---------------------------------------------------
    // STOP Detection
    // ---------------------------------------------------
    always @(posedge sda) begin
        if (scl) begin
            active    <= 0;
            sda_drive <= 0;
        end
    end

    // ---------------------------------------------------
    // Shift In Address + Register
    // ---------------------------------------------------
    always @(posedge scl) begin
        if (active) begin
            shift_reg <= {shift_reg[6:0], sda};
            bit_cnt   <= bit_cnt + 1;

            // Address byte
            if (bit_cnt == 7) begin
                rw <= sda;
                if (shift_reg[7:1] == I2C_ADDR) begin
                    sda_drive <= 1'b1; // ACK
                end else begin
                    active <= 0;
                end
            end

            // Register Address Byte
            if (bit_cnt == 15) begin
                reg_addr <= shift_reg;
                load_sensor_data();
            end
        end
    end

    // ---------------------------------------------------
    // Drive Data back to Master
    // ---------------------------------------------------
    always @(negedge scl) begin
        if (rw && active) begin
            sda_drive <= sensor_data[15];
            sensor_data <= {sensor_data[14:0], 1'b0};
        end
    end

    // ---------------------------------------------------
    // Sensor Register Map
    // ---------------------------------------------------
    task load_sensor_data;
        begin
            case (I2C_ADDR)

                // SHT31 - Temperature
                7'h44: sensor_data = 16'd250;   // 25.0°C

                // CCS811 - eCO2
                7'h5A: sensor_data = 16'd600;   // Good Air

                // LPS22HB - Pressure
                7'h5C: sensor_data = 16'd1013;  // Normal Pressure

                // BH1750 - Light
                7'h23: sensor_data = 16'd350;   // Medium Light

                default: sensor_data = 16'h0000;
            endcase
        end
    endtask

endmodule
