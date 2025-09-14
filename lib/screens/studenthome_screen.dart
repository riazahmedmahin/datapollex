import 'package:datapollex/main.dart';
import 'package:datapollex/notifirer/appstate_notifier.dart';
import 'package:datapollex/screens/teacherlist_screen.dart';
import 'package:datapollex/widgets/languageCard.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class StudentHomeContent extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(
      builder: (context, appState, child) {
        return Padding(
          padding: EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Choose a Language to Learn',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade800,
                ),
              ),
              SizedBox(height: 16),

              Expanded(
                child: GridView.builder(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 1.2,
                  ),
                  itemCount: appState.supportedLanguages.length,
                  itemBuilder: (context, index) {
                    final language = appState.supportedLanguages[index];
                    return LanguageCard(
                      language: language,
                      onTap: () {
                        appState.selectLanguage(language);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder:
                                (context) =>
                                    TeachersListScreen(language: language),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
