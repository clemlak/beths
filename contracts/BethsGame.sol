pragma solidity 0.4.24;

import "openzeppelin-solidity/contracts/math/SafeMath.sol";
import "./BethsHouse.sol";


/**
 * @title We manage all the things related to our games here
 * @author Clemlak (https://www.beths.co)
 */
contract BethsGame is BethsHouse {
  /**
   * @notice We use the SafeMath library in order to prevent overflow errors
   * @dev Don't forget to use add(), sub(), ... instead of +, -, ...
   */
  using SafeMath for uint256;

  /**
   * @notice Emitted when a new game is opened
   * @param gameId The id of the corresponding game
   * @param teamA The name of the team A
   * @param teamB The name of the team B
   * @param description A small description of the game
   * @param frozenTimestamp The exact moment when the game will be frozen
   */
  event GameHasOpened(uint gameId, string teamA, string teamB, string description, uint frozenTimestamp);

  /**
   * @notice Emitted when a game is frozen
   * @param gameId The id of the corresponding game
   */
  event GameHasFrozen(uint gameId);

  /**
   * @notice Emitted when a game is closed
   * @param gameId The id of the corresponding game
   * @param result The result of the game (see: enum GameResults)
   */
  event GameHasClosed(uint gameId, GameResults result);

  /**
   * @notice All the different states a game can have (only 1 at a time)
   */
  enum GameStates { Open, Frozen, Closed }

  /**
   * @notice All the possible results (only 1 at a time)
   * @dev All new games are initialized with a NotYet result
   */
  enum GameResults { NotYet, TeamA, Draw, TeamB }

  /**
   * @notice This struct defines what a game is
   */
  struct Game {
    string teamA;
    uint amountToTeamA;
    string teamB;
    uint amountToTeamB;
    uint amountToDraw;
    string description;
    uint frozenTimestamp;
    uint bettorsCount;
    GameResults result;
    GameStates state;
    bool isHouseCutWithdrawn;
  }

  /**
  * @notice We store all our games in an array
  */
  Game[] public games;

  /**
   * @notice This function creates a new game
   * @dev Can only be called externally by the owner
   * @param teamA The name of the team A
   * @param teamB The name of the team B
   * @param description A small description of the game
   * @param frozenTimestamp A timestamp representing when the game will be frozen
   */
  function createNewGame(
    string teamA,
    string teamB,
    string description,
    uint frozenTimestamp
  ) external onlyOwner {
    // We push the new game directly into our array
    uint gameId = games.push(Game(
      teamA, 0, teamB, 0, 0, description, frozenTimestamp, 0, GameResults.NotYet, GameStates.Open, false
    )) - 1;

    emit GameHasOpened(gameId, teamA, teamB, description, frozenTimestamp);
  }

  /**
   * @notice We use this function to froze a game
   * @dev Can only be called externally by the owner
   * @param gameId The id of the corresponding game
   */
  function freezeGame(uint gameId) external onlyOwner whenGameIsOpen(gameId) {
    games[gameId].state = GameStates.Frozen;

    emit GameHasFrozen(gameId);
  }

  /**
   * @notice We use this function to close a game
   * @dev Can only be called by the owner when a game is frozen
   * @param gameId The id of a specific game
   * @param result The result of the game (see: enum GameResults)
   */
  function closeGame(uint gameId, GameResults result) external onlyOwner whenGameIsFrozen(gameId) {
    games[gameId].state = GameStates.Closed;
    games[gameId].result = result;

    emit GameHasClosed(gameId, result);
  }

  /**
   * @notice Returns some basic information about a specific game
   * @dev This function DOES NOT return the bets-related info, the current state or the result of the game
   * @param gameId The id of the corresponding game
   */
  function getGameInfo(uint gameId) public view returns (
    string,
    string,
    string
  ) {
    return (
      games[gameId].teamA,
      games[gameId].teamB,
      games[gameId].description
    );
  }

  /**
   * @notice Returns all the info related to the bets
   * @dev Use other functions for more info
   * @param gameId The id of the corresponding game
   */
  function getGameAmounts(uint gameId) public view returns (
    uint,
    uint,
    uint,
    uint,
    uint
  ) {
    return (
      games[gameId].amountToTeamA,
      games[gameId].amountToDraw,
      games[gameId].amountToTeamB,
      games[gameId].bettorsCount,
      games[gameId].frozenTimestamp
    );
  }

  /**
   * @notice Returns the state of a specific game
   * @dev Use other functions for more info
   * @param gameId The id of the corresponding game
   */
  function getGameState(uint gameId) public view returns (GameStates) {
    return games[gameId].state;
  }

  /**
   * @notice Returns the result of a specific game
   * @dev Use other functions for more info
   * @param gameId The id of the corresponding game
   */
  function getGameResult(uint gameId) public view returns (GameResults) {
    return games[gameId].result;
  }

  /**
   * @notice Returns the total number of games
   */
  function getTotalGames() public view returns (uint) {
    return games.length;
  }

  /**
   * @dev Compare 2 strings and returns true if they are identical
   * This function even work if a string is in memory and the other in storage
   * @param a The first string
   * @param b The second string
   */
  function compareStrings(string a, string b) internal pure returns (bool) {
    return keccak256(abi.encodePacked(a)) == keccak256(abi.encodePacked(b));
  }

  /**
   * @dev Prevent to interact if the game is not open
   * @param gameId The id of a specific game
   */
  modifier whenGameIsOpen(uint gameId) {
    require(games[gameId].state == GameStates.Open);
    _;
  }

  /**
   * @dev Prevent to interact if the game is not frozen
   * @param gameId The id of a specific game
   */
  modifier whenGameIsFrozen(uint gameId) {
    require(games[gameId].state == GameStates.Frozen);
    _;
  }

  /**
   * @dev Prevent to interact if the game is not closed
   * @param gameId The id of a specific game
   */
  modifier whenGameIsClosed(uint gameId) {
    require(games[gameId].state == GameStates.Closed);
    _;
  }
}
