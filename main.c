#include <stdio.h>
#include <stdlib.h>
#include <ctype.h>
#include <string.h>
#include <assert.h>
#include <math.h>

#include "lib.h"

void test_hashTable(FILE *pfile){
    
}

int main (void){
    FILE *pfile = fopen("salida.caso.propios.txt","w");
    test_hashTable(pfile);
    fclose(pfile);
    return 0;
}