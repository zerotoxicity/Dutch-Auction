pragma solidity 0.8.16;

interface IKetchupToken {
    // ===== Read methods ====

    /**
     * Returns the average price of KCH in wei
     */
    function getAvgTokenPrice() external view returns (uint256);

    // ===== Write methods ====

    /**
     * Fund auction (Owner of Ketchup Token contract) with fixed amount of Ketchup Tokens.
     */
    function fundAuction() external;

    /**
     * Burn unsold token
     * @param amount number of token not sold
     */
    function burnRemainingToken(uint256 amount) external;
}
