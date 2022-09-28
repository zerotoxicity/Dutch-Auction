pragma solidity 0.8.16;

interface IKetchupToken {
    function burnRemainingToken(uint256 amount) external;

    function decimals() external;
}
