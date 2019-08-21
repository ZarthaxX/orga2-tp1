#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include <ctype.h>
#include <string.h>
#include <assert.h>
#include <math.h>
#include <stdbool.h>

#include "lib.h"

#define RUN(filename, action) pfile=fopen(filename,"a"); action; fclose(pfile);
#define NL(filename) pfile=fopen(filename,"a"); fprintf(pfile,"\n"); fclose(pfile);
#define N 50

char *filename_1 =  "salida.caso1.txt";
char *filename_2 =  "salida.caso2.txt";
char *filename_3 =  "salida.caso3.txt";
void test_1();
void test_2();
void test_3();

int main() {
    srand(12345);
    remove(filename_1);
    test_1();
    remove(filename_2);
    test_2();
    remove(filename_3);
    test_3();  
    return 0;
}

char* strings[10] = {"aa","bb","dd","ff","00","zz","cc","ee","gg","hh"};

/** STRINGS **/
void test_strings(FILE *pfile) {
    char *a, *b, *c;
    // clone
    fprintf(pfile,"==> Clone\n");
    a = strClone("casa");
    b = strClone("");
    strPrint(a,pfile);
    fprintf(pfile,"\n");
    strPrint(b,pfile);
    fprintf(pfile,"\n");
    strDelete(a);
    strDelete(b);
    // concat
    fprintf(pfile,"==> Concat\n");
    a = strClone("perro_");
    b = strClone("loco");
    fprintf(pfile,"%i\n",strLen(a));
    fprintf(pfile,"%i\n",strLen(b));
    c = strConcat(a,b);
    strPrint(c,pfile);
    fprintf(pfile,"\n");
    c = strConcat(c,strClone(""));
    strPrint(c,pfile);
    fprintf(pfile,"\n");
    c = strConcat(strClone(""),c);
    strPrint(c,pfile);
    fprintf(pfile,"\n");
    c = strConcat(c,c);
    strPrint(c,pfile);
    fprintf(pfile,"\n");
    // Substring
    fprintf(pfile,"==> Substring\n");
    fprintf(pfile,"%i\n",strLen(c));
    int h = strLen(c);
    for(int i=0; i<h+1; i++) {
        for(int j=0; j<h+1; j++) {    
            a = strClone(c);
            a = strSubstring(a,i,j);
            strPrint(a,pfile);
            fprintf(pfile,"\n");
            strDelete(a);
        }
        fprintf(pfile,"\n");
    }
    strDelete(c);
    // cmp
    fprintf(pfile,"==> Cmp\n");
    char* texts[5] = {"sar","23","taaa","tbb","tix"};
    for(int i=0; i<5; i++) {
        for(int j=0; j<5; j++) {
            fprintf(pfile,"cmp(%s,%s) -> %i\n",texts[i],texts[j],strCmp(texts[i],texts[j]));
        }
    }
}

/** List **/
void test_list(FILE *pfile) {
    char *a, *b, *c;
    list_t* l1;
    // listAddFirst
    fprintf(pfile,"==> listAddFirst\n");
    l1 = listNew();    
    listPrint(l1,pfile,(funcPrint_t*)&strPrint); fprintf(pfile,"\n");
    listPrintReverse(l1,pfile,(funcPrint_t*)&strPrint); fprintf(pfile,"\n");
    listAddFirst(l1,strClone("PRIMERO"));
    listPrint(l1,pfile,(funcPrint_t*)&strPrint); fprintf(pfile,"\n");
    listPrintReverse(l1,pfile,(funcPrint_t*)&strPrint); fprintf(pfile,"\n");
    listDelete(l1,(funcDelete_t*)&strDelete);
    l1 = listNew();
    listAddFirst(l1,strClone("PRIMERO"));
    listAddFirst(l1,strClone("PRIMERO"));
    listPrint(l1,pfile,(funcPrint_t*)&strPrint); fprintf(pfile,"\n");
    listPrintReverse(l1,pfile,(funcPrint_t*)&strPrint); fprintf(pfile,"\n");
    listDelete(l1,(funcDelete_t*)&strDelete);
    l1 = listNew();
    listAddFirst(l1,strClone("PRIMERO"));
    listAddFirst(l1,strClone("PRIMERO"));
    listAddFirst(l1,strClone("PRIMERO"));
    listPrint(l1,pfile,(funcPrint_t*)&strPrint); fprintf(pfile,"\n");
    listPrintReverse(l1,pfile,(funcPrint_t*)&strPrint); fprintf(pfile,"\n");
    listDelete(l1,(funcDelete_t*)&strDelete);
    // listAddLast
    fprintf(pfile,"==> listAddLast\n");
    l1 = listNew();
    listAddLast(l1,strClone("ULTIMO"));
    listPrint(l1,pfile,(funcPrint_t*)&strPrint); fprintf(pfile,"\n");
    listPrintReverse(l1,pfile,(funcPrint_t*)&strPrint); fprintf(pfile,"\n");
    listDelete(l1,(funcDelete_t*)&strDelete);
    l1 = listNew();
    listAddLast(l1,strClone("ULTIMO"));
    listAddLast(l1,strClone("ULTIMO"));
    listPrint(l1,pfile,(funcPrint_t*)&strPrint); fprintf(pfile,"\n");
    listPrintReverse(l1,pfile,(funcPrint_t*)&strPrint); fprintf(pfile,"\n");
    listDelete(l1,(funcDelete_t*)&strDelete);
    l1 = listNew();
    listAddLast(l1,strClone("ULTIMO"));
    listAddLast(l1,strClone("ULTIMO"));
    listAddLast(l1,strClone("ULTIMO"));
    listPrint(l1,pfile,(funcPrint_t*)&strPrint); fprintf(pfile,"\n");
    listPrintReverse(l1,pfile,(funcPrint_t*)&strPrint); fprintf(pfile,"\n");
    listDelete(l1,(funcDelete_t*)&strDelete);
    // listAdd
    fprintf(pfile,"==> listAdd\n");
    l1 = listNew();
    for(int i=0; i<5;i++)
        listAdd(l1,strClone(strings[i]),(funcCmp_t*)&strCmp);
    listAddFirst(l1,strClone("PRIMERO"));
    listAddLast(l1,strClone("ULTIMO"));
    listPrint(l1,pfile,(funcPrint_t*)&strPrint); fprintf(pfile,"\n");
    listPrintReverse(l1,pfile,(funcPrint_t*)&strPrint); fprintf(pfile,"\n");
    listDelete(l1,(funcDelete_t*)&strDelete);
    l1 = listNew();
    listAddFirst(l1,strClone("PRIMERO"));
    listAddLast(l1,strClone("ULTIMO"));
    for(int i=0; i<5;i++)
        listAdd(l1,strClone(strings[i]),(funcCmp_t*)&strCmp);
    listPrint(l1,pfile,(funcPrint_t*)&strPrint); fprintf(pfile,"\n");
    listPrintReverse(l1,pfile,(funcPrint_t*)&strPrint); fprintf(pfile,"\n");
    listDelete(l1,(funcDelete_t*)&strDelete);
    // listRemove
    fprintf(pfile,"==> listRemove\n");
    l1 = listNew();
    listRemove(l1, strings[0], (funcCmp_t*)&strCmp, (funcDelete_t*)&strDelete);
    for(int i=0; i<5;i++) {
        listAdd(l1,strClone(strings[i]),(funcCmp_t*)&strCmp);
        listRemove(l1, strings[0], (funcCmp_t*)&strCmp, (funcDelete_t*)&strDelete);
    }
    listRemove(l1, strings[1], (funcCmp_t*)&strCmp, (funcDelete_t*)&strDelete);
    listAddFirst(l1,strClone("PRIMERO"));
    listRemove(l1, strings[2], (funcCmp_t*)&strCmp, (funcDelete_t*)&strDelete);
    listAddLast(l1,strClone("ULTIMO"));
    listRemove(l1, "PRIMERO", (funcCmp_t*)&strCmp, (funcDelete_t*)&strDelete);
    listRemove(l1, "ULTIMO", (funcCmp_t*)&strCmp, (funcDelete_t*)&strDelete);
    listPrint(l1,pfile,(funcPrint_t*)&strPrint); fprintf(pfile,"\n");
    listPrintReverse(l1,pfile,(funcPrint_t*)&strPrint); fprintf(pfile,"\n");
    listDelete(l1,(funcDelete_t*)&strDelete);
    // listRemoveFirst
    fprintf(pfile,"==> listRemoveFirst\n");
    l1 = listNew();
    listRemoveFirst(l1, (funcDelete_t*)&strDelete);
    for(int i=0; i<5;i++)
        listAdd(l1,strClone(strings[i]),(funcCmp_t*)&strCmp);
    listRemoveFirst(l1, (funcDelete_t*)&strDelete);
    listAddFirst(l1,strClone("PRIMERO"));
    listRemoveFirst(l1, (funcDelete_t*)&strDelete);
    listAddLast(l1,strClone("ULTIMO"));
    listRemoveFirst(l1, (funcDelete_t*)&strDelete);
    listRemoveFirst(l1, (funcDelete_t*)&strDelete);
    listPrint(l1,pfile,(funcPrint_t*)&strPrint); fprintf(pfile,"\n");
    listPrintReverse(l1,pfile,(funcPrint_t*)&strPrint); fprintf(pfile,"\n");
    listDelete(l1,(funcDelete_t*)&strDelete);
    // listRemoveLast
    fprintf(pfile,"==> listRemoveLast\n");
    l1 = listNew();
    listRemoveLast(l1, (funcDelete_t*)&strDelete);
    for(int i=0; i<5;i++)
        listAdd(l1,strClone(strings[i]),(funcCmp_t*)&strCmp);
    listRemoveLast(l1, (funcDelete_t*)&strDelete);
    listAddFirst(l1,strClone("PRIMERO"));
    listRemoveLast(l1, (funcDelete_t*)&strDelete);
    listAddLast(l1,strClone("ULTIMO"));
    listRemoveLast(l1, (funcDelete_t*)&strDelete);
    listRemoveLast(l1, (funcDelete_t*)&strDelete);
    listPrint(l1,pfile,(funcPrint_t*)&strPrint); fprintf(pfile,"\n");
    listPrintReverse(l1,pfile,(funcPrint_t*)&strPrint); fprintf(pfile,"\n");
    listDelete(l1,(funcDelete_t*)&strDelete);
    // listRemove listRemoveFirst listRemoveLast
    fprintf(pfile,"==> listRemove listRemoveFirst listRemoveLast\n");
    l1 = listNew();
    listRemove(l1, strings[2], (funcCmp_t*)&strCmp, 0);
    listRemoveFirst(l1, 0);
    listRemoveLast(l1, 0);
    char* stringsLocal[10];
    for(int i=0; i<10;i++)
        stringsLocal[i] = strClone(strings[i]);
    for(int i=0; i<10;i++)
        listAdd(l1,stringsLocal[i],(funcCmp_t*)&strCmp);
    listPrint(l1,pfile,(funcPrint_t*)&strPrint); fprintf(pfile,"\n");
    listPrintReverse(l1,pfile,(funcPrint_t*)&strPrint); fprintf(pfile,"\n");
    listRemove(l1, strings[2], (funcCmp_t*)&strCmp, 0);
    listPrint(l1,pfile,(funcPrint_t*)&strPrint); fprintf(pfile,"\n");
    listPrintReverse(l1,pfile,(funcPrint_t*)&strPrint); fprintf(pfile,"\n");
    listRemoveLast(l1, 0);
    listPrint(l1,pfile,(funcPrint_t*)&strPrint); fprintf(pfile,"\n");
    listPrintReverse(l1,pfile,(funcPrint_t*)&strPrint); fprintf(pfile,"\n");
    listRemoveFirst(l1, 0);
    listPrint(l1,pfile,(funcPrint_t*)&strPrint); fprintf(pfile,"\n");
    listPrintReverse(l1,pfile,(funcPrint_t*)&strPrint); fprintf(pfile,"\n");
    listRemoveLast(l1, 0);
    listPrint(l1,pfile,(funcPrint_t*)&strPrint); fprintf(pfile,"\n");
    listPrintReverse(l1,pfile,(funcPrint_t*)&strPrint); fprintf(pfile,"\n");
    listRemove(l1, strings[2], (funcCmp_t*)&strCmp, 0);
    listPrint(l1,pfile,(funcPrint_t*)&strPrint); fprintf(pfile,"\n");
    listPrintReverse(l1,pfile,(funcPrint_t*)&strPrint); fprintf(pfile,"\n");
    listRemoveFirst(l1, 0);
    listPrint(l1,pfile,(funcPrint_t*)&strPrint); fprintf(pfile,"\n");
    listPrintReverse(l1,pfile,(funcPrint_t*)&strPrint); fprintf(pfile,"\n");
    listRemoveLast(l1, 0);
    listPrint(l1,pfile,(funcPrint_t*)&strPrint); fprintf(pfile,"\n");
    listPrintReverse(l1,pfile,(funcPrint_t*)&strPrint); fprintf(pfile,"\n");
    listRemoveFirst(l1, 0);
    listPrint(l1,pfile,(funcPrint_t*)&strPrint); fprintf(pfile,"\n");
    listPrintReverse(l1,pfile,(funcPrint_t*)&strPrint); fprintf(pfile,"\n");
    listRemove(l1, strings[2], (funcCmp_t*)&strCmp, 0);
    listPrint(l1,pfile,(funcPrint_t*)&strPrint); fprintf(pfile,"\n");
    listPrintReverse(l1,pfile,(funcPrint_t*)&strPrint); fprintf(pfile,"\n");
    listDelete(l1,0);
    for(int i=0; i<10;i++)
        free(stringsLocal[i]);
}

/** hashTable **/
void test_hashTable(FILE *pfile) {
    char *a, *b, *c;
    hashTable_t *n;
    // strHash
    fprintf(pfile,"==> strHash\n");
    fprintf(pfile,"abeja=%i\n", strHash("abeja"));
    fprintf(pfile,"arco=%i\n", strHash("arco"));
    fprintf(pfile,"casa=%i\n", strHash("casa"));
    fprintf(pfile,"dado=%i\n", strHash("dado"));
    // hashTableAdd
    fprintf(pfile,"==> hashTableAdd\n");
    n = hashTableNew(32, (funcHash_t*)&strHash);
    for(int s=0;s<64;s++) {
        for(int i=0;i<10;i++) {
            hashTableAdd(n, strClone(strings[i]));}}
    // hashTableRemoveAll
    fprintf(pfile,"==> hashTableRemoveAll\n");
    for(int i=5;i<10;i++) {
        a = strClone(strings[i]);
        hashTableRemoveAll(n,a,(funcCmp_t*)&strCmp,(funcDelete_t*)&strDelete);
        strDelete(a);}
    // hashTableDeleteSlot
    fprintf(pfile,"==> hashTableDeleteSlot\n");
    for(int i=50;i<56;i++) {
        hashTableDeleteSlot(n,i,(funcDelete_t*)&strDelete);}
    hashTablePrint(n,pfile,(funcPrint_t*)&strPrint);
    hashTableDelete(n,(funcDelete_t*)&strDelete);
}

void test_1(char* filename){
    FILE *pfile;
    RUN(filename,test_strings(pfile););
    RUN(filename,test_list(pfile););
    RUN(filename,test_hashTable(pfile););
}

void test_2(char* filename){
    FILE *pfile;
    char *text[20] = {"aA","bB","1234","ffff","oiuytre","dfsd","ss","qw","pp","PP",
                      "","d9","i9","uU","KLA","8","yYy","lla","yaff","9"};
    list_t* l   = listNew();
    hashTable_t *n = hashTableNew(32, (funcHash_t*)&strHash);
    RUN(filename, listPrint(l, pfile, (funcPrint_t*)&strPrint);)NL(filename)
    RUN(filename, hashTablePrint(n, pfile, (funcPrint_t*)&strPrint);)NL(filename)
    for(int s=0;s<40;s++) {
        for(int i=0;i<20;i++) {
            for(int j=0;j<20;j++) {
                listAdd(l, strConcat(strClone(text[i]), strClone(text[j])), (funcCmp_t*)&strCmp);
                hashTableAdd(n,strConcat(strClone(text[i]), strClone(text[j])));
            }}}
    RUN(filename, listPrint(l, pfile, (funcPrint_t*)&strPrint);)NL(filename)
    RUN(filename, hashTablePrint(n, pfile, (funcPrint_t*)&strPrint);)NL(filename)
    for(int i=0;i<20;i=i+2) {
        for(int j=0;j<20;j=j+2) {
            char* a = strConcat(strClone(text[i]), strClone(text[j]));
            listRemove(l, a, (funcCmp_t*)&strCmp, (funcDelete_t*)&strDelete);
            hashTableRemoveAll(n, a, (funcCmp_t*)&strCmp, (funcDelete_t*)&strDelete);
            strDelete(a);
        }}
    RUN(filename, listPrint(l, pfile, (funcPrint_t*)&strPrint);)NL(filename)
    RUN(filename, hashTablePrint(n, pfile, (funcPrint_t*)&strPrint);)NL(filename)
    listDelete(l, (funcDelete_t*)&strDelete);
    hashTableDelete(n, (funcDelete_t*)&strDelete);
}

char* randomString(uint32_t l) {
    // 32 a 126 = caracteres validos
    char* s = malloc(l+1);
    for(uint32_t i=0; i<(l+1); i++)
       s[i] = (char)(33+(rand()%(126-33)));
    s[l] = 0;
    return s;
}

void test_3(char* filename){
    FILE *pfile;
    list_t* l   = listNew();
    hashTable_t *n = hashTableNew(32, (funcHash_t*)&strHash);
    RUN(filename, listPrint(l, pfile, (funcPrint_t*)&strPrint);)NL(filename)
    RUN(filename, hashTablePrint(n, pfile, (funcPrint_t*)&strPrint);)NL(filename)
    for(int s=0;s<40;s++) {
        for(int i=0;i<1000;i++) {
                listAdd(l, randomString(rand()%10+1), (funcCmp_t*)&strCmp);
                hashTableAdd(n, randomString(rand()%10+1));
            }}
    RUN(filename, listPrint(l, pfile, (funcPrint_t*)&strPrint);)NL(filename)
    RUN(filename, hashTablePrint(n, pfile, (funcPrint_t*)&strPrint);)NL(filename)
    for(int i=0;i<1000;i++) {
            char* a = randomString(rand()%3+1);
            listRemove(l, a, (funcCmp_t*)&strCmp, (funcDelete_t*)&strDelete);
            hashTableRemoveAll(n, a, (funcCmp_t*)&strCmp, (funcDelete_t*)&strDelete);
            strDelete(a);
    }
    RUN(filename, listPrint(l, pfile, (funcPrint_t*)&strPrint);)NL(filename)
    RUN(filename, hashTablePrint(n, pfile, (funcPrint_t*)&strPrint);)NL(filename)
    listDelete(l, (funcDelete_t*)&strDelete);
    hashTableDelete(n, (funcDelete_t*)&strDelete);
}
