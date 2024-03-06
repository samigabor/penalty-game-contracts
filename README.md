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


- communityToken: contract CommunityToken 0x37E7F7e81f3De777da0a30cB27660c66eAEC0e0B
- tokenTransferRequest: contract TokenTransferRequest 0x44E07b18647249550bf2597Dba37906f83FC05e7
- tokenPool: contract TokenPool 0xD2c29b02DcF91BC05736A4164940BeE8A3e06277
- communityRegistry: contract CommunityRegistry 0xE25CeC204eB0786D4840FaF336a04f92e2D89d59
- helperConfig: contract HelperConfig 0xC7f2Cf4845C6db0e1a1e91ED41Bcd0FcC1b0E141