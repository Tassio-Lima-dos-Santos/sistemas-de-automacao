FUNCTION registrarItem : BOOL
VAR_INPUT
END_VAR
VAR
END_VAR

global.Fila_cla.itemIn.metal := FIO.i_SI; // Seta a variável metal do item de entrada da fila de classificação
                                          // como a informação indicada pelo sensor indutivo
global.Fila_cla(push := TRUE);  // Dá push na fila de classificação
global.Fila_cla(push := FALSE);
