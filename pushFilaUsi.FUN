FUNCTION pushFilaUsi : BOOL
VAR_INPUT
END_VAR
VAR
END_VAR

global.Fila_usi.itemIn.metal := global.Fila_cla.itemOut;
global.Fila_usi(push := TRUE);
global.Fila_usi(push := FALSE);
global.Fila_cla(pop := TRUE);
global.Fila_cla(pop := FALSE);
