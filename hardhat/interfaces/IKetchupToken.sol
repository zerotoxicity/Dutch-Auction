pragma solidity 0.8.16;

interface IKetchupToken {
    function fundAuction() external;

    function burnRemainingToken(uint256 amount) external;
}
