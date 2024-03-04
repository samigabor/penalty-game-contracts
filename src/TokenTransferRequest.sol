// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

enum RequestStatus {
    // Inactive,
    Pending,
    Approved,
    Completed
}

struct TransferRequest {
    address from;
    address to;
    RequestStatus status;
}

/**
 * @title TokenTransferRequest
 * @notice The contract is used to manage token transfer state. 
 * Only pending requests can be approved.
 * Only approved requests can be transferred.
 */
contract TokenTransferRequest {

    mapping(uint256 => TransferRequest) internal _transferRequests;

    event UpdateTransferRequest(uint256 tokenId, address from, address to, RequestStatus status);

    error OnlyPendingRequestCanBeApproved(uint256 tokenId, RequestStatus status);
    error OnlyApprovedRequestCanBeCompleted(uint256 tokenId, RequestStatus status);
    error TransferRequestNotApproved(uint256 tokenId);
    error TransferRequestToZeroAddress();

    modifier onlyApprovedRequest(uint256 tokenId) {
        if (_transferRequests[tokenId].status != RequestStatus.Approved) {
            revert TransferRequestNotApproved(tokenId);
        }
        _;
    }

    function _updateRequestStatus(uint256 tokenId, RequestStatus status, address to) internal {
        if (status == RequestStatus.Pending) {
            if (to == address(0)) revert TransferRequestToZeroAddress();
            _transferRequests[tokenId].from = msg.sender;
            _transferRequests[tokenId].to = to;
        }
        if (status == RequestStatus.Approved && _transferRequests[tokenId].status != RequestStatus.Pending) {
            revert OnlyPendingRequestCanBeApproved(tokenId, status);
        }
        if (status == RequestStatus.Completed && _transferRequests[tokenId].status != RequestStatus.Approved) {
            revert OnlyApprovedRequestCanBeCompleted(tokenId, status);
        }

        _transferRequests[tokenId].status = status;
        emit UpdateTransferRequest(tokenId, _transferRequests[tokenId].from, _transferRequests[tokenId].to, status);
    }
}
