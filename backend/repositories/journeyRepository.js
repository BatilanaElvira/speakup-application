const db = require('../config/db');

class JourneyRepository {
  async getObstaclesWithStagesAndNodes(userId) {
    const completedNodeIds = await this.getUserCompletedNodeIds(userId);

    const obstacles = db.memoryStore.speaking_obstacles;
    const stages = db.memoryStore.journey_stages;
    const nodes = db.memoryStore.journey_nodes;

    return obstacles.map(obs => {
      const obsStages = stages
        .filter(s => s.obstacle_id === obs.id)
        .map(stg => {
          const stgNodes = nodes
            .filter(n => n.stage_id === stg.id)
            .map(n => ({
              id: n.id,
              title: n.title,
              situationPrompt: n.situation_prompt,
              durationSeconds: n.duration_seconds,
              difficulty: n.difficulty,
              xpReward: n.xp_reward,
              isCompleted: completedNodeIds.includes(n.id)
            }));

          return {
            id: stg.id,
            stageNumber: stg.stage_number,
            environmentName: stg.environment_name,
            environmentEmoji: stg.environment_emoji,
            title: stg.title,
            description: stg.description,
            nodes: stgNodes
          };
        });

      return {
        id: obs.id,
        title: obs.title,
        emoji: obs.emoji,
        subtitle: obs.subtitle,
        themeColorHex: obs.theme_color_hex,
        stages: obsStages
      };
    });
  }

  async getAllRoadmap() {
    const stages = db.memoryStore.journey_stages || [];
    const nodes = db.memoryStore.journey_nodes || [];

    return stages.map(stg => {
      const stgNodes = nodes.filter(n => n.stage_id === stg.id);
      const firstNode = stgNodes[0] || {};
      return {
        id: stg.id,
        obstacleId: stg.obstacle_id || 'confidence',
        stageNumber: stg.stage_number,
        environmentEmoji: stg.environment_emoji,
        environmentName: stg.environment_name,
        title: stg.title,
        description: stg.description,
        situationPrompt: firstNode.situation_prompt || stg.description || 'Practice speaking in this environment',
        durationSeconds: firstNode.duration_seconds || 60,
        xpReward: firstNode.xp_reward || 100,
        nodes: stgNodes
      };
    });
  }

  async createStage(data) {
    const {
      id = `stg_${Date.now()}`,
      obstacle_id = 'confidence',
      stage_number = (db.memoryStore.journey_stages.length + 1),
      environment_name,
      environment_emoji = '🎤',
      title,
      description = '',
      situation_prompt = '',
      duration_seconds = 60,
      xp_reward = 100
    } = data;

    await db.query(
      'INSERT INTO journey_stages (id, obstacle_id, stage_number, environment_name, environment_emoji, title, description) VALUES (?, ?, ?, ?, ?, ?, ?)',
      [id, obstacle_id, stage_number, environment_name, environment_emoji, title, description || title]
    );

    const newStage = {
      id,
      obstacle_id,
      stage_number: Number(stage_number),
      environment_name,
      environment_emoji,
      title,
      description: description || title
    };

    if (!db.memoryStore.journey_stages) db.memoryStore.journey_stages = [];
    db.memoryStore.journey_stages.push(newStage);

    // Create a corresponding default node for this stage
    const nodeId = `node_${Date.now()}`;
    await db.query(
      'INSERT INTO journey_nodes (id, stage_id, title, situation_prompt, duration_seconds, difficulty, xp_reward) VALUES (?, ?, ?, ?, ?, ?, ?)',
      [nodeId, id, title, situation_prompt || description || title, duration_seconds, 'Medium', xp_reward]
    );

    const newNode = {
      id: nodeId,
      stage_id: id,
      title,
      situation_prompt: situation_prompt || description || title,
      duration_seconds: Number(duration_seconds),
      difficulty: 'Medium',
      xp_reward: Number(xp_reward)
    };

    if (!db.memoryStore.journey_nodes) db.memoryStore.journey_nodes = [];
    db.memoryStore.journey_nodes.push(newNode);

    return {
      ...newStage,
      situationPrompt: newNode.situation_prompt,
      durationSeconds: newNode.duration_seconds,
      xpReward: newNode.xp_reward,
      nodes: [newNode]
    };
  }

  async updateStage(id, data) {
    const stage = (db.memoryStore.journey_stages || []).find(s => s.id === id);
    if (!stage) return null;

    const environment_name = data.environment_name !== undefined ? data.environment_name : stage.environment_name;
    const environment_emoji = data.environment_emoji !== undefined ? data.environment_emoji : stage.environment_emoji;
    const title = data.title !== undefined ? data.title : stage.title;
    const description = data.description !== undefined ? data.description : stage.description;
    const stage_number = data.stage_number !== undefined ? Number(data.stage_number) : stage.stage_number;

    await db.query(
      'UPDATE journey_stages SET environment_name = ?, environment_emoji = ?, title = ?, description = ?, stage_number = ? WHERE id = ?',
      [environment_name, environment_emoji, title, description, stage_number, id]
    );

    stage.environment_name = environment_name;
    stage.environment_emoji = environment_emoji;
    stage.title = title;
    stage.description = description;
    stage.stage_number = stage_number;

    // Update first node prompt and reward if provided
    const node = (db.memoryStore.journey_nodes || []).find(n => n.stage_id === id);
    if (node) {
      if (data.situation_prompt !== undefined) node.situation_prompt = data.situation_prompt;
      if (data.duration_seconds !== undefined) node.duration_seconds = Number(data.duration_seconds);
      if (data.xp_reward !== undefined) node.xp_reward = Number(data.xp_reward);

      await db.query(
        'UPDATE journey_nodes SET situation_prompt = ?, duration_seconds = ?, xp_reward = ? WHERE id = ?',
        [node.situation_prompt, node.duration_seconds, node.xp_reward, node.id]
      );
    }

    return {
      ...stage,
      situationPrompt: node ? node.situation_prompt : stage.description,
      durationSeconds: node ? node.duration_seconds : 60,
      xpReward: node ? node.xp_reward : 100
    };
  }

  async deleteStage(id) {
    await db.query('DELETE FROM journey_stages WHERE id = ?', [id]);
    await db.query('DELETE FROM journey_nodes WHERE stage_id = ?', [id]);

    const sIdx = (db.memoryStore.journey_stages || []).findIndex(s => s.id === id);
    if (sIdx !== -1) db.memoryStore.journey_stages.splice(sIdx, 1);

    if (db.memoryStore.journey_nodes) {
      db.memoryStore.journey_nodes = db.memoryStore.journey_nodes.filter(n => n.stage_id !== id);
    }

    return true;
  }

  async getUserCompletedNodeIds(userId) {
    const rows = await db.query('SELECT node_id FROM user_node_progress WHERE user_id = ?', [userId]);
    if (rows && rows.length > 0) {
      return rows.map(r => r.node_id);
    }
    return (db.memoryStore.user_node_progress || [])
      .filter(p => p.user_id === userId)
      .map(p => p.node_id);
  }

  async markNodeCompleted(userId, nodeId) {
    const existing = await db.query('SELECT * FROM user_node_progress WHERE user_id = ? AND node_id = ?', [userId, nodeId]);
    if (!existing || existing.length === 0) {
      const id = `unp_${Date.now()}`;
      await db.query('INSERT INTO user_node_progress (id, user_id, node_id) VALUES (?, ?, ?)', [id, userId, nodeId]);

      if (!(db.memoryStore.user_node_progress || []).some(p => p.user_id === userId && p.node_id === nodeId)) {
        if (!db.memoryStore.user_node_progress) db.memoryStore.user_node_progress = [];
        db.memoryStore.user_node_progress.push({ id, user_id: userId, node_id: nodeId, completed_at: new Date() });
      }
    }
    return await this.getUserCompletedNodeIds(userId);
  }
}

module.exports = new JourneyRepository();
