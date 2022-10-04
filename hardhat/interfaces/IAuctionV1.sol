pragma solidity 0.8.16;

interface IAuctionV1 {
    /**
     * Emitted after users check if the auction should end
     * @param value True/false value of if auction should end
     */
    event ShouldAuctionEnd(bool value);

    /**
     * Emitted when msg.sender is to receive ETH
     * @param amount The amount received by msg.sender
     */
    event Receiving(uint256 amount);

    /**
     * Returns current auction number
     */
    function getAuctionNo() external view returns (uint256);

    /**
     * Returns auction's start time
     */
    function getAuctionStartTime() external view returns (uint256);

    /**
     * Returns auction current state
     * 0 - ONGOING
     * 1 - CLOSED
     * 2 - CLOSING
     */
    function getAuctionState() external view returns (uint8);

    /**
     * Returns current supply reserved by bidders
     */
    function getSupplyReserved() external view returns (uint256);

    /**
     * Returns current KCH token price
     */
    function getTokenPrice() external view returns (uint256);

    /**
     * Returns selected auction's KCH token price
     * @param auctionNo The number of the auction caller wish to view
     */
    function getTokenPrice(uint256 auctionNo) external view returns (uint256);

    /**
     * Return total ETH bidded in selected auction
     * @param auctionNo The number of the auction caller wish to view
     */
    function getTotalBiddedAmount(uint256 auctionNo)
        external
        view
        returns (uint256);

    /**
     * Returns a user's bidded amount in current auction
     */
    function getUserBidAmount(address account) external view returns (uint256);

    /**
     * Caller sends ETH to bid for KCH token
     */
    function insertBid() external payable;

    /**
     * Owner of auction contract starts the auction
     */
    function startAuction() external;

    /**
     * Check if the auction should end.
     * Caller will end the auction, if end conditions have been fulfiled.
     * @return bool Boolean value of if auction should end
     */
    function checkIfAuctionShouldEnd() external returns (bool);

    /**
     * Caller withdraws KCH tokens and refunds if entitled
     */
    function withdraw() external;

    /**
     * Owner of the auction contract withdraw all ETH that is in the contract
     */
    function withdrawAll() external;
}
