// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {PRBTest} from "@prb/test/PRBTest.sol";
import {WorldIDIdentityManagerRouterMock} from "src/test/mock/WorldIDIdentityManagerRouterMock.sol";
import {TestERC20} from "./mock/TestERC20.sol";
import {WorldIDAirdrop} from "../WorldIDAirdrop.sol";

/// @title World ID Airdrop Tests
/// @notice Contains tests for the template airdrop contracts for WorldID users
/// @author Worldcoin
/// @dev These contracts mock the identity manager (never reverts) and tests the airdrop
/// functionality for a single airdrop.
contract WorldIDAirdropTest is PRBTest {
    event AmountUpdated(uint256 amount);

    address public user;
    uint256 internal groupId;
    uint256[8] internal proof;
    address public manager;
    TestERC20 internal token;
    WorldIDIdentityManagerRouterMock internal worldIDIdentityManagerRouterMock;
    WorldIDAirdrop internal airdrop;

    function setUp() public {
        groupId = 1;
        user = address(0x2);
        token = new TestERC20();
        worldIDIdentityManagerRouterMock = new WorldIDIdentityManagerRouterMock();

        manager = address(0x1);

        proof = [0, 0, 0, 0, 0, 0, 0, 0];

        vm.prank(manager);
        airdrop =
        new WorldIDAirdrop(worldIDIdentityManagerRouterMock, groupId, 'wld_test_12345678', token, address(user), 1 ether);

        ///////////////////////////////////////////////////////////////////
        ///                            LABELS                           ///
        ///////////////////////////////////////////////////////////////////

        vm.label(address(this), "Sender");
        vm.label(user, "Holder");
        vm.label(manager, "Manager");
        vm.label(address(token), "Token");
        vm.label(address(worldIDIdentityManagerRouterMock), "WorldIDIdentityManagerRouterMock");
        vm.label(address(airdrop), "WorldIDAirdrop");

        // Issue some tokens to the user address, to be airdropped from the contract
        token.issue(address(user), 10 ether);

        // Approve spending from the airdrop contract
        vm.prank(address(user));
        token.approve(address(airdrop), type(uint256).max);
    }

    /// @notice Tests that the user is able to claim tokens if the World ID proof is valid
    function testCanClaim(uint256 worldIDRoot, uint256 nullifierHash) public {
        vm.assume(worldIDRoot != 0 && nullifierHash != 0);

        assertEq(token.balanceOf(address(this)), 0);

        airdrop.claim(address(this), worldIDRoot, nullifierHash, proof);

        assertEq(token.balanceOf(address(this)), airdrop.airdropAmount());
    }

    /// @notice Tests that nullifier hash for the same action cannot be consumed twice
    function testCannotDoubleClaim(uint256 worldIDRoot, uint256 nullifierHash) public {
        vm.assume(worldIDRoot != 0 && nullifierHash != 0);

        assertEq(token.balanceOf(address(this)), 0);

        airdrop.claim(address(this), worldIDRoot, nullifierHash, proof);

        assertEq(token.balanceOf(address(this)), airdrop.airdropAmount());

        vm.expectRevert(WorldIDAirdrop.InvalidNullifier.selector);
        airdrop.claim(address(this), worldIDRoot, nullifierHash, proof);

        assertEq(token.balanceOf(address(this)), airdrop.airdropAmount());
    }

    /// @notice Tests that the manager can update the airdrop amount
    function testUpdateAirdropAmount() public {
        assertEq(airdrop.airdropAmount(), 1 ether);

        vm.expectEmit(false, false, false, true);
        emit AmountUpdated(2 ether);
        vm.prank(manager);
        airdrop.updateAmount(2 ether);

        assertEq(airdrop.airdropAmount(), 2 ether);
    }

    /// @notice Tests that anyone that is not the manager can't update the airdrop amount
    function testCannotUpdateAirdropAmountIfNotManager(address notManager) public {
        vm.assume(notManager != manager && notManager != address(0));
        assertEq(airdrop.airdropAmount(), 1 ether);

        vm.expectRevert(WorldIDAirdrop.Unauthorized.selector);
        vm.prank(notManager);
        airdrop.updateAmount(2 ether);

        assertEq(airdrop.airdropAmount(), 1 ether);
    }
}
