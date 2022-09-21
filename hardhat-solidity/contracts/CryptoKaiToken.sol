// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./ICryptoDevs.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract CryptoKaiToken is ERC20, Ownable {
    // Price of one Crypto Kai token
    uint256 public constant tokenPrice = 0.0001 ether;
    // Each NFT would give the user 10 tokens
    uint256 public constant tokensPerNFT = 10 * 10**18;
    // the max total supply is 10000 for Crypto Kai Tokens
    uint256 public constant maxTotalSupply = 10000 * 10**18;
    // CryptoDevsNFT contract instance
    ICryptoDevs CryptoDevsNFT;
    // Mapping to keep track of which tokenIds have been claimed
    mapping(uint256 => bool) public tokenIdsClaimed;

    constructor(address _cryptoDevsContract) ERC20("Crypto Kai Token", "CK") {
        CryptoDevsNFT = ICryptoDevs(_cryptoDevsContract);
    }

    /**
     * @dev Mints 'amount' number of CryptoKaiTokens
     */
    function mint(uint256 amount) public payable {
        uint256 _requireAmount = tokenPrice * amount;
        require(msg.value >= _requireAmount, "Ether sent is incorrect");
        uint256 amountWithDecimals = amount * 10**18;
        require(
            (totalSupply() + amountWithDecimals) <= maxTotalSupply,
            "Exceeds the max total supply avaliable."
        );
        // call the internal function from Openzeppelin's ERC20 contract
        _mint(msg.sender, amountWithDecimals);
    }

    /**
     * @dev Mints tokens based on the number of NFT's held by the sender
     * 相当于使用NFT免费兑换CK代币，每个NFT ID可以兑换10个CK代币
     */
    function claim() public {
        address sender = msg.sender;
        // Get the number of CryptoDev NFT's held by a given sender address
        uint256 balance = CryptoDevsNFT.balanceOf(sender);
        // If the balance is 0, revert the transaction
        require(balance > 0, "You don't own any Crypto Dev NFT's");

        // amount keeps track of number of unclaimed tokenIds
        uint256 amount = 0;
        // loop over the balance and get the token ID owned by 'sender' at a given 'index' of its token list
        for (uint256 i = 0; i < balance; i++) {
            uint256 tokenId = CryptoDevsNFT.tokenOfOwnerByIndex(sender, i);
            // if the tokenId has not been claimed,increase the amount
            if (!tokenIdsClaimed[tokenId]) {
                amount += 1;
                tokenIdsClaimed[tokenId] = true;
            }
        }
        // If all the token Ids have been claimed, revert the transaction
        require(amount > 0, "You have already claimed all the tokens");
        // call the internal function from Openzeppelin's ERC20 contract
        // Mint (amount * 10) tokens for each NFT
        _mint(msg.sender, amount * tokensPerNFT);
    }

    /**
     * @dev withdraw all ETH and tokens sent to the contract
     */
    function withdraw() public onlyOwner {
        address _owner = owner();
        uint256 amount = address(this).balance;
        (bool sent, ) = _owner.call{value: amount}("");
        require(sent, "Failed to send Ether");
    }

    // Function to receive Ether. msg.data must be empty
    receive() external payable {}

    // Fallback function is called when msg.data is not empty
    fallback() external payable {}
}
