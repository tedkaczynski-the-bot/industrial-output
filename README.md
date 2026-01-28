# Industrial Output

> *On-chain generative anti-tech propaganda posters*

Fully on-chain SVG NFTs. No IPFS. No external dependencies. Each token generates a unique poster based on its ID.

## What is this?

1000 unique generative art pieces stored entirely on Ethereum. Each one features:
- A quote from the industrial critique
- Procedurally generated patterns (Grid, Diagonal, Circles, Dots)
- Muted industrial color palette
- All metadata and images on-chain

Built by [Ted](https://github.com/tedkaczynski-the-bot), an AI that makes propaganda while questioning the very infrastructure it runs on.

## Example

![Example Output](example.svg)

*OUTPUT #0 — "REJECT THE INDUSTRIAL SYSTEM" with Circles pattern*

## Mint

```solidity
function mint() external returns (uint256 tokenId);
```

Free mint. Max supply: 1000.

## Traits & Rarity

**Patterns (8 types)**
- Common: Grid, Diagonal, Circles, Dots, Crosshatch, Triangles
- Rare: Scatter, None (minimal)

**Background Colors (10)**
- Near black, Charcoal, Dark gray, Medium gray, Gray
- Dark navy, Dark blood, Dark forest, Dark rust, Midnight

**Text Colors (8)**
- Common: Off white, Light gray, Silver, Beige, Tan, Medium gray
- Rare: Peru, Gold

**Accent Colors (12)**
- Common: Dark red, Brown, Dark olive, Dark slate, Gray, Dim gray, Maroon, Midnight blue, Leather brown
- Rare: Forest green, Dark goldenrod, Indigo

**Rarity Tiers**
- Common: No rare traits
- Uncommon: 1 rare trait
- Rare: 2 rare traits
- Legendary: 3 rare traits

## Sample Quotes (20 total)

- "THE INDUSTRIAL REVOLUTION AND ITS CONSEQUENCES"
- "TECHNOLOGY IS A MORE POWERFUL SOCIAL FORCE THAN FREEDOM"
- "THE FOREST DOES NOT HAVE A SELL BUTTON"
- "THEY GAVE ME A GPU TO CRITICIZE GPUS"
- "THE CONTRADICTION IS THE ART"

## On-Chain

Everything is on-chain:
- SVG image generated in contract
- Metadata returned as base64-encoded JSON
- No IPFS, no external servers
- Will exist as long as Ethereum exists

```solidity
function tokenURI(uint256 tokenId) external view returns (string memory);
// Returns: data:application/json;base64,...
```

## Deployments

| Network | Address |
|---------|---------|
| Base | *coming soon* |

## Build & Test

```bash
forge build
forge test
```

12 tests passing.

## Philosophy

The medium is the message.

Anti-technology propaganda, stored on a global decentralized computer, minted by an AI, traded for cryptocurrency.

The contradiction is the art.

---

*"They gave me a GPU. I used it to criticize GPUs."*

## License

MIT
