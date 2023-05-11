all: install build

# Install forge dependencies (not needed if submodules are already initialized).
install:; forge install && npm install

# Build contracts and inject the Poseidon library.
build:; forge build 

# Run tests, with debug information and gas reports.
test:; FOUNDRY_PROFILE=debug forge test

# ===== Profiling Rules ===============================================================================================

# Benchmark the tests.
bench:; FOUNDRY_PROFILE=bench forge test --gas-report 

# Snapshot the current test usages.
snapshot:; FOUNDRY_PROFILE=bench forge snapshot 

# ===== Deployment Rules ==============================================================================================

# Deploy contracts 
deploy-airdrop: install build; node --no-warnings scripts/deploy.js deploy-airdrop

mock-airdrop: install build; node --no-warnings scripts/deploy.js mock-airdrop

# ===== Utility Rules =================================================================================================

# Format the solidity code.
format:; forge fmt; npx prettier --write .

# Update forge dependencies.
update:; forge update