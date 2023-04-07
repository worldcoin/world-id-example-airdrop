pragma solidity ^0.8.19;

import {Script} from "forge-std/Script.sol";

import {WorldIDIdentityManagerRouterMock} from "src/test/mock/WorldIDIdentityManagerRouterMock.sol";


contract DeployWorldIDIdentityManagerRouterMock is Script {
    WorldIDIdentityManagerRouterMock worldIDIdentityManagerRouterMock;

    /*//////////////////////////////////////////////////////////////
                                 CONFIG
    //////////////////////////////////////////////////////////////*/
    string public root = vm.projectRoot();
    string public path = string.concat(root, "/script/.deploy-config.json");
    string public json = vm.readFile(path);

    uint256 private privateKey = abi.decode(vm.parseJson(json, ".privateKey"), (uint256));

    function run() external {
        vm.startBroadcast(privateKey);

        worldIDIdentityManagerRouterMock = new WorldIDIdentityManagerRouterMock();

        vm.stopBroadcast();
    }

}