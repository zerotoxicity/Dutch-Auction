pragma solidity 0.8.16;

import "./Constants.sol";
import "./libraries/IterableMapping.sol";
import "./interfaces/IKetchupToken.sol";
import "./interfaces/IERC20.sol";
import "./interfaces/IAuctionV1.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/security/ReentrancyGuardUpgradeable.sol";

import "hardhat/console.sol";

/**
 * @title Auction contract V1
 * @author Team Ketchup
 */
contract AuctionV1 is
    IAuctionV1,
    Initializable,
    UUPSUpgradeable,
    OwnableUpgradeable,
    ReentrancyGuardUpgradeable
{
    using IterableMapping for IterableMapping.Map;

    ///Auction-related variables
    AuctionState private _currentAuctionState;
    uint256 private _auctionNo; //Auction starts from 0
    mapping(uint256 => uint256) private _endPrice;
    mapping(uint256 => uint256) private _auctionStartTime;
    mapping(uint256 => uint256) private _auctionEndTime;

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
        __ReentrancyGuard_init();
        _ketchupToken = ketchupToken;
        _currentAuctionState = AuctionState.CLOSED;
    }

    ///@inheritdoc IAuctionV1
    function getAuctionSupply() external pure returns (uint256) {
        return AUCTION_SUPPLY;
    }

    ///@inheritdoc IAuctionV1
    function viewAuctionDuration() public pure returns (uint) {
        return AUCTION_DURATION;
    }

    ///@inheritdoc IAuctionV1
    function getSupplyReserved() public view returns (uint256) {
        uint256 totalBiddedAmount = getTotalBiddedAmount(_auctionNo);
        if (totalBiddedAmount == 0) return 0;

        return ((totalBiddedAmount * 1e18) / getTokenPrice(_auctionNo));
    }

    ///@inheritdoc IAuctionV1
    function getTokenPrice(uint256 auctionNo) public view returns (uint256) {
        if (_currentAuctionState == AuctionState.CLOSED) {
            return _endPrice[auctionNo];
        }
        return (STARTING_PRICE -
            ((block.timestamp - _auctionStartTime[auctionNo]) * MULTIPLIER));
    }

    ///@inheritdoc IAuctionV1
    function getTotalBiddedAmount(uint256 auctionNo)
        public
        view
        returns (uint256)
    {
        return _totalBidAmount[auctionNo];
    }

    ///@inheritdoc IAuctionV1
    function getAuctionNo() external view returns (uint256) {
        return _auctionNo;
    }

    ///@inheritdoc IAuctionV1
    function getAuctionStartTime(uint256 auctionNo)
        external
        view
        returns (uint256)
    {
        return _auctionStartTime[auctionNo];
    }

    ///@inheritdoc IAuctionV1
    function getAuctionEndTime(uint256 auctionNo)
        external
        view
        returns (uint256)
    {
        return _auctionEndTime[auctionNo];
    }

    ///@inheritdoc IAuctionV1
    function getAuctionState() external view returns (uint8) {
        return uint8(_currentAuctionState);
    }

    ///@inheritdoc IAuctionV1
    function getUserBidAmount(address account, uint256 auctionNo)
        external
        view
        returns (uint256)
    {
        return bidders[auctionNo].get(account);
    }

    function _authorizeUpgrade(address) internal override onlyOwner {}

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
            (block.timestamp >=
                _auctionStartTime[_auctionNo] + AUCTION_DURATION)
        ) {
            _endAuction();
            emit ShouldAuctionEnd(true);
            return true;
        }

        emit ShouldAuctionEnd(false);
        return false;
    }

    ///@inheritdoc IAuctionV1
    function insertBid() external payable auctionOngoing {
        if (checkIfAuctionShouldEnd()) {
            _refunds[msg.sender] = msg.value;
            _refundAmount += msg.value;
        } else {
            bidders[_auctionNo].set(msg.sender, msg.value);
            _totalBidAmount[_auctionNo] += msg.value;
            if (getSupplyReserved() >= AUCTION_SUPPLY) {
                _endAuction();
            }
        }
    }

    ///@inheritdoc IAuctionV1
    function withdraw() external nonReentrant {
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

        uint256 numOfKetchup;
        for (uint256 i = 0; i < _auctionNo; i++) {
            numOfKetchup +=
                (bidders[i].get(msg.sender) * 1e18) /
                getTokenPrice(i);
            bidders[i].remove(msg.sender);
        }
        //Put transfer at the end after states change
        IERC20(_ketchupToken).transfer(msg.sender, numOfKetchup);
        uint256 refundValue = _refundEthToAcc(msg.sender);
        emit Receiving(refundValue);
    }

    /**
     * End auction
     */
    function _endAuction() private {
        _currentAuctionState = AuctionState.CLOSING;
        _endPrice[_auctionNo] = getSupplyReserved() >= AUCTION_SUPPLY
            ? getTokenPrice(_auctionNo)
            : RESERVED_PRICE;
        if (_endPrice[_auctionNo] == RESERVED_PRICE) {
            _auctionEndTime[_auctionNo] =
                _auctionStartTime[_auctionNo] +
                20 minutes;
        } else {
            _auctionEndTime[_auctionNo] = block.timestamp;
        }

        _currentAuctionState = AuctionState.CLOSED;
        if (getSupplyReserved() > AUCTION_SUPPLY) {
            _refundLastBidder();
        } else {
            uint256 leftover = AUCTION_SUPPLY - getSupplyReserved();
            if (leftover > 0)
                IKetchupToken(_ketchupToken).burnRemainingToken(leftover);
        }
        uint256 amountToTransfer = address(this).balance - _refundAmount;
        if (amountToTransfer > 0) {
            (bool sent, ) = _ketchupToken.call{value: amountToTransfer}("");
            require(sent, "Failed to send ETH");
        }
        _auctionNo++;
    }

    /**
     * Send ETH to account if they have overbidded
     * @param account The account that is withdrawing
     */
    function _refundEthToAcc(address account) private returns (uint256) {
        uint256 refundValue = _refunds[account];
        if (refundValue != 0) {
            _refunds[account] = 0;
            _refundAmount -= refundValue;
            (bool sent, ) = account.call{value: refundValue}("");
            require(sent, "Failed to withdraw");
        }
        return refundValue;
    }

    /**
     * Refund excess ETH to the last bidder
     */
    function _refundLastBidder() private {
        uint256 tokensExceeded = getSupplyReserved() - AUCTION_SUPPLY;
        address lastBidder = bidders[_auctionNo].getKeyAtIndex(
            bidders[_auctionNo].size() - 1
        );
        uint256 excessValue = (tokensExceeded * getTokenPrice(_auctionNo));
        bidders[_auctionNo].values[lastBidder] =
            (bidders[_auctionNo].values[lastBidder] * 1e18 - excessValue) /
            1e18;
        uint256 refundVal = excessValue / 1e18;
        _refunds[lastBidder] += refundVal;
        _refundAmount += refundVal;
    }
}
