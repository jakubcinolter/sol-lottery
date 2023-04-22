pragma solidity ^0.8.0;

contract Lottery {
    address payable[] public players;
    uint public numPlayers;
    uint public constant minPlayers = 5;
    uint public constant maxPlayers = 20;
    uint public constant ticketPrice = 0.1 ether;
    uint public constant timeLimit = 24 hours;
    address public winner;
    address public topReferrer;
    bool public ended;
    bool public referralEnded;
    mapping(address => uint) public referrals;

    function enter() public payable {
        require(!ended, "Lottery is already over.");
        require(msg.value == ticketPrice, "You need to send 0.1 ETH to enter the lottery.");
        players.push(payable(msg.sender));
        numPlayers++;
        if (numPlayers == maxPlayers) {
            endLottery();
        }
    }

    function endLottery() private {
        require(!ended, "Lottery is already over.");
        require(now >= (timeLimit + block.timestamp), "Time limit has not yet expired.");
        uint seed = uint(keccak256(abi.encode(block.timestamp, block.difficulty, players)));
        uint index = seed % numPlayers;
        winner = players[index];
        ended = true;
        uint prize = address(this).balance / 2;
        payable(winner).transfer(prize);
        selectTopReferrer();
    }

    function selectTopReferrer() private {
        require(ended, "Lottery is not over yet.");
        uint maxReferrals = 0;
        for (uint i = 0; i < numPlayers; i++) {
            address player = players[i];
            if (referrals[player] > maxReferrals) {
                topReferrer = player;
                maxReferrals = referrals[player];
            }
        }
        referralEnded = true;
        uint prize = address(this).balance;
        payable(topReferrer).transfer(prize);
    }

    function refer(address _referral) public {
        require(!ended, "Lottery is already over.");
        require(referrals[msg.sender] == 0, "You can only refer one player.");
        require(_referral != msg.sender, "You cannot refer yourself.");
        require(numPlayers < maxPlayers, "Lottery is full.");
        referrals[_referral]++;
        enter();
    }

    function getReferrals(address player) public view returns (uint) {
        return referrals[player];
    }
}
