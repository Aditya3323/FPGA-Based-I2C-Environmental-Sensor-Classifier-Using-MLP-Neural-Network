module i2c_4sensor_top (
    input  wire clk,
    input  wire rst,

    inout  wire sda,
    output wire scl,

    output reg [15:0] in1_temp,
    output reg [15:0] in2_airq,
    output reg [15:0] in3_pressure,
    output reg [15:0] in4_light
);

    //-------------------------------------------------------
    // Wires to connect top ? I2C Master
    //-------------------------------------------------------
    reg        start;
    wire       busy;
    wire       done;
    reg [6:0]  dev_addr;
    reg [7:0]  reg_addr;
    wire [15:0] read_data;

    //-------------------------------------------------------
    // I2C Master Instance
    //-------------------------------------------------------
    i2c_master MASTER (
        .clk(clk),
        .rst(rst),
        .start(start),
        .dev_addr(dev_addr),
        .reg_addr(reg_addr),
        .busy(busy),
        .done(done),
        .sda(sda),
        .scl(scl),
        .read_data(read_data)
    );

    //-------------------------------------------------------
    // Sensor FSM
    //-------------------------------------------------------
    reg [3:0] state;

    localparam S_IDLE   = 0,
               S_T_WAIT = 1,
               S_A_WAIT = 2,
               S_P_WAIT = 3,
               S_L_WAIT = 4;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            state       <= S_IDLE;
            start       <= 0;
            in1_temp    <= 0;
            in2_airq    <= 0;
            in3_pressure<= 0;
            in4_light   <= 0;
        end else begin
            start <= 0;   // auto-clear

            case(state)

            //-------------------------------------------------
            // SHT31 - Temperature
            //-------------------------------------------------
            S_IDLE: begin
                dev_addr <= 7'h44;   // SHT31
                reg_addr <= 8'h00;   // Temperature
                start    <= 1;
                state    <= S_T_WAIT;
            end

            S_T_WAIT: begin
                if (done) begin
                    in1_temp <= read_data;

                    //-------------------------------------------------
                    // CCS811 - Air Quality
                    //-------------------------------------------------
                    dev_addr <= 7'h5A;   // CCS811
                    reg_addr <= 8'h02;   // eCO2 / TVOC result
                    start    <= 1;
                    state    <= S_A_WAIT;
                end
            end

            //-------------------------------------------------
            // CCS811 - Air Quality
            //-------------------------------------------------
            S_A_WAIT: begin
                if (done) begin
                    in2_airq <= read_data;

                    //-------------------------------------------------
                    // LPS22HB - Pressure
                    //-------------------------------------------------
                    dev_addr <= 7'h5C;
                    reg_addr <= 8'h28;
                    start    <= 1;
                    state    <= S_P_WAIT;
                end
            end

            //-------------------------------------------------
            // LPS22HB - Pressure
            //-------------------------------------------------
            S_P_WAIT: begin
                if (done) begin
                    in3_pressure <= read_data;

                    //-------------------------------------------------
                    // BH1750 - Light
                    //-------------------------------------------------
                    dev_addr <= 7'h23;
                    reg_addr <= 8'h10;
                    start    <= 1;
                    state    <= S_L_WAIT;
                end
            end

            //-------------------------------------------------
            // BH1750 - Light
            //-------------------------------------------------
            S_L_WAIT: begin
                if (done) begin
                    in4_light <= read_data;
                    state <= S_IDLE;
                end
            end

            endcase
        end
    end

endmodule
