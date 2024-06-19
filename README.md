## Ethernaut solutions using Foundry

Running solution using a Forge script
```
CONTRACT=0xAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA forge script --rpc-url $ETH_RPC_URL --broadcast script/Level00.s.sol
```

Running solution using a Cast script
```
bash cast_solutions/level00.sh 0xAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA 
```

Testing the solutions locally with Anvil
```
export ETH_RPC_URL="http://127.0.0.1:8545"
export CHAIN="31337"
forge create --private-key $PRIVATE_KEY src/LevelXX.sol:CONTRACT_NAME

bash cast_solutions/levelXX.sh DEPLOYED_TO_ADDRESS
```
