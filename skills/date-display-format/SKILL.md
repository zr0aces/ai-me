---
name: date-display-format
description: Date display standardization to `dd MMM yyyy` format (e.g., `06 Jun 2026`) with a shared formatting utility and client-server timezone synchronization.
---

# Date Display Format Skill

Use this skill when standardizing, formatting, or displaying calendar dates across the frontend application, API services, database queries, and report briefings.

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

```typescript
/**
 * Formats a Date object or ISO string into 'dd MMM yyyy' (e.g., '06 Jun 2026')
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

### Backend (Python)
Implement a corresponding formatting function in backend time utilities (e.g. in `app/timeutils.py`):

```python
from datetime import datetime

def format_date(dt: datetime) -> str:
    """Format a datetime object into 'dd MMM yyyy' format (e.g. '06 Jun 2026')."""
    if dt is None:
        return "N/A"
    return dt.strftime("%d %b %Y")
```

---

## 🔒 3. Timezone Validation and Server Alignment

To prevent inconsistent date rendering between client-side rendering (local timezone) and server-side scanning/briefings:
1.  **Naive UTC Datetimes:** Store all datetimes in naive UTC format in the database.
2.  **Explicit Date Bounds:** Anchor date ranges (such as "today's scans") on UTC boundaries, for example, using `app.timeutils.utc_day_start()` rather than server-local or client-local midnights.
3.  **Client-Side Rendering:** When presenting date bounds on the UI, ensure dates are parsed or formatted explicitly in UTC if they represent market scan dates, or explicitly in client timezone if they represent user-triggered event timestamps.
