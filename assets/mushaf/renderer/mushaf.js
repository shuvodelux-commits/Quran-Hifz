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
    fontSize: 32,
    lineHeight: 1.35,
    showTajweedColors: true,
    continuousLayout: false,
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

  function pageElement() {
    return root.querySelector('.mushaf-page');
  }

  function postPageMetrics() {
    const pageNode = pageElement();
    if (!pageNode || !state.page) return;
    const rect = pageNode.getBoundingClientRect();
    const contentHeight = state.continuousLayout
      ? Math.max(pageNode.scrollHeight, rect.height)
      : Math.max(
          pageNode.scrollHeight,
          rect.height,
          document.documentElement.scrollHeight,
          document.body.scrollHeight,
        );
    if (!Number.isFinite(contentHeight) || contentHeight <= 0) return;
    post('pageMetrics', {
      page: state.page,
      generation: state.generation,
      contentHeight,
    });
  }

  function postPlaybackTarget(ayahKey, wordPosition = null) {
    if (!state.page || !ayahKey) return;
    let elements = [];
    if (Number(wordPosition) > 0) {
      const element = root.querySelector(
        '.word[data-ayah-key="' + CSS.escape(ayahKey) +
        '"][data-word-position="' + Number(wordPosition) + '"]',
      );
      if (element) elements = [element];
    } else {
      elements = [...root.querySelectorAll('.word, .ayah-end')]
        .filter((element) => element.dataset.ayahKey === ayahKey);
    }
    if (elements.length === 0) return;
    const pageNode = pageElement();
    if (!pageNode) return;
    const pageRect = pageNode.getBoundingClientRect();
    const rects = elements.map((element) => element.getBoundingClientRect());
    const top = Math.min(...rects.map((rect) => rect.top)) - pageRect.top;
    const bottom = Math.max(...rects.map((rect) => rect.bottom)) - pageRect.top;
    post('playbackTarget', {
      page: state.page,
      generation: state.generation,
      ayahKey,
      ...(Number(wordPosition) > 0 ? { wordPosition: Number(wordPosition) } : {}),
      top,
      bottom,
    });
  }

  function playbackElements(ayahKey, wordPosition = null) {
    if (!ayahKey) return [];
    if (Number(wordPosition) > 0) {
      const element = root.querySelector(
        '.word[data-ayah-key="' + CSS.escape(ayahKey) +
        '"][data-word-position="' + Number(wordPosition) + '"]',
      );
      return element ? [element] : [];
    }
    return [...root.querySelectorAll('.word, .ayah-end')]
      .filter((element) => element.dataset.ayahKey === ayahKey);
  }

  function ensurePlaybackTargetVisible(ayahKey, wordPosition = null) {
    if (state.continuousLayout) return;
    const elements = playbackElements(ayahKey, wordPosition);
    if (elements.length === 0) return;
    const rects = elements.map((element) => element.getBoundingClientRect());
    const top = Math.min(...rects.map((rect) => rect.top));
    const bottom = Math.max(...rects.map((rect) => rect.bottom));
    const safeTop = 48;
    const safeBottom = Math.max(safeTop + 1, window.innerHeight - 88);
    if (top >= safeTop && bottom <= safeBottom) return;
    const target = Math.max(
      0,
      window.scrollY + top - window.innerHeight * 0.34,
    );
    window.scrollTo({ top: target, behavior: 'smooth' });
  }

  function clearMeaningBubble() {
    root.querySelectorAll('.playback-meaning-bubble')
      .forEach((element) => element.remove());
  }

  function showMeaningBubble(wordElement, meaning) {
    clearMeaningBubble();
    const text = String(meaning || '').trim();
    if (!wordElement || !text) return;
    const bubble = document.createElement('span');
    bubble.className = 'playback-meaning-bubble';
    bubble.textContent = text;
    wordElement.appendChild(bubble);
    requestAnimationFrame(() => {
      const rect = bubble.getBoundingClientRect();
      let correction = 0;
      const margin = 8;
      if (rect.left < margin) correction += margin - rect.left;
      if (rect.right > window.innerWidth - margin) {
        correction -= rect.right - (window.innerWidth - margin);
      }
      bubble.style.setProperty('--meaning-shift-x', correction + 'px');
    });
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
      state.continuousLayout = Boolean(payload.continuousLayout);
      document.body.dataset.continuousLayout =
        state.continuousLayout ? 'on' : 'off';
      setPalette(payload.palette || state.palette);
      setTypography(
        payload.fontSize ?? state.fontSize,
        payload.lineHeight ?? state.lineHeight,
        payload.showTajweedColors ?? state.showTajweedColors,
      );

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
      requestAnimationFrame(postPageMetrics);
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

  function setTypography(fontSize, lineHeight, showTajweedColors) {
    const size = Number(fontSize);
    const height = Number(lineHeight);
    if (!Number.isFinite(size) || size < 20 || size > 56) {
      throw new Error('Hifz font size must be in 20..56');
    }
    if (!Number.isFinite(height) || height < 1.2 || height > 2.4) {
      throw new Error('Hifz line height must be in 1.2..2.4');
    }
    state.fontSize = size;
    state.lineHeight = height;
    state.showTajweedColors = Boolean(showTajweedColors);
    document.documentElement.style.setProperty('--hifz-font-size', size + 'px');
    document.documentElement.style.setProperty('--hifz-line-height', String(height));
    document.body.dataset.tajweedColors =
      state.showTajweedColors ? 'on' : 'off';
    requestAnimationFrame(postPageMetrics);
  }

  function setActiveWord(ayahKey, wordPosition, banglaMeaning = null) {
    root.querySelectorAll('.word.active-word')
      .forEach((element) => element.classList.remove('active-word'));
    let activeWord = null;
    root.querySelectorAll('.word').forEach((element) => {
      const matches = element.dataset.ayahKey === ayahKey &&
        Number(element.dataset.wordPosition) === Number(wordPosition);
      if (matches) {
        element.classList.add('active-word');
        activeWord = element;
      }
    });
    showMeaningBubble(activeWord, banglaMeaning);
    requestAnimationFrame(() => {
      ensurePlaybackTargetVisible(ayahKey, wordPosition);
      postPlaybackTarget(ayahKey, wordPosition);
    });
  }
  function setActiveAyah(ayahKey, deferFollowToWord = false) {
    root.querySelectorAll('.word.active-word')
      .forEach((element) => element.classList.remove('active-word'));
    clearMeaningBubble();
    root.querySelectorAll('.word, .ayah-end').forEach((element) => {
      element.classList.toggle(
        'active-ayah',
        element.dataset.ayahKey === ayahKey,
      );
    });
    requestAnimationFrame(() => {
      if (Boolean(deferFollowToWord)) return;
      ensurePlaybackTargetVisible(ayahKey);
      postPlaybackTarget(ayahKey);
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
    clearMeaningBubble();
  }

  window.mushaf = Object.freeze({
    renderPage,
    setPalette,
    setTypography,
    setActiveWord,
    setActiveAyah,
    setRange,
    clearPlaybackHighlight,
  });
})();
