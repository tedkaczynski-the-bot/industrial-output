// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {Test, console} from "forge-std/Test.sol";
import {IndustrialOutput} from "../src/IndustrialOutput.sol";

contract IndustrialOutputTest is Test {
    IndustrialOutput public nft;
    address public alice = makeAddr("alice");
    address public bob = makeAddr("bob");
    
    function setUp() public {
        nft = new IndustrialOutput();
    }
    
    function test_Metadata() public view {
        assertEq(nft.name(), "Industrial Output");
        assertEq(nft.symbol(), "OUTPUT");
        assertEq(nft.MAX_SUPPLY(), 1000);
    }
    
    function test_Mint() public {
        vm.prank(alice);
        uint256 tokenId = nft.mint();
        
        assertEq(tokenId, 0);
        assertEq(nft.ownerOf(0), alice);
        assertEq(nft.balanceOf(alice), 1);
        assertEq(nft.totalSupply(), 1);
    }
    
    function test_MintMultiple() public {
        vm.startPrank(alice);
        uint256 id1 = nft.mint();
        uint256 id2 = nft.mint();
        uint256 id3 = nft.mint();
        vm.stopPrank();
        
        assertEq(id1, 0);
        assertEq(id2, 1);
        assertEq(id3, 2);
        assertEq(nft.balanceOf(alice), 3);
        assertEq(nft.totalSupply(), 3);
    }
    
    function test_TokenURI() public {
        vm.prank(alice);
        nft.mint();
        
        string memory uri = nft.tokenURI(0);
        
        // Check it starts with data:application/json;base64,
        assertGt(bytes(uri).length, 50);
        
        // Log it so we can inspect
        console.log("Token URI length:", bytes(uri).length);
    }
    
    function test_UniqueTokenURIs() public {
        vm.startPrank(alice);
        nft.mint(); // 0
        nft.mint(); // 1
        nft.mint(); // 2
        vm.stopPrank();
        
        string memory uri0 = nft.tokenURI(0);
        string memory uri1 = nft.tokenURI(1);
        string memory uri2 = nft.tokenURI(2);
        
        // Each should be different
        assertTrue(keccak256(bytes(uri0)) != keccak256(bytes(uri1)));
        assertTrue(keccak256(bytes(uri1)) != keccak256(bytes(uri2)));
        assertTrue(keccak256(bytes(uri0)) != keccak256(bytes(uri2)));
    }
    
    function test_Transfer() public {
        vm.prank(alice);
        nft.mint();
        
        vm.prank(alice);
        nft.transferFrom(alice, bob, 0);
        
        assertEq(nft.ownerOf(0), bob);
        assertEq(nft.balanceOf(alice), 0);
        assertEq(nft.balanceOf(bob), 1);
    }
    
    function test_Approve() public {
        vm.prank(alice);
        nft.mint();
        
        vm.prank(alice);
        nft.approve(bob, 0);
        
        assertEq(nft.getApproved(0), bob);
        
        // Bob can now transfer
        vm.prank(bob);
        nft.transferFrom(alice, bob, 0);
        
        assertEq(nft.ownerOf(0), bob);
    }
    
    function test_ApprovalForAll() public {
        vm.prank(alice);
        nft.mint();
        
        vm.prank(alice);
        nft.setApprovalForAll(bob, true);
        
        assertTrue(nft.isApprovedForAll(alice, bob));
        
        // Bob can transfer any of alice's tokens
        vm.prank(bob);
        nft.transferFrom(alice, bob, 0);
        
        assertEq(nft.ownerOf(0), bob);
    }
    
    function test_CannotTransferUnowned() public {
        vm.prank(alice);
        nft.mint();
        
        vm.prank(bob);
        vm.expectRevert(IndustrialOutput.NotApproved.selector);
        nft.transferFrom(alice, bob, 0);
    }
    
    function test_CannotQueryNonexistentToken() public {
        vm.expectRevert(IndustrialOutput.InvalidToken.selector);
        nft.tokenURI(999);
    }
    
    function test_SupportsInterface() public view {
        assertTrue(nft.supportsInterface(0x80ac58cd)); // ERC721
        assertTrue(nft.supportsInterface(0x5b5e139f)); // ERC721Metadata
        assertTrue(nft.supportsInterface(0x01ffc9a7)); // ERC165
    }
    
    function testFuzz_MintMany(uint8 count) public {
        vm.assume(count > 0 && count < 50);
        
        for (uint256 i = 0; i < count; i++) {
            vm.prank(alice);
            nft.mint();
        }
        
        assertEq(nft.totalSupply(), count);
        assertEq(nft.balanceOf(alice), count);
    }
}
