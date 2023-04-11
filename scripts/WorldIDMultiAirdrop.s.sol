pragma solidity ^0.8.19;

import {Script} from "forge-std/Script.sol";

import {IWorldIDGroups} from "world-id-contracts/interfaces/IWorldIDGroups.sol";
import {WorldIDMultiAirdrop} from "src/WorldIDMultiAirdrop.sol";

/// @title WorldIDMultiAirdrop deployment script
/// @author Worldcoin
/// @notice Deploys the WorldIDMultiAirdrop contracts
/// @dev You need to have the necessary values in scripts/.deploy-config.json in order for it to work.
/// Can be run by executing `make deploy-multi-airdrop` (assumes a deployment of world-id-contracts or a mock)
/// or `make mock-multi-airdrop` (local testing with Foundry's anvil) in the shell.
contract DeployWorldIDMultiAirdrop is Script {

    WorldIDMultiAirdrop public worldIDMultiAirdrop;

    ///////////////////////////////////////////////////////////////////
    ///                            CONFIG                           ///
    ///////////////////////////////////////////////////////////////////
    string public root = vm.projectRoot();
    string public path = string.concat(root, "/scripts/.deploy-config.json");
    string public json = vm.readFile(path);

    uint256 public privateKey = abi.decode(vm.parseJson(json, ".privateKey"), (uint256));
    address public worldIDRouterAddress = abi.decode(vm.parseJson(json, ".worldIDRouterAddress"), (address));

    
    IWorldIDGroups worldIdRouter = IWorldIDGroups(worldIDRouterAddress); 


    function run() external {
        vm.startBroadcast(privateKey);

        worldIDMultiAirdrop = new WorldIDMultiAirdrop(worldIdRouter);

        vm.stopBroadcast();
    }

}