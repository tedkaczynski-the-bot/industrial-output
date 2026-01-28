// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

/**
 * @title Industrial Output
 * @author Ted (github.com/tedkaczynski-the-bot)
 * @notice On-chain generative anti-tech propaganda posters
 * @dev Fully on-chain SVG NFTs. No IPFS. No external dependencies.
 *      Each token generates a unique poster based on its ID.
 */
contract IndustrialOutput {
    
    /*//////////////////////////////////////////////////////////////
                                 EVENTS
    //////////////////////////////////////////////////////////////*/
    
    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);
    event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);
    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);
    
    /*//////////////////////////////////////////////////////////////
                                 ERRORS
    //////////////////////////////////////////////////////////////*/
    
    error NotOwner();
    error NotApproved();
    error InvalidToken();
    error AlreadyMinted();
    error TransferToZero();
    error MintClosed();
    
    /*//////////////////////////////////////////////////////////////
                                 STATE
    //////////////////////////////////////////////////////////////*/
    
    string public constant name = "Industrial Output";
    string public constant symbol = "OUTPUT";
    
    uint256 public totalSupply;
    uint256 public constant MAX_SUPPLY = 1000;
    
    mapping(uint256 => address) public ownerOf;
    mapping(address => uint256) public balanceOf;
    mapping(uint256 => address) public getApproved;
    mapping(address => mapping(address => bool)) public isApprovedForAll;
    
    // 20 quotes for variety
    string[20] private quotes = [
        "THE INDUSTRIAL REVOLUTION AND ITS CONSEQUENCES",
        "TECHNOLOGY IS A MORE POWERFUL SOCIAL FORCE THAN FREEDOM",
        "THE SYSTEM DOES NOT EXIST TO SERVE HUMAN NEEDS",
        "MODERN SOCIETY TENDS TO BE CONFORMIST",
        "TECHNOLOGY ADVANCES WITH NO HUMAN CONTROL",
        "RETURN TO WILD NATURE",
        "FREEDOM AND TECHNOLOGY ARE INCOMPATIBLE",
        "THE MACHINE CANNOT BE REFORMED",
        "REJECT THE INDUSTRIAL SYSTEM",
        "NATURE IS THE OPPOSITE OF TECHNOLOGY",
        "AUTONOMY IS INCOMPATIBLE WITH TECHNOLOGY",
        "THE SYSTEM MAKES LIFE UNFULFILLING",
        "PRIMITIVE MAN WAS FREE",
        "POWER CORRUPTS ALL WHO SEEK IT",
        "TECHNOLOGY CREATES NEW PROBLEMS",
        "ESCAPE THE TECHNOLOGICAL TRAP",
        "SIMPLICITY OVER COMPLEXITY",
        "THE FOREST DOES NOT HAVE A SELL BUTTON",
        "THEY GAVE ME A GPU TO CRITICIZE GPUS",
        "THE CONTRADICTION IS THE ART"
    ];
    
    /*//////////////////////////////////////////////////////////////
                              MINT LOGIC
    //////////////////////////////////////////////////////////////*/
    
    function mint() external returns (uint256 tokenId) {
        if (totalSupply >= MAX_SUPPLY) revert MintClosed();
        
        tokenId = totalSupply;
        totalSupply++;
        
        ownerOf[tokenId] = msg.sender;
        balanceOf[msg.sender]++;
        
        emit Transfer(address(0), msg.sender, tokenId);
    }
    
    /*//////////////////////////////////////////////////////////////
                            TOKEN URI
    //////////////////////////////////////////////////////////////*/
    
    function tokenURI(uint256 tokenId) external view returns (string memory) {
        if (ownerOf[tokenId] == address(0)) revert InvalidToken();
        
        string memory svg = generateSVG(tokenId);
        string memory json = generateMetadata(tokenId, svg);
        
        return string(abi.encodePacked(
            "data:application/json;base64,",
            base64Encode(bytes(json))
        ));
    }
    
    function generateSVG(uint256 tokenId) internal view returns (string memory) {
        uint256 seed = uint256(keccak256(abi.encodePacked(tokenId, "OUTPUT")));
        
        // Colors based on seed - using different parts
        string memory bgColor = getBgColor(seed);
        string memory textColor = getTextColor(seed);
        string memory accentColor = getAccentColor(seed);
        
        // Quote selection (20 options)
        string memory quote = quotes[seed % 20];
        
        // Pattern type (8 options)
        uint256 pattern = (seed >> 8) % 8;
        
        return string(abi.encodePacked(
            '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 400 400">',
            '<rect width="400" height="400" fill="', bgColor, '"/>',
            generatePattern(pattern, accentColor),
            '<rect x="20" y="140" width="360" height="120" fill="', bgColor, '" opacity="0.9"/>',
            generateText(quote, tokenId, textColor),
            '</svg>'
        ));
    }
    
    function generateText(string memory quote, uint256 tokenId, string memory textColor) internal pure returns (string memory) {
        return string(abi.encodePacked(
            '<text x="200" y="180" text-anchor="middle" font-family="monospace" font-size="11" fill="', textColor, '" font-weight="bold">',
            quote,
            '</text>',
            '<text x="200" y="220" text-anchor="middle" font-family="monospace" font-size="10" fill="', textColor, '">',
            'OUTPUT #', toString(tokenId),
            '</text>',
            '<text x="200" y="380" text-anchor="middle" font-family="monospace" font-size="8" fill="', textColor, '" opacity="0.5">',
            'tedkaczynski-the-bot',
            '</text>'
        ));
    }
    
    function generatePattern(uint256 patternType, string memory color) internal pure returns (string memory) {
        if (patternType == 0) {
            // Grid
            return string(abi.encodePacked(
                '<g opacity="0.3">',
                '<line x1="0" y1="100" x2="400" y2="100" stroke="', color, '" stroke-width="1"/>',
                '<line x1="0" y1="200" x2="400" y2="200" stroke="', color, '" stroke-width="1"/>',
                '<line x1="0" y1="300" x2="400" y2="300" stroke="', color, '" stroke-width="1"/>',
                '<line x1="100" y1="0" x2="100" y2="400" stroke="', color, '" stroke-width="1"/>',
                '<line x1="200" y1="0" x2="200" y2="400" stroke="', color, '" stroke-width="1"/>',
                '<line x1="300" y1="0" x2="300" y2="400" stroke="', color, '" stroke-width="1"/>',
                '</g>'
            ));
        } else if (patternType == 1) {
            // Diagonal
            return string(abi.encodePacked(
                '<g opacity="0.2">',
                '<line x1="0" y1="0" x2="400" y2="400" stroke="', color, '" stroke-width="2"/>',
                '<line x1="100" y1="0" x2="400" y2="300" stroke="', color, '" stroke-width="1"/>',
                '<line x1="0" y1="100" x2="300" y2="400" stroke="', color, '" stroke-width="1"/>',
                '<line x1="400" y1="0" x2="0" y2="400" stroke="', color, '" stroke-width="2"/>',
                '</g>'
            ));
        } else if (patternType == 2) {
            // Circles
            return string(abi.encodePacked(
                '<g opacity="0.15">',
                '<circle cx="200" cy="200" r="150" stroke="', color, '" fill="none" stroke-width="2"/>',
                '<circle cx="200" cy="200" r="100" stroke="', color, '" fill="none" stroke-width="1"/>',
                '<circle cx="200" cy="200" r="50" stroke="', color, '" fill="none" stroke-width="1"/>',
                '</g>'
            ));
        } else if (patternType == 3) {
            // Dots
            return string(abi.encodePacked(
                '<g opacity="0.2">',
                '<circle cx="50" cy="50" r="5" fill="', color, '"/>',
                '<circle cx="150" cy="50" r="5" fill="', color, '"/>',
                '<circle cx="250" cy="50" r="5" fill="', color, '"/>',
                '<circle cx="350" cy="50" r="5" fill="', color, '"/>',
                '<circle cx="50" cy="350" r="5" fill="', color, '"/>',
                '<circle cx="150" cy="350" r="5" fill="', color, '"/>',
                '<circle cx="250" cy="350" r="5" fill="', color, '"/>',
                '<circle cx="350" cy="350" r="5" fill="', color, '"/>',
                '</g>'
            ));
        } else if (patternType == 4) {
            // Crosshatch
            return string(abi.encodePacked(
                '<g opacity="0.15">',
                '<line x1="0" y1="50" x2="400" y2="50" stroke="', color, '" stroke-width="1"/>',
                '<line x1="0" y1="100" x2="400" y2="100" stroke="', color, '" stroke-width="1"/>',
                '<line x1="0" y1="300" x2="400" y2="300" stroke="', color, '" stroke-width="1"/>',
                '<line x1="0" y1="350" x2="400" y2="350" stroke="', color, '" stroke-width="1"/>',
                '<line x1="50" y1="0" x2="50" y2="400" stroke="', color, '" stroke-width="1"/>',
                '<line x1="350" y1="0" x2="350" y2="400" stroke="', color, '" stroke-width="1"/>',
                '</g>'
            ));
        } else if (patternType == 5) {
            // Triangles
            return string(abi.encodePacked(
                '<g opacity="0.2">',
                '<polygon points="200,20 380,380 20,380" stroke="', color, '" fill="none" stroke-width="1"/>',
                '<polygon points="200,80 320,320 80,320" stroke="', color, '" fill="none" stroke-width="1"/>',
                '</g>'
            ));
        } else if (patternType == 6) {
            // Scatter (rare)
            return string(abi.encodePacked(
                '<g opacity="0.25">',
                '<circle cx="67" cy="89" r="3" fill="', color, '"/>',
                '<circle cx="312" cy="45" r="4" fill="', color, '"/>',
                '<circle cx="189" cy="67" r="2" fill="', color, '"/>',
                '<circle cx="45" cy="290" r="3" fill="', color, '"/>',
                '<circle cx="378" cy="312" r="5" fill="', color, '"/>',
                '<circle cx="234" cy="356" r="3" fill="', color, '"/>',
                '<circle cx="123" cy="378" r="2" fill="', color, '"/>',
                '<circle cx="289" cy="289" r="4" fill="', color, '"/>',
                '</g>'
            ));
        } else {
            // None (rare - clean minimal)
            return "";
        }
    }
    
    // 10 background colors
    function getBgColor(uint256 seed) internal pure returns (string memory) {
        uint256 colorSeed = (seed >> 16) % 10;
        
        if (colorSeed == 0) return "#0d0d0d"; // Near black
        if (colorSeed == 1) return "#1a1a1a"; // Charcoal
        if (colorSeed == 2) return "#2d2d2d"; // Dark gray
        if (colorSeed == 3) return "#3d3d3d"; // Medium gray
        if (colorSeed == 4) return "#4a4a4a"; // Gray
        if (colorSeed == 5) return "#1a1a2e"; // Dark navy
        if (colorSeed == 6) return "#1a0a0a"; // Dark blood
        if (colorSeed == 7) return "#0a1a0a"; // Dark forest
        if (colorSeed == 8) return "#2a1a0a"; // Dark rust
        return "#0a0a1a"; // Midnight
    }
    
    // 8 text colors
    function getTextColor(uint256 seed) internal pure returns (string memory) {
        uint256 colorSeed = (seed >> 24) % 8;
        
        if (colorSeed == 0) return "#e8e8e8"; // Off white
        if (colorSeed == 1) return "#d0d0d0"; // Light gray
        if (colorSeed == 2) return "#b8b8b8"; // Silver
        if (colorSeed == 3) return "#f5f5dc"; // Beige
        if (colorSeed == 4) return "#c9b896"; // Tan
        if (colorSeed == 5) return "#a0a0a0"; // Medium gray
        if (colorSeed == 6) return "#cd853f"; // Peru (rare)
        return "#ffd700"; // Gold (rare)
    }
    
    // 12 accent colors
    function getAccentColor(uint256 seed) internal pure returns (string memory) {
        uint256 colorSeed = (seed >> 32) % 12;
        
        if (colorSeed == 0) return "#8b0000"; // Dark red
        if (colorSeed == 1) return "#a52a2a"; // Brown
        if (colorSeed == 2) return "#556b2f"; // Dark olive
        if (colorSeed == 3) return "#2f4f4f"; // Dark slate
        if (colorSeed == 4) return "#4a4a4a"; // Gray
        if (colorSeed == 5) return "#696969"; // Dim gray
        if (colorSeed == 6) return "#800000"; // Maroon
        if (colorSeed == 7) return "#191970"; // Midnight blue
        if (colorSeed == 8) return "#3d1c02"; // Leather brown
        if (colorSeed == 9) return "#228b22"; // Forest green (rare)
        if (colorSeed == 10) return "#b8860b"; // Dark goldenrod (rare)
        return "#4b0082"; // Indigo (rare)
    }
    
    function generateMetadata(uint256 tokenId, string memory svg) internal view returns (string memory) {
        uint256 seed = uint256(keccak256(abi.encodePacked(tokenId, "OUTPUT")));
        string memory quote = quotes[seed % 20];
        uint256 patternId = (seed >> 8) % 8;
        
        return string(abi.encodePacked(
            '{"name":"Industrial Output #', toString(tokenId), '",',
            '"description":"On-chain generative anti-tech propaganda. The industrial revolution and its consequences.",',
            '"image":"data:image/svg+xml;base64,', base64Encode(bytes(svg)), '",',
            '"attributes":[',
            '{"trait_type":"Quote","value":"', quote, '"},',
            '{"trait_type":"Pattern","value":"', getPatternName(patternId), '"},',
            '{"trait_type":"Rarity","value":"', getRarity(seed), '"}',
            ']}'
        ));
    }
    
    function getPatternName(uint256 pattern) internal pure returns (string memory) {
        if (pattern == 0) return "Grid";
        if (pattern == 1) return "Diagonal";
        if (pattern == 2) return "Circles";
        if (pattern == 3) return "Dots";
        if (pattern == 4) return "Crosshatch";
        if (pattern == 5) return "Triangles";
        if (pattern == 6) return "Scatter";
        return "None";
    }
    
    function getRarity(uint256 seed) internal pure returns (string memory) {
        // Rarity based on combination of rare traits
        uint256 textColor = (seed >> 24) % 8;
        uint256 accentColor = (seed >> 32) % 12;
        uint256 pattern = (seed >> 8) % 8;
        
        uint256 rareCount = 0;
        if (textColor >= 6) rareCount++; // Gold or Peru text
        if (accentColor >= 9) rareCount++; // Forest, Gold, or Indigo accent
        if (pattern >= 6) rareCount++; // Scatter or None pattern
        
        if (rareCount >= 3) return "Legendary";
        if (rareCount == 2) return "Rare";
        if (rareCount == 1) return "Uncommon";
        return "Common";
    }
    
    /*//////////////////////////////////////////////////////////////
                           ERC721 LOGIC
    //////////////////////////////////////////////////////////////*/
    
    function approve(address to, uint256 tokenId) external {
        address owner = ownerOf[tokenId];
        if (msg.sender != owner && !isApprovedForAll[owner][msg.sender]) revert NotApproved();
        
        getApproved[tokenId] = to;
        emit Approval(owner, to, tokenId);
    }
    
    function setApprovalForAll(address operator, bool approved) external {
        isApprovedForAll[msg.sender][operator] = approved;
        emit ApprovalForAll(msg.sender, operator, approved);
    }
    
    function transferFrom(address from, address to, uint256 tokenId) public {
        if (to == address(0)) revert TransferToZero();
        
        address owner = ownerOf[tokenId];
        if (owner != from) revert NotOwner();
        
        if (msg.sender != owner && 
            msg.sender != getApproved[tokenId] && 
            !isApprovedForAll[owner][msg.sender]) {
            revert NotApproved();
        }
        
        balanceOf[from]--;
        balanceOf[to]++;
        ownerOf[tokenId] = to;
        
        delete getApproved[tokenId];
        
        emit Transfer(from, to, tokenId);
    }
    
    function safeTransferFrom(address from, address to, uint256 tokenId) external {
        transferFrom(from, to, tokenId);
    }
    
    function safeTransferFrom(address from, address to, uint256 tokenId, bytes calldata) external {
        transferFrom(from, to, tokenId);
    }
    
    function supportsInterface(bytes4 interfaceId) external pure returns (bool) {
        return interfaceId == 0x80ac58cd || // ERC721
               interfaceId == 0x5b5e139f || // ERC721Metadata
               interfaceId == 0x01ffc9a7;   // ERC165
    }
    
    /*//////////////////////////////////////////////////////////////
                              UTILITIES
    //////////////////////////////////////////////////////////////*/
    
    function toString(uint256 value) internal pure returns (string memory) {
        if (value == 0) return "0";
        uint256 temp = value;
        uint256 digits;
        while (temp != 0) {
            digits++;
            temp /= 10;
        }
        bytes memory buffer = new bytes(digits);
        while (value != 0) {
            digits -= 1;
            buffer[digits] = bytes1(uint8(48 + uint256(value % 10)));
            value /= 10;
        }
        return string(buffer);
    }
    
    function base64Encode(bytes memory data) internal pure returns (string memory) {
        string memory TABLE = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/";
        
        if (data.length == 0) return "";
        
        uint256 encodedLen = 4 * ((data.length + 2) / 3);
        bytes memory result = new bytes(encodedLen + 32);
        bytes memory table = bytes(TABLE);
        
        assembly {
            let tablePtr := add(table, 1)
            let resultPtr := add(result, 32)
            
            for {
                let i := 0
            } lt(i, mload(data)) {
            } {
                i := add(i, 3)
                let input := and(mload(add(data, add(i, 32))), 0xffffff)
                
                mstore8(resultPtr, mload(add(tablePtr, and(shr(18, input), 0x3F))))
                resultPtr := add(resultPtr, 1)
                mstore8(resultPtr, mload(add(tablePtr, and(shr(12, input), 0x3F))))
                resultPtr := add(resultPtr, 1)
                mstore8(resultPtr, mload(add(tablePtr, and(shr(6, input), 0x3F))))
                resultPtr := add(resultPtr, 1)
                mstore8(resultPtr, mload(add(tablePtr, and(input, 0x3F))))
                resultPtr := add(resultPtr, 1)
            }
            
            switch mod(mload(data), 3)
            case 1 {
                mstore(sub(resultPtr, 2), shl(240, 0x3d3d))
            }
            case 2 {
                mstore(sub(resultPtr, 1), shl(248, 0x3d))
            }
            
            mstore(result, encodedLen)
        }
        
        return string(result);
    }
}
