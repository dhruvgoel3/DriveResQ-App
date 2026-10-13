<div align="center">

# 🚗 DriveResQ — On-Demand Roadside Assistance & Emergency Dispatch Platform

<p align="center">
  <strong>Instant Emergency Rescue • Real-Time GPS Navigation • Fair Transparent Pricing • 6-Digit OTP Handshake • Razorpay Settlement • Multi-Role Verification</strong>
</p>

[![Flutter Version](https://img.shields.io/badge/Flutter-3.10%2B-02569B?style=for-the-badge&logo=flutter&logoColor=white)](https://flutter.dev)
[![Dart Version](https://img.shields.io/badge/Dart-3.0%2B-0175C2?style=for-the-badge&logo=dart&logoColor=white)](https://dart.dev)
[![Firebase](https://img.shields.io/badge/Backend-Firebase%20Suite-FFCA28?style=for-the-badge&logo=firebase&logoColor=black)](https://firebase.google.com)
[![Razorpay](https://img.shields.io/badge/Payments-Razorpay%20UPI%20%26%20Cards-0C2340?style=for-the-badge&logo=razorpay&logoColor=white)](https://razorpay.com)
[![Architecture](https://img.shields.io/badge/Architecture-GetX%20%7C%20MVC%20%2B%20Services-6C63FF?style=for-the-badge)](https://pub.dev/packages/get)
[![Platform](https://img.shields.io/badge/Platforms-Android%20%7C%20iOS%20%7C%20Web-4CAF50?style=for-the-badge)](#-platforms-supported)
[![License](https://img.shields.io/badge/License-MIT-blue.svg?style=for-the-badge)](LICENSE)

<br/>

<img src="assets/DriverDashPhotos/hero_banner.jpg" alt="DriveResQ Hero Banner" width="100%" style="border-radius: 12px; box-shadow: 0 8px 30px rgba(0,0,0,0.12);" />

</div>

---

## 📌 Executive Summary

**DriveResQ** is an end-to-end, enterprise-grade roadside emergency dispatch ecosystem built with Flutter, Firebase, Google Maps Platform, and Razorpay. It connects stranded motorists with certified local mechanics in real-time. 

Unlike traditional, fragmented towing services, DriveResQ coordinates every stage of roadside distress: from **GPS reverse-geocoded dispatch**, **upfront price locking**, and **live turn-by-turn tracking**, to **cryptographic 6-digit OTP job verification**, **instant digital invoicing**, and **automated platform commission collection via Razorpay**.

---

## 🧭 Table of Contents

- [🚨 The Problem & The Solution](#-the-problem--the-solution)
  - [The Motorist Crisis](#1-the-motorist-crisis-on-the-road)
  - [The Local Mechanic's Dilemma](#2-the-local-mechanics-dilemma)
  - [The Platform Solution](#3-the-driveresq-solution)
- [📸 Triple-Dashboard Showcase](#-triple-dashboard-showcase)
  - [1. Driver Mobile Experience](#1-driver-mobile-experience)
  - [2. Mechanic Dispatch & Operations](#2-mechanic-dispatch--operations)
  - [3. Central Command Admin Web Portal](#3-central-command-admin-web-portal)
- [⚙️ Core Functional Architecture](#️-core-functional-architecture)
- [💳 Monetization, Fair Pricing & Razorpay Integration](#-monetization-fair-pricing--razorpay-integration)
- [🛡️ Trust & Security Protocol](#️-trust--security-protocol)
- [📁 Repository & Directory Layout](#-repository--directory-layout)
- [🚀 Quickstart & Setup Guide](#-quickstart--setup-guide)
- [🗺️ Product Roadmap](#️-product-roadmap)
- [👥 Contributing & License](#-contributing--license)

---

## 🚨 The Problem & The Solution

```
┌────────────────────────────────────────┐         ┌────────────────────────────────────────┐
│         THE OLD REALITY (PAIN)         │         │      THE DRIVERESQ WAY (SOLUTION)      │
├────────────────────────────────────────┤         ├────────────────────────────────────────┤
│ ❌ Stranded in unfamiliar highways     │  ────►  │ ✅ Instant GPS reverse-geocoded ping   │
│ ❌ Opaque, predatory roadside pricing  │  ────►  │ ✅ Locked base fee + upfront per-km    │
│ ❌ Unverified roadside mechanics       │  ────►  │ ✅ 6-step KYC & Admin verification     │
│ ❌ Ghost technician arrivals           │  ────►  │ ✅ Live Google Maps polyline tracking   │
│ ❌ Disputed cash payments & fraud      │  ────►  │ ✅ 6-digit OTP completion handshake    │
│ ❌ No platform commission tracking     │  ────►  │ ✅ Razorpay automated dues settlement  │
└────────────────────────────────────────┘         └────────────────────────────────────────┘
```

### 1. The Motorist Crisis on the Road
Every day, thousands of motorists experience sudden vehicular failure — flat tires, drained batteries, engine overheating, lockouts, or fuel exhaustion. In these moments:
- **Zero Visibility:** Motorists call unverified numbers or search search engines blindly with no arrival estimates (ETAs).
- **Predatory Extortion:** Mechanics on isolated highways frequently charge exorbitant rates once arriving on-site.
- **Safety Hazards:** Stranded drivers, especially at night or on desolate expressways, face physical vulnerability without emergency coordination.

### 2. The Local Mechanic's Dilemma
Small automotive repair shops and independent mechanics struggle with modern dispatch mechanics:
- **Inability to Compete:** Independent mechanics cannot afford expensive dispatch centers or proprietary tracking software.
- **Wasted Trips & Fake Calls:** Technicians drive miles only to find the motorist was picked up by someone else or gave the wrong address.
- **Payment Insecurity:** Mechanics have no standard way to itemize labor, parts, and travel fees, leading to uncomfortable disputes.

### 3. The DriveResQ Solution
DriveResQ addresses both sides of the market with a unified multi-tier platform:
1. **Intelligent Dispatch Engine:** Motorists create pinpoint requests with photos, vehicle model, and landmark notes. Certified mechanics within a 20 km radar are notified in milliseconds via high-priority FCM channels.
2. **Transparent Fair-Fare Architecture:** Travel fees are locked before the mechanic departs (`Base Fee + Per-Km Rate`), while parts and labor are itemized upon inspection.
3. **Double-Blind 6-Digit OTP Handshake:** A job cannot be marked finished until the driver shares their uniquely generated 6-digit verification code with the mechanic.
4. **Self-Balancing Platform Economy:** Drivers pay mechanics directly in cash or UPI. The platform automatically tallies commission on labor charges and enforces dues clearance via **Razorpay** to maintain account health.

---

## 📸 Triple-Dashboard Showcase

DriveResQ provides three tailored interfaces built on a unified codebase: **Driver Dashboard**, **Mechanic Operations Console**, and **Web Central Command Admin**.

---

### 1. Driver Mobile Experience

The driver app is crafted for ease-of-use under stress, featuring one-tap emergency triggers, transparent pricing breakdowns, live GPS tracking, and safety assistance.

| 01. Home & Quick SOS | 02. Service Categories | 03. Create Help Request |
|:---:|:---:|:---:|
| <img src="assets/DriverDashPhotos/01_driver_home.png" width="240" alt="Driver Home" /> | <img src="assets/DriverDashPhotos/02_request_services.png" width="240" alt="Service Catalog" /> | <img src="assets/DriverDashPhotos/03_create_help_request.png" width="240" alt="Create Request Form" /> |
| **Instant Rescue Trigger**<br/>GPS status, standby banner & 1-tap dispatch | **Broad Issue Matrix**<br/>Flat tire, dead battery, engine, towing, lockout | **Pinpoint Precision**<br/>Reverse geocoding, vehicle details & landmark notes |

| 04. Mechanic Radar Search | 05. Dispatch In Progress | 06. Mechanic Offer Received |
|:---:|:---:|:---:|
| <img src="assets/DriverDashPhotos/04_find_mechanics.png" width="240" alt="Find Mechanics" /> | <img src="assets/DriverDashPhotos/05_dispatch_progress.png" width="240" alt="Dispatch In Progress" /> | <img src="assets/DriverDashPhotos/06_mechanic_accepted.png" width="240" alt="Mechanic Accepted" /> |
| **Proximity Radar**<br/>Live distance filtering & service type filters | **Safety SOS Active**<br/>Emergency alert armed with shake detection | **Bid Confirmation**<br/>Mechanic profile preview, Accept/Decline action |

| 07. Live Radar & En-Route Map | 08. Handshake OTP Generated | 09. Verification Code Revealed |
|:---:|:---:|:---:|
| <img src="assets/DriverDashPhotos/07_mechanic_enroute_map.png" width="240" alt="Live Tracking Map" /> | <img src="assets/DriverDashPhotos/08_otp_generated.png" width="240" alt="OTP Generated" /> | <img src="assets/DriverDashPhotos/09_otp_verification_view.png" width="240" alt="OTP Revealed" /> |
| **Turn-by-Turn GPS**<br/>Live Google Maps tracking & ResQ AI Assistant | **Job Security Code**<br/>Protected 6-digit code issued to driver | **Locked Travel Breakdown**<br/>Transparent base fee + per-km calculation |

| 10. Navigation & Safety Drawer | 11. Driver Profile & History |
|:---:|:---:|
| <img src="assets/DriverDashPhotos/10_driver_sidebar.png" width="240" alt="Driver Drawer" /> | <img src="assets/DriverDashPhotos/11_driver_profile.png" width="240" alt="Driver Profile" /> |
| **Quick Access**<br/>Safety SOS, history, notifications & settings | **Driver Metrics**<br/>Total requests, completed rescues & verified status |

---

### 2. Mechanic Dispatch & Operations

The mechanic app functions as an all-in-one mobile workshop tool: accepting nearby calls, routing to the customer, itemizing labor and replacement parts, collecting cash, and clearing platform commission.

| 01. Incoming Emergency Radar | 02. Request Review & Acceptance | 03. Awaiting Driver Approval |
|:---:|:---:|:---:|
| <img src="assets/MechanicDashPhotos/01_all_requests_feed.png" width="240" alt="All Requests Feed" /> | <img src="assets/MechanicDashPhotos/02_request_details_modal.png" width="240" alt="Request Triage" /> | <img src="assets/MechanicDashPhotos/03_accepted_awaiting_approval.png" width="240" alt="Awaiting Driver" /> |
| **Live Broadcast Queue**<br/>Requests within 20 km auto-streamed in real-time | **Transparent Fee Preview**<br/>Base travel fee, distance & customer description | **Mutual Handshake**<br/>Driver verifies mechanic profile before lock-in |

| 04. Active Job Control Center | 05. Enter Verification OTP | 06. Job Summary & Labor Logging |
|:---:|:---:|:---:|
| <img src="assets/MechanicDashPhotos/04_active_job_dashboard.png" width="240" alt="Active Job Dashboard" /> | <img src="assets/MechanicDashPhotos/05_enter_otp_modal.png" width="240" alt="Enter 6-Digit OTP" /> | <img src="assets/MechanicDashPhotos/06_job_summary_services.png" width="240" alt="Services Logging" /> |
| **Field Operations**<br/>Call driver, open in-app chat, or launch Maps | **Cryptographic Verification**<br/>Driver provides code only upon on-site arrival | **Itemized Work Ledger**<br/>Select services performed & add replaced parts |

| 07. Cost Breakdown & Cash Receipt | 08. Customer Rating & Tags | 09. Job Completion & Invoicing |
|:---:|:---:|:---:|
| <img src="assets/MechanicDashPhotos/07_cost_breakdown_cash.png" width="240" alt="Cost Breakdown" /> | <img src="assets/MechanicDashPhotos/08_rate_customer.png" width="240" alt="Rate Driver" /> | <img src="assets/MechanicDashPhotos/09_job_completed_success.png" width="240" alt="Job Completed Celebration" /> |
| **Transparent Billing**<br/>Travel cost + parts + labor charges audited | **Two-Way Feedback**<br/>Rate driver courtesy, cooperation, and punctuality | **Download & Share**<br/>Official PDF invoice generated with one-tap sharing |

| 10. Service History & Analytics | 11. Profile & Cumulative Earnings | 12. KYC Trust Badges & Status |
|:---:|:---:|:---:|
| <img src="assets/MechanicDashPhotos/10_job_history.png" width="240" alt="Job History" /> | <img src="assets/MechanicDashPhotos/11_mechanic_profile.png" width="240" alt="Mechanic Profile" /> | <img src="assets/MechanicDashPhotos/12_trust_and_platform_dues.png" width="240" alt="Verification Badges" /> |
| **Historical Ledger**<br/>All past rescues, cancellations, earnings, and kms | **Reputation Score**<br/>Live star ratings, gross payouts & verified badge | **KYC Status Check**<br/>Aadhaar, PAN, Trade License & Bank verification |

| 13. Platform Dues Ledger | 14. Razorpay Secure Checkout | 15. Empty Standby Radar |
|:---:|:---:|:---:|
| <img src="assets/MechanicDashPhotos/13_razorpay_dues_ledger.png" width="240" alt="Platform Dues" /> | <img src="assets/MechanicDashPhotos/14_razorpay_processing.png" width="240" alt="Razorpay Processing" /> | <img src="assets/MechanicDashPhotos/15_empty_requests.png" width="240" alt="No Requests Standby" /> |
| **Transparent Commission**<br/>Unpaid invoices calculated solely from labor cuts | **Instant UPI / Card Payment**<br/>In-app Razorpay SDK clears dues in seconds | **Radar Standby Mode**<br/>Auto-refreshes when new breakdowns occur |

---

### 3. Central Command Admin Web Portal

A dedicated administrative workstation (`/admin`) optimized for web browsers and tablets to manage the driver and mechanic verification pipeline.

<div align="center">
  <img src="assets/adminPhotos/admin_dashboard.png" alt="DriveResQ Admin Web Dashboard" width="95%" style="border-radius: 12px; border: 1px solid #e0e0e0; box-shadow: 0 10px 30px rgba(0,0,0,0.08);" />
</div>

<br/>

#### 🛡️ Admin Portal Capabilities:
- **Comprehensive Verification Queue:** Tabbed workflows for reviewing submitted Aadhaar identity cards, PAN records, trade workshop licenses, and banking details.
- **Real-Time Key Metrics:** High-level dashboard counters tracking **Total Mechanics**, **Total Drivers**, **Pending Applications**, and **Approved Today**.
- **Audit Trails & Rejections:** Provide specific rejection reasons allowing mechanics to resubmit deficient documents without being permanently banned.
- **Safety Enforcement:** Ability to immediately suspend bad actors or accounts failing compliance audits.

---

## ⚙️ Core Functional Architecture

DriveResQ is engineered with **GetX MVC + Services Architecture**, decoupling UI rendering from state and reactive data streams.

```mermaid
sequenceDiagram
    autonumber
    actor Driver as 🚗 Stranded Driver
    participant App as 📱 DriveResQ App
    participant Cloud as ☁️ Firebase Firestore
    participant Func as ⚡ Cloud Functions
    actor Mech as 🔧 Mobile Mechanic
    participant Razorpay as 💳 Razorpay Gateway

    Driver->>App: Submits Emergency Request (Problem, Location, Vehicle)
    App->>Cloud: Writes to /requests/{id} (status: open)
    Cloud->>Func: Firestore Trigger (onCreate)
    Func->>Mech: High-Priority FCM Push Notification (20km radius)
    Mech->>App: Reviews & Taps "Accept Request"
    App->>Cloud: Updates request (status: accepted, mechanicId)
    Driver->>App: Reviews Mechanic & Approves Handshake
    App->>Cloud: Generates 6-Digit OTP (status: in_progress)
    Mech->>App: Navigates via Google Maps Polylines to Vehicle
    Note over Driver,Mech: On-Site Arrival & Physical Inspection
    Driver->>Mech: Shares 6-Digit OTP verbally
    Mech->>App: Enters OTP to unlock Job Completion
    Mech->>App: Itemizes Labor Charges + Replaced Parts
    App->>Cloud: Marks job completed, writes /completedJobs
    Driver->>Mech: Hands over Cash / Direct UPI Settlement
    Func->>Cloud: Calculates 10% platform commission on labor
    Cloud->>Mech: Flags /platformDues invoice
    Mech->>Razorpay: Initiates Razorpay Checkout to clear commission
    Razorpay->>Func: Server-Side HMAC Signature Verification
    Func->>Cloud: Clears dues & unlocks Mechanic account
```

---

## 💳 Monetization, Fair Pricing & Razorpay Integration

DriveResQ introduces a transparent, dispute-free billing model designed to protect drivers from price gouging while rewarding technicians for urgent travel.

### 1. The Transparent Fare Formula
$$\text{Total Invoice} = \underbrace{\text{Base Travel Fee} + (\text{Distance (km)} \times \text{Rate/km})}_{\text{Locked Upfront Travel Fee}} + \text{Spare Parts} + \text{Labor Charges}$$

- **Travel Fee is Locked:** Calculated from driver-to-mechanic GPS distance before departure. No arrival surprises.
- **100% Retained by Mechanic:** Fuel compensation and spare parts reimbursement are never taxed by the platform.
- **10% Fair Commission on Labor Only:** Platform commission applies **strictly** to labor charges collected in cash.

### 2. Built-in Razorpay Escrow & Dues Flow
When a mechanic collects cash on-site, a corresponding platform due invoice is generated:
1. **Dues Ledger:** Unpaid platform fees are logged in `/platformDues/{dueId}`.
2. **Account Pausing:** If dues exceed threshold, the mechanic's account is temporarily paused from taking new calls.
3. **In-App Razorpay Checkout:** The mechanic taps **"Pay ₹50.00 with Razorpay"** to clear the invoice instantly using UPI, Debit/Credit Card, or NetBanking.
4. **Server-Side Validation:** Cloud Function `verifyDuesPayment` validates the cryptographic HMAC-SHA256 signature and Razorpay Order ID before clearing the mechanic's account.

---

## 🛡️ Trust & Security Protocol

- **Cryptographic 6-Digit Verification Code:** Drivers hold an encrypted 6-digit OTP visible only on their device. Technicians must physically obtain this code to unlock the invoice screen.
- **6-Step KYC Verification Gate:** Mechanics must submit government-issued Aadhaar ID, workshop trade certification, and verified phone number before receiving active dispatches.
- **Shake-to-SOS Emergency Protocol:** Built-in accelerometer listener lets drivers shake their device to trigger emergency safety alerts with live location sharing.
- **Granular Security Rules:** Strict Firestore document rules ensure drivers can only mutate their own requests, mechanics cannot alter ratings, and only authenticated admins can inspect documents.

---

## 📁 Repository & Directory Layout

```text
DriveResQ-App/
├── android/                         # Android native manifests, UPI intents & ProGuard
├── ios/                             # iOS workspace & Info.plist UPI scheme configurations
├── web/                             # Web support & Razorpay checkout integration
├── assets/
│   ├── DriverDashPhotos/            # Driver flow screenshots & hero banners
│   ├── MechanicDashPhotos/          # Mechanic workflow & Razorpay ledger screenshots
│   ├── adminPhotos/                 # Admin web dashboard screenshots
│   ├── icon/                        # High-res app launcher icons
│   └── logo.png                     # Official DriveResQ emblem
├── functions/                       # Firebase Serverless Cloud Functions (Node.js 22)
│   ├── index.js                     # Push notification engine & Razorpay HMAC verifier
│   └── package.json
├── firestore.rules                  # Production Firestore document security rules
├── storage.rules                    # Cloud Storage bucket upload access rules
├── pubspec.yaml                     # Dependencies (GetX, Google Maps, Razorpay, etc.)
└── lib/
    ├── main.dart                    # App initialization & FCM foreground/background setup
    ├── firebase_options.dart        # Platform-specific Firebase credentials
    ├── admin/                       # Web & Tablet Admin Management Portal
    │   ├── controllers/             # Verification & metric aggregation controllers
    │   ├── views/                   # Dashboard, document inspections, applicant tables
    │   └── widgets/                 # Stat cards, verification modals, sidebar
    ├── app/
    │   └── routes/                  # GetX routing table (AppPages & AppRoutes)
    ├── data/
    │   └── models/                  # UserModel, RequestModel, DueModel, ChatModel
    ├── modules/
    │   ├── auth/                    # Phone OTP authentication, role selection & splash
    │   ├── driver/                  # Driver home, request creation, mechanics radar
    │   ├── mechanic/                # Requests feed, operations console, 6-step onboarding
    │   ├── dues/                    # Platform dues ledger, Razorpay checkout & sync
    │   ├── chat/                    # Real-time chat, walkie-talkie audio & quote cards
    │   ├── jobs/                    # 6-digit OTP verification, job summary, PDF billing
    │   ├── notifications/           # Push notifications & high-priority audio channels
    │   └── tracking/                # Google Maps real-time polyline tracking
    ├── shared/                      # Reusable Material 3 widgets, buttons & dialogs
    ├── theme/                       # Modern typography & vibrant palette
    └── utils/                       # Helpers, DevRole switcher, formatters
```

---

## 🚀 Quickstart & Setup Guide

### 📋 Prerequisites
- **Flutter SDK:** `^3.10.1` or higher ([Install Guide](https://docs.flutter.dev/get-started/install))
- **Dart SDK:** `^3.0.0`
- **Node.js:** `18.x` or `22.x` (for Cloud Functions)
- **Firebase CLI:** `npm install -g firebase-tools`
- **Google Maps API Key:** With Maps SDK (Android/iOS) and Geocoding APIs enabled
- **Razorpay Account:** Test Key ID & Key Secret

---

### 🛠️ Step-by-Step Installation

#### 1. Clone the Codebase
```bash
git clone https://github.com/dhruvgoel3/DriveResQ-App.git
cd DriveResQ-App
```

#### 2. Install Flutter Packages
```bash
flutter pub get
```

#### 3. Configure Google Maps
Add your Google Maps API Key to `android/app/local.properties`:
```properties
MAPS_API_KEY=your_google_maps_api_key_here
```
For iOS, add the key inside `ios/Runner/AppDelegate.swift`.

#### 4. Configure Razorpay & Firebase Cloud Functions
Inside `functions/.env`:
```env
RAZORPAY_KEY_ID=rzp_test_YourKeyHere
RAZORPAY_KEY_SECRET=YourSecretHere
```
Deploy the functions to Firebase:
```bash
cd functions
npm install
firebase deploy --only functions
cd ..
```

#### 5. Launch the Application
```bash
# Run on connected device or simulator
flutter run
```

> **Tip for Pair-Testing:** DriveResQ includes a built-in Developer Role Switcher in `lib/utils/role_change/dev_config.dart`. When `devMode = true`, you can toggle between Driver and Mechanic modes on a single device without re-logging.

---

## 🗺️ Product Roadmap

- [x] **Real-time Geo-Dispatch & Navigation** (Live Google Maps Polylines)
- [x] **Double-Blind 6-Digit OTP Handshake**
- [x] **Full-Featured Admin Verification Web Portal**
- [x] **Razorpay Automated Platform Dues Settlement**
- [ ] **AI-Powered Audio Damage Diagnostics** (Predict mechanical failure from sound waveforms)
- [ ] **Multi-Lingual Voice Navigation** (Regional Indian languages support for mechanics)
- [ ] **Highway Patrol & National SOS Integration** (Direct dispatch to 112 emergency services)

---

## 👥 Contributing & License

Contributions are welcome! Please follow these steps:
1. **Fork** the repository.
2. Create a feature branch (`git checkout -b feat/SmartBatteryDiagnostic`).
3. Commit your changes (`git commit -m 'feat: Add battery voltage checker'`).
4. Push to branch (`git push origin feat/SmartBatteryDiagnostic`).
5. Open a **Pull Request**.

Distributed under the **MIT License**. See [`LICENSE`](LICENSE) for details.

---

<div align="center">
  <sub>Built with ❤️ by Dhruv Goel & the DriveResQ Engineering Team</sub>
</div>
