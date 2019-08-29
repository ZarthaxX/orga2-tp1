section .rodata

null : DB 'NULL',0
strFormat : DB '%s',0

listStart : DB '[',0
listEnd : DB ']',0
elementSeparator : DB ',',0
ptrFormat : DB '%p',0

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
;                              RDI
    push RBP
    xor RAX,RAX
    .ciclo:
        cmp byte [RDI], 0
        je .fin
        inc EAX
        inc RDI
        jmp .ciclo
    .fin:
    pop RBP
    ret

strClone: ;char* strClone(char* pString)
;                               RDI
    push RBP
    ;Obtengo la longitud del string y lo guardo en RCX
    push RDI
    sub RSP,8
    call strLen
    add RSP,8
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
    .ciclo:
        mov SIL,[RDI + RCX * 1 - 1]
        mov [RAX + RCX * 1 - 1],SIL
        loop .ciclo

    pop RBP
    ret

strCmp: ;int32_t strCmp(char* pStringA, char* pStringB)
;                           RDI             RSI
    push RBP
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
    jmp .end

    .stringAisFirst:
    mov EAX,-1
    jmp .end
    
    .stringBisFirst:
    mov EAX,1

    .end:
    pop RBP
    ret

strConcat: ;char* strConcat(char* pStringA, char* pStringB)
;                               RDI             RSI
    push rbp
    mov rbp,rsp
    sub rsp,32
    mov [rbp-8],rdi
    mov [rbp-16],rsi

    ;Get length of string A
    call strLen
    shl rax,32
    shr rax,32
    mov [rbp-24],rax

    ;Get length of string B
    mov rdi,[rbp-16]
    call strLen
    shl rax,32
    shr rax,32
    mov [rbp-32],rax

    ;Allocate block of memory for concat of strings
    mov rdi,[rbp-24]
    add rdi,[rbp-32]
    inc rdi
    call malloc

    mov rdx,0
    mov rdi,[rbp-8]
    .copyA:
        cmp byte [rdi+rdx*1],0
        je .endCopyA
        mov cl,[rdi+rdx*1]
        mov [rax+rdx],cl
        inc rdx
        jmp .copyA

    .endCopyA:

    mov rdx,0
    mov rdi,[rbp-16]
    .copyB:
        cmp byte [rdi+rdx*1],0
        je .endCopyB
        mov cl,[rdi+rdx*1]
        push rdx
        add rdx,[rbp-24]
        mov [rax+rdx],cl
        pop rdx
        inc rdx
        jmp .copyB

    .endCopyB:

    mov rdx,[rbp-24]
    add rdx,[rbp-32]
    mov byte [rax+rdx*1],0

    sub rsp,8
    push rax
    mov rdi,[rbp-8]
    call strDelete
    mov rdi,[rbp-16]
    cmp rdi,[rbp-8]
    je .sameStrings
    call strDelete
    .sameStrings:
    pop rax
    add rsp,8
    add rsp,32
    pop rbp
    ret

strDelete: ;void strDelete(char* pString)
;                               RDI
    push RBP
    call free
    pop RBP
    ret

strPrint: ;void strPrint(char* pString, FILE *pFile)
;                               RDI         RSI
    push RBP
    push RDI
    push RSI
    call strLen
    pop RSI
    pop RDI
    cmp EAX,0
    jne .stringNotNull
    mov RDI,RSI
    mov RSI,null
    call fprintf
    jmp .end

    .stringNotNull:
    mov RDX,RDI
    mov RDI,RSI
    mov RSI,strFormat
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
    push RBP
    mov RDI,16
    call malloc
    mov qword [RAX+list_t_first],0
    mov qword [RAX+list_t_last],0
    pop RBP
    ret

listAddFirst: ;void listAddFirst(list_t* pList, void* data)
;                                       RDI         RSI
    push RBP
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
    jmp .end

    .firstIsNull:
    mov [RDI+list_t_last],RAX
    
    .end:
    pop RBP
    ret

listAddLast: ;void listAddLast(list_t* pList, void* data)
;                                       RDI         RSI
    push RBP
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
    jmp .end

    .lastIsNull:
    mov [RDI+list_t_first],RAX
    
    .end:
    pop RBP
    ret
    
;%define list_t_first 0
;%define list_t_last 8
;%define listElem_t_data 0
;%define listElem_t_next 8
;%define listElem_t_prev 16
;%define list_t_size 16
;%define listElem_t_size 24

listAdd: ;void listAdd(list_t* pList, void* data, funcCmp_t* fc)
;                               RDI         RSI             RDX
    push rbp
    mov rbp,rsp
    sub rsp,32
    ;Save the 3 initial parameters in stack
    mov [rbp-8],rdi
    mov [rbp-16],rsi
    mov [rbp-24],rdx

    ;Create new node for list
    mov rdi,listElem_t_size
    call malloc
    mov [rbp-32],rax
    mov rsi,[rbp-16]
    mov [rax+listElem_t_data],rsi
    mov rdi,[rbp-8]
    mov rdi,[rdi+list_t_first] ;Save the next node to visit
    mov rsi,0 ;Save the last seen prev node,initially NULL

    .cycle:
        cmp rdi,0
        je .insertNode ;If next node is NULL, list end reached and we exit
        push rdi
        push rsi
        ;We compare the 2 values, the one pointed by *data and the actual node data
        mov rsi,[rbp-16]
        mov rdi,[rdi+listElem_t_data]
        call [rbp-24]
        pop rsi
        pop rdi

        cmp rax,1 
        jne .insertNode ;Jump if the new node data is <= next node data
        mov rsi,rdi
        mov rdi,[rdi+listElem_t_next]
        jmp .cycle

    .insertNode:
    cmp rsi,0 ;Node is smaller than min element or list is empty
    jmp .addNodeFirst
    cmp rdi,0 ;Node is greater than max element
    je .addNodeLast
    ;New node has to be inserted between 2 nodes
    mov rdx,[rbp-32]
    mov [rsi+listElem_t_next],rdx ;prevNode.next points to newNode
    mov [rdi+listElem_t_prev],rdx ;nextNode.prev points to newNode
    mov [rdx+listElem_t_prev],rsi ;newNode.prev points to prevNode
    mov [rdx+listElem_t_next],rdi ;newNode.next points to nextNode
    jmp .end

    .addNodeFirst:
    mov rdi,[rbp-8]
    mov rsi,[rbp-16]
    call listAddFirst
    jmp .end

    .addNodeLast:
    mov rdi,[rbp-8]
    mov rsi,[rbp-16]
    call listAddLast
    jmp .end

    .end:
    add rsp,32
    pop rbp
    ret


listRemove: ;void listRemove(list_t* pList, void* data, funcCmp_t* fc, funcDelete_t* fd)
;                               RDI         RSI             RDX                     RCX
    push rbp
    mov rbp,rsp
    sub rsp,48
    ;Save the 3 initial parameters in stack
    mov [rbp-8],rdi
    mov [rbp-16],rsi
    mov [rbp-24],rdx
    mov [rbp-32],rcx

    mov rdi,[rdi+list_t_first] ;Save the next node to visit

    .cycle:
        cmp rdi,0
        je .end ;If next node is NULL, list end reached and we exit
        mov [rbp-40],rdi ; Save actual node pointer
        mov rsi,[rdi+listElem_t_next]
        mov [rbp-48],rsi ; Save next node pointer
        ;We compare the 2 values, the one pointed by *data and the actual node data
        mov rsi,[rbp-16]
        mov rdi,[rdi+listElem_t_data]
        call [rbp-24]

        cmp rax,0
        jne .continue ;Continue if the new node data is == next node data
        
        mov rdi,[rbp-40]
        mov rsi,[rdi+listElem_t_prev]
        cmp rsi,0 ;Node has no prev, so it is the first node
        je .removeNodeFirst
        mov rdx,[rdi+listElem_t_next]
        cmp rdx,0 ;Node has no next, so it is the last node
        je .removeNodeLast
        ;Delete node between 2 nodes
        mov [rsi+listElem_t_next],rdx
        mov [rdx+listElem_t_prev],rsi

        mov rdi,[rdi+listElem_t_data]
        cmp qword [rbp-32],0
        je .fdIsNull 
        call [rbp-32]
        jmp .deleteStruct

        .fdIsNull:
        call free

        .deleteStruct:
        mov rdi,[rbp-40]
        call free
        jmp .continue

        .removeNodeFirst:
        mov rdi,[rbp-8]
        mov rsi,[rbp-32]
        call listRemoveFirst
        jmp .continue

        .removeNodeLast:
        mov rdi,[rbp-8]
        mov rsi,[rbp-32]
        call listRemoveLast

        .continue:
        mov rdi,[rbp-48]
        jmp .cycle

    .end:
    add rsp,48
    pop rbp
    ret

listRemoveFirst: ;void listRemoveFirst(list_t* pList, funcDelete_t* fd)
;                                           RDI                 RSI
    push rbp
    mov rbp,rsp
    sub rsp,16
    mov [rbp-8],rdi
    mov [rbp-16],rsi

    cmp qword [rdi+list_t_first],0 ;List is empty already
    je .end
    mov rdi,[rdi+list_t_first]
    mov rdi,[rdi+listElem_t_data]
    cmp rsi,0
    je .fdIsNull
    call [rbp-16]
    jmp .eraseStruct

    .fdIsNull:
    call free
    
    .eraseStruct:
    mov rdi,[rbp-8]
    mov rdi,[rdi+list_t_first]
    mov rsi,[rdi+listElem_t_next]
    push rsi
    sub rsp,8
    call free
    add rsp,8
    pop rsi
    mov rdi,[rbp-8]
    cmp rsi,0
    je .emptyList
    mov [rdi+list_t_first],rsi
    mov qword [rsi+listElem_t_prev],0
    jmp .end

    .emptyList:
    mov qword [rdi+list_t_first],0
    mov qword [rdi+list_t_last],0

    .end:
    add rsp,16
    pop rbp
    ret

listRemoveLast: ;void listRemoveLast(list_t* pList, funcDelete_t* fd)
;                                           RDI                 RSI
    push rbp
    mov rbp,rsp
    sub rsp,16
    mov [rbp-8],rdi
    mov [rbp-16],rsi

    cmp qword [rdi+list_t_last],0
    je .end
    mov rdi,[rdi+list_t_last]
    mov rdi,[rdi+listElem_t_data]
    cmp rsi,0
    je .fdIsNull
    call [rbp-16]
    jmp .eraseStruct

    .fdIsNull:
    call free
    
    .eraseStruct:
    mov rdi,[rbp-8]
    mov rdi,[rdi+list_t_last]
    mov rsi,[rdi+listElem_t_prev]
    push rsi
    sub rsp,8
    call free
    add rsp,8
    pop rsi
    mov rdi,[rbp-8]
    cmp rsi,0
    je .emptyList
    mov [rdi+list_t_last],rsi
    mov qword [rsi+listElem_t_next],0
    jmp .end

    .emptyList:
    mov qword [rdi+list_t_first],0
    mov qword [rdi+list_t_last],0

    .end:
    add rsp,16
    pop rbp
    ret

listDelete: ;void listDelete(list_t* pList, funcDelete_t* fd)
    ;                               RDI                 RSI
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
        mov RDI,[RDI+listElem_t_data]
        cmp RSI,0
        je .free 

        call RSI
        jmp .next

        .free:
        call free

        .next:
        mov RDI,[RBP-8]
        mov RSI,[RBP-16]
        mov RDI,[RDI+listElem_t_next]
        cmp RDI,0
        jne .cycle

    .end:
    add RSP,16
    pop RBP
    ret

listPrint: ;void listPrint(list_t* pList, FILE *pFile, funcPrint_t* fp)
    ;                               RDI         RSI             RDX
    push rbp
    mov rbp,rsp
    sub rsp,32
    mov [rbp-8],rdi
    mov [rbp-16],rsi
    mov [rbp-24],rdx
    mov rdi,rsi
    mov rsi,listStart
    call fprintf

    mov rdi,[rbp-8]
    mov rdi,[rdi+list_t_first]
    cmp rdi,0
    je .end

    .cycle:
        mov [rbp-32],rdi
        cmp qword [rbp-24],0
        je .fpIsNull

        mov rdi,[rdi+listElem_t_data]
        mov rsi,[rbp-16]
        call [rbp-24]
        jmp .continue

        .fpIsNull:
        mov rdx,[rdi+listElem_t_data]
        mov rsi,ptrFormat
        mov rdi,[rbp-16]
        call fprintf
        
        .continue:
        mov rdi,[rbp-32]
        mov rdi,[rdi+listElem_t_next]
        cmp rdi,0
        je .end
        mov [rbp-32],rdi
        mov rdi,[rbp-16]
        mov rsi,elementSeparator
        call fprintf
        mov rdi,[rbp-32]
        jmp .cycle
    .end:
    mov rdi,[rbp-16]
    mov rsi,listEnd
    call fprintf
    add rsp,32
    pop rbp
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
%define hashTable_t.funcHash 16
%define hashTable_t_size 24

hashTableNew: ;hashTable_t* hashTableNew(uint32_t size, funcHash_t* funcHash)
;                                               RDI                     RSI
    push rbp
    mov rbp,rsp
    sub rsp,32
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
    add rsp,32
    pop rbp
    ret

hashTableAdd: ;void hashTableAdd(hashTable_t* pTable, void* data)
;                                           RDI             RSI
    push rbp
    mov rbp,rsp
    sub rsp,16

    mov [rbp-8],rdi
    mov [rbp-16],rsi
    mov rdx,[rdi+hashTable_t.funcHash]
    mov rdi,rsi
    call rdx
    mov edx,0
    mov rdi,[rbp-8]
    div dword [rdi+hashTable_t.size]
    mov rdi,[rdi+hashTable_t.listArray]
    mov eax,edx
    shl rax,32
    shr rax,32
    mov rdi,[rdi+rax*8]
    mov rsi,[rbp-16]
    call listAddLast
    add rsp,16
    pop rbp
    ret
    
hashTableDeleteSlot: ;void hashTableDeleteSlot(hashTable_t* pTable, uint32_t slot, funcDelete_t* fd)
;                                                       RDI                 ESI             RDX
    push rbp

    ;Calculate slot number modulo array size
    push rdx
    mov eax,esi
    mov edx,0
    div dword [rdi+hashTable_t.size]
    mov esi,edx
    shl rsi,32
    shr rsi,32
    pop rdx

    ;Use index in rsi to erase list on that position
    ;and reinitialize it to empty list
    mov rdi,[rdi+hashTable_t.listArray]
    mov rdi,[rdi+rsi*8]
    push rdi
    push rsi
    mov rsi,rdx
    call listDelete
    call listNew
    pop rsi
    pop rdi
    mov [rdi+rsi*8],rax
    pop rbp
    ret

hashTableDelete: ;void hashTableDelete(hashTable_t* pTable, funcDelete_t* fd)
;                                                   RDI                 RSI
    push rbp
    push rdi
    xor rcx,rcx
    mov ecx,[rdi+hashTable_t.size]
    mov rdi,[rdi+hashTable_t.listArray]
    .cycle:
        ;Delete a slot from the listArray of hashtable
        push rdi
        push rsi
        push rcx
        mov rdi,[rdi]
        call listDelete
        pop rcx 
        pop rsi
        pop rdi
        add rdi,8
        loop .cycle

    pop rdi
    call free
    pop rbp
    ret
