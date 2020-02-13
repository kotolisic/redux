`timescale 10ns / 1ns

module main;

// ---------------------------------------------------------------------
reg clock; always #0.5 clock = ~clock;

initial begin clock = 0; #5 locked = 1; #2000 $finish; end
initial begin $dumpfile("main.vcd"); $dumpvars(0, main); end

// ---------------------------------------------------------------------
// Памяти интерфейс
// ---------------------------------------------------------------------
reg  [7:0]  ram[1048576];
initial     $readmemh("mem.hex", ram, 20'h0000);

reg         locked = 0;
wire [19:0] o_address;
reg  [7:0]  i_data  = 8'hFF;
reg  [7:0]  i_data_ = 8'hFF;
wire [7:0]  o_data;
wire        o_we;
wire [7:0]  reg_n;
wire [31:0] reg_i;
wire [31:0] reg_o;

// Чтение и запись в память
always @(posedge clock) begin

    // Память
    i_data  <= i_data_;
    i_data_ <= ram[ o_address ];

    // Запись в память
    if (o_we) ram[ o_address ] <= o_data;

end

// ---------------------------------------------------------------------
redux ucpu
(
    .locked (locked),
    .clock  (clock),
    .address(o_address),
    .din    (i_data),
    .dout   (o_data),
    .we     (o_we),
    .reg_n  (reg_n),
    .reg_i  (reg_i),
    .reg_o  (reg_o)
);

endmodule
