#include <stdio.h>

int divide10(int* n){
    int a = *n;
    *n = 0;
    while(a >= 0){
        a -= 10;
        (*n)++;
    }

    a += 10;
    (*n)--;

    return a;
}

void displayA(int* n){
    int rem;
    while(*n != 0){
        rem = divide10(n);
        printf("%d", rem);
    }
}

int main(){
    int a = 256;

    //printf("%d", divide10(&a));

    displayA(&a);


    return 0;
}