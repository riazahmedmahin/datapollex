import 'package:flutter/material.dart';

class LanguageCard extends StatelessWidget {
  final String language;
  final VoidCallback onTap;

  const LanguageCard({
    Key? key,
    required this.language,
    required this.onTap,
  }) : super(key: key);

  // Language -> Flag Emoji mapping
  String _getFlagEmoji(String language) {
    switch (language.toLowerCase()) {
      case 'english':
        return "🇬🇧"; // UK Flag
      case 'spanish':
        return "🇪🇸"; // Spain Flag
      case 'french':
        return "🇫🇷"; // France Flag
      case 'german':
        return "🇩🇪"; // Germany Flag
      case 'japanese':
        return "🇯🇵"; 
      case 'bengali':
        return "🇧🇩"; // Bangladesh Flag
      default:
        return "🌍"; // default globe
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Colors.blue.shade400, Colors.blue.shade600],
            ),
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  _getFlagEmoji(language),
                  style: const TextStyle(fontSize: 40), // big flag emoji
                ),
                const SizedBox(height: 8),
                Text(
                  language,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

