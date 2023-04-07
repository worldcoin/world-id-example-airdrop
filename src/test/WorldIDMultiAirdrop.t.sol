// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {PRBTest} from "@prb/test/PRBTest.sol";
import {WorldIDIdentityManagerRouterMock} from "src/test/mock/WorldIDIdentityManagerRouterMock.sol";
import {TestERC20, ERC20} from "src/test/mock/TestERC20.sol";
import {TypeConverter} from "src/test/utils/TypeConverter.sol";
import {WorldIDMultiAirdrop} from "src/WorldIDMultiAirdrop.sol";

contract User {}

contract WorldIDMultiAirdropTest is PRBTest {
    using TypeConverter for address;

    event AirdropClaimed(uint256 indexed airdropId, address receiver);
    event AirdropCreated(uint256 airdropId, WorldIDMultiAirdrop.Airdrop airdrop);
    event AirdropUpdated(uint256 indexed airdropId, WorldIDMultiAirdrop.Airdrop airdrop);

    User internal user;
    uint256 internal groupId;
    TestERC20 internal token;
    uint256[8] internal proof;
    WorldIDIdentityManagerRouterMock internal worldIDIdentityManagerRouterMock;
    WorldIDMultiAirdrop internal airdrop;

    function setUp() public {
        groupId = 1;
        user = new User();
        token = new TestERC20();
        worldIDIdentityManagerRouterMock = new WorldIDIdentityManagerRouterMock();
        airdrop = new WorldIDMultiAirdrop(worldIDIdentityManagerRouterMock);
        proof = [0, 0, 0, 0, 0, 0, 0, 0];

        vm.label(address(this), "Sender");
        vm.label(address(user), "Holder");
        vm.label(address(token), "Token");
        vm.label(address(worldIDIdentityManagerRouterMock), "WorldIDIdentityManagerRouterMock");
        vm.label(address(airdrop), "WorldIDMultiAirdrop");

        // Issue some tokens to the user address, to be airdropped from the contract
        token.issue(address(user), 10 ether);

        // Approve spending from the airdrop contract
        vm.prank(address(user));
        token.approve(address(airdrop), type(uint256).max);
    }

    function testCanCreateAirdrop() public {
        vm.expectEmit(false, false, false, true);
        emit AirdropCreated(
            1,
            WorldIDMultiAirdrop.Airdrop({
                groupId: groupId,
                token: token,
                manager: address(this),
                holder: address(user),
                amount: 1 ether
            })
        );
        airdrop.createAirdrop(groupId, token, address(user), 1 ether);

        (uint256 _groupId, ERC20 _token, address manager, address _holder, uint256 amount) =
            airdrop.getAirdrop(1);

        assertEq(_groupId, groupId);
        assertEq(address(_token), address(token));
        assertEq(manager, address(this));
        assertEq(_holder, address(user));
        assertEq(amount, 1 ether);
    }

    /// @dev mocks verifyProof inside airdrop.claim(), always goes through
    function testCanClaim(uint256 worldIDRoot, uint256 nullifierHash) public {
        vm.assume(worldIDRoot != 0 && nullifierHash != 0);

        assertEq(token.balanceOf(address(this)), 0);

        airdrop.createAirdrop(groupId, token, address(user), 1 ether);

        vm.expectEmit(true, false, false, true);
        emit AirdropClaimed(1, address(this));
        airdrop.claim(1, address(this), worldIDRoot, nullifierHash, proof);

        assertEq(token.balanceOf(address(this)), 1 ether);
    }

    /// @dev mocks verifyProof inside airdrop.claim(), always goes through
    function testCannotClaimNonExistantAirdrop(uint256 worldIDRoot, uint256 nullifierHash) public {
        vm.assume(worldIDRoot != 0 && nullifierHash != 0);

        assertEq(token.balanceOf(address(this)), 0);

        vm.expectRevert(WorldIDMultiAirdrop.InvalidAirdrop.selector);
        airdrop.claim(1, address(this), worldIDRoot, nullifierHash, proof);

        assertEq(token.balanceOf(address(this)), 0);
    }

    /// @dev mocks verifyProof inside airdrop.claim(), always goes through
    function testCanClaimAfterNewMemberAdded(uint256 worldIDRoot, uint256 nullifierHash) public {
        vm.assume(worldIDRoot != 0 && nullifierHash != 0);

        assertEq(token.balanceOf(address(this)), 0);

        airdrop.createAirdrop(groupId, token, address(user), 1 ether);

        airdrop.claim(1, address(this), worldIDRoot, nullifierHash, proof);

        assertEq(token.balanceOf(address(this)), 1 ether);
    }

    function testCannotDoubleClaim(uint256 worldIDRoot, uint256 nullifierHash) public {
        vm.assume(worldIDRoot != 0 && nullifierHash != 0);

        assertEq(token.balanceOf(address(this)), 0);

        airdrop.createAirdrop(groupId, token, address(user), 1 ether);

        airdrop.claim(1, address(this), worldIDRoot, nullifierHash, proof);

        assertEq(token.balanceOf(address(this)), 1 ether);

        vm.expectRevert(WorldIDMultiAirdrop.InvalidNullifier.selector);
        airdrop.claim(1, address(this), worldIDRoot, nullifierHash, proof);

        assertEq(token.balanceOf(address(this)), 1 ether);
    }

    function testCannotClaimIfNotMember(uint256 worldIDRoot, uint256 nullifierHash) public {
        vm.assume(worldIDRoot != 0 && nullifierHash != 0);

        assertEq(token.balanceOf(address(this)), 0);

        airdrop.createAirdrop(groupId, token, address(user), 1 ether);

        vm.expectRevert(abi.encodeWithSignature("InvalidProof()"));
        airdrop.claim(1, address(this), worldIDRoot, nullifierHash, proof);

        assertEq(token.balanceOf(address(this)), 0);
    }

    function testCannotClaimWithInvalidSignal(uint256 worldIDRoot, uint256 nullifierHash) public {
        vm.assume(worldIDRoot != 0 && nullifierHash != 0);

        assertEq(token.balanceOf(address(this)), 0);

        airdrop.createAirdrop(groupId, token, address(user), 1 ether);

        vm.expectRevert(abi.encodeWithSignature("InvalidProof()"));
        airdrop.claim(1, address(user), worldIDRoot, nullifierHash, proof);

        assertEq(token.balanceOf(address(this)), 0);
    }

    function testCannotClaimWithInvalidProof(uint256 worldIDRoot, uint256 nullifierHash) public {
        vm.assume(worldIDRoot != 0 && nullifierHash != 0);

        assertEq(token.balanceOf(address(this)), 0);

        airdrop.createAirdrop(groupId, token, address(user), 1 ether);
        proof[0] ^= 42;

        vm.expectRevert(abi.encodeWithSignature("InvalidProof()"));
        airdrop.claim(1, address(this), worldIDRoot, nullifierHash, proof);

        assertEq(token.balanceOf(address(this)), 0);
    }

    function testCanUpdateAirdropDetails() public {
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
        assertEq(oldManager, address(this));
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
        airdrop.updateDetails(1, newDetails);

        (uint256 _groupId, ERC20 _token, address manager, address _holder, uint256 amount) =
            airdrop.getAirdrop(1);

        assertEq(_groupId, newDetails.groupId);
        assertEq(address(_token), address(newDetails.token));
        assertEq(manager, newDetails.manager);
        assertEq(_holder, newDetails.holder);
        assertEq(amount, newDetails.amount);
    }

    function testNonOwnerCannotUpdateAirdropDetails() public {
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
        assertEq(oldManager, address(this));
        assertEq(oldHolder, address(user));
        assertEq(oldAmount, 1 ether);

        vm.prank(address(user));
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
        assertEq(manager, address(this));
        assertEq(_holder, address(user));
        assertEq(amount, 1 ether);
    }
}
