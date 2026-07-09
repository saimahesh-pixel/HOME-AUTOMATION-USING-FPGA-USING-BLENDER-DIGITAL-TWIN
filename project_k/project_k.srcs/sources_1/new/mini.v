`timescale 1ns / 1ps

// ============================================================
// TOP MODULE
// ============================================================
module ultrasonic_display_top(
    input  wire clk,
    input  wire rst,
    input  wire echo,
    input  wire ir_sensor,
    input  wire gas_sensor,
    input  wire ky028_sen,
    input  wire ldr_sensor,

    output wire trig,
    output wire uart_tx,
    output wire buzzer,
    output wire light_out,
    output wire [3:0] led,
    output wire [2:0] rgb_led,
    output wire [6:0] seg,
    output wire [3:0] an
);

    wire ultra_detect;
    wire ir_detect;
    wire gas_detect;
    wire temp_detect;
    wire ldr_detect;
    wire [2:0] system_state;

    assign ir_detect   = ~ir_sensor;
    assign gas_detect  = gas_sensor;
    assign temp_detect = ~ky028_sen;
    assign ldr_detect  = ldr_sensor;

    assign buzzer    = ir_detect;
    assign light_out = ldr_detect;
    assign led[0]    = ultra_detect;
    assign led[1]    = ir_detect;
    assign led[2]    = temp_detect;
    assign led[3]    = ~ldr_detect;

    assign rgb_led[2] = ~gas_detect;
    assign rgb_led[1] = gas_detect;
    assign rgb_led[0] = 1'b0;

    // 1. Ultrasonic Controller
    ultrasonic_ctrl u_sonic (
        .clk(clk),
        .rst(rst),
        .echo(echo),
        .trig(trig),
        .ultra_detect(ultra_detect)
    );

    // 2. Sensor FSM
    sensor_fsm u_fsm (
        .clk(clk),
        .rst(rst),
        .ir_detect(ir_detect),
        .gas_detect(gas_detect),
        .temp_detect(temp_detect),
        .ldr_detect(ldr_detect),
        .ultra_detect(ultra_detect),
        .system_state(system_state)
    );

    // 3. Seven Segment Display
    seven_seg_ctrl u_seg (
        .clk(clk),
        .rst(rst),
        .ir_detect(ir_detect),
        .gas_detect(gas_detect),
        .temp_detect(temp_detect),
        .ldr_detect(ldr_detect),
        .ultra_detect(ultra_detect),
        .seg(seg),
        .an(an)
    );

    // 4. UART Sender
    uart_message_sender u_uart (
        .clk(clk),
        .rst(rst),
        .ir_detect(ir_detect),
        .gas_detect(gas_detect),
        .temp_detect(temp_detect),
        .ldr_detect(ldr_detect),
        .ultra_detect(ultra_detect),
        .tx(uart_tx)
    );

endmodule


// ============================================================
// ULTRASONIC CONTROLLER (fixed threshold)
// ============================================================
module ultrasonic_ctrl(
    input  wire clk,
    input  wire rst,
    input  wire echo,
    output reg  trig,
    output reg  ultra_detect
);
    reg [31:0] count;
    reg [31:0] echo_count;
    reg measuring;

    always @(posedge clk) begin
        if (rst) begin
            count        <= 0;
            trig         <= 0;
            echo_count   <= 0;
            measuring    <= 0;
            ultra_detect <= 0;
        end else begin
            if (count < 1000) trig <= 1;
            else              trig <= 0;

            if (count < 6_000_000) count <= count + 1;
            else                   count <= 0;

            if (echo) begin
                echo_count <= echo_count + 1;
                measuring  <= 1'b1;
            end else if (measuring) begin
                if (echo_count > 100 && echo_count < 174_000)
                    ultra_detect <= 1'b1;
                else
                    ultra_detect <= 1'b0;

                echo_count <= 0;
                measuring  <= 0;
            end
        end
    end
endmodule


// ============================================================
// SENSOR FSM
// ============================================================
module sensor_fsm(
    input  wire clk,
    input  wire rst,
    input  wire ir_detect,
    input  wire gas_detect,
    input  wire temp_detect,
    input  wire ldr_detect,
    input  wire ultra_detect,
    output reg  [2:0] system_state
);
    always @(posedge clk) begin
        if (rst) system_state <= 3'd0;
        else begin
            if      (ir_detect)    system_state <= 3'd1;
            else if (~gas_detect)  system_state <= 3'd2;
            else if (temp_detect)  system_state <= 3'd3;
            else if (ldr_detect)   system_state <= 3'd4;
            else if (ultra_detect) system_state <= 3'd5;
            else                   system_state <= 3'd0;
        end
    end
endmodule


// ============================================================
// SEVEN SEGMENT CONTROLLER
// ============================================================
module seven_seg_ctrl(
    input  wire clk,
    input  wire rst,
    input  wire ir_detect,
    input  wire gas_detect,
    input  wire temp_detect,
    input  wire ldr_detect,
    input  wire ultra_detect,
    output reg  [6:0] seg,
    output reg  [3:0] an
);
    reg [16:0] refresh_counter;
    reg [1:0]  active_digit;

    always @(posedge clk) begin
        if (rst) begin
            refresh_counter <= 0;
            active_digit    <= 0;
        end else begin
            if (refresh_counter >= 17'd99_999) begin
                refresh_counter <= 0;
                active_digit    <= active_digit + 1;
            end else
                refresh_counter <= refresh_counter + 1;
        end
    end

    wire [6:0] BLANK  = ~7'b0000000;
    wire [6:0] CHAR_N = ~7'b0010101;
    wire [6:0] CHAR_F = ~7'b1000111;
    wire [6:0] CHAR_G = ~7'b1111011;
    wire [6:0] CHAR_T = ~7'b0001111;
    wire [6:0] CHAR_L = ~7'b0001110;
    wire [6:0] CHAR_D = ~7'b0111101;

    reg [6:0] buffer [0:4];
    reg [2:0] ptr;
    reg [6:0] slot3, slot2, slot1, slot0;

    always @(*) begin
        buffer[0] = BLANK; buffer[1] = BLANK; buffer[2] = BLANK;
        buffer[3] = BLANK; buffer[4] = BLANK;
        ptr = 0;

        if (ir_detect)    begin buffer[ptr] = CHAR_F; ptr = ptr + 1; end
        if (~gas_detect)  begin buffer[ptr] = CHAR_G; ptr = ptr + 1; end
        if (temp_detect)  begin buffer[ptr] = CHAR_T; ptr = ptr + 1; end
        if (ldr_detect)   begin buffer[ptr] = CHAR_L; ptr = ptr + 1; end
        if (ultra_detect) begin buffer[ptr] = CHAR_D; ptr = ptr + 1; end

        if (ptr == 0) begin
            slot3 = BLANK; slot2 = BLANK;
            slot1 = BLANK; slot0 = CHAR_N;
        end else begin
            slot3 = buffer[0]; slot2 = buffer[1];
            slot1 = buffer[2]; slot0 = buffer[3];
        end
    end

    always @(*) begin
        case(active_digit)
            2'b00: begin an = 4'b0111; seg = slot3; end
            2'b01: begin an = 4'b1011; seg = slot2; end
            2'b10: begin an = 4'b1101; seg = slot1; end
            2'b11: begin an = 4'b1110; seg = slot0; end
        endcase
    end
endmodule


// ============================================================
// UART MESSAGE SENDER
// Sends: "STATE: FgTLd\r\n"
// ============================================================
module uart_message_sender(
    input  wire clk,
    input  wire rst,
    input  wire ir_detect,
    input  wire gas_detect,
    input  wire temp_detect,
    input  wire ldr_detect,
    input  wire ultra_detect,
    output wire tx
);
    reg tx_start;
    reg [7:0] tx_data;
    wire busy;

    uart_tx_module u_uart (
        .clk(clk), .rst(rst),
        .tx_start(tx_start),
        .tx_data(tx_data),
        .tx(tx),
        .busy(busy)
    );

    reg [26:0] one_sec_counter;
    reg send_enable;

    always @(posedge clk) begin
        if (rst) begin
            one_sec_counter <= 0;
            send_enable     <= 0;
        end else begin
            if (one_sec_counter == 27'd100_000_000 - 1) begin
                one_sec_counter <= 0;
                send_enable     <= 1'b1;
            end else begin
                one_sec_counter <= one_sec_counter + 1;
                send_enable     <= 1'b0;
            end
        end
    end

    reg [7:0]  msg_buf [0:13];
    reg [3:0]  msg_len;
    reg [3:0]  char_index;
    reg        sending;

    always @(posedge clk) begin
        if (rst) begin
            char_index <= 0;
            sending    <= 0;
            tx_start   <= 0;
            tx_data    <= 8'h00;
            msg_len    <= 0;
        end else begin
            tx_start <= 1'b0;

            if (send_enable && !sending && !busy) begin
                msg_buf[0] <= "S";
                msg_buf[1] <= "T";
                msg_buf[2] <= "A";
                msg_buf[3] <= "T";
                msg_buf[4] <= "E";
                msg_buf[5] <= ":";
                msg_buf[6] <= " ";

                begin : build_block
                    reg [3:0] p;
                    p = 7;

                    if (ir_detect)    begin msg_buf[p] <= "F"; p = p + 1; end
                    if (~gas_detect)  begin msg_buf[p] <= "g"; p = p + 1; end
                    if (temp_detect)  begin msg_buf[p] <= "T"; p = p + 1; end
                    if (ldr_detect)   begin msg_buf[p] <= "L"; p = p + 1; end
                    if (ultra_detect) begin msg_buf[p] <= "d"; p = p + 1; end

                    if (p == 7) begin msg_buf[p] <= "n"; p = p + 1; end

                    msg_buf[p]     <= 8'h0D;
                    msg_buf[p + 1] <= 8'h0A;
                    msg_len        <= p + 2;
                end

                sending    <= 1'b1;
                char_index <= 0;
            end

            if (sending && !busy && !tx_start) begin
                tx_data  <= msg_buf[char_index];
                tx_start <= 1'b1;

                if (char_index == msg_len - 1) begin
                    sending    <= 1'b0;
                    char_index <= 0;
                end else begin
                    char_index <= char_index + 1;
                end
            end
        end
    end
endmodule


// ============================================================
// UART TX ENGINE
// ============================================================
module uart_tx_module #(
    parameter CLK_FREQ = 100_000_000,
    parameter BAUD     = 9600
)(
    input  wire clk, input  wire rst,
    input  wire tx_start, input  wire [7:0] tx_data,
    output reg  tx, output reg  busy
);
    localparam CLKS_PER_BIT = CLK_FREQ / BAUD;
    reg [31:0] clk_count;
    reg [3:0]  bit_index;
    reg [9:0]  tx_shift;

    always @(posedge clk) begin
        if (rst) begin
            tx <= 1'b1; busy <= 1'b0;
            clk_count <= 0; bit_index <= 0;
            tx_shift  <= 10'h3FF;
        end else begin
            if (tx_start && !busy) begin
                tx_shift  <= {1'b1, tx_data, 1'b0};
                busy      <= 1'b1;
                clk_count <= 0;
                bit_index <= 0;
            end else if (busy) begin
                tx <= tx_shift[bit_index];
                if (clk_count < CLKS_PER_BIT - 1)
                    clk_count <= clk_count + 1;
                else begin
                    clk_count <= 0;
                    if (bit_index < 9)
                        bit_index <= bit_index + 1;
                    else begin
                        busy <= 1'b0;
                        tx   <= 1'b1;
                    end
                end
            end
        end
    end
endmodule