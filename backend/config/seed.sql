-- SpeakUp Database Seed Data

-- Seed Categories
INSERT IGNORE INTO categories (id, title, emoji, card_color_hex, sample_topics_json) VALUES
('tech', 'Technology', '💻', '#3157D5', '["Should artificial intelligence replace some entry-level jobs?","How quantum computing will transform cybersecurity.","Explaining blockchain technology to non-technical users."]'),
('law', 'Law & Justice', '⚖️', '#7C3AED', '["Defending digital privacy in the age of big data.","The ethics of autonomous vehicle liability.","Presenting a closing argument in a mock trial."]'),
('management', 'Management', '📊', '#2BB7A9', '["Handling remote team conflicts productively.","Pitching a quarterly budget increase to stakeholders.","Communicating organizational restructuring with empathy."]'),
('general_knowledge', 'General Knowledge', '🌐', '#0284C7', '["Why space exploration matters for humanity on Earth.","The origin and future of global renewable energy.","How urbanization affects local ecosystems."]'),
('psychology', 'Psychology', '🧠', '#DB2777', '["Overcoming cognitive bias in personal decision making.","The science of habit formation and willpower.","Understanding non-verbal micro-expressions."]'),
('leadership', 'Leadership', '👑', '#FF7A6B', '["Inspiring a team during times of crisis and uncertainty.","Servant leadership versus command-and-control.","How to deliver tough constructive feedback."]'),
('personal_development', 'Personal Development', '🌱', '#42B883', '["Building daily resilience in high-stress environments.","The art of time blocking and deep work focus.","Setting boundaries to protect mental well-being."]'),
('marketing', 'Marketing', '🚀', '#EA580C', '["Crafting a viral brand narrative on social media.","Positioning a new SaaS product in a crowded market.","Ethical marketing versus manipulative copywriting."]'),
('social_life', 'Social Life', '☕', '#F4B740', '["Making a captivating first impression at networking events.","How to give a memorable wedding or birthday toast.","Navigating small talk into deep meaningful conversation."]'),
('history', 'History', '📜', '#D97706', '["How historical speeches changed the course of nations.","Lessons from ancient Roman and Greek rhetoric.","The impact of the industrial revolution on modern work."]');

-- Seed AI Evaluators
INSERT IGNORE INTO ai_evaluators (id, name, title, description, icon, accent_color_hex, focus_area, specialized_scenarios_json, sample_prompt) VALUES
('coach', 'The Coach', 'Everyday speaking practice', 'Supportive and encouraging guidance for building daily habit and vocal ease.', '🎤', '#2BB7A9', 'Natural delivery, vocal ease & daily consistency', '["Everyday conversation introduction","Sharing a personal daily highlight","Explaining an everyday topic simply"]', 'Tell me about something exciting you learned today in under 60 seconds.'),
('executive', 'The Executive', 'Professional communication', 'Focuses on conciseness, executive presence, structure, and strategic clarity.', '💼', '#3157D5', 'Executive presence, conciseness & data delivery', '["Job Interview: Tell me about yourself","Project Status Update to Senior Leadership","Handling manager objections during a proposal"]', 'Briefly present the key metrics and ROI of your recent project.'),
('storyteller', 'The Storyteller', 'Storytelling & presentations', 'Evaluates emotional resonance, narrative structure, hooks, and listener engagement.', '🎙️', '#FF7A6B', 'Narrative hook, vocal inflection & emotional impact', '["TEDx Style Keynote Hook","Inspiring a team with a personal story","Explaining a vision for the future"]', 'Start your presentation with a captivating story or personal anecdote.'),
('advocate', 'The Advocate', 'Persuasion & arguments', 'Sharp analysis of logical arguments, evidence, rebuttal, and persuasive power.', '⚖️', '#F4B740', 'Logical coherence, persuasive arguments & rebuttal', '["Debate: Should AI replace customer service?","Defending a controversial strategic decision","Courtroom opening statement"]', 'Defend your position for 2 minutes against an opposing perspective.'),
('thesis_jury', 'Thesis Defense Jury', 'Academic & technical defense', 'Rigorous examination testing research methodology, evidence, and composure under questioning.', '🎓', '#7C3AED', 'Methodological rigor, precision & defense against academic cross-examination', '["Defending research methodology against jury challenge","Explaining statistical significance and limitations","Answering unexpected technical panel questions"]', 'Present your research findings and justify why your methodology is valid.'),
('debate_opponent', 'The Debate Evaluator', 'Interactive AI Counter-Arguments', 'Simulates a live debate opponent offering real-time counter-arguments and objections.', '⚔️', '#DC2626', 'Spontaneous rebuttal, logical counter-arguments & staying calm under fire', '["Live Rebuttal: Universal Basic Income Debate","Countering an opposing negotiator in business","Refuting a logical fallacy in real-time"]', 'Take a stance on remote work mandates and prepare to counter my objection.'),
('stage', 'The Stage', 'Public speaking & performance', 'Assesses high-stakes delivery, stage panic management, and audience presence.', '🎤', '#8B5CF6', 'Stage presence, projection & composure under pressure', '["Large Conference Keynote","Handling unexpected slide failures gracefully","Town Hall Speech with 200+ attendees"]', 'Deliver a 3-minute speech imagining you are addressing a hall of 500 people.'),
('interview_evaluator', 'Interview Evaluator', 'Corporate & Tech Hiring Manager', 'Evaluates STAR method answers, behavioral responses, conciseness, and executive confidence.', '👔', '#0284C7', 'STAR method structured answers, behavioral Q&A & executive presence', '["Behavioral: Tell me about a time you failed","System Design & Technical explanation for non-tech bosses","Salary negotiation & executive leadership pitch"]', 'Answer this classic interview prompt using the Situation, Task, Action, Result framework.');

-- Seed Simulated Environments
INSERT IGNORE INTO simulated_environments (id, title, icon, description, recommended_evaluator_id, audience_type, noise_level, strictness_options_json) VALUES
('bedroom', 'Personal Bedroom Studio', '🛌', 'Low-pressure private environment ideal for warm-ups and daily speech building.', 'coach', 'Solo practice / AI companion', 'Silent (0 dB)', '["Gentle", "Balanced"]'),
('meeting_room', 'Corporate Conference Room', '💼', 'Simulates a panel of 5 executives evaluating your presentation.', 'executive', 'Senior Leadership Board', 'Low murmur (20 dB)', '["Balanced", "Strict"]'),
('tedx_stage', 'TEDx Stage Auditorium', '🎙️', 'Spotlight stage facing an audience of 300 engaged listeners.', 'storyteller', 'Large Auditorium Audience', 'Responsive applause', '["Balanced", "High Impact"]'),
('courtroom', 'High Courtroom Bench', '⚖️', 'Formal legal setting with a judge and opposing council examining evidence.', 'advocate', 'Judicial Panel & Jury', 'Formal quiet', '["Strict", "Ruthless"]'),
('university_hall', 'Academic Defense Lecture Hall', '🎓', 'Faced with professors and academic peers challenging your thesis.', 'thesis_jury', 'Academic Committee', 'Low whispers', '["Strict", "Jury Defense"]');

-- Seed Subscription Plans
INSERT IGNORE INTO subscription_plans (id, name, price_monthly, price_yearly, is_popular, badge, features_json) VALUES
('free', 'Free Trainee', 0.00, 0.00, 0, NULL, '["3 Practice sessions / week", "Standard AI Evaluator", "Basic score breakdown", "Community access", "0 FCFA Forever Free"]'),
('pro', 'Pro Speaker', 3500.00, 35000.00, 1, 'MOST POPULAR', '["Unlimited practice sessions", "All 8 Specialized AI Evaluators", "Full simulated environments", "Detailed clarity & filler word breakdown", "Personalized book recommendations", "PDF progress reports"]'),
('enterprise', 'Executive Plus', 5500.00, 55000.00, 0, 'VIP', '["Everything in Pro Plan", "1-on-1 Human Speech Coach review", "Custom simulated environment builder", "Priority AI response latency", "Team collaboration dashboard"]');

-- Seed Speaking Obstacles
INSERT IGNORE INTO speaking_obstacles (id, title, emoji, subtitle, theme_color_hex) VALUES
('confidence', 'Confidence', '😰', 'I am afraid of speaking in front of people', '#FF7A6B'),
('clarity', 'Clarity', '🗣️', 'People do not always understand my ideas', '#3157D5'),
('pace', 'Speaking Pace', '⏱️', 'I speak too fast or stumble when rushed', '#2BB7A9'),
('fluency', 'Fluency', '🤐', 'I often hesitate or search for words', '#42B883'),
('storytelling', 'Storytelling', '📖', 'I struggle to make my speeches interesting', '#F4B740'),
('stage_fright', 'Stage Fright', '🎤', 'I panic when everyone looks at me', '#E56B6F');

-- Seed Journey Stages
INSERT IGNORE INTO journey_stages (id, obstacle_id, stage_number, environment_name, environment_emoji, title, description) VALUES
('stg_conf_1', 'confidence', 1, 'Your Room', '🌱', 'Find Your Voice', 'Safe solo space to speak out loud without judgment.'),
('stg_conf_2', 'confidence', 2, 'Small Conversation', '☕', 'Speak Without Fear', 'Practice speaking in 1-on-1 informal settings.'),
('stg_conf_3', 'confidence', 3, 'Meeting Room', '💼', 'Speak Under Pressure', 'Handle unexpected questions during a group meeting.'),
('stg_clar_1', 'clarity', 1, 'Your Desk', '📝', 'Simple Structures', 'Trim fluff and speak with razor-sharp clarity.');

-- Seed Journey Nodes
INSERT IGNORE INTO journey_nodes (id, stage_id, title, situation_prompt, duration_seconds, difficulty, xp_reward) VALUES
('conf_1_1', 'stg_conf_1', 'Introduce Yourself for 30 seconds', 'Describe your name, what you do, and one secret passion you have in 30 seconds.', 30, 'Easy', 50),
('conf_1_2', 'stg_conf_1', 'Talk About Something You Love', 'Pick a favorite hobby, movie, or food. Explain why you love it in 45 seconds.', 45, 'Easy', 60),
('conf_1_3', 'stg_conf_1', 'Express Your Pure Opinion', 'State your honest opinion on whether working from home is better than office work.', 60, 'Easy', 75),
('conf_2_1', 'stg_conf_2', 'Spontaneous Answer', 'A colleague at coffee breaks asks: What did you do over the weekend? Answer spontaneously.', 60, 'Medium', 90),
('conf_2_2', 'stg_conf_2', 'Explain an Unfamiliar Topic', 'Explain quantum physics or AI to a 10-year-old child in simple terms.', 90, 'Medium', 100),
('conf_3_1', 'stg_conf_3', 'Manager Sudden Question', 'Your manager asks: What is your main priority this quarter? Respond in 60 seconds.', 60, 'Hard', 120),
('conf_3_2', 'stg_conf_3', 'Debate an AI Objection', 'Defend your project timeline when a team member objects it is too slow.', 90, 'Hard', 150),
('clar_1_1', 'stg_clar_1', 'Explain an Object in 3 Sentences', 'Describe how a smartphone works using only 3 simple sentences.', 30, 'Easy', 50),
('clar_1_2', 'stg_clar_1', 'Remove Filler Words Challenge', 'Explain why water is essential without saying um, like, or ah.', 45, 'Medium', 80);

-- Seed Default Users
-- Default Trainee: Amina Bello (password: password123)
-- Default Admin: Platform Administrator (password: admin123)
INSERT IGNORE INTO users (id, name, email, password_hash, role, streak_days, total_xp, current_plan_id, obstacle_id) VALUES
('usr_amina', 'Amina Bello', 'amina@speakup.ai', '$2a$10$7R9bZtQyD.GZl2M3v8X7e.X6E9R1T2W3Y4U5I6O7P8Q9R0S1T2U3V', 'Trainee', 7, 520, 'pro', 'confidence'),
('usr_admin', 'Platform Administrator', 'admin@speakup.ai', '$2a$10$7R9bZtQyD.GZl2M3v8X7e.X6E9R1T2W3Y4U5I6O7P8Q9R0S1T2U3V', 'Admin', 30, 2400, 'enterprise', 'confidence');

-- Seed Initial Completed Nodes for Amina
INSERT IGNORE INTO user_node_progress (id, user_id, node_id) VALUES
('unp_1', 'usr_amina', 'conf_1_1'),
('unp_2', 'usr_amina', 'conf_1_2'),
('unp_3', 'usr_amina', 'clar_1_1');

-- Seed Daily Knowledge Briefs
INSERT IGNORE INTO daily_briefs (id, brief_date, category, topic, emoji, summary_text, key_facts_json, suggested_prompt) VALUES
('db_1', '2026-09-13', 'Technology & AI', 'Quantum Computing in 2026', '⚛️', 'Quantum computing harnesses superposition and entanglement to solve complex optimizations in seconds rather than centuries.', '["Qubits can exist in multiple states simultaneously.", "Error correction reached 99.9% fidelity in 2026.", "Main applications include drug discovery and financial modeling."]', 'Explain quantum superposition to a high school student in under 60 seconds.'),
('db_2', '2026-09-12', 'Leadership & Rhetoric', 'The Power of Strategic Pauses', '🎙️', 'Top public speakers use 2-to-3 second deliberate pauses before key assertions to increase audience retention by 40%.', '["Silence creates anticipation and projects confidence.", "Pausing replaces nervous filler words like um and ah.", "Gives listeners time to digest complex technical ideas."]', 'Deliver a short proposal on remote work using three distinct 2-second pauses.');

-- Seed Skill Rules
INSERT IGNORE INTO skill_rules (id, title, focus_area, min_score_threshold, max_filler_words, guidance_tip) VALUES
('rule_1', 'Executive Clarity Standard', 'Executive Presence', 80, 2, 'Pause 2 seconds before key assertions to maintain composed authority.'),
('rule_2', 'Pace & Rhythm Consistency', 'Speaking Pace', 75, 3, 'Maintain tempo between 130-150 words per minute to ensure optimal comprehension.'),
('rule_3', 'Thesis Defense Composure', 'Academic Defense', 85, 1, 'Cite empirical evidence directly under cross-examination without defensive hesitation.'),
('rule_4', 'Persuasive Hook Structure', 'Storytelling', 78, 3, 'Open speech with a personal anecdote or provocative metric in the first 15 seconds.');

-- Seed Exercises
INSERT IGNORE INTO exercises (id, title, category_id, evaluator_name, target_duration_seconds, sample_prompt) VALUES
('ex_1', 'AI Ethics in Entry Jobs', 'tech', 'The Coach', 60, 'Should artificial intelligence replace some entry-level jobs?'),
('ex_2', 'Remote Team Conflict Resolution', 'management', 'The Executive', 90, 'How to handle remote team conflicts productively and pitch a win-win solution.'),
('ex_3', 'Digital Privacy Defense', 'law', 'The Advocate', 120, 'Defend user digital privacy rights in the age of generative AI and big data.'),
('ex_4', 'First Impression Networking', 'social_life', 'The Storyteller', 45, 'Make a captivating first impression at high-stakes networking events in 45 seconds.');

-- Seed Avatar Presets
INSERT IGNORE INTO avatar_presets (id, label, category, url) VALUES
('av_1', 'Amina (Speaker)', 'Professional', 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=300&auto=format&fit=crop&q=80'),
('av_2', 'Executive Leader', 'Corporate', 'https://images.unsplash.com/photo-1573496359142-b8d87734a5a2?w=300&auto=format&fit=crop&q=80'),
('av_3', 'Tech Innovator', 'Technology', 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=300&auto=format&fit=crop&q=80'),
('av_4', 'Keynote Presenter', 'Keynote', 'https://images.unsplash.com/photo-1580489944761-15a19d654956?w=300&auto=format&fit=crop&q=80'),
('av_5', 'Visionary Coach', 'Coaching', 'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=300&auto=format&fit=crop&q=80'),
('av_6', 'Speech Mentor', 'Education', 'https://images.unsplash.com/photo-1544005313-94ddf0286df2?w=300&auto=format&fit=crop&q=80'),
('av_7', 'Debate Champion', 'Debate', 'https://images.unsplash.com/photo-1539571696357-5a69c17a67c6?w=300&auto=format&fit=crop&q=80'),
('av_8', 'Creative Storyteller', 'Storytelling', 'https://images.unsplash.com/photo-1517841905240-472988babdf9?w=300&auto=format&fit=crop&q=80');


