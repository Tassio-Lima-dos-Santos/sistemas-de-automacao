PROGRAM PLC_PRG
VAR
    // Estados das máquinas
    E_Cla : INT := 0;      // Classificadora
    E_Usi : INT := 0;      // Usinagem
    E_Emp : INT := 0;      // Empacotamento
    E_Sup : INT := 0;      // Supervisora
	
	// Oneshot das máquinas
	os_cla : ARRAY[0..50] OF BOOL; // Classificação
	os_usi : ARRAY[0..50] OF BOOL; // Usinagem
	os_emp : ARRAY[0..50] OF BOOL; // Empacotamento
	os_sup : ARRAY[0..50] OF BOOL; // Supervisora
	
	os_reset : ARRAY[0..50] OF BOOL; // Array de reset dos oneshot


    // Entradas gerais
    START : BOOL;
    STOP  : BOOL;
	EMER  : BOOL;

    // Sinais de emergência
    Emergencia1 : BOOL := FALSE;
    Emergencia2 : BOOL := FALSE;
    Emergencia3 : BOOL := FALSE;
    

    // Comandos da máquina supervisora
    Maquina1 : BOOL := FALSE;   // Liga classificadora
    Maquina2 : BOOL := FALSE;   // Liga usinagem
    Maquina3 : BOOL := FALSE;   // Liga empacotamento

    // Sensores
    SC  : BOOL := FALSE;    // Sensor capacitivo
	SI  : BOOL := FALSE;    // Sensor indutivo
    OP1 : BOOL := FALSE;    // Sensor óptico 1
    OP2 : BOOL := FALSE;    // Sensor óptico 2
    OP3 : BOOL := FALSE;    // Sensor óptico 3

    // Contadores
    contador_classificacao : INT := 0;
    contador_usinagem      : INT := 0;

    // Contadores da empacotadora
    plastico_counter : INT := 0;
    metal_counter    : INT := 0;
    itemPorCaixa     : INT := 3;   // EXEMPLO — ajuste conforme sua lógica

    // Variáveis lógicas da empacotadora
    metal    : BOOL;
	caixa    : BOOL;

    // Variáveis da usinagem
    Mov1_concluido     : BOOL := FALSE;   // Movimento 1 concluído
    Mov2_concluido     : BOOL := FALSE;   // Movimento 2 concluído
    Usinagem_concluido : BOOL := FALSE;
	
	// Atuadores
	Esteira1 	  : BOOL := FALSE;
	Esteira2 	  : BOOL := FALSE;
	Esteira3 	  : BOOL := FALSE;
	Esteira4      : BOOL := FALSE;
	Esteira_plas  : BOOL := FALSE;
	Esteira_metal : BOOL := FALSE;
	Pistao1  	  : BOOL := FALSE;
	
	// Timers
	Timer_sc  	  : TON := (PT := T#30S);
	Timer_op1 	  : TON := (PT := T#30S);
	Timer_op2     : TON := (PT := T#30S);
	Timer_op3     : TON := (PT := T#30S);
	Timer_balanca : TON := (PT := T#2S); 
	Timer_esteira : TON := (PT := T#3S);
	
	// Delays
	Delay_E_Cla_2 : TON := (PT := T#1S);
	
	// Filas de itens
	Fila_cla : FB_PRODUCT_QUEUE;
	Fila_usi : FB_PRODUCT_QUEUE;
	Fila_emp : FB_PRODUCT_QUEUE;
	
	// Buffer de produto
	produtoBuffer : ST_PRODUCT;
	
	// Blocos Funcionais
	empCNC : FB_MoveTo;
	
END_VAR

//--------------------------------------------------------------------------------------------
//-------------------------------TRATAMENTO DE VARIÁVEIS--------------------------------------
//----------------------------------------INÍCIO----------------------------------------------

// Variáveis de lógica inversa
EMER := NOT(FIO.i_Emergencia);
STOP := NOT(FIO.i_Stop);
OP2 := NOT(FIO.i_RS1);
OP3 := NOT(FIO.i_RS2);

// Variáveis com valores padrão
FIO.o_LedG := FALSE;
FIO.o_LedR := FALSE;
FIO.o_LedY := FALSE;
FIO.o_LedSPMais := FIO.i_SPMais;
FIO.o_LedSPMenos := FIO.i_SPMenos;
FIO.o_LedStart := FIO.i_Start;
FIO.o_LedStop := NOT(FIO.i_Stop);


//------------------------------------------FINAL---------------------------------------------
//-------------------------------TRATAMENTO DE VARIÁVEIS--------------------------------------
//--------------------------------------------------------------------------------------------

//--------------------------------------------------------------------------------------------
//----------------------------------MÁQUINAS DE ESTADO----------------------------------------
//----------------------------------------INÍCIO----------------------------------------------



//----------------------------------MÁQUINA CLASSIFICADORA------------------------------------
//----------------------------------------INÍCIO----------------------------------------------

CASE E_Cla OF
	0: // Estado ocioso 
	// Ação oneshot
	IF NOT os_cla[E_Cla] THEN
		os_cla := os_reset;
		
		
		
		os_cla[E_Cla] := TRUE;
	END_IF
	
    // Ações
	FIO.o_E1          := FALSE;
	FIO.o_E_SP          := FALSE;
	FIO.o_C1           := FALSE;
	Timer_sc     (IN := FALSE);
	Timer_op1    (IN := FALSE);
	Timer_balanca(IN := FALSE);
	Fila_cla.clear    :=  TRUE;
  
	// Transições de estado
  	IF Maquina1 THEN // Se receber o sinal Maquina1, a máquina classificadora sai do ócio
		E_Cla := 1;
		Fila_cla.clear := FALSE;
		os_cla[E_Cla] := FALSE;
	END_IF;
	
	1: // Liga Esteira
	// Ação oneshot
	IF NOT os_cla[E_Cla] THEN
		os_cla := os_reset;
		
		
		
		os_cla[E_Cla] := TRUE;
	END_IF
	
	// Ações
	FIO.o_E1    := TRUE;
	FIO.o_E_SP  := TRUE;
	Timer_sc(IN := TRUE);
  
	// Transições de estado
    IF FIO.i_SC THEN // Se o sensor capacitivo detectar algo, muda para o estado de classificação de metal
		E_Cla := 2;
	END_IF;
	
	2: // Classificação Metal ou não Metal
	// Ação oneshot
	IF NOT os_cla[E_Cla] THEN
		os_cla := os_reset;
		
		FIO.o_E1 := FALSE;
// 		produtoBuffer.processed := FALSE;
// 		produtoBuffer.metal := FIO.i_SI;
// 		Fila_cla.itemIn := produtoBuffer;
// 		Fila_cla.push   := TRUE;
		
		os_cla[E_Cla] := TRUE;
	END_IF
	
  	// Ações
	Timer_sc(IN := FALSE);
	Delay_E_Cla_2(IN := TRUE);
	// Fila_cla.push := FALSE;
  
	// Transições de estado
    IF Delay_E_Cla_2.Q THEN // Se tanto o sensor capacitivo não detectar nada, quanto o sensor optíco 1 detectar, passa pro próximo estado
		E_Cla := 3;
		Delay_E_Cla_2(IN := FALSE);
	END_IF;
	
	3: // Item segue para a balança
	// Ação oneshot
	IF NOT os_cla[E_Cla] THEN
		os_cla := os_reset;
		
		
		
		os_cla[E_Cla] := TRUE;
	END_IF
	
  	// Ações
	Timer_op1(IN := TRUE);
	FIO.o_E1         := TRUE;
	FIO.o_E_SP       := TRUE;
  
	// Transições de estado
    IF FIO.i_DS2 THEN // Se o timer 1 der sinal, passa pro próximo estado
		E_Cla := 4;
		Timer_op1(IN := FALSE);
	END_IF;
	
	4: // Espera estabilizar peso
	// Ação oneshot
	IF NOT os_cla[E_Cla] THEN
		os_cla := os_reset;
		
		
		
		os_cla[E_Cla] := TRUE;
	END_IF
	
  	// Ações
	Timer_op1.IN     := FALSE;
	FIO.o_E1         := FALSE;
	FIO.o_E_SP         := FALSE;
	Timer_balanca(IN := TRUE);
  
	// Transições de estado
    IF Timer_balanca.Q THEN // Se o timer 1 der sinal, passa pro próximo estado
		E_Cla := 5;
		Timer_balanca(IN := FALSE);
	END_IF;
	
	5: // Classificação Caixa ou não caixa
	// Ação oneshot
	IF NOT os_cla[E_Cla] THEN
		os_cla := os_reset;
		
		caixa := (FIO.i_SP > 3);
		// Se o peso for menor que 3 é uma caixa
		IF caixa THEN
			FIO.o_C1 := TRUE;
		ELSE
			FIO.o_C1 := FALSE;
			contador_classificacao := contador_classificacao + 1;
			FIO.o_E_SP := TRUE;
// 			IF (Fila_cla.itemOut <> 0) THEN
// 				Fila_usi.itemIn := Fila_cla.itemOut^;
// 				Fila_usi.push := TRUE;
// 			END_IF
		END_IF
// 		Fila_cla.pop := TRUE;
		
		os_cla[E_Cla] := TRUE;
	END_IF
	
  	// Ações
	Fila_usi.push := FALSE;
  
	// Transições de estado
    IF (NOT(FIO.i_DS2)) THEN // Se o sensor optíco 1 não detectar nada, volta ao início da operação
		E_Cla := 1;
		FIO.o_C1 := FALSE;
	END_IF;
	
  	6: // Estado Emergência
	// Ação oneshot
	IF NOT os_cla[E_Cla] THEN
		os_cla := os_reset;
		
		
		
		os_cla[E_Cla] := TRUE;
	END_IF
	
  	// Ações
	FIO.o_E1          := FALSE;
	FIO.o_E_SP          := FALSE;
	FIO.o_C1           := FALSE;
	Timer_sc     (IN := FALSE);
	Timer_op1    (IN := FALSE);
	Timer_balanca(IN := FALSE);
	Fila_cla.clear    :=  TRUE;
  
	// Transições de estado
  
	
	ELSE // Caso a máquina não esteja em nenhum estado válido, ela retorna ao estado ocioso 
		E_Cla := 0;
	
END_CASE;

// Transições de estado universais
IF Emergencia1 THEN
	E_Cla := 6;
	
ELSIF NOT(Maquina1) THEN
	E_Cla := 0;

END_IF;
//------------------------------------------FINAL---------------------------------------------
//----------------------------------MÁQUINA CLASSIFICADORA------------------------------------



//-----------------------------------MÁQUINA USINAGEM-----------------------------------------
//----------------------------------------INÍCIO----------------------------------------------

CASE E_Usi OF
	0: // Estado ocioso 
  	// Ações
	FIO.o_E2     := FALSE;
	Timer_op2(IN := FALSE);
	FIO.o_RB1_Stop := TRUE;
	Fila_usi.clear := TRUE;
  
	// Transições de estado
    IF Maquina2 THEN // Se a máquina supervisora mandar o sinal de ligar, a máquina de usinagem sai do ócio
		E_Usi := 1;
		FIO.o_RB1_Stop := FALSE;
		Fila_usi.clear := FALSE;
	END_IF;
	
	1: // Liga Esteira
	// Ações
	FIO.o_E2     := TRUE;
	Timer_op2(IN := TRUE);
  
	// Transições de estado
	IF NOT(Maquina2) THEN // Se a máquina supervisora mandar o sinal de desligar, a máquina de usinagem volta pro ócio
		E_Usi := 0;
    ELSIF OP2 THEN // Se o sensor optíco 2 detectar a peça, passa para o próximo estado
		E_Usi := 2;
	END_IF;
	
	2: // Usinagem
  	// Ações
	Timer_op2(IN := FALSE);
	FIO.o_MachiningCenterProduceLids := NOT(Fila_usi.itemOut^.metal);
	FIO.o_RB1_Start := TRUE;
  
	// Transições de estado
  	IF NOT(FIO.i_MachiningCenterIsBusy) THEN // Se o movimento 1 do braço robótico for concluído, passa pro próximo estado
		E_Usi := 1;
		contador_usinagem := contador_usinagem + 1;
		IF (Fila_usi.itemOut <> 0) THEN
			Fila_emp.itemIn := Fila_usi.itemOut^;
			Fila_emp.push := TRUE;
			Fila_cla.pop := TRUE;
		END_IF
	END_IF;
	
  	3: // Estado Emergência
  	// Ações
	FIO.o_E2     := FALSE;
	Timer_op2(IN := FALSE);
	FIO.o_RB1_Stop := TRUE;
	Fila_usi.clear := TRUE;
  
	// Transições de estado
  
	
	ELSE // Caso a máquina não esteja em nenhum estado válido, ela retorna ao estado ocioso 
		E_Usi := 0;
	
END_CASE;

// Transições de estado universais
IF Emergencia2 THEN
	E_Usi := 3;
	
ELSIF NOT(Maquina2) THEN
	E_Usi := 0;

END_IF;

//------------------------------------------FINAL---------------------------------------------
//------------------------------------MÁQUINA USINAGEM----------------------------------------



//---------------------------------MÁQUINA EMPACOTAMENTO--------------------------------------
//----------------------------------------INÍCIO----------------------------------------------

CASE E_Emp OF
	0: // Estado ocioso 
  	// Ações
	FIO.o_E3          := FALSE;
	Esteira_plas      := FALSE;
	Esteira_metal     := FALSE;
	Timer_op3(IN     := FALSE);
	Timer_esteira(IN := FALSE);
	Fila_emp.clear     := TRUE;
  
	// Transições de estado
  	IF Maquina3 THEN // Se a máquina supervisora mandar o sinal de ligar, a máquina de empacotamento sai do ócio
		E_Emp := 1;
		Fila_emp.clear := FALSE;
	END_IF;
	
	1: // Liga Esteira
	// Ações
	FIO.o_E3       := TRUE;
	Esteira_plas  := FALSE;
	Esteira_metal := FALSE;
	Timer_op3(IN := TRUE);
	// Posicionar na esteira de plástico
	empCNC(targetX := 0, targetY := 5, targetZ := 5, start := TRUE);
  
	// Transições de estado
	IF NOT(Maquina3) THEN // Se a máquina supervisora mandar o sinal de desligar, a máquina de empacotamento volta pro ócio
		E_Emp := 0;
  	ELSIF OP3 THEN // Se o sensor optíco 3 detectar a peça, passa para o próximo estado
		E_Emp := 2;
	END_IF;
	
	2: // Pegar item
  	// Ações
    FIO.o_E3      := FALSE;
	Timer_op3(IN := FALSE);
	// Pegar peça
	empCNC(targetX := 0, targetY := 5, targetZ := 10, start := TRUE);
  
	// Transições de estado
	IF empCNC.done THEN
		FIO.o_Succao := TRUE;
		IF (Fila_emp.itemOut <> 0) THEN
  			IF Fila_emp.itemOut^.metal THEN // Se o item pego for metal, segue pro estado 3
				E_Emp := 3;
			ELSE // Se não for, segue pro estado 4
				E_Emp := 4;
			END_IF;
		END_IF;
	END_IF;
	
	3: // Mover plástico
  	// Ações
	// Posicionar na esteira de plástico
	empCNC(targetX := 3, targetY := 5, targetZ := 10, start := TRUE);
  	Fila_emp.pop := TRUE;
	
	// Transições de estado
	IF empCNC.done THEN
		FIO.o_Succao := FALSE;
  		IF (plastico_counter < itemPorCaixa) THEN // Se a máquina supervisora mandar o sinal de ligar, a máquina de empacotamento sai do ócio
			plastico_counter := plastico_counter + 1;
			E_Emp := 1;
			Fila_emp.pop := FALSE;
		ELSE
			E_Emp := 5;
			Fila_emp.pop := FALSE;
		END_IF;
	END_IF;
	
	4: // Mover metal
  	// Ações
	// Posicionar na esteira de metal
	empCNC(targetX := 7, targetY := 5, targetZ := 10, start := TRUE);
  	Fila_emp.pop := TRUE;
	
	// Transições de estado
	IF empCNC.done THEN
		FIO.o_Succao := FALSE;
  		IF (metal_counter < itemPorCaixa) THEN // Se a máquina supervisora mandar o sinal de ligar, a máquina de empacotamento sai do ócio
			metal_counter := metal_counter + 1;
			E_Emp := 1;
		ELSE
			E_Emp := 6;
		END_IF;
	END_IF;
	
  	5: // Mover esteira plástico
  	// Ações
	Esteira_plas := TRUE;
	Timer_esteira(IN := TRUE);
  
	// Transições de estado
	IF Timer_esteira.Q THEN
  		E_Emp := 1;
	END_IF;

  	6: // Mover esteira metal
  	// Ações
	Esteira_metal := TRUE;
	Timer_esteira(IN := TRUE);
  
	// Transições de estado
  	IF Timer_esteira.Q THEN
  		E_Emp := 1;
	END_IF;
	
  	7: // Estado Emergência
  	// Ações
	FIO.o_E3          := FALSE;
	Esteira_plas      := FALSE;
	Esteira_metal     := FALSE;
	Timer_op3(IN     := FALSE);
	Timer_esteira(IN := FALSE);
	Fila_emp.clear     := TRUE;
  
	// Transições de estado
  
	
	ELSE // Caso a máquina não esteja em nenhum estado válido, ela retorna ao estado ocioso 
		E_Emp := 0;
	
END_CASE;

// Transições de estado universais
IF Emergencia3 THEN
	E_Emp := 7;
	
ELSIF NOT(Maquina3) THEN
	E_Emp := 0;

END_IF;

//------------------------------------------FINAL---------------------------------------------
//---------------------------------MÁQUINA EMPACOTAMENTO--------------------------------------



//----------------------------------MÁQUINA SUPERVISORA---------------------------------------
//----------------------------------------INÍCIO----------------------------------------------

// Deixar leds desligados por padrão
FIO.o_LedG := FALSE;
FIO.o_LedR := FALSE;
FIO.o_LedY := FALSE;

CASE E_Sup OF
	0: // Estado ocioso 
  	// Ações
	Maquina1    := FALSE;
	Maquina2    := FALSE;
	Maquina3    := FALSE;
	Emergencia1 := FALSE;
	Emergencia2 := FALSE;
	Emergencia3 := FALSE;
	FIO.o_LedY  := TRUE;
  
	// Transições de estado
  	IF FIO.i_Start THEN // Se o botão FIO.i_Start for pressionado, a máquina supervisora sai do ócio
		E_Sup := 1;
	END_IF;
	
	1: // Ligar máquina classificação
	// Ações
	FIO.o_LedG := TRUE;
	Maquina1 := TRUE;

  
	// Transições de estado
  	IF (contador_classificacao > 0) THEN // Se o primeiro item passar por todas os estados da máquina classificadora, passa pro próximo estado
		E_Sup := 2;
	END_IF;
	
	2: // Ligar máquina usinagem
  	// Ações
	Maquina2 := TRUE;
  
	// Transições de estado
  	IF (contador_usinagem > 0) THEN // Se o primeiro item passar por todas os estados da máquina usinadora, passa pro próximo estado
		E_Sup := 3;
	END_IF;
	
	3: // Ligar máquina empacotamento
  	// Ações
	Maquina3 := TRUE;
  
	// Transições de estado
  
	
  	4: // Estado Emergência
  	// Ações
	Maquina1   := FALSE;
	Maquina2   := FALSE;
	Maquina3   := FALSE;
	Emergencia1 := TRUE;
	Emergencia2 := TRUE;
	Emergencia3 := TRUE;
	FIO.o_LedR := TRUE;
  
	// Transições de estado
	
	ELSE // Caso a máquina não esteja em nenhum estado válido, ela retorna ao estado ocioso 
		E_Sup := 0;
	
END_CASE;

// Transições de estado universais
IF (EMER OR Timer_sc.Q OR Timer_op1.Q OR Timer_op2.Q OR Timer_op3.Q) THEN
	E_Sup := 4;
	
ELSIF STOP THEN
	E_Sup := 0;

END_IF;

//------------------------------------------FINAL---------------------------------------------
//----------------------------------MÁQUINA SUPERVISORA---------------------------------------

//------------------------------------------FINAL---------------------------------------------
//-----------------------------------MÁQUINAS DE ESTADOS--------------------------------------
//--------------------------------------------------------------------------------------------
