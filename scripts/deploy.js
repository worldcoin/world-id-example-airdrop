import fs from 'fs';
import ora from 'ora';
import dotenv from 'dotenv';
import readline from 'readline';
import { Command } from 'commander';
import { execSync } from 'child_process';

const DEFAULT_RPC_URL = 'http://localhost:8545';
const CONFIG_FILENAME = 'script/.deploy-config.json';

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

async function loadConfiguration(useConfig) {
  if (!useConfig) {
    return {};
  }

  let answer = await ask(`Do you want to load configuration from prior runs? [Y/n]: `, 'bool');
  const spinner = ora('Configuration Loading').start();
  if (answer === undefined) {
    answer = true;
  }
  if (answer) {
    if (!fs.existsSync(CONFIG_FILENAME)) {
      spinner.warn('Configuration load requested but no configuration available: continuing');
      return {};
    }
    try {
      const fileContents = JSON.parse(fs.readFileSync(CONFIG_FILENAME).toString());
      if (fileContents) {
        spinner.succeed('Configuration loaded');
        return fileContents;
      } else {
        spinner.warn('Unable to parse configuration: deleting and continuing');
        fs.rmSync(CONFIG_FILENAME);
        return {};
      }
    } catch {
      spinner.warn('Unable to parse configuration: deleting and continuing');
      fs.rmSync(CONFIG_FILENAME);
      return {};
    }
  } else {
    spinner.succeed('Configuration not loaded');
    return {};
  }
}

async function saveConfiguration(config) {
  const oldData = (() => {
    try {
      return JSON.parse(fs.readFileSync(CONFIG_FILENAME).toString());
    } catch {
      return {};
    }
  })();

  const data = JSON.stringify({ ...oldData, ...config });
  fs.writeFileSync(CONFIG_FILENAME, data);
}

async function getPrivateKey(config) {
  if (!config.privateKey) {
    config.privateKey = process.env.PRIVATE_KEY;
  }
  if (!config.privateKey) {
    config.privateKey = await ask('Enter your private key: ');
  }
}

async function getEthereumRpcUrl(config) {
  if (!config.ethereumRpcUrl) {
    config.ethereumRpcUrl = process.env.ETH_RPC_URL;
  }
  if (!config.ethereumRpcUrl) {
    config.ethereumRpcUrl = await ask(`Enter Ethereum RPC URL: (${DEFAULT_RPC_URL}) `);
  }
  if (!config.ethereumRpcUrl) {
    config.ethereumRpcUrl = DEFAULT_RPC_URL;
  }
}

async function getEtherscanApiKey(config) {
  if (!config.ethereumEtherscanApiKey) {
    config.ethereumEtherscanApiKey = process.env.ETHERSCAN_API_KEY;
  }
  if (!config.ethereumEtherscanApiKey) {
    config.ethereumEtherscanApiKey = await ask(
      `Enter Ethereum Etherscan API KEY: (https://etherscan.io/myaccount) `
    );
  }
}

async function getWorldIDIdentityManagerRouterAddress(config) {
  if (!config.worldIDRouterAddress) {
    config.worldIDRouterAddress = process.env.WORLD_ID_ROUTER_ADDRESS;
  }
  if (!config.worldIDRouterAddress) {
    config.worldIDRouterAddress = await ask('Enter the WorldIDRouter address: ');
  }
}

async function getWorldIDRouterGroupId(config) {
  if (!config.groupId) {
    config.groupId = process.env.GROUP_ID;
  }
  if (!config.groupId) {
    config.groupId = await ask('Enter WorldIDRouter group id: ');
  }
}

async function getActionId(config) {
  if (!config.actionId) {
    config.actionId = process.env.ACTION_ID;
  }
  if (!config.actionId) {
    config.actionId = await ask('Enter ActionId: ');
  }
}

async function getErc20Address(config) {
  if (!config.erc20Address) {
    config.erc20Address = process.env.ERC20_ADDRESS;
  }
  if (!config.erc20Address) {
    config.erc20Address = await ask('Enter ERC20 address: ');
  }
}

async function getHolderAddress(config) {
  if (!config.holderAddress) {
    config.holderAddress = process.env.HOLDER_ADDRESS;
  }
  if (!config.holderAddress) {
    config.holderAddress = await ask('Enter ActionId: ');
  }
}

async function getAirdropAmount(config) {
  if (!config.airdropAmount) {
    config.airdropAmount = process.env.AIRDROP_AMOUNT;
  }
  if (!config.airdropAmount) {
    config.airdropAmount = await ask('Enter amount to airdrop: ');
  }
}

async function getAirdropParameters(config) {
  await getWorldIDRouterGroupId(config);
  await getActionId(config);
  await getErc20Address(config);
  await getHolderAddress(config);
  await getAirdropAmount(config);

  await saveConfiguration(config);
}

async function deployAirdrop(config) {
  dotenv.config();

  await getPrivateKey(config);
  await getEthereumRpcUrl(config);
  await getEtherscanApiKey(config);
  await getWorldIDIdentityManagerRouterAddress(config);
  await saveConfiguration(config);
  await getAirdropParameters(config);

  const spinner = ora(`Deploying WorldIDAirdrop contract...`).start();

  try {
    const data = execSync(
      `forge script script/WorldIDAirdrop.s.sol:DeployWorldIDAirdrop --fork-url ${config.ethereumRpcUrl} \
      --etherscan-api-key ${config.ethereumEtherscanApiKey} --broadcast --verify -vvvv`
    );
    console.log(data.toString());
    spinner.succeed('Deployed WorldIDAirdrop contract successfully!');
  } catch (err) {
    console.error(err);
    spinner.fail('Deployment of WorldIDAirdrop has failed.');
  }
}

async function deployMockAirdrop(config) {
  dotenv.config();

  await getPrivateKey(config);
  await getEthereumRpcUrl(config);
  await getEtherscanApiKey(config);
  await deployWorldIDIdentityManagerRouterMock(config);
  await getWorldIDIdentityManagerRouterAddress(config);
  await saveConfiguration(config);
  await getAirdropParameters(config);

  const spinner = ora(`Deploying WorldIDAirdrop contract...`).start();

  try {
    const data = execSync(
      `forge script script/WorldIDAirdrop.s.sol:DeployWorldIDAirdrop --fork-url ${config.ethereumRpcUrl} \
      --etherscan-api-key ${config.ethereumEtherscanApiKey} --broadcast --verify -vvvv`
    );
    console.log(data.toString());
    spinner.succeed('Deployed WorldIDAirdrop contract successfully!');
  } catch (err) {
    console.error(err);
    spinner.fail('Deployment of WorldIDAirdrop has failed.');
  }
}

async function deployMockMultiAirdrop(config) {
  dotenv.config();

  await getPrivateKey(config);
  await getEthereumRpcUrl(config);
  await getEtherscanApiKey(config);
  await deployWorldIDIdentityManagerRouterMock(config);
  await getWorldIDIdentityManagerRouterAddress(config);
  await saveConfiguration(config);
  await getAirdropParameters(config);

  const spinner = ora(`Deploying WorldIDAirdrop contract...`).start();

  try {
    const data = execSync(
      `forge script scripts/WorldIDMultiAirdrop.s.sol:DeployWorldIDMultiAirdrop --fork-url ${config.ethereumRpcUrl} \
      --etherscan-api-key ${config.ethereumEtherscanApiKey} --broadcast --verify -vvvv`
    );
    console.log(data.toString());
    spinner.succeed('Deployed WorldIDMultiAirdrop contract successfully!');
  } catch (err) {
    console.error(err);
    spinner.fail('Deployment of WorldIDMultiAirdrop has failed.');
  }
}

async function setAllowance(config) {
  await getErc20Address(config);
  await getHolderAddress(config);
  await getAirdropAmount(config);

  await saveConfiguration(config);

  const spinner = ora(`setting allowance...`).start();

  try {
    const data = execSync(
      `forge script scripts/utils/SetAllowanceERC20.s.sol:SetAllowanceERC20 --fork-url ${config.ethereumRpcUrl} \
      --etherscan-api-key ${config.ethereumEtherscanApiKey} --broadcast --verify -vvvv`
    );
    console.log(data.toString());

    spinner.succeed(`Allowance set for ${config.holderAddress}!`);
  } catch (err) {
    console.error(err);
    spinner.fail(`Setting allowance for ${config.holderAddress} failed.`);
  }
}

async function main() {
  let config = await loadConfiguration();

  const program = new Command();

  program
    .name('deploy-airdrop')
    .command('deploy-airdrop')
    .description('Interactively deploys the WorldIDAirdrop contracts on Ethereum mainnet.')
    .action(async () => {
      const options = program.opts();
      let config = await loadConfiguration(options.config);
      await deployAirdrop(config);
      await saveConfiguration(config);
    });

  program
    .name('deploy-multi-aidrop')
    .command('deploy-multi-airdrop')
    .description('Interactively deploys the WorldIDMultiAirdrop contracts on Ethereum mainnet.')
    .action(async () => {
      const options = program.opts();
      let config = await loadConfiguration(options.config);
      await deployMultiAirdrop(config);
      await saveConfiguration(config);
    });

  program
    .name('mock-airdrop')
    .command('mock-airdrop')
    .description(
      'Interactively deploys WorldIDIdentityManagerMock alongside with WorldIDAirdrop for testing.'
    )
    .action(async () => {
      const options = program.opts();
      let config = await loadConfiguration(options.config);
      await deployMockAirdrop(config);
      await saveConfiguration(config);
    });

  program
    .name('mock-multi-airdrop')
    .command('mock-multi-airdrop')
    .description(
      'Interactively deploys WorldIDIdentityManagerMock alongside with WorldIDMultiAirdrop for testing.'
    )
    .action(async () => {
      const options = program.opts();
      let config = await loadConfiguration(options.config);
      await deployMockMultiAirdrop(config);
      await saveConfiguration(config);
    });

  program
    .name('set-allowance')
    .command('set-allowance')
    .description('Sets ERC20 token allowance of the holder address to the specified amount.')
    .action(async () => {
      const options = program.opts();
      let config = await loadConfiguration(options.config);
      await setAllowance(config);
      await saveConfiguration(config);
    });
}

main().then(() => process.exit(0));
