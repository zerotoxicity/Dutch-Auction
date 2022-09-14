pragma solidity 0.8.16;

import "@openzeppelin/contracts/interfaces/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract Auction is Ownable {
    enum AuctionState {
        OPEN,
        CLOSED
    }

    ///Address of Ketchup Token
    address private _ketchupToken;
    mapping(address => uint256) private _bidAmount;
    AuctionState private _currentState;

    constructor(address ketchupToken) {
        _ketchupToken = ketchupToken;
    }

    function buyIn() external payable {}

    function withdraw() external {}
}
