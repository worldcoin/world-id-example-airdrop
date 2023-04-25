// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {PRBTest} from "@prb/test/PRBTest.sol";
import {WorldIDIdentityManagerRouterMock} from "src/test/mock/WorldIDIdentityManagerRouterMock.sol";
import {TestERC20, ERC20} from "src/test/mock/TestERC20.sol";
import {WorldIDMultiAirdrop} from "src/WorldIDMultiAirdrop.sol";

/// @title World ID Multi Airdrop tests
/// @notice Contains tests for the aidrop contracts of various tokens to the World ID users
/// @author Worldcoin
/// @dev Tests that multiple airdrops can be created and later claimed by World ID users that submit
/// valid World ID proofs.
contract WorldIDMultiAirdropTest is PRBTest {
    ///////////////////////////////////////////////////////////////////
    ///                            EVENTS                           ///
    ///////////////////////////////////////////////////////////////////

    event AirdropClaimed(uint256 indexed airdropId, address receiver);
    event AirdropCreated(uint256 airdropId, WorldIDMultiAirdrop.Airdrop airdrop);
    event AirdropUpdated(uint256 indexed airdropId, WorldIDMultiAirdrop.Airdrop airdrop);

    ///////////////////////////////////////////////////////////////////
    ///                        CONFIG STORAGE                       ///
    ///////////////////////////////////////////////////////////////////

    address public user;
    address public airdropOwner;
    uint256 internal groupId;
    TestERC20 internal token;
    uint256[8] internal proof;
    WorldIDIdentityManagerRouterMock internal worldIDIdentityManagerRouterMock;
    WorldIDMultiAirdrop internal airdrop;

    function setUp() public {
        groupId = 1;
        user = address(0x2);
        token = new TestERC20();
        airdropOwner = address(0x1);
        worldIDIdentityManagerRouterMock = new WorldIDIdentityManagerRouterMock();
        vm.prank(airdropOwner);
        airdrop = new WorldIDMultiAirdrop(worldIDIdentityManagerRouterMock);
        proof = [0, 0, 0, 0, 0, 0, 0, 0];

        vm.label(address(this), "Sender");
        vm.label(user, "Holder");
        vm.label(airdropOwner, "Airdrop Owner");
        vm.label(address(token), "Token");
        vm.label(address(worldIDIdentityManagerRouterMock), "WorldIDIdentityManagerRouterMock");
        vm.label(address(airdrop), "WorldIDMultiAirdrop");

        // Issue some tokens to the user address, to be airdropped from the contract
        token.issue(address(user), 10 ether);

        // Approve spending from the airdrop contract
        vm.prank(address(user));
        token.approve(address(airdrop), type(uint256).max);
    }

    /// @notice Tests that you can create an airdrop
    function testCanCreateAirdrop() public {

        vm.expectEmit(false, false, false, true);
        emit AirdropCreated(
            1,
            WorldIDMultiAirdrop.Airdrop({
                groupId: groupId,
                token: token,
                manager: airdropOwner,
                holder: address(user),
                amount: 1 ether
            })
        );
        
        vm.prank(airdropOwner);
        airdrop.createAirdrop(groupId, token, address(user), 1 ether);

        (uint256 _groupId, ERC20 _token, address manager, address _holder, uint256 amount) =
            airdrop.getAirdrop(1);

        assertEq(_groupId, groupId);
        assertEq(address(_token), address(token));
        assertEq(manager, airdropOwner);
        assertEq(_holder, address(user));
        assertEq(amount, 1 ether);
    }

    /// @notice Tests that a user can claim a specific airdrop if they provide a valid World ID proof
    /// @dev mocks verifyProof inside airdrop.claim(), always goes through
    function testCanClaim(uint256 worldIDRoot, uint256 nullifierHash) public {
        vm.assume(worldIDRoot != 0 && nullifierHash != 0);

        assertEq(token.balanceOf(address(this)), 0);

        vm.prank(airdropOwner);
        airdrop.createAirdrop(groupId, token, address(user), 1 ether);

        vm.expectEmit(true, false, false, true);
        emit AirdropClaimed(1, address(this));
        airdrop.claim(1, address(this), worldIDRoot, nullifierHash, proof);

        assertEq(token.balanceOf(address(this)), 1 ether);
    }

    /// @notice Tests that a user can't claim an airdrop that hasn't been defined in the contract.
    /// @dev mocks verifyProof inside airdrop.claim(), always goes through
    function testCannotClaimNonExistantAirdrop(uint256 worldIDRoot, uint256 nullifierHash) public {
        vm.assume(worldIDRoot != 0 && nullifierHash != 0);

        assertEq(token.balanceOf(address(this)), 0);

        vm.expectRevert(WorldIDMultiAirdrop.InvalidAirdrop.selector);
        airdrop.claim(1, address(this), worldIDRoot, nullifierHash, proof);

        assertEq(token.balanceOf(address(this)), 0);
    }

    /// @notice Tests that a user can't claim an airdrop twice (consume the same nullifier hash twice).
    function testCannotDoubleClaim(uint256 worldIDRoot, uint256 nullifierHash) public {
        vm.assume(worldIDRoot != 0 && nullifierHash != 0);

        assertEq(token.balanceOf(address(this)), 0);

        vm.prank(airdropOwner);
        airdrop.createAirdrop(groupId, token, address(user), 1 ether);

        airdrop.claim(1, address(this), worldIDRoot, nullifierHash, proof);

        assertEq(token.balanceOf(address(this)), 1 ether);

        vm.expectRevert(WorldIDMultiAirdrop.InvalidNullifier.selector);
        airdrop.claim(1, address(this), worldIDRoot, nullifierHash, proof);

        assertEq(token.balanceOf(address(this)), 1 ether);
    }

    /// @notice Tests that the creator of the airdrop can update the details of the airdrop.
    function testCanUpdateAirdropDetails() public {
        vm.prank(airdropOwner);
        airdrop.createAirdrop(groupId, token, address(user), 1 ether);

        (
            uint256 oldGroupId,
            ERC20 oldToken,
            address oldManager,
            address oldHolder,
            uint256 oldAmount
        ) = airdrop.getAirdrop(1);

        assertEq(oldGroupId, groupId);
        assertEq(address(oldToken), address(token));
        assertEq(oldManager, airdropOwner);
        assertEq(oldHolder, address(user));
        assertEq(oldAmount, 1 ether);

        WorldIDMultiAirdrop.Airdrop memory newDetails = WorldIDMultiAirdrop.Airdrop({
            groupId: groupId + 1,
            token: token,
            manager: address(user),
            holder: address(this),
            amount: 2 ether
        });

        vm.expectEmit(true, false, false, true);
        emit AirdropUpdated(1, newDetails);
        vm.prank(airdropOwner);
        airdrop.updateDetails(1, newDetails);

        (uint256 _groupId, ERC20 _token, address manager, address _holder, uint256 amount) =
            airdrop.getAirdrop(1);

        assertEq(_groupId, newDetails.groupId);
        assertEq(address(_token), address(newDetails.token));
        assertEq(manager, newDetails.manager);
        assertEq(_holder, newDetails.holder);
        assertEq(amount, newDetails.amount);
    }

    /// @notice Tests that a non owner can't update details of an existing airdrop.
    function testNonOwnerCannotUpdateAirdropDetails(address notAirdropOwner) public {
        vm.assume(notAirdropOwner != airdropOwner && notAirdropOwner != address(0));

        vm.prank(airdropOwner);
        airdrop.createAirdrop(groupId, token, address(user), 1 ether);

        (
            uint256 oldGroupId,
            ERC20 oldToken,
            address oldManager,
            address oldHolder,
            uint256 oldAmount
        ) = airdrop.getAirdrop(1);

        assertEq(oldGroupId, groupId);
        assertEq(address(oldToken), address(token));
        assertEq(oldManager, airdropOwner);
        assertEq(oldHolder, address(user));
        assertEq(oldAmount, 1 ether);

        vm.prank(notAirdropOwner);
        vm.expectRevert(WorldIDMultiAirdrop.Unauthorized.selector);
        airdrop.updateDetails(
            1,
            WorldIDMultiAirdrop.Airdrop({
                groupId: groupId + 1,
                token: token,
                manager: address(user),
                holder: address(this),
                amount: 2 ether
            })
        );

        (uint256 _groupId, ERC20 _token, address manager, address _holder, uint256 amount) =
            airdrop.getAirdrop(1);

        assertEq(_groupId, groupId);
        assertEq(address(_token), address(token));
        assertEq(manager, airdropOwner);
        assertEq(_holder, address(user));
        assertEq(amount, 1 ether);
    }
}
