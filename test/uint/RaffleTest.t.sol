// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {Test, console} from "forge-std/Test.sol";
import {DeployRaffle} from "./../../script/DeployRaffle.s.sol";
import {Raffle} from "./../../src/Raffle.sol";
import {HelperConfig} from "script/HelperConfig.s.sol";
import {Vm} from "forge-std/Vm.sol";
import {VRFCoordinatorV2_5Mock} from "@chainlink/contracts/src/v0.8/vrf/mocks/VRFCoordinatorV2_5Mock.sol";

contract RaffleTest is Test {
    event RaffleEntered(address indexed player);
    event WinnerPicked(address indexed winner);
    event RequestedRaffleWinner(uint256 indexed requestId);

    Raffle public raffle;
    HelperConfig public helperConfig;

    uint256 entranceFee;
    uint256 interval;
    address vrfCoordinator;
    bytes32 gasLane;
    uint256 subscribtionId;
    uint32 callbackGasLimit;

    address public PLAYER = makeAddr("player");
    uint256 public constant startingPlayerBalance = 10 ether;

    // modifier giveEth(address _player) {
    //     vm.deal(_player, startingPlayerBalance);
    //     _;
    // }

    function setUp() external {
        DeployRaffle deployer = new DeployRaffle();

        (raffle, helperConfig) = deployer.deployContract();

        HelperConfig.NetworkConfig memory config = helperConfig.getConfig();
        entranceFee = config.entranceFee;
        interval = config.interval;
        vrfCoordinator = config.vrfCoordinator;
        gasLane = config.gasLane;
        subscribtionId = config.subscriptionId;
        callbackGasLimit = config.callbackGasLimit;

        vm.deal(PLAYER, startingPlayerBalance);
    }

    function testRaffleInitializesInOpenState() external view {
        Raffle.RaffleState state = raffle.getRaffleState();
        assert(state == Raffle.RaffleState.OPEN);
    }

    function testRaffleRevertsWhenNotPayedEnough() external {
        vm.prank(PLAYER);
        vm.expectRevert(Raffle.Raffle__SendMoreToEnterRaffle.selector);
        raffle.enterRaffle();
    }

    function testRaffleAddstoPlayersArray() external /*giveEth(PLAYER)*/ {
        vm.prank(PLAYER);
        raffle.enterRaffle{value: entranceFee}();
        assert(raffle.getPlayers(0) == PLAYER);
    }

    /**
     * Testing Events
     */
    function testWillEmitEventAfterEnteringRaffle() external {
        vm.prank(PLAYER);
        vm.expectEmit(true, false, false, false, address(raffle));
        emit RaffleEntered(PLAYER);

        raffle.enterRaffle{value: entranceFee}();
    }

    function testDontAllowPlayersToEnterRaffleIsCalculating() external {
        vm.startPrank(PLAYER);
        raffle.enterRaffle{value: entranceFee}();

        vm.warp(block.timestamp + raffle.getInterval() + 1);
        vm.roll(block.number + 1);
        raffle.performUpkeep(""); // <- Fix this line

        assert(Raffle.RaffleState.CALCULATING == raffle.getRaffleState());

        vm.expectRevert(Raffle.Raffle__RaffleNotOpen.selector);
        raffle.enterRaffle{value: entranceFee}();
        vm.stopPrank();
    }

    /*//////////////////////////////////////////////////////////////
                              CHECK UPKEEP
    //////////////////////////////////////////////////////////////*/

    function testCheckUpkeepReturnsFalseIfItHasNoBalance() public {
        vm.warp(block.timestamp + raffle.getInterval() + 1);
        vm.roll(block.number + 1);

        //Act

        (bool upKeepNeeded, ) = raffle.checkUpKeep("");

        assert(!upKeepNeeded);
    }

    function testCheckUpKeepReturnsFalseIfRaffleIsNotOpen() public {
        vm.startPrank(PLAYER);
        raffle.enterRaffle{value: entranceFee}();
        vm.warp(block.timestamp + raffle.getInterval() + 1);
        vm.roll(block.number + 1);
        raffle.performUpkeep("");

        (bool upKeepNeeded, ) = raffle.checkUpKeep("");

        assert(!upKeepNeeded);
    }

    function testCheckUpKeepReturnsFalseIfEnoughTimeHasNotPassed() public {
        vm.startPrank(PLAYER);
        raffle.enterRaffle{value: entranceFee}();
        (bool upKeepNeeded, ) = raffle.checkUpKeep("");
        assert(!upKeepNeeded);
    }

    function testUpkeepReturnsTrueWhenParametersAreGood() public {
        vm.startPrank(PLAYER);
        raffle.enterRaffle{value: entranceFee}();
        vm.warp(block.timestamp + raffle.getInterval() + 1);
        vm.roll(block.number + 1);
        (bool upKeepNeeded, ) = raffle.checkUpKeep("");
        assert(upKeepNeeded);
        // console.log(upKeepNeeded);
    }

    /*//////////////////////////////////////////////////////////////
                             PERFORM UPKEEP
    //////////////////////////////////////////////////////////////*/

    function testPerformUpkeepCanOnlyRunIfCheckUpKeepIsTrue() public {
        vm.startPrank(PLAYER);
        raffle.enterRaffle{value: entranceFee}();
        vm.warp(block.timestamp + raffle.getInterval() + 1);
        vm.roll(block.number + 1);
        // (bool upKeepNeeded, ) = raffle.checkUpKeep("");
        // assert(upKeepNeeded);

        raffle.performUpkeep("");

        Raffle.RaffleState state = raffle.getRaffleState();
        assert(state != Raffle.RaffleState.OPEN);
    }

    function testPerformUpkeepRevertsIfCheckUpkeepIsFalse() public {
        uint256 currentBalance = 0;
        uint256 numPlayers = 0;
        Raffle.RaffleState state = raffle.getRaffleState();

        vm.startPrank(PLAYER);
        raffle.enterRaffle{value: entranceFee}();
        currentBalance += entranceFee;
        numPlayers = 1;

        vm.expectRevert(
            abi.encodeWithSelector(
                Raffle.Raffle__UpkeepNotNeeded.selector,
                currentBalance,
                numPlayers,
                state
            )
        );
        raffle.performUpkeep("");
    }

    modifier raffleEntered() {
        vm.prank(PLAYER);
        raffle.enterRaffle{value: entranceFee}();
        vm.warp(block.timestamp + raffle.getInterval() + 1);
        vm.roll(block.number + 1);

        _;
    }

    function testPerformUpkeepUpdatesRaffleStateAndEmitsRequestId()
        public
        raffleEntered
    {
        vm.recordLogs();
        raffle.performUpkeep("");
        Vm.Log[] memory entries = vm.getRecordedLogs();
        bytes32 requestId = entries[1].topics[1];

        // Assert
        Raffle.RaffleState raffleState = raffle.getRaffleState();
        assert(uint256(requestId) > 0);
        assert(uint256(raffleState) == 1);
    }

    modifier skipFork() {
        if (block.chainid != 31337) {
            return;
        }
        _;
    }

    /*//////////////////////////////////////////////////////////////
                           FULFILL RANDOM WORDS
    //////////////////////////////////////////////////////////////*/

    function testFullfilRandomWordsCanOnlyBeCalledAfterPerformUpkeep(
        uint256 reqId
    ) public raffleEntered skipFork {
        vm.expectRevert(VRFCoordinatorV2_5Mock.InvalidRequest.selector);
        VRFCoordinatorV2_5Mock(vrfCoordinator).fulfillRandomWords(
            reqId,
            address(raffle)
        );
    }

    function testFulfillrandomWordsPicksAWinnerAndSendsMoney()
        public
        raffleEntered
        skipFork
    {
        uint256 people = 3;
        uint256 startingIndex = 1;
        // address expectedWinner = address(1);

        uint i = 0;
        for (i; i < startingIndex + people; i++) {
            address newPlayer = address(uint160(i));
            hoax(newPlayer, 1 ether);
            raffle.enterRaffle{value: entranceFee}();
        }
        uint256 startTimeStamp = raffle.getLastTimeStamp();
        // vm.warp(block.timestamp + startTimeStamp + 1);
        // vm.roll(block.number + 1);
        vm.recordLogs();
        raffle.performUpkeep("");
        Vm.Log[] memory entries = vm.getRecordedLogs();
        bytes32 requestId = entries[1].topics[1];
        VRFCoordinatorV2_5Mock(vrfCoordinator).fulfillRandomWords(
            uint256(requestId),
            address(raffle)
        );

        // address recentWinner = raffle.getRecentWinner();
        Raffle.RaffleState raffleState = raffle.getRaffleState();
        uint256 winnerBal = raffle.getRecentWinner().balance;
        uint256 endingTimeStamp = raffle.getLastTimeStamp();
        uint256 prize = entranceFee * (people + 1);

        assert(uint256(raffleState) == 0);
        // assert(recentWinner == expectedWinner);
        // assert(winnerBal == winnerBal + prize);
        assert(address(raffle).balance == 0);
        assert(endingTimeStamp > startTimeStamp);
    }
}
