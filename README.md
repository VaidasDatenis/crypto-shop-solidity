# Escrow Smart Contract

This Ethereum-based smart contract facilitates secure and transparent transactions between buyers and sellers, leveraging the trustless environment of blockchain technology. It supports transactions with stablecoins, providing a reliable platform for buying and selling items without the volatility associated with other cryptocurrencies.

## Key Features

### Dynamic Fee Structure

The contract implements a tiered fee structure, automatically adjusting the fee based on the transaction amount. This approach ensures that fees are proportionate to the transaction size, making it fair and accessible for transactions of all values.

- **Low Tier Transactions**: For transactions up to 50 stablecoin units, a fee of 0.7% is applied.
- **Mid Tier Transactions**: Transactions above 50 and up to 100 stablecoin units incur a fee of 0.5%.
- **High Tier Transactions**: For transactions exceeding 100 stablecoin units, the fee is reduced to 0.2%.

This dynamic fee model is designed to encourage larger transactions by offering lower fees for higher amounts, benefiting both buyers and sellers on the platform.

### Flexible Fee Recipient Management

The contract allows for the dynamic updating of the fee recipient address by the contract owner. This feature adds an additional layer of operational flexibility, ensuring that fee distribution aligns with the platform's evolving business needs.

### Transaction State Management

Transactions progress through defined states (Pending, Shipped, Completed, Cancelled), with safeguards in place to ensure actions are appropriate for the transaction's current state. This state management enforces a structured and secure transaction process.

### Support for Stablecoin Transactions

Designed specifically for transactions with stablecoins, the contract provides a stable and reliable medium for trade, immune to the price volatility commonly associated with other cryptocurrencies.

### Cancellation and Refund Mechanism

Buyers have the option to cancel transactions while in the Pending state, triggering an automatic refund. This feature protects buyers against undelivered items, ensuring a trustworthy trading environment.

## How to Use

1. **Creating a Transaction**: Initiate by specifying the seller, amount, and the ERC-20 token address for the stablecoin being used.
2. **Updating Transaction States**: Sellers mark transactions as shipped, and buyers confirm receipt, triggering the automated fee deduction and fund transfer.
3. **Managing Fees and Recipients**: The contract owner can update fee thresholds and the fee recipient address as needed, adapting to the platform's requirements.

## Development and Deployment

The contract should be deployed using tools like Truffle or Hardhat. Ensure thorough testing, especially for the dynamic fee calculation and transaction cancellation functionalities, to maintain contract integrity and user trust.

## Security and Auditing

Given the contract's handling of financial transactions, a comprehensive security audit is recommended before deployment. Regular reviews and updates in response to discovered vulnerabilities are crucial to safeguarding user assets.
