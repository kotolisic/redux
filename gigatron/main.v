`timescale 10ns / 1ns

module main;

// ---------------------------------------------------------------------
reg clock;  always #0.5 clock   = ~clock;
reg clock6; always #2.0 clock6  = ~clock6; // 6.25 Mhz

initial begin clock = 0; clock6 = 0; #2000 $finish; end
initial begin $dumpfile("main.vcd"); $dumpvars(0, main); end

// ---------------------------------------------------------------------
// Памяти интерфейс
// ---------------------------------------------------------------------

reg  [15:0]  rom[65536]; // 64k, word
reg  [ 7:0]  ram[32768]; // 32k, byte

initial      $readmemh("rom.hex", rom, 0);

reg  [15:0] data_ir;
wire [15:0] address_pc;

always @(posedge clock) begin

    // Чтение данных из ROM
    data_ir <= rom[ address_pc ];

end

// ---------------------------------------------------------------------
gigatron u1
(
    .clock  (clock6),
    .rst_n  (1'b1),
    .pc     (address_pc),
    .ir     (data_ir)

    // ....
);

endmodule
