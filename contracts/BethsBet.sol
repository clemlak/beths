pragma solidity 0.4.24;

import "./BethsGame.sol";


/**
 * @title We manage all the things related to our bets here
 * @author Clemlak (https://www.beths.co)
 */
contract BethsBet is BethsGame {
  /**
   * @notice Emitted when a new bet is placed
   * @param gameId The name of the corresponding game
   * @param result The result expected by the bettor (see: enum GameResults)
   * @param amount How much the bettor placed
   */
  event NewBetPlaced(uint gameId, GameResults result, uint amount);

  /**
   * @notice The minimum amount needed to place bet (in Wei)
   * @dev Can be changed later by the changeMinimumBetAmount() function
   */
  uint public minimumBetAmount = 1000000000;

  /**
   * @notice This struct defines what a bet is
   */
  struct Bet {
    uint gameId;
    GameResults result;
    uint amount;
    bool isPayoutWithdrawn;
  }

  /**
   * @notice We store all our bets in an array
   */
  Bet[] public bets;

  /**
   * @notice This links bets with bettors
   */
  mapping (uint => address) public betToAddress;

  /**
   * @notice This links the bettor to their bets
   */
  mapping (address => uint[]) public addressToBets;

  /**
   * @notice Changes the minimum amount needed to place a bet
   * @dev The amount is in Wei and must be greater than 0 (can only be changed by the owner)
   * @param newMinimumBetAmount The new amount
   */
  function changeMinimumBetAmount(uint newMinimumBetAmount) external onlyOwner {
    if (newMinimumBetAmount > 0) {
      minimumBetAmount = newMinimumBetAmount;
    }
  }

  /**
   * @notice Place a new bet
   * @dev This function is payable and we'll use the amount we receive as the bet amount
   * Bets can only be placed while the game is open
   * @param gameId The id of the corresponding game
   * @param result The result expected by the bettor (see enum GameResults)
   */
  function placeNewBet(uint gameId, GameResults result) public whenGameIsOpen(gameId) payable {
    // We check if the bet amount is greater or equal to our minimum
    if (msg.value >= minimumBetAmount) {
      // We push our bet in our main array
      uint betId = bets.push(Bet(gameId, result, msg.value, false)) - 1;

      // We link the bet with the bettor
      betToAddress[betId] = msg.sender;

      // We link the address with their bets
      addressToBets[msg.sender].push(betId);

      // Then we update our game
      games[gameId].bettorsCount = games[gameId].bettorsCount.add(1);

      // And we update the amount bet on the expected result
      if (result == GameResults.TeamA) {
        games[gameId].amountToTeamA = games[gameId].amountToTeamA.add(msg.value);
      } else if (result == GameResults.Draw) {
        games[gameId].amountToDraw = games[gameId].amountToDraw.add(msg.value);
      } else if (result == GameResults.TeamB) {
        games[gameId].amountToTeamB = games[gameId].amountToTeamB.add(msg.value);
      }

      // And finally we emit the corresponding event
      emit NewBetPlaced(gameId, result, msg.value);
    }
  }

  /**
   * @notice Returns an array containing the ids of the bets placed by a specific address
   * @dev This function is meant to be used with the getBetInfo() function
   * @param bettorAddress The address of the bettor
   */
  function getBetsFromAddress(address bettorAddress) public view returns (uint[]) {
    return addressToBets[bettorAddress];
  }

  /**
   * @notice Returns the info of a specific bet
   * @dev This function is meant to be used with the getBetsFromAddress() function
   * @param betId The id of the specific bet
   */
  function getBetInfo(uint betId) public view returns (uint, GameResults, uint, bool) {
    return (bets[betId].gameId, bets[betId].result, bets[betId].amount, bets[betId].isPayoutWithdrawn);
  }
}
