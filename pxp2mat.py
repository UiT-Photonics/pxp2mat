#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Wed Jan  3 14:28:49 2024
igor2's cli didn't quite work when i tried it so this is just a wrapper.
absolutely no error checking or any other type of safety stuff. just plows
straight ahead and tries to store all scalars and waverecords in a dict and
then writes them to a mat. anything that's not either of those two types is
simply ignored. also the keys are just used straight up, so if you have any
funky characters in them matlab will be sad.

@author: ragnar.seton@uit.no
"""
import sys
import numpy as np
from os.path import splitext
from igor2.packed import load as loadpxp
from igor2.record.wave import WaveRecord
from scipy.io import savemat

# these two could be replaced with a logger or something
def fail(msg):
    print(msg, file = sys.stderr)
    sys.exit()

def warn(msg):
    print(msg, file = sys.stderr)

# the "converter"...
def pxp2mat(fn):
    d = loadpxp(fn)[1]['root'] or fail("Failed to load {0}".format(fn))
    mdict = {}
    for k,v in d.items():
        if isinstance(k, bytes):
            k = k.decode()
        if np.isscalar(v):
            mdict[k] = v
        elif isinstance(v, WaveRecord):
            mdict[k] = {
                'type': 'wave',
                'data': v.wave['wave']['wData'],
                'formula': v.wave['wave']['formula'],
                'data_units': v.wave['wave']['data_units'],
                'dim_units': v.wave['wave']['dimension_units'],
                'labels': v.wave['wave']['labels'],
                'indices': v.wave['wave']['sIndices']
                }
        else:
            warn("Unknown value format '{0}' for key '{1}".format(type(v), k))
    matfn = splitext(fn)[0]+".mat"
    savemat(matfn, mdict) or fail("Failed to save dict to {0}".format(matfn))
    


if __name__ == '__main__':
    if len(sys.argv) < 2:
        fail("You need to supply at least one filename of a pxp.")
    for fn in sys.argv[1:]:
        pxp2mat(fn)

