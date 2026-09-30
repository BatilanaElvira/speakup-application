# 🎙️ SpeakUp — AI-Powered Speech Coaching Platform

Welcome to **SpeakUp**, an intelligent, interactive public speaking, debate, and presentation training platform. SpeakUp pairs a rich **Flutter** cross-platform frontend with a robust **Node.js/Express** N-tier backend, featuring Google Gemini AI integration, simulated practice environments, and gamified progress tracking.

---

## 🧭 Why Do My Files Have Different Colors in the Editor?

If you are using **VS Code**, **Cursor**, or **Antigravity IDE**, the files in your sidebar explorer and tabs are color-coded by **Git Version Control**. **These colors are NOT errors**—they indicate file change status:

| Color | Badge Letter | Meaning | What It Means for You |
| :--- | :---: | :--- | :--- |
| 🟢 **Green** | **`U`** or **`A`** | **Untracked / Added** | A new file that has been created but not yet committed to Git. |
| 🟠 **Yellow / Orange** | **`M`** | **Modified** | An existing file that you have edited since the last commit. |
| ⚪ **Grey / Dimmed** | — | **Ignored** | Files matched by `.gitignore` (such as `node_modules`, `build/`, `.env`). Git will ignore these. |
| 🔴 **Red** | **`!`** or **`C`** | **Error / Conflict** | A file containing a Git merge conflict or an unhandled compile-time syntax error. |
| 🔵 **Blue / Cyan** | — | **Special / Renamed** | A file that has been renamed or moved in Git history. |

> 💡 **Tip:** If you see Yellow/Orange or Green files, your project is completely healthy! It simply means Git knows which files you've recently created or modified.

---

## 📁 Repository Structure

```text
APPLICATION/
├── backend/                       # Node.js + Express API Backend (MVC Architecture)
│   ├── config/                    # Database connection, schemas, and seeds
│   │   ├── db.js                  # MySQL pool with seamless In-Memory Fallback
│   │   ├── schema.sql             # SQL database schema
│   │   └── seed.sql               # Initial seed data for evaluators and categories
│   ├── controllers/               # HTTP Request Handlers (Presentation Layer)
│   ├── middleware/                # JWT Auth, Validation, and Global Error Handler
│   ├── repositories/              # Database & Data Access Layer (Repository Pattern)
│   ├── routes/                    # Express REST route definitions
│   ├── services/                  # Business logic (Gemini AI, DigiPay, Auth, Cron)
│   ├── test/                      # Automated API integration tests & Postman collections
│   ├── .env.example               # Clean template for environment secrets
│   ├── package.json               # Backend dependencies and run scripts
│   └── server.js                  # Application entry point
│
├── FRONTEND/                      # Flutter Application (iOS, Android, Web, Desktop)
│   ├── lib/
│   │   ├── constants/             # AppColors, styles, and typography
│   │   ├── models/                # Dart data models (Evaluators, Journeys, Sessions)
│   │   ├── providers/             # State management via Provider (AppProvider)
│   │   ├── screens/               # App views (Auth, Dashboard, Practice, Profile)
│   │   ├── services/              # API Client (HTTP requests to backend)
│   │   └── widgets/               # Reusable UI components
│   ├── test/                      # Flutter unit and widget tests
│   └── pubspec.yaml               # Flutter dependencies and assets
│
├── .gitignore                     # Monorepo version control rules
├── README.md                      # Developer onboarding and project guide
└── SYSTEM_ARCHITECTURE_AND_API_INTEGRATION_GUIDE.md # Detailed architecture documentation
```

---

## 🚀 Quickstart Guide for Developers

### 1. Prerequisites
- **Node.js**: v18.x or v20.x+
- **Flutter SDK**: v3.22+
- **MySQL** *(optional)*: The backend includes an automated **In-Memory State Engine fallback**, so you can develop immediately even without a local MySQL instance running!

---

### 2. Setting Up & Running the Backend

```bash
# Navigate to the backend directory
cd backend

# Install dependencies
npm install

# Setup your environment file
# (Copy from .env.example if creating a fresh environment)
cp .env.example .env

# Start in development mode (with auto-reload)
npm run dev

# Or start standard production server
npm start
```
The server will start listening at: **`http://localhost:5000`**

#### Running Backend Tests:
The automated test runner will test health, authentication, social login, password reset, subscription plans, and speech analysis. It automatically launches an in-process test server if the backend isn't already active:
```bash
npm test
```

---

### 3. Setting Up & Running the Frontend

```bash
# Navigate to the frontend directory
cd FRONTEND

# Fetch Flutter dependencies
flutter pub get

# Run static analysis
flutter analyze

# Run Flutter tests
flutter test

# Run the app (on Chrome / Emulator / Connected Device)
flutter run -d chrome
# or for Windows desktop:
flutter run -d windows
```

---

## ⚙️ Environment Variables Reference (`backend/.env`)

| Variable | Description | Default / Example |
| :--- | :--- | :--- |
| `PORT` | Port the Express server listens on | `5000` |
| `NODE_ENV` | Environment mode | `development` |
| `DB_HOST` | MySQL hostname (Optional; in-memory fallback if unreachable) | `localhost` |
| `DB_PORT` | MySQL port | `3306` |
| `DB_USER` | MySQL user | `root` |
| `DB_PASSWORD` | MySQL password | *(blank)* |
| `DB_NAME` | MySQL database name | `speakup_db` |
| `JWT_SECRET` | Secret key used to sign authentication tokens | `your_secret_key` |
| `GEMINI_API_KEY` | Google AI Studio Key (Optional: heuristic fallback if omitted) | `AIzaSy...` |
| `GEMINI_MODEL` | Google Gemini model identifier | `gemini-1.5-flash` |
| `DIGIPAY_API_KEY` | DigiPay payment gateway API key | `dpk_...` |
| `DIGIPAY_BASE_URL`| DigiPay gateway endpoint | `https://digitalcertify.tech` |

---

## 🏛️ Architectural Highlights
- **Presentation Tier**: Express routes delegating to dedicated controllers with structured error handling.
- **Application Logic Tier**: Clean domain services (`authService`, `geminiService`, `practiceSessionService`, `cronService`).
- **Data Access Tier**: Repository pattern with automatic transparent fallback between live MySQL and high-fidelity mock data.
- **Resilience**: The application functions 100% offline out-of-the-box using the built-in heuristic scoring engine if MySQL or Gemini AI credentials are not provided.
