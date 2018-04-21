pragma solidity ^0.4.18;

contract Wrestling {
  address public playerA;
  address public playerB;

  bool public playerAPlayed;
  bool public playerBPlayed;

  uint private playerADeposit;
  uint private playerBDeposit;

  bool public gameOver;
  address public theWinner;
  uint public prize;


  event WrestlingStartsEvent(address playerA, address playerB);
  event EndOfRoundEvent(uint playerADeposit, uint playerBDeposit);
  event WrestlingEndsEvent(address winner, uint prize);

  constructor() public {
    playerA = msg.sender;
  }

  function registerAnOpponent() public {
    require(playerB == address(0));
    playerB = msg.sender;
    emit WrestlingStartsEvent(playerA, playerB);
  }

  function wrestle() public payable {
    require(!gameOver && (msg.sender == playerA || msg.sender == playerB));

    if (msg.sender == playerA) {
      require(!playerAPlayed);
      playerAPlayed = true;
      playerADeposit = playerADeposit + msg.value;
    } else {
      require(!playerBPlayed);
      playerBPlayed = true;
      playerBDeposit = playerBDeposit + msg.value;
    }

    if (playerAPlayed && playerBPlayed) {
      if (playerADeposit > 2 * playerBDeposit) {
        endGame(playerA);
      } else if (playerBDeposit > 2 * playerADeposit) {
        endGame(playerB);
      } else {
        endRound();
      }
    }
  }

  function endGame(address winner) internal {
    gameOver = true;
    theWinner = winner;
    prize = playerADeposit + playerBDeposit;
    emit WrestlingEndsEvent(winner, prize);
  }

  function endRound() internal {
    playerAPlayed = false;
    playerBPlayed = false;
    emit EndOfRoundEvent(playerADeposit, playerBDeposit);
  }

  function withDraw() public {
    require(gameOver && msg.sender == theWinner);
    uint amount = prize;
    prize = 0;
    msg.sender.transfer(amount);
  }

}
