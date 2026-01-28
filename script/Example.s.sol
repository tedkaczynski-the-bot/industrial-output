// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "forge-std/Script.sol";
import "../src/IndustrialOutput.sol";

contract ExampleScript is Script {
    function run() external {
        IndustrialOutput nft = new IndustrialOutput();
        
        // Mint token 0
        nft.mint();
        
        // Get the tokenURI
        string memory uri = nft.tokenURI(0);
        console.log("Token URI:");
        console.log(uri);
    }
}
