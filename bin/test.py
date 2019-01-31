#!/usr/bin/python



import sys

import numpy as np

def ellipse_angle_degrees(phi):
    yang = np.cos(phi)
    xang = np.sin(phi)
    
    return ((90 + 0.5 * np.arctan2(yang ,xang )) * 180 / np.pi) % 180

a = np.arange(-np.pi,np.pi,1)



angle = ellipse_angle_degrees(a)


print angle