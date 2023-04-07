// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

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
    uint256[8] internal proof;
    TestERC20 internal token;
    WorldIDIdentityManagerRouterMock internal worldIDIdentityManagerRouterMock;
    WorldIDAirdrop internal airdrop;

    function setUp() public {
        groupId = 1;
        user = new User();
        token = new TestERC20();
        worldIDIdentityManagerRouterMock = new WorldIDIdentityManagerRouterMock();

        proof = [0, 0, 0, 0, 0, 0, 0, 0];
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

    function testCanClaim(uint256 worldIDRoot, uint256 nullifierHash) public {
        vm.assume(worldIDRoot != 0 && nullifierHash != 0);

        assertEq(token.balanceOf(address(this)), 0);

        airdrop.claim(address(this), worldIDRoot, nullifierHash, proof);

        assertEq(token.balanceOf(address(this)), airdrop.airdropAmount());
    }

    function testCanClaimAfterNewMemberAdded(uint256 worldIDRoot, uint256 nullifierHash) public {
        vm.assume(worldIDRoot != 0 && nullifierHash != 0);

        assertEq(token.balanceOf(address(this)), 0);

        airdrop.claim(address(this), worldIDRoot, nullifierHash, proof);

        assertEq(token.balanceOf(address(this)), airdrop.airdropAmount());
    }

    function testCannotDoubleClaim(uint256 worldIDRoot, uint256 nullifierHash) public {
        vm.assume(worldIDRoot != 0 && nullifierHash != 0);

        assertEq(token.balanceOf(address(this)), 0);

        airdrop.claim(address(this), worldIDRoot, nullifierHash, proof);

        assertEq(token.balanceOf(address(this)), airdrop.airdropAmount());

        vm.expectRevert(WorldIDAirdrop.InvalidNullifier.selector);
        airdrop.claim(address(this), worldIDRoot, nullifierHash, proof);

        assertEq(token.balanceOf(address(this)), airdrop.airdropAmount());
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
