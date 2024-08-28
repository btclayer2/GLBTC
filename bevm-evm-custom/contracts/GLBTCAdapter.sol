// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract GLBTCAdapter is Ownable {
    // Mapping to store processed cross-chain requests
    mapping(bytes32 => bool) public processedRequests;

    // Token contract address
    IERC20 public token;

    // Chain ID of the source chain (set during contract deployment)
    uint256 public fromChain;

    // Nonce to ensure uniqueness of each lockTokens call, increments with each call
    uint256 public nonce;

    // Events for locking and unlocking tokens with indexed requestId
    event TokensLocked(
        bytes32 indexed requestId,
        address indexed user,
        uint256 amount,
        uint256 fromChain,
        uint256 toChain,
        uint256 nonce
    );

    event TokensUnlocked(
        bytes32 indexed requestId,
        address indexed user,
        uint256 amount,
        uint256 fromChain,
        uint256 toChain,
        uint256 nonce
    );

    constructor(address tokenAddress, uint256 _fromChain) {
        token = IERC20(tokenAddress);
        fromChain = _fromChain;
    }

    // View function to compute the requestId for external use
    function computeRequestId(
        uint256 _fromChain,
        uint256 toChain,
        uint256 _nonce,
        address user,
        uint256 amount
    ) public pure returns (bytes32) {
        return keccak256(abi.encode(_fromChain, toChain, _nonce, user, amount));
    }

    // Lock tokens and create a cross-chain request
    function lockTokens(uint256 amount, uint256 toChain) external {
        require(amount > 0, "Amount must be greater than zero");

        // Increment nonce for each new lockTokens call
        uint256 currentNonce = nonce;
        nonce++;

        // Generate a unique identifier for the cross-chain request
        bytes32 requestId = keccak256(abi.encode(fromChain, toChain, currentNonce, msg.sender, amount));

        require(!processedRequests[requestId], "Request has already been processed");

        // Lock tokens by transferring them from the user to the contract
        token.transferFrom(msg.sender, address(this), amount);

        emit TokensLocked(requestId, msg.sender, amount, fromChain, toChain, currentNonce);
    }

    // Unlock tokens based on a cross-chain request
    function unlockTokens(
        address user,
        uint256 amount,
        uint256 _fromChain,
        uint256 toChain,
        uint256 _nonce
    ) external onlyOwner {
        require(amount > 0, "Amount must be greater than zero");
        require(toChain == fromChain, "Invalid destination chain");

        // Generate a unique identifier for the cross-chain request
        bytes32 requestId = keccak256(abi.encode(_fromChain, toChain, _nonce, user, amount));

        require(!processedRequests[requestId], "Request has already been processed");

        // Mark the request as processed
        processedRequests[requestId] = true;

        // Unlock tokens to the user's account
        token.transfer(user, amount);

        emit TokensUnlocked(requestId, user, amount, _fromChain, toChain, _nonce);
    }
}
