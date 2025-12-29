FUNCTION_BLOCK posicionarEsteiraPlastico
VAR_INPUT
    start   : BOOL;  // pulso de start
END_VAR

VAR_OUTPUT
    done : BOOL;      // TRUE quando chegou
END_VAR

VAR
	trigStart : R_TRIG;
	trigSensor : R_TRIG;
    state : INT := 0;

END_VAR

trigStart(CLK:=start);

CASE state OF

    0: // Estado ocioso
        IF trigStart.Q THEN
            state := 10;
			done := FALSE;
        END_IF

    10: // Liga as esteiras
        FIO.o_EPLASTIC1 := TRUE;
        FIO.o_EPLASTIC2 := TRUE;
        FIO.o_EPLASTIC3 := TRUE;
        state := 20;


    20: // Aguarda pelo trigger do sensor
        trigSensor(CLK:=FIO.i_DS3);
        IF trigSensor.Q THEN
            state := 30;
        END_IF

    30: // Desliga as esteiras
        FIO.o_EPLASTIC1 := FALSE;
        FIO.o_EPLASTIC2 := FALSE;
        FIO.o_EPLASTIC3 := FALSE;
        state := 40;

    40: // Finalizado
        done := TRUE;
		state := 0;

END_CASE
