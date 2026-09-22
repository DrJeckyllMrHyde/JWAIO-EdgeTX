"""Build reproducible v0.3.1 Alpha packages from the three public variants."""
from pathlib import Path
import argparse
import hashlib
import zipfile

ROOT = Path(__file__).resolve().parents[1]
VARIANTS = ('TX15', 'TX16S-Mk1-Mk2', 'TX16S-Mk3')
NOTICES = ('LICENSE', 'NOTICE', 'LICENSE-ASSETS.md', 'THIRD_PARTY_NOTICES.txt', 'MODE_EMPLOI.txt')

def package_files(variant):
    source = ROOT / 'radios' / variant
    files = {}
    for folder in ('WIDGETS', 'SOUNDS', 'LOGS'):
        for file in (source / folder).rglob('*'):
            if not file.is_file():
                continue
            name = file.relative_to(source).as_posix()
            if folder == 'LOGS' and name != 'LOGS/JWAIO/README.txt':
                continue
            if '/skins/' in name and '/skins/jwaio/' not in name:
                continue
            if file.suffix.lower() not in ('.lua', '.png', '.wav', '.txt'):
                continue
            files[name] = file
    files.update({name: ROOT / name for name in NOTICES})
    files['LIRE_AVANT_INSTALLATION.txt'] = source / 'LIRE_AVANT_INSTALLATION.txt'
    for required in ('WIDGETS/JWAIO/main.lua', 'WIDGETS/JWAIO/config.lua',
                     'SOUNDS/fr/JWAIO/finder_bip.wav', 'LOGS/JWAIO/README.txt'):
        if required not in files:
            raise ValueError(f'{variant}: missing {required}')
    return files

def build(output, variants=VARIANTS):
    output.mkdir(parents=True, exist_ok=True)
    sums = []
    for variant in variants:
        archive = output / f'JWAIO-v0.3.1-Alpha-{variant}.zip'
        with zipfile.ZipFile(archive, 'w', compression=zipfile.ZIP_DEFLATED, compresslevel=9) as z:
            for name, file in sorted(package_files(variant).items()):
                info = zipfile.ZipInfo(name, date_time=(2026, 9, 22 if variant == "TX15" else 17, 0, 0, 0))
                info.compress_type = zipfile.ZIP_DEFLATED
                info.external_attr = 0o100644 << 16
                z.writestr(info, file.read_bytes(), compresslevel=9)
    for archive in sorted(output.glob('JWAIO-v0.3.1-Alpha-*.zip')):
        sums.append(f'{hashlib.sha256(archive.read_bytes()).hexdigest()}  {archive.name}')
    (output / 'SHA256SUMS.txt').write_text('\n'.join(sums)+'\n', encoding='utf-8', newline='\n')
    print('\n'.join(sums))

if __name__ == '__main__':
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--output', type=Path, default=ROOT / 'outputs' / 'v0.3.1')
    parser.add_argument('--variant', choices=VARIANTS, help='Build only this radio package')
    args = parser.parse_args()
    build(args.output, (args.variant,) if args.variant else VARIANTS)
