#!/usr/bin/python

import re,string
from numpy import *
from pylab import *

name = "fuzzy9/Resultado_Dataset1_75treino_25teste_9FuncFuzzy"
nameout = "fuzzy15_error_vs_reject"

print name+'.txt'
fd = open(name+'.txt');

lines = fd.readlines();
result = [];
vec = [0,0,0,0]
count = 0
for i in lines:
	#print i
	res0 = re.search("TX. REJEICAO",i)
	if res0 != None:
		count = count + 1
		res0  = i.split(':')
		vec[0] = float(res0[1].strip())
		result.append(vec)
		vec = [0,0,0,0]
		continue
	res1 = re.search("ACCURACY",i)
	if res1 != None:
		res0  = i.split(':')
		vec[1] = 1-float(res0[1].strip())
		continue

# closes descriptor
fd.close();

result = array(result)

savetxt(nameout+'.csv', result,fmt='%.6f',delimiter=',')
print result


