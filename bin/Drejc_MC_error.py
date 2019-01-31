#!/usr/bin/python
#

import math
import sys
import numpy as np
from numpy import *

#def randnorm(a,b):
#	num = a + b * math.sqrt(-2.0 * math.log(np.random.rand())) * math.cos(2.0 * math.pi * np.random.rand())
#	return num

iterations = 1000
p_min = 1.0
p_max = 0.0
 
q_val = float(sys.argv[1])
u_val = float(sys.argv[2])
q_err = float(sys.argv[3])
u_err = float(sys.argv[4])

vector = u_val/q_val
p_val = math.sqrt(q_val*q_val + u_val*u_val)

for i in range(0,101):
	q_sim = i/100.0
	u_sim = q_sim * vector
	p_sim = math.sqrt(q_sim*q_sim + u_sim*u_sim)
	q_array = []
	u_array = []
	p_array = []
	for j in range(0,iterations):
		q_array.append(q_sim + np.random.normal(0,1,size=None)*q_err)
		u_array.append(u_sim + np.random.normal(0,1,size=None)*u_err)
		#q_array.append(randnorm(q_sim,q_err))
		#u_array.append(randnorm(u_sim,u_err))
		p_array.append(math.sqrt(q_array[-1]*q_array[-1] + u_array[-1]*u_array[-1])) #[-1] means the last added value to the list
	
	p_array_sort = sorted(p_array)
	p_sim_lower = p_sim - p_array_sort[int(round(0.1587 * iterations))] #this is unused?
	p_sim_upper = p_array_sort[int(round(0.8413 * iterations))] - p_sim  #this is unused?
	
	if (p_array_sort[int(0.1587 * iterations)] < p_val) and (p_array_sort[int(0.8413 * iterations)] > p_val):
		if p_sim > p_max: p_max = p_sim
		if p_sim < p_min: p_min = p_sim
	
if (p_max == 0.0) and (p_min == 1.0): p_min = 0.0

if (p_max < p_val): p_max = p_val + q_err

p_err_lower = p_val - p_min
p_err_upper = p_max - p_val

print p_val, p_err_lower, p_err_upper
