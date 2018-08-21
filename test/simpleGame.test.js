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
    });
  });

  /**
   * We start another new game
   */
  it('Should create anoter new game and verify info', () => {
    return Beths.deployed().then((instance) => {
      beths = instance;
      return beths.createNewGame('USA', 'Japan', 'World cup match: USA Vs Japan', 1529054843);
    })
    .then(() => beths.getGameInfo.call(1))
    .then((game) => {
      assert.equal(game[0], 'USA');
      assert.equal(game[1], 'Japan');
      assert.equal(game[2], 'World cup match: USA Vs Japan');
    });
  });

  /**
   * We place some bets and verify them
   */
  it('Should place some bets on the 1st game', () => {
    return Beths.deployed().then((instance) => {
      beths = instance;

      return beths.placeNewBet(0, 1, {
        from: accounts[1],
        value: web3.toWei('11', 'ether'),
      });
    })
    .then(() => {
      return beths.placeNewBet(0, 1, {
        from: accounts[2],
        value: web3.toWei('23', 'ether'),
      });
    })
    .then(() => {
      return beths.placeNewBet(0, 3, {
        from: accounts[3],
        value: web3.toWei('28', 'ether'),
      });
    })
    .then(() => {
      return beths.placeNewBet(0, 2, {
        from: accounts[4],
        value: web3.toWei('6', 'ether'),
      });
    })
    .then(() => beths.getGameAmounts.call(0))
    .then((gameAmounts) => {
      assert.equal(gameAmounts[0].toNumber(), web3.toWei('34', 'ether'));
      assert.equal(gameAmounts[1].toNumber(), web3.toWei('6', 'ether'));
      assert.equal(gameAmounts[2].toNumber(), web3.toWei('28', 'ether'));
      assert.equal(gameAmounts[3].toNumber(), 4);
      assert.equal(gameAmounts[4].toNumber(), 1529054843);
    });
  });

  /**
   * We place some bets and verify them
   */
  it('Should place some bets on the 2nd game', () => {
    return Beths.deployed().then((instance) => {
      beths = instance;

      return beths.placeNewBet(1, 1, {
        from: accounts[1],
        value: web3.toWei('6', 'ether'),
      });
    })
    .then(() => {
      return beths.placeNewBet(1, 1, {
        from: accounts[3],
        value: web3.toWei('8', 'ether'),
      });
    })
    .then(() => {
      return beths.placeNewBet(1, 1, {
        from: accounts[4],
        value: web3.toWei('14', 'ether'),
      });
    })
    .then(() => {
      return beths.placeNewBet(1, 3, {
        from: accounts[5],
        value: web3.toWei('18', 'ether'),
      });
    })
    .then(() => {
      return beths.placeNewBet(1, 3, {
        from: accounts[6],
        value: web3.toWei('6', 'ether'),
      });
    })
    .then(() => {
      return beths.placeNewBet(1, 2, {
        from: accounts[7],
        value: web3.toWei('5', 'ether'),
      });
    })
    .then(() => beths.getGameAmounts.call(1))
    .then((gameAmounts) => {
      assert.equal(gameAmounts[0].toNumber(), web3.toWei('28', 'ether'));
      assert.equal(gameAmounts[1].toNumber(), web3.toWei('5', 'ether'));
      assert.equal(gameAmounts[2].toNumber(), web3.toWei('24', 'ether'));
      assert.equal(gameAmounts[3].toNumber(), 6);
      assert.equal(gameAmounts[4].toNumber(), 1529054843);
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
      beths.closeGame(0, 1, {
        from: accounts[0],
      });

      return beths.getGameState.call(0);
    })
    .then((gameState) => {
      assert.equal(gameState.toNumber(), 2, 'Game 1 should be closed');

      return beths.getGameResult.call(0);
    })
    .then((gameResult) => {
      assert.equal(gameResult.toNumber(), 1, 'Game 1 result should be 1: team A');
    })
  });

  /**
   * Froze and close a game
   */
  it('Should froze the 2nd game and close it', () => {
    return Beths.deployed().then((instance) => {
      beths = instance;

      return beths.frozeGame(1, {
        from: accounts[0],
      });
    })
    .then(() => {
      beths.closeGame(1, 3, {
        from: accounts[0],
      });

      return beths.getGameState.call(1);
    })
    .then((gameState) => {
      assert.equal(gameState.toNumber(), 2, 'Game 2 should be closed');

      return beths.getGameResult.call(1);
    })
    .then((gameResult) => {
      assert.equal(gameResult.toNumber(), 3, 'Game 1 result should be 3: team B');
    });
  });

  /**
   * Get the bets from the 1st account
   */
  it('Should get the bets from the 1st account and withdraw the payout', () => {
    return Beths.deployed().then((instance) => {
      beths = instance;

      return beths.getBetsFromAddress.call(accounts[1]);
    })
    .then((bets) => {
      for (let i = 0; i < bets.length; i++) {
        beths.withdrawPayout(bets[i], {
          from: accounts[1],
        });
      }
    });
  });

  /**
   * Get the bets from the 2nd account
   */
  it('Should get the bets from the 2nd account and withdraw the payout', () => {
    return Beths.deployed().then((instance) => {
      beths = instance;

      return beths.getBetsFromAddress.call(accounts[2]);
    })
    .then((bets) => {
      for (let i = 0; i < bets.length; i++) {
        beths.withdrawPayout(bets[i], {
          from: accounts[2],
        });
      }
    });
  });

  /**
   * Get the bets from the 2nd account
   */
  it('Should get the bets from the 2nd account and withdraw the payout', () => {
    return Beths.deployed().then((instance) => {
      beths = instance;

      return beths.getBetsFromAddress.call(accounts[3]);
    })
    .then((bets) => {
      for (let i = 0; i < bets.length; i++) {
        beths.withdrawPayout(bets[i], {
          from: accounts[3],
        });
      }
    });
  });

  /**
   * Get the bets from the 2nd account
   */
  it('Should get the bets from the 2nd account and withdraw the payout', () => {
    return Beths.deployed().then((instance) => {
      beths = instance;

      return beths.getBetsFromAddress.call(accounts[4]);
    })
    .then((bets) => {
      for (let i = 0; i < bets.length; i++) {
        beths.withdrawPayout(bets[i], {
          from: accounts[4],
        });
      }
    });
  });

  /**
   * Get the bets from the 2nd account
   */
  it('Should get the bets from the 2nd account and withdraw the payout', () => {
    return Beths.deployed().then((instance) => {
      beths = instance;

      return beths.getBetsFromAddress.call(accounts[5]);
    })
    .then((bets) => {
      for (let i = 0; i < bets.length; i++) {
        beths.withdrawPayout(bets[i], {
          from: accounts[5],
        });
      }
    });
  });

  /**
   * Get the bets from the 2nd account
   */
  it('Should get the bets from the 2nd account and withdraw the payout', () => {
    return Beths.deployed().then((instance) => {
      beths = instance;

      return beths.getBetsFromAddress.call(accounts[6]);
    })
    .then((bets) => {
      for (let i = 0; i < bets.length; i++) {
        beths.withdrawPayout(bets[i], {
          from: accounts[6],
        });
      }
    });
  });

  /**
   * Get the bets from the 2nd account
   */
  it('Should get the bets from the 2nd account and withdraw the payout', () => {
    return Beths.deployed().then((instance) => {
      beths = instance;

      return beths.getBetsFromAddress.call(accounts[7]);
    })
    .then((bets) => {
      for (let i = 0; i < bets.length; i++) {
        beths.withdrawPayout(bets[i], {
          from: accounts[7],
        });
      }
    });
  });
});
