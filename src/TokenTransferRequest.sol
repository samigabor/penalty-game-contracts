// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

enum RequestStatus {
    None,
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
    mapping(address community => mapping(uint256 => TransferRequest)) internal _transferRequests;
    
    event UpdateTransferRequest(uint256 indexed tokenId, RequestStatus indexed status);

    error TransferToZeroAddressDenied();
    error ApproveForYourselfDenied();
    error CompleteForOthersDenied();
    error NotPendingRequest();
    error NotApprovedRequest();

    function _initiateTransferRequest(address community, address to, uint256 tokenId) internal {
        if (to == address(0)) revert TransferToZeroAddressDenied();

        _transferRequests[community][tokenId].from = msg.sender;
        _transferRequests[community][tokenId].to = to;
        _transferRequests[community][tokenId].status = RequestStatus.Pending;
        emit UpdateTransferRequest(tokenId, RequestStatus.Pending);
    }

    function _approveTransferRequest(address community, uint256 tokenId) internal {
        TransferRequest memory request = _transferRequests[community][tokenId];
        if (request.from == msg.sender || request.to == msg.sender) revert ApproveForYourselfDenied();
        if (request.status != RequestStatus.Pending) revert NotPendingRequest();

        _transferRequests[community][tokenId].status = RequestStatus.Approved;
        emit UpdateTransferRequest(tokenId, RequestStatus.Approved);
    }

    function _completeTransferRequest(address community, uint256 tokenId) internal {
        TransferRequest memory request = _transferRequests[community][tokenId];
        if (request.from != msg.sender) revert CompleteForOthersDenied();
        if (request.status != RequestStatus.Approved) revert NotApprovedRequest();

        _transferRequests[community][tokenId].status = RequestStatus.Completed;
        emit UpdateTransferRequest(tokenId, RequestStatus.Completed);
    }
}
