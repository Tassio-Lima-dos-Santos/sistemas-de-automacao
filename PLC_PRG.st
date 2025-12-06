//--------------------------------------------------------------------------------------------
//----------------------------------MÁQUINAS DE ESTADO----------------------------------------
//----------------------------------------INÍCIO----------------------------------------------



//----------------------------------MÁQUINA CLASSIFICADORA------------------------------------
//----------------------------------------INÍCIO----------------------------------------------

CASE E_Cla OF
	0: // Estado ocioso 
  // Ações

  
	// Transições de estado
  
	
	1: // Liga Esteira
	// Ações

  
	// Transições de estado
  
	
	2: // Classificação Metal ou não Metal
  // Ações

  
	// Transições de estado
  
	
	3: // Espera estabilizar peso
  // Ações

  
	// Transições de estado
  
	
	4: // Classificação Caixa ou não caixa
  // Ações

  
	// Transições de estado
  
	
  5: // Estado Emergência
  // Ações

  
	// Transições de estado
  
	
	ELSE // Caso a máquina não esteja em nenhum estado válido, ela retorna ao estado ocioso 
		STATE := 0;
	
END_CASE;

//------------------------------------------FINAL---------------------------------------------
//----------------------------------MÁQUINA CLASSIFICADORA------------------------------------



//-----------------------------------MÁQUINA USINAGEM-----------------------------------------
//----------------------------------------INÍCIO----------------------------------------------

CASE E_Usi OF
	0: // Estado ocioso 
  // Ações

  
	// Transições de estado
  
	
	1: // Liga Esteira
	// Ações

  
	// Transições de estado
  
	
	2: // Pôr peça na usinagem
  // Ações

  
	// Transições de estado
  
	
	3: // Usinagem
  // Ações

  
	// Transições de estado
  
	
	4: // Tira peça da usinagem
  // Ações

  
	// Transições de estado
  
	
  5: // Estado Emergência
  // Ações

  
	// Transições de estado
  
	
	ELSE // Caso a máquina não esteja em nenhum estado válido, ela retorna ao estado ocioso 
		STATE := 0;
	
END_CASE;

//------------------------------------------FINAL---------------------------------------------
//------------------------------------MÁQUINA USINAGEM----------------------------------------



//---------------------------------MÁQUINA EMPACOTAMENTO--------------------------------------
//----------------------------------------INÍCIO----------------------------------------------

CASE E_Emp OF
	0: // Estado ocioso 
  // Ações

  
	// Transições de estado
  
	
	1: // Liga Esteira
	// Ações

  
	// Transições de estado
  
	
	2: // Pegar item
  // Ações

  
	// Transições de estado
  
	
	3: // Mover plástico
  // Ações

  
	// Transições de estado
  
	
	4: // Mover metal
  // Ações

  
	// Transições de estado
  
	
  5: // Mover esteira plástico
  // Ações

  
	// Transições de estado
  

  6: // Mover esteira metal
  // Ações

  
	// Transições de estado
  
	
  7: // Estado Emergência
  // Ações

  
	// Transições de estado
  
	
	ELSE // Caso a máquina não esteja em nenhum estado válido, ela retorna ao estado ocioso 
		STATE := 0;
	
END_CASE;

//------------------------------------------FINAL---------------------------------------------
//---------------------------------MÁQUINA EMPACOTAMENTO--------------------------------------



//----------------------------------MÁQUINA SUPERVISORA---------------------------------------
//----------------------------------------INÍCIO----------------------------------------------

CASE E_Sup OF
	0: // Estado ocioso 
  // Ações

  
	// Transições de estado
  
	
	1: // Ligar máquina classificação
	// Ações

  
	// Transições de estado
  
	
	2: // Ligar máquina usinagem
  // Ações

  
	// Transições de estado
  
	
	3: // Ligar máquina empacotamento
  // Ações

  
	// Transições de estado
  
	
  4: // Estado Emergência
  // Ações

  
	// Transições de estado
  
	
	ELSE // Caso a máquina não esteja em nenhum estado válido, ela retorna ao estado ocioso 
		STATE := 0;
	
END_CASE;

//------------------------------------------FINAL---------------------------------------------
//----------------------------------MÁQUINA SUPERVISORA---------------------------------------

//------------------------------------------FINAL---------------------------------------------
//-----------------------------------MÁQUINAS DE ESTADOS--------------------------------------
//--------------------------------------------------------------------------------------------

