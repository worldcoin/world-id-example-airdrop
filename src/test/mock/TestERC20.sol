// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

import {ERC20} from "solmate/tokens/ERC20.sol";

/// @title Test ERC20
/// @notice Wrapper around solmate's ERC20 that instantiates the TEST token.
/// @author Worldcoin
contract TestERC20 is ERC20("Test Token", "TEST", 18) {
    function issue(address receiver, uint256 amount) public {
        _mint(receiver, amount);
    }
}
