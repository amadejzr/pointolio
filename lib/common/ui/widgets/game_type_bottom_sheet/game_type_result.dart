/// Result data returned from GameTypeBottomSheet.
///
/// Contains the game type information entered by the user.
class GameTypeResult {
  GameTypeResult({
    required this.name,
    required this.lowestScoreWins,
    this.color,
  });

  final String name;
  final bool lowestScoreWins;
  final int? color;
}
