#!/usr/bin/python


# Script to take 8 fits files of RINGO and output an average stack

import numpy
import pyfits
import sys


fits1, header_data = pyfits.getdata(sys.argv[1],0, header=True)
fits2 = pyfits.getdata(sys.argv[2],0)
fits3 = pyfits.getdata(sys.argv[3],0)
fits4 = pyfits.getdata(sys.argv[4],0)
fits5 = pyfits.getdata(sys.argv[5],0)
fits6 = pyfits.getdata(sys.argv[6],0)
fits7 = pyfits.getdata(sys.argv[7],0)
fits8 = pyfits.getdata(sys.argv[8],0)



combinedfits = (fits1 + fits2 + fits3 + fits4 + fits5 + fits6 +fits7 + fits8)

#print combinedfits


pyfits.writeto(sys.argv[9], combinedfits, header_data)

print sys.argv[9]
