// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/interfaces/IERC2981.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";

contract NftMarketplace is ReentrancyGuard {
    struct Listing {
        address seller;
        uint256 price;
    }

    // NFT Address -> Token ID -> Listing
    mapping(address => mapping(uint256 => Listing)) private s_listings;

    error NotOwner();
    error NotListed(address nftAddress, uint256 tokenId);
    error PriceNotMet(address nftAddress, uint256 tokenId, uint256 price);
    error NoProceeds();

    event ItemListed(address indexed seller, address indexed nftAddress, uint256 indexed tokenId, uint256 price);
    event ItemSold(address indexed buyer, address indexed nftAddress, uint256 indexed tokenId, uint256 price);

    function listNft(address nftAddress, uint256 tokenId, uint256 price) external {
        IERC721 nft = IERC721(nftAddress);
        if (nft.ownerOf(tokenId) != msg.sender) revert NotOwner();
        require(price > 0, "Price must be above zero");
        
        s_listings[nftAddress][tokenId] = Listing(msg.sender, price);
        emit ItemListed(msg.sender, nftAddress, tokenId, price);
    }

    function buyNft(address nftAddress, uint256 tokenId) external payable nonReentrant {
        Listing memory listedItem = s_listings[nftAddress][tokenId];
        if (listedItem.price <= 0) revert NotListed(nftAddress, tokenId);
        if (msg.value < listedItem.price) revert PriceNotMet(nftAddress, tokenId, listedItem.price);

        delete s_listings[nftAddress][tokenId];

        uint256 royaltyAmount = 0;
        address royaltyRecipient;

        // Handle EIP-2981 Royalties
        try IERC2981(nftAddress).royaltyInfo(tokenId, msg.value) returns (address receiver, uint256 amount) {
            royaltyRecipient = receiver;
            royaltyAmount = amount;
        } catch {}

        if (royaltyAmount > 0 && royaltyRecipient != address(0)) {
            (bool royaltySuccess, ) = payable(royaltyRecipient).call{value: royaltyAmount}("");
            require(royaltySuccess, "Royalty transfer failed");
        }

        (bool sellerSuccess, ) = payable(listedItem.seller).call{value: msg.value - royaltyAmount}("");
        require(sellerSuccess, "Seller transfer failed");

        IERC721(nftAddress).safeTransferFrom(listedItem.seller, msg.sender, tokenId);
        emit ItemSold(msg.sender, nftAddress, tokenId, listedItem.price);
    }

    function getListing(address nftAddress, uint256 tokenId) external view returns (Listing memory) {
        return s_listings[nftAddress][tokenId];
    }
}
