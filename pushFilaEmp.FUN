FUNCTION pushFilaEmp : BOOL
VAR_INPUT
END_VAR
VAR
END_VAR

global.Fila_emp.itemIn := global.Fila_usi.itemOut;
global.Fila_emp(push := TRUE);
global.Fila_emp.push := FALSE;
global.Fila_usi(pop := TRUE);
global.Fila_usi.pop := FALSE;
