PRAGMA foreign_keys = ON;
PRAGMA user_version = 2;

CREATE TABLE surahs (
  number INTEGER NOT NULL PRIMARY KEY,
  name_arabic TEXT NOT NULL,
  name_english TEXT NOT NULL,
  name_bangla TEXT,
  revelation_place TEXT,
  ayah_count INTEGER NOT NULL,
  page_start INTEGER NOT NULL,
  page_end INTEGER NOT NULL,
  juz_start INTEGER NOT NULL
);

CREATE TABLE ayahs (
  surah_number INTEGER NOT NULL,
  ayah_number INTEGER NOT NULL,
  verse_key TEXT NOT NULL UNIQUE,
  arabic_text TEXT NOT NULL,
  arabic_text_indopak TEXT NOT NULL,
  arabic_text_tajweed TEXT,
  page_number INTEGER NOT NULL CHECK (page_number BETWEEN 1 AND 604),
  juz_number INTEGER NOT NULL CHECK (juz_number BETWEEN 1 AND 30),
  hizb_number INTEGER,
  rub_number INTEGER,
  PRIMARY KEY (surah_number, ayah_number),
  FOREIGN KEY (surah_number) REFERENCES surahs(number)
);

CREATE TABLE quran_words (
  surah_number INTEGER NOT NULL,
  ayah_number INTEGER NOT NULL,
  position INTEGER NOT NULL,
  arabic TEXT NOT NULL,
  arabic_indopak TEXT NOT NULL,
  arabic_tajweed TEXT,
  transliteration TEXT,
  bangla_meaning TEXT,
  english_meaning TEXT,
  root TEXT,
  lemma TEXT,
  grammar TEXT,
  audio_remote_path TEXT,
  PRIMARY KEY (surah_number, ayah_number, position),
  FOREIGN KEY (surah_number, ayah_number)
    REFERENCES ayahs(surah_number, ayah_number)
);

CREATE TABLE translations (
  resource_id INTEGER NOT NULL,
  surah_number INTEGER NOT NULL,
  ayah_number INTEGER NOT NULL,
  language TEXT NOT NULL,
  text TEXT NOT NULL,
  PRIMARY KEY (resource_id, surah_number, ayah_number),
  FOREIGN KEY (surah_number, ayah_number)
    REFERENCES ayahs(surah_number, ayah_number)
);

CREATE TABLE quran_metadata (
  metadata_key TEXT NOT NULL PRIMARY KEY,
  metadata_value TEXT NOT NULL
);

CREATE TABLE mushaf_lines (
  page_number INTEGER NOT NULL CHECK (page_number BETWEEN 1 AND 604),
  line_number INTEGER NOT NULL,
  line_type TEXT NOT NULL CHECK (line_type IN ('ayah','surah_name','basmallah')),
  is_centered INTEGER NOT NULL CHECK (is_centered IN (0,1)),
  surah_number INTEGER,
  first_word_location TEXT,
  last_word_location TEXT,
  PRIMARY KEY (page_number, line_number)
);

CREATE INDEX idx_ayah_page
  ON ayahs(page_number, surah_number, ayah_number);
CREATE INDEX idx_ayah_juz
  ON ayahs(juz_number, surah_number, ayah_number);
CREATE INDEX idx_word_lookup
  ON quran_words(surah_number, ayah_number, position);
CREATE INDEX idx_translation_lookup
  ON translations(resource_id, surah_number, ayah_number);
CREATE INDEX idx_mushaf_line_page
  ON mushaf_lines(page_number, line_number);
