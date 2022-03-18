// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

import {Vm} from "forge-std/Vm.sol";
import {DSTest} from "ds-test/test.sol";
import {Semaphore} from "./mock/Semaphore.sol";
import {TestERC20} from "./mock/TestERC20.sol";
import {TypeConverter} from "./utils/TypeConverter.sol";
import {SemaphoreAirdrop} from "../SemaphoreAirdrop.sol";

contract User {}

contract SemaphoreAirdropTest is DSTest {
    using TypeConverter for address;
    using TypeConverter for uint256;

    event AmountUpdated(uint256 amount);

    User internal user;
    uint256 internal groupId;
    TestERC20 internal token;
    Semaphore internal semaphore;
    SemaphoreAirdrop internal airdrop;
    Vm internal hevm = Vm(HEVM_ADDRESS);

    function setUp() public {
        user = new User();
        token = new TestERC20();
        semaphore = new Semaphore();
        airdrop = new SemaphoreAirdrop(
            semaphore,
            0,
            token,
            address(user),
            1 ether
        );

        // Issue some tokens to the user address, to be airdropped from the contract
        token.issue(address(user), 10 ether);

        // Approve spending from the airdrop contract
        hevm.prank(address(user));
        token.approve(address(airdrop), type(uint256).max);
    }

    function genIdentityCommitment() internal returns (uint256) {
        string[] memory ffiArgs = new string[](2);
        ffiArgs[0] = "node";
        ffiArgs[1] = "src/test/scripts/generate-commitment.js";

        bytes memory returnData = hevm.ffi(ffiArgs);
        return abi.decode(returnData, (uint256));
    }

    function genProof() internal returns (uint256, uint256[8] memory proof) {
        string[] memory ffiArgs = new string[](4);
        ffiArgs[0] = "node";
        ffiArgs[1] = "src/test/scripts/generate-proof.js";
        ffiArgs[2] = uint256(uint160(address(semaphore))).toString();
        ffiArgs[3] = string.concat("0x", address(this).toString());

        bytes memory returnData = hevm.ffi(ffiArgs);

        return abi.decode(returnData, (uint256, uint256[8]));
    }

    function testUpdateAirdropAmount() public {
        assertEq(airdrop.airdropAmount(), 1 ether);

        hevm.expectEmit(false, false, false, true);
        emit AmountUpdated(2 ether);
        airdrop.updateAmount(2 ether);

        assertEq(airdrop.airdropAmount(), 2 ether);
    }

    function testCannotUpdateAirdropAmountIfNotManager() public {
        assertEq(airdrop.airdropAmount(), 1 ether);

        hevm.expectRevert(SemaphoreAirdrop.Unauthorized.selector);
        hevm.prank(address(user));
        airdrop.updateAmount(2 ether);

        assertEq(airdrop.airdropAmount(), 1 ether);
    }
}