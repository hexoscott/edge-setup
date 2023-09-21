#!/bin/sh

set -e

rm -f genesis.json
rm -f genesis-pre-merge.json

rpc=https://rpc.eu-north-2.gateway.fm/v4/ethereum/non-archival/goerli?apiKey=GFiNjfnzATpNtswaj5ZMoYsLmCQkPNO5.NIzokENnBcGQf6HQ

privateKey="$1"

stakeToken=0x499d11E0b6eAC7c0593d8Fb292DCBbF815Fb29Ae

# ./polygon-edge polybft-secrets --insecure --private --network --data-dir 1 >> secrets.txt && \
# ./polygon-edge polybft-secrets --insecure --private --network --data-dir 2 >> secrets.txt && \
# ./polygon-edge polybft-secrets --insecure --private --network --data-dir 3 >> secrets.txt && \
# ./polygon-edge polybft-secrets --insecure --private --network --data-dir 4 >> secrets.txt

address1=$(./polygon-edge polybft-secrets --insecure --private --network --data-dir 1 | grep Public | head -n 1 | awk -F ' ' '{print $5}')
address2=$(./polygon-edge polybft-secrets --insecure --private --network --data-dir 2 | grep Public | head -n 1 | awk -F ' ' '{print $5}')
address3=$(./polygon-edge polybft-secrets --insecure --private --network --data-dir 3 | grep Public | head -n 1 | awk -F ' ' '{print $5}')
address4=$(./polygon-edge polybft-secrets --insecure --private --network --data-dir 4 | grep Public | head -n 1 | awk -F ' ' '{print $5}')


./polygon-edge genesis \
--chain-id 11297108099 \
--name "palm-testnet" \
--block-gas-limit 18800000 \
--epoch-size 2160 \
--epoch-reward "0xD5BD3944E5A01F800" \
--consensus polybft \
--min-validator-count 4 \
--sprint-size 1080 \
--block-time 5s \
--reward-wallet 0x276DA6a8cfaabf5070a6c0d2E3B9e9256E499E5c \
--native-token-config "Palm Token:PALM:18:true:0x276DA6a8cfaabf5070a6c0d2E3B9e9256E499E5c" \
--premine 0x276DA6a8cfaabf5070a6c0d2E3B9e9256E499E5c:374566000000000000000000 \
--premine 0x0 \
--validators /ip4/94.156.203.203/tcp/30301/p2p/16Uiu2HAm9ziqXTQCFSAxL1VDLcZY3gteHNyvQYohMRcXMnjNKXDh:0x276DA6a8cfaabf5070a6c0d2E3B9e9256E499E5c:18156e8c8f4f23a62644f14457f4abaa29f1399a9c437afcf71ce4b7f92930b01468b29aabea6c0f6bca58e6ecacbbe3caec117b9a0486a56f37de15137dc71803992d97d84f582740bec425bed630daf725849188244961004c0834ab82276f1d8faa0859f623a3e4347a0ff7fc619712846900dc2a6b1ed449b4d54191f842 \
--validators /ip4/94.156.202.134/tcp/30301/p2p/16Uiu2HAmKpo4uxqTmH1Ti4zS1pSR7XZ1bto6dMfR9v5FZSJz31Y1:0xbA9fFe92510CAf16e8F060f41A097145F1f5a497:19bee9b94eeeba060321f8630269e666fa6d6746309f4e551422901cf8f42a521b843c855bdae12162bdc1493bc6e94efa9bb3dbb05a9502e0263f2dd3aa2b342250091c7ddc2ced81fae7e94de6c114a42f38f00c47e18f28f76666f7b557930d48a198aa03381757f20fe33f737097140fddbe34f164d039d5c929612a33f0 \
--validators /ip4/94.156.202.214/tcp/30301/p2p/16Uiu2HAmPa98Utcf5t86EE5UPXKJjPSaDxSQSKyjZ89iLzGXM46H:0xfFE1bDC31374A2a145b95EA4BAedD87dfB4d63D8:0e23462e5b379ffdf9e4f6a25f853ddf666a4d29f4e5bc554b05f0adf7c71bd0167d0f489885bd9920acce6db8629ccff08d8fd16a81477f688505cf0561e4402e3681507933c032309dfec57aa0aae0d49e8c1e24770c7a9a8f0c343fe30031175b6bb7266c1dab48651953e8556344873f06e12be2cbf79990077a38a41d48 \
--validators /ip4/94.156.202.91/tcp/30301/p2p/16Uiu2HAkzRp6ecDjWmzXddJyBaEyWPKjAE4oQzhZ3AtTYEaFLHU5:0x7c802b2FD0F1a8EcEE55ed9F8c9846bA38a2C8B5:2b39a181c2ce48552ff57fd03d56a14e38182640d3480f0d038b32e34cd2bc1a2e699778510354f5f2045a9575436943a8b2626f5fc3989d8f4adadddf5a101f191b90ebe5621fe470a5d10aab573fb8a924aff1014b0f45599605d1884fb6f209493b27d05d5bbd38e82444598970c95e8ab0db52e227a09df4d2e8d9e0724a


./polygon-edge polybft stake-manager-deploy \
--private-key ${privateKey} \
--genesis ./genesis.json \
--jsonrpc ${rpc} \
--stake-token ${stakeToken}


stakeManagerAddr=$(cat genesis.json | jq -r '.params.engine.polybft.bridge.stakeManagerAddr')

./polygon-edge rootchain deploy \
--deployer-key ${privateKey} \
--genesis ./genesis.json \
--json-rpc ${rpc} \
--stake-manager ${stakeManagerAddr} \
--stake-token ${stakeToken}

customSupernetManagerAddr=$(cat genesis.json | jq -r '.params.engine.polybft.bridge.customSupernetManagerAddr')
supernetID=$(cat genesis.json | jq -r '.params.engine.polybft.supernetID')

./polygon-edge polybft whitelist-validators \
--addresses ${address1},${address2},${address3},${address4} \
--supernet-manager ${customSupernetManagerAddr} \
--private-key ${privateKey} \
--jsonrpc ${rpc}


counter=1
while [ $counter -le 4 ]; do
	echo "Registering validator: ${counter}"

	./polygon-edge polybft register-validator \
		--supernet-manager ${customSupernetManagerAddr} \
		--data-dir ${counter} \
		--jsonrpc ${rpc}

	./polygon-edge polybft stake \
		--data-dir ${counter} \
		--amount 1000000000000000000 \
		--supernet-id ${supernetID} \
		--stake-manager ${stakeManagerAddr} \
		--stake-token ${stakeToken} \
		--jsonrpc ${rpc}

	((counter++))
done


./polygon-edge polybft supernet \
--private-key ${privateKey} \
--jsonrpc ${rpc} \
--genesis ./genesis.json \
--supernet-manager ${customSupernetManagerAddr} \
--stake-manager ${stakeManagerAddr} \
--finalize-genesis-set \
--enable-staking

cp genesis.json genesis-pre-merge.json

jq -r '.genesis.alloc' genesis.json > genesis-alloc.json && \
jq '.params.engineForks[1].alloc = input' palm-merge-testnet.json genesis-alloc.json > genesis-merge.json && \
jq 'del(.genesis.alloc)' genesis.json > genesis-no-alloc.json && \
jq -n 'reduce inputs as $i ({}; . * $i)' genesis-no-alloc.json genesis-merge.json > genesis-merged.json && \
rm -f genesis.json && rm -f genesis-no-alloc.json && rm -f genesis-alloc.json && rm -f genesis-merge.json &&  \
mv genesis-merged.json genesis.json