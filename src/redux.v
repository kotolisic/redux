module redux(

    input  wire        locked,
    input  wire        clock,

    // Память
    output reg  [19:0] address,
    input  wire [ 7:0] din,
    output reg  [ 7:0] dout,
    output reg         we,

    // Регистры
    output reg  [ 7:0] reg_n,
    input  wire [31:0] reg_i,
    output reg  [31:0] reg_o
);

initial begin we = 0; dout = 0; end

parameter state_init = 0;
parameter state_imm  = 1;
parameter state_reg  = 2;
parameter state_acc  = 3;
parameter state_exec = 4;

// ---------------------------------------------------------------------

// Состояние процессора
reg [19:0] pc        = 0;
reg        prefetch  = 1;
reg [ 1:0] fetch_id  = 0;

// Аккумулятор и операнд
reg [31:0] a;
reg [31:0] op;

reg [ 7:0] ir;
reg [ 3:0] tstate = 0;
reg [ 2:0] id = 0;

// ---------------------------------------------------------------------

// Обработчик
always @(posedge clock)
if (locked) begin

    // Выбран сброс, перезагрузить новую очередь
    if (prefetch) begin

        prefetch <= 0;
        fetch_id <= 0;
        address  <= pc;

    end
    else begin

        address <= address + 1;

        // Ожидание получения валидного опкода (latency=2)
        if (fetch_id < 2) fetch_id <= fetch_id + 1;
        else case (tstate)

            // Запомнить опкод
            // -------------------------------            
            state_init: begin

                ir <= din;
                id <= 0;
                op <= 0;

                // Выбор режима считывания
                casex (din)

                    /* REG */ 8'bxxxx_00_xx: begin tstate <= state_reg; end
                    /* IMM */ 8'bxxxx_01_xx: begin tstate <= state_imm; end
                    /* [A] */ 8'bxxxx_10_xx: begin tstate <= state_acc;  address <= a; end
                    /* PC  */ 8'bxxxx_11_xx: begin tstate <= state_exec; op <= pc + 2 + din[1:0]; end
                    
                endcase

            end

            // Считывание IMMEDIATE
            // -------------------------------
            state_imm: begin

                case (id)
 
                    0: op[ 7:0]  <= din;
                    1: op[15:8]  <= din;
                    2: op[23:16] <= din;
                    3: op[31:24] <= din;

                endcase
                
                if (id == ir[1:0]) tstate <= state_exec; id <= id + 1;

            end

            // Считывание регистра [$d] в `op`
            // -------------------------------
            state_reg: begin

                case (id)

                    0: begin reg_n <= din; end 
                    3: begin

                        case (ir[1:0])

                            0: op <= reg_i[ 7:0];
                            1: op <= reg_i[15:0];
                            2: op <= reg_i[23:0];
                            3: op <= reg_i[31:0];
                
                        endcase

                        tstate <= state_exec;

                    end

                endcase

                id <= id + 1;

            end

            // Считывание [A] в `op`
            // -------------------------------
            state_acc: 
            case (id)

                0: begin id <= 1; address <= a; end
                1: id <= 2;
                2: id <= 3;
                3: begin op[ 7:0]  <= din; if (ir[1:0] == 0) tstate <= state_exec; end
                4: begin op[15:8]  <= din; if (ir[1:0] == 1) tstate <= state_exec; end
                5: begin op[23:16] <= din; if (ir[1:0] == 2) tstate <= state_exec; end
                6: begin op[31:24] <= din; tstate <= state_exec; end
                    
            endcase

            // Исполнение инструкции
            state_exec: begin

                prefetch <= 1;
                tstate   <= state_init;
                // pc <= pcnext;

                casex (ir)

                /* LDA */ 8'b0000_xxxx: a <= op;
                // /* STA */ 8'b0000_xx_xx: begin a <= op; end
                /* SHL */ 8'b0010_xxxx: begin /* a <= из АЛУ; flags <= shl_flags */ end
                /* SHR */ 8'b0011_xxxx: begin /* a <= из АЛУ; flags <= shr_flags */ end
                /* BNE */ 8'b0100_xxxx: begin /* if (ZF == 0) pc <= op; */ end
                /* BNC */ 8'b0101_xxxx: begin /* if (CF == 0) pc <= op; */ end
                /* JMP */ 8'b0111_xxxx: begin /* pc <= op; */ end
                // .. далее идет простой АЛУ ..

                endcase

            end

        endcase

    end
    
end
else prefetch <= 1;

endmodule
