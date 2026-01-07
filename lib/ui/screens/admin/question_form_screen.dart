import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:islamicquiz/core/localization/question_localizations.dart';
import 'package:islamicquiz/data/models/question_model.dart';
import 'package:islamicquiz/data/providers/question_provider.dart';

class QuestionFormScreen extends ConsumerStatefulWidget {
  final QuestionModel? question;

  const QuestionFormScreen({super.key, this.question});

  @override
  ConsumerState<QuestionFormScreen> createState() => _QuestionFormScreenState();
}

class _QuestionFormScreenState extends ConsumerState<QuestionFormScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  late TabController _tabController;

  // English fields
  late final TextEditingController _questionTextEnController;
  late final TextEditingController _explanationEnController;
  late final List<TextEditingController> _optionEnControllers;

  // Urdu fields
  late final TextEditingController _questionTextUrController;
  late final TextEditingController _explanationUrController;
  late final List<TextEditingController> _optionUrControllers;

  late QuestionDifficulty _difficulty;
  late QuestionCategory _category;
  late int _correctOptionIndex;
  late bool _isActive;

  bool _isLoading = false;

  bool get isEditing => widget.question != null;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    final q = widget.question;
    final questionL10n = QuestionLocalizations.instance;

    // Initialize English fields
    String enQuestion = '';
    String enExplanation = '';
    List<String> enOptions = List.filled(4, '');

    // Initialize Urdu fields
    String urQuestion = '';
    String urExplanation = '';
    List<String> urOptions = List.filled(4, '');

    if (q != null) {
      if (q.hasInlineTranslations) {
        // Custom question with inline translations
        final enTrans = q.getTranslation('en');
        final urTrans = q.getTranslation('ur');

        if (enTrans != null) {
          enQuestion = enTrans.questionText;
          enExplanation = enTrans.explanation ?? '';
          enOptions = List.from(enTrans.options);
          while (enOptions.length < 4) enOptions.add('');
        }

        if (urTrans != null) {
          urQuestion = urTrans.questionText;
          urExplanation = urTrans.explanation ?? '';
          urOptions = List.from(urTrans.options);
          while (urOptions.length < 4) urOptions.add('');
        }
      } else if (questionL10n != null) {
        // Seeded question - load from JSON files (read-only display)
        enQuestion = questionL10n.t(q.questionKey);
        enExplanation = q.explanationKey != null ? questionL10n.t(q.explanationKey!) : '';
        enOptions = q.optionsKeys.map((k) => questionL10n.t(k)).toList();
        while (enOptions.length < 4) enOptions.add('');
      }
    }

    _questionTextEnController = TextEditingController(text: enQuestion);
    _explanationEnController = TextEditingController(text: enExplanation);
    _optionEnControllers = List.generate(
      4,
      (i) => TextEditingController(text: i < enOptions.length ? enOptions[i] : ''),
    );

    _questionTextUrController = TextEditingController(text: urQuestion);
    _explanationUrController = TextEditingController(text: urExplanation);
    _optionUrControllers = List.generate(
      4,
      (i) => TextEditingController(text: i < urOptions.length ? urOptions[i] : ''),
    );

    _difficulty = q?.difficulty ?? QuestionDifficulty.easy;
    _category = q?.category ?? QuestionCategory.beliefs;
    _correctOptionIndex = q?.correctOptionIndex ?? 0;
    _isActive = q?.isActive ?? true;
  }

  @override
  void dispose() {
    _tabController.dispose();
    _questionTextEnController.dispose();
    _explanationEnController.dispose();
    for (final c in _optionEnControllers) {
      c.dispose();
    }
    _questionTextUrController.dispose();
    _explanationUrController.dispose();
    for (final c in _optionUrControllers) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isSeededQuestion = isEditing && !widget.question!.hasInlineTranslations;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Question' : 'Add Question'),
        actions: [
          if (isEditing)
            IconButton(
              icon: const Icon(Icons.delete_outline),
              onPressed: _deleteQuestion,
              tooltip: 'Delete',
            ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'English', icon: Icon(Icons.language)),
            Tab(text: 'اردو', icon: Icon(Icons.translate)),
          ],
        ),
      ),
      body: Form(
        key: _formKey,
        child: Column(
          children: [
            if (isSeededQuestion)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                color: Colors.amber.withValues(alpha: 0.2),
                child: Row(
                  children: [
                    const Icon(Icons.info_outline, color: Colors.amber),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'This is a seeded question. Translations are stored in JSON files. '
                        'Editing will convert it to a custom question with inline translations.',
                        style: TextStyle(color: Colors.amber[800], fontSize: 12),
                      ),
                    ),
                  ],
                ),
              ),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildLanguageForm(
                    questionController: _questionTextEnController,
                    explanationController: _explanationEnController,
                    optionControllers: _optionEnControllers,
                    languageLabel: 'English',
                    colorScheme: colorScheme,
                  ),
                  _buildLanguageForm(
                    questionController: _questionTextUrController,
                    explanationController: _explanationUrController,
                    optionControllers: _optionUrControllers,
                    languageLabel: 'Urdu',
                    colorScheme: colorScheme,
                    isRtl: true,
                  ),
                ],
              ),
            ),
            _buildBottomBar(colorScheme),
          ],
        ),
      ),
    );
  }

  Widget _buildLanguageForm({
    required TextEditingController questionController,
    required TextEditingController explanationController,
    required List<TextEditingController> optionControllers,
    required String languageLabel,
    required ColorScheme colorScheme,
    bool isRtl = false,
  }) {
    return Directionality(
      textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildSectionHeader('Question ($languageLabel)', Icons.quiz),
          const SizedBox(height: 12),
          TextFormField(
            controller: questionController,
            decoration: InputDecoration(
              labelText: 'Question Text *',
              hintText: 'Enter the question...',
              border: const OutlineInputBorder(),
              alignLabelWithHint: true,
            ),
            maxLines: 3,
            textCapitalization: TextCapitalization.sentences,
            textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
            validator: languageLabel == 'English'
                ? (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'English question text is required';
                    }
                    if (value.trim().length < 10) {
                      return 'Question must be at least 10 characters';
                    }
                    return null;
                  }
                : null,
          ),
          const SizedBox(height: 24),
          _buildSectionHeader('Answer Options ($languageLabel)', Icons.list),
          const SizedBox(height: 12),
          ..._buildOptionFields(optionControllers, languageLabel, isRtl),
          const SizedBox(height: 24),
          _buildSectionHeader('Explanation ($languageLabel)', Icons.info_outline),
          const SizedBox(height: 12),
          TextFormField(
            controller: explanationController,
            decoration: InputDecoration(
              labelText: 'Explanation (Optional)',
              hintText: 'Kid-friendly explanation of the correct answer...',
              border: const OutlineInputBorder(),
              alignLabelWithHint: true,
            ),
            maxLines: 2,
            textCapitalization: TextCapitalization.sentences,
            textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
          ),
          const SizedBox(height: 80),
        ],
      ),
    );
  }

  List<Widget> _buildOptionFields(
    List<TextEditingController> controllers,
    String languageLabel,
    bool isRtl,
  ) {
    return List.generate(4, (index) {
      final isCorrect = _correctOptionIndex == index;
      return Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Radio<int>(
              value: index,
              groupValue: _correctOptionIndex,
              onChanged: (val) => setState(() => _correctOptionIndex = val!),
            ),
            Expanded(
              child: TextFormField(
                controller: controllers[index],
                decoration: InputDecoration(
                  labelText: 'Option ${index + 1} *',
                  hintText: 'Enter option ${index + 1}...',
                  border: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: isCorrect ? Colors.green : Colors.grey,
                      width: isCorrect ? 2 : 1,
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: isCorrect ? Colors.green : Colors.grey.shade400,
                      width: isCorrect ? 2 : 1,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: isCorrect ? Colors.green : Theme.of(context).colorScheme.primary,
                      width: 2,
                    ),
                  ),
                  suffixIcon: isCorrect
                      ? const Icon(Icons.check_circle, color: Colors.green)
                      : null,
                ),
                textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
                validator: languageLabel == 'English'
                    ? (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Option ${index + 1} is required';
                        }
                        return null;
                      }
                    : null,
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Theme.of(context).colorScheme.primary),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Widget _buildBottomBar(ColorScheme colorScheme) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<QuestionDifficulty>(
                  initialValue: _difficulty,
                  decoration: const InputDecoration(
                    labelText: 'Difficulty',
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                  items: QuestionDifficulty.values.map((d) {
                    return DropdownMenuItem(
                      value: d,
                      child: Row(
                        children: [
                          Container(
                            width: 12,
                            height: 12,
                            decoration: BoxDecoration(
                              color: _getDifficultyColor(d),
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(d.name.toUpperCase()),
                        ],
                      ),
                    );
                  }).toList(),
                  onChanged: (val) => setState(() => _difficulty = val!),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: DropdownButtonFormField<QuestionCategory>(
                  initialValue: _category,
                  decoration: const InputDecoration(
                    labelText: 'Category',
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                  items: QuestionCategory.values.map((c) {
                    return DropdownMenuItem(
                      value: c,
                      child: Text(c.name),
                    );
                  }).toList(),
                  onChanged: (val) => setState(() => _category = val!),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade400),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _isActive ? 'Active' : 'Inactive',
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          color: _isActive ? Colors.green : Colors.red,
                        ),
                      ),
                      Switch(
                        value: _isActive,
                        onChanged: (val) => setState(() => _isActive = val),
                        activeTrackColor: Colors.green.withValues(alpha: 0.5),
                        activeThumbColor: Colors.green,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: SizedBox(
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _submitForm,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: colorScheme.primary,
                      foregroundColor: colorScheme.onPrimary,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                          )
                        : Text(
                            isEditing ? 'Update' : 'Add Question',
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Color _getDifficultyColor(QuestionDifficulty difficulty) {
    switch (difficulty) {
      case QuestionDifficulty.easy:
        return Colors.green;
      case QuestionDifficulty.medium:
        return Colors.orange;
      case QuestionDifficulty.hard:
        return Colors.red;
    }
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // Validate English options are unique
    final enOptions = _optionEnControllers.map((c) => c.text.trim()).toList();
    final uniqueEnOptions = enOptions.where((o) => o.isNotEmpty).toSet();
    if (uniqueEnOptions.length != 4) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('All English options must be unique and filled')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final notifier = ref.read(questionNotifierProvider.notifier);
      final now = DateTime.now();
      final id = widget.question?.id ?? _generateId();

      // Build translations map
      final Map<String, QuestionTranslation> translations = {};

      // English translation (required)
      translations['en'] = QuestionTranslation(
        questionText: _questionTextEnController.text.trim(),
        options: enOptions,
        explanation: _explanationEnController.text.trim().isEmpty
            ? null
            : _explanationEnController.text.trim(),
      );

      // Urdu translation (optional but include if any field is filled)
      final urQuestion = _questionTextUrController.text.trim();
      final urOptions = _optionUrControllers.map((c) => c.text.trim()).toList();
      final urExplanation = _explanationUrController.text.trim();

      if (urQuestion.isNotEmpty || urOptions.any((o) => o.isNotEmpty)) {
        // Fill empty Urdu options with English fallback
        final filledUrOptions = List.generate(4, (i) {
          return urOptions[i].isNotEmpty ? urOptions[i] : enOptions[i];
        });

        translations['ur'] = QuestionTranslation(
          questionText: urQuestion.isNotEmpty ? urQuestion : _questionTextEnController.text.trim(),
          options: filledUrOptions,
          explanation: urExplanation.isNotEmpty ? urExplanation : translations['en']!.explanation,
        );
      }

      // Create question with inline translations
      final question = QuestionModel(
        id: id,
        questionKey: 'custom_$id', // Key for custom questions
        difficulty: _difficulty,
        category: _category,
        optionsKeys: List.generate(4, (i) => 'custom_${id}_option_$i'),
        correctOptionIndex: _correctOptionIndex,
        explanationKey: 'custom_${id}_explanation',
        isActive: _isActive,
        createdAt: widget.question?.createdAt ?? now,
        updatedAt: now,
        translations: translations,
      );

      if (isEditing) {
        await notifier.updateQuestion(question);
      } else {
        await notifier.addQuestion(question);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(isEditing ? 'Question updated' : 'Question added'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _deleteQuestion() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Question'),
        content: const Text('Are you sure you want to delete this question? This cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm == true && widget.question != null) {
      setState(() => _isLoading = true);
      try {
        await ref.read(questionNotifierProvider.notifier).deleteQuestion(widget.question!.id);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Question deleted')),
          );
          Navigator.pop(context);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
          );
        }
      } finally {
        if (mounted) {
          setState(() => _isLoading = false);
        }
      }
    }
  }

  String _generateId() {
    final prefix = _difficulty.name.substring(0, 1);
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    return '${prefix}_custom_$timestamp';
  }
}
