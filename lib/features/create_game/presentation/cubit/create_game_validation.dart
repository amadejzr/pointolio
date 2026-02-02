/// Constants for create game validation
class CreateGameValidation {
  // Field names for error mapping
  static const String gameNameField = 'gameName';
  static const String gameTypeField = 'gameType';
  static const String playersField = 'players';

  // Error messages
  static const String gameNameEmptyError = 'Game name cannot be empty';
  static const String gameTypeRequiredError = 'Please select a game type';
  static const String playersMinimumError = 'At least 2 players required';

  // Constants
  static const int minimumPlayersRequired = 2;
}
