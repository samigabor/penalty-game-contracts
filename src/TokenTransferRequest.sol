// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/**
 * @title TokenTransferRequest
 * @notice The contract is used to manage token transfer state. Only approved requests can be transferred.
 */
contract TokenTransferRequest {
    enum RequestStatus { Pending, Approved, Completed }

    struct TransferRequest {
        address from;
        address to;
        RequestStatus status;
    }

    mapping(uint256 => TransferRequest) private _transferRequests;

    error NotPendingRequest(uint256 tokenId);
    error NotApprovedRequest(uint256 tokenId);

    function _initiateTransfer(address from, address to, uint256 tokenId) internal {
        _transferRequests[tokenId] = TransferRequest(from, to, RequestStatus.Pending);
    }

    function _approveTransfer(uint256 tokenId) public {
        TransferRequest storage request = _transferRequests[tokenId];
        if (request.status != RequestStatus.Pending) revert NotPendingRequest(tokenId);

        request.status = RequestStatus.Approved;
    }

    function _executeTransfer(uint256 tokenId) internal {
        TransferRequest storage request = _transferRequests[tokenId];
        if (request.status != RequestStatus.Approved) revert NotApprovedRequest(tokenId);

        request.status = RequestStatus.Completed;
    }

    function isApproved(uint256 tokenId) public view returns (bool) {
        return _transferRequests[tokenId].status == RequestStatus.Approved;
    }

    function getRequestStatus(uint256 tokenId) public view returns (RequestStatus) {
        return _transferRequests[tokenId].status;
    }
}
