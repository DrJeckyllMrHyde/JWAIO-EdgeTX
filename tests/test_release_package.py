"""Validate radio-specific release payloads, metadata, media and checksums."""
import importlib.util
from pathlib import Path
import re
import tempfile
import unittest
import zipfile
import hashlib

ROOT = Path(__file__).resolve().parents[1]
spec = importlib.util.spec_from_file_location('builder', ROOT/'tools/build_release.py')
builder = importlib.util.module_from_spec(spec)
spec.loader.exec_module(builder)

class Packages(unittest.TestCase):
    def test_three_radio_packages(self):
        with tempfile.TemporaryDirectory() as tmp:
            output = Path(tmp)
            builder.build(output)
            manifest = dict(line.split('  ', 1)[::-1] for line in
                            (ROOT/'releases/v0.3.1/SHA256SUMS.txt').read_text().splitlines())
            for variant in builder.VARIANTS:
                archive = output/f'JWAIO-v0.3.1-Alpha-{variant}.zip'
                published = ROOT/'releases/v0.3.1'/archive.name
                self.assertEqual(archive.read_bytes(), published.read_bytes())
                self.assertEqual(hashlib.sha256(published.read_bytes()).hexdigest(), manifest[published.name])
                with zipfile.ZipFile(published) as z:
                    self.assertIsNone(z.testzip())
                    expected = builder.package_files(variant)
                    self.assertEqual(set(z.namelist()), set(expected))
                    self.assertEqual(len(z.namelist()), len(set(z.namelist())))
                    self.assertEqual(sum(n.endswith('.lua') for n in z.namelist()), 17)
                    self.assertEqual(sum(n.endswith('.wav') for n in z.namelist()), 20)
                    self.assertEqual(sum(n.endswith('.png') for n in z.namelist()), 8)
                    for name, source in expected.items():
                        self.assertEqual(z.read(name), source.read_bytes())
                        self.assertNotIn('..', Path(name).parts)
                    config = z.read('WIDGETS/JWAIO/config.lua').decode('utf-8')
                    self.assertRegex(config, r'version\s*=\s*"0\.3\.1"')
                    self.assertRegex(config, r'iteration\s*=\s*"Alpha')
                    for name in z.namelist():
                        if name.endswith('.lua'):
                            self.assertNotRegex(z.read(name).decode('utf-8'), r'Preview|0\.3\.0')
                    for media in re.findall(r'"([^"\n]+\.wav)"', config):
                        self.assertIn('SOUNDS/fr/JWAIO/'+media, z.namelist())
            self.assertEqual(set(manifest), {f'JWAIO-v0.3.1-Alpha-{v}.zip' for v in builder.VARIANTS})

if __name__ == '__main__':
    unittest.main()
