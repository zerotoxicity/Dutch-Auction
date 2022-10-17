pragma solidity 0.8.16;

interface IAuctionV1 {
    /**
     * Emitted after users check if the auction should end
     * @param value True/false value of if auction should end
     */
    event ShouldAuctionEnd(bool value);

    /**
     * Emitted when msg.sender is to refunded ETH
     * @param amount The amount received by msg.sender
     */
    event Receiving(uint256 amount);

    // ===== Read methods ====

    /**
     * Returns current supply reserved by bidders
     */
    function getSupplyReserved() external view returns (uint256);

    /**
     * Returns selected auction's KCH token price in wei
     * @param auctionNo The number of the auction that the caller wish to view to view
     */
    function getTokenPrice(uint256 auctionNo) external view returns (uint256);

    /**
     * Return total ETH bidded in selected auction
     * @param auctionNo The number of the auction that the caller wish to view to view
     */
    function getTotalBiddedAmount(uint256 auctionNo)
        external
        view
        returns (uint256);

    /**
     * Returns current auction number.
     * Auctions starts from 0
     */
    function getAuctionNo() external view returns (uint256);

    /**
     * Returns auction's start time
     */
    function getAuctionStartTime() external view returns (uint256);

    /**
     * Returns auction's supply
     */
    function getAuctionSupply() external view returns (uint256);

    /**
     * Returns auction current state
     * 0 - ONGOING
     * 1 - CLOSED
     * 2 - CLOSING
     */
    function getAuctionState() external view returns (uint8);

    /**
     * Returns a user's bidded amount (excluding refunded amount) in the selected auction.
     * @param auctionNo The number of the auction that the caller wish to view to view
     */
    function getUserBidAmount(address account, uint256 auctionNo)
        external
        view
        returns (uint256);

    // ===== Write methods =====

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
     * Caller sends ETH to bid for KCH token
     */
    function insertBid() external payable;

    /**
     * Caller withdraws KCH tokens and refunds if entitled
     */
    function withdraw() external;
}
