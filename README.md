# 💰 Penny — Personal Finance Manager

A smart, AI-powered personal finance app built for Pakistan. Penny helps you track spending, scan receipts, auto-read bank SMS alerts, set budgets, and plan savings — all in one place.

---

## ✨ Features

- 🔐 **Firebase Auth** — Secure login, registration & password reset
- 📲 **Bank SMS Auto-Sync** — Automatically reads & parses bank alert messages
- 🧾 **Receipt Scanner** — Scan receipts via camera; Gemini AI extracts amount, merchant & category
- ✍️ **Manual Transaction Logs** — Quick expense & income entry with category selection
- 📊 **Category Budgets** — Set monthly limits with real-time gauges & push notifications
- 🤖 **AI Co-Pilot** — Financial Health Score, spending forecast, purchase planner & subscription radar
- 🫙 **Saving Vaults** — Goal-based saving jars with liquid fill animations
- 🗓️ **Spending Heatmap** — Visual calendar of daily spending intensity
- 💎 **Onyx Gamification** — Earn reward points for healthy financial habits
- 💬 **AI Chat with Function Calling** — Manage finances via natural language commands

---

## 🛠️ Tech Stack

| Layer | Technology |
|---|---|
| Framework | Flutter (Android & iOS) |
| AI Engine | Google Gemini AI (1.5-flash / 2.0-flash) |
| Backend | Firebase Auth + Firestore |
| Local Storage | Hive, SharedPreferences, SecureStorage |
| OCR | Google ML Kit Document Scanner |
| Architecture | Clean Architecture + BLoC |

---

## 🏗️ Architecture

Penny follows **Clean Architecture** with three layers:

- **Presentation** — Pages, BLoCs, Custom Widgets
- **Domain** — Use Cases, Entities, Repository Interfaces
- **Data** — Repository Implementations, Remote & Local Data Sources

---

## 🤖 AI Capabilities

- **Receipt OCR** — Gemini Vision parses merchant, amount, date & category from receipt images
- **SMS Parsing** — Gemini extracts transaction data from raw bank SMS text
- **Co-Pilot Advisor** — Health score, weekly challenges & purchase path planning
- **Function Calling** — Natural language commands trigger real app actions (add transaction, set budget, etc.)
- **Fallback Chain** — Automatic model fallback with exponential backoff for reliability

---

## 📦 Key Packages

```yaml
dependencies:
  google_generative_ai
  firebase_auth
  cloud_firestore
  hive_flutter
  google_mlkit_document_scanner
  google_mlkit_text_recognition
  telephony
  flutter_local_notifications
  flutter_bloc
  go_router
```

---

## 🇵🇰 Built for Pakistan

- PKR currency formatting throughout
- Bank SMS patterns tuned for Pakistani banks (Rs., PKR, debited, spent)
- Localized financial challenges and saving tips

