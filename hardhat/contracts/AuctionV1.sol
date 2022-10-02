pragma solidity 0.8.16;

import "./IterableMapping.sol";
import "./EnumDeclaration.sol";
import "../interfaces/IKetchupToken.sol";
import "../interfaces/IERC20.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";

///FORMATTED USING SOLIDITY STYLE GUIDE

/**
 * @title Auction contract V1
 * @author Team Ketchup
 */
contract AuctionV1 is Initializable, UUPSUpgradeable, OwnableUpgradeable {
    using IterableMapping for IterableMapping.Map;

    //Starting price: 1 ETH/KCH
    uint256 constant STARTING_PRICE = 1e18;
    uint256 constant MULTIPLIER = 1e12;
    uint256 constant RESERVED_PRICE = STARTING_PRICE - (20 * 60 * MULTIPLIER);
    uint256 constant AUCTION_SUPPLY = 1e20;

    ///Auction-related variables
    uint256 private _endPrice;
    uint256 private _auctionStartTime;
    AuctionState private _currentAuctionState;

    ///Address of Ketchup Token
    address private _ketchupToken;

    ///Binding-related variables
    uint256 public _totalBidAmount;
    mapping(address => uint256) private _refunds;
    IterableMapping.Map bidders;

    event ShouldAuctionEnd(bool value);
    event RefundValue(uint256 amount);

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

    /**
     * Allow the owner of the Auction contract to start auction
     */
    function startAuction() public onlyOwner {
        require(
            _currentAuctionState == AuctionState.CLOSED,
            "Auction is ongoing."
        );
        IKetchupToken(_ketchupToken).fundAuction();
        _auctionStartTime = block.timestamp;
        _currentAuctionState = AuctionState.ONGOING;
        _totalBidAmount = 0;
        delete bidders.keys;
    }

    /**
     * Check if auction should end
     * If yes, end the auction
     * @dev Gas cost of ending the auction is passed to the user
     */
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

    function getAuctionState() public view returns (AuctionState) {
        return _currentAuctionState;
    }

    /**
     * Get current token price
     * @notice decimal of token is 10**18
     * @return price in a range of 10**16 to 10**17
     */
    function getTokenPrice() public view returns (uint256) {
        if (_currentAuctionState == AuctionState.CLOSED) {
            return _endPrice;
        }
        return (STARTING_PRICE -
            ((block.timestamp - _auctionStartTime) * MULTIPLIER));
    }

    /**
     * Get current number of tokens reserved by bidders
     */
    function getSupplyReserved() public view returns (uint256) {
        if (_totalBidAmount == 0) return 0;

        return ((_totalBidAmount * 1e18) / getTokenPrice());
    }

    function _authorizeUpgrade(address) internal override onlyOwner {}

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
        uint256 numOfKetchup = (ethBidded * 1e18) / getTokenPrice();
        IERC20(_ketchupToken).transfer(msg.sender, numOfKetchup);
        (bool sent, ) = msg.sender.call{value: refundValue}("");
        require(sent, "Failed to withdraw");
        emit RefundValue(refundValue);
    }

    /**
     * Get total amount bidded in current auction
     */
    function getTotalBidAmount() external view returns (uint256) {
        return _totalBidAmount;
    }

    function getUserBidAmount(address account) external view returns (uint256) {
        return bidders.get(account);
    }

    function getAuctionStartTime() external view returns (uint256) {
        return _auctionStartTime;
    }

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

    function _refundLastBidder() private {
        uint256 tokensExceeded = getSupplyReserved() - AUCTION_SUPPLY;
        address lastBidder = bidders.getKeyAtIndex(bidders.size() - 1);
        uint256 excessValue = (tokensExceeded * getTokenPrice());
        bidders.values[lastBidder] =
            (bidders.values[lastBidder] * 1e18 - excessValue) /
            1e18;
        _refunds[lastBidder] += excessValue / 1e18;
    }
}