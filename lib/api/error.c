#include <stdio.h>
#include "error.h"


void print_error(char* str, int error_code){
    printf("[ERROR] ERR_CODE:%i ERR_DESC:%s",error_code,str);
}
