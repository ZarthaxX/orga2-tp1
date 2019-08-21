#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include <ctype.h>
#include <string.h>
#include <assert.h>
#include <math.h>
#include <stdbool.h>
#include <unistd.h>

/* String */

char* strClone(char* pString);
uint32_t strLen(char* pString);
int32_t strCmp(char* pStringA, char* pStringB);
char* strConcat(char* pStringA, char* pStringB);
char* strSubstring(char* pString, uint32_t inicio, uint32_t fin);
void strDelete(char* pString);
void strPrint(char* pString, FILE *pFile);

/* List */

typedef struct s_list{
    struct s_listElem *first;
    struct s_listElem *last;
} list_t;

typedef struct s_listElem{
    void *data;
    struct s_listElem *next;
    struct s_listElem *prev;
} listElem_t;


typedef void (funcDelete_t)(void*);
typedef void (funcPrint_t)(void*, FILE *pFile);
typedef int32_t (funcCmp_t)(void*, void*);
typedef int32_t (funcHash_t)(void*);

list_t* listNew();
void listAddFirst(list_t* pList, void* data);
void listAddLast(list_t* pList, void* data);
void listAdd(list_t* pList, void* data, funcCmp_t* fc);
void listRemove(list_t* pList, void* data, funcCmp_t* fc, funcDelete_t* fd);
void listRemoveFirst(list_t* pList, funcDelete_t* fd);
void listRemoveLast(list_t* pList, funcDelete_t* fd);
void listDelete(list_t* pList, funcDelete_t* fd);
void listPrint(list_t* pList, FILE *pFile, funcPrint_t* fp);
void listPrintReverse(list_t* pList, FILE *pFile, funcPrint_t* fp);

/** HashTable **/

typedef struct s_hashTable{
    struct s_list **listArray;
    uint32_t size;
    funcHash_t* funcHash;
} hashTable_t;

uint32_t strHash(char* pString);
hashTable_t* hashTableNew(uint32_t size, funcHash_t* fh);
void hashTableAdd(hashTable_t* pTable, void* data);
void hashTableRemoveAll(hashTable_t* pTable, void* data, funcCmp_t* fc, funcDelete_t* fd);
void hashTableDeleteSlot(hashTable_t* pTable, uint32_t slot, funcDelete_t* fd);
void hashTableDelete(hashTable_t* pTable, funcDelete_t* fd);
void hashTablePrint(hashTable_t* pTable, FILE *pFile, funcPrint_t* fp);