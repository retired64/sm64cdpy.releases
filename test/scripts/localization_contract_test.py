"""Offline guards for Flutter/native language coverage and catalog credits."""
import json
import re
import unittest
from pathlib import Path
import xml.etree.ElementTree as ET

ROOT = Path(__file__).resolve().parents[2]


class LocalizationContractTest(unittest.TestCase):
    def test_all_locales_cover_reference_and_preserve_placeholders(self):
        reference = json.loads((ROOT / 'lib/l10n/app_en.arb').read_text())
        keys = {key for key in reference if not key.startswith('@')}
        for locale in ('en', 'es', 'es_419', 'pt', 'pt_BR', 'fr', 'it'):
            data = json.loads((ROOT / f'lib/l10n/app_{locale}.arb').read_text())
            with self.subTest(locale=locale):
                self.assertEqual(keys, {key for key in data if not key.startswith('@')})
                self.assertEqual(24, len(data['saveFileCourseNames'].split('|')))
                for key in keys:
                    self.assertTrue(data[key].strip(), key)
                    # Named arguments, including the argument preceding ICU plural.
                    names = lambda text: set(re.findall(r'\{([a-zA-Z]\w*)\s*[,}]', text))
                    self.assertEqual(names(reference[key]), names(data[key]), key)

    def test_native_resources_preserve_keys_and_printf_arguments(self):
        def read(folder):
            return {entry.attrib['name']: entry for entry in ET.parse(
                ROOT / f'android/app/src/main/res/{folder}/strings.xml').getroot()}
        reference = read('values')
        for folder in ('values-es', 'values-pt-rBR', 'values-fr', 'values-it'):
            data = read(folder)
            self.assertEqual(reference.keys(), data.keys(), folder)
            for key, original in reference.items():
                expected = re.findall(r'%\d+\$[sd]', ''.join(original.itertext()))
                actual = re.findall(r'%\d+\$[sd]', ''.join(data[key].itertext()))
                self.assertEqual(expected, actual, (folder, key))
                if original.tag == 'plurals':
                    self.assertEqual({'one', 'other'}, {i.attrib['quantity'] for i in data[key]})

    def test_touch_catalog_copies_are_valid_identical_and_credit_every_item(self):
        source = json.loads((ROOT / 'db/touch_controls.json').read_text())
        bundled = json.loads((ROOT / 'assets/db/touch_controls.json').read_text())
        self.assertEqual(source, bundled)
        self.assertEqual(28, len(source['touch_controls']))
        for item in source['touch_controls'].values():
            self.assertEqual('Release Soon', item['author'])
            self.assertTrue(item['download_url'].startswith('https://'))


if __name__ == '__main__':
    unittest.main()
