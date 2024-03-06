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


- communityToken: contract CommunityToken 0x2F6DF87018866202dE3599608efd145452dF7326
- tokenTransferRequest: contract TokenTransferRequest 0x3A5dB93Ee681009157a194D81204dA653E4136cC
- tokenPool: contract TokenPool 0xD1cb28091EE8103B2f6224a210d54B1cBC4d0f64
- communityRegistry: contract CommunityRegistry 0x9A60682f3CEf4Db3c5a3c17eB1FD970dB545490A
- helperConfig: contract HelperConfig 0xC7f2Cf4845C6db0e1a1e91ED41Bcd0FcC1b0E141