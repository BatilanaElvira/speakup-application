-- SpeakUp Database Schema (MySQL)

CREATE DATABASE IF NOT EXISTS speakup_db;
USE speakup_db;

-- 1. Users Table
CREATE TABLE IF NOT EXISTS users (
  id VARCHAR(64) PRIMARY KEY,
  name VARCHAR(255) NOT NULL,
  email VARCHAR(255) NOT NULL UNIQUE,
  password_hash VARCHAR(255) NOT NULL,
  role ENUM('Trainee', 'Admin') DEFAULT 'Trainee',
  streak_days INT DEFAULT 7,
  total_xp INT DEFAULT 520,
  current_plan_id VARCHAR(64) DEFAULT 'pro',
  obstacle_id VARCHAR(64) DEFAULT 'confidence',
  avatar_url TEXT DEFAULT NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- 2. Categories Table
CREATE TABLE IF NOT EXISTS categories (
  id VARCHAR(64) PRIMARY KEY,
  title VARCHAR(255) NOT NULL,
  emoji VARCHAR(32) NOT NULL,
  card_color_hex VARCHAR(32) NOT NULL,
  sample_topics_json TEXT NOT NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 3. AI Evaluators Table
CREATE TABLE IF NOT EXISTS ai_evaluators (
  id VARCHAR(64) PRIMARY KEY,
  name VARCHAR(255) NOT NULL,
  title VARCHAR(255) NOT NULL,
  description TEXT NOT NULL,
  icon VARCHAR(32) NOT NULL,
  accent_color_hex VARCHAR(32) NOT NULL,
  focus_area VARCHAR(255) NOT NULL,
  specialized_scenarios_json TEXT NOT NULL,
  sample_prompt TEXT NOT NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 4. Simulated Environments Table
CREATE TABLE IF NOT EXISTS simulated_environments (
  id VARCHAR(64) PRIMARY KEY,
  title VARCHAR(255) NOT NULL,
  icon VARCHAR(32) NOT NULL,
  description TEXT NOT NULL,
  recommended_evaluator_id VARCHAR(64) NOT NULL,
  audience_type VARCHAR(255) NOT NULL,
  noise_level VARCHAR(64) NOT NULL,
  strictness_options_json TEXT NOT NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 5. Speaking Obstacles Table
CREATE TABLE IF NOT EXISTS speaking_obstacles (
  id VARCHAR(64) PRIMARY KEY,
  title VARCHAR(255) NOT NULL,
  emoji VARCHAR(32) NOT NULL,
  subtitle VARCHAR(255) NOT NULL,
  theme_color_hex VARCHAR(32) NOT NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 6. Journey Stages Table
CREATE TABLE IF NOT EXISTS journey_stages (
  id VARCHAR(64) PRIMARY KEY,
  obstacle_id VARCHAR(64) NOT NULL,
  stage_number INT NOT NULL,
  environment_name VARCHAR(255) NOT NULL,
  environment_emoji VARCHAR(32) NOT NULL,
  title VARCHAR(255) NOT NULL,
  description TEXT NOT NULL,
  FOREIGN KEY (obstacle_id) REFERENCES speaking_obstacles(id) ON DELETE CASCADE
);

-- 7. Journey Nodes Table
CREATE TABLE IF NOT EXISTS journey_nodes (
  id VARCHAR(64) PRIMARY KEY,
  stage_id VARCHAR(64) NOT NULL,
  title VARCHAR(255) NOT NULL,
  situation_prompt TEXT NOT NULL,
  duration_seconds INT NOT NULL,
  difficulty VARCHAR(32) NOT NULL,
  xp_reward INT NOT NULL,
  FOREIGN KEY (stage_id) REFERENCES journey_stages(id) ON DELETE CASCADE
);

-- 8. User Node Progress Table
CREATE TABLE IF NOT EXISTS user_node_progress (
  id VARCHAR(64) PRIMARY KEY,
  user_id VARCHAR(64) NOT NULL,
  node_id VARCHAR(64) NOT NULL,
  completed_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
  FOREIGN KEY (node_id) REFERENCES journey_nodes(id) ON DELETE CASCADE,
  UNIQUE KEY user_node_unique (user_id, node_id)
);

-- 9. Practice Sessions Table
CREATE TABLE IF NOT EXISTS practice_sessions (
  id VARCHAR(64) PRIMARY KEY,
  user_id VARCHAR(64) NOT NULL,
  mode VARCHAR(32) NOT NULL,
  evaluator_id VARCHAR(64) NOT NULL,
  evaluator_name VARCHAR(255) NOT NULL,
  category_id VARCHAR(64) NOT NULL,
  topic TEXT NOT NULL,
  duration_seconds INT NOT NULL,
  overall_score INT NOT NULL,
  clarity_score INT NOT NULL,
  confidence_score INT NOT NULL,
  pace_score INT NOT NULL,
  fluency_score INT NOT NULL,
  structure_score INT NOT NULL,
  filler_word_count INT NOT NULL,
  transcript TEXT NOT NULL,
  strengths_json TEXT NOT NULL,
  weaknesses_json TEXT NOT NULL,
  how_to_improve TEXT NOT NULL,
  next_recommended_exercise TEXT NOT NULL,
  recommended_books_json TEXT,
  audience_questions_json TEXT,
  is_saved_in_inbox TINYINT(1) DEFAULT 1,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);

-- 10. Daily Knowledge Briefs Table
CREATE TABLE IF NOT EXISTS daily_briefs (
  id VARCHAR(64) PRIMARY KEY,
  brief_date DATE NOT NULL,
  category VARCHAR(255) NOT NULL,
  topic VARCHAR(255) NOT NULL,
  emoji VARCHAR(32) NOT NULL,
  summary_text TEXT NOT NULL,
  key_facts_json TEXT NOT NULL,
  suggested_prompt TEXT NOT NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 11. User Brief Reads Table
CREATE TABLE IF NOT EXISTS user_brief_reads (
  id VARCHAR(64) PRIMARY KEY,
  user_id VARCHAR(64) NOT NULL,
  brief_id VARCHAR(64) NOT NULL,
  read_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
  FOREIGN KEY (brief_id) REFERENCES daily_briefs(id) ON DELETE CASCADE,
  UNIQUE KEY user_brief_unique (user_id, brief_id)
);

-- 12. Subscription Plans Table
CREATE TABLE IF NOT EXISTS subscription_plans (
  id VARCHAR(64) PRIMARY KEY,
  name VARCHAR(255) NOT NULL,
  price_monthly DECIMAL(10,2) NOT NULL,
  price_yearly DECIMAL(10,2) NOT NULL,
  is_popular TINYINT(1) DEFAULT 0,
  badge VARCHAR(64),
  features_json TEXT NOT NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 13. Skill Rules Table
CREATE TABLE IF NOT EXISTS skill_rules (
  id VARCHAR(64) PRIMARY KEY,
  title VARCHAR(255) NOT NULL,
  focus_area VARCHAR(255) NOT NULL,
  min_score_threshold INT DEFAULT 80,
  max_filler_words INT DEFAULT 2,
  guidance_tip TEXT NOT NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- 14. Exercises Table
CREATE TABLE IF NOT EXISTS exercises (
  id VARCHAR(64) PRIMARY KEY,
  title VARCHAR(255) NOT NULL,
  category_id VARCHAR(64) NOT NULL,
  evaluator_name VARCHAR(255) NOT NULL,
  target_duration_seconds INT DEFAULT 60,
  sample_prompt TEXT NOT NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- 15. Avatar Presets Table
CREATE TABLE IF NOT EXISTS avatar_presets (
  id VARCHAR(64) PRIMARY KEY,
  label VARCHAR(100) NOT NULL,
  category VARCHAR(100) DEFAULT 'General',
  url TEXT NOT NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);


