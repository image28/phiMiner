#!/bin/bash

# programs and flags
CUR=`pwd`  
GCC="/usr/bin/gcc"
CFLAGS="-v -Wno-error=parentheses -DDEBUG -DPROFILING -g"
LIBS="-L/usr/lib -lOpenCL -lpthread -lcrypto -g " # 
INC="-I. -I/usr/include"

./update\ prototypes main.c 
# OPENCL KERNEL
$CUR/cl2h.sh "ethash.cl" "ethash.h"
# Miner
$GCC -g $INC $CFLAGS main.c -g -o ../bin/phiMiner $LIBS 
#strip --strip-debug --strip-unneeded ./bin/phiMiner
