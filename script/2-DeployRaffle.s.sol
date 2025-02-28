// // SPDX-License-Identifier: MIT
// pragma solidity ^0.8.19;

// import {Script, console} from "forge-std/Script.sol";
// import {Raffle} from "./../src/Raffle.sol";
// import {HelperConfig2} from "./2-HelperConfig.s.sol";
// import {VRFCoordinatorV2_5Mock} from "@chainlink/contracts/src/v0.8/vrf/mocks/VRFCoordinatorV2_5Mock.sol";
// import {LinkToken} from "./../test/mocks/LinkToken.sol";
// import {DevOpsTools} from "foundry-devops/src/DevOpsTools.sol";

// contract DeployRaffle2 is Script {
//     // struct NetworkConfig {
//     //     uint256 entranceFee;
//     //     uint256 interval;
//     //     address vrfCoordinator;
//     //     bytes32 gasLane;
//     //     uint256 subscriptionId;
//     //     uint32 callbackGasLimit;
//     //     address link;
//     // }
//     function deployContractAndSetup() external returns (Raffle, HelperConfig2) {
//         HelperConfig2 helperConfig = new HelperConfig2();

//         HelperConfig2.NetworkConfig memory config = helperConfig
//             .createAnvilConfig();

//         vm.startBroadcast();
//         Raffle raffle = new Raffle(
//             config.entranceFee,
//             config.interval,
//             config.vrfCoordinator,
//             config.gasLane,
//             config.subscriptionId,
//             config.callbackGasLimit
//         );
//         vm.stopBroadcast();

//         uint96 FUND_AMOUNT = 3 ether;

//         VRFCoordinatorV2_5Mock vrfCoordinator = VRFCoordinatorV2_5Mock(
//             config.vrfCoordinator
//         );

//         // address mostRecentlyDeployed = DevOpsTools.get_most_recent_deployment(
//         //     "Raffle",
//         //     block.chainid
//         // );

//         vm.startBroadcast();
//         vrfCoordinator.addConsumer(config.subscriptionId, address(raffle));
//         vrfCoordinator.fundSubscription(config.subscriptionId, FUND_AMOUNT);
//         vm.stopBroadcast();

//         return (raffle, helperConfig);
//     }

//     // function helper(HelperConfig2.NetworkConfig memory config) public {
//     //     // add a consumer and a fund the subscription

//     // }
// }
