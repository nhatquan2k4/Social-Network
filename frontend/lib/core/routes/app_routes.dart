class AppRoutes {
  static const String welcome = '/';
  static const String login = '/login';
  static const String fogot = '/fogot';
  static const String register = '/register';
  static const String profile = '/profile';
  static const String friends = '/friends';
  static const String conversations = '/conversations';
  static const String messages = '/messages/direct';
  static const String groups = '/messages/group';
  static const String posts = '/posts';
  static const String postsFeed = '/posts/feed';
  static const String postsCreate = '/posts/create';
  static const String explore = '/explore';
  static const String reels = '/reels';
  static String postById(String postId) => '/posts/$postId';
  static String postLike(String postId) => '/posts/$postId/like';
  static String postComments(String postId) => '/posts/$postId/comments';
  static String postCommentById(String postId, String commentId) =>
      '/posts/$postId/comments/$commentId';
}
