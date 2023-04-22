pragma solidity ^0.8.0;

contract Lottery {
    address payable[] public players;
    uint public numPlayers;
    uint public constant maxPlayers = 11;
    uint public constant ticketPrice = 0.09 ether;
    address public winner;
    bool public ended;

    function enter() public payable {
        require(!ended, "Lottery is already over.");
        require(msg.value == ticketPrice, "You need to send 0.09 ETH to enter the lottery.");
        players.push(payable(msg.sender));
        numPlayers++;
        if (numPlayers == maxPlayers) {
            endLottery();
        }
    }

    function endLottery() private {
        uint seed = uint(keccak256(abi.encode(block.timestamp, block.difficulty, players)));
        uint index = seed % maxPlayers;
        winner = players[index];
        ended = true;
        uint prize = address(this).balance;
        payable(winner).transfer(prize);
    }
}
