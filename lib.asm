section .rodata

%define NULL 0

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
    push r12
    mov r12,rdi
    call strLen
    xor rdi,rdi
    mov edi,eax
    inc edi
    call malloc

    mov rcx,0
    .cycle:
        mov dl,[r12+rcx]
        mov [rax+rcx],dl
        inc rcx
        cmp dl,0
        jne .cycle


    pop r12
    ret

strCmp: ;int32_t strCmp(char* pStringA, char* pStringB)
;                           RDI             RSI
    
    .cycle:
        mov dl,[rdi]
        cmp dl,[rsi]
        mov eax,1
        jb .end
        mov eax,-1
        jg .end
        cmp dl,0
        mov eax,0
        je .end
        inc rdi
        inc rsi
        jmp .cycle
    
    .end:
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


%define next_node r12
%define prev_node r13
%define funcCmp r14
%define data r15
%define new_node rax
%define list_ptr rbx
listAdd: ;void listAdd(list_t* pList, void* data, funcCmp_t* fc)
;                               RDI         RSI             RDX
    push next_node
    push prev_node
    push data
    push funcCmp
    push list_ptr

    mov list_ptr,rdi
    mov data,rsi
    mov funcCmp,rdx

    mov next_node,[list_ptr+list_t_first] ;Save the next node to visit
    mov prev_node,0 ;Save the last seen prev node,initially NULL
    .cycle:
        cmp next_node,0
        je .insertNode ;If next node is NULL, list end reached and we exit
        ;We compare the 2 values, the one pointed by *data and the actual node data
        mov rsi,data
        mov rdi,[next_node+listElem_t_data]
        call funcCmp

        cmp rax,1 
        jne .insertNode ;Jump if the new node data is <= next node data
        mov prev_node,next_node
        mov next_node,[next_node+listElem_t_next]
        jmp .cycle

    .insertNode:
    cmp prev_node,0 ;Node is smaller than min element or list is empty
    je .addNodeFirst
    cmp next_node,0 ;Node is greater than max element
    je .addNodeLast
    ;New node has to be inserted between 2 nodes

    ;Create new node for list
    mov rdi,listElem_t_size
    call malloc
    mov [rax+listElem_t_data],data
    mov [prev_node+listElem_t_next],new_node ;prevNode.next points to newNode
    mov [next_node+listElem_t_prev],new_node ;nextNode.prev points to newNode
    mov [new_node+listElem_t_prev],prev_node ;newNode.prev points to prevNode
    mov [new_node+listElem_t_next],next_node ;newNode.next points to nextNode
    jmp .end

    .addNodeFirst:
    mov rdi,list_ptr
    mov rsi,data
    call listAddFirst
    jmp .end

    .addNodeLast:
    mov rdi,list_ptr
    mov rsi,data
    call listAddLast
    jmp .end

    .end:
    pop list_ptr
    pop funcCmp
    pop data
    pop prev_node
    pop next_node
    ret


%define actual_node r12
%define funcDelete r13
%define funcCmp r14
%define data r15
%define list_ptr rbx

listRemove: ;void listRemove(list_t* pList, void* data, funcCmp_t* fc, funcDelete_t* fd)
;                               RDI         RSI             RDX                     RCX
    push actual_node
    push funcDelete
    push funcCmp
    push data
    push list_ptr
    ;Save the 3 initial parameters in stack
    mov list_ptr,rdi
    mov data,rsi
    mov funcCmp,rdx
    mov funcDelete,rcx

    mov actual_node,[list_ptr+list_t_first] ;Save the next node to visit

    .cycle:
        ;Check if end of list has been reached
        cmp actual_node,NULL
        je .end 

        ;Save next node in rdi and save it on stack for next iteration
        mov rdi,[actual_node+listElem_t_next]
        push rdi
        sub rsp,8

        ;Check if both strings are equal
        mov rdi,[actual_node+listElem_t_data]
        mov rsi,data
        call funcCmp
        cmp eax,0
        jne .continue

        ;Gotta delete this node
        mov rdi,list_ptr
        mov rsi,funcDelete
        cmp [list_ptr+list_t_first],actual_node
        je .deleteFirst
        cmp [list_ptr+list_t_last],actual_node
        je .deleteLast
        ;It is a middle node so it has a next and prev
        mov rdi,[actual_node+listElem_t_next]
        mov rsi,[actual_node+listElem_t_prev]
        mov [rdi+listElem_t_prev],rsi
        mov [rsi+listElem_t_next],rdi

        push qword [actual_node+listElem_t_data]
        sub rsp,8
        mov rdi,actual_node
        call free
        add rsp,8

        ;Get the pointer to data from stack to rdi and delete data
        pop rdi
        cmp funcDelete,NULL
        je .continue
        call funcDelete
        jmp .continue

        .deleteFirst:
        call listRemoveFirst
        jmp .continue

        .deleteLast:
        call listRemoveLast

        .continue:
        add rsp,8
        pop actual_node
        jmp .cycle

    .end:    
    pop list_ptr
    pop data
    pop funcCmp
    pop funcDelete
    pop actual_node
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
    je .eraseStruct
    call [rbp-16]
    
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
    je .eraseStruct
    call [rbp-16]

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

%define actual_node r12
%define funcDelete r13
listDelete: ;void listDelete(list_t* pList, funcDelete_t* fd)
    ;                               RDI                 RSI
    push actual_node
    push funcDelete
    push rdi
    mov funcDelete,rsi
    mov actual_node,[rdi+list_t_first]

    .cycle:
        cmp qword actual_node,NULL
        je .end
        mov rdi,[actual_node+listElem_t_data]
        cmp funcDelete,NULL
        je .funcDeleteIsNull
        call funcDelete
        .funcDeleteIsNull:
        mov rdi,actual_node
        mov actual_node,[actual_node+listElem_t_next]
        call free
        jmp .cycle
    .end:
    pop rdi
    sub rsp,8
    call free
    add rsp,8
    pop funcDelete
    pop actual_node
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

%define hashTable r12
%define funcDelete r13
hashTableDeleteSlot: ;void hashTableDeleteSlot(hashTable_t* pTable, uint32_t slot, funcDelete_t* fd)
;                                                       RDI                 ESI             RDX
    push hashTable
    push funcDelete

    mov hashTable,rdi
    mov funcDelete,rdx
    ;Calculate slot number modulo array size
    mov eax,esi
    mov edx,0
    div dword [rdi+hashTable_t.size]
    mov esi,edx
    shl rsi,32
    shr rsi,32

    ;Use index in rsi to erase list on that position
    ;and reinitialize it to empty list
    mov rdi,[hashTable+hashTable_t.listArray]
    mov rdi,[rdi+rsi*8]
    push rsi
    mov rsi,funcDelete
    call listDelete
    call listNew
    pop rsi
    mov rdi,[hashTable+hashTable_t.listArray]
    mov [rdi+rsi*8],rax

    pop funcDelete
    pop hashTable
    ret


%define hashTable r12
%define funcDelete r13
hashTableDelete: ;void hashTableDelete(hashTable_t* pTable, funcDelete_t* fd)
;                                                   RDI                 RSI
    push hashTable
    push funcDelete
    mov hashTable,rdi
    mov funcDelete,rsi
    xor rcx,rcx
    mov ecx,[rdi+hashTable_t.size]

    .cycle:
        ;Delete a slot from the listArray of hashtable
        
        push rcx
        mov rdi,[hashTable+hashTable_t.listArray]
        mov rdi,[rdi+rcx*8-8]
        mov rsi,funcDelete
        call listDelete
        pop rcx

        loop .cycle

  
    sub rsp,8
    mov rdi,[hashTable+hashTable_t.listArray]
    call free
    mov rdi,hashTable
    call free

    add rsp,8
    pop funcDelete
    pop hashTable
    ret


