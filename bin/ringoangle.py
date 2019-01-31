#!/usr/bin/python

from pylab import *
import sys
import math



def ringo_angle_error(q_obs, u_obs, q_err, u_err):

   theta_obs = degrees(0.5*arctan2(u_obs,q_obs)) % 180
   
   #   print "Theta Observed=",theta_obs

   good_thetas=[]

   q_min=q_obs-1.5*q_err
   q_max=q_obs+1.5*q_err
   u_min=u_obs-1.5*u_err
   u_max=u_obs+1.5*u_err

   t1 = degrees(0.5*arctan2(u_min,q_min)) % 180
   t2 = degrees(0.5*arctan2(u_max,q_min)) % 180
   t3 = degrees(0.5*arctan2(u_min,q_max)) % 180
   t4 = degrees(0.5*arctan2(u_max,q_max)) % 180

   #print t1,t2,t3,t4

   tmin=min([t1,t2,t3,t4])
   tmax=max([t1,t2,t3,t4])

   if ((tmax-tmin)>90.0): # i.e. probably zero crossing
      temp=tmin
      tmin=tmax-180.0
      tmax=temp

      # print tmin,tmax

      
   for theta in arange(tmin,tmax,0.1):
      #for theta in arange(0.0,179.9,0.1):
      q_val = cos(radians(2*theta)) * sqrt(u_obs*u_obs+q_obs*q_obs)
      u_val = sin(radians(2*theta)) * sqrt(u_obs*u_obs+q_obs*q_obs)
      
      #      print "Theta=",theta,"q_val=",q_val,"u_val=",u_val,"Derived Theta=",degrees(0.5*arctan2(u_val,q_val)) % 180

      q = q_val + randn(1000)*q_err
      u = u_val + randn(1000)*u_err

      t = degrees(0.5*arctan2(u,q)) % 180

      #    print "A q_val of ",q_val,"gives a mean theta of",mean(t)

      lower=percentile(t,16)
      middle=percentile(t,50)
      upper=percentile(t,84)

      #  if ((upper-lower)>90):
      #  temp=upper
      #   upper=lower+90
      #   lower=(upper+90) % 180
      #   t=(t+90) % 180

      #print "The measured theta is",theta_obs
      #print "The one sigma limits are at",lower,"and",upper

      if theta_obs>lower and theta_obs<upper:
         good_thetas.append(theta)
         
         

         #print good_thetas
   

   raw_theta = theta_obs

   corrected_theta=90.0
   lower_theta=0.0
   upper_theta=180.0
   
   if (len(good_thetas)!=0):
      corrected_theta=mean(good_thetas)
      lower_theta=min(good_thetas)
      upper_theta=max(good_thetas)

   return ([raw_theta,corrected_theta,lower_theta, upper_theta])



   

(raw_theta, corrected_theta, lower_theta, upper_theta) = ringo_angle_error(float(sys.argv[1]), float(sys.argv[2]), float(sys.argv[3]), float(sys.argv[4]))

print raw_theta, corrected_theta, lower_theta, upper_theta
