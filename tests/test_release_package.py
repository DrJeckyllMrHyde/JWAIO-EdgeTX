"""Controle de l'archive publique JWAIO 0.3_Alpha."""
import io
import struct
import wave
import zipfile
from pathlib import Path

root = Path(__file__).resolve().parents[1]
with zipfile.ZipFile(root / 'outputs/JWAIO 0.3_Alpha.zip') as archive:
    names = archive.namelist()
    assert len(names) == len(set(names))
    assert archive.testzip() is None
    assert not any(n.endswith(('.luac', '.csv', '.pyc')) for n in names)
    assert not any('0.2.1' in n or 'PRIVATE' in n for n in names)
    assert [n for n in names if n.startswith('LOGS/')] == ['LOGS/JWAIO/README.txt']
    skins = {n.split('/')[3] for n in names if n.startswith('WIDGETS/JWAIO/skins/')}
    assert skins == {'jwaio'}, skins
    for image, size in [('background.png', (480, 320)), ('logo.png', (216, 132))]:
        data = archive.read('WIDGETS/JWAIO/skins/jwaio/' + image)
        assert data[:8] == b'\x89PNG\r\n\x1a\n'
        assert struct.unpack('>II', data[16:24]) == size
    assert len([n for n in names if n.endswith('.wav')]) == 17
    for name in names:
        if name.endswith('.wav'):
            with wave.open(io.BytesIO(archive.read(name))) as audio:
                assert audio.getcomptype() == 'NONE'
                assert audio.getnframes() > 0
    for name in ('WIDGETS/JWAIO/main.lua', 'WIDGETS/JWAIO/lib/data.lua',
                 'WIDGETS/JWAIO/lib/skin.lua', 'WIDGETS/JWAIO/lib/diagnostics.lua',
                 'MODE_EMPLOI.txt'):
        assert name in names
        if name.startswith('WIDGETS/'):
            assert archive.read(name) == (root / 'sdcard' / name).read_bytes()
print('Public release archive: OK')
