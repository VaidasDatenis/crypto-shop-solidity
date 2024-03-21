// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IERC20 {
    function transfer(address recipient, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
}

contract Escrow {
    address payable public owner;
    address payable public feeRecipient; // Address where the fee will be sent
    uint256 public lowTierThreshold = 50 * (10 ** 18); // Representing 1000 stablecoin units
    uint256 public midTierThreshold = 100 * (10 ** 18); // Representing 5000 stablecoin units
    uint256 public highTierThreshold = 500 * (10 ** 18); // Representing 10000 stablecoin units

    uint256 public lowTierFeePercentage = 7; // 0.7%
    uint256 public midTierFeePercentage = 5; // 0.5%
    uint256 public highTierFeePercentage = 2;  // 0.2%

    constructor() {
        owner = payable(msg.sender); // Setting the contract deployer as the owner
        feeRecipient = owner; // Initially, the owner is also the fee recipient
    }

    enum TransactionState { Pending, Shipped, Completed, Cancelled }

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
    event TransactionCancelled(uint indexed transactionId);
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
        // Dynamic fee calculation based on the transaction amount
        uint256 fee = calculateFee(transaction.amount);
        uint256 amountAfterFee = transaction.amount - fee;

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

    // Function to cancel a transaction and refund the buyer
    function cancelTransaction(uint _transactionId) public onlyBuyer(_transactionId) inState(_transactionId, TransactionState.Pending) {
        Transaction storage transaction = transactions[_transactionId];
        
        if(transaction.isEther) {
            payable(transaction.buyer).transfer(transaction.amount);
        } else {
            IERC20 token = IERC20(transaction.tokenAddress);
            require(token.transfer(transaction.buyer, transaction.amount), "Refund failed.");
        }
        
        transaction.state = TransactionState.Cancelled;
        emit TransactionCancelled(_transactionId);
    }

    // Function to calculate dynamic fees based on the cost of the item
    function calculateFee(uint256 _amount) public view returns (uint256) {
        uint256 feePercentage;
        if (_amount <= lowTierThreshold) {
            feePercentage = lowTierFeePercentage;
        } else if (_amount <= midTierThreshold) {
            feePercentage = midTierFeePercentage;
        } else {
            feePercentage = highTierFeePercentage;
        }
        return _amount * feePercentage / 10000;
    }

    // Function to call from dApp to shod the status of thansaction
    function getTransactionState(uint _transactionId) public view returns (string memory) {
        require(_transactionId < transactions.length, "Transaction does not exist.");
        
        TransactionState state = transactions[_transactionId].state;
        
        // Return a human-readable state
        if (state == TransactionState.Pending) {
            return "Pending";
        } else if (state == TransactionState.Shipped) {
            return "Shipped";
        } else if (state == TransactionState.Completed) {
            return "Completed";
        } else if (state == TransactionState.Cancelled) {
            return "Cancelled";
        } else {
            return "Unknown";
        }
    }

    // Allow the contract to receive ETH directly
    receive() external payable {
        emit DirectDepositReceived(msg.sender, msg.value);
    }

    fallback() external payable {
        emit DirectDepositReceived(msg.sender, msg.value);
    }
}
