// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {Vm} from "forge-std/Vm.sol";
import {PRBTest} from "@prb/test/PRBTest.sol";
import {WorldIDIdentityManagerRouterMock} from "src/test/mock/WorldIDIdentityManagerRouterMock.sol";
import {TestERC20} from "./mock/TestERC20.sol";
import {TypeConverter} from "./utils/TypeConverter.sol";
import {WorldIDAirdrop} from "../WorldIDAirdrop.sol";

contract User {}

contract WorldIDAirdropTest is PRBTest {
    using TypeConverter for address;

    event AmountUpdated(uint256 amount);

    User internal user;
    uint256 internal groupId;
    TestERC20 internal token;
    WorldIDIdentityManagerRouterMock internal worldIDIdentityManagerRouterMock;
    WorldIDAirdrop internal airdrop;

    function setUp() public {
        groupId = 1;
        user = new User();
        token = new TestERC20();
        worldIDIdentityManagerRouterMock = new WorldIDIdentityManagerRouterMock();
        airdrop =
        new WorldIDAirdrop(worldIDIdentityManagerRouterMock, groupId, 'wld_test_12345678', token, address(user), 1 ether);

        vm.label(address(this), "Sender");
        vm.label(address(user), "Holder");
        vm.label(address(token), "Token");
        vm.label(address(worldIDIdentityManagerRouterMock), "WorldIDIdentityManagerRouterMock");
        vm.label(address(airdrop), "WorldIDAirdrop");

        // Issue some tokens to the user address, to be airdropped from the contract
        token.issue(address(user), 10 ether);

        // Approve spending from the airdrop contract
        vm.prank(address(user));
        token.approve(address(airdrop), type(uint256).max);
    }

    function testCanClaim() public {
        assertEq(token.balanceOf(address(this)), 0);

        airdrop.claim(address(this), semaphore.getRoot(groupId), nullifierHash, proof);

        assertEq(token.balanceOf(address(this)), airdrop.airdropAmount());
    }

    function testCanClaimAfterNewMemberAdded() public {
        assertEq(token.balanceOf(address(this)), 0);

        semaphore.createGroup(groupId, 20, 0);
        semaphore.addMember(groupId, genIdentityCommitment());
        uint256 root = semaphore.getRoot(groupId);
        semaphore.addMember(groupId, 1);

        (uint256 nullifierHash, uint256[8] memory proof) = genProof();
        airdrop.claim(address(this), root, nullifierHash, proof);

        assertEq(token.balanceOf(address(this)), airdrop.airdropAmount());
    }

    function testCannotClaimHoursAfterNewMemberAdded() public {
        assertEq(token.balanceOf(address(this)), 0);

        semaphore.createGroup(groupId, 20, 0);
        semaphore.addMember(groupId, genIdentityCommitment());
        uint256 root = semaphore.getRoot(groupId);
        semaphore.addMember(groupId, 1);

        vm.warp(block.timestamp + 7 days + 1 hours);

        (uint256 nullifierHash, uint256[8] memory proof) = genProof();
        vm.expectRevert(Semaphore.InvalidRoot.selector);
        airdrop.claim(address(this), root, nullifierHash, proof);

        assertEq(token.balanceOf(address(this)), 0);
    }

    function testCannotDoubleClaim() public {
        assertEq(token.balanceOf(address(this)), 0);

        semaphore.createGroup(groupId, 20, 0);
        semaphore.addMember(groupId, genIdentityCommitment());

        (uint256 nullifierHash, uint256[8] memory proof) = genProof();
        airdrop.claim(address(this), semaphore.getRoot(groupId), nullifierHash, proof);

        assertEq(token.balanceOf(address(this)), airdrop.airdropAmount());

        uint256 root = semaphore.getRoot(groupId);
        vm.expectRevert(WorldIDAirdrop.InvalidNullifier.selector);
        airdrop.claim(address(this), root, nullifierHash, proof);

        assertEq(token.balanceOf(address(this)), airdrop.airdropAmount());
    }

    function testCannotClaimIfNotMember() public {
        assertEq(token.balanceOf(address(this)), 0);

        semaphore.createGroup(groupId, 20, 0);
        semaphore.addMember(groupId, 1);

        uint256 root = semaphore.getRoot(groupId);
        (uint256 nullifierHash, uint256[8] memory proof) = genProof();

        vm.expectRevert(abi.encodeWithSignature("InvalidProof()"));
        airdrop.claim(address(this), root, nullifierHash, proof);

        assertEq(token.balanceOf(address(this)), 0);
    }

    function testCannotClaimWithInvalidSignal() public {
        assertEq(token.balanceOf(address(this)), 0);

        semaphore.createGroup(groupId, 20, 0);
        semaphore.addMember(groupId, genIdentityCommitment());

        (uint256 nullifierHash, uint256[8] memory proof) = genProof();

        uint256 root = semaphore.getRoot(groupId);
        vm.expectRevert(abi.encodeWithSignature("InvalidProof()"));
        airdrop.claim(address(user), root, nullifierHash, proof);

        assertEq(token.balanceOf(address(this)), 0);
    }

    function testCannotClaimWithInvalidProof() public {
        assertEq(token.balanceOf(address(this)), 0);

        semaphore.createGroup(groupId, 20, 0);
        semaphore.addMember(groupId, genIdentityCommitment());

        (uint256 nullifierHash, uint256[8] memory proof) = genProof();
        proof[0] ^= 42;

        uint256 root = semaphore.getRoot(groupId);
        vm.expectRevert(abi.encodeWithSignature("InvalidProof()"));
        airdrop.claim(address(this), root, nullifierHash, proof);

        assertEq(token.balanceOf(address(this)), 0);
    }

    function testUpdateAirdropAmount() public {
        assertEq(airdrop.airdropAmount(), 1 ether);

        vm.expectEmit(false, false, false, true);
        emit AmountUpdated(2 ether);
        airdrop.updateAmount(2 ether);

        assertEq(airdrop.airdropAmount(), 2 ether);
    }

    function testCannotUpdateAirdropAmountIfNotManager() public {
        assertEq(airdrop.airdropAmount(), 1 ether);

        vm.expectRevert(WorldIDAirdrop.Unauthorized.selector);
        vm.prank(address(user));
        airdrop.updateAmount(2 ether);

        assertEq(airdrop.airdropAmount(), 1 ether);
    }
}
