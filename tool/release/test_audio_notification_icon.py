import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]


class AndroidAudioNotificationIconContractTest(unittest.TestCase):
    def test_background_audio_uses_existing_android_small_icon(self):
        source = (ROOT / 'lib/core/audio/background_audio.dart').read_text(encoding='utf-8')
        self.assertIn("androidNotificationIcon: 'drawable/ic_stat_quran'", source)
        icon = ROOT / 'android/app/src/main/res/drawable/ic_stat_quran.xml'
        self.assertTrue(icon.is_file(), 'Missing Android notification small-icon resource')
        text = icon.read_text(encoding='utf-8')
        self.assertIn('<vector', text)
        self.assertIn('android:fillColor="#FFFFFFFF"', text)


if __name__ == '__main__':
    unittest.main()
