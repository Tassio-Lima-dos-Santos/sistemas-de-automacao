//--------------------------------------------------------------------------------------------
//----------------------------------MÁQUINAS DE ESTADO----------------------------------------
//----------------------------------------INÍCIO----------------------------------------------



//----------------------------------MÁQUINA CLASSIFICADORA------------------------------------
//----------------------------------------INÍCIO----------------------------------------------

CASE E_Cla OF
	0: // Estado ocioso 
    // Ações

  
	// Transições de estado
  	IF Maquina1 THEN // Se receber o sinal Maquina1, a máquina classificadora sai do ócio
		E_Cla := 1;
	END_IF;
	
	1: // Liga Esteira
	// Ações

  
	// Transições de estado
	IF NOT(Maquina1) THEN // Se a máquina supervisora mandar um sinal para desligar, a máquina volta pro ócio
		E_Cla := 0;
    ELSIF SC THEN // Se o sensor capacitivo detectar algo, muda para o estado de classificação de metal
		E_Cla := 2;
	END_IF;
	
	2: // Classificação Metal ou não Metal
  // Ações

  
	// Transições de estado
    IF (NOT(SC) AND OP1) THEN // Se tanto o sensor capacitivo não detectar nada, quanto o sensor optíco 1 detectar, passa pro próximo estado
		E_Cla := 3;
	END_IF;
	
	3: // Espera estabilizar peso
  // Ações

  
	// Transições de estado
    IF KT1 THEN // Se o timer 1 der sinal, passa pro próximo estado
		E_Cla := 4;
	END_IF;
	
	4: // Classificação Caixa ou não caixa
  // Ações

  
	// Transições de estado
    IF (NOT(OP1)) THEN // Se o sensor optíco 1 não detectar nada, volta ao início da operação
		E_Cla := 1;
	END_IF;
	
  5: // Estado Emergência
  // Ações

  
	// Transições de estado
  
	
	ELSE // Caso a máquina não esteja em nenhum estado válido, ela retorna ao estado ocioso 
		E_Cla := 0;
	
END_CASE;

// Transições de estado universais
IF Emergencia1 THEN
	E_Cla := 5;
	
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

  
	// Transições de estado
    IF Maquina2 THEN // Se a máquina supervisora mandar o sinal de ligar, a máquina de usinagem sai do ócio
		E_Usi := 1;
	END_IF;
	
	1: // Liga Esteira
	// Ações

  
	// Transições de estado
	IF NOT(Maquina2) THEN // Se a máquina supervisora mandar o sinal de desligar, a máquina de usinagem volta pro ócio
		E_Usi := 0;
    ELSIF OP2 THEN // Se o sensor optíco 2 detectar a peça, passa para o próximo estado
		E_Usi := 2;
	END_IF;
	
	2: // Pôr peça na usinagem
  // Ações

  
	// Transições de estado
  	IF (Mov1_concluido) THEN // Se o movimento 1 do braço robótico for concluído, passa pro próximo estado
		E_Usi := 3;
	END_IF;
	
	3: // Usinagem
  // Ações

  
	// Transições de estado
  	IF (Usinagem_concluido) THEN // Se a usinagem for concluída, passa pro próximo estado
		E_Usi := 4;
	END_IF;
	
	4: // Tira peça da usinagem
  // Ações

  
	// Transições de estado
  	IF (Mov2_concluido) THEN // Se o movimento 2 do braço robótico for concluído, passa pro próximo estado
		E_Usi := 1;
	END_IF;
	
  5: // Estado Emergência
  // Ações

  
	// Transições de estado
  
	
	ELSE // Caso a máquina não esteja em nenhum estado válido, ela retorna ao estado ocioso 
		E_Usi := 0;
	
END_CASE;

// Transições de estado universais
IF Emergencia2 THEN
	E_Usi := 5;
	
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

  
	// Transições de estado
  	IF Maquina3 THEN // Se a máquina supervisora mandar o sinal de ligar, a máquina de empacotamento sai do ócio
		E_Emp := 1;
	END_IF;
	
	1: // Liga Esteira
	// Ações

  
	// Transições de estado
	IF NOT(Maquina3) THEN // Se a máquina supervisora mandar o sinal de desligar, a máquina de empacotamento volta pro ócio
		E_Emp := 0;
  	ELSIF OP3 THEN // Se o sensor optíco 3 detectar a peça, passa para o próximo estado
		E_Emp := 2;
	END_IF;
	
	2: // Pegar item
  // Ações

  
	// Transições de estado
  	IF metal THEN // Se o item pego for metal, segue pro estado 3
		E_Emp := 3;
	ELSE // Se não for, segue pro estado 4
		E_Emp := 4;
	END_IF;
	
	3: // Mover plástico
  // Ações

  
	// Transições de estado
  	IF (plastico_counter < itemPorCaixa) THEN // Se a máquina supervisora mandar o sinal de ligar, a máquina de empacotamento sai do ócio
		E_Emp := 1;
	ELSE
		E_Emp := 5;
	END_IF;
	
	4: // Mover metal
  // Ações

  
	// Transições de estado
  	IF (metal_counter < itemPorCaixa) THEN // Se a máquina supervisora mandar o sinal de ligar, a máquina de empacotamento sai do ócio
		E_Emp := 1;
	ELSE
		E_Emp := 6;
	END_IF;
	
  5: // Mover esteira plástico
  // Ações

  
	// Transições de estado
  	E_Emp := 1;

  6: // Mover esteira metal
  // Ações

  
	// Transições de estado
  	E_Emp := 1;
	
  7: // Estado Emergência
  // Ações

  
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

CASE E_Sup OF
	0: // Estado ocioso 
  // Ações

  
	// Transições de estado
  	IF START THEN // Se o botão start for pressionado, a máquina supervisora sai do ócio
		E_Sup := 1;
	END_IF;
	
	1: // Ligar máquina classificação
	// Ações

  
	// Transições de estado
  	IF (contador_classificacao > 0) THEN // Se o primeiro item passar por todas os estados da máquina classificadora, passa pro próximo estado
		E_Sup := 2;
	END_IF;
	
	2: // Ligar máquina usinagem
  // Ações

  
	// Transições de estado
  	IF (contador_usinagem > 0) THEN // Se o primeiro item passar por todas os estados da máquina usinadora, passa pro próximo estado
		E_Sup := 2;
	END_IF;
	
	3: // Ligar máquina empacotamento
  // Ações

  
	// Transições de estado
  
	
  4: // Estado Emergência
  // Ações

  
	// Transições de estado
  
	
	ELSE // Caso a máquina não esteja em nenhum estado válido, ela retorna ao estado ocioso 
		E_Sup := 0;
	
END_CASE;

// Transições de estado universais
IF (EMER OR Contador_sc OR Contador_op1 OR Contador_op2 OR Contador_op3) THEN
	E_Sup := 4;
	
ELSIF STOP THEN
	E_Sup := 0;

END_IF;

//------------------------------------------FINAL---------------------------------------------
//----------------------------------MÁQUINA SUPERVISORA---------------------------------------

//------------------------------------------FINAL---------------------------------------------
//-----------------------------------MÁQUINAS DE ESTADOS--------------------------------------
//--------------------------------------------------------------------------------------------

