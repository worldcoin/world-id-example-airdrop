pragma solidity ^0.8.19;

import {Script} from "forge-std/Script.sol";

import {ERC20} from "solmate/tokens/ERC20.sol";

import {IWorldIDGroups} from "world-id-contracts/interfaces/IWorldIDGroups.sol";
import {WorldIDAirdrop} from "src/WorldIDAirdrop.sol";

/// @title Deployment script for WorldIDAirdrop
/// @author Worldcoin
/// @notice Deploys the WorldIDAirdrop contract with the correct parameters
/// @dev You need to have the necessary values in scripts/.deploy-config.json in order for it to work.
/// Can be run by executing `make deploy-airdrop` (assumes a deployment of world-id-contracts or a mock)
/// or `make mock-airdrop` (local testing with Foundry's anvil) in the shell.
contract DeployWorldIDAirdrop is Script {

    WorldIDAirdrop public worldIDAirdrop;

    ///////////////////////////////////////////////////////////////////
    ///                            CONFIG                           ///
    ///////////////////////////////////////////////////////////////////
    string public root = vm.projectRoot();
    string public path = string.concat(root, "/scripts/.deploy-config.json");
    string public json = vm.readFile(path);

    uint256 private privateKey = abi.decode(vm.parseJson(json, ".privateKey"), (uint256));

    ///////////////////////////////////////////////////////////////////
    ///                          VARIABLES                          ///
    ///////////////////////////////////////////////////////////////////

    address public worldIDRouterAddress = abi.decode(vm.parseJson(json, ".worldIDRouterAddress"), (address));

    IWorldIDGroups public worldIdRouter = IWorldIDGroups(worldIDRouterAddress);

    uint256 public groupId = abi.decode(vm.parseJson(json, ".groupId"), (uint256));
    string public actionId = abi.decode(vm.parseJson(json, ".actionId"), (string));
    address public erc20Address = abi.decode(vm.parseJson(json, ".erc20Address"), (address)); 
    address public holder = abi.decode(vm.parseJson(json, ".holderAddress"), (address)); 
    uint256 public airdropAmount = abi.decode(vm.parseJson(json, ".airdropAmount"), (uint256)); 

    ERC20 public token = ERC20(erc20Address);

    function run() external {
        vm.startBroadcast(privateKey);

        worldIDAirdrop = new WorldIDAirdrop(worldIdRouter, groupId, actionId, token, holder, airdropAmount);

        vm.stopBroadcast();
    }
}