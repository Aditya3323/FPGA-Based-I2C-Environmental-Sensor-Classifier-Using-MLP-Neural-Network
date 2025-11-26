module i2c_master (
    input  wire clk,
    input  wire rst,

    input  wire start,
    input  wire [6:0] dev_addr,
    input  wire [7:0] reg_addr,

    output reg busy,
    output reg done,

    inout  wire sda,
    output wire scl,

    output reg [15:0] read_data
);

    // ------------------------------------------------------
    // Clock divider for 100 kHz SCL
    // ------------------------------------------------------
    reg [8:0] clk_div;
    reg scl_int;
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            clk_div <= 0;
            scl_int <= 1;
        end else begin
            if (clk_div == 249) begin
                clk_div <= 0;
                scl_int <= ~scl_int;
            end else begin
                clk_div <= clk_div + 1;
            end
        end
    end
    assign scl = scl_int;

    // ------------------------------------------------------
    // SDA open-drain signals
    // ------------------------------------------------------
    reg sda_out;
    reg sda_oe;
    assign sda = sda_oe ? 1'b0 : 1'bz;
    wire sda_in = sda;

    // ------------------------------------------------------
    // FSM
    // ------------------------------------------------------
    reg [5:0] state;
    reg [3:0] bit_cnt;
    reg [7:0] shift;

    localparam ST_IDLE     = 0,
               ST_START    = 1,
               ST_ADDR_W   = 2,
               ST_ACK1     = 3,
               ST_REG      = 4,
               ST_ACK2     = 5,
               ST_RESTART  = 6,
               ST_ADDR_R   = 7,
               ST_ACK3     = 8,
               ST_READ_HI  = 9,
               ST_ACK4     = 10,
               ST_READ_LO  = 11,
               ST_NACK     = 12,
               ST_STOP     = 13,
               ST_DONE     = 14;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            state <= ST_IDLE;
            busy  <= 0;
            done  <= 0;
            sda_oe <= 0;
            shift <= 8'h00;
            bit_cnt <= 0;
            read_data <= 16'h0000;
        end else if (scl_int == 1) begin

            done <= 0;

            case(state)

            ST_IDLE: begin
                busy <= 0;
                sda_oe <= 0;
                if (start) begin
                    busy <= 1;
                    shift <= {dev_addr, 1'b0};  // write
                    bit_cnt <= 7;
                    state <= ST_START;
                end
            end

            ST_START: begin
                sda_oe <= 1;   // drive SDA low
                state <= ST_ADDR_W;
            end

            ST_ADDR_W: begin
                sda_out <= shift[bit_cnt];
                sda_oe <= 1;
                if (bit_cnt == 0) state <= ST_ACK1;
                else bit_cnt <= bit_cnt - 1;
            end

            ST_ACK1: begin
                sda_oe <= 0;   // release SDA
                shift <= reg_addr;
                bit_cnt <= 7;
                state <= ST_REG;
            end

            ST_REG: begin
                sda_out <= shift[bit_cnt];
                sda_oe <= 1;
                if (bit_cnt == 0) state <= ST_ACK2;
                else bit_cnt <= bit_cnt - 1;
            end

            ST_ACK2: begin
                sda_oe <= 0;
                shift <= {dev_addr, 1'b1}; // read
                bit_cnt <= 7;
                state <= ST_RESTART;
            end

            ST_RESTART: begin
                sda_oe <= 1;
                state <= ST_ADDR_R;
            end

            ST_ADDR_R: begin
                sda_out <= shift[bit_cnt];
                sda_oe <= 1;
                if (bit_cnt == 0) state <= ST_ACK3;
                else bit_cnt <= bit_cnt - 1;
            end

            ST_ACK3: begin
                sda_oe <= 0;
                bit_cnt <= 7;
                state <= ST_READ_HI;
            end

            ST_READ_HI: begin
                read_data[15:8] <= {read_data[14:8], sda_in};  // shift left
                if (bit_cnt == 0) state <= ST_ACK4;
                else bit_cnt <= bit_cnt - 1;
            end

            ST_ACK4: begin
                sda_oe <= 1;  // ACK
                bit_cnt <= 7;
                state <= ST_READ_LO;
            end

            ST_READ_LO: begin
                read_data[7:0] <= {read_data[6:0], sda_in};
                if (bit_cnt == 0) state <= ST_NACK;
                else bit_cnt <= bit_cnt - 1;
            end

            ST_NACK: begin
                sda_oe <= 0;
                state <= ST_STOP;
            end

            ST_STOP: begin
                sda_oe <= 1; // drive SDA high
                state <= ST_DONE;
            end

            ST_DONE: begin
                sda_oe <= 0;
                busy <= 0;
                done <= 1;
                state <= ST_IDLE;
            end

            endcase
        end
    end
endmodule
