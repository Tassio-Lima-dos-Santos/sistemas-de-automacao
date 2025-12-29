VAR_GLOBAL CONSTANT
    Xidle : INT := 500; // As coordenadas do Gantry CNC quando ele estiver ocioso
    Yidle : INT := 500;
    Zidle : INT := 200;

    XconveyorPlas : INT := 470; // As coordenadas do Gantry CNC para detectar uma caixa passando 
    YconveyorPlas : INT := 600; // pela esteira de plástico usando o sensor SPP
    ZconveyorPlas : INT := 1000;

    XconveyorMetal : INT := 1000; // As coordenadas do Gantry CNC para detectar uma caixa passando 
    YconveyorMetal : INT := 600;  // pela esteira de plástico usando o sensor SPP
    ZconveyorMetal : INT := 1000;

    Xpart : INT := 110; // As coordenadas do Gantry CNC para pegar uma peça na esteira da usinagem
    Ypart : INT := 500;
    Zpart : INT := 830;

    XboxMetal : INT := 850; // As coordenadas do Gantry CNC para pôr uma peça numa caixa da esteira
    YboxMetal : INT := 500; // de metal
    ZboxMetal : INT := 800;

    XboxPlas : INT := 330; // As coordenadas do Gantry CNC para pôr uma peça numa caixa da esteira
    YboxPlas : INT := 500; // de plástico
    ZboxPlas : INT := 800;

END_VAR
