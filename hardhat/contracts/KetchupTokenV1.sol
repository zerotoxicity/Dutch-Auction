pragma solidity 0.8.16;

import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC20/ERC20Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";

/**
 * @title Ketchup Token contract V1
 * @author Team Ketchup
 */
contract KetchupTokenV1 is
    Initializable,
    UUPSUpgradeable,
    ERC20Upgradeable,
    OwnableUpgradeable
{
    function initialize(string memory name, string memory symbol)
        public
        initializer
    {
        __ERC20_init(name, symbol);
        __Ownable_init();
        __UUPSUpgradeable_init();
    }

    function _authorizeUpgrade(address) internal override onlyOwner {}

    function fundAuction() external onlyOwner {
        _mint(owner(), 1e20);
    }

    /**
     * Burn unsold token
     * @param amount number of token not sold
     */
    function burnRemainingToken(uint256 amount) external onlyOwner {
        _burn(owner(), amount);
    }
}
