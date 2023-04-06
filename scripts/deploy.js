import ora from 'ora';
import dotenv from 'dotenv';
import readline from 'readline';
import { Wallet } from '@ethersproject/wallet';
import { hexlify, concat } from '@ethersproject/bytes';
import { JsonRpcProvider } from '@ethersproject/providers';
import { Contract } from '@ethersproject/contracts';
import { defaultAbiCoder as abi } from '@ethersproject/abi';
import WorldIDAirdrop from '../out/WorldIDAirdrop.sol/WorldIDAirdrop.json' assert { type: 'json' };
import WorldIDMultiAirdrop from '../out/WorldIDMultiAirdrop.sol/WorldIDMultiAirdrop.json' assert { type: 'json' };
import IncrementalBinaryTree from '../out/IncrementalBinaryTree.sol/IncrementalBinaryTree.json' assert { type: 'json' };
import ERC20 from '../out/ERC20.sol/ERC20.json' assert { type: 'json' };
dotenv.config();

let validConfig = true;
if (process.env.RPC_URL === undefined) {
  console.log('Missing RPC_URL');
  validConfig = false;
}
if (process.env.PRIVATE_KEY === undefined) {
  console.log('Missing PRIVATE_KEY');
  validConfig = false;
}
if (!validConfig) process.exit(1);

const provider = new JsonRpcProvider(process.env.RPC_URL);

const ask = async question => {
  const rl = readline.createInterface({
    input: process.stdin,
    output: process.stdout,
  });

  return new Promise(resolve => {
    rl.question(question, input => {
      resolve(input);
      rl.close();
    });
  });
};

async function deployAirdrop(semaphoreAddress) {
  const [groupId, actionId, erc20Address, holderAddress, airdropAmount] = [
    await ask('Semaphore group id: '),
    await ask('ActionId: '),
    await ask('ERC20 address: '),
    await ask('ERC20 holder address: '),
    await ask('Amount to airdrop: '),
  ];

  const spinner = ora(`Deploying WorldIDAirdrop contract...`).start();

  let tx = await wallet.sendTransaction({
    data: hexlify(
      concat([
        WorldIDAirdrop.bytecode.object,
        abi.encode(WorldIDAirdrop.abi[0].inputs, [
          semaphoreAddress,
          groupId,
          actionId,
          erc20Address,
          holderAddress,
          airdropAmount,
        ]),
      ])
    ),
  });
  spinner.text = `Waiting for WorldIDAirdrop deploy transaction (tx: ${tx.hash})`;
  tx = await tx.wait();
  spinner.succeed(`Deployed WorldIDAirdrop contract to ${tx.contractAddress}`);

  return tx.contractAddress;
}

async function setAllowance() {
  const [tokenAddress, holder, amount] = [
    await ask('ERC20 address: '),
    await ask('Spender address: '),
    await ask('Amount: '),
  ];

  const spinner = ora(`setting allowance...`).start();

  const contract = new Contract(tokenAddress, ERC20.abi, wallet);
  const tx = await contract.approve(holder, amount, {
    maxPriorityFeePerGas: 31e9,
    maxFeePerGas: 60e9,
  });

  spinner.text = `Waiting for approve transaction (tx: ${tx.hash})`;
  spinner.succeed(`Allowance set for ${holder}!`);
}

async function main(worldIDAddress) {
  if (!worldIDAddress) {
    await deployWorldIDContracts();
  }

  const option = await ask(
    'Deploy WorldIDAirdrop (1), WorldIDMultiAirdrop (2) or set allowance (3): '
  ).then(answer => answer.trim());

  switch (option) {
    case '1':
      await deployAirdrop(semaphoreAddress);
      break;
    case '2':
      await deployMultiAirdrop(semaphoreAddress);
      break;
    case '3':
      await setAllowance();
      break;

    default:
      console.log('Please enter either 1, 2 or 3. Exiting...');
      process.exit(1);
      break;
  }
}

main(...process.argv.splice(2)).then(() => process.exit(0));
