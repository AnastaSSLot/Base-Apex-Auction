# Base Apex Auction

A highly optimized decentralized auction protocol deployed on the Base L2 network. Designed to facilitate trustless, high-value asset bidding with automated refund routing and anti-manipulation mechanics.

## Core Features
* **Anti-Sniping Protection:** Automatically extends the auction duration if a valid bid is placed within the final minutes, preventing malicious last-second outbidding.
* **Automated Escrow & Refunds:** Employs the "Pull over Push" withdrawal pattern to securely store outbid ETH, completely eliminating reentrancy vectors during active bidding phases.
* **Immutable State Transitions:** Auction states (Active, Ended, Canceled) are cryptographically locked, ensuring that finalizing an auction permanently freezes the bidding logic.

## Architecture
Compiled with Solidity `0.8.37`. The protocol minimizes gas consumption by tightly packing state variables (e.g., timestamps and boolean flags) and utilizing custom errors for standard revert conditions.
