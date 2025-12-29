import 'package:flutter/material.dart';
import 'package:islamicquiz/core/theme_data.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Islamic Quiz'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              // TODO: Navigate to settings
            },
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Welcome Card
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      const Icon(
                        Icons.waving_hand,
                        size: 48,
                        color: accentGold,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Assalamu Alaikum!',
                        style: textTheme.headlineMedium,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Ready to learn about Islam?',
                        style: textTheme.bodyMedium,
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              
              // Stats Row
              Row(
                children: [
                  Expanded(
                    child: _buildStatCard(
                      textTheme: textTheme,
                      icon: Icons.emoji_events,
                      label: 'Points',
                      value: '0',
                      color: accentGold,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildStatCard(
                      textTheme: textTheme,
                      icon: Icons.star,
                      label: 'Level',
                      value: '1',
                      color: starYellow,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              
              // Quiz Categories
              Text(
                'Choose a Category',
                style: textTheme.titleLarge,
              ),
              const SizedBox(height: 16),
              
              _buildCategoryCard(
                textTheme: textTheme,
                title: 'Prophets',
                subtitle: 'Learn about the Prophets',
                icon: Icons.person,
                color: primaryGreen,
                onTap: () {
                  // TODO: Navigate to Prophets quiz
                },
              ),
              const SizedBox(height: 12),
              
              _buildCategoryCard(
                textTheme: textTheme,
                title: 'Quran',
                subtitle: 'Test your Quran knowledge',
                icon: Icons.menu_book,
                color: secondaryTeal,
                onTap: () {
                  // TODO: Navigate to Quran quiz
                },
              ),
              const SizedBox(height: 12),
              
              _buildCategoryCard(
                textTheme: textTheme,
                title: 'Pillars of Islam',
                subtitle: 'Learn the 5 pillars',
                icon: Icons.mosque,
                color: accentGold,
                onTap: () {
                  // TODO: Navigate to Pillars quiz
                },
              ),
              const SizedBox(height: 12),
              
              _buildCategoryCard(
                textTheme: textTheme,
                title: 'Good Deeds',
                subtitle: 'Learn about good actions',
                icon: Icons.favorite,
                color: successGreen,
                onTap: () {
                  // TODO: Navigate to Good Deeds quiz
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard({
    required TextTheme textTheme,
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, size: 32, color: color),
            const SizedBox(height: 8),
            Text(
              value,
              style: textTheme.headlineMedium?.copyWith(
                    color: color,
                  ),
            ),
            Text(
              label,
              style: textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryCard({
    required TextTheme textTheme,
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, size: 32, color: color),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: textTheme.titleLarge,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios, size: 20),
            ],
          ),
        ),
      ),
    );
  }
}
