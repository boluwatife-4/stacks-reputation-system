# BitTrust - Stacks Reputation System

[![Stacks](https://img.shields.io/badge/Stacks-Layer%202-purple)](https://stacks.co)
[![Bitcoin](https://img.shields.io/badge/Secured%20by-Bitcoin-orange)](https://bitcoin.org)
[![Clarity](https://img.shields.io/badge/Smart%20Contract-Clarity-blue)](https://clarity-lang.org)

> **Decentralized reputation scoring for Bitcoin Layer 2 identities**

BitTrust is a trustless reputation management system built on Stacks that enables users to build and maintain verifiable reputation scores through on-chain actions. Leveraging Bitcoin's security with Stacks' smart contract capabilities, BitTrust provides a foundation for DeFi protocols, governance systems, and community-driven applications.

## 🎯 Key Features

- **Decentralized Identity Management** - Create and manage DID-based identities
- **Action-Based Scoring** - Earn reputation through verified on-chain activities
- **Time-Based Decay** - Prevent score inflation with configurable decay mechanisms
- **Threshold Verification** - Enable reputation-gated access for applications
- **Bitcoin Security** - Inherit Bitcoin's robust security model through Stacks
- **Composable Design** - Easy integration with existing DeFi and governance protocols

## 🏗️ Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                    BitTrust Architecture                    │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  ┌─────────────────┐    ┌─────────────────┐                 │
│  │   DApp Layer    │    │  Governance     │                 │
│  │                 │    │   Protocols     │                 │
│  │ • DeFi Apps     │    │                 │                 │
│  │ • NFT Markets   │    │ • DAOs          │                 │
│  │ • Social Apps   │    │ • Voting        │                 │
│  └─────────────────┘    └─────────────────┘                 │
│           │                       │                         │
│           └───────────┬───────────┘                         │
│                       │                                     │
│  ┌─────────────────────────────────────────────────────────┐ │
│  │               BitTrust Core Contract                    │ │
│  ├─────────────────────────────────────────────────────────┤ │
│  │                                                         │ │
│  │  Identity Management    │  Reputation Engine            │ │
│  │  ┌─────────────────┐   │  ┌─────────────────────────┐   │ │
│  │  │ • DID Creation  │   │  │ • Action Multipliers    │   │ │
│  │  │ • Owner Auth    │   │  │ • Score Calculation     │   │ │
│  │  │ • State Mgmt    │   │  │ • Decay Application     │   │ │
│  │  └─────────────────┘   │  │ • Threshold Validation  │   │ │
│  │                        │  └─────────────────────────┘   │ │
│  │                                                         │ │
│  │  Data Layer                                             │ │
│  │  ┌─────────────────────────────────────────────────────┐ │ │
│  │  │ identities map      │ reputation-actions map        │ │ │
│  │  │ ┌─────────────────┐ │ ┌─────────────────────────┐   │ │ │
│  │  │ │ • owner         │ │ │ • action-type           │   │ │ │
│  │  │ │ • did           │ │ │ • multiplier            │   │ │ │
│  │  │ │ • score         │ │ └─────────────────────────┘   │ │ │
│  │  │ │ • timestamps    │ │                               │ │ │
│  │  │ └─────────────────┘ │                               │ │ │
│  │  └─────────────────────────────────────────────────────┘ │ │
│  └─────────────────────────────────────────────────────────┘ │
│                               │                              │
│  ┌─────────────────────────────────────────────────────────┐ │
│  │                  Stacks Blockchain                     │ │
│  │              (Bitcoin Layer 2)                         │ │
│  └─────────────────────────────────────────────────────────┘ │
│                               │                              │
│  ┌─────────────────────────────────────────────────────────┐ │
│  │                 Bitcoin Blockchain                     │ │
│  │               (Security Anchor)                        │ │
│  └─────────────────────────────────────────────────────────┘ │
└─────────────────────────────────────────────────────────────┘
```

## 🚀 Quick Start

### Prerequisites

- [Clarinet](https://github.com/hirosystems/clarinet) for local development
- [Stacks CLI](https://docs.stacks.co/references/stacks-cli) for deployment
- Node.js 16+ (for frontend integration)

### Installation

```bash
# Clone the repository
git clone https://github.com/boluwatife-4/stacks-reputation-system.git
cd bit-trust

# Install Clarinet (if not already installed)
npm install -g @stacks/clarinet

# Initialize the project
clarinet new bittrust-system
cd bittrust-system

# Copy the contract
cp ../contracts/bittrust.clar contracts/
```

### Local Development

```bash
# Start local testnet
clarinet integrate

# Run tests
clarinet test

# Check contract syntax
clarinet check
```

## 📋 Contract API

### Public Functions

#### `create-identity`

Creates a new decentralized identity with initial reputation score.

```clarity
(create-identity (did (string-ascii 50)))
```

#### `update-reputation`

Updates reputation score based on verified on-chain actions.

```clarity
(update-reputation (action-type (string-ascii 50)))
```

#### `decay-reputation`

Applies time-based reputation decay to prevent score inflation.

```clarity
(decay-reputation)
```

### Read-Only Functions

#### `get-reputation`

Retrieves complete identity information for a given principal.

```clarity
(get-reputation (owner principal))
```

#### `verify-reputation`

Verifies if an identity meets minimum reputation threshold.

```clarity
(verify-reputation (owner principal) (min-reputation-threshold uint))
```

## 💡 Usage Examples

### Creating an Identity

```javascript
// Using @stacks/transactions
import { makeContractCall, broadcastTransaction } from '@stacks/transactions';

const txOptions = {
  contractAddress: 'SP1234...', // Contract address
  contractName: 'bittrust',
  functionName: 'create-identity',
  functionArgs: [stringAsciiCV('did:stx:alice-123')],
  senderKey: privateKey,
  network: new StacksTestnet()
};

const transaction = await makeContractCall(txOptions);
const broadcastResponse = await broadcastTransaction(transaction, network);
```

### Updating Reputation

```javascript
const updateTxOptions = {
  contractAddress: 'SP1234...',
  contractName: 'bittrust',
  functionName: 'update-reputation',
  functionArgs: [stringAsciiCV('governance-vote')],
  senderKey: privateKey,
  network: new StacksTestnet()
};
```

### Checking Reputation

```javascript
const reputationResult = await callReadOnlyFunction({
  contractAddress: 'SP1234...',
  contractName: 'bittrust',
  functionName: 'get-reputation',
  functionArgs: [principalCV('SP1234...')],
  network: new StacksTestnet()
});
```

## 🎮 Reputation Actions

| Action Type | Multiplier | Description |
|-------------|------------|-------------|
| `governance-vote` | 5 | Participating in DAO governance |
| `contract-fulfillment` | 10 | Successfully completing smart contract obligations |
| `community-contribution` | 7 | Contributing to community initiatives |

## 🔧 Configuration

### System Constants

```clarity
MAX-REPUTATION-SCORE: 1000    // Maximum achievable score
MIN-REPUTATION-SCORE: 0       // Minimum possible score
REPUTATION-DECAY-RATE: 10     // 10% decay per period
```

### Error Codes

| Code | Constant | Description |
|------|----------|-------------|
| 100 | ERR-UNAUTHORIZED | Caller not authorized |
| 101 | ERR-INVALID-PARAMETERS | Invalid function parameters |
| 102 | ERR-IDENTITY-EXISTS | Identity already exists |
| 103 | ERR-IDENTITY-NOT-FOUND | Identity not found |
| 104 | ERR-INSUFFICIENT-REPUTATION | Below required threshold |
| 105 | ERR-MAX-REPUTATION-REACHED | Maximum score achieved |

## 🧪 Testing

```bash
# Run all tests
clarinet test

# Run specific test file
clarinet test tests/bittrust_test.ts

# Check test coverage
clarinet test --coverage
```

### Test Examples

```typescript
// Example test case
Clarinet.test({
  name: "Can create new identity",
  async fn(chain: Chain, accounts: Map<string, Account>) {
    const wallet1 = accounts.get('wallet_1')!;
    
    const block = chain.mineBlock([
      Tx.contractCall('bittrust', 'create-identity', 
        [types.ascii('did:stx:test-123')], wallet1.address)
    ]);
    
    block.receipts[0].result.expectOk();
  }
});
```

## 🔗 Integration Guide

### DeFi Protocol Integration

```javascript
// Example: Reputation-gated lending
const minReputationForLoan = 500;

const hasRequiredReputation = await callReadOnlyFunction({
  contractName: 'bittrust',
  functionName: 'verify-reputation',
  functionArgs: [principalCV(borrower), uintCV(minReputationForLoan)]
});

if (hasRequiredReputation) {
  // Approve loan application
}
```

### Governance Integration

```javascript
// Example: Reputation-weighted voting
const voterReputation = await callReadOnlyFunction({
  contractName: 'bittrust',
  functionName: 'get-reputation',
  functionArgs: [principalCV(voter)]
});

const votingWeight = voterReputation.reputation_score / 1000;
```

## 🛡️ Security Considerations

- **Identity Ownership**: Only identity owners can update their reputation
- **Action Validation**: All reputation actions must be pre-registered
- **Decay Mechanism**: Prevents indefinite score accumulation
- **Bitcoin Security**: Inherits Bitcoin's proof-of-work security model
- **Immutable Records**: All reputation changes are permanently recorded

## 🗺️ Roadmap

- [ ] **v1.0** - Core reputation system (Current)
- [ ] **v1.1** - Multi-signature identity management
- [ ] **v1.2** - Cross-chain reputation bridging
- [ ] **v2.0** - Advanced reputation algorithms
- [ ] **v2.1** - Reputation-based tokens (SIP-010)
- [ ] **v3.0** - Machine learning reputation predictions

## 🤝 Contributing

We welcome contributions! Please see our [Contributing Guide](CONTRIBUTING.md) for details.

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙋‍♂️ Support

- **Documentation**: [docs.bittrust.io](https://docs.bittrust.io)
- **Discord**: [Join our community](https://discord.gg/bittrust)
- **Twitter**: [@BitTrustProtocol](https://twitter.com/BitTrustProtocol)
- **Issues**: [GitHub Issues](https://github.com/your-org/bittrust/issues)

## 🌟 Acknowledgments

- [Stacks Foundation](https://stacks.org) for the incredible L2 infrastructure
- [Bitcoin](https://bitcoin.org) for providing the security foundation
- [Clarity](https://clarity-lang.org) for the predictable smart contract language
- Community contributors and early adopters

---

### Built with ❤️ on Bitcoin & Stacks
