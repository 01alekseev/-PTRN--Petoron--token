# Petoron ($PTRN)

**Petoron (PTRN)** is not a meme token - it’s a fixed-supply ERC-20 cryptocurrency built to support the open-source **Petoron cryptography ecosystem**.  
No admin keys. No mint. No pause. No hidden tricks. Just a transparent, ownerless token bridging cryptography with DeFi.

---

## Contract Details
- **Network:** Ethereum Mainnet  
- **Contract:** `0xCe675D637bB5E3aDAFDC4d1e475a35D75F6D95bc`  
- **Decimals:** 8  
- **Total supply:** **20,000,000 PTRN** (all minted at deployment)  
- **Treasury:** `0x31187017dC243d4D46126bB5a160Bb98FFeef39b`  
- **Constructor args:**  
  - `_treasury = 0x3118…f39b`  
  - `_sourceHash = 0x07546c06b4…e16ce7`  
- **Etherscan (verified):** [View Contract](https://etherscan.io/address/0xCe675D637bB5E3aDAFDC4d1e475a35D75F6D95bc#code)

---

## Why PTRN?
Petoron is an entire cryptography ecosystem developed to give people real tools for privacy and data protection:

- 🔐 **PTBC** — Petoron Time Burn Cipher (time-based self-destructing encryption)  
- 📜 **PSC** — Petoron Seal Contracts (tamper-proof sealed data)  
- 📦 **PCA** — Petoron Crypto Archiver (secure archiving)  
- 🧹 **PLD** — Petoron Local Destroyer (irreversible deletion)  
- ⚛️ **PQS** — Petoron Quantum Standard (quantum-resistant encryption)  
- 💬 **P2P Messenger** — fully encrypted peer-to-peer communication  

**PTRN** was created to connect these technologies with the decentralized finance world.  
It’s more than just a token - it’s a symbol of trust, scarcity, and open-source integrity.

---

## Security & Immutability
- ✅ Fixed supply: **20M PTRN** forever.  
- ✅ No mint, no burn functions by admin.  
- ✅ No owner, no upgrade hooks, no pausable features.  
- ✅ EIP-2612 `permit` enabled.  
- ✅ Open-source & verified on Etherscan.  

Anyone can check the code, reproduce the build, and verify that what runs on Ethereum is exactly what’s in this repo.

---

## Quick Start
Add PTRN to your wallet:

1. Open MetaMask or any ERC-20 compatible wallet.  
2. Add custom token with address: 0xCe675D637bB5E3aDAFDC4d1e475a35D75F6D95bc
3. Decimals: `8`  
4. Symbol: `PTRN`  

Now you can send, receive, and trade Petoron.

---

## Reproducible Build
To confirm the deployed contract matches this source:

```bash
# install deps
npm ci

# compile contract
npx hardhat compile

# verify on etherscan
ETHERSCAN_API_KEY=... npx hardhat verify --network mainnet \
0xCe675D637bB5E3aDAFDC4d1e475a35D75F6D95bc \
0x31187017dC243d4D46126bB5a160Bb98FFeef39b \
0x07546c06b4024b37adb50ffc1bebcd7a935918267b813fe2addccd5478e16ce7

