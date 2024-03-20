Our Ethereum-based Escrow Smart Contract is designed to facilitate secure and transparent transactions between buyers and sellers, handling both Ethereum (ETH) and ERC-20 token payments. This contract is especially useful for online marketplaces or any platform that requires a trustless escrow service.

## Key Features

### Fee Handling

- **Automated Fee Calculation**: For every transaction, the contract automatically calculates and deducts a 0.2% fee from the total amount. This ensures that the platform's operational costs are covered without manual intervention.
- **Support for Multiple Currencies**: The fee deduction mechanism works seamlessly with both ETH and ERC-20 token transactions, ensuring flexibility and convenience for users.

### Flexible Fee Recipient

- **Dynamic Fee Recipient Address**: Through the `updateFeeRecipient` function, the contract owner can change the address that receives the transaction fees, adding a layer of operational flexibility.
- **Secure Updates**: This critical function is restricted to the contract owner, with additional safeguards to prevent setting an invalid address.

### Transaction State Management

- **Defined Transaction States**: Utilizing enums, the contract delineates clear transaction states (Pending, Shipped, Completed), guiding the flow of transactions.
- **Role and State Enforcement**: With modifiers (`inState`, `onlyBuyer`, `onlySeller`), the contract ensures actions are performed by authorized parties and in the correct order.

### Transparency and Tracking

- **Events for Visibility**: The contract emits detailed events for key actions (e.g., `TransactionCreated`, `TransactionCompleted`), enabling real-time tracking of activities and enhancing transparency.

### Direct ETH Deposits

- **Support for Direct Deposits**: Implemented `receive` and `fallback` functions allow the contract to accept ETH directly, with emitted events logging these transactions.

## How to Use

1. **Deploy the Contract**: Deploy the escrow contract to your preferred Ethereum network (mainnet or testnet).
2. **Set Up Transactions**: Buyers can initiate transactions specifying the seller and the amount. The contract supports both ETH and ERC-20 tokens.
3. **Track and Update Transactions**: Sellers mark transactions as shipped, and buyers confirm receipt, with the contract handling state transitions and fee deductions automatically.
4. **Fee Recipient Management**: Contract owners can update the fee recipient address as needed, ensuring flexibility in managing collected fees.

## Development and Deployment

- Ensure you have a development environment set up with tools like Truffle or Hardhat for deploying and interacting with smart contracts.
- For testing, use networks like Ropsten or Rinkeby to avoid incurring real costs.
- Always test thoroughly before deploying to the Ethereum mainnet.

## Events and Tracking

- Monitor contract events using tools like Etherscan or a custom frontend integrated with web3 libraries to track transactions and contract interactions in real-time.

## Security Considerations

- Regularly audit and review your contract code, especially when making updates or adjusting fee structures.
- Consider engaging with professional auditors for comprehensive security checks.