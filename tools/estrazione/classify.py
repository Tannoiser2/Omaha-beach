import json
T=json.load(open('terrain_raw.json'))
def cls(f):
    land=1-f['mare']
    if f['mare']>0.8: return 'mare'
    if f['accidentato']>0.3: return 'accidentato'
    if f['bosco']>0.3: return 'bosco'
    sp=f['spiaggia']+f['linea']; pa=f['pianoro']
    alt=f['altura']+f['bocage']
    if sp+pa> alt and sp+pa>0.25:
        return 'pianoro' if pa>sp else 'spiaggia'
    if f['bocage']>0.05: return 'bocage'
    if alt>0.2: return 'altura'
    if f['mare']>0.4: return 'mare'
    return '?'
C={h:cls(f) for h,f in T.items()}
B={h for h,f in T.items() if f['bianco']>0.04}
json.dump(dict(cls=C,edifici=sorted(B)),open('terrain_cls.json','w'))
