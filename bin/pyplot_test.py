#!/usr/bin/python


import sys
import numpy as np
import matplotlib.pyplot as plt
import time




ax = plt.gca()
ax.spines['right'].set_color('none')
ax.spines['top'].set_color('none')
ax.xaxis.set_ticks_position('bottom')
ax.spines['bottom'].set_position(('data',0))
ax.yaxis.set_ticks_position('left')
ax.spines['left'].set_position(('data',0))

x = float(sys.argv[1])
y = float(sys.argv[2])
x_err = float(sys.argv[3]) 
y_err = float(sys.argv[4])

plt.axis([-0.5, 0.5, -0.5, 0.5])
plt.xticks([-0.5, -0.4, -0.3, -0.2, -0.1, 0.1, 0.2, 0.3, 0.4, 0.5])
plt.yticks([-0.5, -0.4, -0.3, -0.2, -0.1, 0.1, 0.2, 0.3, 0.4, 0.5])
plt.gca().set_aspect('equal', adjustable='box')


circle1=plt.Circle((0,0),.1,color='0.8',fill=False)
circle2=plt.Circle((0,0),.2,color='0.8',fill=False)
circle3=plt.Circle((0,0),.3,color='0.8',fill=False)
circle4=plt.Circle((0,0),.4,color='0.8',fill=False)

fig = plt.gcf()
fig.gca().add_artist(circle1)
fig.gca().add_artist(circle2)
fig.gca().add_artist(circle3)
fig.gca().add_artist(circle4)



plt.errorbar(x, y, xerr=0.02, yerr=0.04)

#plt.plot(x, y2)



#plt.show()


filename = 'myplot'
plt.savefig(filename + '.pdf',format = 'pdf', transparent=True)




time.sleep(5)
plt.plot(x, y, 'o')
plt.savefig(filename + '.pdf',format = 'pdf', transparent=True)