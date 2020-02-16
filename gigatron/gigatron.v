module gigatron(

    input   wire        clock,
    input   wire        rst_n,
    output  reg  [15:0] pc,
    input   wire [15:0] ir,

    // Адрес для чтения 
    output  reg  [14:0] r_addr,
    input   wire [ 7:0] i_data,

    // Адрес для записи
    output  reg  [14:0] w_addr,
    output  reg  [ 7:0] o_data,
    output  reg         o_we,

    // Порты ввода-вывода
    input   wire [ 7:0] inreg,
    output  reg  [ 7:0] out,
    output  reg  [ 7:0] outx
);

// Регистры
reg  [ 7:0] ac   = 0;
reg  [ 7:0] x    = 0;
reg  [ 7:0] y    = 0;

initial begin pc = 0; out = 0; outx = 0; end

wire [ 7:0] op   = ir[15:13]; // 3
wire [ 7:0] mode = ir[12:10]; // 3
wire [ 7:0] bus  = ir[ 9:8];  // 2
wire [ 7:0] d    = ir[ 7:0];  // 8
wire [ 7:0] zac  = {~ac[7], ac[6:0]};

// ---------------------------------------

reg  [ 7:0] b; // Значение на BUS
reg  [ 7:0] b_alu;
reg         cond;
reg  [ 7:0] base;

// Комбинационная логика
always @* begin

    base = pc[15:7];

    // Чтение из памяти по ZeroPage для branchOp
    if (op == 7) r_addr = d;
    // Иначе зависит от режимов
    else case (mode)

        4'h0, 4'h4, 4'h5, 4'h6: 
                    r_addr = d;
        4'h1:       r_addr = x;
        4'h2:       r_addr = {y, d};
        4'h3, 4'h7: r_addr = {y, x}; // bus=1, mode=7 => X++

    endcase

    // Выборка шины
    case (bus)

        2'b00: b = d;
        2'b01: b = i_data;
        2'b10: b = ac; 
        2'b11: b = inreg; 

    endcase

    // Результат вычисления АЛУ
    case (op)

        1: b_alu = ac & b; 
        2: b_alu = ac | b; 
        3: b_alu = ac ^ b; 
        4: b_alu = ac + b; 
        5: b_alu = ac - b;
        default: b_alu = b;

    endcase

    // Вычисление условия
    case (mode)

        /* JMP */ 0: begin cond = 1; base = y; end
        /* BGT */ 1: cond = zac  > 8'h80;
        /* BLT */ 2: cond = zac  < 8'h80;
        /* BNE */ 3: cond = zac != 8'h80;
        /* BEQ */ 4: cond = zac == 8'h80;
        /* BGE */ 5: cond = zac >= 8'h80;
        /* BLE */ 6: cond = zac <= 8'h80;
        /* BRA */ 7: cond = 1;

    endcase

end

// Основная логика
always @(posedge clock) begin

    pc   <= pc + 1;
    o_we <= 0;

    case (op)

        // storeOp
        6: begin

            w_addr <= r_addr;
            o_data <= b;
            o_we   <= 1'b1;

            case (mode)

                4: x <= b;
                5: y <= b;
                7: if (bus == 1) x <= x + 1;

            endcase

        end

        // brancOp
        7: if (cond) pc <= {base, b};

        // aluOp (0-5)
        default:
        begin

            // Запись обратно в регистры
            case (mode)

                0, 1, 2, 3:
                   ac <= b_alu;
                4: x  <= b_alu;
                5: y  <= b_alu;
                6, 7:
                begin

                    if (mode == 7 && bus == 1)
                        x <= x + 1;

                    if (out[6] == 1'b0 && b_alu[6])
                        outx <= ac;
                        
                    out <= b_alu;

                end
                
            endcase

        end
        
    endcase

end

endmodule
