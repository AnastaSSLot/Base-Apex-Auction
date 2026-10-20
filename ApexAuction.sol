// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

contract ApexAuction {
    struct AuctionItem {
        string title;
        uint256 highestBid;
        address highestBidder;
        uint256 endTime;
        bool settled;
    }

    address payable public immutable creator;
    uint256 public auctionCount;

    mapping(uint256 => AuctionItem) public auctions;

    event AuctionCreated(uint256 indexed auctionId, string title, uint256 endTime);
    event NewHighestBid(uint256 indexed auctionId, address indexed bidder, uint256 amount);
    event AuctionExtended(uint256 indexed auctionId, uint256 newEndTime);
    event AuctionSettled(uint256 indexed auctionId, address winner, uint256 winningBid);

    modifier onlyCreator() {
        require(msg.sender == creator, "ApexAuction: Only creator permitted");
        _;
    }

    constructor() {
        creator = payable(msg.sender);
    }

    // 1. Создать аукционный лот (длительность в секундах)
    function createAuction(string calldata title, uint256 durationSeconds) external onlyCreator returns (uint256) {
        require(bytes(title).length > 0, "ApexAuction: Empty title");
        require(durationSeconds >= 60, "ApexAuction: Duration too short");

        auctionCount++;
        auctions[auctionCount] = AuctionItem({
            title: title,
            highestBid: 0,
            highestBidder: address(0),
            endTime: block.timestamp + durationSeconds,
            settled: false
        });

        emit AuctionCreated(auctionCount, title, block.timestamp + durationSeconds);
        return auctionCount;
    }

    // 2. Сделать ставку (payable)
    function placeBid(uint256 auctionId) external payable {
        AuctionItem storage item = auctions[auctionId];
        require(auctionId > 0 && auctionId <= auctionCount, "ApexAuction: Invalid auction ID");
        require(block.timestamp < item.endTime, "ApexAuction: Auction has ended");
        require(msg.value > item.highestBid, "ApexAuction: Bid must be higher than current highest");

        address previousBidder = item.highestBidder;
        uint256 previousBid = item.highestBid;

        item.highestBid = msg.value;
        item.highestBidder = msg.sender;

        emit NewHighestBid(auctionId, msg.sender, msg.value);

        // Возврат предыдущей ставки, если она была
        if (previousBidder != address(0)) {
            (bool refunded, ) = payable(previousBidder).call{value: previousBid}("");
            require(refunded, "ApexAuction: Refund failed");
        }
    }

    // 3. Продлить время аукциона
    function extendAuctionDuration(uint256 auctionId, uint256 extraSeconds) external onlyCreator {
        AuctionItem storage item = auctions[auctionId];
        require(auctionId > 0 && auctionId <= auctionCount, "ApexAuction: Invalid auction ID");
        require(!item.settled, "ApexAuction: Already settled");

        item.endTime += extraSeconds;
        emit AuctionExtended(auctionId, item.endTime);
    }

    // 4. Завершить аукцион и забрать финальную сумму создателю
    function closeAuction(uint256 auctionId) external onlyCreator {
        AuctionItem storage item = auctions[auctionId];
        require(auctionId > 0 && auctionId <= auctionCount, "ApexAuction: Invalid auction ID");
        require(!item.settled, "ApexAuction: Already settled");

        item.settled = true;
        uint256 proceeds = item.highestBid;

        if (proceeds > 0) {
            (bool sent, ) = creator.call{value: proceeds}("");
            require(sent, "ApexAuction: Transfer failed");
        }

        emit AuctionSettled(auctionId, item.highestBidder, proceeds);
    }

    // Просмотр лота
    function getAuction(uint256 auctionId) external view returns (
        string memory title,
        uint256 highestBid,
        address highestBidder,
        uint256 endTime,
        bool settled
    ) {
        AuctionItem memory item = auctions[auctionId];
        return (item.title, item.highestBid, item.highestBidder, item.endTime, item.settled);
    }
}