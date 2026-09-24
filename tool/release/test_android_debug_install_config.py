import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]


class AndroidDebugInstallConfigTest(unittest.TestCase):
    def test_debug_build_uses_separate_application_id(self):
        build_gradle = (ROOT / 'android/app/build.gradle.kts').read_text(encoding='utf-8')
        self.assertIn('debug {', build_gradle)
        self.assertIn('applicationIdSuffix = ".debug"', build_gradle)
        self.assertIn('versionNameSuffix = "-debug"', build_gradle)

    def test_gradle_daemon_allows_native_access(self):
        properties = (ROOT / 'android/gradle.properties').read_text(encoding='utf-8')
        jvmargs = next(
            line for line in properties.splitlines()
            if line.startswith('org.gradle.jvmargs=')
        )
        self.assertIn('--enable-native-access=ALL-UNNAMED', jvmargs)


if __name__ == '__main__':
    unittest.main()
