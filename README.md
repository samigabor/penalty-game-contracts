# Penalty Game

## Architecture

- [CommunityToken](https://sepolia.etherscan.io/address/0xDd88659C8d77b092cd6B68459A86f33F123E2B47#code) contract allows members to transfer their tokens to other members or the pool contract for burning.
- [CommunityRegistry](https://sepolia.etherscan.io/address/0xc9bE2366fB425F7C1371008Ef9AD773C9AD103F2#code) contract allows admins to create and managinge communities.
- [TokenPool](https://sepolia.etherscan.io/address/0xBC1dba2a6fE6eE4Ba6A886fc1BBeC09a19963cf5#code) contract allows burning tokens from a community
- `TransferRequestToken` is a helper contract for the Community Token contract.

## Etherscan interaction:

Admins will manage the communities through the Community Registry contract deployed on Sepolia at [0xc9bE2366fB425F7C1371008Ef9AD773C9AD103F2](https://sepolia.etherscan.io/address/0xc9bE2366fB425F7C1371008Ef9AD773C9AD103F2#code). 

First step would be to create a community `deployCommunityContract(<name>, <symbol>)`, and the following actions are possible:
- view deployed communities: `communities[<index>]`
- view deployed communitites by admin: `communitiesByAdmin[<adminAddress>][<index>]`
- add members to a community: `mintTokenToMember(<communityAddress>, <memberAddress>)`
- check if a member is part of a community: `isInCommunity(<memberAddress>, <communityAddress>)`
- remove a member from a community: `removeMemberFromCommunity(<memberAddress>, <communityAddress>)`
- burn tokens transferred to the [TokenPool](https://sepolia.etherscan.io/address/0xBC1dba2a6fE6eE4Ba6A886fc1BBeC09a19963cf5#code) contract: `burnCommunityToken(<communityAddress>, <tokenId>)`

Members can interact directly with the CommunityToken contract deployed on Sepolia at [0xDd88659C8d77b092cd6B68459A86f33F123E2B47](https://sepolia.etherscan.io/address/0xDd88659C8d77b092cd6B68459A86f33F123E2B47#code). Here are the actions a member can take:
- initiate a transfer request: `initiateTransferRequest(<toAddress>, <tokenId>)`
- approve transfer requests for other members in the community: `approveTransferRequest(<tokenId>)`
- complete transfer requests (must be approved by another member in the community): `completeTransferRequest(<tokenId>)`
- members can also transfer their tokens to the [TokenPool](https://sepolia.etherscan.io/address/0xBC1dba2a6fE6eE4Ba6A886fc1BBeC09a19963cf5#code) contract, from where they can be burned by the community admin.

## Security considerations

- all system is contraolled by the registry
- easy management of the registry using Ownable access control with easy migration to a role based access control
- the `safe` version of the methods is used for token management (mint & transfer). Ensures tokens will not get accidentally lost


communityToken: contract CommunityToken 0xDd88659C8d77b092cd6B68459A86f33F123E2B47
tokenTransferRequest: contract TokenTransferRequest 0x77Dcd2922138F77cc53B7296c86f297B9CC07F83
tokenPool: contract TokenPool 0xBC1dba2a6fE6eE4Ba6A886fc1BBeC09a19963cf5
communityRegistry: contract CommunityRegistry 0xc9bE2366fB425F7C1371008Ef9AD773C9AD103F2
helperConfig: contract HelperConfig 0xC7f2Cf4845C6db0e1a1e91ED41Bcd0FcC1b0E141