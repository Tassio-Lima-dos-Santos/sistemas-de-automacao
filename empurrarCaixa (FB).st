FUNCTION_BLOCK empurrarCaixa
VAR_INPUT
    start   : BOOL; // Variável de entrada que em rising inicia o movimento
END_VAR

VAR_OUTPUT
    done  : BOOL; // Variável de saída que indica que o movimento foi concluído
END_VAR

VAR
	trigStart : R_TRIG;
    state : INT := 0;
END_VAR

trigStart(CLK:=start);

CASE state OF

    0: // Estado Ocioso
        IF trigStart.Q THEN
            state := 10;
			done := FALSE;
        END_IF

    10: // Move pistão para frente
        IF NOT FIO.i_SC1Mais THEN
            FIO.o_C1 := TRUE;
        ELSE
            state := 20;
        END_IF

    20: // Move pistão para trás
        IF NOT FIO.i_SC1Menos THEN
            FIO.o_C1 := FALSE;
        ELSE
            state := 30;
        END_IF

    30: // Finalizado
        done := TRUE;
		state := 0;

END_CASE
