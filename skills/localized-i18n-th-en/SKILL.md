---
name: localized-i18n-th-en
description: >
  Full i18n audit and implementation for frontend apps targeting Thai (TH) and English (EN).
  Use this skill whenever the user mentions: adding Thai/English language support, hardcoded UI text,
  localization keys, translation files, language switching, i18n setup, internationalization,
  "make the app support Thai", "add English/Thai translation", or any mention of th/en locale work.
  Also trigger when the user shares a component or page and asks why text is not translatable,
  or when they want to make a multilingual app from an existing single-language codebase.
  Supports React, Next.js, Vue, and Nuxt.
---

# Localized i18n — Thai / English Skill

This skill guides a complete i18n audit and implementation pass: detect the framework, check whether
i18n is already configured, install/configure it if needed, extract every hardcoded string into flat
dot-notation keys, produce EN and TH translation files, wire up a language switcher, and leave the
codebase ready for future language additions.

---

## Step 0: Detect Framework and Existing i18n

Run these checks before touching any files:

```bash
# Framework detection
cat package.json | grep -E '"next"|"react"|"vue"|"nuxt"'

# Existing i18n
grep -r "i18next\|react-i18next\|vue-i18n\|@nuxtjs/i18n\|next-intl\|useTranslation\|useI18n" \
  --include="*.ts" --include="*.tsx" --include="*.js" --include="*.jsx" --include="*.vue" \
  -l 2>/dev/null | head -20

# Existing locale files
find . -type f -name "*.json" | xargs grep -l '"en"\|"th"\|"translation"' 2>/dev/null | head -10
find . -path "*/locales/*" -o -path "*/i18n/*" -o -path "*/translations/*" 2>/dev/null | head -20
```

**Outcome matrix:**

| Framework | i18n present? | Action |
|-----------|---------------|--------|
| React/Next.js | No | Follow `references/react-nextjs.md` §Setup |
| React/Next.js | Yes | Follow `references/react-nextjs.md` §Audit only |
| Vue/Nuxt | No | Follow `references/vue-nuxt.md` §Setup |
| Vue/Nuxt | Yes | Follow `references/vue-nuxt.md` §Audit only |

Read the relevant reference file now before proceeding.

---

## Step 1: Audit — Find All Hardcoded Strings

Search for UI-visible text that is not already routed through a translation function:

```bash
# JSX/TSX — text in JSX attributes and children
grep -rn --include="*.tsx" --include="*.jsx" \
  -E '>[^<{]{3,}<|placeholder="|label="|title="|aria-label="' \
  src/ | grep -v "//\|className\|style\|href\|src\|key=\|id=" | head -60

# Vue SFC — text in templates
grep -rn --include="*.vue" \
  -E '>[^<{]{3,}<|:placeholder=|v-bind.*=.*"[A-Za-z]' \
  src/ | grep -v "//\|class\|style\|href\|src\|:key\|v-if\|v-for" | head -60

# JS/TS strings that look like UI copy (sentence-cased, multi-word, contains spaces)
grep -rn --include="*.ts" --include="*.js" \
  -E '"[A-Z][a-z]+ [a-zA-Z ]{3,}"|'"'"'[A-Z][a-z]+ [a-zA-Z ]{3,}'"'" \
  src/ | grep -v "console\|import\|require\|//\|test\|spec" | head -40
```

Collect results into a working list. Group by source file to make replacement easier.

---

## Step 2: Design Translation Keys

Key rules:
- **Flat dot-notation**: `page.section.element` (no nesting in JSON)
- **Format**: `<page>.<component>.<purpose>` — e.g., `auth.login.title`, `nav.menu.dashboard`
- Keep keys lowercase, words separated by dots
- Be semantic, not literal — `auth.login.error.invalid_credentials` not `auth.login.error.wrong_password_or_email`
- Reuse keys across pages when the string is genuinely the same concept (e.g., `common.button.save`)

**Reserve namespace `common.*` for strings that appear in 3+ places.**

---

## Step 3: Build Translation Files

Create `en.json` first (source of truth), then produce `th.json`.

**English file** — write the literal extracted strings:
```json
{
  "common.button.save": "Save",
  "common.button.cancel": "Cancel",
  "auth.login.title": "Log in to your account",
  "auth.login.email.label": "Email address",
  "auth.login.password.label": "Password",
  "auth.login.submit": "Sign in",
  "auth.login.error.invalid_credentials": "Invalid email or password",
  "nav.menu.dashboard": "Dashboard",
  "nav.menu.settings": "Settings"
}
```

**Thai file** — translate every key. If uncertain of a term, use the most common Thai UI convention
(not a literal word-for-word translation). Examples:
```json
{
  "common.button.save": "บันทึก",
  "common.button.cancel": "ยกเลิก",
  "auth.login.title": "เข้าสู่ระบบ",
  "auth.login.email.label": "อีเมล",
  "auth.login.password.label": "รหัสผ่าน",
  "auth.login.submit": "เข้าสู่ระบบ",
  "auth.login.error.invalid_credentials": "อีเมลหรือรหัสผ่านไม่ถูกต้อง",
  "nav.menu.dashboard": "แดชบอร์ด",
  "nav.menu.settings": "การตั้งค่า"
}
```

**Both files must have identical key sets.** Run this after writing both:
```bash
node -e "
  const en = Object.keys(require('./locales/en.json')).sort();
  const th = Object.keys(require('./locales/th.json')).sort();
  const missing = en.filter(k => !th.includes(k));
  const extra = th.filter(k => !en.includes(k));
  if (missing.length) console.log('Missing in TH:', missing);
  if (extra.length) console.log('Extra in TH:', extra);
  if (!missing.length && !extra.length) console.log('Keys match ✓');
"
```

---

## Step 4: Replace Hardcoded Strings in Source

Work file-by-file. Replace each hardcoded string with the appropriate translation call per framework:

| Framework | Translation call |
|-----------|-----------------|
| React | `const { t } = useTranslation(); ... {t('key')}` |
| Next.js App Router | `const t = await getTranslations(); ... {t('key')}` or `useTranslations()` |
| Vue SFC | `const { t } = useI18n(); ... {{ t('key') }}` |
| Nuxt | Same as Vue — `@nuxtjs/i18n` exposes `useI18n()` globally |

For **attribute strings** (placeholder, aria-label, title):
- React: `` placeholder={t('form.search.placeholder')} ``
- Vue: `` :placeholder="t('form.search.placeholder')" ``

For **string concatenation** (e.g., `"Hello " + name`), use interpolation:
- i18next: `t('greeting.hello', { name })` + key `"greeting.hello": "Hello {{name}}"`
- vue-i18n: `t('greeting.hello', { name })` + key `"greeting.hello": "Hello {name}"`

---

## Step 5: Language Switcher

Add a minimal language switcher. See the relevant reference file for placement conventions.
The switcher must:
1. Show current language (flag emoji or "TH / EN" label)
2. Persist selection to `localStorage` key `preferred-lang`
3. Default to EN if no preference stored and browser locale is not TH

**Minimal React example:**
```tsx
import { useTranslation } from 'react-i18next';

export function LanguageSwitcher() {
  const { i18n } = useTranslation();
  const toggle = () => {
    const next = i18n.language === 'en' ? 'th' : 'en';
    i18n.changeLanguage(next);
    localStorage.setItem('preferred-lang', next);
  };
  return (
    <button onClick={toggle}>
      {i18n.language === 'en' ? '🇹🇭 TH' : '🇬🇧 EN'}
    </button>
  );
}
```

**Minimal Vue example:**
```vue
<script setup>
import { useI18n } from 'vue-i18n';
const { locale } = useI18n();
const toggle = () => {
  locale.value = locale.value === 'en' ? 'th' : 'en';
  localStorage.setItem('preferred-lang', locale.value);
};
</script>
<template>
  <button @click="toggle">{{ locale === 'en' ? '🇹🇭 TH' : '🇬🇧 EN' }}</button>
</template>
```

---

## Step 6: Verify

```bash
# No raw English or Thai sentence strings remain outside t() calls
grep -rn --include="*.tsx" --include="*.jsx" --include="*.vue" \
  -E '>[A-Z][a-z]+ [a-zA-Z ]{3,}<' src/ | grep -v "//\|{t(\|{{ t(" | head -20

# Translation files are valid JSON
node -e "require('./locales/en.json'); require('./locales/th.json'); console.log('JSON valid ✓')"

# Key parity check (same script as Step 3)
```

Report any remaining hardcoded strings to the user with file:line references.

---

## Future Language Expansion

The flat-key structure makes adding a third language trivial:
1. Copy `locales/en.json` → `locales/{lang}.json`
2. Translate values
3. Register the new locale in the i18n config (see reference file §Adding Languages)
4. Add a case to the language switcher

---

## Reference Files

- `references/react-nextjs.md` — Setup, config, App Router vs Pages Router, adding languages
- `references/vue-nuxt.md` — Setup, config, Nuxt module, adding languages
