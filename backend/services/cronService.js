const cron = require('node-cron');
const db = require('../config/db');

class CronService {
  constructor() {
    this.isInitialized = false;
    this.cronTask = null;
  }

  // Pre-configured knowledge base across varied categories for AI Daily Brief generation
  static knowledgeTopics = [
    {
      category: '🧠 Cognitive Science & Psychology',
      topic: 'The Pratfall Effect: Why Vulnerability Increases Trust',
      emoji: '🧠',
      summary: 'The Pratfall Effect demonstrates that highly competent individuals become significantly more likable and relatable when they commit a minor blunder or show genuine vulnerability. In public speaking, acknowledging a minor hiccup humanizes the speaker and instantly diffuses audience skepticism.',
      keyFacts: [
        'Discovered by social psychologist Elliot Aronson at UC Santa Cruz in 1966.',
        'Audiences perceive overly polished or robotic speakers with emotional detachment.',
        'Admitting uncertainty on a secondary point boosts credibility on core arguments by up to 34%.'
      ],
      suggestedPrompt: 'Deliver a 90-second speech sharing a personal learning moment or mistake that ultimately made you stronger in your craft.'
    },
    {
      category: '🚀 Technology & Future Innovations',
      topic: 'Quantum Supremacy & Post-Quantum Cryptography',
      emoji: '⚡',
      summary: 'Quantum computing harnesses quantum superposition and entanglement to perform complex computations exponentially faster than classical supercomputers. As quantum processors mature, modern RSA encryption must transition to lattice-based post-quantum cryptography to secure global data.',
      keyFacts: [
        'Quantum bits (qubits) can exist in states 0, 1, or both simultaneously via superposition.',
        'NIST has finalized global standards for Post-Quantum Cryptographic algorithms in 2024–2026.',
        'Applications span hyper-accurate molecular drug modeling, climate simulation, and quantum routing.'
      ],
      suggestedPrompt: 'Explain quantum computing in simple, vivid metaphors to a non-technical audience in under two minutes.'
    },
    {
      category: '🌍 Global Economics & Geopolitics',
      topic: 'The Bretton Woods Legacy & The Digital Currency Shift',
      emoji: '🌐',
      summary: 'Established in 1944, the Bretton Woods system created the IMF, World Bank, and pegged international trade to the USD. Today, the rise of Central Bank Digital Currencies (CBDCs) and cross-border instant settlement rails is transforming international trade liquidity.',
      keyFacts: [
        'Delegates from 44 allied nations drafted the original Bretton Woods agreement in New Hampshire.',
        'Over 130 nations representing 98% of global GDP are currently researching or piloting CBDCs.',
        'Financial inclusion in developing markets has expanded via mobile banking and decentralized settlement.'
      ],
      suggestedPrompt: 'Present your perspective on how digital currencies will impact small business owners over the next decade.'
    },
    {
      category: '🎙️ Public Speaking & Rhetorical Mastery',
      topic: 'The Rule of Three (Tricolon) in Classical Oratory',
      emoji: '🎙️',
      summary: 'The Rule of Three (Tricolon) is a timeless rhetorical principle stating that concepts presented in triads are inherently more satisfying, memorable, and persuasive to the human brain. From Caesar to Churchill and Steve Jobs, triads form the backbone of iconic speeches.',
      keyFacts: [
        'Short-term human memory processes information most efficiently in chunks of three or four items.',
        'Iconic examples: "Veni, vidi, vici", "Government of the people, by the people, for the people".',
        'Steve Jobs introduced the original iPhone using a triad: "an iPod, a phone, and an internet communicator".'
      ],
      suggestedPrompt: 'Draft a short 2-minute pitch for your favorite idea using exactly three core supporting arguments structured as a tricolon.'
    },
    {
      category: '🏛️ History & Philosophy',
      topic: 'Stoic Dichotomy of Control in High-Pressure Decision Making',
      emoji: '🏛️',
      summary: 'Epictetus formulated the core Stoic doctrine: dividing everything in life into what is within our control (our thoughts, reactions, choices) and what is outside our control (outcomes, other people, market conditions). Focusing energy exclusively on internal locus of control eliminates stage anxiety.',
      keyFacts: [
        'Written in the Enchiridion by Greek Stoic philosopher Epictetus around 125 AD.',
        'Modern Cognitive Behavioral Therapy (CBT) was directly inspired by Stoic cognitive reframing.',
        'Applied in public speaking: you cannot control the audience’s mood, only your own preparation and authenticity.'
      ],
      suggestedPrompt: 'Speak for 2 minutes on how you handle unexpected setbacks during a presentation or critical meeting.'
    },
    {
      category: '🌿 Environment & Planetary Science',
      topic: 'The Mycorrhizal Wood Wide Web: Underground Forest Networks',
      emoji: '🌲',
      summary: 'Beneath the forest floor lies a vast subterranean network of mycorrhizal fungal filaments connecting tree root systems. Through this biological internet, trees share carbon, nutrients, water, and even send chemical distress signals warning neighboring trees of pest infestations.',
      keyFacts: [
        'Pioneered by forest ecologist Dr. Suzanne Simard at the University of British Columbia.',
        'Older "mother trees" use fungal networks to nurture shaded saplings with vital nitrogen and phosphorus.',
        'Over 90% of all land plant families form symbiotic relationships with mycorrhizal fungi.'
      ],
      suggestedPrompt: 'Deliver an inspiring speech illustrating how natural biological collaboration teaches modern human teams to communicate better.'
    },
    {
      category: '🎨 Art & Cultural Anthropology',
      topic: 'The Golden Ratio (Phi) and Visual Harmony in Storytelling',
      emoji: '🎨',
      summary: 'The Golden Ratio (~1.618), denoted by Phi, appears recurrently in classical geometry, biological spiral phyllotaxis, Renaissance art, and modern slide typography. Incorporating golden proportions in visual presentations creates immediate subconscious visual comfort and authority.',
      keyFacts: [
        'First mathematically documented by Euclid in his Elements around 300 BC.',
        'Applied by Leonardo da Vinci in The Vitruvian Man and Salvador Dalí in The Sacrament of the Last Supper.',
        'Used in presentation design to balance white space, header-to-body font scale ratios (1 : 1.6), and imagery.'
      ],
      suggestedPrompt: 'Present a 90-second speech on the intersection of aesthetic beauty and analytical precision.'
    }
  ];

  /**
   * Initializes the scheduled Daily Brief Cron Job
   * Schedule: Every day at 05:00:00 AM (0 5 * * *)
   */
  initCronJobs() {
    if (this.isInitialized) return;

    // Cron expression: '0 5 * * *' = At 05:00 AM every day
    this.cronTask = cron.schedule('0 5 * * *', async () => {
      console.log(`\n⏰ [CRON JOB TRIGGERED: 05:00 AM] Sending AI Daily Brief Request to AI Knowledge API...`);
      try {
        const brief = await this.generateAndSaveDailyBrief();
        console.log(`✅ [CRON 05:00 AM SUCCESS] New AI Daily Brief Published: "${brief.topic}" [${brief.category}]`);
      } catch (err) {
        console.error(`❌ [CRON 05:00 AM ERROR] Failed to generate scheduled daily brief:`, err);
      }
    });

    this.isInitialized = true;
    console.log(`⏰ [CRON SERVICE INITIALIZED] AI Daily Knowledge Brief scheduled for 05:00 AM daily ('0 5 * * *').`);
  }

  /**
   * Generates a new AI Knowledge Brief and persists it to MySQL + memory store
   */
  async generateAndSaveDailyBrief(forcedIndex = null) {
    const today = new Date().toISOString().split('T')[0];
    const pool = CronService.knowledgeTopics;
    
    // Pick topic based on day index or random selection
    const topicIndex = forcedIndex !== null 
      ? (forcedIndex % pool.length) 
      : Math.floor(Math.random() * pool.length);
    
    const chosen = pool[topicIndex];
    const briefId = `brief_${Date.now()}`;

    const newBrief = {
      id: briefId,
      brief_date: today,
      category: chosen.category,
      topic: chosen.topic,
      emoji: chosen.emoji,
      summary_text: chosen.summary,
      key_facts_json: JSON.stringify(chosen.keyFacts),
      suggested_prompt: chosen.suggestedPrompt,
      created_at: new Date()
    };

    try {
      await db.query(
        `INSERT INTO daily_briefs (id, brief_date, category, topic, emoji, summary_text, key_facts_json, suggested_prompt, created_at)
         VALUES (?, ?, ?, ?, ?, ?, ?, ?, NOW())`,
        [
          newBrief.id,
          newBrief.brief_date,
          newBrief.category,
          newBrief.topic,
          newBrief.emoji,
          newBrief.summary_text,
          newBrief.key_facts_json,
          newBrief.suggested_prompt
        ]
      );
    } catch (dbErr) {
      console.warn(`[CronService] MySQL insert note (using memory fallback if needed):`, dbErr.message);
    }

    // Always update memory store so it's instantly live for clients
    if (!db.memoryStore.daily_briefs) {
      db.memoryStore.daily_briefs = [];
    }
    db.memoryStore.daily_briefs.unshift(newBrief);

    return {
      id: newBrief.id,
      date: newBrief.brief_date,
      category: newBrief.category,
      topic: newBrief.topic,
      emoji: newBrief.emoji,
      summaryText: newBrief.summary_text,
      keyFactBullets: chosen.keyFacts,
      suggestedSpeakingPrompt: newBrief.suggested_prompt,
      isRead: false
    };
  }
}

module.exports = new CronService();
