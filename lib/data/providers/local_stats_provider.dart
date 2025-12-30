import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:islamicquiz/data/models/user_model.dart';
import 'package:islamicquiz/data/providers/shared_prefs_provider.dart';

final localStatsProvider = StateNotifierProvider<LocalStatsNotifier, LocalStats>((ref) {
  final prefs = ref.watch(sharedPrefsProvider);
  return LocalStatsNotifier(prefs);
});

class LocalStats {
  final int points;
  final int level;

  LocalStats({this.points = 0, this.level = 1});
}

class LocalStatsNotifier extends StateNotifier<LocalStats> {
  final dynamic _prefs;
  static const _pointsKey = 'local_points';

  LocalStatsNotifier(this._prefs) : super(LocalStats()) {
    _load();
  }

  void _load() {
    final points = _prefs.getInt(_pointsKey) ?? 0;
    final level = UserModel.calculateLevel(points);
    state = LocalStats(points: points, level: level);
  }

  Future<void> addPoints(int pointsToAdd) async {
    final newPoints = state.points + pointsToAdd;
    final newLevel = UserModel.calculateLevel(newPoints);
    await _prefs.setInt(_pointsKey, newPoints);
    state = LocalStats(points: newPoints, level: newLevel);
  }

  Future<void> reset() async {
    await _prefs.setInt(_pointsKey, 0);
    state = LocalStats(points: 0, level: 1);
  }
}
