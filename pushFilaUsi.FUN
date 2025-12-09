FUNCTION pushFilaUsi : BOOL
VAR_INPUT
VAR_END;
VAR
VAR_END;

global.Fila_usi.itemIn := global.Fila_cla.itemOut;
global.Fila_usi(push := TRUE);
global.Fila_usi.push := FALSE;
global.Fila_cla(pop := TRUE);
global.Fila_cla.pop := FALSE;