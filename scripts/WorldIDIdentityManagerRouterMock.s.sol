pragma solidity ^0.8.19;

import {Script} from "forge-std/Script.sol";

import {WorldIDIdentityManagerRouterMock} from "src/test/mock/WorldIDIdentityManagerRouterMock.sol";


/// @title Deployment script for WorldIDIdentityManagerRouterMock 
/// @author Worldcoin
/// @notice Deploys the WorldIDIdentityManagerRouterMock where verifyProof never reverts
/// @dev You need to have the necessary values in scripts/.deploy-config.json in order for it to work.
/// Will be deployed for mock deployments using `make mock-airdrop` or `make mock-multi-airdrop`.
contract DeployWorldIDIdentityManagerRouterMock is Script {
    WorldIDIdentityManagerRouterMock worldIDIdentityManagerRouterMock;

    ///////////////////////////////////////////////////////////////////
    ///                            CONFIG                           ///
    ///////////////////////////////////////////////////////////////////    

    string public root = vm.projectRoot();
    string public path = string.concat(root, "/scripts/.deploy-config.json");
    string public json = vm.readFile(path);

    uint256 private privateKey = abi.decode(vm.parseJson(json, ".privateKey"), (uint256));

    function run() external {
        vm.startBroadcast(privateKey);

        worldIDIdentityManagerRouterMock = new WorldIDIdentityManagerRouterMock();

        vm.stopBroadcast();
    }

}