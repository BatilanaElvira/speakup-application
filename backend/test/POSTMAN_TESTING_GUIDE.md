# 📮 Postman Unit & Integration Testing Guide — SpeakUp API

This guide provides instructions on how to use the automated **Postman Collection** and **Environment** created for the **SpeakUp** Node.js + Express backend.

---

## 📂 1. Included Test Files

Both files are located directly in your project under `backend/test/`:

| File | Purpose |
| :--- | :--- |
| **`SpeakUp_Postman_Collection.json`** | Comprehensive Postman v2.1.0 Collection with **47 test cases** covering all 10 API domains, complete with JavaScript unit tests (`pm.test`), status checks, and data schema assertions. |
| **`SpeakUp_Postman_Environment.json`** | Pre-configured environment variables (`base_url`, `user_token`, `admin_token`, `reset_code`, `payment_reference`, test credentials). |
| **`generate_postman_collection.js`** | NodeJS script to regenerate or customize the Postman collection at any time (`npm run postman:generate`). |

---

## 🚀 2. Quick Setup & Import (30 Seconds)

### Step 1: Start your backend server
Make sure your Express server is running on `http://localhost:5000`:
```bash
cd c:\Users\user\Desktop\APPLICATION\backend
npm run dev
```

### Step 2: Import into Postman
1. Launch the **Postman** desktop application (or web client).
2. Click the **Import** button in the top-left corner (or press `Ctrl + O` / `Cmd + O`).
3. Select and import both files from `c:\Users\user\Desktop\APPLICATION\backend\test\`:
   - `SpeakUp_Postman_Collection.json`
   - `SpeakUp_Postman_Environment.json`

### Step 3: Select the Environment
In the top-right dropdown of Postman, select:
> **`SpeakUp Local Environment (Port 5000)`**

---

## 🧪 3. Complete Test Suite Architecture (47 Requests)

The collection is organized into 10 structured folders matching the MVC & N-Tier architecture:

```
🎙️ SpeakUp AI API — Full Unit & Integration Test Suite
├── 01. System & Health Check (1 test)
│   └── GET Health Check (/health)
├── 02. Authentication & Authorization (10 tests)
│   ├── POST Register New Trainee (/auth/register)
│   ├── POST User Login - Amina Trainee (/auth/login) [Auto-saves user_token]
│   ├── POST User Login - Administrator (/auth/login) [Auto-saves admin_token]
│   ├── POST Social OAuth Login Simulation (/auth/social-login)
│   ├── POST Forgot Password - Request 6-digit OTP (/auth/forgot-password) [Auto-saves reset_code]
│   ├── POST Verify Reset OTP Code (/auth/verify-reset-code)
│   ├── POST Reset Password Final (/auth/reset-password)
│   ├── GET Authenticated User Profile (/auth/me)
│   ├── PUT Update User Profile (/auth/profile)
│   └── POST Register Negative Test - Missing Email (/auth/register) [400 Validation]
├── 03. Categories & Speaking Domains (5 tests)
│   ├── GET All Categories (/categories)
│   ├── GET Category by ID - Tech (/categories/tech)
│   ├── POST Create Custom Category [Admin] (/categories)
│   ├── PUT Update Custom Category [Admin] (/categories/{{temp_category_id}})
│   └── DELETE Category Cleanup [Admin] (/categories/{{temp_category_id}})
├── 04. AI Evaluators & Environments (4 tests)
│   ├── GET All AI Evaluators (/evaluators)
│   ├── GET Evaluator by ID - The Executive (/evaluators/executive)
│   ├── GET All Simulated Environments (/environments)
│   └── GET Environment by ID - TEDx Stage (/environments/tedx_stage)
├── 05. Avatar Presets & Profiles (3 tests)
│   ├── GET All Avatar Presets (/avatars)
│   ├── GET Avatar Preset by ID (/avatars/av_1)
│   └── POST Create Custom Avatar Preset (/avatars)
├── 06. Practice Sessions & AI Speech Analysis (3 tests)
│   ├── GET Practice Sessions History (/sessions/history)
│   ├── POST Analyze Speech Session - The Coach (/sessions/analyze) [4 Pillars Validation]
│   └── POST Analyze Speech Session - The Executive (/sessions/analyze)
├── 07. Gamified Journey Roadmap (2 tests)
│   ├── GET Journey Roadmap Tree (/journey/tree)
│   └── POST Complete Journey Node (/journey/nodes/conf_1_1/complete) [XP & Streak Increment]
├── 08. Daily Knowledge Briefs & Cron (3 tests)
│   ├── GET All Daily Knowledge Briefs (/daily-briefs)
│   ├── POST Simulate 05:00 AM Cron Generator (/daily-briefs/trigger-cron)
│   └── POST Mark Daily Brief as Read (/daily-briefs/db_1/read)
├── 09. Subscriptions & DigiPay Gateway (4 tests)
│   ├── GET All Subscription Plans (/subscriptions/plans)
│   ├── POST Direct Plan Subscription (/subscriptions/subscribe)
│   ├── POST Process DigiPay Mobile Money Payment (/subscriptions/process-payment) [Auto-saves payment_reference]
│   └── GET Verify DigiPay Payment by Reference (/subscriptions/verify/{{payment_reference}})
└── 10. Admin Telemetry & Full CRUD (12 tests)
    ├── GET Platform Telemetry & Metrics [Admin] (/admin/metrics)
    ├── GET All Registered Users [Admin] (/admin/users)
    ├── POST Create User [Admin] (/admin/users) [Auto-saves temp_user_id]
    ├── PUT Update User [Admin] (/admin/users/{{temp_user_id}})
    ├── DELETE User [Admin] (/admin/users/{{temp_user_id}})
    ├── GET All Skill Rules [Admin] (/admin/skill-rules)
    ├── POST Create Skill Rule [Admin] (/admin/skill-rules)
    ├── DELETE Skill Rule Cleanup [Admin] (/admin/skill-rules/{{temp_rule_id}})
    ├── GET All Non-Audio Exercises [Admin] (/admin/exercises)
    ├── POST Create Exercise Drill [Admin] (/admin/exercises)
    ├── DELETE Exercise Drill Cleanup [Admin] (/admin/exercises/{{temp_exercise_id}})
    └── GET Admin Metrics Negative Test - 403 Forbidden (/admin/metrics) [Security Auth Check]
```

---

## ⚡ 4. How to Run the Automated Test Suite (Collection Runner)

You can run all 47 tests with 1 click:

1. Click on the collection title: **`🎙️ SpeakUp AI API — Full Unit & Integration Test Suite`**.
2. Click the **Run** button (top right of the collection overview).
3. Ensure the environment is set to `SpeakUp Local Environment (Port 5000)`.
4. Click **Run SpeakUp AI API...**.
5. Postman will execute all requests in order, automatically chaining dynamic tokens, OTPs, and IDs, displaying:
   - ✅ **Passed test assertions**
   - ⏱️ **Response times**
   - 📊 **Detailed summary report**

---

## 🔗 5. How Dynamic Test Chaining Works

The collection handles state dynamically so you do NOT need to copy-paste tokens or IDs manually:

1. **Authentication Chaining**:
   - `POST /auth/login` extracts the JWT token and automatically saves it:
     ```javascript
     pm.collectionVariables.set("user_token", pm.response.json().token);
     ```
   - Subsequent authenticated endpoints automatically send:
     ```http
     Authorization: Bearer {{user_token}}
     ```

2. **Admin Role Chaining**:
   - `POST /auth/login (Admin)` stores `admin_token` and uses `x-admin-role: Admin` for all admin management endpoints.

3. **Forgot Password OTP Chaining**:
   - `POST /auth/forgot-password` generates a random 6-digit code and stores it in `{{reset_code}}`.
   - `POST /auth/verify-reset-code` and `POST /auth/reset-password` use `{{reset_code}}` directly.

4. **Payment Verification Chaining**:
   - `POST /subscriptions/process-payment` generates a reference like `DIGIPAY_SPK_...`.
   - `GET /subscriptions/verify/{{payment_reference}}` verifies the transaction status.

5. **Entity Lifecycle & Cleanup**:
   - Admin CRUD tests create temporary items (Categories, Users, Skill Rules, Exercises) and automatically clean them up with corresponding `DELETE` calls so test runs do not pollute your database.

---

## 💻 6. Running via Terminal (Newman CLI)

If you have Newman installed or want to run tests from your command line:

```bash
# Install newman globally (optional)
npm install -g newman

# Run the test collection
newman run backend/test/SpeakUp_Postman_Collection.json -e backend/test/SpeakUp_Postman_Environment.json --reporters cli
```
