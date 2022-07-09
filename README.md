# On-chain asset Store

On-chain asset store, which allows multiple smart contracts to shara vector assets.

All assets registered to this store will be treated as cc0 (public domain),
CC-BY(attribution), Apache 2.0 or MIT (should be specified in the "group").
In case of CC-BY, the creater's name should be in the "group", "category" or "name".

All registered assets will be available to other smart contracts for free, including
commecial services. Therefore, it is not allowed to register assets that require
any form of commercial licenses.

Once an asset is registed with group/category/name, it is NOT possible to update,
which guaranttees the availability in future.

Created by Satoshi Nakajima (@snakajima)

## WebUI repository

The corresponding WebUI respository assumes that it can access this repository via "../contract" to access some generated contents in the "cache" folder. 

## Setup package

```
yarn install
```

## Setup your wallet

### setup .env for rinkeby

#### Web3 Provider

Get Api key from Web3 Provider and set API KEY

```
INFURA_API_KEY = "xxxxx"
```

or

```
ALCHEMY_API_KEY = "xxxx"
```

#### Your Account

Set your account


```
MNEMONIC = "hoge hoge hoge"
ACCOUNT_INITIAL_INDEX = 2
```

or 

```
PRIVATE_KEY= "hogehoge"
```

### deploy to rinkeby

```
npx hardhat --network rinkeby run scripts/deploy-rinkeby.ts 
```

## deploy to local

```
npx hardhat --network localhost run scripts/deploy.ts 
```

# Etherscan verification

```
npx hardhat verify --network mainnet --constructor-args arguments.js CONTRACT_ADDRESS
```

# local unit test

```
npx hardhat test --network hardhat
```
