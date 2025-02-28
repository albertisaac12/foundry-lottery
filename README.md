## Foundry pt 2

Follow a Style Guide :

1. Pragma
2. Import statement
3. errors
4. Interfaces
5. Libraries
6. Contracts

Inside each contract, library or interface, use the following order :

1. Type declarations
2. State variables
3. Events
4. Modifiers
5. Functions :
   1. constructor
   2. receive functions (if exists)
   3. fallback function (if exists)
   4. external
   5. public
   6. internal
   7. private
6. Within a grouping, place the view and pure functions at last.

// if (msg.value < i_entranceFee) revert SendMoreToEnterRaffle();
// this is still cheaper than require(msg.value > i_entranceFee,SendMoreToEnterRaffle()); // and to let this run we need to compile this via-ir.

// Why use events ?

1. Makes migration easier
2. Makes front end "indexing" easier

EVM logs are a data structure
events allow you to "print" stuff to this log data structure (probably bloom filter)

to index events we use the graph and stores then so that we can later query them at a later date

indexed events and events , at max an event can have only 3 indexed parameters and these are `indexed events` are called `Topics` and topics are searchable and much easier to query and much more searchable

Non indexed get abi encoded and we need to know the abi to decode them again

Topics: indexed events
Data: abi.encoded (non-indexed) events

abstract contract can have both defined and undefined functions and when imported we need to implement all the undefined functions

CEI: Checks Effects(internal) Interaction(external) Patterns

checkUpKeep and performUpKeep both will be called by chainlink nodes now

checkUpKeep := checks if the lottery is done and updates the upKeepNeeded variable
performUpKeep := picks up the winner for us (only if upKeepNeeded is true)

## Tests

1. Write deploy scripts
2. Write tests
   1. Local chain
   2. Forked Testnet
   3. Forked Mainnet

HelperConfig.NetworkConfig memory config // this is a way to get the struct variable or directly referencing it.

expectEmit(topic,topic,topic,data,address);
emit event; // copy paste the actual events into the test file

match test is now --mt

vm.warp(); // sets the block.timestamp
vm.roll(); // forwards the blocknumber

cast sig "function()";

openchain.xyz // database of function signatures

Helper Config helps you to deploy the contracts and provides the instances back to the deploy script which then is used inside the tests to carry out the tests.
