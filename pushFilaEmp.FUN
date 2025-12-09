FUNCTION pushFilaUsi : BOOL
VAR_INPUT
VAR_END;
VAR
VAR_END;

global.Fila_emp.itemIn := global.Fila_usi.itemOut;
global.Fila_emp(push := TRUE);
global.Fila_emp.push := FALSE;
global.Fila_usi(pop := TRUE);
global.Fila_usi.pop := FALSE;