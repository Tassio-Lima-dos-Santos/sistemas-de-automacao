FUNCTION pushFilaUsi : BOOL
VAR_INPUT
END_VAR
VAR
END_VAR

global.Fila_usi.itemIn.metal := global.Fila_cla.itemOut.metal; // Seta o item que está entrando na fila de
                                                               // usinagem igual ao item que está saindo
                                                               // da fila de classificação
global.Fila_usi(push := TRUE);  // Dá push na fila de usinagem
global.Fila_usi(push := FALSE);
global.Fila_cla(pop := TRUE);   // Dá pop na fila de classificação
global.Fila_cla(pop := FALSE);
