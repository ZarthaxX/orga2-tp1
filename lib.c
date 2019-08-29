#include "lib.h"

/** STRING **/


char* strSubstring(char* pString, uint32_t inicio, uint32_t fin) {
	uint32_t length = strLen(pString);
	char* ptr;
	if(inicio <= fin && length > 0){
		
		if(fin >= length)
			fin = length-1;
			
		uint32_t new_length = (fin-inicio+1 + 1);
		ptr = (char*) malloc(new_length* sizeof(char));
		
		for(uint32_t i = inicio;i <= fin;i++){
			ptr[i-inicio] = pString[i];
		}
		
		ptr[new_length-1] = 0;
		
	}else{
		ptr = (char*)malloc((length+1) * sizeof(char));
		for(uint32_t i = 0;i < length+1;i++){
			ptr[i] = pString[i];
		}
	}
	free(pString);
    return ptr;
}

/** Lista **/

void listPrintReverse(list_t* pList, FILE *pFile, funcPrint_t* fp) {
	listElem_t* last = pList->last;

	fprintf(pFile,"[");

	while (last != NULL) {

		if(fp==NULL)
			fprintf(pFile,"%p", last->data);
		else
			(*fp)(last->data,pFile);
		last = last->prev;

		if(last != NULL)
			fprintf(pFile,",");
	}

	fprintf(pFile,"]");
}

/** HashTable **/

uint32_t strHash(char* pString) {
  if(strLen(pString) != 0)
      return (uint32_t)pString[0] - 'a';
  else
      return 0;
}

void hashTableRemoveAll(hashTable_t* pTable, void* data, funcCmp_t* fc, funcDelete_t* fd) {
	uint32_t index = pTable->funcHash((char*)data) % pTable->size;
	listRemove(pTable->listArray[index],data,fc,fd);
}

void hashTablePrint(hashTable_t* pTable, FILE *pFile, funcPrint_t* fp) {
	for(uint32_t i = 0;i < pTable->size;i++){
		fprintf(pFile,"%d = ",i);
		listPrintReverse(pTable->listArray[i],pFile,fp);
		fprintf(pFile, "\n");
	}
}
