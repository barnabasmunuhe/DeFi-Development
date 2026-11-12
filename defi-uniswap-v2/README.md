# DeFi Uniswap V2 ⚡

An engineering study of Uniswap V2, covering its AMM architecture, core and periphery contracts, mathematical foundations, smart contract implementation, and security properties.

This project combines official protocol source-code analysis, Cyfrin Updraft course exercises, independent implementations, technical documentation, and Foundry testing.

## 🎯 Objectives

- Understand the constant-product AMM model.
- Analyze Uniswap V2 Core and Periphery architecture.
- Study production-grade Solidity implementations.
- Reproduce protocol mechanics through independent implementations.
- Complete practical smart contract exercises.
- Test protocol behavior, edge cases, and security assumptions.
- Build the foundation for advanced AMM engineering.

## 🏗️ Architecture

### 1. Protocol Source Code

Official Uniswap repositories maintained as Git submodules.

| Component | Repository | Responsibility |
|---|---|---|
| V2 Core | [Uniswap/v2-core](https://github.com/Uniswap/v2-core) | Factory, Pair, LP accounting, swaps |
| V2 Periphery | [Uniswap/v2-periphery](https://github.com/Uniswap/v2-periphery) | Router, libraries, interfaces |

### 2. Foundry Development

My independent engineering workspace containing:

- Instructor-provided exercises
- Exercise solutions
- Personal implementations
- Unit and integration tests
- Fuzz and invariant tests
- Deployment scripts

## 📚 Core Study Areas

### AMM Fundamentals
- Constant-product invariant: x × y = k
- Liquidity pools
- Liquidity providers
- LP tokens
- Token reserves
- Price discovery
- Slippage
- Swap fees
- Impermanent loss

### Core Architecture
- UniswapV2Factory
- UniswapV2Pair
- Pair creation
- Pair initialization
- Mint and burn
- Swap execution
- Reserve accounting
- Protocol fees
- Flash swaps
- TWAP oracle mechanics

### Periphery Architecture
- UniswapV2Router01
- UniswapV2Router02
- UniswapV2Library
- Liquidity management
- Token swaps
- Multi-hop swaps
- Price calculations
- Slippage protection
- Deadline protection

### Security & Testing
- Reentrancy considerations
- Flash-swap callbacks
- Reserve manipulation
- Integer precision and rounding
- Fee accounting
- Invariant testing
- Fuzz testing
- Edge-case analysis

## 🧠 Engineering Approach

Understand → Analyze → Implement → Test → Integrate

## 🛠️ Technology Stack

- Solidity
- Foundry
- Forge
- Git / GitHub
- JavaScript / TypeScript
- Ethers.js / Viem

## 📈 Development Progress

| Area | Status |
|---|---|
| Protocol architecture | 🔄 Studying |
| Core contracts | 🔄 Studying |
| Periphery contracts | 🔄 Studying |
| Course exercises | 🔄 Ongoing |
| Independent implementations | ⏳ Planned |
| Technical documentation | 🔄 Ongoing |
| Advanced testing | ⏳ Planned |

## 🔐 Disclaimer

This is an educational and experimental engineering project. It is not production-ready financial infrastructure.

Official Uniswap source code retains its original licensing and attribution notices.

---

Building in public. Learning deeply. Engineering continuously.