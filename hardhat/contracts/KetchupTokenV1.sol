pragma solidity 0.8.16;

import "./interfaces/IKetchupToken.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC20/ERC20Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";

/**
 * @title Ketchup Token contract V1
 * @author Team Ketchup
 */
contract KetchupTokenV1 is
    IKetchupToken,
    Initializable,
    UUPSUpgradeable,
    ERC20Upgradeable,
    OwnableUpgradeable
{
    receive() external payable {}

    function initialize(string memory name, string memory symbol)
        public
        initializer
    {
        __ERC20_init(name, symbol);
        __Ownable_init();
        __UUPSUpgradeable_init();
    }

    function _authorizeUpgrade(address) internal override onlyOwner {}

    ///@inheritdoc IKetchupToken
    function fundAuction() external onlyOwner {
        require(totalSupply() < 1e21, "Max supply exceeded");
        _mint(owner(), 1e20);
    }

    ///@inheritdoc IKetchupToken
    function burnRemainingToken(uint256 amount) external onlyOwner {
        _burn(owner(), amount);
    }

    ///@inheritdoc IKetchupToken
    function getAvgTokenPrice() external view returns (uint256) {
        if (address(this).balance == 0) return 0;
        return (address(this).balance * 1e18) / totalSupply();
    }
}
