FUNCTION pushFilaEmp : BOOL
VAR_INPUT
END_VAR
VAR
END_VAR

global.Fila_emp.itemIn.metal := global.Fila_usi.itemOut.metal; // Seta o item que está entrando na fila de
                                                               // empacotamento igual ao item que está saindo
                                                               // da fila de usinagem
global.Fila_emp(push := TRUE);  // Dá push na fila de empacotamento
global.Fila_emp(push := FALSE);
global.Fila_usi(pop := TRUE);  // Dá pop na fila de usinagem
global.Fila_usi(pop := FALSE);
