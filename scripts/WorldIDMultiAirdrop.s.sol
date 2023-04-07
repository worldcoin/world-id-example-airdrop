pragma solidity ^0.8.19;

import {Script} from "forge-std/Script.sol";

import {IWorldIDGroups} from "world-id-contracts/interfaces/IWorldIDGroups.sol";
import {WorldIDMultiAirdrop} from "src/WorldIDMultiAirdrop.sol";

contract DeployWorldIDMultiAirdrop is Script {

    WorldIDMultiAirdrop public worldIDMultiAirdrop;
    IWorldIDGroups worldIdRouter;

    /*//////////////////////////////////////////////////////////////
                                 CONFIG
    //////////////////////////////////////////////////////////////*/
    string public root = vm.projectRoot();
    string public path = string.concat(root, "/script/.deploy-config.json");
    string public json = vm.readFile(path);

    uint256 public privateKey = abi.decode(vm.parseJson(json, ".privateKey"), (uint256));
    address public worldIDRouterAddress = abi.decode(vm.parseJson(json, ".worldIDRouterAddress"), (address));

    worldIdRouter = IWorldIDGroups(worldIDRouterAddress);


    function run() external {
        vm.startBroadcast(privateKey);

        worldIDMultiAirdrop = new WorldIDMultiAirdrop(worldIDRouter);

        vm.stopBroadcast();
    }

}