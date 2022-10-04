pragma solidity 0.8.16;

import "./EnumDeclaration.sol";
import "./libraries/IterableMapping.sol";
import "../interfaces/IKetchupToken.sol";
import "../interfaces/IERC20.sol";
import "../interfaces/IAuctionV1.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";

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
    uint256 private _auctionNo;
    mapping(uint256 => uint256) private _endPrice;
    mapping(uint256 => uint256) private _auctionStartTime;

    ///Bidding-related variables
    uint256 private _refundAmount;
    mapping(uint256 => uint256) private _totalBidAmount;
    mapping(address => uint256) private _refunds;
    mapping(uint256 => IterableMapping.Map) bidders;

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
        _auctionStartTime[_auctionNo] = block.timestamp;
        _currentAuctionState = AuctionState.ONGOING;
    }

    ///@inheritdoc IAuctionV1
    function checkIfAuctionShouldEnd() public auctionOngoing returns (bool) {
        if (
            (getSupplyReserved() >= AUCTION_SUPPLY) ||
            (block.timestamp >= _auctionStartTime[_auctionNo] + 20 minutes)
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
        uint256 totalBiddedAmount = getTotalBiddedAmount(_auctionNo);
        if (totalBiddedAmount == 0) return 0;

        return ((totalBiddedAmount * 1e18) / getTokenPrice());
    }

    ///@inheritdoc IAuctionV1
    function getTokenPrice() public view returns (uint256) {
        return _getTokenPrice(_auctionNo);
    }

    ///@inheritdoc IAuctionV1
    function getTokenPrice(uint256 auctionNo) public view returns (uint256) {
        return _getTokenPrice(auctionNo);
    }

    ///@inheritdoc IAuctionV1
    function getTotalBiddedAmount(uint256 auctionNo)
        public
        view
        returns (uint256)
    {
        return _totalBidAmount[auctionNo];
    }

    function _authorizeUpgrade(address) internal override onlyOwner {}

    ///@inheritdoc IAuctionV1
    function insertBid() external payable auctionOngoing {
        bool ended = checkIfAuctionShouldEnd();
        if (ended) _refunds[msg.sender] = msg.value;
        else {
            bidders[_auctionNo].set(msg.sender, msg.value);
            _totalBidAmount[_auctionNo] += msg.value;
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

        uint256 ethBidded;
        for (uint256 i = 0; i < _auctionNo; i++) {
            ethBidded += bidders[i].get(msg.sender);
        }
        require(
            ((ethBidded > 0)) || (_refunds[msg.sender] > 0),
            "Did not bid/Withdrawn"
        );
        uint256 refundValue = _refunds[msg.sender];
        _refunds[msg.sender] = 0;
        _refundAmount -= refundValue;
        uint256 numOfKetchup;
        for (uint256 i = 0; i < _auctionNo; i++) {
            numOfKetchup +=
                (bidders[i].get(msg.sender) * 1e18) /
                getTokenPrice(i);
            bidders[i].remove(msg.sender);
        }
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
    function getAuctionNo() external view returns (uint256) {
        return _auctionNo;
    }

    ///@inheritdoc IAuctionV1
    function getAuctionStartTime() external view returns (uint256) {
        return _auctionStartTime[_auctionNo];
    }

    ///@inheritdoc IAuctionV1
    function getUserBidAmount(address account) external view returns (uint256) {
        return bidders[_auctionNo].get(account);
    }

    /**
     * End auction
     */
    function _endAuction() private {
        _currentAuctionState = AuctionState.CLOSING;
        _endPrice[_auctionNo] = getSupplyReserved() >= AUCTION_SUPPLY
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
        _auctionNo++;
    }

    /**
     * Refund excess ETH to the last bidder
     */
    function _refundLastBidder() private {
        uint256 tokensExceeded = getSupplyReserved() - AUCTION_SUPPLY;
        address lastBidder = bidders[_auctionNo].getKeyAtIndex(
            bidders[_auctionNo].size() - 1
        );
        uint256 excessValue = (tokensExceeded * getTokenPrice());
        bidders[_auctionNo].values[lastBidder] =
            (bidders[_auctionNo].values[lastBidder] * 1e18 - excessValue) /
            1e18;
        uint256 refundVal = excessValue / 1e18;
        _refunds[lastBidder] += refundVal;
        _refundAmount += refundVal;
    }

    /**
     * @dev See getTokenPrice(uint256 auctionNo)
     */
    function _getTokenPrice(uint256 value) private view returns (uint256) {
        if (_currentAuctionState == AuctionState.CLOSED) {
            return _endPrice[value];
        }
        return (STARTING_PRICE -
            ((block.timestamp - _auctionStartTime[value]) * MULTIPLIER));
    }
}
