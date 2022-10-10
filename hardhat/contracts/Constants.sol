pragma solidity 0.8.16;

enum AuctionState {
    ONGOING,
    CLOSED,
    CLOSING
}

//Starting price: 1 ETH/KCH
uint256 constant STARTING_PRICE = 1e18;
uint256 constant MULTIPLIER = 1e12;
uint256 constant RESERVED_PRICE = STARTING_PRICE - (20 * 60 * MULTIPLIER);
uint256 constant AUCTION_SUPPLY = 1e20;
