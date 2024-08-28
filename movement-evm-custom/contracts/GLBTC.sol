// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";

contract GLBTC is ERC20, Ownable, AccessControl {
    // Role for addresses allowed to mint tokens via cross-chain operations
    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");

    // Mapping to store processed cross-chain requests
    mapping(bytes32 => bool) public processedRequests;

    // Chain ID of the source chain (set during contract deployment)
    uint256 public fromChain;

    // Nonce to ensure uniqueness of each cross-chain operation, increments with each call
    uint256 public nonce;

    // Variable to store the decimals
    uint8 private _decimals;

    // Events for cross-chain operations
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

    constructor(string memory name, string memory symbol, uint8 decimals_, uint256 _fromChain) ERC20(name, symbol) {
        fromChain = _fromChain;
        _decimals = decimals_;

        // Grant the deployer the default admin role and minter role
        _setupRole(MINTER_ROLE, msg.sender);
    }

    // Override the decimals function to return the custom decimals value
    function decimals() public view virtual override returns (uint8) {
        return _decimals;
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

    // Cross out tokens to another chain by burning them
    function lockTokens(uint256 amount, uint256 toChain) external {
        require(amount > 0, "Amount must be greater than zero");

        // Increment nonce for each new lockTokens call
        uint256 currentNonce = nonce;
        nonce++;

        // Generate a unique identifier for the cross-chain request
        bytes32 requestId = keccak256(abi.encode(fromChain, toChain, currentNonce, msg.sender, amount));

        // Burn tokens from the user's balance
        _burn(msg.sender, amount);

        emit TokensLocked(requestId, msg.sender, amount, fromChain, toChain, currentNonce);
    }

    // Cross in tokens from another chain by minting them
    function unlockTokens(
        address user,
        uint256 amount,
        uint256 _fromChain,
        uint256 toChain,
        uint256 _nonce
    ) external onlyRole(MINTER_ROLE) {
        require(amount > 0, "Amount must be greater than zero");
        require(toChain == fromChain, "Invalid destination chain");

        // Generate a unique identifier for the cross-chain request
        bytes32 requestId = keccak256(abi.encode(_fromChain, toChain, _nonce, user, amount));

        require(!processedRequests[requestId], "Request has already been processed");

        // Mark the request as processed
        processedRequests[requestId] = true;

        // Mint tokens to the user's account
        _mint(user, amount);

        emit TokensUnlocked(requestId, user, amount, _fromChain, toChain, _nonce);
    }

    // Function to grant MINTER_ROLE to an address
    function grantMinterRole(address account) external onlyOwner {
        grantRole(MINTER_ROLE, account);
    }

    // Function to revoke MINTER_ROLE from an address
    function revokeMinterRole(address account) external onlyOwner {
        revokeRole(MINTER_ROLE, account);
    }

    // Overriding transferOwnership to also transfer AccessControl admin role
    function transferOwnership(address newOwner) public override onlyOwner {
        // Transfer ownership of the contract
        super.transferOwnership(newOwner);

        // Transfer DEFAULT_ADMIN_ROLE to the new owner
        _setupRole(DEFAULT_ADMIN_ROLE, newOwner);
        _revokeRole(DEFAULT_ADMIN_ROLE, msg.sender);
    }
}
