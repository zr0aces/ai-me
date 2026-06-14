---
name: logo-design
description: "Guidelines and workflows for creating professional logos, generating visual assets programmatically (SVGs, multi-resolution favicons, PNGs) using Pillow, and integrating them consistently into web application themes."
trigger: /logo-design
---

# Logo and Brand Identity Design Skill

Use this skill when you need to create or update the visual identity, logo, and brand color system for any application. It guides you from initial design concept definition, through programmatic asset generation, to comprehensive application integration.

---

## 🎨 1. Core Design Principles

- **Simple & Minimalistic**: Design sleek, clean geometric shapes. Avoid complex details, busy gradients, or generic clip art.
- **Concept-Driven**: Build a unique identity based on the application's name, purpose, and core functionality.
- **Scalable**: The icon must look sharp and recognizable at both small sizes (16x16 favicon) and large formats (512x512 app launcher or desktop banners).
- **Multi-medium Ready**: Ensure suitability for web, mobile, desktop, documentation, and print/marketing materials.

---

## 🍊 2. Brand Color System

When establishing the color palette:
1. **Define the Primary Brand Color**: Use a prominent brand color (e.g., Orange `#FF6B00` or `#FF7A00`) across the logo and key branding elements.
2. **Build a Premium Palette**:
   - **Primary Accent**: Core brand color.
   - **Secondary Accent/Hover Shades**: Slightly darker or more saturated versions for interactive states.
   - **Neutral Colors**: Curated colors for backgrounds, typography, borders (e.g. slate-blues, cool grays).
   - **Dark-Mode compatible variants**: High-contrast, vibrant versions for dark themes.
3. **Contrast & Accessibility**: Ensure contrast meets WCAG accessibility guidelines on light, dark, and colored backgrounds.
4. **Monochrome Recognition**: The logo must remain recognizable in full-color, monochrome (solid black/white), and grayscale versions.

---

## 📦 3. Required Deliverables Checklist

Every brand identity overhaul must deliver:
- **Primary Logo**: Full horizontal/vertical version (Icon + Typography).
- **Compact Icon**: Compact/icon-only version.
- **Monochrome Version**: pure black (`logo-monochrome-black`) and pure white (`logo-monochrome-white`) versions.
- **Light & Dark Variants**: Versions styled specifically for light and dark backgrounds.
- **Formats**: SVG source files (vector) and optimized PNG exports (raster).
- **Favicon-Ready Assets**:
  - `favicon.ico` (multi-resolution: 16x16, 32x32, 48x48)
  - `favicon-16x16.png`, `favicon-32x32.png`, `favicon-96x96.png`
  - `apple-touch-icon.png` (180x180)
  - `web-app-manifest-192x192.png`, `web-app-manifest-512x512.png`

---

## 🛠️ 4. Programmatic Asset Generation (Python + Pillow)

To generate professional raster assets programmatically, write a Python script that leverages the **Pillow (PIL)** library. The technique draws geometry at 2048×2048 (8–16× larger than the largest output size of 512px) then downsamples with `LANCZOS` — this acts as supersampling, producing crisp anti-aliased edges.

### Generic Script Template
You can adapt this pattern to draw custom shapes based on the target application:

```python
import os
import math
from PIL import Image, ImageDraw, ImageFont

# Define path configurations
WORKSPACE_DIR = os.getcwd()
PUBLIC_DIR = os.path.join(WORKSPACE_DIR, "frontend/public")  # Adjust target directory
os.makedirs(PUBLIC_DIR, exist_ok=True)

# Define Brand Colors (adapt as needed)
BRAND_PRIMARY = (255, 107, 0, 255)  # E.g. Premium Orange #FF6B00
BRAND_DARK = (15, 23, 42, 255)      # Slate text #0F172A
BRAND_LIGHT = (255, 255, 255, 255)
TRANSPARENT = (0, 0, 0, 0)

# 1. GENERATE ICON MASK (4x Resolution: 2048x2048 for high-quality downsampling)
mask = Image.new('L', (2048, 2048), 0)
draw = ImageDraw.Draw(mask)

# --- DRAW CUSTOM GEOMETRY HERE ---
# Draw solid shapes with fill=255 (white)
# Draw cutouts/negative spaces with fill=0 (black)
# Example: draw.polygon([(x1, y1), ...], fill=255)
# Example: draw.arc(bbox, start_angle, end_angle, fill=255, width=stroke_width)
# ---------------------------------

# 2. COMPOSITE COLORED ICON
color_img = Image.new('RGBA', (2048, 2048), BRAND_PRIMARY)
icon_canvas = Image.new('RGBA', (2048, 2048), TRANSPARENT)
icon_canvas.paste(color_img, (0, 0), mask)

# 3. GENERATE ICON SIZES
sizes = [16, 32, 48, 96, 180, 192, 512]
png_icons = {s: icon_canvas.resize((s, s), Image.Resampling.LANCZOS) for s in sizes}

# 4. SAVE FAVICONS AND WEB APP ICONS
png_icons[16].save(os.path.join(PUBLIC_DIR, "favicon-16x16.png"), "PNG", optimize=True)
png_icons[32].save(os.path.join(PUBLIC_DIR, "favicon-32x32.png"), "PNG", optimize=True)
png_icons[96].save(os.path.join(PUBLIC_DIR, "favicon-96x96.png"), "PNG", optimize=True)
png_icons[180].save(os.path.join(PUBLIC_DIR, "apple-touch-icon.png"), "PNG", optimize=True)
png_icons[192].save(os.path.join(PUBLIC_DIR, "web-app-manifest-192x192.png"), "PNG", optimize=True)
png_icons[512].save(os.path.join(PUBLIC_DIR, "web-app-manifest-512x512.png"), "PNG", optimize=True)

# Save multi-resolution favicon.ico
# sizes tuple must match order: base image first (16), then append_images in order (32, 48)
png_icons[16].save(
    os.path.join(PUBLIC_DIR, "favicon.ico"),
    format="ICO",
    sizes=[(16, 16), (32, 32), (48, 48)],
    append_images=[png_icons[32], png_icons[48]]  # order must match sizes tuple
)

# 5. GENERATE FULL LOGO WITH TEXT
# Create a wider canvas (e.g. 7680x2048 at 4x), paste the resized mask, and draw text
# text_font = ImageFont.truetype("Path/To/Font.ttf", size)
# draw.text((x, y), "AppName", fill=BRAND_DARK, font=text_font)
```

---

## 📐 5. Handcrafting Vector Sources (SVGs)

Provide clean, hand-coded SVGs that scale infinitely in the browser. 

- Use a clean `viewBox` grid (e.g., `0 0 512 512` for icons, `0 0 1920 512` for horizontal full logos).
- Utilize single compound `<path>` tags for shapes with cutouts using winding rules or path commands (rather than layering white circles on top).
- Set standard layout font properties: `font-family="'Prompt', 'Kanit', 'Inter', sans-serif"`.

---

## 🔗 6. Codebase Integration Workflow

After generating the assets, integrate them system-wide using this step-by-step checklist:

1. **Replace Static Assets**: Copy all generated PNGs, SVGs, and ICO files into the application's public asset directory.
2. **Update Core HTML**: Check the main entry point (e.g., `index.html`) and update standard branding tags:
   ```html
   <link rel="icon" type="image/svg+xml" href="/favicon.ico" />
   <link rel="icon" type="image/png" sizes="32x32" href="/favicon-32x32.png" />
   <link rel="icon" type="image/png" sizes="16x16" href="/favicon-16x16.png" />
   <link rel="apple-touch-icon" sizes="180x180" href="/apple-touch-icon.png" />
   <link rel="manifest" href="/site.webmanifest" />
   ```
3. **Update Web App Manifest**: Ensure `/site.webmanifest` or `/manifest.json` matches the new sizes, icons, names, and theme colors.
4. **Update App Layout Components**:
   - Replace logo and icon files in website headers, navigation bars, login cards, settings screens, and footer sections.
   - **Vector Optimization**: Prefer SVGs over PNGs in layout components.
   - **Contrast Optimization**: Use monochrome vector variants (e.g., `logo-icon-mono-white.svg`) when the logo is rendered inside a colored theme container (like a gradient header or primary button) to ensure readability.
5. **Open Graph & SEO metadata**: Update social sharing assets (e.g. `og:image`, `twitter:image`), title tags, meta descriptions, and application metadata.

---

## 🎨 7. UI/UX Branding Consistency

Ensure a cohesive design system centered around the brand color:
- **Theme Variables**: Update tailwind/css custom variables (e.g., `--color-primary`, `--accent`, `--primary` HSL tokens) to route to the new primary and secondary hover brand colors.
- **UI Element Mapping**: Apply the branding consistently to:
  - Primary buttons, links, and highlights.
  - Active navigation indicators, border rings, and badges.
  - Chart colors, loading spinners, and notification banners.
  - Custom scrollbars.
- **Verification**: Run build validation commands (e.g. `npm run build` or type checks) and inspect rendering responsiveness across desktop, tablet, and mobile dimensions.
