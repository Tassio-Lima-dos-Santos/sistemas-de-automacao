FUNCTION_BLOCK FB_PRODUCT_QUEUE
VAR_INPUT
<<<<<<< HEAD:FB_PRODUCT_QUEUE (FB).st
    push : BOOL; // Sinais de entrada que determinam o método chamado do objeto
    pop  : BOOL;
    clear  : BOOL;
    itemIn : ST_PRODUCT; // Buffer do produto que vai entrar na fila
=======
    push : BOOL := FALSE;
    pop  : BOOL := FALSE;
    clear  : BOOL := FALSE;
    itemIn : ST_PRODUCT;
>>>>>>> origin/main:FB_PRODUCT_QUEUE.FB
END_VAR

VAR_OUTPUT
    itemOut : ST_PRODUCT; // Buffer do produto que vai sair da fila
    isEmpty : BOOL; // Informação se a fila está vazia
    isFull  : BOOL; // Informação se a fila está cheia
END_VAR

VAR
    // Triggers dos métodos
	trigPush : R_TRIG;
    trigPop  : R_TRIG;
    trigClear : R_TRIG;	

    // Array que guarda de fato a informação dos produtos na fila
    buffer : ARRAY[1..100] OF ST_PRODUCT;
    head   : INT := 1; // Índice que indica o produto que está saindo da fila
    tail   : INT := 1; // Índice que indica o produto que está entrando na fila
    count  : INT := 0; // Quantidade de itens atualmente na fila
END_VAR

// Atualiza os detectores de flanco
trigPush(CLK := push);
trigPop(CLK := pop);
trigClear(CLK := clear);

// Peek
itemOut := buffer[head];

// Clear
IF trigClear.Q THEN
    head := 1;
    tail := head;
    count := 0;

// Dequeue
ELSIF trigPop.Q AND (count > 0) THEN
    head := (head MOD 100) + 1;
    count := count - 1;

// Enqueue
ELSIF trigPush.Q AND (count < 100) THEN
    buffer[tail] := itemIn;
    tail := (tail MOD 100) + 1;
    count := count + 1;
END_IF;

isEmpty := (count = 0);
isFull  := (count = 100);
