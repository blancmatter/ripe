
#from pylab import *
import sys
import math

q_obs = float(str(sys.argv[1]))
u_obs = float(str(sys.argv[2]))

q_err = float(str(sys.argv[3]))
u_err = float(str(sys.argv[4]))

print "Input parameters:" 
print "q=",q_obs
print "u=",u_obs
print "q_err=",q_err
print "u_err=",u_err

p_obs = sqrt(q_obs*q_obs+u_obs*u_obs)

for q_percent in xrange(30):

    q_val = q_percent / 100.0

    q = q_val + randn(10000)*q_err

    u=randn(10000)*u_err

    p = sqrt(u*u+q*q)

    print "A q_val of ",q_val,"gives a mean p of",mean(p)

    lower=percentile(p,16)  
    upper=percentile(p,84)

    print "The measured polarization is",p_obs
    print "The one sigma limits are at",lower,"and",upper

    if p_obs>lower and p_obs<upper:
       print "*** q_val of ",q_val,"is allowed"

    print