"""Controle les ZIP construits et les durees du pack audio de la 0.2.1."""
import hashlib
import io
import re
import wave
import zipfile
from pathlib import Path

root = Path(__file__).resolve().parents[1]
cfg = (root / 'sdcard/WIDGETS/JWAIO/config.lua').read_text(encoding='utf-8')
durations = dict((k, float(v)) for k,v in re.findall(r'(\w+)\s*=\s*([\d.]+)', cfg.split('soundDurations = {')[1].split('}')[0]))
sounds = dict(re.findall(r'(\w+)\s*=\s*"([^"]+)"', cfg.split('sounds = {')[1].split('}')[0]))
installer = root / 'outputs/JWAIO-v0.2.1.zip'
with zipfile.ZipFile(installer) as z:
    assert z.testzip() is None
    names = z.namelist()
    assert len(names) == len(set(names))
    assert not any('skins/' in n.lower() or 'culture' in n.lower() or n.endswith(('.luac','.csv')) for n in names)
    assert not any(n.endswith(('lastpos.txt','lastdistance.txt')) for n in names)
    assert z.read('WIDGETS/JWAIO/config.lua').decode('utf-8') == cfg
    for path in (root / 'sdcard').rglob('*'):
        if path.is_file(): assert z.read(path.relative_to(root / 'sdcard').as_posix()) == path.read_bytes(), path
    for key, name in sounds.items():
        payload = z.read('SOUNDS/fr/JWAIO/' + name + '.wav')
        with wave.open(io.BytesIO(payload)) as wav:
            assert (wav.getnchannels(), wav.getsampwidth(), wav.getframerate()) == (1,2,32000)
            actual = wav.getnframes()/wav.getframerate()
            assert actual <= durations[key] < actual + 0.03, (name,actual,durations[key])
    assert len([n for n in names if n.endswith('.wav')]) == 17
source = root / 'outputs/JWAIO-v0.2.1-SOURCE-BACKUP.zip'
with zipfile.ZipFile(source) as z:
    assert z.testzip() is None
    assert not any('__pycache__' in n or n.startswith(('work/','.git/')) or '/skins/' in n for n in z.namelist())
    for name in z.namelist():
        if not name.endswith('/'): assert z.read(name) == (root / name).read_bytes(), name
for path in [installer, source]:
    sha=hashlib.sha256(path.read_bytes()).hexdigest()
    assert Path(str(path)+'.sha256').read_text().split()[0]==sha
    print(path.name, path.stat().st_size, sha)
print('Release contents / privacy / audio durations / source consistency OK')
