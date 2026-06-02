import 'package:feedback/feedback.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(
    BetterFeedback(
      theme: FeedbackThemeData(
        background: Colors.grey[200]!,
        feedbackSheetColor: Colors.white,
        activeFeedbackModeColor: const Color(0xFF1DB954),
        bottomSheetDescriptionStyle: const TextStyle(color: Colors.black87, fontSize: 14),
      ),
      localizationsDelegates: const [],
      child: const ProviderScope(
        child: AllTimeApp(),
      ),
    ),
  );
}
