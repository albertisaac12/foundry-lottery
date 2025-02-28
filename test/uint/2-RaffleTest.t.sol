// // SPDX-License-Identifier: MIT
// pragma solidity ^0.8.19;

// import {Test} from "forge-std/Test.sol";
// import {DeployRaffle2} from "./../../script/2-DeployRaffle.s.sol";
// import {Raffle} from "./../../src/Raffle.sol";
// import {HelperConfig2} from "script/2-HelperConfig.s.sol";

// contract raffleTest is Test {
//     // deploy the raffle contract
//     // deploy mock vrf coordinator => done
//     // create a subscription => done
//     // deploy a mock link token => done
//     // fund the subscription
//     // add the raffle as a consumer
//     // test the function

//     event RaffleEntered(address indexed player);
//     event WinnerPicked(address indexed winner);

//     Raffle public raffle;
//     HelperConfig2 public helperConfig;

//     uint256 entranceFee;
//     uint256 interval;
//     address vrfCoordinator;
//     bytes32 gasLane;
//     uint256 subscribtionId;
//     uint32 callbackGasLimit;

//     address public PLAYER = makeAddr("player");
//     uint256 public constant startingPlayerBalance = 10 ether;

//     function setUp() external {
//         DeployRaffle2 deployer = new DeployRaffle2();
//         (raffle, helperConfig) = deployer.deployContractAndSetup();

//         HelperConfig2.NetworkConfig memory config = helperConfig.getConfig();

//         entranceFee = config.entranceFee;
//         interval = config.interval;
//         vrfCoordinator = config.vrfCoordinator;
//         gasLane = config.gasLane;
//         subscribtionId = config.subscriptionId;
//         callbackGasLimit = config.callbackGasLimit;

//         vm.deal(PLAYER, startingPlayerBalance);
//     }

//     function testOneIsOne() external {}

//     function testDontAllowPlayersToEnterRaffleIsCalculating() external {
//         vm.startPrank(PLAYER);
//         raffle.enterRaffle{value: entranceFee}();

//         vm.warp(block.timestamp + raffle.getInterval() + 1);
//         vm.roll(block.number + 1);
//         raffle.performUpkeep(""); // <- Fix this line

//         assert(Raffle.RaffleState.CALCULATING == raffle.getRaffleState());

//         vm.expectRevert(Raffle.Raffle__RaffleNotOpen.selector);
//         raffle.enterRaffle{value: entranceFee}();
//         vm.stopPrank();
//     }
// }
