import cv2, numpy as np, sys
sys.path.insert(0,'/home/claude/src/work')
from grid import *
IMG=cv2.imread('/home/claude/src/mod/Mods/Images/httpssteamusercontentaakamaihdnetugc102620265285965100533DDA44DA90E280CACC5597E492098D72B57967B.jpg')
RGB=cv2.cvtColor(IMG,cv2.COLOR_BGR2RGB).astype(int)
