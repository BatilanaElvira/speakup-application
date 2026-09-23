import 'dart:convert';
import 'dart:developer' as developer;
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../models/book_recommendation.dart';
import '../models/category.dart';
import '../models/daily_knowledge_brief.dart';
import '../models/practice_session.dart';


class ApiService {
  static final ApiService instance = ApiService._internal();
  factory ApiService() => instance;
  ApiService._internal();

  // Local Node.js Express REST Backend URL
  final String baseUrl = 'http://localhost:5000/api';
  String? _authToken;

  void setAuthToken(String? token) {
    _authToken = token;
  }

  Map<String, String> get _headers => {
        'Content-Type': 'application/json',
        if (_authToken != null) 'Authorization': 'Bearer $_authToken',
      };

  Future<bool> checkHealth() async {
    try {
      final res = await http.get(Uri.parse('$baseUrl/health')).timeout(const Duration(seconds: 3));
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        return data['status'] == 'UP';
      }
    } catch (e) {
      developer.log('[ApiService] Health check error: $e');
    }
    return false;
  }

  Future<Map<String, dynamic>?> login(String email, [String? password]) async {
    try {
      final res = await http.post(
        Uri.parse('$baseUrl/auth/login'),
        headers: _headers,
        body: jsonEncode({'email': email, 'password': password ?? 'password123'}),
      );
      if (res.statusCode == 200 || res.statusCode == 201) {
        final data = jsonDecode(res.body);
        _authToken = data['token'];
        return data;
      }
    } catch (e) {
      developer.log('[ApiService] Login error: $e');
    }
    return null;
  }

  Future<Map<String, dynamic>?> register({required String name, required String email, String? password, String? role}) async {
    try {
      final res = await http.post(
        Uri.parse('$baseUrl/auth/register'),
        headers: _headers,
        body: jsonEncode({'name': name, 'email': email, 'password': password ?? 'password123', 'role': role ?? 'Trainee'}),
      );
      if (res.statusCode == 200 || res.statusCode == 201) {
        final data = jsonDecode(res.body);
        _authToken = data['token'];
        return data;
      }
    } catch (e) {
      developer.log('[ApiService] Register error: $e');
    }
    return null;
  }

  Future<Map<String, dynamic>?> socialLogin({required String provider, String? email, String? name}) async {
    try {
      final res = await http.post(
        Uri.parse('$baseUrl/auth/social-login'),
        headers: _headers,
        body: jsonEncode({
          'provider': provider,
          'email': email ?? '${provider.toLowerCase()}_user@speakup.ai',
          'name': name ?? '${provider[0].toUpperCase()}${provider.substring(1)} User',
        }),
      );
      if (res.statusCode == 200 || res.statusCode == 201) {
        final data = jsonDecode(res.body);
        _authToken = data['token'];
        return data;
      }
    } catch (e) {
      developer.log('[ApiService] Social Login error: $e');
    }
    return null;
  }

  Future<Map<String, dynamic>?> forgotPassword(String email) async {
    try {
      final res = await http.post(
        Uri.parse('$baseUrl/auth/forgot-password'),
        headers: _headers,
        body: jsonEncode({'email': email}),
      );
      if (res.statusCode == 200) {
        return jsonDecode(res.body);
      }
    } catch (e) {
      developer.log('[ApiService] Forgot password error: $e');
    }
    return null;
  }

  Future<bool> verifyResetCode(String email, String code) async {
    try {
      final res = await http.post(
        Uri.parse('$baseUrl/auth/verify-reset-code'),
        headers: _headers,
        body: jsonEncode({'email': email, 'code': code}),
      );
      return res.statusCode == 200;
    } catch (e) {
      developer.log('[ApiService] Verify reset code error: $e');
      return false;
    }
  }

  Future<Map<String, dynamic>?> resetPassword(String email, String code, String newPassword) async {
    try {
      final res = await http.post(
        Uri.parse('$baseUrl/auth/reset-password'),
        headers: _headers,
        body: jsonEncode({'email': email, 'code': code, 'newPassword': newPassword}),
      );
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        _authToken = data['token'];
        return data;
      }
    } catch (e) {
      developer.log('[ApiService] Reset password error: $e');
    }
    return null;
  }

  Future<Map<String, dynamic>?> updateProfile({required String name, required String email, String? obstacleId, String? avatarUrl}) async {
    try {
      final Map<String, dynamic> payload = {
        'name': name,
        'email': email,
      };
      if (obstacleId != null) payload['obstacle_id'] = obstacleId;
      if (avatarUrl != null) payload['avatar_url'] = avatarUrl;

      final res = await http.put(
        Uri.parse('$baseUrl/auth/profile'),
        headers: _headers,
        body: jsonEncode(payload),
      );
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        return data['data'];
      }
    } catch (e) {
      developer.log('[ApiService] updateProfile error: $e');
    }
    return null;
  }

  Future<List<CategoryItem>?> fetchCategories() async {
    try {
      final res = await http.get(Uri.parse('$baseUrl/categories'), headers: _headers);
      if (res.statusCode == 200) {
        final body = jsonDecode(res.body);
        final List list = body['data'] ?? [];
        return list.map((c) {
          return CategoryItem(
            id: c['id'],
            title: c['title'],
            emoji: c['emoji'],
            cardColor: _parseHexColor(c['card_color_hex']),
            sampleTopics: List<String>.from(c['sample_topics'] ?? []),
          );
        }).toList();
      }
    } catch (e) {
      developer.log('[ApiService] fetchCategories error: $e');
    }
    return null;
  }

  Future<List<PracticeSessionResult>?> fetchSessionHistory() async {
    try {
      final res = await http.get(Uri.parse('$baseUrl/sessions/history'), headers: _headers);
      if (res.statusCode == 200) {
        final body = jsonDecode(res.body);
        final List list = body['data'] ?? [];
        return list.map((s) => _mapSessionResult(s)).toList();
      }
    } catch (e) {
      developer.log('[ApiService] fetchSessionHistory error: $e');
    }
    return null;
  }

  Future<PracticeSessionResult?> submitAndAnalyzeSession({
    required PracticeMode mode,
    required String evaluatorId,
    required String evaluatorName,
    required String categoryId,
    required String topic,
    required int durationSeconds,
  }) async {
    try {
      final res = await http.post(
        Uri.parse('$baseUrl/sessions/analyze'),
        headers: _headers,
        body: jsonEncode({
          'mode': mode.name,
          'evaluatorId': evaluatorId,
          'evaluatorName': evaluatorName,
          'categoryId': categoryId,
          'topic': topic,
          'durationSeconds': durationSeconds,
        }),
      );
      if (res.statusCode == 200 || res.statusCode == 201) {
        final body = jsonDecode(res.body);
        return _mapSessionResult(body['data']);
      }
    } catch (e) {
      developer.log('[ApiService] submitAndAnalyzeSession error: $e');
    }
    return null;
  }

  Future<Map<String, dynamic>?> completeNode(String nodeId) async {
    try {
      final res = await http.post(
        Uri.parse('$baseUrl/journey/nodes/$nodeId/complete'),
        headers: _headers,
      );
      if (res.statusCode == 200) {
        final body = jsonDecode(res.body);
        return body['data'];
      }
    } catch (e) {
      developer.log('[ApiService] completeNode error: $e');
    }
    return null;
  }

  Future<List<DailyKnowledgeBrief>?> fetchDailyBriefs() async {
    try {
      final res = await http.get(Uri.parse('$baseUrl/daily-briefs'), headers: _headers);
      if (res.statusCode == 200) {
        final body = jsonDecode(res.body);
        final List list = body['data'] ?? [];
        return list.map((b) {
          return DailyKnowledgeBrief(
            id: b['id'],
            date: DateTime.parse(b['date']),
            category: b['category'],
            topic: b['topic'],
            emoji: b['emoji'],
            summaryText: b['summaryText'],
            keyFactBullets: List<String>.from(b['keyFactBullets'] ?? []),
            suggestedSpeakingPrompt: b['suggestedSpeakingPrompt'],
            isRead: b['isRead'] ?? false,
          );
        }).toList();
      }
    } catch (e) {
      developer.log('[ApiService] fetchDailyBriefs error: $e');
    }
    return null;
  }

  Future<bool> markBriefAsRead(String briefId) async {
    try {
      final res = await http.post(Uri.parse('$baseUrl/daily-briefs/$briefId/read'), headers: _headers);
      return res.statusCode == 200;
    } catch (e) {
      developer.log('[ApiService] markBriefAsRead error: $e');
      return false;
    }
  }

  PracticeSessionResult _mapSessionResult(Map<String, dynamic> s) {
    PracticeMode mode = PracticeMode.full;
    if (s['mode'] == 'quick') mode = PracticeMode.quick;
    if (s['mode'] == 'goal') mode = PracticeMode.goal;

    final booksRaw = s['recommendedBooks'] as List? ?? [];
    final books = booksRaw.map((b) {
      final titleStr = b['title'] ?? 'Talk Like TED';
      return BookRecommendation(
        id: b['id'] ?? 'book_${titleStr.toString().toLowerCase().replaceAll(' ', '_')}',
        title: titleStr,
        author: b['author'] ?? 'Carmine Gallo',
        coverEmoji: b['coverEmoji'] ?? '🎙️',
        targetProblem: b['targetProblem'] ?? 'Public Speaking Mastery',
        keyTakeaway: b['keyTakeaway'] ?? 'Master public speaking secrets.',
        amazonSearchUrl: b['amazonSearchUrl'] ?? 'https://www.google.com/search?q=${Uri.encodeComponent(titleStr)}',
      );
    }).toList();

    final questionsRaw = s['audienceQuestions'] as List? ?? [];
    final questions = questionsRaw.map((q) {
      return AudienceQuestion(
        question: q['question'] ?? 'Audience Question',
        speakerAnswer: q['speakerAnswer'] ?? 'Speaker Answer',
      );
    }).toList();

    return PracticeSessionResult(
      id: s['id'] ?? 'sess_${DateTime.now().millisecondsSinceEpoch}',
      mode: mode,
      evaluatorId: s['evaluatorId'] ?? 'coach',
      evaluatorName: s['evaluatorName'] ?? 'The Coach',
      categoryId: s['categoryId'] ?? 'tech',
      topic: s['topic'] ?? 'General Topic',
      timestamp: DateTime.tryParse(s['timestamp'].toString()) ?? DateTime.now(),
      durationSeconds: s['durationSeconds'] ?? 45,
      overallScore: s['overallScore'] ?? 80,
      clarityScore: s['clarityScore'] ?? 80,
      confidenceScore: s['confidenceScore'] ?? 80,
      paceScore: s['paceScore'] ?? 80,
      fluencyScore: s['fluencyScore'] ?? 80,
      structureScore: s['structureScore'] ?? 80,
      fillerWordCount: s['fillerWordCount'] ?? 0,
      transcript: s['transcript'] ?? '',
      strengths: List<String>.from(s['strengths'] ?? []),
      weaknesses: List<String>.from(s['weaknesses'] ?? []),
      howToImprove: s['howToImprove'] ?? '',
      nextRecommendedExercise: s['nextRecommendedExercise'] ?? '',
      recommendedBooks: books,
      audienceQuestions: questions,
      isSavedInInbox: s['isSavedInInbox'] ?? true,
    );
  }

  Map<String, String> get _adminHeaders => {
        'Content-Type': 'application/json',
        'X-Admin-Role': 'Admin',
        if (_authToken != null) 'Authorization': 'Bearer $_authToken',
      };

  // --- ADMIN METRICS ---
  Future<Map<String, dynamic>?> fetchAdminMetrics() async {
    try {
      final res = await http.get(Uri.parse('$baseUrl/admin/metrics'), headers: _adminHeaders);
      if (res.statusCode == 200) {
        final body = jsonDecode(res.body);
        return body['data'];
      }
    } catch (e) {
      developer.log('[ApiService] fetchAdminMetrics error: $e');
    }
    return null;
  }

  // --- ADMIN USERS CRUD ---
  Future<List<Map<String, dynamic>>?> fetchAdminUsers() async {
    try {
      final res = await http.get(Uri.parse('$baseUrl/admin/users'), headers: _adminHeaders);
      if (res.statusCode == 200) {
        final body = jsonDecode(res.body);
        return List<Map<String, dynamic>>.from(body['data'] ?? []);
      }
    } catch (e) {
      developer.log('[ApiService] fetchAdminUsers error: $e');
    }
    return null;
  }

  Future<Map<String, dynamic>?> createAdminUser(Map<String, dynamic> userData) async {
    try {
      final res = await http.post(
        Uri.parse('$baseUrl/admin/users'),
        headers: _adminHeaders,
        body: jsonEncode(userData),
      );
      if (res.statusCode == 200 || res.statusCode == 201) {
        final body = jsonDecode(res.body);
        return body['data'];
      }
    } catch (e) {
      developer.log('[ApiService] createAdminUser error: $e');
    }
    return null;
  }

  Future<Map<String, dynamic>?> updateAdminUser(String id, Map<String, dynamic> userData) async {
    try {
      final res = await http.put(
        Uri.parse('$baseUrl/admin/users/$id'),
        headers: _adminHeaders,
        body: jsonEncode(userData),
      );
      if (res.statusCode == 200) {
        final body = jsonDecode(res.body);
        return body['data'];
      }
    } catch (e) {
      developer.log('[ApiService] updateAdminUser error: $e');
    }
    return null;
  }

  Future<bool> deleteAdminUser(String id) async {
    try {
      final res = await http.delete(Uri.parse('$baseUrl/admin/users/$id'), headers: _adminHeaders);
      return res.statusCode == 200;
    } catch (e) {
      developer.log('[ApiService] deleteAdminUser error: $e');
      return false;
    }
  }

  // --- ADMIN SKILL RULES CRUD ---
  Future<List<Map<String, dynamic>>?> fetchSkillRules() async {
    try {
      final res = await http.get(Uri.parse('$baseUrl/admin/skill-rules'), headers: _adminHeaders);
      if (res.statusCode == 200) {
        final body = jsonDecode(res.body);
        return List<Map<String, dynamic>>.from(body['data'] ?? []);
      }
    } catch (e) {
      developer.log('[ApiService] fetchSkillRules error: $e');
    }
    return null;
  }

  Future<Map<String, dynamic>?> createSkillRule(Map<String, dynamic> ruleData) async {
    try {
      final res = await http.post(
        Uri.parse('$baseUrl/admin/skill-rules'),
        headers: _adminHeaders,
        body: jsonEncode(ruleData),
      );
      if (res.statusCode == 200 || res.statusCode == 201) {
        final body = jsonDecode(res.body);
        return body['data'];
      }
    } catch (e) {
      developer.log('[ApiService] createSkillRule error: $e');
    }
    return null;
  }

  Future<Map<String, dynamic>?> updateSkillRule(String id, Map<String, dynamic> ruleData) async {
    try {
      final res = await http.put(
        Uri.parse('$baseUrl/admin/skill-rules/$id'),
        headers: _adminHeaders,
        body: jsonEncode(ruleData),
      );
      if (res.statusCode == 200) {
        final body = jsonDecode(res.body);
        return body['data'];
      }
    } catch (e) {
      developer.log('[ApiService] updateSkillRule error: $e');
    }
    return null;
  }

  Future<bool> deleteSkillRule(String id) async {
    try {
      final res = await http.delete(Uri.parse('$baseUrl/admin/skill-rules/$id'), headers: _adminHeaders);
      return res.statusCode == 200;
    } catch (e) {
      developer.log('[ApiService] deleteSkillRule error: $e');
      return false;
    }
  }

  // --- ADMIN ROADMAP CRUD ---
  Future<List<Map<String, dynamic>>?> fetchRoadmapStages() async {
    try {
      final res = await http.get(Uri.parse('$baseUrl/admin/roadmap'), headers: _adminHeaders);
      if (res.statusCode == 200) {
        final body = jsonDecode(res.body);
        return List<Map<String, dynamic>>.from(body['data'] ?? []);
      }
    } catch (e) {
      developer.log('[ApiService] fetchRoadmapStages error: $e');
    }
    return null;
  }

  Future<Map<String, dynamic>?> createRoadmapStage(Map<String, dynamic> stageData) async {
    try {
      final res = await http.post(
        Uri.parse('$baseUrl/admin/roadmap/stages'),
        headers: _adminHeaders,
        body: jsonEncode(stageData),
      );
      if (res.statusCode == 200 || res.statusCode == 201) {
        final body = jsonDecode(res.body);
        return body['data'];
      }
    } catch (e) {
      developer.log('[ApiService] createRoadmapStage error: $e');
    }
    return null;
  }

  Future<Map<String, dynamic>?> updateRoadmapStage(String id, Map<String, dynamic> stageData) async {
    try {
      final res = await http.put(
        Uri.parse('$baseUrl/admin/roadmap/stages/$id'),
        headers: _adminHeaders,
        body: jsonEncode(stageData),
      );
      if (res.statusCode == 200) {
        final body = jsonDecode(res.body);
        return body['data'];
      }
    } catch (e) {
      developer.log('[ApiService] updateRoadmapStage error: $e');
    }
    return null;
  }

  Future<bool> deleteRoadmapStage(String id) async {
    try {
      final res = await http.delete(Uri.parse('$baseUrl/admin/roadmap/stages/$id'), headers: _adminHeaders);
      return res.statusCode == 200;
    } catch (e) {
      developer.log('[ApiService] deleteRoadmapStage error: $e');
      return false;
    }
  }

  // --- ADMIN EXERCISES CRUD ---
  Future<List<Map<String, dynamic>>?> fetchExercises() async {
    try {
      final res = await http.get(Uri.parse('$baseUrl/admin/exercises'), headers: _adminHeaders);
      if (res.statusCode == 200) {
        final body = jsonDecode(res.body);
        return List<Map<String, dynamic>>.from(body['data'] ?? []);
      }
    } catch (e) {
      developer.log('[ApiService] fetchExercises error: $e');
    }
    return null;
  }

  Future<Map<String, dynamic>?> createExercise(Map<String, dynamic> exerciseData) async {
    try {
      final res = await http.post(
        Uri.parse('$baseUrl/admin/exercises'),
        headers: _adminHeaders,
        body: jsonEncode(exerciseData),
      );
      if (res.statusCode == 200 || res.statusCode == 201) {
        final body = jsonDecode(res.body);
        return body['data'];
      }
    } catch (e) {
      developer.log('[ApiService] createExercise error: $e');
    }
    return null;
  }

  Future<Map<String, dynamic>?> updateExercise(String id, Map<String, dynamic> exerciseData) async {
    try {
      final res = await http.put(
        Uri.parse('$baseUrl/admin/exercises/$id'),
        headers: _adminHeaders,
        body: jsonEncode(exerciseData),
      );
      if (res.statusCode == 200) {
        final body = jsonDecode(res.body);
        return body['data'];
      }
    } catch (e) {
      developer.log('[ApiService] updateExercise error: $e');
    }
    return null;
  }

  Future<bool> deleteExercise(String id) async {
    try {
      final res = await http.delete(Uri.parse('$baseUrl/admin/exercises/$id'), headers: _adminHeaders);
      return res.statusCode == 200;
    } catch (e) {
      developer.log('[ApiService] deleteExercise error: $e');
      return false;
    }
  }

  Future<List<Map<String, dynamic>>> getAvatarPresets() async {
    try {
      final res = await http.get(Uri.parse('$baseUrl/avatars'), headers: _headers);
      if (res.statusCode == 200) {
        final body = jsonDecode(res.body);
        if (body['data'] is List) {
          return List<Map<String, dynamic>>.from(body['data']);
        }
      }
    } catch (e) {
      developer.log('[ApiService] getAvatarPresets error: $e');
    }
    return [];
  }

  Future<bool> subscribePlan(String planId) async {
    try {
      final res = await http.post(
        Uri.parse('$baseUrl/subscriptions/subscribe'),
        headers: _headers,
        body: jsonEncode({'planId': planId}),
      );
      return res.statusCode == 200;
    } catch (e) {
      developer.log('[ApiService] subscribePlan error: $e');
      return false;
    }
  }

  Color _parseHexColor(String? hexString) {
    if (hexString == null) return const Color(0xFF3157D5);
    final buffer = StringBuffer();
    if (hexString.length == 6 || hexString.length == 7) buffer.write('ff');
    buffer.write(hexString.replaceFirst('#', ''));
    return Color(int.parse(buffer.toString(), radix: 16));
  }
}




