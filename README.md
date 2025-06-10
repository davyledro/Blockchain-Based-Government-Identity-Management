# Blockchain-Based Government Identity Management System

A comprehensive blockchain-based identity management system for government services, built on the Stacks blockchain using Clarity smart contracts.

## Overview

This system provides a secure, transparent, and privacy-focused approach to managing government identities and service access. It consists of five interconnected smart contracts that handle different aspects of identity management:

1. **Agency Verification Contract** - Validates and manages government agencies
2. **Citizen Identity Contract** - Manages citizen identities and basic information
3. **Service Access Contract** - Controls access to government services
4. **Identity Verification Contract** - Handles identity verification processes
5. **Privacy Protection Contract** - Manages privacy settings and data access permissions

## Features

### 🏛️ Agency Management
- Agency registration and verification
- Status management (pending, verified, suspended, revoked)
- Principal-to-agency mapping
- Verification by contract owner

### 👤 Citizen Identity
- Secure citizen registration with identity hashing
- Status management (active, suspended, inactive)
- Agency-verified registration process
- Principal-based identity mapping

### 🔐 Service Access Control
- Government service creation and management
- Verification level requirements
- Time-based access permissions
- Access granting and revocation

### ✅ Identity Verification
- Multiple verification types (identity, address, employment, income)
- Agency-approved verification process
- Expiration-based validity
- Status tracking (pending, verified, rejected, expired)

### 🛡️ Privacy Protection
- Granular privacy settings
- Data access permission management
- Access logging and audit trails
- Encryption requirements

## Smart Contract Architecture

\`\`\`
┌─────────────────────┐    ┌─────────────────────┐
│  Agency Verification │    │  Citizen Identity   │
│     Contract        │    │     Contract        │
└─────────┬───────────┘    └─────────┬───────────┘
│                          │
└──────────┬─────────────────┘
│
┌─────────────────────┐
│  Service Access     │
│     Contract        │
└─────────┬───────────┘
│
┌───────────────┼───────────────┐
│               │               │
┌───▼────────────┐  │  ┌───────────▼──┐
│ Identity       │  │  │ Privacy      │
│ Verification   │  │  │ Protection   │
│ Contract       │  │  │ Contract     │
└────────────────┘  │  └──────────────┘
│
┌─────▼─────┐
│   User    │
│Interface  │
└───────────┘
\`\`\`

## Installation

### Prerequisites
- Node.js (v16 or higher)
- Clarinet CLI
- Stacks Wallet

### Setup

1. Clone the repository:
   \`\`\`bash
   git clone <repository-url>
   cd blockchain-gov-identity
   \`\`\`

2. Install dependencies:
   \`\`\`bash
   npm install
   \`\`\`

3. Initialize Clarinet project:
   \`\`\`bash
   clarinet new gov-identity-system
   cd gov-identity-system
   \`\`\`

4. Copy contract files to the contracts directory:
   \`\`\`bash
   cp ../contracts/*.clar contracts/
   \`\`\`

## Usage

### Deploying Contracts

1. Deploy the contracts in the following order:
   \`\`\`bash
   clarinet deploy --testnet
   \`\`\`

2. Verify deployment:
   \`\`\`bash
   clarinet console
   \`\`\`

### Contract Interactions

#### Agency Registration
\`\`\`clarity
(contract-call? .agency-verification register-agency "Department of Motor Vehicles" "dmv@state.gov")
\`\`\`

#### Citizen Registration
\`\`\`clarity
(contract-call? .citizen-identity register-citizen 0x1234567890abcdef... u1)
\`\`\`

#### Service Creation
\`\`\`clarity
(contract-call? .service-access create-service "Driver License Renewal" "Online driver license renewal service" u2 u1)
\`\`\`

#### Identity Verification
\`\`\`clarity
(contract-call? .identity-verification submit-verification u1 u1 0xabcdef... u5000)
\`\`\`

#### Privacy Settings
\`\`\`clarity
(contract-call? .privacy-protection set-privacy-settings u1 u2 true true true)
\`\`\`

## Testing

Run the test suite:
\`\`\`bash
npm test
\`\`\`

Run specific test files:
\`\`\`bash
npm test -- agency-verification.test.js
npm test -- citizen-identity.test.js
npm test -- service-access.test.js
npm test -- identity-verification.test.js
npm test -- privacy-protection.test.js
\`\`\`

## Security Considerations

### Access Control
- Contract owner controls agency verification
- Citizens control their own data and privacy settings
- Agencies can only access data with proper permissions

### Data Protection
- Identity data is hashed before storage
- Privacy settings control data sharing levels
- Access logging provides audit trails
- Encryption requirements can be enforced

### Verification Integrity
- Multi-level verification system
- Time-based expiration for verifications
- Agency-based approval process
- Status tracking for all verifications

## API Reference

### Agency Verification Contract

#### Public Functions
- \`register-agency(name, contact-info)\` - Register a new agency
- \`verify-agency(agency-id)\` - Verify an agency (owner only)
- \`update-agency-status(agency-id, status)\` - Update agency status

#### Read-Only Functions
- \`get-agency(agency-id)\` - Get agency information
- \`is-verified-agency(agency-id)\` - Check if agency is verified

### Citizen Identity Contract

#### Public Functions
- \`register-citizen(identity-hash, agency-id)\` - Register a new citizen
- \`update-citizen-status(citizen-id, status)\` - Update citizen status

#### Read-Only Functions
- \`get-citizen(citizen-id)\` - Get citizen information
- \`is-active-citizen(citizen-id)\` - Check if citizen is active

### Service Access Contract

#### Public Functions
- \`create-service(name, description, verification-level, agency-id)\` - Create a service
- \`grant-service-access(citizen-id, service-id, expiry-blocks, agency-id)\` - Grant access
- \`revoke-service-access(citizen-id, service-id)\` - Revoke access

#### Read-Only Functions
- \`get-service(service-id)\` - Get service information
- \`check-service-access(citizen-id, service-id)\` - Check access permission

### Identity Verification Contract

#### Public Functions
- \`submit-verification(citizen-id, type, data-hash, validity-blocks)\` - Submit verification
- \`approve-verification(verification-id, agency-id)\` - Approve verification
- \`reject-verification(verification-id, agency-id)\` - Reject verification

#### Read-Only Functions
- \`get-verification(verification-id)\` - Get verification details
- \`is-verification-valid(citizen-id, type)\` - Check verification validity

### Privacy Protection Contract

#### Public Functions
- \`set-privacy-settings(citizen-id, sharing-level, allow-agencies, allow-services, require-encryption)\` - Set privacy preferences
- \`grant-data-access(citizen-id, requester, access-level, validity-blocks, purpose)\` - Grant data access
- \`revoke-data-access(citizen-id, requester)\` - Revoke data access
- \`log-data-access(citizen-id, access-type, data-accessed)\` - Log access

#### Read-Only Functions
- \`get-privacy-settings(citizen-id)\` - Get privacy settings
- \`check-data-access-permission(citizen-id, requester)\` - Check access permission

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests for new functionality
5. Ensure all tests pass
6. Submit a pull request

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Support

For support and questions:
- Create an issue in the GitHub repository
- Contact the development team
- Check the documentation wiki

## Roadmap

### Phase 1 (Current)
- ✅ Core contract development
- ✅ Basic testing framework
- ✅ Documentation

### Phase 2 (Planned)
- [ ] Web interface development
- [ ] Advanced privacy features
- [ ] Integration with existing government systems
- [ ] Mobile application

### Phase 3 (Future)
- [ ] Cross-chain compatibility
- [ ] Advanced analytics
- [ ] AI-powered fraud detection
- [ ] International standards compliance
  \`\`\`

## Version History

### v1.0.0
- Initial release with core functionality
- Five main contracts implemented
- Basic testing suite
- Comprehensive documentation
