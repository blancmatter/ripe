#!/usr/bin/python

from pylab import *
import sys
import math
import numpy

def ringo_pol_error(q_obs, u_obs, q_err, u_err):

   #print "Input parameters:" 
   #print "q=",q_obs
   #print "u=",u_obs
   #print "q_err=",q_err
   #print "u_err=",u_err

   c = u_obs/q_obs
   
   p_obs = sqrt(q_obs*q_obs+u_obs*u_obs)
   
   good_pols = [] # empty list
      
   for pol in arange(0.001,50.0,0.001):
      
      q_val = sqrt(pol*pol/(1+c*c))
      u_val = sqrt(pol*pol/(1+1/(c*c)))
      
      q=q_val+q_err*randn(1000)
      u=u_val+u_err*randn(1000)
      
      p = sqrt(u*u+q*q)
      
      lower=numpy.percentile(p,16)
      middle=numpy.percentile(p,50)
      upper=numpy.percentile(p,84)
      
      if p_obs>lower and p_obs<upper:
         good_pols.append(pol)


   raw_pol = p_obs
   corrected_pol=0.0
   upper_pol=0.0
   lower_pol=0.0
   
   if (len(good_pols)!=0):      
      corrected_pol = mean(good_pols)
      lower_pol = min(good_pols)
      upper_pol = max(good_pols)

   return([raw_pol, corrected_pol, lower_pol, upper_pol])



   

(raw_pol, corrected_pol, lower_pol, upper_pol) = ringo_pol_error(float(sys.argv[1]), float(sys.argv[2]), float(sys.argv[3]), float(sys.argv[4]))

print raw_pol, corrected_pol, lower_pol, upper_pol
