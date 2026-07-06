import 'package:flutter/material.dart';

class SocialPost {
  final String id;
  final String author;
  final String content;
  int likes;
  final List<String> comments;
  final DateTime timestamp;
  bool isLiked;

  SocialPost({
    required this.id,
    required this.author,
    required this.content,
    required this.likes,
    required this.comments,
    required this.timestamp,
    this.isLiked = false,
  });
}

class FitnessChallenge {
  final String id;
  final String title;
  final String description;
  final int participantCount;
  final String goalStreak;
  bool isJoined;

  FitnessChallenge({
    required this.id,
    required this.title,
    required this.description,
    required this.participantCount,
    required this.goalStreak,
    this.isJoined = false,
  });
}

class LeaderboardEntry {
  final int rank;
  final String name;
  final int score;

  LeaderboardEntry({
    required this.rank,
    required this.name,
    required this.score,
  });
}

class SocialProvider extends ChangeNotifier {
  final List<SocialPost> _feedPosts = [
    SocialPost(
      id: '1',
      author: 'Ayesha Khan',
      content: 'Just smashed my Monday Push Split workout! Finished with 15 incline pushups. Feel super strong!',
      likes: 12,
      comments: ['Keep it up!', 'Amazing focus!'],
      timestamp: DateTime.now().subtract(const Duration(hours: 1)),
    ),
    SocialPost(
      id: '2',
      author: 'Zain Ahmed',
      content: 'Clean protein morning breakfast oatmeal bowl. Hit my 30g protein baseline today! 🥗',
      likes: 8,
      comments: ['Looks clean!', 'What substitutions did you use?'],
      timestamp: DateTime.now().subtract(const Duration(hours: 3)),
    ),
  ];

  final List<FitnessChallenge> _challenges = [
    FitnessChallenge(
      id: 'c1',
      title: '7-Day Workout Streak',
      description: 'Log any workout activity for 7 consecutive days. Keep the fire burning!',
      participantCount: 412,
      goalStreak: '7 days',
      isJoined: true,
    ),
    FitnessChallenge(
      id: 'c2',
      title: 'Pure Hydration Quest',
      description: 'Log at least 2.5L water daily to complete the wellness balance track.',
      participantCount: 184,
      goalStreak: '5 days',
      isJoined: false,
    ),
  ];

  final List<LeaderboardEntry> _leaderboard = [
    LeaderboardEntry(rank: 1, name: 'Sana Malik', score: 98),
    LeaderboardEntry(rank: 2, name: 'Bilal Farooq', score: 95),
    LeaderboardEntry(rank: 3, name: 'You (ShapeUp User)', score: 90),
    LeaderboardEntry(rank: 4, name: 'Hamza Niaz', score: 85),
  ];

  List<SocialPost> get feedPosts => _feedPosts;
  List<FitnessChallenge> get challenges => _challenges;
  List<LeaderboardEntry> get leaderboard => _leaderboard;

  void likePost(String id) {
    final idx = _feedPosts.indexWhere((p) => p.id == id);
    if (idx != -1) {
      final post = _feedPosts[idx];
      if (post.isLiked) {
        post.likes--;
        post.isLiked = false;
      } else {
        post.likes++;
        post.isLiked = true;
      }
      notifyListeners();
    }
  }

  bool addPost(String author, String content) {
    // Safety & Anti-toxicity moderation check: filter bad terms
    final lower = content.toLowerCase();
    if (lower.contains('fat') && (lower.contains('ugly') || lower.contains('hate'))) {
      // Abusive content blocked
      return false;
    }

    _feedPosts.insert(
      0,
      SocialPost(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        author: author,
        content: content,
        likes: 0,
        comments: [],
        timestamp: DateTime.now(),
      ),
    );
    notifyListeners();
    return true;
  }

  void toggleChallenge(String id) {
    final idx = _challenges.indexWhere((c) => c.id == id);
    if (idx != -1) {
      _challenges[idx].isJoined = !_challenges[idx].isJoined;
      notifyListeners();
    }
  }
}
