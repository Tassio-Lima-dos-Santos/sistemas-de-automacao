{attribute 'qualified_only'}
{attribute 'strict'}

// Enum para os tipos de itens que podem ser gerados e identificados no início da operação

TYPE E_PRODUCT_TYPE :
(
	e_productType_unknown := 0, // Caso o item ainda não tenha sido identificado ou tenha ocorrido algum erro
								// durante a identificação
	e_productType_plastic := 1, // Caso o item seja um bloco de plástico
	e_productType_metal := 2, // Caso o item seja um bloco de metal
	e_productType_box := 3 // Caso o item seja uma caixa
);
END_TYPE
