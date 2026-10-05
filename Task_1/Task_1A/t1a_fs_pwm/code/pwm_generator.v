// Logic Quest Bot : Task 1A : PWM Generator
/*
Instructions
-------------------
Students are not allowed to make any changes in the Module declaration.
This file is used to design a module which will scale down the clk_5MHz Clock Frequency to 500Hz and perform Pulse Width Modulation on it.

Recommended Quartus Version : 20.1
The submitted project file must be 20.1 compatible as the evaluation will be done on Quartus Prime Lite 20.1.

Warning: The error due to compatibility will not be entertained.
-------------------
*/

//PWM Generator
//Inputs : clk_5MHz, pulse_width
//Output : clk_500Hz, pwm_signal

module pwm_generator(
    input clk_5MHz,
    input reset_n,
    input [4:0] pulse_width,
    output reg clk_500Hz, pwm_signal
);

//////////////////DO NOT MAKE ANY CHANGES ABOVE THIS LINE //////////////////

/*
 * Two-stage logic:
 * Stage 1: Generate clk_500Hz by toggling every 5000 clk_5MHz cycles
 *          (5 MHz / 10000 = 500 Hz, i.e., half-period = 5000 cycles)
 * Stage 2: For every full 500 Hz period (10000 clk_5MHz cycles = 20 PWM steps
 *          where each step = 500 clk_5MHz cycles), compare step counter to
 *          pulse_width to produce pwm_signal.
 *
 *  pulse_width = 0  → pwm stays low  (0% duty)
 *  pulse_width = 5  → 25%  (5/20)
 *  pulse_width = 10 → 50% (10/20)
 *  pulse_width = 20 → pwm stays high (100% duty)
 */

// --- Stage 1: clk_500Hz divider (toggle every 5000 clk_5MHz cycles) ---
reg [12:0] clk_div_cnt;   // counts 0..4999

always @(posedge clk_5MHz or negedge reset_n) begin
    if (!reset_n) begin
        clk_div_cnt <= 13'd0;
        clk_500Hz   <= 1'b1;
    end else begin
        if (clk_div_cnt == 13'd4999) begin
            clk_div_cnt <= 13'd0;
            clk_500Hz   <= ~clk_500Hz;   // toggle → 500 Hz
        end else begin
            clk_div_cnt <= clk_div_cnt + 13'd1;
        end
    end
end

// --- Stage 2: PWM signal (20 steps per 500 Hz period) ---
// Each step = 500 clk_5MHz cycles  (5 MHz / 500 Hz / 20 steps = 500)
reg [8:0]  step_cnt;      // counts 0..499 within one PWM step
reg [4:0]  pwm_step;      // counts 0..19 steps per 500 Hz period
reg [4:0]  active_pulse_width;

always @(posedge clk_5MHz or negedge reset_n) begin
    if (!reset_n) begin
        step_cnt   <= 9'd0;
        pwm_step   <= 5'd0;
        pwm_signal <= 1'b0;
        active_pulse_width <= 5'd0;
    end else begin
        if (step_cnt == 9'd0 && pwm_step == 5'd0) begin
            active_pulse_width <= (pulse_width > 5'd20) ? 5'd20 : pulse_width;
        end

        if (step_cnt == 9'd499) begin
            step_cnt <= 9'd0;
            if (pwm_step == 5'd19)
                pwm_step <= 5'd0;
            else
                pwm_step <= pwm_step + 5'd1;
        end else begin
            step_cnt <= step_cnt + 9'd1;
        end
        // PWM output: high when current step index < active_pulse_width
        // For the very first cycle, use the new active_pulse_width
        pwm_signal <= (pwm_step < ((step_cnt == 9'd0 && pwm_step == 5'd0) ? ((pulse_width > 5'd20) ? 5'd20 : pulse_width) : active_pulse_width)) ? 1'b1 : 1'b0;
    end
end
 
//////////////////DO NOT MAKE ANY CHANGES BELOW THIS LINE//////////////////

endmodule

