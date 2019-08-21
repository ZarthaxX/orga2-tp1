#include "lib.h"

/** STRING **/

char* strSubstring(char* pString, uint32_t inicio, uint32_t fin) {

    return 0;
}

/** Lista **/

void listPrintReverse(list_t* pList, FILE *pFile, funcPrint_t* fp) {

}

/** HashTable **/

uint32_t strHash(char* pString) {
  if(strLen(pString) != 0)
      return (uint32_t)pString[0] - 'a';
  else
      return 0;
}

void hashTableRemoveAll(hashTable_t* pTable, void* data, funcCmp_t* fc, funcDelete_t* fd) {

}

void hashTablePrint(hashTable_t* pTable, FILE *pFile, funcPrint_t* fp) {

}
