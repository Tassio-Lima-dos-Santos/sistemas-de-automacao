PROGRAM PLC_PRG
VAR
    // Estados das máquinas
    E_Cla : INT := 0;      		// Classificadora
	E_Cla_anterior : INT := 0; 	// Guarda o estado da máquina classificadora antes da espera
    E_Usi : INT := 0;      		// Usinagem
    E_Emp : INT := 0;      		// Empacotamento
    E_Sup : INT := 0;      		// Supervisora
	
	// Oneshot das máquinas
	os_cla : ARRAY[0..10] OF BOOL; // Classificação
	os_usi : ARRAY[0..10] OF BOOL; // Usinagem
	os_emp : ARRAY[0..10] OF BOOL; // Empacotamento
	os_sup : ARRAY[0..10] OF BOOL; // Supervisora
	
	os_reset : ARRAY[0..10] OF BOOL; // Array de reset dos oneshot

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
    contador_classificacao : INT := 0; // Itens que passaram pela classificação
    contador_usinagem      : INT := 0; // Itens que passaram pela usinagem
    contador_empacotamento : INT := 0; // Itens que passaram pelo empacotamento

    // Contadores da empacotadora
    plastico_counter : INT := 0; // Quantidade de itens de plástico na caixa de plástico atual
    metal_counter    : INT := 0; // Quantidade de itens de metal na caixa de metal atual
    itemPorCaixa     : INT := 3; // Quantidade de itens que devem ser colocados em uma caixa no empacotamento

    // Buffers de variáveis lógicas
	caixa    : BOOL; // Guarda a informação se o item em cima da balança é uma caixa ou não
	
	// Timers de emergência
	Timer_sc  	  : TON := (PT := T#30S);
	Timer_op1 	  : TON := (PT := T#30S);
	Timer_op2     : TON := (PT := T#30S);
<<<<<<< HEAD:PLC_PRG (PRG).st
<<<<<<< HEAD:PLC_PRG (PRG).st
=======
>>>>>>> 670f2d2 (Código funcionando 100% e com 100% de eficiência):PLC_PRG.st
	Timer_usi     : TON := (PT := T#15S);
	Timer_op3     : TON := (PT := T#40S);
=======
	Timer_op3     : TON := (PT := T#30S);
>>>>>>> 3a60cd6 (Update PLC_PRG.st):PLC_PRG.st
	
	// Delays
	delayEstabilizarBalanca : TON := (PT := T#1.5S); // Delay da balança
	
	// Triggers
	trigSC : R_TRIG; // Trigger ativo na subida do sensor SC, 
					 // usado para identificar um item passando na classificação
	trigUsiConcluida : F_TRIG; // Trigger ativo na descida da variável MachiningCenterIsBusy,
							   // Usado para identificar quando a usinagem é concluída
	trigUsiOcupada : R_TRIG; // Trigger ativo na subida da variável MachiningCenterIsBusy,
							 // Usado para identificar quando a usinagem é iniciada
	trigSPMais : R_TRIG; // Triggers de subida dos botões SP+ e SP-, usado para identificar
	trigSPMenos : R_TRIG; // quando esse botões são pressionados
	
	// Blocos Funcionais - Classificação
	movimentoPistao : empurrarCaixa;

	// Blocos Funcionais - Usinagem

	// Blocos Funcionais - Empacotamento
	empCNC : FB_MoveTo;
	posicionarEstPlas : posicionarEsteiraPlastico;
 	posicionarEstMetal : posicionarEsteiraMetal;
 	movPlas : moverPlastico;
 	movMetal : moverMetal;
	
END_VAR

//--------------------------------------------------------------------------------------------
//-------------------------------TRATAMENTO DE VARIÁVEIS--------------------------------------
//----------------------------------------INÍCIO----------------------------------------------

// Variáveis de lógica inversa
EMER := NOT(FIO.i_Emergencia);
STOP := NOT(FIO.i_Stop);
OP2 := NOT(FIO.i_RS1);
OP3 := NOT(FIO.i_RS2);

// Led dos botões
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
	Timer_sc(IN:=NOT FIO.i_SC); // A entrada dos timers será o inverso dos sensores
	Timer_op1(IN:=NOT FIO.i_DS2); // Logo quando os sensores detectarem algo, os timers reiniciam
ELSE // Caso contrário, os timers permanecem inativos
	Timer_sc(IN:=FALSE);
	Timer_op1(IN:=FALSE);
END_IF;

IF Maquina2 AND NOT Emergencia2 THEN // Se a máquina 2 estiver operando
<<<<<<< HEAD:PLC_PRG (PRG).st
<<<<<<< HEAD:PLC_PRG (PRG).st
	Timer_op2(IN:=NOT OP2); // A entrada dos timers será o inverso dos sensores
	Timer_usi(IN:=NOT FIO.i_MachiningCenterIsBusy); // Logo quando os sensores detectarem algo, os timers reiniciam
ELSE // Caso contrário, os timers permanecem inativos
=======
	Timer_op2(IN:=NOT OP2);
	Timer_usi(IN:=NOT FIO.i_MachiningCenterIsBusy);
ELSE
>>>>>>> origin/main:PLC_PRG.st
=======
	Timer_op2(IN:=NOT OP2);
	Timer_usi(IN:=NOT FIO.i_MachiningCenterIsBusy);
ELSE
>>>>>>> 670f2d2 (Código funcionando 100% e com 100% de eficiência):PLC_PRG.st
	Timer_op2(IN:=FALSE);
	Timer_usi(IN:=FALSE);
END_IF;

IF Maquina3 AND NOT Emergencia3 THEN // Se a máquina 3 estiver operando
	Timer_op3(IN:=NOT OP3); // A entrada do timer será o inverso do sensor
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
		global.Fila_cla(clear := FALSE);
		
		os_cla[E_Cla] := TRUE;
	END_IF
	
    // Ações
	FIO.o_E1          := FALSE; // Esteira 1 parada
	FIO.o_E_SP        := FALSE; // Esteira 2 parada
	FIO.o_C1          := FALSE; // Pistão retraído
	FIO.o_NumCaixas := 0;
  
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
    IF FIO.i_DS2 THEN // Se o sensor óptico 1 detectar algo
		IF esperaCla THEN // A máquina espera caso a usinagem tenha pedido
			E_Cla := 7;
		ELSE // Senão vai para o estado de estabilizar o peso
			E_Cla := 2;
		END_IF;
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
    IF delayEstabilizarBalanca.Q THEN // Se o timer da balança der sinal
		IF esperaCla THEN // Ele espera caso a usinagem peça
			E_Cla := 7;
		ELSE // Senão segue pra classificação de caixa ou não caixa
			E_Cla := 3;
		END_IF;
		delayEstabilizarBalanca(IN := FALSE);
	END_IF;
	
	3: // Classificação Caixa ou não caixa
	// Ação oneshot
	IF NOT os_cla[E_Cla] THEN
		os_cla := os_reset;
		
		caixa := (FIO.i_SP < 300); // Com a ação oneshot, determina se é uma caixa ou não pelo peso
		
		os_cla[E_Cla] := TRUE;
	END_IF
	
  	// Ações
	FIO.o_E1 := TRUE; // Esteira 1 ligada
	FIO.o_E_SP := FALSE; // Esteira da balança desligada

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
		
		global.Fila_cla(pop := TRUE); // Na ação oneshot dá um pop na fila de classificação
		global.Fila_cla(pop := FALSE);
		
		os_cla[E_Cla] := TRUE;
	END_IF
	
  	// Ações
	FIO.o_E1 := TRUE; // Esteira 1 ligada
	FIO.o_E_SP := FALSE; // Esteira da balança desligada
	movimentoPistao(start:=TRUE); // Inicia o movimento do pistão

	// Transições de estado
<<<<<<< HEAD:PLC_PRG (PRG).st
    IF movimentoPistao.done THEN // Quando o movimento do pistão é concluído
		FIO.o_NumCaixas := FIO.o_NumCaixas + 1; // Aumenta a quantidade de caixas processadas
		IF esperaCla THEN // E espera caso a usinagem peça
=======
    IF movimentoPistao.done THEN
		FIO.o_NumCaixas := FIO.o_NumCaixas + 1;
		IF esperaCla THEN
>>>>>>> origin/main:PLC_PRG.st
			E_Cla := 7;
		ELSE // Caso não peça volta pro primeiro estado
			E_Cla := 1;
		END_IF;
		movimentoPistao(start:=FALSE);
	END_IF;

	5: // Caixa não detectada
	// Ação oneshot
	IF NOT os_cla[E_Cla] THEN
		os_cla := os_reset;
		
		pushFilaUsi(); // Na ação oneshot, usa a função pushFilaUsi, que tira o item da fila de 
					   // classificação e manda para a fila de usinagem
		contador_classificacao := contador_classificacao + 1; // Aumenta a contagem dos itens que passaram
															  // na classificação
		
		os_cla[E_Cla] := TRUE;
	END_IF
	
  	// Ações
	FIO.o_E1 := TRUE; // Liga a esteira 1
	FIO.o_E_SP := TRUE; // Liga a esteira da balança

	// Transições de estado
    IF NOT FIO.i_DS2 THEN // Se não detectar mais com o sensor óptico
		IF esperaCla THEN // Espera caso a usinagem peça para esperar
			E_Cla := 7;
		ELSE // Caso contrário volta ao primeiro estado
			E_Cla := 1;
		END_IF;
	END_IF;
	
  	6: // Estado Emergência
	// Ação oneshot
	IF NOT os_cla[E_Cla] THEN
		os_cla := os_reset;
		
		global.Fila_cla(clear := TRUE); // Limpa a fila com uma ação oneshot
		global.Fila_cla(clear := FALSE);
		
		os_cla[E_Cla] := TRUE;
	END_IF
	
  	// Ações
<<<<<<< HEAD:PLC_PRG (PRG).st
	FIO.o_E1          	:= FALSE; // Desliga a esteira 1
	FIO.o_E_SP          := FALSE; // Desliga a esteira da balança
	FIO.o_C1           	:= FALSE; // Desliga o pistão
	FIO.o_NumCaixas 	:= 0; // Reseta o número de caixas processadas
	delayEstabilizarBalanca(IN := FALSE); // Reseta o timer de delay da balança
=======
	FIO.o_E1          := FALSE;
	FIO.o_E_SP          := FALSE;
	FIO.o_C1           := FALSE;
	FIO.o_NumCaixas := 0;
	delayEstabilizarBalanca(IN := FALSE);
>>>>>>> origin/main:PLC_PRG.st
  
	// Transições de estado
  
	7: // Espera
	// Ação oneshot
	IF NOT os_cla[E_Cla] THEN
		os_cla := os_reset;
		
		
		
		os_cla[E_Cla] := TRUE;
	END_IF
	
  	// Ações
	FIO.o_E1          := FALSE; // Desliga a esteira 1
	FIO.o_E_SP        := FALSE; // Desliga a esteira da balança
	delayEstabilizarBalanca(IN := FALSE); // Reseta o timer de delay da balança
  
	// Transições de estado
	IF NOT esperaCla THEN // Caso a usinagem não peça mais pra esperar a máquina volta ao estado anterior
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

END_IF;

// Ações Stateless

// Se der um rising no sensor capacitivo, ele registra o item na fila de classificação
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
		global.Fila_usi(clear := FALSE);
		
		os_usi[E_Usi] := TRUE;
	END_IF
	
  	// Ações
	FIO.o_E2     := FALSE; // Esteira 2 desligada
	FIO.o_MachiningCenterProduceLids := FALSE; // Seta a máquina para não produzir tampas
	FIO.o_RB1_Reset := TRUE; // Reseta o robô
	FIO.o_RB1_Stop := FALSE; // Impede o robô travado
	FIO.o_RB1_Start := FALSE; // Impede o robô iniciar o movimento
  
	// Transições de estado
    IF Maquina2 THEN // Se a máquina supervisora mandar o sinal de ligar, a máquina de usinagem sai do ócio
		E_Usi := 1;
	END_IF;
	
	1: // Liga Esteira
	// Ação oneshot
	IF NOT os_usi[E_Usi] THEN
		os_usi := os_reset;
		
		
		
		os_usi[E_Usi] := TRUE;
	END_IF
	
  	// Ações
	FIO.o_E2 := TRUE; // Liga a esteira
	FIO.o_RB1_Reset := FALSE; // Impede o robô de resetar
	FIO.o_RB1_Stop := TRUE; // Deixa o robô travado
	FIO.o_RB1_Start := FALSE; // Impede o robô iniciar o movimento

  
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
	FIO.o_E2 := TRUE; // Liga a esteira
	// Se o item for metal, ele recebe o design fundo, se for plástico recebe o design de tampa
	FIO.o_MachiningCenterProduceLids := NOT(global.Fila_usi.itemOut.metal);
	FIO.o_RB1_Reset := FALSE; // Impede o robô de resetar
	FIO.o_RB1_Stop := FALSE; // Impede o robô travado
	FIO.o_RB1_Start := TRUE; // Inicia o movimento do robô
  
	// Transições de estado
	trigUsiConcluida(CLK:=FIO.i_MachiningCenterIsBusy);
  	IF trigUsiConcluida.Q THEN // Se a usinagem for concluída, passa pro próximo estado
		E_Usi := 3; // Volta pro estado 1
		contador_usinagem := contador_usinagem + 1; // Aumenta em um o números de coisas usinadas
		trigUsiConcluida(CLK:=FIO.i_MachiningCenterIsBusy);
	END_IF;

	3: // Passar item para a próxima fila 
	// Ação oneshot
	IF NOT os_usi[E_Usi] THEN
		os_usi := os_reset;
		
		pushFilaEmp(); // Na ação oneshot, usa a função pushFilaEmp, que tira o item da fila de 
					   // usinagem e manda para a fila de classificação
		
		os_usi[E_Usi] := TRUE;
	END_IF
	
  	// Ações
	FIO.o_E2 := FALSE; // Desliga a esteira
	FIO.o_RB1_Reset := FALSE; // Impede o robô de resetar
	FIO.o_RB1_Stop := FALSE; // Impede o robô travado
	FIO.o_RB1_Start := FALSE; // Impede o movimento do robô
  
	// Transições de estado
	E_Usi := 1; // Volta pro estado 1


	
  	4: // Estado Emergência
  	// Ação oneshot
	IF NOT os_usi[E_Usi] THEN
		os_usi := os_reset;
		
		global.Fila_usi(clear := TRUE); // Limpa a fila
		global.Fila_usi(clear := FALSE);
		
		os_usi[E_Usi] := TRUE;
	END_IF
	
  	// Ações
	FIO.o_E2     := FALSE; // Desliga a esteira
	FIO.o_RB1_Reset := FALSE; // Impede o robô de resetar
	FIO.o_RB1_Stop := TRUE; // Deixa o robô travado
	FIO.o_RB1_Start := FALSE; // Impede o robô iniciar o movimento
  
	
	ELSE // Caso a máquina não esteja em nenhum estado válido, ela retorna ao estado ocioso 
		E_Usi := 0;
	
END_CASE;

// Transições de estado universais
IF Emergencia2 THEN
	E_Usi := 4;
	
ELSIF NOT(Maquina2) THEN
	E_Usi := 0;

END_IF;

// Ações Stateless

// Se a máquina de usinagem estiver ocupada e tiver item chegando ela faz as esteiras pararem
trigUsiOcupada(CLK:=FIO.i_MachiningCenterIsBusy AND OP2);
IF (FIO.i_MachiningCenterIsBusy AND OP2) THEN
	IF trigUsiOcupada.Q THEN // Se a máquina de usinagem acabou de ficar ocupada, ela salva o estado
							 // atual da máquina de classificação antes de pedir para esperar
		E_Cla_anterior := E_Cla;
	END_IF;
	trigUsiOcupada(CLK:=FIO.i_MachiningCenterIsBusy AND OP2);
	FIO.o_E2 := FALSE; // Desliga a esteira que leva até a usinagem
	esperaCla := TRUE; // Liga o sinal de espera da classificação, ou seja, pede para a classificação esperar
ELSE
	esperaCla := FALSE; // Caso a usinagem não esteja ocupada, não pede para a classificação parar
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
		
		global.Fila_emp(clear := TRUE); // Limpa a fila de empacotamento
		global.Fila_emp(clear := FALSE);
		
		os_emp[E_Emp] := TRUE;
	END_IF 
  	// Ações
	// Seta o gantry para ficar na posição de ócio
	empCNC(targetX := constante.Xidle, targetY := constante.Yidle, targetZ := constante.Zidle, start := TRUE);
	FIO.o_E3          := FALSE; // Desliga a esteira que leva ao gantry
	FIO.o_EPLASTIC1 := FALSE; // Desliga as esteiras dos itens de plástico
	FIO.o_EPLASTIC2 := FALSE;
	FIO.o_EPLASTIC3 := FALSE;
	FIO.o_EMETAL1 := FALSE; // Desliga as esteiras dos itens de metal
	FIO.o_EMETAL2 := FALSE;
	FIO.o_EMETAL3 := FALSE;
	metal_counter := 0;
	plastico_counter := 0;
<<<<<<< HEAD:PLC_PRG (PRG).st
	FIO.o_NumPlastico := 0;
	FIO.o_NumMetal := 0;
=======
>>>>>>> edf0396 (Update PLC_PRG.st):PLC_PRG.st
  
	// Transições de estado
  	IF Maquina3 THEN // Se a máquina supervisora mandar o sinal de ligar, a máquina de empacotamento sai do ócio
		empCNC(start := FALSE);
		E_Emp := 1;
	END_IF;
	
	1: // Posicionar esteira de plástico
	// Ação oneshot
	IF NOT os_emp[E_Emp] THEN
		os_emp := os_reset;
		
		
		
		os_emp[E_Emp] := TRUE;
	END_IF 
	
	// Ações
	FIO.o_E3 := FALSE; // Desliga a esteira que leva ao gantry
	posicionarEstPlas(start:=TRUE); // Inicia o FB que posiciona a caixa das esteiras de plástico
  
	// Transições de estado
	IF posicionarEstPlas.done THEN // Quando o posicionamento é concluído passa para o próximo estado
		posicionarEstPlas(start := FALSE);
		E_Emp := 2;
	END_IF;
	
	2: // Posicionar esteira de metal
	// Ação oneshot
	IF NOT os_emp[E_Emp] THEN
		os_emp := os_reset;
		
		
		
		os_emp[E_Emp] := TRUE;
	END_IF 
	
  	// Ações
	FIO.o_E3 := FALSE; // Desliga a esteira que leva ao gantry
	posicionarEstMetal(start:=TRUE); // Inicia o FB que posiciona a caixa das esteiras de plástico

	// Transições de estado
	IF posicionarEstMetal.done THEN // Quando o posicionamento é concluído passa para o próximo estado
		posicionarEstMetal(start := FALSE);
		E_Emp := 3;
	END_IF;
	
	3: // Ligar esteira
	// Ação oneshot
	IF NOT os_emp[E_Emp] THEN
		os_emp := os_reset;
		
		
		
		os_emp[E_Emp] := TRUE;
	END_IF 
	
  	// Ações
	FIO.o_E3 := TRUE; // Liga a esteira que leva ao gantry
	FIO.o_EPLASTIC1 := FALSE; // Desliga as esteiras dos itens de plástico
	FIO.o_EPLASTIC2 := FALSE;
	FIO.o_EPLASTIC3 := FALSE;
	FIO.o_EMETAL1 := FALSE; // Desliga as esteiras dos itens de metal
	FIO.o_EMETAL2 := FALSE;
	FIO.o_EMETAL3 := FALSE;
	
	// Transições de estado
	IF OP3 THEN // Caso o sensor óptico da esteira do empacotamento detecte algo
		IF global.Fila_emp.itemOut.metal THEN // Vai para o estado 5 se o último item da fila for metal
			E_Emp := 5;

		ELSE // Caso contrário vai para o estado 4
			E_Emp := 4;
		END_IF;
		
	END_IF;
	
	4: // Mover plástico
	// Ação oneshot
	IF NOT os_emp[E_Emp] THEN
		os_emp := os_reset;
		
		
		
		os_emp[E_Emp] := TRUE;
	END_IF 
	
  	// Ações
	movPlas(start:=TRUE); // Inicia o FB de empacotar o item de plástico
	FIO.o_EPLASTIC1 := FALSE; // Desliga as esteiras dos itens de plástico
	FIO.o_EPLASTIC2 := FALSE;
	FIO.o_EPLASTIC3 := FALSE;
	FIO.o_EMETAL1 := FALSE; // Desliga as esteiras dos itens de metal
	FIO.o_EMETAL2 := FALSE;
	FIO.o_EMETAL3 := FALSE;

	// Transições de estado
	IF movPlas.done THEN // Quando o empacotamento é concluído
		global.Fila_emp(pop := TRUE); // Dá um pop na fila de empacotamento
		global.Fila_emp(pop := FALSE);
		movPlas(start := FALSE);
<<<<<<< HEAD:PLC_PRG (PRG).st
		FIO.o_NumPlastico := FIO.o_NumPlastico + 1; // Aumenta o contador de itens totais de plástico em 1
		plastico_counter := plastico_counter + 1; // Aumenta o contador de itens da caixa atual de plástico em 1
   		IF plastico_counter < itemPorCaixa THEN // Caso o contador de itens de plástico da caixa atual for
												// menor que os itens por caixa, volta pro estado 3
=======
		FIO.o_NumPlastico := FIO.o_NumPlastico + 1;
		plastico_counter := plastico_counter + 1;
   		IF plastico_counter < itemPorCaixa THEN
>>>>>>> origin/main:PLC_PRG.st
    		E_Emp := 3;

   		ELSE // Caso contrário, vai para o estado 6
    		E_Emp := 6;
   		END_IF;
  	END_IF;
	
  	5: // Mover metal
	// Ação oneshot
	IF NOT os_emp[E_Emp] THEN
		os_emp := os_reset;
		
		
		
		os_emp[E_Emp] := TRUE;
	END_IF 
	
	// Ações
	movMetal(start:=TRUE); // Inicia o FB de empacotar o item de metal
	FIO.o_EPLASTIC1 := FALSE; // Desliga as esteiras dos itens de plástico
	FIO.o_EPLASTIC2 := FALSE;
	FIO.o_EPLASTIC3 := FALSE;
	FIO.o_EMETAL1 := FALSE; // Desliga as esteiras dos itens de metal
	FIO.o_EMETAL2 := FALSE;
	FIO.o_EMETAL3 := FALSE;

	// Transições de estado
  	IF movMetal.done THEN // Quando o empacotamento é concluído
		global.Fila_emp(pop := TRUE); // Dá um pop na fila de empacotamento
		global.Fila_emp(pop := FALSE);
   		movMetal(start := FALSE);
<<<<<<< HEAD:PLC_PRG (PRG).st
		FIO.o_NumMetal := FIO.o_NumMetal + 1; // Aumenta o contador de itens totais de metal em 1
   		metal_counter := metal_counter + 1; // Aumenta o contador de itens da caixa atual de metal em 1
   		IF metal_counter < itemPorCaixa THEN // Caso o contador de itens de metal da caixa atual for
    		E_Emp := 3;						 // menor que os itens por caixa, volta pro estado 3
   		ELSE // Caso contrário, vai para o estado 7
=======
		FIO.o_NumMetal := FIO.o_NumMetal + 1;
   		metal_counter := metal_counter + 1;
   		IF metal_counter < itemPorCaixa THEN
    		E_Emp := 3;
   		ELSE
>>>>>>> origin/main:PLC_PRG.st
    		E_Emp := 7;
   		END_IF;
  	END_IF;

  	6: // Mover esteira plástico
	// Ação oneshot
	IF NOT os_emp[E_Emp] THEN
		os_emp := os_reset;
		
		
		
		os_emp[E_Emp] := TRUE;
	END_IF 
	
  	// Ações
	posicionarEstPlas(start:=TRUE); // Reposiciona a esteira de plástico para que outra caixa vazia fica em posição
  
	// Transições de estado
	IF posicionarEstPlas.done THEN // Caso a reposição da caixa for concluída
		posicionarEstPlas(start := FALSE);
		plastico_counter := 0; // Reseta o contador de itens da caixa atual de plástico
		E_Emp := 3; // E volta para o estado 3
	END_IF;
	
  	7: // Mover esteira metal
	// Ação oneshot
	IF NOT os_emp[E_Emp] THEN
		os_emp := os_reset;
		
		
		
		os_emp[E_Emp] := TRUE;
	END_IF 
	
  	// Ações
  	posicionarEstMetal(start:=TRUE); // Reposiciona a esteira de metal para que outra caixa vazia fica em posição
  
	// Transições de estado
	IF posicionarEstMetal.done THEN // Caso a reposição da caixa for concluída
		posicionarEstMetal(start := FALSE);
		metal_counter := 0; // Reseta o contador de itens da caixa atual de metal
		E_Emp := 3; // E volta para o estado 3
	END_IF;
	
  	8: // Estado Emergência
  	// Ação oneshot
	IF NOT os_emp[E_Emp] THEN
		os_emp := os_reset;
		
		global.Fila_emp(clear:=TRUE); // Limpa a fila de empacotamento
		global.Fila_emp(clear:=FALSE);
		
		os_emp[E_Emp] := TRUE;
	END_IF 
  	// Ações
	FIO.o_E3          := FALSE; // Desliga a esteira que leva ao empacotamento
	FIO.o_EPLASTIC1 := FALSE; // Desliga as esteiras dos itens de plástico
	FIO.o_EPLASTIC2 := FALSE;
	FIO.o_EPLASTIC3 := FALSE;
	FIO.o_EMETAL1 := FALSE; // Desliga as esteiras dos itens de metal
	FIO.o_EMETAL2 := FALSE;
	FIO.o_EMETAL3 := FALSE;
	metal_counter := 0;
	plastico_counter := 0;
<<<<<<< HEAD:PLC_PRG (PRG).st
	FIO.o_NumPlastico := 0;
	FIO.o_NumMetal := 0;
=======
  
>>>>>>> edf0396 (Update PLC_PRG.st):PLC_PRG.st
	
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

CASE E_Sup OF  
	0: // Estado ocioso 
  	// Ações
	Maquina1    			:= FALSE; // Desliga a máquina 1
	Maquina2    			:= FALSE; // Desliga a máquina 2
	Maquina3    			:= FALSE; // Desliga a máquina 3
	Emergencia1 			:= FALSE; // Emergência da máquina 1 desligada
	Emergencia2 			:= FALSE; // Emergência da máquina 2 desligada
	Emergencia3 			:= FALSE; // Emergência da máquina 3 desligada
	FIO.o_LedR  			:= FALSE; // Desliga o led vermelho
	FIO.o_LedG  			:= FALSE; // Desliga o led verde
	FIO.o_LedY  			:= TRUE;  // Liga o led amarelo
	contador_classificacao 	:= 0;	  // Contador de itens processados pela máquina 1 resetado
	contador_usinagem 		:= 0;	  // Contador de itens processados pela máquina 2 resetado

	trigSPMais(CLK:=FIO.i_SPMais);
	IF trigSPMais.Q THEN // Caso o botão SP+ for clicado, a variável itemPorCaixa aumenta em 1
		itemPorCaixa := itemPorCaixa + 1;
		trigSPMais(CLK:=FIO.i_SPMais);
	END_IF;

	trigSPMenos(CLK:=FIO.i_SPMenos);
	IF trigSPMenos.Q THEN // Caso o botão SP- for clicado, a variável itemPorCaixa diminui em 1
		itemPorCaixa := itemPorCaixa - 1;
		trigSPMenos(CLK:=FIO.i_SPMenos);
	END_IF;
  
	// Transições de estado
  	IF FIO.i_Start THEN // Se o botão FIO.i_Start for pressionado, a máquina supervisora sai do ócio
		E_Sup := 1;
	END_IF;
	
	1: // Ligar máquina classificação
	// Ações
	Maquina1   	:= TRUE;  // Liga a máquina 1
	Maquina2   	:= FALSE; // Desliga a máquina 2
	Maquina3   	:= FALSE; // Desliga a máquina 3
	Emergencia1 := FALSE; // Emergência da máquina 1 desligada
	Emergencia2 := FALSE; // Emergência da máquina 2 desligada
	Emergencia3 := FALSE; // Emergência da máquina 3 desligada
	FIO.o_LedR 	:= FALSE; // Desliga o led vermelho
	FIO.o_LedG 	:= TRUE;  // Liga o led verde
	FIO.o_LedY 	:= FALSE; // Desliga o led amarelo

  
	// Transições de estado
  	IF (contador_classificacao > 0) THEN // Se o primeiro item passar por todas os estados da máquina classificadora, passa pro próximo estado
		E_Sup := 2;
	END_IF;
	
	2: // Ligar máquina usinagem
  	// Ações
<<<<<<< HEAD:PLC_PRG (PRG).st
	Maquina1   	:= TRUE;  // Liga a máquina 1
	Maquina2   	:= TRUE;  // Liga a máquina 2
	Maquina3   	:= FALSE; // Desliga a máquina 3
	Emergencia1 := FALSE; // Emergência da máquina 1 desligada
	Emergencia2 := FALSE; // Emergência da máquina 2 desligada
	Emergencia3 := FALSE; // Emergência da máquina 3 desligada
	FIO.o_LedR 	:= FALSE; // Desliga o led vermelho
	FIO.o_LedG 	:= TRUE;  // Liga o led verde
	FIO.o_LedY 	:= FALSE; // Desliga o led amarelo
=======
	Maquina1   := TRUE;
	Maquina2   := TRUE;
	Maquina3   := FALSE;
	Emergencia1 := FALSE;
	Emergencia2 := FALSE;
	Emergencia3 := FALSE;
	FIO.o_LedR := FALSE;
	FIO.o_LedG := TRUE;
	FIO.o_LedY := FALSE;
>>>>>>> origin/main:PLC_PRG.st
  
	// Transições de estado
  	IF (contador_usinagem > 0) THEN // Se o primeiro item passar por todas os estados da máquina usinadora, passa pro próximo estado
		E_Sup := 3;
	END_IF;
	
	3: // Ligar máquina empacotamento
  	// Ações
	Maquina1   	:= TRUE;  // Liga a máquina 1
	Maquina2   	:= TRUE;  // Liga a máquina 2
	Maquina3   	:= TRUE;  // Liga a máquina 3
	Emergencia1 := FALSE; // Emergência da máquina 1 desligada
	Emergencia2 := FALSE; // Emergência da máquina 2 desligada
	Emergencia3 := FALSE; // Emergência da máquina 3 desligada
	FIO.o_LedR 	:= FALSE; // Desliga o led vermelho
	FIO.o_LedG 	:= TRUE;  // Liga o led verde
	FIO.o_LedY 	:= FALSE; // Desliga o led amarelo
  
	// Transições de estado
  
	
  	4: // Estado Emergência
  	// Ações
	Maquina1   				:= FALSE; // Desliga a máquina 1
	Maquina2   				:= FALSE; // Desliga a máquina 2
	Maquina3   				:= FALSE; // Desliga a máquina 3
	Emergencia1 			:= TRUE;  // Emergência da máquina 1 ligada
	Emergencia2 			:= TRUE;  // Emergência da máquina 2 ligada
	Emergencia3 			:= TRUE;  // Emergência da máquina 3 ligada
	FIO.o_LedR 				:= TRUE;  // Liga o led vermelho
	FIO.o_LedG 				:= FALSE; // Desliga o led verde
	FIO.o_LedY 				:= FALSE; // Desliga o led amarelo
	contador_classificacao 	:= 0;     // Contador de itens processados pela máquina 1 resetado
	contador_usinagem 		:= 0;     // Contador de itens processados pela máquina 2 resetado
  
	// Transições de estado
	
	ELSE // Caso a máquina não esteja em nenhum estado válido, ela retorna ao estado ocioso 
		E_Sup := 0;
	
END_CASE;

// Transições de estado universais
<<<<<<< HEAD:PLC_PRG (PRG).st
<<<<<<< HEAD:PLC_PRG (PRG).st
IF (EMER OR Timer_sc.Q OR Timer_op1.Q OR Timer_op2.Q OR Timer_usi.Q OR Timer_op3.Q) THEN // Caso algum timer
																					// de sensor dispare
	E_Sup := 4; // Entra em estado de emergência
=======
=======
>>>>>>> 670f2d2 (Código funcionando 100% e com 100% de eficiência):PLC_PRG.st
IF (EMER OR Timer_sc.Q OR Timer_op1.Q OR Timer_op2.Q OR Timer_usi.Q OR Timer_op3.Q) THEN
	E_Sup := 4;
>>>>>>> origin/main:PLC_PRG.st
	
ELSIF STOP THEN // Caso o botão de parada for ativado, vai para o estado ocioso
	E_Sup := 0;

END_IF;

//------------------------------------------FINAL---------------------------------------------
//----------------------------------MÁQUINA SUPERVISORA---------------------------------------

//------------------------------------------FINAL---------------------------------------------
//-----------------------------------MÁQUINAS DE ESTADOS--------------------------------------
//--------------------------------------------------------------------------------------------