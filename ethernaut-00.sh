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

OUTPUT=$(cast call ${CONTRACT} "$(cast sig 'info()')")
cast to-ascii $OUTPUT
echo

OUTPUT=$(cast call ${CONTRACT} "$(cast sig 'info1()')")
cast to-ascii $OUTPUT
echo

OUTPUT=$(cast call ${CONTRACT} "$(cast calldata 'info2(string)' hello)")
cast to-ascii $OUTPUT
echo

OUTPUT=$(cast call ${CONTRACT} "$(cast sig 'infoNum()')")
cast to-dec $OUTPUT
echo

OUTPUT=$(cast call ${CONTRACT} "$(cast sig 'info42()')")
cast to-ascii $OUTPUT
echo

OUTPUT=$(cast call ${CONTRACT} "$(cast sig 'theMethodName()')")
cast to-ascii $OUTPUT
echo

OUTPUT=$(cast call ${CONTRACT} "$(cast sig 'method7123949()')")
cast to-ascii $OUTPUT
echo

echo "Executing every public method to find the password..."
for SEL in $(cast selectors $(cast code $CONTRACT) |cut -f1)
do
	echo "Selector: $SEL"
	OUTPUT=$(cast call $CONTRACT $SEL 2>/dev/null)
	[ $? == 0 ] && echo "     $(cast to-ascii $OUTPUT | tr -d '\t\n\r\0')"
done

OUTPUT=$(cast call ${CONTRACT} "0x224b610b")
PASSWORD="$(cast to-ascii $OUTPUT | tr -d '\t\n\r\0 ')"

echo "Authenticating..."
cast send --private-key ${PRIVATE_KEY} \
	${CONTRACT} \
	$(cast calldata 'authenticate(string)' "$PASSWORD")

SUCCESS=$(cast to-dec $(cast storage $CONTRACT 3))

if [ $SUCCESS -eq 1 ]
then
	echo "Level completed, submit instance"
else
	echo "ERROR: Solution failed"
fi
