// SPDX-License-Identifier: MIT
pragma solidity 0.8.37;
interface IApexAuction {
    function placeBid(uint256 auctionId) external payable;
    function finalizeAuction(uint256 auctionId) external;
}
