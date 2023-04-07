all: install build
# Install forge dependencies (not needed if submodules are already initialized).
install:; forge install && npm install
# Build contracts and inject the Poseidon library.
build:; forge build 
# Run tests, with debug information and gas reports.
test:; forge test -vvv --gas-report
# Deploy contracts
deploy:; node --no-warnings scripts/deploy.js

# ===== Deployment Rules ==============================================================================================

# Deploy contracts 
deploy-airdrop: install build; node --no-warnings script/deploy.js deploy-airdrop

deploy-multi-airdrop: install build; node --no-warnings script/deploy.js deploy-multi-airdrop

mock-airdrop: install build; node --no-warnings script/deploy.js mock-airdrop

mock-multi-airdrop: install build; node --no-warnings script/deploy.js mock-multi-airdrop

# ===== Utility Rules =================================================================================================

# Format the solidity code.
format:; forge fmt; npx prettier --write .

# Update forge dependencies.
update:; forge update