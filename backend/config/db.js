const mysql = require('mysql2/promise');
const fs = require('fs');
const path = require('path');

let pool = null;
let isUsingFallback = false;

// Memory Fallback Store if MySQL DB is not running locally
const memoryStore = {
  users: [
    {
      id: 'usr_amina',
      name: 'Amina Bello',
      email: 'amina@speakup.ai',
      password_hash: '$2a$10$7R9bZtQyD.GZl2M3v8X7e.X6E9R1T2W3Y4U5I6O7P8Q9R0S1T2U3V',
      role: 'Trainee',
      streak_days: 7,
      total_xp: 520,
      current_plan_id: 'pro',
      obstacle_id: 'confidence',
    },
    {
      id: 'usr_admin',
      name: 'Platform Administrator',
      email: 'admin@speakup.ai',
      password_hash: '$2a$10$7R9bZtQyD.GZl2M3v8X7e.X6E9R1T2W3Y4U5I6O7P8Q9R0S1T2U3V',
      role: 'Admin',
      streak_days: 30,
      total_xp: 2400,
      current_plan_id: 'enterprise',
      obstacle_id: 'confidence',
    }
  ],
  categories: [
    { id: 'tech', title: 'Technology', emoji: '💻', card_color_hex: '#3157D5', sample_topics_json: '["Should artificial intelligence replace some entry-level jobs?","How quantum computing will transform cybersecurity.","Explaining blockchain technology to non-technical users."]' },
    { id: 'law', title: 'Law & Justice', emoji: '⚖️', card_color_hex: '#7C3AED', sample_topics_json: '["Defending digital privacy in the age of big data.","The ethics of autonomous vehicle liability.","Presenting a closing argument in a mock trial."]' },
    { id: 'management', title: 'Management', emoji: '📊', card_color_hex: '#2BB7A9', sample_topics_json: '["Handling remote team conflicts productively.","Pitching a quarterly budget increase to stakeholders.","Communicating organizational restructuring with empathy."]' },
    { id: 'general_knowledge', title: 'General Knowledge', emoji: '🌐', card_color_hex: '#0284C7', sample_topics_json: '["Why space exploration matters for humanity on Earth.","The origin and future of global renewable energy.","How urbanization affects local ecosystems."]' },
    { id: 'psychology', title: 'Psychology', emoji: '🧠', card_color_hex: '#DB2777', sample_topics_json: '["Overcoming cognitive bias in personal decision making.","The science of habit formation and willpower.","Understanding non-verbal micro-expressions."]' },
    { id: 'leadership', title: 'Leadership', emoji: '👑', card_color_hex: '#FF7A6B', sample_topics_json: '["Inspiring a team during times of crisis and uncertainty.","Servant leadership versus command-and-control.","How to deliver tough constructive feedback."]' },
    { id: 'personal_development', title: 'Personal Development', emoji: '🌱', card_color_hex: '#42B883', sample_topics_json: '["Building daily resilience in high-stress environments.","The art of time blocking and deep work focus.","Setting boundaries to protect mental well-being."]' },
    { id: 'marketing', title: 'Marketing', emoji: '🚀', card_color_hex: '#EA580C', sample_topics_json: '["Crafting a viral brand narrative on social media.","Positioning a new SaaS product in a crowded market.","Ethical marketing versus manipulative copywriting."]' },
    { id: 'social_life', title: 'Social Life', emoji: '☕', card_color_hex: '#F4B740', sample_topics_json: '["Making a captivating first impression at networking events.","How to give a memorable wedding or birthday toast.","Navigating small talk into deep meaningful conversation."]' },
    { id: 'history', title: 'History', emoji: '📜', card_color_hex: '#D97706', sample_topics_json: '["How historical speeches changed the course of nations.","Lessons from ancient Roman and Greek rhetoric.","The impact of the industrial revolution on modern work."]' }
  ],
  ai_evaluators: [
    { id: 'coach', name: 'The Coach', title: 'Everyday speaking practice', description: 'Supportive and encouraging guidance for building daily habit and vocal ease.', icon: '🎤', accent_color_hex: '#2BB7A9', focus_area: 'Natural delivery, vocal ease & daily consistency', specialized_scenarios_json: '["Everyday conversation introduction","Sharing a personal daily highlight","Explaining an everyday topic simply"]', sample_prompt: 'Tell me about something exciting you learned today in under 60 seconds.' },
    { id: 'executive', name: 'The Executive', title: 'Professional communication', description: 'Focuses on conciseness, executive presence, structure, and strategic clarity.', icon: '💼', accent_color_hex: '#3157D5', focus_area: 'Executive presence, conciseness & data delivery', specialized_scenarios_json: '["Job Interview: Tell me about yourself","Project Status Update to Senior Leadership","Handling manager objections during a proposal"]', sample_prompt: 'Briefly present the key metrics and ROI of your recent project.' },
    { id: 'storyteller', name: 'The Storyteller', title: 'Storytelling & presentations', description: 'Evaluates emotional resonance, narrative structure, hooks, and listener engagement.', icon: '🎙️', accent_color_hex: '#FF7A6B', focus_area: 'Narrative hook, vocal inflection & emotional impact', specialized_scenarios_json: '["TEDx Style Keynote Hook","Inspiring a team with a personal story","Explaining a vision for the future"]', sample_prompt: 'Start your presentation with a captivating story or personal anecdote.' },
    { id: 'advocate', name: 'The Advocate', title: 'Persuasion & arguments', description: 'Sharp analysis of logical arguments, evidence, rebuttal, and persuasive power.', icon: '⚖️', accent_color_hex: '#F4B740', focus_area: 'Logical coherence, persuasive arguments & rebuttal', specialized_scenarios_json: '["Debate: Should AI replace customer service?","Defending a controversial strategic decision","Courtroom opening statement"]', sample_prompt: 'Defend your position for 2 minutes against an opposing perspective.' },
    { id: 'thesis_jury', name: 'Thesis Defense Jury', title: 'Academic & technical defense', description: 'Rigorous examination testing research methodology, evidence, and composure under questioning.', icon: '🎓', accent_color_hex: '#7C3AED', focus_area: 'Methodological rigor, precision & defense against academic cross-examination', specialized_scenarios_json: '["Defending research methodology against jury challenge","Explaining statistical significance and limitations","Answering unexpected technical panel questions"]', sample_prompt: 'Present your research findings and justify why your methodology is valid.' },
    { id: 'debate_opponent', name: 'The Debate Evaluator', title: 'Interactive AI Counter-Arguments', description: 'Simulates a live debate opponent offering real-time counter-arguments and objections.', icon: '⚔️', accent_color_hex: '#DC2626', focus_area: 'Spontaneous rebuttal, logical counter-arguments & staying calm under fire', specialized_scenarios_json: '["Live Rebuttal: Universal Basic Income Debate","Countering an opposing negotiator in business","Refuting a logical fallacy in real-time"]', sample_prompt: 'Take a stance on remote work mandates and prepare to counter my objection.' },
    { id: 'stage', name: 'The Stage', title: 'Public speaking & performance', description: 'Assesses high-stakes delivery, stage panic management, and audience presence.', icon: '🎤', accent_color_hex: '#8B5CF6', focus_area: 'Stage presence, projection & composure under pressure', specialized_scenarios_json: '["Large Conference Keynote","Handling unexpected slide failures gracefully","Town Hall Speech with 200+ attendees"]', sample_prompt: 'Deliver a 3-minute speech imagining you are addressing a hall of 500 people.' },
    { id: 'interview_evaluator', name: 'Interview Evaluator', title: 'Corporate & Tech Hiring Manager', description: 'Evaluates STAR method answers, behavioral responses, conciseness, and executive confidence.', icon: '👔', accent_color_hex: '#0284C7', focus_area: 'STAR method structured answers, behavioral Q&A & executive presence', specialized_scenarios_json: '["Behavioral: Tell me about a time you failed","System Design & Technical explanation for non-tech bosses","Salary negotiation & executive leadership pitch"]', sample_prompt: 'Answer this classic interview prompt using the Situation, Task, Action, Result framework.' }
  ],
  simulated_environments: [
    { id: 'bedroom', title: 'Personal Bedroom Studio', icon: '🛌', description: 'Low-pressure private environment ideal for warm-ups and daily speech building.', recommended_evaluator_id: 'coach', audience_type: 'Solo practice / AI companion', noise_level: 'Silent (0 dB)', strictness_options_json: '["Gentle", "Balanced"]' },
    { id: 'meeting_room', title: 'Corporate Conference Room', icon: '💼', description: 'Simulates a panel of 5 executives evaluating your presentation.', recommended_evaluator_id: 'executive', audience_type: 'Senior Leadership Board', noise_level: 'Low murmur (20 dB)', strictness_options_json: '["Balanced", "Strict"]' },
    { id: 'tedx_stage', title: 'TEDx Stage Auditorium', icon: '🎙️', description: 'Spotlight stage facing an audience of 300 engaged listeners.', recommended_evaluator_id: 'storyteller', audience_type: 'Large Auditorium Audience', noise_level: 'Responsive applause', strictness_options_json: '["Balanced", "High Impact"]' },
    { id: 'courtroom', title: 'High Courtroom Bench', icon: '⚖️', description: 'Formal legal setting with a judge and opposing council examining evidence.', recommended_evaluator_id: 'advocate', audience_type: 'Judicial Panel & Jury', noise_level: 'Formal quiet', strictness_options_json: '["Strict", "Ruthless"]' },
    { id: 'university_hall', title: 'Academic Defense Lecture Hall', icon: '🎓', description: 'Faced with professors and academic peers challenging your thesis.', recommended_evaluator_id: 'thesis_jury', audience_type: 'Academic Committee', noise_level: 'Low whispers', strictness_options_json: '["Strict", "Jury Defense"]' }
  ],
  subscription_plans: [
    { id: 'free', name: 'Free Trainee', price_monthly: 0.00, price_yearly: 0.00, is_popular: 0, badge: null, features_json: '["3 Practice sessions / week", "Standard AI Evaluator", "Basic score breakdown", "Community access", "0 FCFA Forever Free"]' },
    { id: 'pro', name: 'Pro Speaker', price_monthly: 3500.00, price_yearly: 35000.00, is_popular: 1, badge: 'MOST POPULAR', features_json: '["Unlimited practice sessions", "All 8 Specialized AI Evaluators", "Full simulated environments", "Detailed clarity & filler word breakdown", "Personalized book recommendations", "PDF progress reports"]' },
    { id: 'enterprise', name: 'Executive Plus', price_monthly: 5500.00, price_yearly: 55000.00, is_popular: 0, badge: 'VIP', features_json: '["Everything in Pro Plan", "1-on-1 Human Speech Coach review", "Custom simulated environment builder", "Priority AI response latency", "Team collaboration dashboard"]' }
  ],
  speaking_obstacles: [
    { id: 'confidence', title: 'Confidence', emoji: '😰', subtitle: 'I am afraid of speaking in front of people', theme_color_hex: '#FF7A6B' },
    { id: 'clarity', title: 'Clarity', emoji: '🗣️', subtitle: 'People do not always understand my ideas', theme_color_hex: '#3157D5' },
    { id: 'pace', title: 'Speaking Pace', emoji: '⏱️', subtitle: 'I speak too fast or stumble when rushed', theme_color_hex: '#2BB7A9' },
    { id: 'fluency', title: 'Fluency', emoji: '🤐', subtitle: 'I often hesitate or search for words', theme_color_hex: '#42B883' },
    { id: 'storytelling', title: 'Storytelling', emoji: '📖', subtitle: 'I struggle to make my speeches interesting', theme_color_hex: '#F4B740' },
    { id: 'stage_fright', title: 'Stage Fright', emoji: '🎤', subtitle: 'I panic when everyone looks at me', theme_color_hex: '#E56B6F' }
  ],
  journey_stages: [
    { id: 'stg_conf_1', obstacle_id: 'confidence', stage_number: 1, environment_name: 'Your Room', environment_emoji: '🌱', title: 'Find Your Voice', description: 'Safe solo space to speak out loud without judgment.' },
    { id: 'stg_conf_2', obstacle_id: 'confidence', stage_number: 2, environment_name: 'Small Conversation', environment_emoji: '☕', title: 'Speak Without Fear', description: 'Practice speaking in 1-on-1 informal settings.' },
    { id: 'stg_conf_3', obstacle_id: 'confidence', stage_number: 3, environment_name: 'Meeting Room', environment_emoji: '💼', title: 'Speak Under Pressure', description: 'Handle unexpected questions during a group meeting.' },
    { id: 'stg_clar_1', obstacle_id: 'clarity', stage_number: 1, environment_name: 'Your Desk', environment_emoji: '📝', title: 'Simple Structures', description: 'Trim fluff and speak with razor-sharp clarity.' }
  ],
  journey_nodes: [
    { id: 'conf_1_1', stage_id: 'stg_conf_1', title: 'Introduce Yourself for 30 seconds', situation_prompt: 'Describe your name, what you do, and one secret passion you have in 30 seconds.', duration_seconds: 30, difficulty: 'Easy', xp_reward: 50 },
    { id: 'conf_1_2', stage_id: 'stg_conf_1', title: 'Talk About Something You Love', situation_prompt: 'Pick a favorite hobby, movie, or food. Explain why you love it in 45 seconds.', duration_seconds: 45, difficulty: 'Easy', xp_reward: 60 },
    { id: 'conf_1_3', stage_id: 'stg_conf_1', title: 'Express Your Pure Opinion', situation_prompt: 'State your honest opinion on whether working from home is better than office work.', duration_seconds: 60, difficulty: 'Easy', xp_reward: 75 },
    { id: 'conf_2_1', stage_id: 'stg_conf_2', title: 'Spontaneous Answer', situation_prompt: 'A colleague at coffee breaks asks: What did you do over the weekend? Answer spontaneously.', duration_seconds: 60, difficulty: 'Medium', xp_reward: 90 },
    { id: 'conf_2_2', stage_id: 'stg_conf_2', title: 'Explain an Unfamiliar Topic', situation_prompt: 'Explain quantum physics or AI to a 10-year-old child in simple terms.', duration_seconds: 90, difficulty: 'Medium', xp_reward: 100 },
    { id: 'conf_3_1', stage_id: 'stg_conf_3', title: 'Manager Sudden Question', situation_prompt: 'Your manager asks: What is your main priority this quarter? Respond in 60 seconds.', duration_seconds: 60, difficulty: 'Hard', xp_reward: 120 },
    { id: 'conf_3_2', stage_id: 'stg_conf_3', title: 'Debate an AI Objection', situation_prompt: 'Defend your project timeline when a team member objects it is too slow.', duration_seconds: 90, difficulty: 'Hard', xp_reward: 150 },
    { id: 'clar_1_1', stage_id: 'stg_clar_1', title: 'Explain an Object in 3 Sentences', situation_prompt: 'Describe how a smartphone works using only 3 simple sentences.', duration_seconds: 30, difficulty: 'Easy', xp_reward: 50 },
    { id: 'clar_1_2', stage_id: 'stg_clar_1', title: 'Remove Filler Words Challenge', situation_prompt: 'Explain why water is essential without saying um, like, or ah.', duration_seconds: 45, difficulty: 'Medium', xp_reward: 80 }
  ],
  user_node_progress: [
    { id: 'unp_1', user_id: 'usr_amina', node_id: 'conf_1_1', completed_at: new Date() },
    { id: 'unp_2', user_id: 'usr_amina', node_id: 'conf_1_2', completed_at: new Date() },
    { id: 'unp_3', user_id: 'usr_amina', node_id: 'clar_1_1', completed_at: new Date() }
  ],
  practice_sessions: [
    {
      id: 'sess_101',
      user_id: 'usr_amina',
      mode: 'full',
      evaluator_id: 'thesis_jury',
      evaluator_name: 'Thesis Defense Jury',
      category_id: 'tech',
      topic: 'Should artificial intelligence replace customer service workers?',
      duration_seconds: 112,
      overall_score: 82,
      clarity_score: 88,
      confidence_score: 78,
      pace_score: 85,
      fluency_score: 74,
      structure_score: 86,
      filler_word_count: 3,
      transcript: 'In my view, while artificial intelligence offers remarkable efficiency gains in routine inquiries, human customer service remains indispensable for high-empathy scenarios. Um, companies should aim for a hybrid model where AI handles basic triage while human agents handle complex concerns.',
      strengths_json: '["Clear logical structure with defined main point","Strong executive vocabulary and tone","Excellent articulation on technical terms"]',
      weaknesses_json: '["Slight hesitation when transitioning to the second point","Pace sped up slightly near the 90-second mark"]',
      how_to_improve: 'Before speaking, take 5 seconds to mentally list your 2 supporting pillars. Insert a 2-second deliberate pause before transitioning to maintain calm authority.',
      next_recommended_exercise: 'Defend your hybrid model recommendation against a budget objection.',
      recommended_books_json: '[{"title":"Talk Like TED","author":"Carmine Gallo","coverEmoji":"🎙️","keyTakeaway":"Master the 9 public speaking secrets of the world\'s top minds.","accentColorHex":"#3157D5"},{"title":"Made to Stick","author":"Chip Heath & Dan Heath","coverEmoji":"💡","keyTakeaway":"Why some ideas survive and others die in communication.","accentColorHex":"#FF7A6B"}]',
      audience_questions_json: '[{"question":"Jury Question: Why did you choose a hybrid model over full automation?","speakerAnswer":"A hybrid model mitigates operational risk. While automation handles 70% of low-complexity tickets, high-churn customer accounts require human empathy to prevent churn."}]',
      is_saved_in_inbox: 1,
      created_at: new Date()
    }
  ],
  daily_briefs: [
    {
      id: 'db_1',
      brief_date: '2026-09-13',
      category: 'Technology & AI',
      topic: 'Quantum Computing in 2026',
      emoji: '⚛️',
      summary_text: 'Quantum computing harnesses superposition and entanglement to solve complex optimizations in seconds rather than centuries.',
      key_facts_json: '["Qubits can exist in multiple states simultaneously.", "Error correction reached 99.9% fidelity in 2026.", "Main applications include drug discovery and financial modeling."]',
      suggested_prompt: 'Explain quantum superposition to a high school student in under 60 seconds.'
    },
    {
      id: 'db_2',
      brief_date: '2026-09-12',
      category: 'Leadership & Rhetoric',
      topic: 'The Power of Strategic Pauses',
      emoji: '🎙️',
      summary_text: 'Top public speakers use 2-to-3 second deliberate pauses before key assertions to increase audience retention by 40%.',
      key_facts_json: '["Silence creates anticipation and projects confidence.", "Pausing replaces nervous filler words like um and ah.", "Gives listeners time to digest complex technical ideas."]',
      suggested_prompt: 'Deliver a short proposal on remote work using three distinct 2-second pauses.'
    }
  ],
  user_brief_reads: [
    { id: 'ubr_1', user_id: 'usr_amina', brief_id: 'db_2', read_at: new Date() }
  ],
  skill_rules: [
    {
      id: 'rule_1',
      title: 'Executive Clarity Standard',
      focus_area: 'Executive Presence',
      min_score_threshold: 80,
      max_filler_words: 2,
      guidance_tip: 'Pause 2 seconds before key assertions to maintain composed authority.'
    },
    {
      id: 'rule_2',
      title: 'Pace & Rhythm Consistency',
      focus_area: 'Speaking Pace',
      min_score_threshold: 75,
      max_filler_words: 3,
      guidance_tip: 'Maintain tempo between 130-150 words per minute to ensure optimal comprehension.'
    },
    {
      id: 'rule_3',
      title: 'Thesis Defense Composure',
      focus_area: 'Academic Defense',
      min_score_threshold: 85,
      max_filler_words: 1,
      guidance_tip: 'Cite empirical evidence directly under cross-examination without defensive hesitation.'
    },
    {
      id: 'rule_4',
      title: 'Persuasive Hook Structure',
      focus_area: 'Storytelling',
      min_score_threshold: 78,
      max_filler_words: 3,
      guidance_tip: 'Open speech with a personal anecdote or provocative metric in the first 15 seconds.'
    }
  ],
  exercises: [
    {
      id: 'ex_1',
      title: 'AI Ethics in Entry Jobs',
      category_id: 'tech',
      evaluator_name: 'The Coach',
      target_duration_seconds: 60,
      sample_prompt: 'Should artificial intelligence replace some entry-level jobs?'
    },
    {
      id: 'ex_2',
      title: 'Remote Team Conflict Resolution',
      category_id: 'management',
      evaluator_name: 'The Executive',
      target_duration_seconds: 90,
      sample_prompt: 'How to handle remote team conflicts productively and pitch a win-win solution.'
    },
    {
      id: 'ex_3',
      title: 'Digital Privacy Defense',
      category_id: 'law',
      evaluator_name: 'The Advocate',
      target_duration_seconds: 120,
      sample_prompt: 'Defend user digital privacy rights in the age of generative AI and big data.'
    },
    {
      id: 'ex_4',
      title: 'First Impression Networking',
      category_id: 'social_life',
      evaluator_name: 'The Storyteller',
      target_duration_seconds: 45,
      sample_prompt: 'Make a captivating first impression at high-stakes networking events in 45 seconds.'
    }
  ],
  avatar_presets: [
    { id: 'av_1', label: 'Amina (Speaker)', category: 'Professional', url: 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=300&auto=format&fit=crop&q=80' },
    { id: 'av_2', label: 'Executive Leader', category: 'Corporate', url: 'https://images.unsplash.com/photo-1573496359142-b8d87734a5a2?w=300&auto=format&fit=crop&q=80' },
    { id: 'av_3', label: 'Tech Innovator', category: 'Technology', url: 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=300&auto=format&fit=crop&q=80' },
    { id: 'av_4', label: 'Keynote Presenter', category: 'Keynote', url: 'https://images.unsplash.com/photo-1580489944761-15a19d654956?w=300&auto=format&fit=crop&q=80' },
    { id: 'av_5', label: 'Visionary Coach', category: 'Coaching', url: 'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=300&auto=format&fit=crop&q=80' },
    { id: 'av_6', label: 'Speech Mentor', category: 'Education', url: 'https://images.unsplash.com/photo-1544005313-94ddf0286df2?w=300&auto=format&fit=crop&q=80' },
    { id: 'av_7', label: 'Debate Champion', category: 'Debate', url: 'https://images.unsplash.com/photo-1539571696357-5a69c17a67c6?w=300&auto=format&fit=crop&q=80' },
    { id: 'av_8', label: 'Creative Storyteller', category: 'Storytelling', url: 'https://images.unsplash.com/photo-1517841905240-472988babdf9?w=300&auto=format&fit=crop&q=80' }
  ]
};



async function initDB() {
  const host = process.env.DB_HOST || 'localhost';
  const port = process.env.DB_PORT || 3306;
  const user = process.env.DB_USER || 'root';
  const password = process.env.DB_PASSWORD || '';
  const database = process.env.DB_NAME || 'speakup_db';

  try {
    // Attempt connecting to MySQL server
    const connection = await mysql.createConnection({
      host,
      port: Number(port),
      user,
      password,
      multipleStatements: true
    });
    await connection.query(`CREATE DATABASE IF NOT EXISTS \`${database}\`;`);
    await connection.end();

    pool = mysql.createPool({
      host,
      port: Number(port),
      user,
      password,
      database,
      waitForConnections: true,
      connectionLimit: 10,
      queueLimit: 0,
      multipleStatements: true
    });

    // Execute schema and seed
    const schemaPath = path.join(__dirname, 'schema.sql');
    const seedPath = path.join(__dirname, 'seed.sql');

    if (fs.existsSync(schemaPath)) {
      const schemaSql = fs.readFileSync(schemaPath, 'utf8');
      await pool.query(schemaSql);
    }

    if (fs.existsSync(seedPath)) {
      const seedSql = fs.readFileSync(seedPath, 'utf8');
      await pool.query(seedSql);
    }

    console.log(`=======================================================`);
    console.log(`🟢 [MySQL Persistent DB] Connected to database '${database}' on ${host}:${port}`);
    console.log(`💾 All logins, practice sessions, XP, and streak data are PERMANENTLY saved to MySQL.`);
    console.log(`=======================================================`);
    isUsingFallback = false;
  } catch (err) {
    console.warn(`[MySQL Notice] Local MySQL connection failed (${err.message}). Activating In-Memory State Engine Fallback.`);
    isUsingFallback = true;
  }
}

async function query(sql, params = []) {
  if (!isUsingFallback && pool) {
    try {
      const [rows] = await pool.execute(sql, params);
      return rows;
    } catch (err) {
      console.warn(`[MySQL Query Error] Falling back to Memory Engine: ${err.message}`);
    }
  }
  return null; // Signals controller/repository to consult fallback store
}

module.exports = {
  initDB,
  query,
  memoryStore,
  getIsFallback: () => isUsingFallback
};
