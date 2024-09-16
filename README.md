# Penalty Game

## Live dApp [HERE](https://penalty-game-react.vercel.app/)

## Architecture (deployed on Polygon Mainnet)

- [CommunityRegistry](https://polygonscan.com/address/0x8392c3FFD7C80a4fFdaFE7F1117BAa556154b372#code) contract is the gateway to the system. From here admins and members perform all actions.
- [CommunityToken](https://polygonscan.com/address/0x07d8Cb502429483485ae3eaC4Ac8DA3E038b8b80#code) is an ERC721 contract supercharged with the approval mechanism.
- [TokenPool](https://polygonscan.com/address/0xEa4e3Af80a3fb7d8C6fCaC9632034ab41170Da68#code) contract allows burning tokens from communities
- [TransferRequestToken](https://polygonscan.com/address/0x2B6Bd7190eD74161C979623f9B5E6d02861Dda44#code) is a helper contract for the registry.

## Blockexplorer interaction:

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
