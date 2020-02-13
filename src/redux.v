module redux(

    input  wire        locked,
    input  wire        clock,
    output reg  [19:0] address,
    input  wire [ 7:0] din,
    output reg  [ 7:0] dout,
    output reg         we
);

initial begin we = 0; dout = 0; end

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
            0: begin

                ir <= din;
                id <= 0;
                op <= 0;

                // Выбор режима считывания
                casex (din)

                    /* REG */ 8'bxxxx_00_xx: begin tstate <= 2; end
                    /* IMM */ 8'bxxxx_01_xx: begin tstate <= 1; end
                    /* [A] */ 8'bxxxx_11_xx: begin tstate <= 3;  address <= a; end
                    /* PC  */ 8'bxxxx_11_xx: begin tstate <= 11; op <= pc + 2 + din[1:0]; end
                    
                endcase

            end

            // Считывание IMMEDIATE
            1: begin

                case (id)
 
                    0: op[ 7:0]  <= din;
                    1: op[15:8]  <= din;
                    2: op[23:16] <= din;
                    3: op[31:24] <= din;

                endcase

                // Выход из цикла считывания
                if (id == ir[1:0]) tstate <= 2; // @todo ----- exec

                // К следующему байту
                id <= id + 1;

            end

            // Считывание регистра [$d] в `op`
            2: begin

                case (id)

                    0: begin address   <= din; end 
                    3: begin op[ 7:0]  <= din; if (ir[1:0] == 2'b00) tstate <= 11; end // @todo
                    4: begin op[15:8]  <= din; if (ir[1:0] == 2'b01) tstate <= 11; end // @todo
                    5: begin op[23:16] <= din; if (ir[1:0] == 2'b10) tstate <= 11; end // @todo
                    6: begin op[31:24] <= din; tstate <= 11; end // @todo

                endcase

                id <= id + 1;

            end

            // Считывание [A] в `op`
            3: begin

            end

        endcase

    end
    
end
else prefetch <= 1;

endmodule
