// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.19;

import {Script, console} from "forge-std/Script.sol";
import {HelperConfig, CodeConstants} from "./HelperConfig.s.sol";
import {VRFCoordinatorV2_5Mock} from "@chainlink/contracts/src/v0.8/vrf/mocks/VRFCoordinatorV2_5Mock.sol";
import {LinkToken} from "./../test/mocks/LinkToken.sol";
import {DevOpsTools} from "lib/foundry-devops/src/DevOpsTools.sol";

contract CreateSubscription is Script {
    function createSubscrtiptionUsingConfig()
        public
        returns (uint256, address)
    {
        HelperConfig helperConfig = new HelperConfig();

        HelperConfig.NetworkConfig memory activeConfig = helperConfig
            .getConfig();

        address vrfCoordinator = activeConfig.vrfCoordinator;
        (uint256 subId, ) = createSubscription(vrfCoordinator);
        return (subId, vrfCoordinator);
    }

    function createSubscription(
        address vrfCoordinator
    ) public returns (uint256, address) {
        console.log("Creating subscribtion on chain Id: ", block.chainid);
        vm.startBroadcast();
        uint256 subId = VRFCoordinatorV2_5Mock(vrfCoordinator)
            .createSubscription();
        vm.stopBroadcast();

        console.log("SubId: ", subId);
        console.log(
            "Please update the subscription Id in your HelperConfig.s.sol"
        );

        return (subId, vrfCoordinator);
    }
}

contract FundSubscription is Script, CodeConstants {
    uint256 public constant FUND_AMOUNT = 3 ether;

    // function fundSubscriptionUsingConfig() public {
    //     HelperConfig helperConfig = new HelperConfig();
    //     address vrfCoordinator = helperConfig.getConfig().vrfCoordinator;
    //     uint256 subscriptionId = helperConfig.getConfig().subscriptionId;
    //     address linkToken = helperConfig.getConfig().link;
    //     vm.startBroadcast();
    //     fundSubscription(vrfCoordinator, subscriptionId, linkToken);
    //     vm.stopBroadcast();
    // }

    function fundSubscription(
        address vrfCoordinator,
        uint256 subscriptionId,
        address linkToken
    ) public {
        console.log("SubId: ", subscriptionId);
        console.log("coordinator: ", vrfCoordinator);
        console.log("chainId: ", block.chainid);
        vm.startBroadcast();
        if (block.chainid == LOCAL_CHAIN_ID) {
            VRFCoordinatorV2_5Mock(vrfCoordinator).fundSubscription(
                subscriptionId,
                FUND_AMOUNT
            );
        } else {
            LinkToken(linkToken).transferAndCall(
                vrfCoordinator,
                FUND_AMOUNT,
                abi.encode(subscriptionId)
            );
        }
        vm.stopBroadcast();
    }

    // function run() external {
    //     fundSubscriptionUsingConfig();
    // }
}

contract AddConsumer is Script {
    // function addConsumerUsingConfig(address contractToAddtoVrf) public {
    //     HelperConfig helperConfig = new HelperConfig();
    //     uint256 subscriptionId = helperConfig.getConfig().subscriptionId;
    //     address vrfCoordinator = helperConfig.getConfig().vrfCoordinator;
    //     vm.startBroadcast();
    //     addConsumer(contractToAddtoVrf, vrfCoordinator, subscriptionId);
    //     vm.stopBroadcast();
    // }

    function addConsumer(
        address contractToAddtoVrf,
        address vrfCoordinator,
        uint256 subId
    ) public {
        console.log("Adding consumer contract", contractToAddtoVrf);
        console.log("To vrfCoordinator", vrfCoordinator);
        console.log("On ChainId", block.chainid);
        vm.startBroadcast();
        VRFCoordinatorV2_5Mock(vrfCoordinator).addConsumer(
            subId,
            contractToAddtoVrf
        );
        vm.stopBroadcast();
    }

    // function run() external {
    //     address mostRecentlydep = DevOpsTools.get_most_recent_deployment(
    //         "Raffle",
    //         block.chainid
    //     );
    //     // addConsumerUsingConfig(mostRecentlydep);
    // }
}
