FUNCTION_BLOCK FB_MoveTo
VAR_INPUT
    targetX : INT;    // Coordenadas da posição desejada
    targetY : INT;
    targetZ : INT;
    start   : BOOL;   // pulso de start
END_VAR

VAR_OUTPUT
    done : BOOL;      // TRUE quando chegou
END_VAR

VAR
	trigStart : R_TRIG;
    state : INT := 0;
	timer : TON;
END_VAR

trigStart(CLK:=start);

CASE state OF

    0: // Estado ocioso
        IF trigStart.Q THEN
            state := 10;
			done := FALSE;
        END_IF

    10: // Move no eixo X
		FIO.o_X := targetX;
        IF (FIO.i_XPOS < targetX - 5) OR (FIO.i_XPOS > targetX + 5) THEN // Deixa um intervalo de +/- 5 para o sensor de posição
            FIO.o_X := targetX;
        ELSE
            state := 20;
        END_IF

    20: // Move no eixo Y
	FIO.o_Y := targetY;
        IF (FIO.i_YPOS < targetY - 5) OR (FIO.i_YPOS > targetY + 5) THEN
            FIO.o_Y := targetY;
        ELSE
            state := 30;
        END_IF

    30: // Move no eixo Z
	FIO.o_Z := targetZ;
        IF (FIO.i_ZPOS < targetZ - 5) OR (FIO.i_ZPOS > targetZ + 5) THEN
            FIO.o_Z := targetZ;
        ELSE
            state := 40;
        END_IF

    40: // Finalizado
	Timer(IN:=TRUE, PT:=T#0.5S);
	IF Timer.Q THEN
		Timer.IN := FALSE;
        done := TRUE;
		state := 0;
	END_IF;

END_CASE
