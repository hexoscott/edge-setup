#!/usr/bin/env bash

rm genesis.json

extra_data="0x0000000000000000000000000000000000000000000000000000000000000000"
alloc="{"
for i in {0..2};
do
	rm -rf data-${i}
	./geth account new --datadir data-${i}
	addr=$(cat data-${i}/keystore/UTC* | jq -r '.address')
	extra_data="${extra_data}${addr}"
	alloc="${alloc}\"${addr}\":{\"balance\":1000000000000000000000000000},"
done

# now go back up a level to add the other allocs for the generated validators
for i in {0..4};
do
	# get the address and trim off the 0x prefix
	addr=$(cat ../Step-1/validators.json | jq -r ".[${i}].address" | sed 's/^..//g')
	alloc="${alloc}\"${addr}\":{\"balance\":1000000000000000000000000000},"
done

# remove last comma and close the brace
alloc="${alloc::-1}}"

extra_data="${extra_data}0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000"
echo ${alloc}

cat genesis-template.json | sed "s/EXTRADATA/${extra_data}/g" | sed "s/ALLOC/${alloc}/g" > genesis.json