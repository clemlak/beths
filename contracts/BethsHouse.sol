pragma solidity 0.4.24;

import "openzeppelin-solidity/contracts/ownership/Ownable.sol";


/**
 * @title Beths base contract
 * @author clemlak (https://www.beths.co)
 * @notice Place bets using Ether, based on the "pari mutuel" principle
 * Only the owner of the contract can create bets, he can also take a cut on every payouts
 * @dev This is the base contract for our dapp, we manage here all the things related to the "house"
 */
contract BethsHouse is Ownable {
  /**
   * @notice Emitted when the house cut percentage is changed
   * @param newHouseCutPercentage The new percentage
   */
  event HouseCutPercentageChanged(uint newHouseCutPercentage);

  /**
   * @notice The percentage taken by the house on every game
   * @dev Can be changed later with the changeHouseCutPercentage() function
   */
  uint public houseCutPercentage = 10;

  /**
   * @notice Changes the house cut percentage
   * @dev To prevent abuses, the new percentage is checked
   * @param newHouseCutPercentage The new house cut percentage
   */
  function changeHouseCutPercentage(uint newHouseCutPercentage) external onlyOwner {
    // This prevents us from being too greedy ;)
    if (newHouseCutPercentage >= 0 && newHouseCutPercentage < 20) {
      houseCutPercentage = newHouseCutPercentage;
      emit HouseCutPercentageChanged(newHouseCutPercentage);
    }
  }
}
