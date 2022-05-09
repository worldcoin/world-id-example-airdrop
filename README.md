<img src="https://raw.githubusercontent.com/worldcoin/world-id-js/main/world-id-logo.svg" alt="World ID logo" width="300" />

# World ID Example - Mesha Airdrop (Smart contract)

This repository contains an example smart contract for [World ID](https://id.worlcoin.org). With Mesha Airdrop, test airdropping an ERC-20 token validating a single person can only claim a token once.

> World ID is a mechanism to verify a single human has performed a specific action only once without exposing any personal information.

This repository contains the smart contract code. **Please check [this repository][dapp] for the dapp example.**

This repository uses [the Semaphore library](http://semaphore.appliedzkp.org) to allow members of a set to claim an ERC-20 token, preserving their privacy and removing the link between the group and the claimer address thanks to zero-knowledge proofs.

## 🚀 Deployment

1. First, you'll need a contract that adheres to the [ISemaphore](./src/interfaces/ISemaphore.sol) interface to manage the zero-knowledge groups. If you don't have any special requirements, you can use [this one](./src/Semaphore.sol).
2. Create a Semaphore group (`Semaphore.createGroup(YOUR_GROUP_ID, 20, 0)` should do the trick).
3. You'll need an address that holds the tokens to be airdropped (remember to grant access to the airdrop contract after deployment by calling `ERC20.approve(AIRDROP_CONTRACT_ADDRESS, A_VERY_HIGH_NUMBER)`).
4. Finally, deploy the `SemaphoreAirdrop` contract with the Semaphore contract address, the group id, the address of your ERC20 token, the address of the holder, and the amount of tokens to give to each claimer.

## 🗝 Usage instructions

Since only members of a group can claim the airdrop, you'll need to add some entries to your Semaphore group first.
1. End users will need to generate an identity commitment, which can be done through the [mockWLD app](https://mock-app.id.worldcoin.org) ([docs for mock app](https://id.worldcoin.org/test)).
2. Add the identity commitment to the group by calling `Semaphore.addMember(YOUR_GROUP_ID, IDENTITY_COMMITMENT)`. _The mockWLD app contains a faucet to add the identity to the [Worldcoin instance](#-worldcoin-instance) (if you are using it)_.
3. Once a user has their identity included in the configured group, they can generate a nullifier hash, merkle root and ZKP to claim the airdrop. You can generate that proof by doing a quick deployment of the [World ID JS Integration](https://id.worldcoin.org/docs/js). You need to use the receiver's address as the signal, and use the deployed `SempahoreAirdrop`'s encoded (see `hashBytes` function in the [dapp][dapp] repository) address as the action ID (internally called external nullifier).
4. With all three parameters, the aidrop can be claimed by calling `SemaphoreAirdrop.claim(RECEIVER_ADDRESS, MERKLE_ROOT, NULLIFIER_HASH, SOLIDITY_ENCODED_PROOF)`

You can see the complete flow in action on the [SemaphoreAirdrop tests](./src/test/SemaphoreAirdrop.t.sol).

## 🤓 Advanced usage

You can generate your own identity commitments and proofs without relying on the mockWLD app or the JS integration, just follow these steps:

- **Identity commitment**. Can be generated through the [@zk-kit/identity](https://github.com/appliedzkp/zk-kit/tree/main/packages/identity) or [semaphore-rs](https://github.com/worldcoin/semaphore-rs) SDKs.
- **Zero-knowledge proof**. Can be generated with the through the [@zk-kit/protocols](https://github.com/appliedzkp/zk-kit/tree/main/packages/protocols) or [semaphore-rs](https://github.com/worldcoin/semaphore-rs) SDKs, using the address who will receive the tokens as the signal.

## 🌎 Worldcoin instance

Worldcoin maintains an official Semaphore instance with a group for all the people that have onboarded to the protocol. You can point your `SemaphoreAirdrop` instances directly to it. The production instance contains only identities that have been [verified at an orb](https://worldcoin.org/how-the-launch-works), ensuring only unique humans can claim your airdrop.

- **Staging instance**. For use with the [mockWLD app](https://mock-app.id.worldcoin.org) and the related faucet.   
    ```
    Contact address: `0x330C8452C879506f313D1565702560435b0fee4C`
    ```
- **Production instance**. For use with the actual Worldcoin app and orb verification.
    ```
    Contact address: Coming soon.
    ```

## 🧑‍💻 Development & testing

This repository uses the [Foundry](https://github.com/gakonst/foundry) smart contract toolkit. You can download the Foundry installer by running `curl -L https://foundry.paradigm.xyz | bash`, and then install the latest version by running `foundryup` on a new terminal window (additional instructions are available [on the Foundry repo](https://github.com/gakonst/foundry#installation)). You'll also need [Node.js](https://nodejs.org) if you're planning to run the automated tests.

Once you have everything installed, you can run `make` from the base directory to install all dependencies, build the smart contracts, and configure the Poseidon Solidity library.

## 📄 Documentation

Full documentation for this and all World ID examples can be found at [https://id.worldcoin.org/docs/examples](https://id.worldcoin.org/docs/examples).

## 🧑‍⚖️ License

This repository is MIT licensed. Please review the LICENSE file in this repository.

Copyright (C) 2022 Tools for Humanity Corporation.


[dapp]: https://github.com/worldcoin/world-id-example-airdrop-dapp