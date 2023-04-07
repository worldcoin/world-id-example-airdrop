pragma solidity ^0.8.19;

import {Script} from "forge-std/Script.sol";

import {ERC20} from "solmate/tokens/ERC20.sol";

import {IWorldIDGroups} from "world-id-contracts/interfaces/IWorldIDGroups.sol";
import {WorldIDAirdrop} from "src/WorldIDAirdrop.sol";


contract DeployWorldIDAirdrop is Script {

    WorldIDAirdrop public WorldIDAirdrop;
    IWorldIDGroups worldIdRouter;
    ERC20 token;

    /*//////////////////////////////////////////////////////////////
                                 CONFIG
    //////////////////////////////////////////////////////////////*/
    string public root = vm.projectRoot();
    string public path = string.concat(root, "/script/.deploy-config.json");
    string public json = vm.readFile(path);

    uint256 private privateKey = abi.decode(vm.parseJson(json, ".privateKey"), (uint256));
    address public worldIDRouterAddress = abi.decode(vm.parseJson(json, ".worldIDRouterAddress"), (address));

    worldIdRouter = IWorldIDGroups(worldIDRouterAddress);

    uint256 public groupId = abi.decode(vm.parseJson(json, ".groupId"), (uint256));
    string memory public actionId = abi.decode(vm.parseJson(json, ".actionId"), (string memory));
    address public erc20Address = abi.decode(vm.parseJson(json, ".erc20Address"), (address)); 
    address holder = abi.decode(vm.parseJson(json, ".holderAddress"), (address)); 
    uint256 airdropAmount = abi.decode(vm.parseJson(json, ".airdropAmount"), (uint256)); 

    token = ERC20(erc20Address);


    function run() external {
        vm.startBroadcast(privateKey);

        worldIDAirdrop = new WorldIDAirdrop(worldIDRouter, groupId, actionId, erc20Address, holder, aidropAmount);

        vm.stopBroadcast();
    }

}