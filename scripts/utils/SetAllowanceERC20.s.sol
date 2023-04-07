pragma solidity ^0.8.19;

import {Script} from "forge-std/Script.sol";

import {ERC20} from "solmate/tokens/ERC20.sol";


contract SetAllowanceERC20 is Script {
    ERC20 token;

    /*//////////////////////////////////////////////////////////////
                                 CONFIG
    //////////////////////////////////////////////////////////////*/
    string public root = vm.projectRoot();
    string public path = string.concat(root, "/script/.deploy-config.json");
    string public json = vm.readFile(path);

    uint256 private privateKey = abi.decode(vm.parseJson(json, ".privateKey"), (uint256));
    address private erc20Address = abi.decode(vm.parseJson(json, ".erc20Address"), (address));
    address private holderAddress = abi.decode(vm.parseJson(json, ".holderAddress"), (address));
    uint256 private amount = abi.decode(vm.parseJson(json, ".airdropAmount"), (uint256));

    token = ERC20(erc20Address)


    function run() external {
        vm.startBroadcast(privateKey);

        token.approve(holderAddress, amount);

        vm.stopBroadcast();
    }

}