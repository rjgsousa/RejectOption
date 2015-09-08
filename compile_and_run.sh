#!/bin/sh
DATASETID=synthetic51

rm -rvf bin/*

mcc -m -T link:exe reject.m -I ../libraries -I oSVM/ -I ../libraries/qpc/binaries -I ../libraries/libsvm/libsvm-mat-2.89-1/binaries/ -I threshold/ -I weights/ -d bin/

#./bin/reject threshold $DATASETID > log_CPU1.log &
#sleep 5
#./bin/reject weights   $DATASETID > log_CPU2.log &
#sleep 5
#./bin/reject osvm      $DATASETID > log_CPU3.log &
./bin/reject osvm_plus     $DATASETID > log_CPU4.log &
