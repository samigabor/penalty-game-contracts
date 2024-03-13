# Penalty Game

## Architecture (deployed on SEPOLIA)

- [CommunityRegistry](https://sepolia.etherscan.io/address/0xBCa974F068F5686fba05e6cA0ceC5BE6804fBB58#code) contract is the gateway to the system. From here admins and members perform all actions.
- [CommunityToken](https://sepolia.etherscan.io/address/0x1F3DA5eeFc1B23a7FB0b5AaB210d0F45Fc790C34#code) is an ERC721 contract supercharged with the approval mechanism.
- [TokenPool](https://sepolia.etherscan.io/address/0xBC17659eb64bB6cd10FD7A3013372D7BcbbC4fC6#code) contract allows burning tokens from communities
- [TransferRequestToken](https://sepolia.etherscan.io/address/0x8392c3FFD7C80a4fFdaFE7F1117BAa556154b372#code) is a helper contract for the registry.

## Etherscan interaction:

Admins can do the following:
- create new communities: `deployCommunityContract(<name>, <symbol>)`
- view deployed communities: `communities[<index>]`
- view deployed communitites by admin: `communitiesByAdmin[<adminAddress>][<index>]`
- add members to a community: `mintTokenToMember(<communityAddress>, <memberAddress>)`
- check if a member is part of a community: `isInCommunity(<memberAddress>, <communityAddress>)`
- remove a member from a community: `removeMemberFromCommunity(<memberAddress>, <communityAddress>)`
- burn tokens transferred to the `TokenPool` contract: `burnCommunityToken(<communityAddress>, <tokenId>)`

Members  can do the following:
- initiate a transfer request: `initiateTransferRequest(<toAddress>, <tokenId>)`
- approve transfer requests for other members in the community: `approveTransferRequest(<tokenId>)`
- complete transfer requests (must be approved by another member in the community): `completeTransferRequest(<tokenId>)`
- transfer their tokens to the `TokenPool` contract, from where they can be burned by the community admin.

## Security considerations

- all system is contraolled by the registry
- easy management of the registry using Ownable access control with easy migration to a role based access control
- the `safe` version of the methods is used for token management (mint & transfer). Ensures tokens will not get accidentally lost
