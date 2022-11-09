/*
 *  Copyright (C) TetroLabs Inc.
    All rights reserved

 */

#include <stdio.h>

// #include "memory.h"

#include "../devices/vga.h"
#include "init/init.h"
#include "sysinfo.h"
#include <api/input.h>




int main(void) {

    start_init();

    printf("%s %s\n\n", OS_NAME, OS_VERSION);

    get_input();
    
} 
