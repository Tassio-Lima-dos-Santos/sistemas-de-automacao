TYPE ST_PRODUCT :

// Struct que guarda as informações sobre um produto, como o tipo dele, se ele já foi processado ou se ele é metálico
// Na prática só foi usada a informação de se o produto é metálico ou não, mas caso o projeto necessitasse de mais
// features ou fosse expandido de alguma forma, a struct permitiria essas expansão sem muito retrabalho

STRUCT
	productType : E_PRODUCT_TYPE;
	processed : BOOL;
	metal : BOOL;
END_STRUCT
END_TYPE
