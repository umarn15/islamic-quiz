# Question Localization System

## Overview

This app uses a key-based localization system for questions. Questions are stored once (language-agnostic) with localization keys, and text is resolved at runtime based on the user's locale.

## Architecture

### Question Model (Firestore-safe)
```dart
QuestionModel(
  id: 'easy_001',
  questionKey: 'easy_001_question',
  optionsKeys: ['easy_001_option_0', 'easy_001_option_1', ...],
  explanationKey: 'easy_001_explanation',
  audioKey: 'easy_001', // Resolved as: audio/{locale}/easy_001.mp3
  difficulty: QuestionDifficulty.easy,
  category: QuestionCategory.prayer,
  correctOptionIndex: 0,
)
```

### Localization Files
- `assets/l10n/en.json` - English translations
- `assets/l10n/ur.json` - Urdu translations

### Key Format
```
{difficulty}_{number}_question
{difficulty}_{number}_option_{index}
{difficulty}_{number}_explanation
```

## Usage in UI

### Initialize (done in main.dart)
```dart
await QuestionLocalizations.init(Locale('en'));
```

### Access in Widgets
```dart
final questionL10n = context.questionL10n;

// Get question text
final questionText = questionL10n.getQuestionText(question.questionKey);

// Get options
final options = questionL10n.getOptions(question.optionsKeys);

// Get explanation
final explanation = questionL10n.getExplanation(question.explanationKey);

// Get audio path
final audioPath = questionL10n.getAudioPath(question.audioKey!);
// Returns: audio/en/easy_001.mp3
```

### Direct Translation
```dart
final text = questionL10n.t('easy_001_question');
```

## Offline Support

- Bundled questions in `lib/data/local_questions.dart`
- Bundled translations in `assets/l10n/en.json`
- Firestore overrides local when online

## Adding New Languages

1. Create `assets/l10n/{lang_code}.json`
2. Add locale to `AppLocalizations.supportedLocales`
3. Add audio files to `assets/audio/{lang_code}/`

## Audio Resolution

Audio files are resolved by locale:
```
audioKey: 'easy_001'
→ audio/en/easy_001.mp3 (English)
→ audio/ur/easy_001.mp3 (Urdu)
```
