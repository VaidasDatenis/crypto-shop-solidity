// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IERC20 {
    function transfer(address recipient, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
}

contract Escrow {
    address payable public owner;
    address payable public feeRecipient; // Address where the fee will be sent
    uint256 constant feePercentage = 20; // Representing 0.2%, since we'll use basis points for calculation

    constructor() {
        owner = payable(msg.sender); // Setting the contract deployer as the owner
        feeRecipient = owner; // Initially, the owner is also the fee recipient
    }

    enum TransactionState { Pending, Shipped, Completed }

    struct Transaction {
        address buyer;
        address seller;
        uint256 amount;
        TransactionState state;
        bool isEther;
        address tokenAddress; // Relevant for ERC-20 transactions
    }

    Transaction[] public transactions;

    event FeeRecipientUpdated(address indexed newRecipient);
    event DirectDepositReceived(address indexed sender, uint256 amount);
    // Events for tracking the contract's activities
    event TransactionCreated(uint indexed transactionId, address indexed buyer, address indexed seller, uint256 amount, bool isEther, address tokenAddress);
    event TransactionShipped(uint indexed transactionId);
    event TransactionCompleted(uint indexed transactionId);
    event FundsDeposited(uint indexed transactionId, uint256 amount, bool isEther);
    event FundsRefunded(uint indexed transactionId, uint256 amount, bool isEther);

    // Modifier to check transaction state
    modifier inState(uint _transactionId, TransactionState _state) {
        require(transactions[_transactionId].state == _state, "Transaction is not in the correct state.");
        _;
    }

    // Modifier to ensure only the buyer can call certain functions
    modifier onlyBuyer(uint _transactionId) {
        require(msg.sender == transactions[_transactionId].buyer, "Only the buyer can call this function.");
        _;
    }

    // Modifier to ensure only the seller can call certain functions
    modifier onlySeller(uint _transactionId) {
        require(msg.sender == transactions[_transactionId].seller, "Only the seller can call this function.");
        _;
    }

    // Function to create a transaction. Payable for ETH transactions.
    function createTransaction(address _seller, uint256 _amount, bool _isEther, address _tokenAddress) public payable {
        if(_isEther) {
            require(msg.value == _amount, "Sent ether does not match the specified amount.");
        } else {
            require(msg.value == 0, "Do not send ETH for token transactions.");
        }

        Transaction memory newTransaction = Transaction({
            buyer: msg.sender,
            seller: _seller,
            amount: _amount,
            state: TransactionState.Pending,
            isEther: _isEther,
            tokenAddress: _tokenAddress
        });
        transactions.push(newTransaction);
        uint transactionId = transactions.length - 1;
        emit TransactionCreated(transactionId, msg.sender, _seller, _amount, _isEther, _tokenAddress);
        
        if(_isEther) {
            emit FundsDeposited(transactionId, msg.value, true);
        }
    }

    // Mark a transaction as shipped
    function markAsShipped(uint _transactionId) public onlySeller(_transactionId) inState(_transactionId, TransactionState.Pending) {
        transactions[_transactionId].state = TransactionState.Shipped;
        emit TransactionShipped(_transactionId);
    }

    // Function to update the fee recipient address
    function updateFeeRecipient(address payable _newRecipient) public {
        require(msg.sender == owner, "Only the owner can update the fee recipient.");
        require(_newRecipient != address(0), "Invalid address.");

        feeRecipient = _newRecipient;
        emit FeeRecipientUpdated(_newRecipient);
    }

    // Confirm the item was received and release funds to the seller
    function confirmReceived(uint _transactionId) public onlyBuyer(_transactionId) inState(_transactionId, TransactionState.Shipped) {
        Transaction storage transaction = transactions[_transactionId];
        uint256 fee = transaction.amount * feePercentage / 10000; // Calculate the 0.2% fee
        uint256 amountAfterFee = transaction.amount - fee; // Calculate net amount for the seller

        if(transaction.isEther) {
            payable(transaction.seller).transfer(amountAfterFee); // Send net amount to the seller
            feeRecipient.transfer(fee); // Send the fee to the feeRecipient
        } else {
            IERC20 token = IERC20(transaction.tokenAddress);
            require(token.transferFrom(address(this), transaction.seller, amountAfterFee), "Transfer to seller failed."); // Send net amount to the seller for ERC-20
            require(token.transferFrom(address(this), feeRecipient, fee), "Fee transfer failed."); // Send the fee to the feeRecipient for ERC-20
        }

        transaction.state = TransactionState.Completed;
        emit TransactionCompleted(_transactionId);
    }

    // Allow the contract to receive ETH directly
    receive() external payable {
        emit DirectDepositReceived(msg.sender, msg.value);
    }

    fallback() external payable {
        emit DirectDepositReceived(msg.sender, msg.value);
    }
}
