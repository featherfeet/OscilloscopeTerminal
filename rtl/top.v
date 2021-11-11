`define CLOCK_DIVIDER 'd12
`define WAVE_TABLE_LENGTH 'd256
`define DAC_BITS 'd8

module top(
    input [3:0] KEY,
    input CLOCK_50,
    output wire [35:0] GPIO_0
);

reg slow_clock = 'b0;
reg [$clog2(`CLOCK_DIVIDER) - 1:0] counter = 'd0;

// Divide 50 MHz clock by `CLOCK_DIVIDER so that the period of slow_clock is 5 milliseconds (for `CLOCK_DIVIDER of 250,000).
always @(posedge CLOCK_50)
begin
    if (KEY[0] == 0)
    begin
        slow_clock <= 'b0;
        counter <= 'd0;
    end
    else
    begin
        if (counter == `CLOCK_DIVIDER)
        begin
            counter <= 'd0;
            slow_clock <= ~slow_clock;
        end
        else
        begin
            counter <= counter + 'd1;
        end
    end
end

// Load sine wave lookup table for `DAC_BITS-bit DAC (with `WAVE_TABLE_LENGTH entries).
reg[0:`DAC_BITS - 1] wave_table[`WAVE_TABLE_LENGTH - 1:0];
initial begin
    $readmemh("rtl/sine_wave_8_bit_dac_255_entries.mem", wave_table);
end

// Generate sine and cosine waves.
reg [`DAC_BITS - 1:0] x_dac = 'b0;
reg [`DAC_BITS - 1:0] y_dac = 'b0;
assign GPIO_0[`DAC_BITS - 1:0] = x_dac;
assign GPIO_0[2 * `DAC_BITS - 1:`DAC_BITS] = y_dac;
reg [$clog2(`WAVE_TABLE_LENGTH) - 1:0] table_index_x = 0;
reg [$clog2(`WAVE_TABLE_LENGTH) - 1:0] table_index_y = 'd64;
always @(posedge slow_clock)
begin
    if (KEY[0] == 'b0)
    begin
        x_dac <= 'b0;
        y_dac <= 'b0;
        table_index_x <= 'b0;
        table_index_y <= 'd64;
    end
    else
    begin
        if (table_index_x >= `WAVE_TABLE_LENGTH)
        begin
            table_index_x <= 'b0;
        end
        else
        begin
            x_dac <= wave_table[table_index_x];
            table_index_x <= table_index_x + 'b1;
        end
        if (table_index_y >= `WAVE_TABLE_LENGTH)
        begin
            table_index_y <= 'b0;
        end
        else
        begin
            y_dac <= wave_table[table_index_y];
            table_index_y <= table_index_y + 'd3;
        end
        $display("%d,%d", x_dac, y_dac);
    end
end

endmodule
