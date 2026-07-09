`timescale 1ns / 1ps

module tb_ultrasonic_display_top();

    reg  clk;
    reg  rst;
    reg  echo;
    reg  ir_sensor;
    reg  gas_sensor;
    reg  ky028_sen;
    reg  ldr_sensor;

    wire trig;
    wire uart_tx;
    wire light_out;
    wire [3:0] led;
    wire [2:0] rgb_led;
    wire [6:0] seg;
    wire [3:0] an;

    ultrasonic_display_top uut (
        .clk(clk),
        .rst(rst),
        .echo(echo),
        .ir_sensor(ir_sensor),
        .gas_sensor(gas_sensor),
        .ky028_sen(ky028_sen),
        .ldr_sensor(ldr_sensor),
        .trig(trig),
        .uart_tx(uart_tx),
        .light_out(light_out),
        .led(led),
        .rgb_led(rgb_led),
        .seg(seg),
        .an(an)
    );

    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    initial begin
        $display("Time(ns) | RST | IR(F) | GAS(g) | TMP(t) | LDR(L) | ECHO | FSM STATE");
        $display("----------------------------------------------------------------------");
        $monitor("%8t |  %b  |   %b   |   %b    |   %b    |   %b    |  %b   |     %d", 
                 $time, rst, ir_sensor, gas_sensor, ky028_sen, ldr_sensor, echo, uut.u_fsm.system_state);
    end

    initial begin
        rst = 1;
        echo = 0;
        ir_sensor = 1;
        gas_sensor = 0;
        ky028_sen = 1;
        ldr_sensor = 0;
        
        #100;
        rst = 0;
        #100;
        $display("--- SYSTEM NORMAL TEST ---");
        #1000;

        $display("--- INDIVIDUAL SENSOR ISOLATION TESTS ---");
        ldr_sensor = 1;
        #1000;
        ldr_sensor = 0;
        #500;

        ky028_sen = 0;
        #1000;
        ky028_sen = 1;
        #500;

        gas_sensor = 1;
        #1000;
        gas_sensor = 0;
        #500;

        ir_sensor = 0;
        #1000;
        ir_sensor = 1;
        #1000;

        $display("--- PRIORITY ESCALATION TEST (CASCADE UP) ---");
        ldr_sensor = 1;
        #1000;
        ky028_sen = 0;
        #1000;
        gas_sensor = 1;
        #1000;
        ir_sensor = 0;
        #1000;

        $display("--- PRIORITY DE-ESCALATION TEST (CASCADE DOWN) ---");
        ir_sensor = 1;
        #1000;
        gas_sensor = 0;
        #1000;
        ky028_sen = 1;
        #1000;
        ldr_sensor = 0;
        #1000;

        $display("--- SIMULTANEOUS ASSERTION TEST ---");
        ir_sensor = 0;
        gas_sensor = 1;
        ky028_sen = 0;
        ldr_sensor = 1;
        #1000;
        ir_sensor = 1;
        gas_sensor = 0;
        ky028_sen = 1;
        ldr_sensor = 0;
        #1000;

        $display("--- ASYNCHRONOUS RESET DURING CRITICAL ALERT ---");
        ir_sensor = 0;
        #500;
        rst = 1;
        #500;
        rst = 0;
        #500;
        ir_sensor = 1;
        #1000;

        $display("--- GLITCH REJECTION / SHORT PULSE TEST ---");
        gas_sensor = 1;
        #10;
        gas_sensor = 0;
        #1000;

        $display("--- FULL SIMULATION COMPLETE ---");
        $finish;
    end

    always @(posedge trig) begin
        #5000; 
        echo = 1;
        #150000; 
        echo = 0;
    end

endmodule