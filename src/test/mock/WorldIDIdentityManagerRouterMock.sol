// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {IWorldIDGroups} from "world-id-contracts/interfaces/IWorldIDGroups.sol";

/// @title World ID Identity Manager Router Mock
/// @author dcbuild3r
/// @notice Mocks the verifyProof functionality of the Semaphore v3 verifier
contract WorldIDIdentityManagerRouterMock is IWorldIDGroups {
    /// @notice Thrown to mock the verification of a WorldID zero knowledge proof.
    event proofVerified();

    /// @notice Verifies a WorldID zero knowledge proof.
    /// @dev Note that a double-signaling check is not included here, and should be carried by the
    ///      caller.
    /// @dev It is highly recommended that the implementation is restricted to `view` if possible.
    ///
    /// @custom:param groupId The group identifier for the group to verify a proof for.
    /// @custom:param root The of the Merkle tree
    /// @custom:param signalHash A keccak256 hash of the Semaphore signal
    /// @custom:param nullifierHash The nullifier hash
    /// @custom:param externalNullifierHash A keccak256 hash of the external nullifier
    /// @custom:param proof The zero-knowledge proof
    ///
    /// @custom:reverts string If the `proof` is invalid.
    /// @custom:reverts NoSuchGroup If the provided `groupId` references a group that does not exist.
    function verifyProof(uint256, uint256, uint256, uint256, uint256, uint256[8] calldata)
        external
    {
        emit proofVerified();
    }
}
