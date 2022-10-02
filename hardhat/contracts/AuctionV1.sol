pragma solidity 0.8.16;

import "./EnumDeclaration.sol";
import "./libraries/IterableMapping.sol";
import "../interfaces/IKetchupToken.sol";
import "../interfaces/IERC20.sol";
import "../interfaces/IAuctionV1.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";

///FORMATTED USING SOLIDITY STYLE GUIDE

/**
 * @title Auction contract V1
 * @author Team Ketchup
 */
contract AuctionV1 is
    Initializable,
    UUPSUpgradeable,
    OwnableUpgradeable,
    IAuctionV1
{
    using IterableMapping for IterableMapping.Map;

    //Starting price: 1 ETH/KCH
    uint256 constant STARTING_PRICE = 1e18;
    uint256 constant MULTIPLIER = 1e12;
    uint256 constant RESERVED_PRICE = STARTING_PRICE - (20 * 60 * MULTIPLIER);
    uint256 constant AUCTION_SUPPLY = 1e20;

    ///Auction-related variables
    AuctionState private _currentAuctionState;
    uint256 private _endPrice;
    uint256 private _auctionStartTime;

    ///Bidding-related variables
    uint256 private _totalBidAmount;
    uint256 private _refundAmount;
    mapping(address => uint256) private _refunds;
    IterableMapping.Map bidders;

    ///Address of Ketchup Token
    address private _ketchupToken;

    /**
     * CCheck if the auction is still ongoing.
     */
    modifier auctionOngoing() {
        require(
            (_currentAuctionState == AuctionState.ONGOING),
            "Auction is closed."
        );
        _;
    }

    receive() external payable {}

    /**
     * @dev Upgradeable contract constructor
     */
    function initialize(address ketchupToken) public initializer {
        __UUPSUpgradeable_init();
        __Ownable_init();
        _ketchupToken = ketchupToken;
        _currentAuctionState = AuctionState.CLOSED;
    }

    ///@inheritdoc IAuctionV1
    function startAuction() public onlyOwner {
        require(
            _currentAuctionState == AuctionState.CLOSED,
            "Auction is ongoing."
        );
        IKetchupToken(_ketchupToken).fundAuction();
        _auctionStartTime = block.timestamp;
        _currentAuctionState = AuctionState.ONGOING;
        _totalBidAmount = 0;
        _refundAmount = 0;
        delete bidders.keys;
    }

    ///@inheritdoc IAuctionV1
    function checkIfAuctionShouldEnd() public auctionOngoing returns (bool) {
        if (
            (getSupplyReserved() >= AUCTION_SUPPLY) ||
            (block.timestamp >= _auctionStartTime + 20 minutes)
        ) {
            _endAuction();
            emit ShouldAuctionEnd(true);
            return true;
        }

        emit ShouldAuctionEnd(false);
        return false;
    }

    ///@inheritdoc IAuctionV1
    function getAuctionState() external view returns (uint8) {
        return uint8(_currentAuctionState);
    }

    ///@inheritdoc IAuctionV1
    function getSupplyReserved() public view returns (uint256) {
        if (_totalBidAmount == 0) return 0;

        return ((_totalBidAmount * 1e18) / getTokenPrice());
    }

    ///@inheritdoc IAuctionV1
    function getTokenPrice() public view returns (uint256) {
        if (_currentAuctionState == AuctionState.CLOSED) {
            return _endPrice;
        }
        return (STARTING_PRICE -
            ((block.timestamp - _auctionStartTime) * MULTIPLIER));
    }

    function _authorizeUpgrade(address) internal override onlyOwner {}

    ///@inheritdoc IAuctionV1
    function insertBid() external payable auctionOngoing {
        bool ended = checkIfAuctionShouldEnd();
        if (ended) _refunds[msg.sender] = msg.value;
        else {
            bidders.set(msg.sender, msg.value);
            _totalBidAmount += msg.value;
            if (getSupplyReserved() >= AUCTION_SUPPLY) {
                _endAuction();
            }
        }
    }

    ///@inheritdoc IAuctionV1
    function withdraw() external {
        require(
            _currentAuctionState == AuctionState.CLOSED,
            "Auction is not closed"
        );
        require(
            ((bidders.get(msg.sender) > 0)) || (_refunds[msg.sender] > 0),
            "Did not bid/Withdrawn"
        );
        uint256 ethBidded = bidders.get(msg.sender);
        bidders.remove(msg.sender);
        uint256 refundValue = _refunds[msg.sender];
        _refunds[msg.sender] = 0;
        _refundAmount = 0;
        uint256 numOfKetchup = (ethBidded * 1e18) / getTokenPrice();
        IERC20(_ketchupToken).transfer(msg.sender, numOfKetchup);
        (bool sent, ) = msg.sender.call{value: refundValue}("");
        require(sent, "Failed to withdraw");
        emit Receiving(refundValue);
    }

    ///@inheritdoc IAuctionV1
    function withdrawAll() external onlyOwner {
        require(
            _currentAuctionState == AuctionState.CLOSED,
            "Auction is ongoing"
        );
        uint256 balance = address(this).balance - _refundAmount;
        (bool sent, ) = owner().call{value: balance}("");
        require(sent, "Failed to withdraw");
    }

    ///@inheritdoc IAuctionV1
    function getAuctionStartTime() external view returns (uint256) {
        return _auctionStartTime;
    }

    ///@inheritdoc IAuctionV1
    function getTotalBidAmount() external view returns (uint256) {
        return _totalBidAmount;
    }

    ///@inheritdoc IAuctionV1
    function getUserBidAmount(address account) external view returns (uint256) {
        return bidders.get(account);
    }

    /**
     * End auction
     */
    function _endAuction() private {
        _currentAuctionState = AuctionState.CLOSING;
        _endPrice = getSupplyReserved() >= AUCTION_SUPPLY
            ? getTokenPrice()
            : RESERVED_PRICE;

        _currentAuctionState = AuctionState.CLOSED;
        if (getSupplyReserved() > AUCTION_SUPPLY) {
            _refundLastBidder();
        } else {
            uint256 leftover = AUCTION_SUPPLY - getSupplyReserved();
            if (leftover > 0)
                IKetchupToken(_ketchupToken).burnRemainingToken(leftover);
        }
    }

    /**
     * Refund excess ETH to the last bidder
     */
    function _refundLastBidder() private {
        uint256 tokensExceeded = getSupplyReserved() - AUCTION_SUPPLY;
        address lastBidder = bidders.getKeyAtIndex(bidders.size() - 1);
        uint256 excessValue = (tokensExceeded * getTokenPrice());
        bidders.values[lastBidder] =
            (bidders.values[lastBidder] * 1e18 - excessValue) /
            1e18;
        uint256 refundVal = excessValue / 1e18;
        _refunds[lastBidder] += refundVal;
        _refundAmount += refundVal;
    }
}
