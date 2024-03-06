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
- address constant ADMIN_ADDRESS = 0xf13e5F8933976bfdaA31efdB10c93BE23525Ddc3;
- address constant COMMUNITY_TOKEN_ADDRESS = [0xbCbA2AeEAC9FD0506F8E2B6D951C1E870CC447c8](https://sepolia.etherscan.io/address/0xbCbA2AeEAC9FD0506F8E2B6D951C1E870CC447c8#code);
- address constant TOKEN_POOL_ADDRESS = [0x3e488DC02DD6E8B6e6Ff3D2Acf6506Bf3a58bB02](https://sepolia.etherscan.io/address/0x3e488DC02DD6E8B6e6Ff3D2Acf6506Bf3a58bB02#code);
- address constant COMMUNITY_REGISTRY_ADDRESS = [0xDC98a83A93895999d9Ce6336932Ef99fE6a87038](https://sepolia.etherscan.io/address/0xDC98a83A93895999d9Ce6336932Ef99fE6a87038#code);
- address constant TRANSFER_REQUEST_TOKEN_ADDRESS = [0xE2BaDfc491fe719ae905d39FfC36DA2D20b495d6](https://sepolia.etherscan.io/address/0xE2BaDfc491fe719ae905d39FfC36DA2D20b495d6#code);
- address constant HELPER_CONFIG_ADDRESS = [0xC7f2Cf4845C6db0e1a1e91ED41Bcd0FcC1b0E141](https://sepolia.etherscan.io/address/0xC7f2Cf4845C6db0e1a1e91ED41Bcd0FcC1b0E141#code);
