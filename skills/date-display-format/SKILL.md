---
name: date-display-format
description: Date display standardization to `dd MMM yyyy` format (e.g., `06 Jun 2026`) with a shared formatting utility and client-server timezone synchronization.

trigger: /date-display-format
---

# Date Display Format Skill

Use this skill when standardizing, formatting, or displaying calendar dates across the frontend application, API services, database queries, and report briefings.

**Contexts covered:** UI display, API JSON responses, Python backend formatting, timezone-safe date bounds.

---

## 📅 1. Target Format Specification

All end-user visible dates must conform to the single standardized format:
```
dd MMM yyyy
```

### Examples:
*   `06 Jun 2026`
*   `12 Jan 2025`
*   `31 Dec 2026`

---

## 🛠️ 2. Shared Formatting Utilities

### Frontend (TypeScript / JavaScript)
Create a shared date formatting utility (e.g. in `src/time.ts` or `src/utils/date.ts`) using standard `Intl.DateTimeFormat` or custom string manipulation:

Only pass ISO 8601 strings (`"2026-06-14T00:00:00Z"`) or `Date` objects. Avoid locale-ambiguous strings like `"06/06/2026"` — `new Date()` parses them differently per browser.

When passing `number`: must be Unix timestamp in **milliseconds** (e.g. `Date.now()`, not seconds).

```typescript
/**
 * Formats a Date, ISO 8601 string, or ms timestamp into 'dd MMM yyyy' (e.g., '06 Jun 2026').
 * string input: must be ISO 8601 (e.g. "2026-06-14T00:00:00Z") — locale formats not supported.
 * number input: Unix timestamp in milliseconds.
 */
export function formatDate(dateInput: Date | string | number): string {
  const date = new Date(dateInput);
  if (isNaN(date.getTime())) return 'N/A';

  const day = String(date.getDate()).padStart(2, '0');
  const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
  const month = months[date.getMonth()];
  const year = date.getFullYear();

  return `${day} ${month} ${year}`;
}
```

**API JSON response:** serialize dates as ISO 8601 strings; format on the frontend with `formatDate()`:
```typescript
// API returns: { "created_at": "2026-06-14T08:30:00Z" }
formatDate(item.created_at) // → "14 Jun 2026"
```

### Backend (Python)
Implement a corresponding formatting function in backend time utilities (e.g. in `app/timeutils.py`):

All datetimes passed to this function must be **naive UTC** (no `tzinfo`). Timezone-aware datetimes will have their tzinfo silently stripped by `strftime` — assert to catch mistakes early.

```python
from datetime import datetime

def format_date(dt: datetime) -> str:
    """Format a naive UTC datetime into 'dd MMM yyyy' (e.g. '06 Jun 2026').
    Input must be naive UTC (tzinfo=None). Timezone-aware datetimes are rejected.
    """
    if dt is None:
        return "N/A"
    assert dt.tzinfo is None, f"Expected naive UTC datetime, got tzinfo={dt.tzinfo}"
    return dt.strftime("%d %b %Y")
```

---

## 🔒 3. Timezone Validation and Server Alignment

To prevent inconsistent date rendering between client-side rendering (local timezone) and server-side scanning/briefings:
1.  **Naive UTC Convention:** Store all datetimes as naive UTC in the database (no `tzinfo`). Convention: a naive datetime always means UTC — callers must convert to UTC before storing, never pass local time.

2.  **Explicit Date Bounds:** Anchor date ranges on UTC day boundaries. Implement in `app/timeutils.py`:
    ```python
    from datetime import datetime, timezone

    def utc_day_start() -> datetime:
        """Return start of current UTC day as a UTC-aware datetime."""
        now = datetime.now(timezone.utc)
        # Use constructor to preserve tzinfo — .replace(hour=0,...) strips tzinfo
        return datetime(now.year, now.month, now.day, tzinfo=timezone.utc)

    def utc_day_start_naive() -> datetime:
        """Return start of current UTC day as naive datetime (for DB queries)."""
        d = utc_day_start()
        return d.replace(tzinfo=None)
    ```
    Use `utc_day_start_naive()` for DB comparisons; `utc_day_start()` for aware datetime math.

3.  **Client-Side UTC vs Local Parsing:**
    - UTC dates (scan timestamps, server events): append `Z` suffix so browser parses as UTC:
      ```typescript
      // Server returns naive UTC string "2026-06-14T00:00:00" → append Z
      const date = new Date(serverDateStr.endsWith('Z') ? serverDateStr : serverDateStr + 'Z')
      formatDate(date) // renders in user's local timezone display
      ```
    - User-triggered timestamps (form submissions, local actions): parse without `Z` to use client timezone:
      ```typescript
      const date = new Date("2026-06-14T08:30:00") // local time
      formatDate(date)
      ```
