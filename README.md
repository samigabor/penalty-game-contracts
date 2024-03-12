# Penalty Game

## Architecture

- [CommunityToken](https://sepolia.etherscan.io/address/0x121fe9DA9be9fC948bF56F93F99c13ccb2cFE36d#code) contract allows members to transfer their tokens to other members or the pool contract for burning.
- [CommunityRegistry](https://sepolia.etherscan.io/address/0x1826c35d17DB4880Cc8Fe9477EC9e769F264D7A8#code) contract allows admins to create and managinge communities.
- [TokenPool](https://sepolia.etherscan.io/address/0x4432C7E4972a84E20E1FB0D899e61287c522e2dB#code) contract allows burning tokens from a community
- `TransferRequestToken` is a helper contract for the Community Token contract.

## Etherscan interaction:

Admins will manage the communities through the Community Registry contract deployed on Sepolia at [0x1826c35d17DB4880Cc8Fe9477EC9e769F264D7A8](https://sepolia.etherscan.io/address/0x1826c35d17DB4880Cc8Fe9477EC9e769F264D7A8#code). 

First step would be to create a community `deployCommunityContract(<name>, <symbol>)`, and the following actions are possible:
- view deployed communities: `communities[<index>]`
- view deployed communitites by admin: `communitiesByAdmin[<adminAddress>][<index>]`
- add members to a community: `mintTokenToMember(<communityAddress>, <memberAddress>)`
- check if a member is part of a community: `isInCommunity(<memberAddress>, <communityAddress>)`
- remove a member from a community: `removeMemberFromCommunity(<memberAddress>, <communityAddress>)`
- burn tokens transferred to the [TokenPool](https://sepolia.etherscan.io/address/0x4432C7E4972a84E20E1FB0D899e61287c522e2dB#code) contract: `burnCommunityToken(<communityAddress>, <tokenId>)`

Members can interact directly with the CommunityToken contract deployed on Sepolia at [0x121fe9DA9be9fC948bF56F93F99c13ccb2cFE36d](https://sepolia.etherscan.io/address/0x121fe9DA9be9fC948bF56F93F99c13ccb2cFE36d#code). Here are the actions a member can take:
- initiate a transfer request: `initiateTransferRequest(<toAddress>, <tokenId>)`
- approve transfer requests for other members in the community: `approveTransferRequest(<tokenId>)`
- complete transfer requests (must be approved by another member in the community): `completeTransferRequest(<tokenId>)`
- members can also transfer their tokens to the [TokenPool](https://sepolia.etherscan.io/address/0x4432C7E4972a84E20E1FB0D899e61287c522e2dB#code) contract, from where they can be burned by the community admin.

## Security considerations

- all system is contraolled by the registry
- easy management of the registry using Ownable access control with easy migration to a role based access control
- the `safe` version of the methods is used for token management (mint & transfer). Ensures tokens will not get accidentally lost
