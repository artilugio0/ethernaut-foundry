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

SOLVER_ADDRESS=$(cast compute-address $(cast wallet address ${PRIVATE_KEY}) | awk '{print $3}')
echo "Create address: ${SOLVER_ADDRESS}"

echo "Creating small contract"
cast send \
	--private-key ${PRIVATE_KEY} \
	--create \
	0x600a600c600039600a6000f3602a60005260206000f3

echo "Setting solver"
cast send \
	--private-key ${PRIVATE_KEY} \
	${CONTRACT} \
	$(cast calldata "setSolver(address)" ${SOLVER_ADDRESS})

RESULT=$(cast call ${SOLVER_ADDRESS} $(cast calldata "whatIsTheMeaningOfLife()(uint256)") | cast to-dec)
echo "Result: ${RESULT}"

if [ ${RESULT} -eq 42 ]
then
	echo "Level completed, submit instance"
else
	echo "ERROR: Solution failed"
fi
