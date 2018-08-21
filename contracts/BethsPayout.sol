pragma solidity 0.4.24;

import "./BethsBet.sol";


/**
 * @title This contract handles all the functions related to the payouts
 * @author Clemlak (https://www.beths.co)
 * @dev This contract is still in progress
 */
contract BethsPayout is BethsBet {
  /**
   * @notice We use this function to withdraw the house cut from a game
   * @dev Can only be called externally by the owner when a game is closed
   * @param gameId The id of a specific game
   */
  function withdrawHouseCutFromGame(uint gameId) external onlyOwner whenGameIsClosed(gameId) {
    // We check if we haven't already withdrawn the cut
    if (!games[gameId].isHouseCutWithdrawn) {
      games[gameId].isHouseCutWithdrawn = true;
      uint houseCutAmount = calculateHouseCutAmount(gameId);
      owner.transfer(houseCutAmount);
    }
  }

  /**
   * @notice This function is called by a bettor to withdraw his payout
   * @dev This function can only be called externally
   * @param betId The id of a specific bet
   */
  function withdrawPayoutFromBet(uint betId) external whenGameIsClosed(bets[betId].gameId) {
    // We check if the bettor has won
    require(games[bets[betId].gameId].result == bets[betId].result);

    // If he won, but we want to be sure that he didn't already withdraw his payout
    if (!bets[betId].isPayoutWithdrawn) {
      // Everything seems okay, so now we give the bettor his payout
      uint payout = calculatePotentialPayout(betId);

      // We prevent the bettor to withdraw his payout more than once
      bets[betId].isPayoutWithdrawn = true;

      address bettorAddress = betToAddress[betId];

      // We send the payout
      bettorAddress.transfer(payout);
    }
  }

  /**
   * @notice Returns the "raw" pool amount (including the amount of the house cut)
   * @dev Can be called at any state of a game
   * @param gameId The id of a specific game
   */
  function calculateRawPoolAmount(uint gameId) internal view returns (uint) {
    return games[gameId].amountToDraw.add(games[gameId].amountToTeamA.add(games[gameId].amountToTeamB));
  }

  /**
   * @notice Returns the amount the house will take
   * @dev Can be called at any state of a game
   * @param gameId The id of a specific game
   */
  function calculateHouseCutAmount(uint gameId) internal view returns (uint) {
    uint rawPoolAmount = calculateRawPoolAmount(gameId);
    return houseCutPercentage.mul(rawPoolAmount.div(100));
  }

  /**
   * @notice Returns the total of the pool (minus the house part)
   * @dev This value will be used to calculate the bettors' payouts
   * @param gameId the id of a specific game
   */
  function calculatePoolAmount(uint gameId) internal view returns (uint) {
    uint rawPoolAmount = calculateRawPoolAmount(gameId);
    uint houseCutAmount = calculateHouseCutAmount(gameId);

    return rawPoolAmount.sub(houseCutAmount);
  }

  /**
   * @notice Returns the potential payout from a bet
   * @dev Warning! This function DOES NOT check if the game is open/frozen/closed or if the bettor has won
   * @param betId The id of a specific bet
   */
  function calculatePotentialPayout(uint betId) internal view returns (uint) {
    uint betAmount = bets[betId].amount;

    uint poolAmount = calculatePoolAmount(bets[betId].gameId);

    uint temp = betAmount.mul(poolAmount);

    uint betAmountToWinningTeam = 0;

    if (games[bets[betId].gameId].result == GameResults.TeamA) {
      betAmountToWinningTeam = games[bets[betId].gameId].amountToTeamA;
    } else if (games[bets[betId].gameId].result == GameResults.TeamB) {
      betAmountToWinningTeam = games[bets[betId].gameId].amountToTeamB;
    } else if (games[bets[betId].gameId].result == GameResults.Draw) {
      betAmountToWinningTeam = games[bets[betId].gameId].amountToDraw;
    }

    return temp.div(betAmountToWinningTeam);
  }
}
