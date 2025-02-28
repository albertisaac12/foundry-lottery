// // SPDX-License-Identifier: MIT
// pragma solidity ^0.8.19;

// import {Script} from "forge-std/Script.sol";
// import {VRFCoordinatorV2_5Mock} from "@chainlink/contracts/src/v0.8/vrf/mocks/VRFCoordinatorV2_5Mock.sol";
// import {LinkToken} from "./../test/mocks/LinkToken.sol";

// abstract contract CodeConstants2 {
//     uint256 public constant BASE_SEPOLIA_CHAIN_ID = 84532;
//     uint256 public constant LOCAL_CHAIN_ID = 31337;

//     /**Vrf Mock values */
//     uint96 public MOCK_BASE_FEE = 0.25 ether;
//     uint96 public MOCK_GAS_PRICE_LINK = 1e9;

//     /**Link Eth Price */
//     int256 public MOCK_WEI_PER_UINT_LINK = 4e15;
// }

// contract HelperConfig2 is Script, CodeConstants2 {
//     // deploy the Raffle

//     struct NetworkConfig {
//         uint256 entranceFee;
//         uint256 interval;
//         address vrfCoordinator;
//         bytes32 gasLane;
//         uint256 subscriptionId;
//         uint32 callbackGasLimit;
//         address link;
//     }

//     NetworkConfig public localNetworkConfig;

//     function createAnvilConfig() public returns (NetworkConfig memory) {
//         // if (localNetworkConfig.vrfCoordinator != address(0)) {
//         //     return localNetworkConfig;
//         // }

//         vm.startBroadcast();
//         VRFCoordinatorV2_5Mock vrfCoordinator = new VRFCoordinatorV2_5Mock(
//             CodeConstants2.MOCK_BASE_FEE,
//             CodeConstants2.MOCK_GAS_PRICE_LINK,
//             CodeConstants2.MOCK_WEI_PER_UINT_LINK
//         );

//         LinkToken linkToken = new LinkToken();
//         uint256 subscriptionId = vrfCoordinator.createSubscription();
//         vm.stopBroadcast();

//         localNetworkConfig = NetworkConfig({
//             entranceFee: 0.01 ether,
//             interval: 30,
//             vrfCoordinator: address(vrfCoordinator),
//             //dosent matter
//             gasLane: 0x9e1344a1247c8a1785d0a4681a27152bffdb43666ae5bf7d14d24a5efd44bf71,
//             subscriptionId: subscriptionId,
//             callbackGasLimit: 500_000,
//             link: address(linkToken)
//         });

//         return localNetworkConfig;
//     }

//     function getConfig() external view returns (NetworkConfig memory) {
//         return localNetworkConfig;
//     }
// }
