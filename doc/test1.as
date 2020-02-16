
        ; --------------
        ; Разбор опкода
        ; --------------
        
        w.lda [cs]      ; загрузка 16 битного cs в А
        b.shl #4
        w.add [ip]      ; добавить 16 битное ip к 32-х битному A
        d.add #program  ; где находится программа
        b.lda [a]       ; прочесть байт
        w.shl #2
        d.add #optable
        d.jmp [a]       ; перейти по адресу опкода
; ---
        d.jmp pc        ; Вызов процедуры pc будет записан в lr (255-й регистр)
        d.jmp [lr]      ; Возврат из процедуры     

; ----------------------------------------------------------------------

        b.lda #0
        b.sta [r0]
REP:    d.str [r0]
        b.add #1
        w.cmp #$1000
        w.bne REP

; Тест переполнения, вычисление
; (a[7] ^ b[7] ^ 1) & (a[7] ^ r[7]) -- если

        ; OVERFLOW
        b.lda [o1]
        b.xor [o2]
        b.xor #$80
        b.sta [t1]
        b.lda [o1]
        b.xor [r]
        b.and [t1]
        b.and #$80
        b.bne @f            ; Относительный (если imm)
        w.lda [flags]       ; Установка флага
        w.ora #$1000
        w.sta [flags]
@@:     ; ... cont test

        ; ZERO
        b.lda [o1]      
        b.and #$FF
        b.bne _nonzero
        w.lda [flags]
        w.ora #ZERO_FLAG
        w.sta [flags]

        ; SIGN
        b.lda [o1]
        b.and #$80
        b.bne _nosign
        b.jmp _sign
_nosign:
        .. setflag

; ----------------------------------------------------------------------
        ; r0/r1 -> r0/r2

        ; r3 | r0

        b.lda #0
        d.sta [r3]
        d.sta [r2]

        d.lda [r0]
        d.shl #1
        d.sta [r0]
        b.bnc @next
        

@next:
        


        
        
