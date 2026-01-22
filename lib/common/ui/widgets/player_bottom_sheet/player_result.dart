/// Result data returned from PlayerBottomSheet.
///
/// Contains the player information entered by the user.
class PlayerResult {
  PlayerResult({
    required this.firstName,
    this.lastName,
    this.color,
  });

  final String firstName;
  final String? lastName;
  final int? color;
}
