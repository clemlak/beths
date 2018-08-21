const Beths = artifacts.require('BethsPayout');

contract('BethsPayout', (accounts) => {
  let beths;

  /**
   * We start a new game
   */
  it('Should create a new game and verify info', () => {
    return Beths.deployed().then((instance) => {
      beths = instance;
      return beths.createNewGame('France', 'Spain', 'World cup match: France Vs Spain', 1529054843);
    })
    .then(() => beths.getGameInfo.call(0))
    .then((game) => {
      assert.equal(game[0], 'France');
      assert.equal(game[1], 'Spain');
      assert.equal(game[2], 'World cup match: France Vs Spain');
      assert.equal(game[3].toNumber(), 0);
      assert.equal(game[4], 1529054843);
    });
  });

  /**
   * Froze and close a game
   */
  it('Should froze the 1st game and close it', () => {
    return Beths.deployed().then((instance) => {
      beths = instance;

      return beths.frozeGame(0, {
        from: accounts[0],
      });
    })
    .then(() => {
      beths.closeGame(0, 0, {
        from: accounts[0],
      });

      return beths.getGameState.call(0);
    })
    .then((gameState) => {
      assert.equal(gameState.toNumber(), 2, 'Game 1 should be closed');

      return beths.getGameResult.call(0);
    })
    .then((gameResult) => {
      assert.equal(gameResult.toNumber(), 0, 'Game 1 should be closed');
    })
  });
});
