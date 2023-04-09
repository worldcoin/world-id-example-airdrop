# Zero-Knowledge Gated Airdrop

> A template to airdrop an ERC-20 token to a group of addresses, while preserving privacy for the claimers.

This repository uses [the Semaphore library](http://semaphore.appliedzkp.org) to allow members of a set to claim an ERC-20 token, preserving their privacy and removing the link between the group and the claimer address thanks to zero-knowledge proofs.

## Deployment

First, you'll need a contract that adheres to the [ISemaphore](./src/interfaces/ISemaphore.sol) interface to manage the zero-knowledge groups. If you don't have any special requirements, you can use [this one](./src/Semaphore.sol). Next, you'll need to create a Semaphore group (`Semaphore.createGroup(YOUR_GROUP_ID, 20, 0)` should do the trick). You'll also need an address that holds the tokens to be airdropped (remember to grant access to the airdrop contract after deployment by calling `ERC20.approve(AIRDROP_CONTRACT_ADDRESS, A_VERY_HIGH_NUMBER)`). Finally, deploy the `WorldIDAirdrop` contract with the Semaphore contract address, the group id, the address of your ERC20 token, the address of the holder, and the amount of tokens to give to each claimer.

## Usage

Since only members of a group can claim the airdrop, you'll need to add some entries to your Semaphore group first. End-users will need to generate an identity commitment (which can be done through the [@zk-kit/identity](https://github.com/appliedzkp/zk-kit/tree/main/packages/identity) or [semaphore-rs](https://github.com/worldcoin/semaphore-rs) SDKs). Once they have one, you can add it to the group by calling `Semaphore.addMember(YOUR_GROUP_ID, IDENTITY_COMMITMENT)`.

Once users have identities included on the configured group, they should generate a nullifier hash and a proof for it (which can be done through the [@zk-kit/protocols](https://github.com/appliedzkp/zk-kit/tree/main/packages/protocols) or [semaphore-rs](https://github.com/worldcoin/semaphore-rs) SDKs, using the address who will receive the tokens as the signal). Once they have both, they can claim the aidrop by calling `WorldIDAirdrop.claim(RECEIVER_ADDRESS, NULLIFIER_HASH, SOLIDITY_ENCODED_PROOF)`.

You can see the complete flow in action on the [WorldIDAirdrop tests](./src/test/WorldIDAirdrop.t.sol).

## Usage with Worldcoin

Worldcoin will maintain a Semaphore instance with a group for all the people that have onboarded to the protocol. Once the insance is deployed, we'll provide information here so you can point your `WorldIDAirdrop` instances to it, ensuring only unique humans can claim your airdrop.

## Development

This repository uses the [Foundry](https://github.com/gakonst/foundry) smart contract toolkit. You can download the Foundry installer by running `curl -L https://foundry.paradigm.xyz | bash`, and then install the latest version by running `foundryup` on a new terminal window (additional instructions are available [on the Foundry repo](https://github.com/gakonst/foundry#installation)). You'll also need [Node.js](https://nodejs.org) if you're planning to run the automated tests.

Once you have everything installed, you can run `make` from the base directory to install all dependencies, build the smart contracts, and configure the Poseidon Solidity library.


<!-- WORLD-ID-SHARED-README-TAG:START - Do not remove or modify this section directly -->
<!-- The contents of this file are inserted to all World ID repositories to provide general context on World ID. -->

## <img align="left" width="28" height="28" src="https://raw.githubusercontent.com/worldcoin/world-id-docs/main/public/images/shared-readme/readme-world-id.png" alt="" style="margin-right: 0;" /> About World ID

World ID is a protocol that lets you **prove a human is doing an action only once without revealing any personal data**. Stop bots, stop abuse.

World ID uses a device called the [Orb](https://worldcoin.org/how-the-launch-works) which takes a picture align="center" of a person's iris to verify they are a unique and alive human. The protocol uses [Zero-knowledge proofs](https://id.worldcoin.org/zkp) so no traceable information is ever public.

World ID is meant for on-chain web3 apps, traditional cloud applications, and even IRL verifications.

<div align="center">
  <picture align="center">
    <source media="(prefers-color-scheme: dark)" srcset="./public/images/shared-readme/diagram-dark-1.png" />
    <source media="(prefers-color-scheme: light)" srcset="./public/images/shared-readme/diagram-light-1.png" />
    <img width="150px"  />
  </picture>

  <picture align="center">
    <source media="(prefers-color-scheme: dark)" srcset="./public/images/shared-readme/diagram-dark-2.png" />
    <source media="(prefers-color-scheme: light)" srcset="./public/images/shared-readme/diagram-light-2.png" />
    <img width="150px"  />
  </picture>

  <picture align="center">
    <source media="(prefers-color-scheme: dark)" srcset="./public/images/shared-readme/diagram-dark-3.png" />
    <source media="(prefers-color-scheme: light)" srcset="./public/images/shared-readme/diagram-light-3.png" />
    <img width="150px"  />
  </picture>

  <picture align="center">
    <source media="(prefers-color-scheme: dark)" srcset="./public/images/shared-readme/diagram-dark-4.png" />
    <source media="(prefers-color-scheme: light)" srcset="./public/images/shared-readme/diagram-light-4.png" />
    <img width="150px"  />
  </picture>
</div>

### Getting started with World ID

Regardless of how you landed here, the easiest way to get started with World ID is through the the [Dev Portal](https://developer.worldcoin.org).

<a href="https://developer.worldcoin.org">
  <p align="center">
    <picture align="center">
      <source media="(prefers-color-scheme: dark)" srcset="./public/images/shared-readme/get-started-dark.png" height="80px" />
      <source media="(prefers-color-scheme: light)" srcset="./public/images/shared-readme/get-started-light.png" height="50px" />
      <img />
    </picture>
  </p>
</a>

### World ID Demos

Want to see World ID in action? We have a bunch of [Examples](https://id.worldcoin.org/examples).

<div dir="row" align="center">
  <a href="https://poap.worldcoin.org/">
    <picture align="center">
      <source media="(prefers-color-scheme: dark)" srcset="./public/images/shared-readme/examples/poap-dark.png" width="230px" />
      <source media="(prefers-color-scheme: light)" srcset="./public/images/shared-readme/examples/poap-light.png" width="230px" />
      <img />
    </picture>
  </a>
  <a href="https://human.withlens.app/">
    <picture align="center">
      <source media="(prefers-color-scheme: dark)" srcset="./public/images/shared-readme/examples/lens-dark.png" width="230px" />
      <source media="(prefers-color-scheme: light)" srcset="./public/images/shared-readme/examples/lens-light.png" width="230px" />
      <img />
    </picture>
  </a>
  <a href="https://github.com/worldcoin/world-id-discord-bot">
    <picture align="center">
      <source media="(prefers-color-scheme: dark)" srcset="./public/images/shared-readme/examples/discord-bot-dark.png" width="230px" />
      <source media="(prefers-color-scheme: light)" srcset="./public/images/shared-readme/examples/discord-bot-light.png" width="230px" />
      <img />
    </picture>
  </a>
  <a href="https://github.com/worldcoin/hyperdrop-contracts">
    <picture align="center">
      <source media="(prefers-color-scheme: dark)" srcset="./public/images/shared-readme/examples/hyperdrop-dark.png" width="230px" />
      <source media="(prefers-color-scheme: light)" srcset="./public/images/shared-readme/examples/hyperdrop-light.png" width="230px" />
      <img />
    </picture>
  </a>
  <a href="https://petorbz.com/">
    <picture align="center">
      <source media="(prefers-color-scheme: dark)" srcset="./public/images/shared-readme/examples/pet-orbz-dark.png" width="230px" />
      <source media="(prefers-color-scheme: light)" srcset="./public/images/shared-readme/examples/pet-orbz-light.png" width="230px" />
      <img />
    </picture>
  </a>
</div>

## 📄 Documentation

We have comprehensive docs for World ID at https://id.worldcoin.org/docs.

<a href="https://id.worldcoin.org/docs">
  <p align="center">
    <picture align="center">
      <source media="(prefers-color-scheme: dark)" srcset="./public/images/shared-readme/visit-documentation-dark.png" height="80px" />
      <source media="(prefers-color-scheme: light)" srcset="./public/images/shared-readme/visit-documentation-light.png" height="50px" />
      <img />
    </picture>
  </p>
</a>

## 🗣 Feedback

**World ID is in Beta, help us improve!** Please share feedback on your experience. You can find us on [Discord](https://discord.gg/worldcoin), look for the [#world-id](https://discord.com/channels/956750052771127337/968523914638688306) channel. You can also open an issue or a PR directly on this repo.

<a href="https://discord.gg/worldcoin">
  <p align="center">
    <picture align="center">
      <source media="(prefers-color-scheme: dark)" srcset="./public/images/shared-readme/join-discord-dark.png" height="80px" />
      <source media="(prefers-color-scheme: light)" srcset="./public/images/shared-readme/join-discord-light.png" height="50px" />
      <img />
    </picture>
  </p>
</a>

<!-- WORLD-ID-SHARED-README-TAG:END -->
