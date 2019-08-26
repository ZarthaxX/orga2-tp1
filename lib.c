#include "lib.h"

/** STRING **/

char* strSubstring(char* pString, uint32_t inicio, uint32_t fin) {
	uint32_t length = 0;
	
	while(pString[length] != 0){
		length++;
	}
	
	if(fin >= length)
		fin = length-1;
		
	uint32_t new_length = (fin-inicio+1 + 1);
	char* ptr = (char*) malloc((fin-inicio+1 + 1)* sizeof(char));
	
	for(uint32_t i = inicio;i <= fin;i++){
		ptr[i-inicio] = pString[i];
	}
	
	cerr << new_length << endl;
	ptr[new_length-1] = 0;
	
	free(pString);
    return ptr;
}

/** Lista **/

void listPrintReverse(list_t* pList, FILE *pFile, funcPrint_t* fp) {
	s_listElem* last = pList->last;

	while (last != NULL) {
		printf("%p", last->data);
		last = last->prev;
	}
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
