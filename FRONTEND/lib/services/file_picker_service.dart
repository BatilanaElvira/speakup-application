import 'dart:convert';
import 'dart:developer' as developer;
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

class PickedDocumentResult {
  final String fileName;
  final int fileSizeBytes;
  final String content;
  final String extension;

  PickedDocumentResult({
    required this.fileName,
    required this.fileSizeBytes,
    required this.content,
    required this.extension,
  });

  String get formattedSize {
    if (fileSizeBytes < 1024) return '$fileSizeBytes B';
    if (fileSizeBytes < 1024 * 1024) return '${(fileSizeBytes / 1024).toStringAsFixed(1)} KB';
    return '${(fileSizeBytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }
}

class FilePickerService {
  static final FilePickerService instance = FilePickerService._();
  FilePickerService._();

  /// Pick a report document (.txt, .md, .pdf, .doc, .docx, .json, .csv)
  Future<PickedDocumentResult?> pickReportDocument() async {
    try {
      final files = await FilePickerPlatform.instance.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['txt', 'md', 'pdf', 'doc', 'docx', 'json', 'csv'],
      );

      if (files.isNotEmpty) {
        final file = files.first;
        final fileBytes = await file.readAsBytes();
        final int fileSize = (await file.length()) ?? fileBytes.length;
        String textContent = '';

        if (fileBytes.isNotEmpty) {
          try {
            // Attempt to decode UTF-8 plain text / markdown / csv / json
            textContent = utf8.decode(fileBytes, allowMalformed: true);
          } catch (_) {
            textContent = '📄 [Document Attached: ${file.name} ($fileSize bytes)]\nAttached report for AI Evaluator analysis.';
          }
        } else {
          textContent = '📄 [Document Attached: ${file.name} ($fileSize bytes)]';
        }

        // If binary or empty string fallback
        if (textContent.trim().isEmpty || textContent.contains('\x00')) {
          textContent = '📄 [Report Document Attached: ${file.name}]\nFile size: ${(fileSize / 1024).toStringAsFixed(1)} KB\nContext submitted for AI speech evaluator review.';
        }

        final ext = file.name.contains('.') ? file.name.split('.').last : 'txt';

        return PickedDocumentResult(
          fileName: file.name,
          fileSizeBytes: fileSize,
          content: textContent,
          extension: ext,
        );
      }
    } catch (e) {
      developer.log('[FilePickerService] pickReportDocument error: $e');
    }
    return null;
  }

  /// Pick an image from gallery/photos and convert to Base64 Data URL
  Future<String?> pickProfileImageFromGallery() async {
    try {
      final files = await FilePickerPlatform.instance.pickFiles(
        type: FileType.image,
      );

      if (files.isNotEmpty) {
        final file = files.first;
        final bytes = await file.readAsBytes();
        if (bytes.isNotEmpty) {
          final ext = file.name.contains('.') ? file.name.split('.').last.toLowerCase() : 'png';
          final mime = (ext == 'jpg' || ext == 'jpeg') ? 'image/jpeg' : 'image/png';
          final base64String = base64Encode(bytes);
          return 'data:$mime;base64,$base64String';
        }
      }
    } catch (e) {
      developer.log('[FilePickerService] pickProfileImageFromGallery error: $e');
    }
    return null;
  }

  /// Preloaded Sample Reports for quick selection
  static final List<Map<String, String>> sampleReports = [
    {
      'title': '📊 Q3 Business Strategy & Revenue Report',
      'category': 'Executive',
      'summary': 'Executive Summary: In Q3, recurring subscription revenue increased by 28% YoY driven by enterprise adoption. Customer acquisition cost (CAC) fell by 14% with a strong 84% gross retention rate. The upcoming priorities include scaling APAC go-to-market channels, optimizing AI server compute cost, and rolling out real-time audio evaluation features for professional trainees.',
    },
    {
      'title': '🤖 AI Ethics & Automation Thesis Report',
      'category': 'Academic',
      'summary': 'Academic Research Thesis: Exploring ethical governance frameworks in generative AI deployments across public sector communication. The study emphasizes algorithmic accountability, transparent bias audits, human-in-the-loop validation, and fair labor transition protocols for knowledge workers.',
    },
    {
      'title': '🌱 Sustainable Green Energy Policy Report',
      'category': 'Policy',
      'summary': 'Policy Briefing: Renewable energy investments must expand by 40% annually to achieve 2030 net-zero targets. Key focal areas include smart grid modernizations, decentralized micro-hydro infrastructures, regulatory incentives for clean manufacturing, and community solar adoption.',
    },
    {
      'title': '🚀 Product Launch & Pitch Deck Brief',
      'category': 'Startup',
      'summary': 'Product Pitch: Introducing SpeakUp 2.0 — the next-generation AI speech and public speaking simulator. With real-time multimodal feedback, simulated ambient pressure environments, and personalized coaching roadmaps, users improve speech delivery confidence by 3.5x within 14 days.',
    },
  ];

  /// Universal avatar image widget handling network URLs and gallery Base64 Data URLs
  static Widget buildAvatarImageWidget(
    String? url, {
    double? width,
    double? height,
    BoxFit fit = BoxFit.cover,
    Color fallbackColor = const Color(0xFFFF6B4A),
    double iconSize = 48,
  }) {
    if (url == null || url.trim().isEmpty) {
      return Icon(Icons.person_rounded, size: iconSize, color: fallbackColor);
    }

    final trimmed = url.trim();
    if (trimmed.startsWith('data:image')) {
      try {
        final commaIndex = trimmed.indexOf(',');
        final base64Str = commaIndex != -1 ? trimmed.substring(commaIndex + 1) : trimmed;
        final bytes = base64Decode(base64Str);
        return Image.memory(
          bytes,
          width: width,
          height: height,
          fit: fit,
          errorBuilder: (context, error, stackTrace) => Icon(Icons.person_rounded, size: iconSize, color: fallbackColor),
        );
      } catch (_) {
        return Icon(Icons.person_rounded, size: iconSize, color: fallbackColor);
      }
    }

    return Image.network(
      trimmed,
      width: width,
      height: height,
      fit: fit,
      errorBuilder: (context, error, stackTrace) => Icon(Icons.person_rounded, size: iconSize, color: fallbackColor),
    );
  }
}
