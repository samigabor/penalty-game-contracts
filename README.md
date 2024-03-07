## Architecture

### CommunityToken
- contract inherits from ERC721
- at deploy time, the admin/owner address is provided (can be a multisig)
- provides functionalities for managing community memberships and tokens
- a community is created by deploying a new CommunityToken contract

- `CommunityRegistry` contract allows registering community contracts with their associated IDs.
- `TokenTransferRequest` contract handles transfer requests between members.
- `TokenPool` contract allows burning tokens from a community.

## Security considerations

- all system is contraolled by the registry
- easy management of the registry using Ownable access control with easy migration to a role based access control
- the `safe` version of the methods is used for token management (mint & transfer). Ensures tokens will not get accidentally lost

## Deployed to Sepolia
Core contracts:
- address constant COMMUNITY_TOKEN_ADDRESS = [0x121fe9DA9be9fC948bF56F93F99c13ccb2cFE36d](https://sepolia.etherscan.io/address/0x121fe9DA9be9fC948bF56F93F99c13ccb2cFE36d#code);
- address constant COMMUNITY_REGISTRY_ADDRESS = [0xd359AA2364b1F3716dc1CC96bb2Fa4ef19bc97d4](https://sepolia.etherscan.io/address/0xd359AA2364b1F3716dc1CC96bb2Fa4ef19bc97d4#code);

Helper contracts:
- address constant TOKEN_POOL_ADDRESS = [0x4432C7E4972a84E20E1FB0D899e61287c522e2dB](https://sepolia.etherscan.io/address/0x4432C7E4972a84E20E1FB0D899e61287c522e2dB#code);
- address constant TRANSFER_REQUEST_TOKEN_ADDRESS = [0x29BC83517ba99dB62e44d4D2dB3BF60093b17110](https://sepolia.etherscan.io/address/0x29BC83517ba99dB62e44d4D2dB3BF60093b17110#code);
- address constant HELPER_CONFIG_ADDRESS = [0xC7f2Cf4845C6db0e1a1e91ED41Bcd0FcC1b0E141](https://sepolia.etherscan.io/address/0xC7f2Cf4845C6db0e1a1e91ED41Bcd0FcC1b0E141#code);

Registry owner:
- address constant ADMIN_ADDRESS = `0xf13e5F8933976bfdaA31efdB10c93BE23525Ddc3`;
