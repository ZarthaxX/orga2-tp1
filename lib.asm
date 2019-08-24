section .rodata

section .text

extern malloc
extern free
extern fprintf

global strLen
global strClone
global strCmp
global strConcat
global strDelete
global strPrint
global listNew
global listAddFirst
global listAddLast
global listAdd
global listRemove
global listRemoveFirst
global listRemoveLast
global listDelete
global listPrint
global listPrintReverse
global hashTableNew
global hashTableAdd
global hashTableDeleteSlot
global hashTableDelete

;RDI RSI RDX RCX R8 R9 integers
;XMM0 - XMM7 floats/doubles
;RSP when full for floats or integers use this

strLen: ;uint32_t strLen(char* pString)
;							   RDI
	xor RAX,RAX
	.ciclo:
		cmp byte [RDI], 0
		je .fin
		inc EAX
		inc RDI
		jmp .ciclo
	.fin:
    ret

strClone: ;char* strClone(char* pString)
;								RDI
	;Obtengo la longitud del string y lo guardo en RCX
	push RDI
	call strLen
	pop RDI
	mov RCX,RAX
	inc RCX ;Sumo 1 para el caracter nulo
	;Inicializo un bloque de memoria para guardar el nuevo string
	push RDI
	push RCX
	mov RDI,RCX
	call malloc
	pop RCX
	pop RDI

	;Recorro el string original incrementado el puntero en RDI y copio el contenido en RAX
    mov byte [RAX + RCX * 1],0
	.ciclo:
		mov SIL,[RDI + RCX * 1 - 1]
		mov [RAX + RCX * 1 - 1],SIL
		loop .ciclo

	ret

strCmp: ;int32_t strCmp(char* pStringA, char* pStringB)
;							RDI				RSI
	;Obtengo la longitud del string A y lo guardo en RDX
	push RDI
	push RSI
	call strLen
	pop RSI
	pop RDI
	mov RDX,RAX
	
	;Obtengo la longitud del string B y lo guardo en RCX
	push RDX
	push RDI
	push RSI
	mov RDI,RSI
	call strLen
	pop RSI
	pop RDI
	pop RDX
	mov RCX,RAX

	;Guardo la maxima longitud de las strings A y B 
	;y en RAX el resultado si al comparar ambas strings hasta la longitud mas corta son iguales
	xor RAX,RAX
	mov EAX,0
	cmp RCX,RDX
	jz .cycle ;Si los strings son iguales hay que devolver 0 porque tienen misma longitud
	mov EAX,1
	jg .cycle ;Ya esta en RCX la longitud de B y en EAX hay que
			  ;devolver 1 si comparados son iguales omitiendo los caracteres extra de B
	mov EAX,-1
	mov RCX,RDX
	.cycle:
		mov R8,[RDI]
		cmp R8,[RSI]
		jg .stringAisFirst
		jb .stringBisFirst
		inc RDI
		inc RSI
		loop .cycle
	ret

	.stringAisFirst:
	mov EAX,-1
    ret
	
	.stringBisFirst:
	mov EAX,1

	ret

strConcat: ;char* strConcat(char* pStringA, char* pStringB)
;								RDI				RSI
	;Obtengo la longitud del string A y lo guardo en RDX
	push RDI
	push RSI
	call strLen
	pop RSI
	pop RDI
	mov RDX,RAX
	
	;Obtengo la longitud del string B y lo guardo en RCX
	push RDX
	push RDI
	push RSI
	mov RDI,RSI
	call strLen
	pop RSI
	pop RDI
	pop RDX
	mov RCX,RAX
	
	;Inicio un bloque de memoria del tamaño de las longitudes de ambos strings + 1 por el caracter nulo
	push RDX
	push RCX
	push RDI
	push RSI
	mov RDI,RDX
	adcx RDI,RCX
	inc RDI
	call malloc
	pop RSI
	pop RDI
	pop RCX
	pop RDX

	adcx RAX,RDX
	push RDX
	mov byte [RAX + RCX * 1 ],0
	.cycle1:
		mov DL,[RSI + RCX * 1 - 1]
		mov [RAX + RCX * 1 - 1],DL
		loop .cycle1
	pop RDX
	mov RCX,RDX
	.cycle2:
		mov DL,[RDI + RCX * 1 - 1]
		mov [RAX - 1],DL
		dec RAX
		loop .cycle2

    ret

strDelete: ;void strDelete(char* pString)
;								RDI
	call free
    ret
 
strPrint: ;void strPrint(char* pString, FILE *pFile)
;								RDI			RSI
	push RBP
	cmp RDI,0
	jne .stringNotNull
	mov RDI,RSI
	mov RSI,'NULL'
	call fprintf
	jmp .end

	.stringNotNull:
	mov RDX,RDI
	mov RDI,RSI
	mov RSI,'%s'
	call fprintf
	.end:
	pop RBP
    ret
   

;   typedef struct s_list{
;    struct s_listElem *first;
;    struct s_listElem *last;
;} list_t;

;typedef struct s_listElem{
;    void *data;
;    struct s_listElem *next;
;    struct s_listElem *prev;
;} listElem_t;

%define list_t_first 0
%define list_t_last 8
%define listElem_t_data 0
%define listElem_t_next 8
%define listElem_t_prev 16
%define list_t_size 16
%define listElem_t_size 24

listNew: ;list_t* listNew()
	sub RSP, 8
	mov RDI,16
	call malloc
	mov qword [RAX+list_t_first],0
	mov qword [RAX+list_t_last],0
	add RSP, 8
    ret

listAddFirst: ;void listAddFirst(list_t* pList, void* data)
;										RDI			RSI
	;Inicializo bloque de memoria del tamaño de un nodo (24 bytes)
	push RDI
	push RSI
	mov RDI,listElem_t_size
	call malloc
	pop RSI
	pop RDI

	;Seteo datos iniciales del nodo nuevo
	mov [RAX+listElem_t_data],RSI
	mov qword [RAX+listElem_t_prev],0
	mov RSI,[RDI+list_t_first]
	mov [RAX+listElem_t_next],RSI

	;Seteo el puntero al first de la lista al nuevo elemento
	mov [RDI+list_t_first],RAX
	
	;Chequeo si existe un nodo viejo en el primer lugar
	cmp RSI,0
	je .firstIsNull
	;El prev del nodo viejo apunta al nuevo
	mov [RSI+listElem_t_prev],RAX
	ret

	.firstIsNull:
	mov [RDI+list_t_last],RAX
    ret

listAddLast: ;void listAddLast(list_t* pList, void* data)
;										RDI			RSI
	;Inicializo bloque de memoria del tamaño de un nodo (24 bytes)
	push RDI
	push RSI
	mov RDI,listElem_t_size
	call malloc
	pop RSI
	pop RDI

	;Seteo datos iniciales del nodo nuevo
	mov [RAX+listElem_t_data],RSI
	mov qword [RAX+listElem_t_next],0
	mov RSI,[RDI+list_t_last]
	mov [RAX+listElem_t_prev],RSI

	;Seteo el puntero al ultimo de la lista al nuevo elemento
	mov [RDI+list_t_last],RAX
	
	;Chequeo si existe un nodo viejo en el ultimo lugar
	cmp RSI,0
	je .lastIsNull
	;El next del nodo viejo apunta al nuevo
	mov [RSI+listElem_t_next],RAX
	ret

	.lastIsNull:
	mov [RDI+list_t_first],RAX
    ret
	
;%define list_t_first 0
;%define list_t_last 8
;%define listElem_t_data 0
;%define listElem_t_next 8
;%define listElem_t_prev 16
;%define list_t_size 16
;%define listElem_t_size 24

listAdd: ;void listAdd(list_t* pList, void* data, funcCmp_t* fc)
;								RDI			RSI				RDX
	;Inicializo bloque de memoria del tamaño de un nodo (24 bytes)
	push RDI
	push RSI
	mov RDI,listElem_t_size
	call malloc
	pop RSI
	pop RDI

	mov RCX,[RDI+list_t_first]
	cmp RCX,0 ;Check if pointer is null
	jmp .addFirst ;If pointer to first element is null we use the function listAddFirst

	;Check if element has to be inserted in the first position, if it as listAddFirst() is used
	push RDI
	push RSI
	push RDX
	push RCX
	mov RDI,RSI
	mov RSI,[RCX+listElem_t_data]
	call RDX
	pop RCX
	pop RDX
	pop RSI
	pop RDI
	cmp RAX,-1
	jne .addFirst

	;Check if element has to be inserted in the last position, if it as listAddFirst() is used
	push RDI
	push RSI
	push RDX
	push RCX
	mov RCX,[RDI+list_t_last]
	mov RDI,RSI
	mov RSI,[RCX+listElem_t_data]
	call RDX
	pop RCX
	pop RDX
	pop RSI
	pop RDI
	cmp RAX,1
	jne .addLast

	mov RCX,[RDI+list_t_first]
	.cycle:
		push RDI
		push RSI
		push RDX
		push RCX
		mov RDI,RSI
		mov RSI,[RCX + listElem_t_data]
		call RDX
		pop RCX
		pop RDX
		pop RSI
		pop RDI
		cmp RAX,-1
		jne .addBetweenTwo ;If value returned by compare is not -1 we can insert this element here
		mov RCX,[RCX + listElem_t_next]
		jmp .cycle
	
	ret ;This ret should never be reached

	.addBetweenTwo:
	ret

	.addLast:
	call listAddLast
    ret

	.addFirst:
	call listAddFirst
	ret


listRemove:
    ret

listRemoveFirst: ;void listRemoveFirst(list_t* pList, funcDelete_t* fd)
;											RDI					RSI
	;Check if an element exists in the list
	cmp qword [RDI+list_t_first],0
	jne .firstNotNull
	ret

	.firstNotNull:
	mov RDX,[RDI+list_t_first]
	push RDI
	mov RDI,[RDX+listElem_t_data]
	cmp RSI,0
	je .fdIsNull
	call RSI
	jmp .end

	.fdIsNull:
	call free
    
    .end:
    pop RDI
	mov RCX,[RDX+listElem_t_next]
	cmp RCX,0
	je .listIsEmpty
	mov qword [RCX+listElem_t_prev],0
	mov [RDI+list_t_first],RCX
	ret
	.listIsEmpty:
	mov qword [RDI+list_t_first],0
	mov qword [RDI+list_t_last],0
	ret

listRemoveLast:
    ;Check if an element exists in the list
	cmp qword [RDI+list_t_last],0
	jne .lastNotNull
	ret

	.lastNotNull:
	mov RDX,[RDI+list_t_last]
	push RDI
	mov RDI,[RDX+listElem_t_data]
	cmp RSI,0
	je .fdIsNull
	call RSI
	jmp .end

	.fdIsNull:
	call free
    
    .end:
    pop RDI
	mov RCX,[RDX+listElem_t_prev]
	cmp RCX,0
	je .listIsEmpty
	mov qword [RCX+listElem_t_next],0
	mov [RDI+list_t_last],RCX
	ret
	.listIsEmpty:
	mov qword [RDI+list_t_first],0
	mov qword [RDI+list_t_last],0
	ret

listDelete: ;void listDelete(list_t* pList, funcDelete_t* fd)
	;								RDI					RSI
	push RBP
	mov RBP,RSP
	sub RSP,16
	cmp RDI,0 ;list is null
	je .end
	mov RDI,[RDI+list_t_first]
	cmp RDI,0
	je .end

	.cycle:
		mov [RBP-8],RDI
		mov [RBP-16],RSI
		mov RDI,[RDI+list_t_data]
		cmp RSI,0
		je .free 

		call RSI
		jmp .next

		.free:
		call free

		.next:
		mov RDI,[RBP-8]
		mov RSI,[RBP-16]
		mov RDI,[RDI+list_t_next]
		cmp RDI,0
		jne .cycle

	.end:
	add RSP,16
	pop RBP
    ret

listPrint: ;void listPrint(list_t* pList, FILE *pFile, funcPrint_t* fp)
	;								RDI			RSI				RDX
    push RBP
	mov RBP,RSP
	sub RSP,16
	cmp RDI,0 ;list is null
	je .end
	mov RDI,[RDI+list_t_first]
	cmp RDI,0
	je .end

	.cycle:
		mov [RBP-8],RDI
		mov [RBP-16],RSI
		mov RDI,[RDI+list_t_data]
		cmp RSI,0
		je .free 

		call RSI
		jmp .next

		.free:
		call free

		.next:
		mov RDI,[RBP-8]
		mov RSI,[RBP-16]
		mov RDI,[RDI+list_t_next]
		cmp RDI,0
		jne .cycle

	.end:
	add RSP,16
	pop RBP
    ret

%if 0
typedef struct s_hashTable{
    struct s_list **listArray;
    uint32_t size;
    funcHash_t* funcHash;
} hashTable_t;
%endif

%define hashTable_t.listArray 0
%define hashTable_t.size 8
%define hashTable_t.funcHash 12
%define hashTable_t_size 20

hashTableNew: ;hashTable_t* hashTableNew(uint32_t size, funcHash_t* funcHash)
;												RDI						RSI
   	push rbp
   	mov rbp,rsp
   	sub rsp,24
   	mov [rbp-8],rdi
   	mov [rbp-16],rsi

   	;Initialize the hashTable struct
   	mov rdi,hashTable_t_size
   	call malloc
   	mov [rbp-24],rax

   	;We initialize the values in hashTable
   	mov rdx,[rbp-16]
   	mov [rax+hashTable_t.funcHash],rdx
   	mov rdx,[rbp-8]
   	mov [rax+hashTable_t.size],rdx
   	lea rdi,[rdx*8]
   	call malloc
   	mov rdx,[rbp-24]
   	mov [rdx+hashTable_t.listArray],rax

   	mov rcx,[rbp-8]
   	mov rdx,rax
   	.cycle:
   		push rcx
   		push rdx
   		call listNew
   		pop rdx
   		pop rcx
   		mov [rdx+rcx*8-8],rax
   		loop .cycle
   	;Save on rax the pointer to the hashTable
   	mov rax,[rbp-24]
   	add rsp,24
   	pop rbp
   	ret

hashTableAdd: ;void hashTableAdd(hashTable_t* pTable, void* data)
;											RDI				RSI
	push rbp
	mov rbp,rsp
	sub rsp,16
	mov rdx,[rdi+hashTable_t.funcHash]
	mov rdi,rsi
	call rdx
	
	add rsp,16
	pop rbp
    ret
    
hashTableDeleteSlot:
    ret

hashTableDelete:
    ret
