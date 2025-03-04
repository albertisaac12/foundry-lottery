-include .env

.PHONY: all test deploy

build :; forge build

test:; forge test

install :; forge install cyfrin/foundry-devops --no-commit && forge install smartcontractkit/chainlink-browine-contracts --no-commit && forge install foundry-rs/forge-std --no-commit && forge install transmissions11/solmate --no-commit

deploy-base-sepolia :
	@forge script script/DeployRaffle.s.sol:DeployRaffle --rpc-url $(BASE_RPC_URL) --account defaultKey --broadcast --verify --etherscan-api-key $(ETHERSCAN_API_KEY) -vvvvv