# NFT Royalty Marketplace

This repository provides a professional-grade marketplace contract for trading NFTs with integrated royalty support. It ensures that artists are fairly compensated by enforcing royalty payments during secondary sales on-chain.

## Features
* **EIP-2981 Integration**: Compatible with the Ethereum standard for NFT royalties.
* **Fixed Price Listings**: Efficient listing and delisting mechanisms.
* **Secure Escrow**: Funds are handled securely using a pull-payment pattern.
* **Low Gas Fees**: Optimized storage patterns to reduce transaction costs.

## Architecture
The marketplace interacts with any ERC-721 contract. When a sale occurs, the contract checks if the NFT implements `IERC2981`. If it does, it calculates the royalty, sends it to the creator, and transfers the remainder to the seller.

## Setup
1. Deploy the contract.
2. Approve the marketplace address to handle your NFTs.
3. Call `listNft` with the token address, ID, and price.
