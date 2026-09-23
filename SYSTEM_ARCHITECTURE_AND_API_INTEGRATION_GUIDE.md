# 🎙️ SpeakUp — Comprehensive Architecture & API Integration Guide

This guide explains the entire architecture of the **SpeakUp** application from the Frontend (Flutter) to the Backend (Node.js/Express) and Database (MySQL / In-Memory Store), along with step-by-step instructions on how to connect your **Payment API** and **AI Speech API**.

---

## 📁 1. Project Folder Organization & Purpose

The codebase is cleanly separated into two main directories: `FRONTEND` (Flutter client) and `backend` (Node.js API server).

```
APPLICATION/
│
├── FRONTEND/                             # Flutter Mobile & Web Application
│   ├── assets/images/                    # Logos, avatars, and onboarding illustrations
│   └── lib/
│       ├── main.dart                     # App entry point & Provider initialization
│       ├── constants/
│       │   └── app_colors.dart           # Color palette, dark mode tokens & gradients
│       ├── models/                       # Data structures & typed schemas
│       │   ├── ai_evaluator.dart         # 8 AI Evaluator personas & traits
│       │   ├── book_recommendation.dart  # Weakness-targeted books & reading plans
│       │   ├── category.dart             # Speaking domains (Tech, Politics, Business...)
│       │   ├── daily_knowledge_brief.dart# Daily speech articles & prompts
│       │   ├── journey.dart              # Roadmap levels, nodes & exercises
│       │   ├── non_audio_exercise.dart   # Flashcard & non-verbal drills
│       │   ├── practice_session.dart     # Speech recordings, metrics & transcripts
│       │   ├── simulated_environment.dart# 5 real-world stage/room simulations
│       │   └── subscription_plan.dart    # Free, Pro Speaker, Executive Plus plans
│       ├── providers/
│       │   └── app_provider.dart         # Central State Management (Privileges, Streaks, XP)
│       ├── services/
│       │   ├── api_service.dart          # HTTP client communicating with backend
│       │   └── file_picker_service.dart  # Report/PDF/Text document context loader
│       ├── screens/                      # UI Screens grouped by feature
│       │   ├── admin/                    # Admin Control Center & telemetry
│       │   ├── analysis/                 # AI Speech Reports & Book recommendations
│       │   ├── auth/                     # Unified Login Screen & Avatar selection
│       │   ├── daily/                    # Daily Knowledge Briefs archive
│       │   ├── environment/              # Simulated Environment Studio selector
│       │   ├── exercises/                # Non-audio practice drills
│       │   ├── feedback_inbox/           # Speech evaluations history
│       │   ├── home/                     # Home Dashboard & quick-start
│       │   ├── journey/                  # Roadmap, node review & re-take drills
│       │   ├── practice/                 # Studio setup, Evaluator modal, Live Q&A
│       │   ├── profile/                  # Profile stats, lifetime score, avatar picker
│       │   ├── splash/                   # Splash screen & onboarding carousel
│       │   ├── streak/                   # Daily streak calendar & consistency tracker
│       │   └── subscription/             # Subscription tiers & Payment Checkout Modal
│       └── widgets/                      # Reusable UI components
│           ├── audio_wave_visualizer.dart# Live audio waveform animation
│           ├── botanical_header.dart     # Curved organic header container
│           ├── bottom_nav_bar.dart       # Modern floating navigation bar
│           ├── score_ring_gauge.dart     # Circular score & metric progress rings
│           ├── speakup_logo.dart         # Scalable vector logo component
│           └── streak_badge.dart         # Animated flame streak counter
│
└── backend/                              # Node.js & Express REST API Server
    ├── server.js                         # Express server startup, CORS, and routing
    ├── .env                              # Environment variables (PORT, DB_HOST, DB_NAME...)
    ├── config/
    │   ├── db.js                         # MySQL Connection Pool with auto In-Memory Fallback
    │   ├── schema.sql                    # 11 Relational database tables
    │   └── seed.sql                      # Preloaded realistic data (Users, Evaluators, Books)
    ├── controllers/                      # Request handling & JSON response formatting
    │   ├── adminController.js
    │   ├── authController.js
    │   ├── avatarController.js
    │   ├── briefController.js
    │   ├── categoryController.js
    │   ├── environmentController.js
    │   ├── evaluatorController.js
    │   ├── journeyController.js
    │   ├── sessionController.js
    │   └── subscriptionController.js
    ├── repositories/                     # Data Access Layer (MySQL + In-Memory Store sync)
    ├── services/                         # Business logic rules & data transformations
    └── routes/                           # API Route definitions mounted on `/api/*`
```

---

## ⚙️ 2. How the Entire System Works (End-to-End)

```mermaid
graph TD
    A[Flutter UI / Mobile Screen] -->|1. User Interaction| B[AppProvider State Manager]
    B -->|2. Check Subscription Privileges| C{Plan Tier Allowed?}
    C -->|No| D[Open Payment Checkout Modal]
    C -->|Yes| E[Execute Action / Studio Practice]
    D -->|Fill Momo / Card & Pay| F[Process Payment & Activate Plan]
    F -->|Sync Plan Change| G[ApiService.subscribePlan]
    E -->|Finish Recording| H[ApiService.saveSession]
    G -->|HTTP POST /api/subscriptions/subscribe| I[Express Backend Server]
    H -->|HTTP POST /api/sessions| I
    I -->|Controller -> Service -> Repository| J[(MySQL Database / In-Memory Store)]
    J -->|Updated Response| I
    I -->|JSON Response| B
    B -->|notifyListeners| A
```

### Key Workflow Breakdown:
1. **Frontend State & Privileges (`AppProvider`)**:
   - Controls active plan (`Free Trainee: 0 FCFA`, `Pro Speaker: 3,500 FCFA`, `Executive Plus: 5,500 FCFA`).
   - Gating rules:
     - `isEvaluatorAllowed(evaluator)`: Locks executive & jury evaluators for free trainees.
     - `isEnvironmentAllowed(env)`: Locks TEDx stage and Courtroom.
     - `canAccessVideoMode`: Locks HD Video & Facial AI analysis for free users.
     - `canAccessDocumentContext`: Locks Speech Document context attachment.
     - `hasReachedPracticeLimit`: Checks if free user has performed 3 practices today.
2. **Interactive Payment Form (`PaymentCheckoutModal`)**:
   - Supports **Mobile Money** (MTN MoMo, Orange Money, Wave in FCFA), **Credit Card** (Visa, Mastercard), and **1-Tap Pay**.
   - Handles monthly / yearly billing discounts.
   - Updates `AppProvider` immediately and syncs with backend database.
3. **Speech Analysis & Weakness-Targeted Books**:
   - When a session finishes, the evaluator identifies weaknesses (e.g. *filler words*, *pacing*, *persuasion*).
   - Generates scores across 4 pillars (Clarity, Fluency, Confidence, Articulation) and matches 2 targeted book recommendations with estimated reading times.
4. **Streak & Score Telemetry**:
   - Ticks daily streak automatically whenever an exercise or speech session is completed.
   - Calculates lifetime cumulative scores since registration date (`September 1, 2026`).

---

## 💳 3. How to Implement and Add the Payment API

When you are ready to connect a live Payment Gateway (such as **MTN Mobile Money API**, **Orange Money Web Pay**, **Stripe**, **Flutterwave**, or **Paystack**), follow this simple 2-step process:

### Step 1: Open `payment_checkout_modal.dart`
Locate the method `_processPayment()` around **line 160** in `FRONTEND/lib/screens/subscription/payment_checkout_modal.dart`:

```dart
Future<void> _processPayment() async {
  setState(() {
    _isProcessing = true;
  });

  final provider = Provider.of<AppProvider>(context, listen: false);

  try {
    // =========================================================================
    // 💡 LIVE PAYMENT GATEWAY INTEGRATION:
    // Replace this section with your actual Payment Provider call:
    // =========================================================================
    
    // EXAMPLE A: MTN Mobile Money / Orange Money / Flutterwave
    /*
    final response = await http.post(
      Uri.parse('https://api.flutterwave.com/v3/charges?type=mobile_money_franco'),
      headers: {
        'Authorization': 'Bearer YOUR_SECRET_KEY',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'amount': _amountInFCFA,
        'currency': 'XAF',
        'phone_number': _phoneController.text.trim(),
        'email': provider.userEmail,
        'tx_ref': 'SPEAKUP_${DateTime.now().millisecondsSinceEpoch}',
      }),
    );
    if (response.statusCode != 200) {
      throw Exception('Payment transaction failed');
    }
    */

    // EXAMPLE B: Stripe Payment Intent (Card Payments)
    /*
    final stripeResponse = await http.post(
      Uri.parse('https://api.stripe.com/v1/payment_intents'),
      headers: {
        'Authorization': 'Bearer YOUR_STRIPE_SECRET_KEY',
        'Content-Type': 'application/x-www-form-urlencoded',
      },
      body: {
        'amount': (_amountInFCFA * 100).toString(),
        'currency': 'xaf',
        'payment_method_types[]': 'card',
      },
    );
    */

    // Simulated 1.6s delay for preview testing
    await Future.delayed(const Duration(milliseconds: 1600));

    // Activate subscription in local state & sync with backend database
    await provider.changeSubscriptionPlan(widget.plan);

    if (!mounted) return;

    setState(() {
      _isProcessing = false;
    });

    Navigator.pop(context, true);
  } catch (e) {
    if (!mounted) return;
    setState(() {
      _isProcessing = false;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Payment Error: $e'), backgroundColor: AppColors.errorRed),
    );
  }
}
```

---

## 🤖 4. How to Implement and Add the AI Speech & Evaluator API

When you are ready to connect a live AI API (such as **Google Gemini Multimodal API**, **OpenAI Whisper + GPT-4o**, or **ElevenLabs** for simulated voice feedback), follow these steps:

### Option 1: Calling AI via Backend (`backend/services/aiService.js`) — (Recommended)
This keeps your AI API keys safe on the server rather than exposing them on mobile clients.

1. **Add your AI API key in `backend/.env`**:
```env
GEMINI_API_KEY=AIzaSy...your_gemini_key_here
# or
OPENAI_API_KEY=sk-proj-...your_openai_key_here
```

2. **Create `backend/services/aiService.js`**:
```javascript
// backend/services/aiService.js
const { GoogleGenerativeAI } = require('@google/generative-ai');

const genAI = new GoogleGenerativeAI(process.env.GEMINI_API_KEY);

class AIService {
  async evaluateSpeechAudio({ audioBuffer, topic, evaluatorPersona, documentContext }) {
    const model = genAI.getGenerativeModel({ model: 'gemini-1.5-flash' });

    const prompt = `
      You are an expert speech evaluator acting as: ${evaluatorPersona}.
      Topic: "${topic}".
      User Document Context (if any): "${documentContext || 'None'}".
      
      Analyze the speech recording and return a JSON object with:
      - overallScore (0-100)
      - clarityScore (0-100)
      - fluencyScore (0-100)
      - confidenceScore (0-100)
      - articulationScore (0-100)
      - wordsPerMinute (number)
      - fillerWordsCount (number)
      - strengths (array of strings)
      - weaknesses (array of strings)
      - readingRecommendations (array of 2 recommended book titles and reasons)
    `;

    const result = await model.generateContent([
      prompt,
      {
        inlineData: {
          mimeType: 'audio/mp3',
          data: audioBuffer.toString('base64'),
        },
      },
    ]);

    const responseText = result.response.text();
    return JSON.parse(responseText);
  }
}

module.exports = new AIService();
```

3. **In `FRONTEND/lib/services/api_service.dart`**:
Upload the recorded audio file to `POST /api/sessions/evaluate-ai` and pass the returned analysis directly to `provider.completeSpeechAnalysis(result)`.

---

## 🚀 5. How to Run the Application

### 1. Start Backend:
```bash
cd c:\Users\user\Desktop\APPLICATION\backend
npm run dev
```
*Server starts on `http://localhost:5000` (or `http://10.0.2.2:5000` for Android Emulator).*

### 2. Start Frontend:
```bash
cd c:\Users\user\Desktop\APPLICATION\FRONTEND
flutter run -d chrome
# or for mobile / emulator:
flutter run
```
