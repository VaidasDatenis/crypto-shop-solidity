# Escrow Smart Contract

This Ethereum-based smart contract serves as an escrow mechanism, facilitating secure transactions between buyers and sellers. It supports both Ethereum (ETH) and ERC-20 token payments, incorporating a fee system and ensuring transaction integrity through defined states.

## Features

### Fee System
- Automatically calculates a 0.2% fee from each transaction amount.
- Supports fee deduction for both ETH and ERC-20 transactions.
- Fee recipient address can be updated for operational flexibility.

### Transaction States
- Utilizes `Pending`, `Shipped`, `Completed`, and `Cancelled` states to manage the transaction lifecycle.
- Includes modifiers to enforce correct state transitions and role-based actions.

### Role-based Actions
- Specific actions are restricted to either the buyer, seller, or contract owner, ensuring transactions proceed as intended.

### ERC-20 Token Support
- Facilitates transactions with any ERC-20 token, alongside ETH transactions.

### Direct ETH Deposits
- Accepts direct ETH deposits through the `receive` and `fallback` functions.

## Usage

### Creating a Transaction
Buyers initiate transactions by specifying the seller, amount, and payment currency (ETH or ERC-20).

### Updating Transaction State
Sellers mark the transaction as shipped. Buyers confirm receipt, which releases funds to the seller and deducts the platform fee.

### Cancelling a Transaction
Buyers can cancel transactions in the `Pending` state, triggering a refund.

### Fee Recipient Management
The contract owner can update the fee recipient address, directing where transaction fees are sent.

## Development and Deployment

Deploy the contract using your preferred tools (e.g., Truffle, Hardhat) and interact with it through a web3-enabled frontend or directly via an Ethereum wallet.

## Events for Tracking and Transparency

The contract emits events for key actions (e.g., `TransactionCreated`, `TransactionCancelled`), enabling easy tracking of activities on the blockchain.

---

For detailed function documentation and best practices for interacting with the contract, refer to the inline comments within the contract code.
"""