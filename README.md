# Algorithmic Stablecoin Engine

A professional, flat-structured implementation of a decentralized algorithmic stablecoin system. This repository demonstrates the "Seigniorage Shares" model, utilizing three distinct tokens to manage market supply and price stability.

## Architecture
* **Stable Token (Cash):** The asset pegged to 1.00 USD.
* **Share Token:** Captures the seigniorage (inflation) when the system expands.
* **Bond Token:** Used to contract supply when the price falls below the peg.

## Features
* **Epoch-Based Rebase:** Price checks and supply adjustments happen at fixed intervals (e.g., every 8 hours).
* **Treasury Logic:** Orchestrates the minting of new tokens or the issuance of bonds based on Oracle price data.
* **Incentivized Stabilization:** Provides a mechanism for users to arbitrage the peg while supporting the protocol's health.

## Mechanism
1. **Above Peg:** Treasury mints new Stable tokens and distributes them to Share holders.
2. **Below Peg:** Treasury allows users to burn Stable tokens in exchange for Bonds at a discount, reducing circulating supply.
3. **Recovery:** When the price returns above the peg, Bond holders are the first to be redeemed.

## Security
This is a highly complex economic primitive. It requires a robust Oracle integration (e.g., Chainlink) to prevent price manipulation attacks.
