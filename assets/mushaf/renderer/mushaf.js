(() => {
  'use strict';

  const root = document.getElementById('mushaf-root');
  const dynamicFonts = document.createElement('style');
  dynamicFonts.id = 'mushaf-dynamic-fonts';
  document.head.appendChild(dynamicFonts);

  const state = {
    page: null,
    generation: 0,
    palette: 'light',
    rangeStart: null,
    rangeEnd: null,
  };

  const paletteNames = {
    light: '--Light',
    sepia: '--Sepia',
    dark: '--Dark',
    black: '--Black',
    p1: '--P1',
    p2: '--P2',
    p3: '--P3',
    p4: '--P4',
    p5: '--P5',
    p6: '--P6',
  };
  function post(type, fields = {}) {
    if (!window.MushafBridge ||
        typeof window.MushafBridge.postMessage !== 'function') {
      return;
    }
    window.MushafBridge.postMessage(JSON.stringify({ type, ...fields }));
  }

  function rendererError(code, error) {
    const message = String(error && error.message ? error.message : error)
      .slice(0, 512) || 'Unknown renderer error';
    post('rendererError', { code: String(code).slice(0, 64), message });
  }

  function assertFontDataUrl(value, name) {
    if (typeof value !== 'string' ||
        !/^data:font\/(woff2|otf|ttf|opentype|truetype);base64,[A-Za-z0-9+/=]+$/
          .test(value)) {
      throw new Error(name + ' must be a base64 data:font/ URL');
    }
    return value;
  }
  function fontFace(name, dataUrl, format) {
    return '@font-face{font-family:"' + name + '";src:url("' + dataUrl +
      '") format("' + format + '");font-display:block;}';
  }

  function installFonts(payload) {
    const rules = [];
    const pageFamily = String(payload.pageFontFamily || '');
    if (payload.variant === 'qcfV4Tajweed' &&
        pageFamily === 'QcfV4TajweedPage') {
      rules.push(fontFace(
        pageFamily,
        assertFontDataUrl(payload.fontDataUrl, 'fontDataUrl'),
        'woff2',
      ));
    } else if (payload.variant === 'qcfV2' &&
               pageFamily === 'QcfV2Page') {
      rules.push(fontFace(
        pageFamily,
        assertFontDataUrl(payload.fontDataUrl, 'fontDataUrl'),
        'woff2',
      ));
    } else {
      throw new Error('Unknown Mushaf variant/font family');
    }
    if (payload.surahFontDataUrl) {
      rules.push(fontFace(
        'SurahNameV4',
        assertFontDataUrl(payload.surahFontDataUrl, 'surahFontDataUrl'),
        'truetype',
      ));
    }
    if (payload.bismillahFontDataUrl) {
      rules.push(fontFace(
        'MushafBismillah',
        assertFontDataUrl(payload.bismillahFontDataUrl, 'bismillahFontDataUrl'),
        'truetype',
      ));
    }
    if (payload.endMarkerFontDataUrl) {
      rules.push(fontFace(
        'QuranUnicodeHafs',
        assertFontDataUrl(
          payload.endMarkerFontDataUrl,
          'endMarkerFontDataUrl',
        ),
        'truetype',
      ));
    }
    dynamicFonts.textContent = rules.join('\n');
    document.body.dataset.pageFontFamily = pageFamily;
  }

  function verseParts(key) {
    if (typeof key !== 'string') return null;
    const match = /^([1-9][0-9]{0,2}):([1-9][0-9]{0,2})$/.exec(key);
    if (!match) return null;
    return [Number(match[1]), Number(match[2])];
  }
  function compareVerseKeys(left, right) {
    const a = verseParts(left);
    const b = verseParts(right);
    if (!a || !b) return 0;
    if (a[0] !== b[0]) return a[0] - b[0];
    return a[1] - b[1];
  }

  function inSelectedRange(ayahKey) {
    if (!state.rangeStart || !state.rangeEnd || !ayahKey) return false;
    const startFirst =
      compareVerseKeys(state.rangeStart, state.rangeEnd) <= 0;
    const start = startFirst ? state.rangeStart : state.rangeEnd;
    const end = startFirst ? state.rangeEnd : state.rangeStart;
    return compareVerseKeys(ayahKey, start) >= 0 &&
      compareVerseKeys(ayahKey, end) <= 0;
  }

  function refreshRangeClasses() {
    root.querySelectorAll('.word, .ayah-end').forEach((element) => {
      element.classList.toggle(
        'in-range',
        inSelectedRange(element.dataset.ayahKey),
      );
    });
  }
  function bindWordInteraction(element, ayahKey, wordPosition) {
    let longPressTimer = null;
    let longPressed = false;

    const cancelTimer = () => {
      if (longPressTimer !== null) {
        clearTimeout(longPressTimer);
        longPressTimer = null;
      }
    };

    element.addEventListener('pointerdown', () => {
      longPressed = false;
      cancelTimer();
      longPressTimer = setTimeout(() => {
        longPressTimer = null;
        longPressed = true;
        post('wordLongPress', { ayahKey, wordPosition });
      }, 500);
    });
    element.addEventListener('pointerup', cancelTimer);
    element.addEventListener('pointercancel', cancelTimer);
    element.addEventListener('pointerleave', cancelTimer);
    element.addEventListener('click', () => {
      if (longPressed) {
        longPressed = false;
        return;
      }
      post('wordTap', { ayahKey, wordPosition });
    });
  }

  function tokenElement(token) {
    const isEnd = token.type === 'end';
    const element = document.createElement('span');
    element.className = isEnd ? 'ayah-end' : 'word';
    element.textContent = String(
      isEnd && token.unicodeFallback ? token.unicodeFallback : token.display ?? '',
    );

    if (token.ayahKey) {
      element.setAttribute('data-ayah-key', token.ayahKey);
    }

    if (isEnd) {
      element.addEventListener('click', () => {
        if (token.ayahKey) {
          post('ayahTap', { ayahKey: token.ayahKey });
        }
      });
    } else if (token.ayahKey && Number(token.wordPosition) > 0) {
      const wordPosition = Number(token.wordPosition);
      element.setAttribute('data-word-position', String(wordPosition));
      bindWordInteraction(element, token.ayahKey, wordPosition);
    }

    return element;
  }

  function lineElement(line) {
    const element = document.createElement('div');
    const lineType = String(line.type || '');
    element.className = 'mushaf-line ' +
      (line.isCentered ? 'centered' : 'justified');
    element.style.gridRow = String(Number(line.lineNumber));

    if (lineType === 'surah_name' || lineType === 'surahName') {
      element.classList.add('surah-name');
      const number = Number(line.surahNumber);
      if (!Number.isInteger(number) || number < 1 || number > 114) {
        throw new Error('Invalid Surah number');
      }
      element.textContent = 'surah' + String(number).padStart(3, '0');
      return element;
    }
    if (lineType === 'basmallah') {
      element.classList.add('basmallah');
      element.textContent = '﷽';
      return element;
    }

    if (lineType !== 'ayah') {
      throw new Error('Unknown Mushaf line type');
    }

    element.classList.add('ayah');
    const tokens = Array.isArray(line.tokens) ? line.tokens : [];
    tokens.forEach((token) => element.appendChild(tokenElement(token)));
    return element;
  }

  async function renderPage(payload) {
    try {
      if (!payload || typeof payload !== 'object') {
        throw new Error('Page payload is required');
      }
      const page = Number(payload.page);
      const generation = Number(payload.generation);
      if (!Number.isInteger(page) || page < 1 || page > 604) {
        throw new Error('Page must be in 1..604');
      }
      if (!Number.isInteger(generation) || generation < 0) {
        throw new Error('Generation must be non-negative');
      }
      if (!Array.isArray(payload.lines)) {
        throw new Error('Page lines are required');
      }

      installFonts(payload);
      state.page = page;
      state.generation = generation;
      setPalette(payload.palette || state.palette);

      const pageElement = document.createElement('section');
      pageElement.className = 'mushaf-page';
      pageElement.dataset.page = String(page);

      [...payload.lines]
        .sort((a, b) => Number(a.lineNumber) - Number(b.lineNumber))
        .forEach((line) => pageElement.appendChild(lineElement(line)));

      root.replaceChildren(pageElement);
      refreshRangeClasses();
      await document.fonts.ready;
      post('pageReady', { page, generation });
    } catch (error) {
      rendererError('RENDER_PAGE', error);
    }
  }

  function setPalette(name) {
    const normalized = String(name || '').toLowerCase();
    const palette = paletteNames[normalized];
    if (!palette) throw new Error('Unknown Mushaf palette');
    state.palette = normalized;
    document.body.dataset.palette = normalized;
    document.documentElement.style.setProperty('--qpc-palette', palette);
  }

  function setActiveWord(ayahKey, wordPosition) {
    root.querySelectorAll('.word.active-word')
      .forEach((element) => element.classList.remove('active-word'));
    root.querySelectorAll('.word').forEach((element) => {
      const matches = element.dataset.ayahKey === ayahKey &&
        Number(element.dataset.wordPosition) === Number(wordPosition);
      if (matches) element.classList.add('active-word');
    });
  }
  function setActiveAyah(ayahKey) {
    root.querySelectorAll('.word, .ayah-end').forEach((element) => {
      element.classList.toggle(
        'active-ayah',
        element.dataset.ayahKey === ayahKey,
      );
    });
  }

  function setRange(startAyahKey, endAyahKey) {
    state.rangeStart = startAyahKey || null;
    state.rangeEnd = endAyahKey || null;
    refreshRangeClasses();
  }

  function clearPlaybackHighlight() {
    root.querySelectorAll('.active-word, .active-ayah').forEach((element) => {
      element.classList.remove('active-word', 'active-ayah');
    });
  }

  window.mushaf = Object.freeze({
    renderPage,
    setPalette,
    setActiveWord,
    setActiveAyah,
    setRange,
    clearPlaybackHighlight,
  });
})();
