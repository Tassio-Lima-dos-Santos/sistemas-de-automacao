{attribute 'qualified_only'}
VAR_GLOBAL
    i_DS2        			  		: BOOL; // Sensor óptico da balança
    i_Emergencia              		: BOOL; // Botão de emergência
	i_MachiningCenterOpened   		: BOOL; // Centro de usinagem livre
	i_MachiningCenterIsBusy   		: BOOL; // Centro de usinagem trabalhando
	i_MachiningCenterHasError 		: BOOL; // Erro no processo de usinagem
	i_RS1 					  		: BOOL; // Sensor óptico da usinagem
	i_RS2 					  		: BOOL; // Sensor óptico do empacotamento
	i_SC    				  		: BOOL; // Sensor capacitivo
	i_SC1Mais 				  		: BOOL; // Fim de curso do pistão - estendido
	i_SC1Menos 	 			  		: BOOL; // Fim de curso do pistão - retraido
    i_SI        			  		: BOOL; // Sensor indutivo
	i_SP 					  		:  INT; // Sensor da balança (4.0 plástico; 5.0 metal; 1.5 caixa)
	i_SPMais 				  		: BOOL; // Botão de aumentar quantidade de itens por caixa
	i_SPMenos 				  		: BOOL; // Botão de diminuir quantidade de itens por caixa
	i_SPP 					  		: BOOL; // Sensor de item pego pela ponte CNC
	i_Start 				  		: BOOL; // Botão START
	i_Stop 					  		: BOOL; // Botão STOP
    i_XPOS        			  		:  INT; // Dado da posição X atual da ponte CNC
    i_YPOS    				  		:  INT; // Dado da posição Y atual da ponte CNC
    i_ZPOS      			  		:  INT; // Dado da posição Z atual da ponte CNC
	i_DS3        			  		: BOOL; // Sensor óptico da esteira de plástico
	i_DS4        			  		: BOOL; // Sensor óptico da esteira de metal

	o_C1 					  		: BOOL; // Pistão
	o_Caixas_Emissor_1 		  		: BOOL; // Emissor de caixas (metal)
	o_E1 					  		: BOOL; // Primeira Esteira do classificador
	o_E2 					  		: BOOL; // Esteira final do classificador e inicial da usinagem
	o_E3 					  		: BOOL; // Esteira inicial do empacotamento
	o_EMETAL1 				  		: BOOL; // Primeira esteira de rolo do empacotamento de metal
	o_EMETAL2 				  		: BOOL; // Segunda esteira de rolo do empacotamento de metal
	o_EMETAL3 				  		: BOOL; // Terceira esteira de rolo do empacotamento de metal
	o_Emissor_Partes 		  		: BOOL; // Emissor dos itens (Deixar ligado)
	o_Emitter_4 			  		: BOOL; // Emissor de caixas (plástico)
	o_EPLASTIC1 			  		: BOOL; // Primeira esteira de rolo do empacotamento de plástico
	o_EPLASTIC2 			  		: BOOL; // Segunda esteira de rolo do empacotamento de plástico
	o_EPLASTIC3 			  	   	: BOOL; // Terceira esteira de rolo do empacotamento de plástico
	o_E_SP 					  	   	: BOOL; // Esteira da balança
	o_LedG 					  	   	: BOOL; // Led verde no canto da usinagem
	o_LedR 					  	   	: BOOL; // Led vermelho no canto da usinagem
	o_LedSPMais 			  	   	: BOOL; // Led do botão SP+
	o_LedSPMenos 			  	   	: BOOL; // Led do botão SP-
	o_LedStart 				  	   	: BOOL; // Led do botão START
	o_LedStop 				  	   	: BOOL; // Led do botão STOP
	o_LedY 					  	   	: BOOL; // Led amarelo no canto da usinagem
    o_RB1_Stop 				  	   	: BOOL; // Botão de interrupção do processo do braço robótico + usinagem
	o_RB1_Reset 			  	   	: BOOL; // Botão de reset do processo do braço robótico + usinagem
	o_RB1_Start 			  	  	: BOOL; // Botão de iniciar o processo do braço robótico + usinagem
	o_Succao 				  	  	: BOOL; // Acionamento da sucção da ponte CNC
    o_X           			  		:  INT; // Posição X da ponte CNC
    o_Y   					  		:  INT; // Posição Y da ponte CNC
    o_Z  					  		:  INT; // Posição Z da ponte CNC
	o_MachiningCenterProduceLids    : BOOL; // Modo de usinagem do plástico
	o_NumCaixas               		:  INT;  // Número de caixas
	o_NumMetal                		:  INT;  // Número de itens de metal
	o_NumPlastico             		:  INT;  // Número de itens de plástico
END_VAR