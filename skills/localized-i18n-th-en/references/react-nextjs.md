# React / Next.js i18n Reference

## §Setup — react-i18next (React / Next.js Pages Router)

### 1. Install

```bash
npm install react-i18next i18next i18next-browser-languagedetector i18next-http-backend
```

### 2. Create locale files

```
public/
  locales/
    en/
      translation.json   ← all EN keys
    th/
      translation.json   ← all TH keys
```

### 3. i18n config (`src/i18n.ts`)

```ts
import i18n from 'i18next';
import { initReactI18next } from 'react-i18next';
import LanguageDetector from 'i18next-browser-languagedetector';
import HttpBackend from 'i18next-http-backend';

i18n
  .use(HttpBackend)
  .use(LanguageDetector)
  .use(initReactI18next)
  .init({
    fallbackLng: 'en',
    supportedLngs: ['en', 'th'],
    defaultNS: 'translation',
    backend: { loadPath: '/locales/{{lng}}/{{ns}}.json' },
    detection: {
      order: ['localStorage', 'navigator'],
      caches: ['localStorage'],
      lookupLocalStorage: 'preferred-lang',
    },
    interpolation: { escapeValue: false },
  });

export default i18n;
```

### 4. Bootstrap in `src/main.tsx` or `pages/_app.tsx`

```ts
import './i18n'; // import before React renders
```

### 5. Usage in components

```tsx
import { useTranslation } from 'react-i18next';

export function LoginForm() {
  const { t } = useTranslation();
  return (
    <form>
      <h1>{t('auth.login.title')}</h1>
      <input
        type="email"
        placeholder={t('auth.login.email.label')}
        aria-label={t('auth.login.email.label')}
      />
    </form>
  );
}
```

---

## §Setup — next-intl (Next.js App Router)

### 1. Install

```bash
npm install next-intl
```

### 2. Directory layout

```
messages/
  en.json
  th.json
src/
  i18n/
    routing.ts
    request.ts
  middleware.ts
  app/
    [locale]/
      layout.tsx
      page.tsx
```

### 3. Routing config (`src/i18n/routing.ts`)

```ts
import { defineRouting } from 'next-intl/routing';

export const routing = defineRouting({
  locales: ['en', 'th'],
  defaultLocale: 'en',
});
```

### 4. Middleware (`src/middleware.ts`)

```ts
import createMiddleware from 'next-intl/middleware';
import { routing } from './i18n/routing';

export default createMiddleware(routing);

export const config = {
  matcher: ['/((?!api|_next|.*\\..*).*)'],
};
```

### 5. Request config (`src/i18n/request.ts`)

```ts
import { getRequestConfig } from 'next-intl/server';
import { routing } from './routing';

export default getRequestConfig(async ({ requestLocale }) => {
  const locale = (await requestLocale) ?? routing.defaultLocale;
  return {
    locale,
    messages: (await import(`../../messages/${locale}.json`)).default,
  };
});
```

### 6. Root layout (`app/[locale]/layout.tsx`)

```tsx
import { NextIntlClientProvider } from 'next-intl';
import { getMessages } from 'next-intl/server';

export default async function LocaleLayout({ children, params: { locale } }) {
  const messages = await getMessages();
  return (
    <html lang={locale}>
      <body>
        <NextIntlClientProvider messages={messages}>
          {children}
        </NextIntlClientProvider>
      </body>
    </html>
  );
}
```

### 7. Usage

**Server component:**
```tsx
import { getTranslations } from 'next-intl/server';

export default async function LoginPage() {
  const t = await getTranslations();
  return <h1>{t('auth.login.title')}</h1>;
}
```

**Client component:**
```tsx
'use client';
import { useTranslations } from 'next-intl';

export function LoginForm() {
  const t = useTranslations();
  return <h1>{t('auth.login.title')}</h1>;
}
```

### 8. Language switcher for next-intl

```tsx
'use client';
import { useRouter, usePathname } from 'next/navigation';
import { useLocale } from 'next-intl';

export function LanguageSwitcher() {
  const router = useRouter();
  const pathname = usePathname();
  const locale = useLocale();

  const toggle = () => {
    const next = locale === 'en' ? 'th' : 'en';
    // Replace locale prefix in pathname
    const newPath = pathname.replace(`/${locale}`, `/${next}`);
    router.push(newPath);
  };

  return (
    <button onClick={toggle}>
      {locale === 'en' ? '🇹🇭 TH' : '🇬🇧 EN'}
    </button>
  );
}
```

---

## §Audit only — When react-i18next is already configured

1. Locate existing locale files:
   ```bash
   find . -path "*/locales/*" -name "*.json" | head -20
   ```
2. Check which keys exist in EN but not TH (and vice versa) — run the key parity script from SKILL.md §Step 3.
3. Run the hardcoded string audit from SKILL.md §Step 1.
4. For each hardcoded string found, add a new key to both locale files and replace the string.

---

## §Adding Languages

To add a third language (e.g., Japanese `ja`):

**react-i18next:**
1. Create `public/locales/ja/translation.json` with all keys translated
2. Add `'ja'` to `supportedLngs` in `src/i18n.ts`
3. Extend the language switcher to cycle through `['en', 'th', 'ja']`

**next-intl:**
1. Create `messages/ja.json`
2. Add `'ja'` to `locales` array in `src/i18n/routing.ts`
3. Extend the language switcher
