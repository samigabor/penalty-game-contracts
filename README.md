# Penalty Game

## Architecture

- [CommunityRegistry](https://sepolia.etherscan.io/address/0xc9bE2366fB425F7C1371008Ef9AD773C9AD103F2#code) contract is the gateway to the system. From here admins and members perform all actions.
- [CommunityToken](https://sepolia.etherscan.io/address/0xDd88659C8d77b092cd6B68459A86f33F123E2B47#code) is an ERC721 contract supercharged with the approval mechanism.
- [TokenPool](https://sepolia.etherscan.io/address/0xBC1dba2a6fE6eE4Ba6A886fc1BBeC09a19963cf5#code) contract allows burning tokens from communities
- [TransferRequestToken](https://sepolia.etherscan.io/address/0x77Dcd2922138F77cc53B7296c86f297B9CC07F83#code) is a helper contract for the registry.

## Etherscan interaction:

Admins will manage the communities through the Community Registry contract deployed on Sepolia at [0xc9bE2366fB425F7C1371008Ef9AD773C9AD103F2](https://sepolia.etherscan.io/address/0xc9bE2366fB425F7C1371008Ef9AD773C9AD103F2#code). 

Admins can do the following:
- create new communities: `deployCommunityContract(<name>, <symbol>)`
- view deployed communities: `communities[<index>]`
- view deployed communitites by admin: `communitiesByAdmin[<adminAddress>][<index>]`
- add members to a community: `mintTokenToMember(<communityAddress>, <memberAddress>)`
- check if a member is part of a community: `isInCommunity(<memberAddress>, <communityAddress>)`
- remove a member from a community: `removeMemberFromCommunity(<memberAddress>, <communityAddress>)`
- burn tokens transferred to the [TokenPool](https://sepolia.etherscan.io/address/0xBC1dba2a6fE6eE4Ba6A886fc1BBeC09a19963cf5#code) contract: `burnCommunityToken(<communityAddress>, <tokenId>)`

Members  can do the following:
- initiate a transfer request: `initiateTransferRequest(<toAddress>, <tokenId>)`
- approve transfer requests for other members in the community: `approveTransferRequest(<tokenId>)`
- complete transfer requests (must be approved by another member in the community): `completeTransferRequest(<tokenId>)`
- transfer their tokens to the [TokenPool](https://sepolia.etherscan.io/address/0xBC1dba2a6fE6eE4Ba6A886fc1BBeC09a19963cf5#code) contract, from where they can be burned by the community admin.

## Security considerations

- all system is contraolled by the registry
- easy management of the registry using Ownable access control with easy migration to a role based access control
- the `safe` version of the methods is used for token management (mint & transfer). Ensures tokens will not get accidentally lost
