import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:islamicquiz/core/localization/question_localizations.dart';
import 'package:islamicquiz/data/models/question_model.dart';
import 'package:islamicquiz/data/providers/question_provider.dart';
import 'question_form_screen.dart';

class AdminPanelScreen extends ConsumerStatefulWidget {
  const AdminPanelScreen({super.key});

  @override
  ConsumerState<AdminPanelScreen> createState() => _AdminPanelScreenState();
}

class _AdminPanelScreenState extends ConsumerState<AdminPanelScreen> {
  QuestionDifficulty? _selectedDifficulty;
  QuestionCategory? _selectedCategory;
  bool? _selectedActiveStatus;
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final questionsAsync = ref.watch(questionNotifierProvider);
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Panel'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.read(questionNotifierProvider.notifier).loadQuestions(),
            tooltip: 'Refresh',
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert),
            onSelected: (value) => _handleMenuAction(value),
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'seed', child: Text('Seed Questions')),
              const PopupMenuItem(value: 'clear_filters', child: Text('Clear Filters')),
            ],
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _navigateToForm(context),
        icon: const Icon(Icons.add),
        label: const Text('Add Question'),
      ),
      body: Column(
        children: [
          _buildFilters(colorScheme),
          _buildSearchBar(),
          Expanded(
            child: questionsAsync.when(
              data: (questions) => _buildQuestionList(questions),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('Error: $e')),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilters(ColorScheme colorScheme) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
        border: Border(bottom: BorderSide(color: colorScheme.outline.withValues(alpha: 0.2))),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _buildFilterChip(
              label: 'Difficulty',
              value: _selectedDifficulty?.name,
              items: QuestionDifficulty.values.map((d) => d.name).toList(),
              onSelected: (val) => setState(() {
                _selectedDifficulty = val != null
                    ? QuestionDifficulty.values.firstWhere((d) => d.name == val)
                    : null;
              }),
            ),
            const SizedBox(width: 8),
            _buildFilterChip(
              label: 'Category',
              value: _selectedCategory?.name,
              items: QuestionCategory.values.map((c) => c.name).toList(),
              onSelected: (val) => setState(() {
                _selectedCategory = val != null
                    ? QuestionCategory.values.firstWhere((c) => c.name == val)
                    : null;
              }),
            ),
            const SizedBox(width: 8),
            _buildFilterChip(
              label: 'Status',
              value: _selectedActiveStatus == null
                  ? null
                  : (_selectedActiveStatus! ? 'Active' : 'Inactive'),
              items: const ['Active', 'Inactive'],
              onSelected: (val) => setState(() {
                _selectedActiveStatus = val == null ? null : val == 'Active';
              }),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip({
    required String label,
    required String? value,
    required List<String> items,
    required void Function(String?) onSelected,
  }) {
    return PopupMenuButton<String?>(
      initialValue: value,
      onSelected: onSelected,
      child: Chip(
        label: Text(value ?? label),
        deleteIcon: value != null ? const Icon(Icons.close, size: 18) : null,
        onDeleted: value != null ? () => onSelected(null) : null,
        avatar: value == null ? const Icon(Icons.filter_list, size: 18) : null,
      ),
      itemBuilder: (context) => [
        const PopupMenuItem<String?>(value: null, child: Text('All')),
        ...items.map((item) => PopupMenuItem(value: item, child: Text(item))),
      ],
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: TextField(
        decoration: InputDecoration(
          hintText: 'Search questions...',
          prefixIcon: const Icon(Icons.search),
          suffixIcon: _searchQuery.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () => setState(() => _searchQuery = ''),
                )
              : null,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
        onChanged: (val) => setState(() => _searchQuery = val),
      ),
    );
  }

  Widget _buildQuestionList(List<QuestionModel> questions) {
    final filtered = _filterQuestions(questions);

    if (filtered.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.quiz_outlined, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              questions.isEmpty ? 'No questions yet' : 'No matching questions',
              style: TextStyle(fontSize: 18, color: Colors.grey[600]),
            ),
            if (questions.isEmpty) ...[
              const SizedBox(height: 8),
              TextButton.icon(
                onPressed: () => _handleMenuAction('seed'),
                icon: const Icon(Icons.download),
                label: const Text('Seed Local Questions'),
              ),
            ],
          ],
        ),
      );
    }

    // Group by difficulty
    final grouped = <QuestionDifficulty, List<QuestionModel>>{};
    for (final q in filtered) {
      grouped.putIfAbsent(q.difficulty, () => []).add(q);
    }

    return ListView.builder(
      padding: const EdgeInsets.only(bottom: 80),
      itemCount: grouped.length,
      itemBuilder: (context, index) {
        final difficulty = grouped.keys.elementAt(index);
        final items = grouped[difficulty]!;
        return _buildDifficultySection(difficulty, items);
      },
    );
  }

  Widget _buildDifficultySection(QuestionDifficulty difficulty, List<QuestionModel> questions) {
    final difficultyColor = _getDifficultyColor(difficulty);

    return ExpansionTile(
      initiallyExpanded: true,
      leading: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: difficultyColor.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          difficulty.name.toUpperCase(),
          style: TextStyle(
            color: difficultyColor,
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
        ),
      ),
      title: Text('${questions.length} questions'),
      children: questions.map((q) => _buildQuestionTile(q)).toList(),
    );
  }

  Widget _buildQuestionTile(QuestionModel question) {
    final questionL10n = QuestionLocalizations.instance;
    // Get display text - use inline translation for custom questions, or key lookup for seeded ones
    final displayText = questionL10n?.getDisplayText(question.questionKey, question: question) 
        ?? question.questionKey;
    
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: _getCategoryColor(question.category).withValues(alpha: 0.2),
          child: Icon(
            _getCategoryIcon(question.category),
            color: _getCategoryColor(question.category),
            size: 20,
          ),
        ),
        title: Text(
          displayText,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Row(
          children: [
            _buildTag(question.category.name, _getCategoryColor(question.category)),
            const SizedBox(width: 8),
            _buildTag(
              question.isActive ? 'Active' : 'Inactive',
              question.isActive ? Colors.green : Colors.red,
            ),
            if (question.hasInlineTranslations) ...[
              const SizedBox(width: 8),
              _buildTag('Custom', Colors.purple),
            ],
          ],
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (action) => _handleQuestionAction(action, question),
          itemBuilder: (context) => [
            const PopupMenuItem(value: 'edit', child: Text('Edit')),
            PopupMenuItem(
              value: 'toggle',
              child: Text(question.isActive ? 'Deactivate' : 'Activate'),
            ),
            const PopupMenuItem(
              value: 'delete',
              child: Text('Delete', style: TextStyle(color: Colors.red)),
            ),
          ],
        ),
        onTap: () => _navigateToForm(context, question: question),
      ),
    );
  }

  Widget _buildTag(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        text,
        style: TextStyle(fontSize: 11, color: color, fontWeight: FontWeight.w500),
      ),
    );
  }

  List<QuestionModel> _filterQuestions(List<QuestionModel> questions) {
    final questionL10n = QuestionLocalizations.instance;
    
    return questions.where((q) {
      if (_selectedDifficulty != null && q.difficulty != _selectedDifficulty) return false;
      if (_selectedCategory != null && q.category != _selectedCategory) return false;
      if (_selectedActiveStatus != null && q.isActive != _selectedActiveStatus) return false;
      if (_searchQuery.isNotEmpty) {
        final displayText = questionL10n?.getDisplayText(q.questionKey, question: q) ?? q.questionKey;
        if (!displayText.toLowerCase().contains(_searchQuery.toLowerCase())) {
          return false;
        }
      }
      return true;
    }).toList();
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

  Color _getCategoryColor(QuestionCategory category) {
    switch (category) {
      case QuestionCategory.prayer:
        return Colors.blue;
      case QuestionCategory.quran:
        return Colors.teal;
      case QuestionCategory.prophets:
        return Colors.purple;
      case QuestionCategory.pillars:
        return Colors.indigo;
      case QuestionCategory.manners:
        return Colors.pink;
      case QuestionCategory.history:
        return Colors.brown;
      case QuestionCategory.angels:
        return Colors.cyan;
      case QuestionCategory.beliefs:
        return Colors.deepOrange;
      case QuestionCategory.vocabulary:
        return Colors.amber;
      case QuestionCategory.companions:
        return Colors.lime;
    }
  }

  IconData _getCategoryIcon(QuestionCategory category) {
    switch (category) {
      case QuestionCategory.prayer:
        return Icons.mosque;
      case QuestionCategory.quran:
        return Icons.menu_book;
      case QuestionCategory.prophets:
        return Icons.person;
      case QuestionCategory.pillars:
        return Icons.account_balance;
      case QuestionCategory.manners:
        return Icons.favorite;
      case QuestionCategory.history:
        return Icons.history_edu;
      case QuestionCategory.angels:
        return Icons.auto_awesome;
      case QuestionCategory.beliefs:
        return Icons.lightbulb;
      case QuestionCategory.vocabulary:
        return Icons.translate;
      case QuestionCategory.companions:
        return Icons.groups;
    }
  }

  void _navigateToForm(BuildContext context, {QuestionModel? question}) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => QuestionFormScreen(question: question),
      ),
    );
  }

  void _handleQuestionAction(String action, QuestionModel question) async {
    final notifier = ref.read(questionNotifierProvider.notifier);

    switch (action) {
      case 'edit':
        _navigateToForm(context, question: question);
        break;
      case 'toggle':
        await notifier.toggleQuestionStatus(question.id, !question.isActive);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(question.isActive ? 'Question deactivated' : 'Question activated'),
            ),
          );
        }
        break;
      case 'delete':
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
        if (confirm == true) {
          await notifier.deleteQuestion(question.id);
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Question deleted')),
            );
          }
        }
        break;
    }
  }

  void _handleMenuAction(String action) async {
    switch (action) {
      case 'seed':
        final confirm = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Seed Questions'),
            content: const Text('This will add local questions to Firestore. Existing questions will not be overwritten.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Seed'),
              ),
            ],
          ),
        );
        if (confirm == true) {
          await ref.read(questionNotifierProvider.notifier).seedQuestions();
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Questions seeded successfully')),
            );
          }
        }
        break;
      case 'clear_filters':
        setState(() {
          _selectedDifficulty = null;
          _selectedCategory = null;
          _selectedActiveStatus = null;
          _searchQuery = '';
        });
        break;
    }
  }
}
