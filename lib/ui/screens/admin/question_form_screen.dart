import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:islamicquiz/data/models/question_model.dart';
import 'package:islamicquiz/data/providers/question_provider.dart';

class QuestionFormScreen extends ConsumerStatefulWidget {
  final QuestionModel? question;

  const QuestionFormScreen({super.key, this.question});

  @override
  ConsumerState<QuestionFormScreen> createState() => _QuestionFormScreenState();
}

class _QuestionFormScreenState extends ConsumerState<QuestionFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _questionTextController;
  late final TextEditingController _explanationController;
  late final TextEditingController _audioUrlController;
  late final List<TextEditingController> _optionControllers;

  late QuestionDifficulty _difficulty;
  late QuestionCategory _category;
  late int _correctOptionIndex;
  late bool _isActive;
  late String _language;

  bool _isLoading = false;

  bool get isEditing => widget.question != null;

  @override
  void initState() {
    super.initState();
    final q = widget.question;

    _questionTextController = TextEditingController(text: q?.questionText ?? '');
    _explanationController = TextEditingController(text: q?.explanation ?? '');
    _audioUrlController = TextEditingController(text: q?.audioUrl ?? '');

    _optionControllers = List.generate(
      4,
      (i) => TextEditingController(text: q != null && i < q.options.length ? q.options[i] : ''),
    );

    _difficulty = q?.difficulty ?? QuestionDifficulty.easy;
    _category = q?.category ?? QuestionCategory.beliefs;
    _correctOptionIndex = q?.correctOptionIndex ?? 0;
    _isActive = q?.isActive ?? true;
    _language = q?.language ?? 'en';
  }

  @override
  void dispose() {
    _questionTextController.dispose();
    _explanationController.dispose();
    _audioUrlController.dispose();
    for (final c in _optionControllers) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

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
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _buildSectionHeader('Question Details', Icons.quiz),
            const SizedBox(height: 12),
            _buildQuestionTextField(),
            const SizedBox(height: 16),
            _buildDropdownRow(),
            const SizedBox(height: 24),
            _buildSectionHeader('Answer Options', Icons.list),
            const SizedBox(height: 12),
            ..._buildOptionFields(),
            const SizedBox(height: 24),
            _buildSectionHeader('Additional Info', Icons.info_outline),
            const SizedBox(height: 12),
            _buildExplanationField(),
            const SizedBox(height: 16),
            _buildAudioUrlField(),
            const SizedBox(height: 16),
            _buildLanguageAndStatusRow(colorScheme),
            const SizedBox(height: 32),
            _buildSubmitButton(colorScheme),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
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

  Widget _buildQuestionTextField() {
    return TextFormField(
      controller: _questionTextController,
      decoration: const InputDecoration(
        labelText: 'Question Text *',
        hintText: 'Enter the question...',
        border: OutlineInputBorder(),
        alignLabelWithHint: true,
      ),
      maxLines: 3,
      textCapitalization: TextCapitalization.sentences,
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'Question text is required';
        }
        if (value.trim().length < 10) {
          return 'Question must be at least 10 characters';
        }
        return null;
      },
    );
  }

  Widget _buildDropdownRow() {
    return Row(
      children: [
        Expanded(
          child: DropdownButtonFormField<QuestionDifficulty>(
            initialValue: _difficulty,
            decoration: const InputDecoration(
              labelText: 'Difficulty *',
              border: OutlineInputBorder(),
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
        const SizedBox(width: 16),
        Expanded(
          child: DropdownButtonFormField<QuestionCategory>(
            initialValue: _category,
            decoration: const InputDecoration(
              labelText: 'Category *',
              border: OutlineInputBorder(),
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
    );
  }

  List<Widget> _buildOptionFields() {
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
                controller: _optionControllers[index],
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
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Option ${index + 1} is required';
                  }
                  return null;
                },
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildExplanationField() {
    return TextFormField(
      controller: _explanationController,
      decoration: const InputDecoration(
        labelText: 'Explanation (Optional)',
        hintText: 'Kid-friendly explanation of the correct answer...',
        border: OutlineInputBorder(),
        alignLabelWithHint: true,
      ),
      maxLines: 2,
      textCapitalization: TextCapitalization.sentences,
    );
  }

  Widget _buildAudioUrlField() {
    return TextFormField(
      controller: _audioUrlController,
      decoration: const InputDecoration(
        labelText: 'Audio URL (Optional)',
        hintText: 'Firebase Storage URL for audio...',
        border: OutlineInputBorder(),
        prefixIcon: Icon(Icons.audiotrack),
      ),
      keyboardType: TextInputType.url,
    );
  }

  Widget _buildLanguageAndStatusRow(ColorScheme colorScheme) {
    return Row(
      children: [
        Expanded(
          child: DropdownButtonFormField<String>(
            initialValue: _language,
            decoration: const InputDecoration(
              labelText: 'Language',
              border: OutlineInputBorder(),
            ),
            items: const [
              DropdownMenuItem(value: 'en', child: Text('English')),
              DropdownMenuItem(value: 'ar', child: Text('Arabic')),
              DropdownMenuItem(value: 'ur', child: Text('Urdu')),
              DropdownMenuItem(value: 'fr', child: Text('French')),
              DropdownMenuItem(value: 'es', child: Text('Spanish')),
            ],
            onChanged: (val) => setState(() => _language = val!),
          ),
        ),
        const SizedBox(width: 16),
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
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Active Status', style: TextStyle(fontSize: 12, color: Colors.grey)),
                    Text(
                      _isActive ? 'Active' : 'Inactive',
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        color: _isActive ? Colors.green : Colors.red,
                      ),
                    ),
                  ],
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
      ],
    );
  }

  Widget _buildSubmitButton(ColorScheme colorScheme) {
    return SizedBox(
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
                isEditing ? 'Update Question' : 'Add Question',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
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

    // Validate options are unique
    final options = _optionControllers.map((c) => c.text.trim()).toList();
    final uniqueOptions = options.toSet();
    if (uniqueOptions.length != 4) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('All options must be unique')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final notifier = ref.read(questionNotifierProvider.notifier);
      final now = DateTime.now();

      final question = QuestionModel(
        id: widget.question?.id ?? _generateId(),
        questionText: _questionTextController.text.trim(),
        difficulty: _difficulty,
        category: _category,
        options: options,
        correctOptionIndex: _correctOptionIndex,
        explanation: _explanationController.text.trim().isEmpty
            ? null
            : _explanationController.text.trim(),
        isActive: _isActive,
        createdAt: widget.question?.createdAt ?? now,
        updatedAt: now,
        audioUrl: _audioUrlController.text.trim().isEmpty
            ? null
            : _audioUrlController.text.trim(),
        language: _language,
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
