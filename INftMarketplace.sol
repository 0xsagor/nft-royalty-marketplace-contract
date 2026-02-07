// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface INftMarketplace {
    struct Listing {
        address seller;
        uint256 price;
    }

    event ItemListed(address indexed seller, address indexed nftAddress, uint256 indexed tokenId, uint256 price);
    event ItemSold(address indexed buyer, address indexed nftAddress, uint256 indexed tokenId, uint256 price);
    event ItemCanceled(address indexed seller, address indexed nftAddress, uint256 indexed tokenId);

    function listNft(address nftAddress, uint256 tokenId, uint256 price) external;
    function buyNft(address nftAddress, uint256 tokenId) external payable;
    function cancelListing(address nftAddress, uint256 tokenId) external;
}
