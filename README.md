# Nouns love


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

