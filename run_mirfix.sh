#!/bin/bash

tto=$1

python2 MIRfix_test.py 2 /homes/biertank/cristian/workspace/MIRfix_V2/RUNexample/output/ /homes/biertank/cristian/workspace/MIRfix_V2/RUNexample/Families/ /homes/biertank/cristian/workspace/MIRfix_V2/RUNexample/${tto}_list.txt /homes/biertank/cristian/workspace/MIRfix_V2/RUNexample/${tto}_genomes_list.txt /homes/biertank/cristian/workspace/MIRfix_V2/RUNexample/${tto}_mappingtest.txt /homes/biertank/cristian/workspace/MIRfix_V2/RUNexample/${tto}_maturetest.fa 10
