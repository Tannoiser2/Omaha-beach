import json
new=json.load(open('new.json'))
old=json.load(open('/home/claude/omaha-beach/data/mappa.json'))['strade']
H=json.load(open('/home/claude/omaha-beach/data/mappa.json'))['hexes']
def k(a,b): return '|'.join(sorted([a,b]))
s=dict(new)
for kk in old:
    if kk not in s: s[kk]='T'
# rimuovi M rilevate
for kk in list(s):
    if s[kk]=='M': s[kk]='T'
def path(seq,t):
    hs=seq.split()
    for a,b in zip(hs,hs[1:]):
        assert a in H and b in H,(a,b)
        s[k(a,b)]=t
P="""1410 1511 1611 1612 1513 1514 1515 1516 1517 1417 1418 1419 1320 1321 1322 1323 1223 1224 1125 1126 1026 1027 0928 0929 0930
1001 1002 1103 1104 1105 1106 1207 1308 1309 1409 1410
2022 1922 1921 1821 1721 1621 1521 1421 1321
2025 1925 1825 1726 1625 1526 1426 1327 1328 1329 1229 1130 1029 0930 0830 0831 0832 0833 0834 0735 0635"""
for l in P.splitlines(): path(l,'P')
S="""1902 1802 1703 1603 1503 1403 1303 1203 1103
2016 1916 1815 1814 1714 1713 1612
2015 1916
1727 1627 1628 1529 1530 1531 1532 1533 1433 1434 1435
1321 1220 1121
1220 1120 1119
1410 1310 1311
1320 1219 1119
1320 1220
1121 1022
1825 1826 1727
0925 0825 0826 0827 0828 0829 0830"""
for l in S.splitlines(): path(l,'S')
M="""1311 1211 1112 1011 0911 0811
1022 0923 0822 0723
0830 0731 0630 0530"""
for l in M.splitlines(): path(l,'M')
s[k('0811','0812')]='T'
for kk in ['2000|2001','2001|2002','2034|2035','2035|2036','0201|0202']: s.pop(kk,None)
json.dump(s,open('final.json','w'))
# componenti P/S/M
adj={}
for kk,t in s.items():
    if t=='T': continue
    a,b=kk.split('|'); adj.setdefault(a,[]).append(b); adj.setdefault(b,[]).append(a)
seen=set();comps=[]
for h in adj:
    if h in seen: continue
    st=[h];c={h};seen.add(h)
    while st:
        x=st.pop()
        for v in adj[x]:
            if v not in seen: seen.add(v);c.add(v);st.append(v)
    comps.append(sorted(c))
comps.sort(key=len,reverse=True)
for c in comps: print(len(c),c if len(c)<12 else c[:12])
