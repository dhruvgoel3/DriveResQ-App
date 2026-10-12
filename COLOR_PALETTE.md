# DriveResQ — Design System & Color Palette

A human-centric, modern visual design system engineered for emergency roadside assistance. The palette balances **trust & urgency**—providing visual clarity under bright daylight on roadside breakdowns, as well as high-contrast legibility during midnight highway emergencies.

---

## 🎨 Core Brand Palette

```
   Primary Brand         Driver Safety         Mechanic Action
   #6C63FF               #2196F3               #FF9800
   Electric Indigo       Vivid Blue            Safety Amber
```

| Token | HEX | RGB | HSL | Semantic Meaning & Psychology |
|---|---|---|---|---|
| `primary` | `#6C63FF` | `108, 99, 255` | `243°, 100%, 69%` | **Modern Reliability**: High-tech signature brand color, distinct and calm. |
| `primaryDark` | `#5A52D5` | `90, 82, 213` | `244°, 61%, 58%` | Primary hover/active state and gradient anchor. |
| `primaryLight` | `#8B7CFF` | `139, 124, 255` | `247°, 100%, 74%` | Highlights, badges, and glowing accent rings. |
| `secondary` | `#FF9800` | `255, 152, 0` | `36°, 100%, 50%` | **Mechanic Energetics**: Industrial alertness, urgency, and fast response. |
| `secondaryDark` | `#F57C00` | `245, 124, 0` | `30°, 100%, 48%` | High-contrast mechanic CTA buttons. |
| `accent` | `#00BCD4` | `0, 188, 212` | `187°, 100%, 42%` | GPS location radar pulse, route indicators, and active chips. |

---

## 🚗 Role-Specific Visual Identity

To maintain immediate user orientation and prevent cognitive friction between driver and mechanic personas, DriveResQ utilizes dedicated role color themes:

### 1. Driver Persona (Assurance, Safety, Calm)
* **Theme Anchor**: `AppColors.driverPrimary` (`#2196F3`)
* **Supporting Accent**: `AppColors.driverAccent` (`#00BCD4`)
* **Use Cases**: Driver request creation cards, driver dashboard header, favorite mechanic bookmarks, emergency SOS banner.

### 2. Mechanic Persona (Action, Dispatch, Commercial)
* **Theme Anchor**: `AppColors.mechanicPrimary` (`#FF9800`)
* **Supporting Accent**: `AppColors.mechanicAccent` (`#FF5722`)
* **Use Cases**: Incoming open request cards, active job status countdown, earnings ticker, customer verification prompt.

---

## 🚦 Semantic Status System

Every status indicator throughout the dispatch lifecycle maps to a strict semantic token:

| Status | Color Name | HEX | UX Meaning |
|---|---|---|---|
| **Success** | `AppColors.success` | `#4CAF50` | Mechanic arrived, OTP verified, payment complete, account approved. |
| **Warning** | `AppColors.warning` | `#FFC107` | Pending driver confirmation, low GPS accuracy, document verification review. |
| **Error / Alert** | `AppColors.error` | `#F44336` | SOS distress ping, request cancelled, rejected KYC application. |
| **Info** | `AppColors.info` | `#2196F3` | Mechanic en route, route recalculating, system notice. |

---

## 🌓 Surface & Neutral Tokens

### Light Theme (Default Daylight Mode)
```
Background: #F8F9FA  |  Surface: #FFFFFF  |  Border: #E0E0E0  |  Text Primary: #212121
```

- **Canvas Background** (`#F8F9FA`): Subtle cool gray that reduces screen glare on sunny roads.
- **Card Surface** (`#FFFFFF`): Pure white with subtle elevation shadows (`blurRadius: 10`, `alpha: 0.08`).
- **Dividers & Borders** (`#E0E0E0`): Crisp 1px boundary lines for card segmentation.
- **Text Primary** (`#212121`): Deep carbon black for maximum sunlight readability.
- **Text Secondary** (`#757575`): Muted slate for metadata timestamps and subtext.

### Dark Theme (Night Roadside Emergency Mode)
```
Background: #121212  |  Surface: #1E1E1E  |  Surface Variant: #2C2C2C  |  Text: #FFFFFF
```

- **Canvas Background** (`#121212`): True OLED black to conserve battery when stranded in remote areas.
- **Card Surface** (`#1E1E1E`): High-legibility elevated dark slate.
- **Primary Glow** (`#BB86FC`): Soft lavender accent that prevents eye strain in low-light environments.

---

## 🌈 Visual Gradients

```dart
// 1. Primary Brand Signature Gradient
LinearGradient(
  colors: [Color(0xFF6C63FF), Color(0xFF5A52D5)],
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
);

// 2. Mechanic Urgency Action Gradient
LinearGradient(
  colors: [Color(0xFFFF9800), Color(0xFFF57C00)],
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
);

// 3. Splash Screen Immersion Gradient
LinearGradient(
  colors: [Color(0xFF6C63FF), Color(0xFF5B52E5), Color(0xFF3D35C5)],
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
);
```

---

## 🔤 Typography & Contrast Ratios

DriveResQ uses **Google Fonts Poppins** for strong geometric headers and **Inter** for dense transactional UI data (coordinates, pricing, phone numbers).

- **H1 Headline**: Poppins Bold 24sp (`lineHeight: 1.3`, `color: textPrimary`)
- **H2 Section Title**: Poppins SemiBold 18sp
- **Body Regular**: Inter Regular 14sp (`lineHeight: 1.5`, `color: textPrimary`)
- **Metadata Caption**: Inter Medium 11sp (`color: textSecondary`)
- **Contrast Guarantee**: All text elements adhere strictly to WCAG AA standard (minimum 4.5:1 contrast against surface).
