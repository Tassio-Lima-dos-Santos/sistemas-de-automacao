PROGRAM PLC_PRG
VAR
    // Estados das máquinas
    E_Cla : INT := 0;      // Classificadora
	E_Cla_anterior : INT := 0; // Guarda o estado da máquina classificadora antes da espera
    E_Usi : INT := 0;      // Usinagem
    E_Emp : INT := 0;      // Empacotamento
    E_Sup : INT := 0;      // Supervisora

	// Codições de mudança de estado
	classificacaoConcluida : BOOL;
	
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

	// Comunicação entre máquinas
	esperaCla : BOOL := FALSE;  // Sinal que faz a máquina classificadora entrar em espera

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
	
	// Timers dos sensores
	Timer_sc  	  : TON := (PT := T#30S);
	Timer_op1 	  : TON := (PT := T#30S);
	Timer_op2     : TON := (PT := T#30S);
	Timer_op3     : TON := (PT := T#30S);
	
	// Delays
	Delay_Cla_metal : TP := (PT := T#1S); // Delay da classificação metal
	delayEstabilizarBalanca : TON := (PT := T#2S); // Delay da balança
	Delay_E_Cla_5 : TON := (PT := T#5S); // Delay para considerar classificação concluída
	Delay_E_Emp_5 : TON := (PT := T#3S); // Delay para movimentar as esteiras de plástico e metal
	
	// Triggers
	trigSC : R_TRIG;
	trigDelayMetal : F_TRIG;
	trigUsiConcluida : F_TRIG;
	trigUsiOcupada : R_TRIG;
	
	// Buffer de produto
	produtoBuffer : ST_PRODUCT;
	
	// Blocos Funcionais
	movimentoPistao : empurrarCaixa;
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
//----------------------------------LÓGICA DOS SENSORES---------------------------------------
//----------------------------------------INÍCIO----------------------------------------------

IF Maquina1 AND NOT Emergencia1 AND NOT esperaCla THEN // Se a máquina 1 estiver operando
	Timer_sc(IN:=NOT FIO.i_SC); // A entrada dos timers será o inverso do sensores
	Timer_op1(IN:=NOT FIO.i_DS2); // Logo quando os sensores detectarem algo, os timers reiniciam
ELSE // Caso contrário, os timers permanecem inativos
	Timer_sc(IN:=FALSE);
	Timer_op1(IN:=FALSE);
END_IF;

IF Maquina2 AND NOT Emergencia2 THEN // Se a máquina 2 estiver operando
	Timer_op2(IN:=NOT OP2); // Timer perma
ELSE // Caso contrário, os timers permanecem inativos
	Timer_op2(IN:=FALSE);
END_IF;

IF Maquina3 AND NOT Emergencia3 THEN // Se a máquina 3 estiver operando
	Timer_op3(IN:=NOT OP3);
ELSE // Caso contrário, os timers permanecem inativos
	Timer_op3(IN:=FALSE);
END_IF;

//------------------------------------------FINAL---------------------------------------------
//----------------------------------LÓGICA DOS SENSORES---------------------------------------
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
		
		delayEstabilizarBalanca(IN := FALSE); // Reinicia o timer de delay da balança
		global.Fila_cla(clear := TRUE); // Limpa fila de dados
		global.Fila_cla.clear := FALSE;
		
		os_cla[E_Cla] := TRUE;
	END_IF
	
    // Ações
	FIO.o_E1          := FALSE; // Esteira 1 parada
	FIO.o_E_SP        := FALSE; // Esteira 2 parada
	FIO.o_C1          := FALSE; // Pistão retraído
  
	// Transições de estado
  	IF Maquina1 THEN // Se receber o sinal Maquina1, a máquina classificadora sai do ócio
		E_Cla := 1;
	END_IF;
	
	1: // Liga Esteira
	// Ação oneshot
	IF NOT os_cla[E_Cla] THEN
		os_cla := os_reset;
		
		os_cla[E_Cla] := TRUE;
	END_IF
	
	// Ações
	FIO.o_E1    := TRUE; // Deixa a esteira 1 ligada
	FIO.o_E_SP  := TRUE; // Deixa a esteira 2 ligada
  
	// Transições de estado
    IF FIO.i_DS2 THEN // Se o sensor óptico 1 detectar algo, vai para o estado de estabilizar o peso
		E_Cla := 2;
	END_IF;
	
	2: // Espera estabilizar peso
	// Ação oneshot
	IF NOT os_cla[E_Cla] THEN
		os_cla := os_reset;
		
		
		
		os_cla[E_Cla] := TRUE;
	END_IF
	
  	// Ações
	delayEstabilizarBalanca(IN := TRUE); // Delay para estabilizar a balança
	FIO.o_E1         := FALSE; // Para a esteira 1
	FIO.o_E_SP       := FALSE; // Para a esteira 2

	// Transições de estado
    IF delayEstabilizarBalanca.Q THEN // Se o timer 1 der sinal, passa pro próximo estado
		E_Cla := 3;
		delayEstabilizarBalanca(IN := FALSE);
	END_IF;
	
	3: // Classificação Caixa ou não caixa
	// Ação oneshot
	IF NOT os_cla[E_Cla] THEN
		os_cla := os_reset;
		
		caixa := (FIO.i_SP < 300);
		
		os_cla[E_Cla] := TRUE;
	END_IF
	
  	// Ações

	// Transições de estado
    IF caixa THEN // Se for uma caixa passa para o estado de caixa detectada
		E_Cla := 4;
	ELSE // Se não for, passa para o estado de caixa não detectada
		E_Cla := 5;
	END_IF;

	4: // Caixa detectada
	// Ação oneshot
	IF NOT os_cla[E_Cla] THEN
		os_cla := os_reset;
		
		global.Fila_cla(pop := TRUE);
		global.Fila_cla.pop := FALSE;
		
		os_cla[E_Cla] := TRUE;
	END_IF
	
  	// Ações
	movimentoPistao(start:=TRUE);

	// Transições de estado
    IF movimentoPistao.done THEN
		E_Cla := 1;
		movimentoPistao(start:=FALSE);
	END_IF;

	5: // Caixa não detectada
	// Ação oneshot
	IF NOT os_cla[E_Cla] THEN
		os_cla := os_reset;
		
		pushFilaUsi(); // Passa o item que está saindo da fila de classificação para a fila de usinagem
		contador_classificacao := contador_classificacao + 1; // Aumenta a contagem dos itens que passaram na classificação
		
		os_cla[E_Cla] := TRUE;
	END_IF
	
  	// Ações
	FIO.o_E_SP := TRUE; // Liga a esteira da balança

	// Transições de estado
    IF NOT FIO.i_DS2 THEN // Se não detectar mais com o sensor óptico, volta ao início
		E_Cla := 1;
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
	delayEstabilizarBalanca(IN := FALSE);
	global.Fila_cla.clear    :=  TRUE;
  
	// Transições de estado
  
	7: // Espera
	// Ação oneshot
	IF NOT os_cla[E_Cla] THEN
		os_cla := os_reset;
		
		
		
		os_cla[E_Cla] := TRUE;
	END_IF
	
  	// Ações
	FIO.o_E1          := FALSE;
	FIO.o_E_SP        := FALSE;
	delayEstabilizarBalanca(IN := FALSE);
  
	// Transições de estado
	IF NOT esperaCla THEN
		E_Cla := E_Cla_anterior;
	END_IF;
	
	ELSE // Caso a máquina não esteja em nenhum estado válido, ela retorna ao estado ocioso 
		E_Cla := 0;
	
END_CASE;

// Transições de estado universais
IF Emergencia1 THEN
	E_Cla := 6;
	
ELSIF NOT(Maquina1) THEN
	E_Cla := 0;

ELSIF esperaCla THEN
	E_Cla := 7;

END_IF;

// Ações Stateless

// Se der um rising no sensor capacitivo, ele registra na fila
trigSC(CLK := FIO.i_SC);
IF trigSC.Q THEN
	registrarItem();
END_IF;

//------------------------------------------FINAL---------------------------------------------
//----------------------------------MÁQUINA CLASSIFICADORA------------------------------------



//-----------------------------------MÁQUINA USINAGEM-----------------------------------------
//----------------------------------------INÍCIO----------------------------------------------

CASE E_Usi OF
	0: // Estado ocioso 
	// Ação oneshot
	IF NOT os_usi[E_Usi] THEN
		os_usi := os_reset;
		
		global.Fila_usi(clear := TRUE); // Limpa fila
		global.Fila_usi.clear := FALSE;
		
		os_usi[E_Usi] := TRUE;
	END_IF
	
  	// Ações
	FIO.o_E2     := FALSE; // Esteira 2 desligada
	FIO.o_RB1_Reset := TRUE; // Reseta o robô
	FIO.o_RB1_Stop := FALSE;
  
	// Transições de estado
    IF Maquina2 THEN // Se a máquina supervisora mandar o sinal de ligar, a máquina de usinagem sai do ócio
		E_Usi := 1;
		FIO.o_RB1_Reset := FALSE;
	END_IF;
	
	1: // Liga Esteira
	// Ação oneshot
	IF NOT os_usi[E_Usi] THEN
		os_usi := os_reset;
		
		
		
		os_usi[E_Usi] := TRUE;
	END_IF
	
  	// Ações
	FIO.o_E2 := TRUE; // Liga a esteira
  
	// Transições de estado
    IF OP2 THEN // Se o sensor optíco 2 detectar a peça, passa para o próximo estado
		E_Usi := 2;
	END_IF;
	
	2: // Usinagem
  	// Ação oneshot
	IF NOT os_usi[E_Usi] THEN
		os_usi := os_reset;
		
		
		
		os_usi[E_Usi] := TRUE;
	END_IF
	
  	// Ações
	// Se o item for metal, ele recebe o design fundo, se for plástico recebe o design de lids
	FIO.o_MachiningCenterProduceLids := NOT(global.Fila_usi.itemOut.metal);
	FIO.o_RB1_Start := TRUE; // Inicia 
  
	// Transições de estado
	trigUsiConcluida(CLK:=FIO.i_MachiningCenterIsBusy);
  	IF trigUsiConcluida.Q THEN // Se o movimento 1 do braço robótico for concluído, passa pro próximo estado
		E_Usi := 1; // Volta pro estado 1
		contador_usinagem := contador_usinagem + 1; // Aumenta em um o números de coisas usinadas
		pushFilaEmp();
	END_IF;
	
  	3: // Estado Emergência
  	// Ação oneshot
	IF NOT os_usi[E_Usi] THEN
		os_usi := os_reset;
		
		global.Fila_usi(clear := TRUE); // Limpa a fila
		global.Fila_usi.clear := FALSE;
		
		os_usi[E_Usi] := TRUE;
	END_IF
	
  	// Ações
	FIO.o_E2     := FALSE; // Desliga a esteira
	FIO.o_RB1_Stop := TRUE; // Para o robô
  
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

// Ações Stateless

// Se a máquina de usinagem estiver ocupada e tiver item chegando ela faz as esteiras pararem
trigUsiOcupada(CLK:=FIO.i_MachiningCenterIsBusy AND OP2);
IF (FIO.i_MachiningCenterIsBusy AND OP2) THEN
	IF trigUsiOcupada.Q THEN
		E_Cla_anterior := E_Cla;
	END_IF;
	FIO.o_E2 := FALSE;
	esperaCla := TRUE;
END_IF;

//------------------------------------------FINAL---------------------------------------------
//------------------------------------MÁQUINA USINAGEM----------------------------------------



//---------------------------------MÁQUINA EMPACOTAMENTO--------------------------------------
//----------------------------------------INÍCIO----------------------------------------------

CASE E_Emp OF
	0: // Estado ocioso
  	// Ação oneshot
	IF NOT os_emp[E_Emp] THEN
		os_emp := os_reset;
		
		
		
		os_emp[E_Emp] := TRUE;
	END_IF 
  	// Ações
	FIO.o_E3          := FALSE;
	FIO.o_EPLASTIC1 := FALSE;
	FIO.o_EPLASTIC2 := FALSE;
	FIO.o_EPLASTIC3 := FALSE;
	FIO.o_EMETAL1 := FALSE;
	FIO.o_EMETAL2 := FALSE;
	FIO.o_EMETAL3 := FALSE;
	Delay_E_Emp_5(IN := FALSE);
	global.Fila_emp.clear     := TRUE;
  
	// Transições de estado
  	IF Maquina3 THEN // Se a máquina supervisora mandar o sinal de ligar, a máquina de empacotamento sai do ócio
		E_Emp := 1;
		global.Fila_emp.clear := FALSE;
	END_IF;
	
	1: // Posicionar esteira de plástico
  	// Ação oneshot
	IF NOT os_emp[E_Emp] THEN
		os_emp := os_reset;
		
		
		
		os_emp[E_Emp] := TRUE;
	END_IF 
	// Ações
	posicionarEstPlas(start:=TRUE);
  
	// Transições de estado
	IF posicionarEstPlas.done THEN
		E_Emp := 2;
	END_IF;
	
	2: // Posicionar esteira de metal
  	// Ação oneshot
	IF NOT os_emp[E_Emp] THEN
		os_emp := os_reset;
		
		
		
		os_emp[E_Emp] := TRUE;
	END_IF 
  	// Ações
	posicionarEstMetal(start:=TRUE);

	// Transições de estado
	IF posicionarEstMetal.done THEN
		E_Emp := 3;
	END_IF;
	
	3: // Ligar esteira
  	// Ação oneshot
	IF NOT os_emp[E_Emp] THEN
		os_emp := os_reset;
		
		
		
		os_emp[E_Emp] := TRUE;
	END_IF 
  	// Ações
	
	// Transições de estado
	
	4: // Mover plástico
  	// Ação oneshot
	IF NOT os_emp[E_Emp] THEN
		os_emp := os_reset;
		
		
		
		os_emp[E_Emp] := TRUE;
	END_IF 
  	// Ações
	
	// Transições de estado
	
  	5: // Mover metal
  	// Ação oneshot
	IF NOT os_emp[E_Emp] THEN
		os_emp := os_reset;
		
		
		
		os_emp[E_Emp] := TRUE;
	END_IF 
	// Ações
  
	// Transições de estado

  	6: // Mover esteira plástico
  	// Ação oneshot
	IF NOT os_emp[E_Emp] THEN
		os_emp := os_reset;
		
		
		
		os_emp[E_Emp] := TRUE;
	END_IF 
  	// Ações
  
	// Transições de estado
	
  	7: // Mover esteira plástico
  	// Ação oneshot
	IF NOT os_emp[E_Emp] THEN
		os_emp := os_reset;
		
		
		
		os_emp[E_Emp] := TRUE;
	END_IF 
  	// Ações
  
	// Transições de estado
	
  	8: // Estado Emergência
  	// Ação oneshot
	IF NOT os_emp[E_Emp] THEN
		os_emp := os_reset;
		
		
		
		os_emp[E_Emp] := TRUE;
	END_IF 
  	// Ações
	FIO.o_E3          := FALSE;
	FIO.o_EPLASTIC1 := FALSE;
	FIO.o_EPLASTIC2 := FALSE;
	FIO.o_EPLASTIC3 := FALSE;
	FIO.o_EMETAL1 := FALSE;
	FIO.o_EMETAL2 := FALSE;
	FIO.o_EMETAL3 := FALSE;
	Delay_E_Emp_5(IN := FALSE);
	global.Fila_emp.clear     := TRUE;
  
	// Transições de estado
  
	
	ELSE // Caso a máquina não esteja em nenhum estado válido, ela retorna ao estado ocioso 
		E_Emp := 0;
	
END_CASE;

// Transições de estado universais
IF Emergencia3 THEN
	E_Emp := 8;
	
ELSIF NOT(Maquina3) THEN
	E_Emp := 0;

END_IF;

// Ações stateless
IF OP3 THEN
	FIO.o_E3 := FALSE; // Desliga a esteira caso algo item seja detectado
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
