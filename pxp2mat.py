#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Wed Jan  3 14:28:49 2024
igor2's cli didn't quite work when i tried it so this is just a wrapper.
absolutely no error checking or any other type of safety stuff. doesn't parse
all the different records, nor parses the ones it does particularly well.

@author: ragnar.seton@uit.no
"""
import sys
import numpy as np
from os.path import splitext
from igor2.packed import load as loadpxp
from igor2 import record as r
from scipy.io import savemat

# these two could be replaced with a logger or something
def fail(msg):
    print(msg, file = sys.stderr)
    sys.exit()

def warn(msg):
    print(msg, file = sys.stderr)

# the "converter"...
def pxp2mat(fn):
    d = loadpxp(fn)[0] or fail("Failed to load {0}".format(fn))
    md = []
    meta = []
    for e in d:
        if isinstance(e, r.WaveRecord):
            md.append(waveRec2md(e))
        elif isinstance(e, r.VariablesRecord):
            md.append(variablesRec2md(e))
        elif isinstance(e, r.HistoryRecord):
            md.append(historyRec2md(e))
        elif isinstance(e, r.PackedFileRecord):
            md.append(packedFileRec2md(e))
        else:
            warn("Dunno how to parse record '{0}'".format(type(e)))
            continue
        meta.append(md[-1]['type'])
    matfn = splitext(fn)[0]+".mat"
    try:
        savemat(matfn, {'records': np.asarray(md, dtype=object), 'meta': meta})
    except:
        fail("Saving '{0}' failed: {1}".format(matfn, sys.exc_info()[1]))

def waveRec2md(wr):
    # i'm just assuming that the prefix for name indicated that it's always bytes
    return {
            'type': 'wave',
            'name': wr.wave['wave']['wave_header']['bname'].decode(),
            'data': wr.wave['wave']['wData'],
            'formula': wr.wave['wave']['formula'],
            'data_units': wr.wave['wave']['data_units'],
            'dim_units': wr.wave['wave']['dimension_units'],
            'labels': wr.wave['wave']['labels'],
            'indices': wr.wave['wave']['sIndices']
        }

def variablesRec2md(vr):
    return {
        'type': 'variables',
        'sysVars': pxpDict2md(vr.variables['variables']['sysVars']),
        'userVars': pxpDict2md(vr.variables['variables']['userVars'])
        }

def historyRec2md(hr):
    return {
        'type': 'history',
        'text': hr.text.decode()
        }

def packedFileRec2md(pfr):
    # TODO: parse some shit here
    return {
        'type': 'packedFile',
        'data': pfr.data.decode()
        }

def pxpDict2md(pd):
    md = {}
    for k,v in pd.items():
        if isinstance(k, bytes):
            k = k.decode()
        if np.isscalar(v) or isinstance(v, np.ndarray):
            md[k] = v
        elif isinstance(v, dict):
            md[k] = pxpDict2md(v)
        else:
            warn("Unknown value format '{0}' for key '{1}".format(type(v), k))
    return md
        

if __name__ == '__main__':
    if len(sys.argv) < 2:
        fail("You need to supply at least one filename of a pxp.")
    for fn in sys.argv[1:]:
        pxp2mat(fn)

