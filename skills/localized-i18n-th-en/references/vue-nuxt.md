# Vue / Nuxt i18n Reference

## §Setup — vue-i18n (Vue 3 / Vite)

### 1. Install

```bash
npm install vue-i18n@9
```

### 2. Directory layout

```
src/
  locales/
    en.json
    th.json
  i18n/
    index.ts
  main.ts
  App.vue
```

### 3. i18n plugin (`src/i18n/index.ts`)

```ts
import { createI18n } from 'vue-i18n';
import en from '../locales/en.json';
import th from '../locales/th.json';

const savedLang = localStorage.getItem('preferred-lang');
const browserLang = navigator.language.startsWith('th') ? 'th' : 'en';

export const i18n = createI18n({
  legacy: false,          // Composition API mode
  locale: savedLang ?? browserLang,
  fallbackLocale: 'en',
  messages: { en, th },
});
```

### 4. Register in `src/main.ts`

```ts
import { createApp } from 'vue';
import App from './App.vue';
import { i18n } from './i18n';

createApp(App).use(i18n).mount('#app');
```

### 5. Usage in components

```vue
<script setup lang="ts">
import { useI18n } from 'vue-i18n';
const { t } = useI18n();
</script>

<template>
  <form>
    <h1>{{ t('auth.login.title') }}</h1>
    <input
      type="email"
      :placeholder="t('auth.login.email.label')"
      :aria-label="t('auth.login.email.label')"
    />
    <button type="submit">{{ t('auth.login.submit') }}</button>
  </form>
</template>
```

---

## §Setup — @nuxtjs/i18n (Nuxt 3)

### 1. Install

```bash
npm install @nuxtjs/i18n
```

### 2. Register in `nuxt.config.ts`

```ts
export default defineNuxtConfig({
  modules: ['@nuxtjs/i18n'],
  i18n: {
    locales: [
      { code: 'en', name: 'English', file: 'en.json' },
      { code: 'th', name: 'ภาษาไทย', file: 'th.json' },
    ],
    defaultLocale: 'en',
    langDir: 'locales/',
    strategy: 'prefix_except_default',
    detectBrowserLanguage: {
      useCookie: true,
      cookieKey: 'preferred-lang',
      redirectOn: 'root',
      fallbackLocale: 'en',
    },
  },
});
```

### 3. Directory layout

```
locales/
  en.json
  th.json
nuxt.config.ts
pages/
  index.vue
```

### 4. Usage in Nuxt pages/components

`useI18n()` is auto-imported — no import statement needed:

```vue
<script setup>
const { t, locale } = useI18n();
</script>

<template>
  <h1>{{ t('auth.login.title') }}</h1>
</template>
```

### 5. Language switcher for Nuxt

```vue
<script setup>
const { locale, setLocale } = useI18n();
const toggle = () => {
  const next = locale.value === 'en' ? 'th' : 'en';
  setLocale(next);  // @nuxtjs/i18n handles cookie + URL prefix automatically
};
</script>

<template>
  <button @click="toggle">
    {{ locale === 'en' ? '🇹🇭 TH' : '🇬🇧 EN' }}
  </button>
</template>
```

---

## §Audit only — When vue-i18n is already configured

1. Locate locale files:
   ```bash
   find . -path "*/locales/*" -name "*.json" | head -20
   ls src/i18n/ 2>/dev/null
   ```
2. Check key parity — run the script from SKILL.md §Step 3 pointing at your locale paths.
3. Run the hardcoded string audit from SKILL.md §Step 1.
4. For Vue templates — watch for `v-text`, `innerHTML`, and raw text nodes that bypass `t()`.

### Common Vue anti-patterns to catch

```vue
<!-- Bad: raw text -->
<p>Dashboard</p>

<!-- Bad: string in v-bind without t() -->
<MyComp title="Settings" />

<!-- Bad: string in script -->
const label = 'Submit';

<!-- Good -->
<p>{{ t('nav.menu.dashboard') }}</p>
<MyComp :title="t('nav.menu.settings')" />
const label = t('common.button.submit');
```

---

## §Adding Languages

**vue-i18n:**
1. Create `src/locales/{lang}.json` with all keys translated
2. Import and add to `messages` in `src/i18n/index.ts`
3. Extend the language switcher

**@nuxtjs/i18n:**
1. Create `locales/{lang}.json`
2. Add `{ code: '{lang}', name: '...', file: '{lang}.json' }` to the `locales` array in `nuxt.config.ts`
3. Extend the language switcher
