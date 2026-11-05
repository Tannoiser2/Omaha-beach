import math
W=191.657; RS=169.55
SIZE=W/math.sqrt(3)  # circumradius
def center(r,c,dx=66.0):
    x=-10.093+W*c-95.949*(r%2)+dx
    y=4486.4-RS*r
    return x,y
def corners(r,c):
    x,y=center(r,c)
    return [(x+SIZE*math.cos(math.radians(60*i-30)), y+SIZE*math.sin(math.radians(60*i-30))) for i in range(6)]
SY=169.55/1.5
def corners(r,c):
    x,y=center(r,c)
    return [(x+SIZE*math.cos(math.radians(60*i-30)), y+SY*math.sin(math.radians(60*i-30))) for i in range(6)]
def pix2hex(px,py):
    best=None
    r0=round((4486.4-py)/169.55)
    for r in range(r0-1,r0+2):
        c0=round((px-66+10.093+95.949*(r%2))/W)
        for c in range(c0-1,c0+2):
            x,y=center(r,c); dd=(x-px)**2+((y-py)*SIZE/SY)**2
            if best is None or dd<best[0]: best=(dd,r,c)
    return best[1],best[2]
