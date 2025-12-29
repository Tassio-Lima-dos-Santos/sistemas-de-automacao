FUNCTION_BLOCK moverMetal
VAR_INPUT
    start   : BOOL;   // pulso de start
END_VAR

VAR_OUTPUT
    done : BOOL;      // TRUE quando chegou
END_VAR

VAR
    empCNC : FB_MoveTo;
	trigStart : R_TRIG;
    state : INT := 0;

END_VAR

trigStart(CLK:=start);

CASE state OF

    0: // Estado ocioso
        IF trigStart.Q THEN
            state := 10;
			done := FALSE;
        END_IF

    10: // Move até o item
        empCNC(targetX := constante.Xpart, targetY := constante.Ypart, targetZ := constante.Zpart, start := TRUE);
        IF empCNC.done THEN
            empCNC(start := FALSE);
            state := 20;
        END_IF

    20: // Pega o item
        FIO.o_Succao := TRUE;
        IF FIO.i_SPP THEN
            state := 30;
        END_IF

    30: // Move para cima
        empCNC(targetX := constante.Xpart, targetY := constante.Ypart, targetZ := constante.Zpart - 50, start := TRUE);
        IF empCNC.done THEN
            empCNC(start := FALSE);
            state := 40;
        END_IF

    40: // Move até a caixa
        empCNC(targetX := constante.XboxMetal, targetY := constante.YboxMetal, targetZ := constante.ZboxMetal, start := TRUE);
        IF empCNC.done THEN
            empCNC(start := FALSE);
            state := 50;
        END_IF

    50: // Solta a peça
        FIO.o_Succao := FALSE;
        IF NOT FIO.i_SPP THEN
            state := 60;
        END_IF

    60: // Retorna a posição de descanso 
        empCNC(targetX := constante.Xidle, targetY := constante.Yidle, targetZ := constante.Zidle, start := TRUE);
        IF empCNC.done THEN
            empCNC(start := FALSE);
            state := 70;
        END_IF

    70: // Finalizado
        done := TRUE;
		state := 0;

END_CASE
