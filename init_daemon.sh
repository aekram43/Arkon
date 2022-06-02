KEY="arkonmint"
CHAINID="arkon_1234-1"
MONIKER="arkonprefix"
KEYRING="file"
KEYALGO="eth_secp256k1"
LOGLEVEL="info"
# to trace evm
#TRACE="--trace"
TRACE=""

# validate dependencies are installed
command -v jq > /dev/null 2>&1 || { echo >&2 "jq not installed. More info: https://stedolan.github.io/jq/download/"; exit 1; }

# Reinstall daemon
rm -rf ~/.arkond*
make install

# Set client config
arkond config keyring-backend $KEYRING
arkond config chain-id $CHAINID

# if $KEY exists it should be deleted
arkond keys add $KEY --keyring-backend $KEYRING --algo $KEYALGO

# Set moniker and chain-id for Evmos (Moniker can be anything, chain-id must be an integer)
arkond init $MONIKER --chain-id $CHAINID

# Change parameter token denominations to kon
cat $HOME/.arkond/config/genesis.json | jq '.app_state["staking"]["params"]["bond_denom"]="arkon"' > $HOME/.arkond/config/tmp_genesis.json && mv $HOME/.arkond/config/tmp_genesis.json $HOME/.arkond/config/genesis.json
cat $HOME/.arkond/config/genesis.json | jq '.app_state["crisis"]["constant_fee"]["denom"]="arkon"' > $HOME/.arkond/config/tmp_genesis.json && mv $HOME/.arkond/config/tmp_genesis.json $HOME/.arkond/config/genesis.json
cat $HOME/.arkond/config/genesis.json | jq '.app_state["gov"]["deposit_params"]["min_deposit"][0]["denom"]="arkon"' > $HOME/.arkond/config/tmp_genesis.json && mv $HOME/.arkond/config/tmp_genesis.json $HOME/.arkond/config/genesis.json
cat $HOME/.arkond/config/genesis.json | jq '.app_state["evm"]["params"]["evm_denom"]="arkon"' > $HOME/.arkond/config/tmp_genesis.json && mv $HOME/.arkond/config/tmp_genesis.json $HOME/.arkond/config/genesis.json
cat $HOME/.arkond/config/genesis.json | jq '.app_state["inflation"]["params"]["mint_denom"]="arkon"' > $HOME/.arkond/config/tmp_genesis.json && mv $HOME/.arkond/config/tmp_genesis.json $HOME/.arkond/config/genesis.json
cat $HOME/.arkond/config/genesis.json | jq '.app_state["claims"]["params"]["claims_denom"]="arkon"' > $HOME/.arkond/config/tmp_genesis.json && mv $HOME/.arkond/config/tmp_genesis.json $HOME/.arkond/config/genesis.json

#Change proposal amount
cat $HOME/.arkond/config/genesis.json | jq '.app_state["gov"]["deposit_params"]["min_deposit"][0]["amount"]="10000"' > $HOME/.arkond/config/tmp_genesis.json && mv $HOME/.arkond/config/tmp_genesis.json $HOME/.arkond/config/genesis.json

#fee
#cat $HOME/.arkond/config/genesis.json | jq '.app_state["feemarket"]["params"]["base_fee"]="1000"' > $HOME/.arkond/config/tmp_genesis.json && mv $HOME/.arkond/config/tmp_genesis.json $HOME/.arkond/config/genesis.json

# increase block time (?)
cat $HOME/.arkond/config/genesis.json | jq '.consensus_params["block"]["time_iota_ms"]="5000"' > $HOME/.arkond/config/tmp_genesis.json && mv $HOME/.arkond/config/tmp_genesis.json $HOME/.arkond/config/genesis.json

# Set gas limit in genesis
cat $HOME/.arkond/config/genesis.json | jq '.consensus_params["block"]["max_gas"]="60000000"' > $HOME/.arkond/config/tmp_genesis.json && mv $HOME/.arkond/config/tmp_genesis.json $HOME/.arkond/config/genesis.json

# Set claims start time
node_address=$(arkond keys list | grep  "address: " | cut -c12-)
current_date=$(date -u +"%Y-%m-%dT%TZ")
cat $HOME/.arkond/config/genesis.json | jq -r --arg current_date "$current_date" '.app_state["claims"]["params"]["airdrop_start_time"]=$current_date' > $HOME/.arkond/config/tmp_genesis.json && mv $HOME/.arkond/config/tmp_genesis.json $HOME/.arkond/config/genesis.json

# Set claims records for validator account
#amount_to_claim=10000
#cat $HOME/.arkond/config/genesis.json | jq -r --arg node_address "$node_address" --arg amount_to_claim "$amount_to_claim" '.app_state["claims"]["claims_records"]=[{"initial_claimable_amount":$amount_to_claim, "actions_completed":[false, false, false, false],"address":$node_address}]' > $HOME/.arkond/config/tmp_genesis.json && mv $HOME/.arkond/config/tmp_genesis.json $HOME/.arkond/config/genesis.json

# Set claims decay
cat $HOME/.arkond/config/genesis.json | jq -r --arg current_date "$current_date" '.app_state["claims"]["params"]["duration_of_decay"]="1000000s"' > $HOME/.arkond/config/tmp_genesis.json && mv $HOME/.arkond/config/tmp_genesis.json $HOME/.arkond/config/genesis.json
cat $HOME/.arkond/config/genesis.json | jq -r --arg current_date "$current_date" '.app_state["claims"]["params"]["duration_until_decay"]="100000s"' > $HOME/.arkond/config/tmp_genesis.json && mv $HOME/.arkond/config/tmp_genesis.json $HOME/.arkond/config/genesis.json

# Claim module account:
# 0xA61808Fe40fEb8B3433778BBC2ecECCAA47c8c47 || arkon15cvq3ljql6utxseh0zau9m8ve2j8erz89m5wkz
#cat $HOME/.arkond/config/genesis.json | jq -r --arg amount_to_claim "$amount_to_claim" '.app_state["bank"]["balances"] += [{"address":"arkon1u85ywcegvhukgh0exf9wft32pzy82mg6djqa8l","coins":[{"denom":"arkon", "amount":$amount_to_claim}]}]' > $HOME/.arkond/config/tmp_genesis.json && mv $HOME/.arkond/config/tmp_genesis.json $HOME/.arkond/config/genesis.json

# disable produce empty block
if [[ "$OSTYPE" == "darwin"* ]]; then
    sed -i '' 's/create_empty_blocks = true/create_empty_blocks = false/g' $HOME/.arkond/config/config.toml
  else
    sed -i 's/create_empty_blocks = true/create_empty_blocks = false/g' $HOME/.arkond/config/config.toml
fi

if [[ $1 == "pending" ]]; then
  if [[ "$OSTYPE" == "darwin"* ]]; then
      sed -i '' 's/create_empty_blocks_interval = "0s"/create_empty_blocks_interval = "5s"/g' $HOME/.arkond/config/config.toml
      sed -i '' 's/timeout_propose = "3s"/timeout_propose = "30s"/g' $HOME/.arkond/config/config.toml
      sed -i '' 's/timeout_propose_delta = "500ms"/timeout_propose_delta = "5s"/g' $HOME/.arkond/config/config.toml
      sed -i '' 's/timeout_prevote = "1s"/timeout_prevote = "10s"/g' $HOME/.arkond/config/config.toml
      sed -i '' 's/timeout_prevote_delta = "500ms"/timeout_prevote_delta = "5s"/g' $HOME/.arkond/config/config.toml
      sed -i '' 's/timeout_precommit = "1s"/timeout_precommit = "10s"/g' $HOME/.arkond/config/config.toml
      sed -i '' 's/timeout_precommit_delta = "500ms"/timeout_precommit_delta = "5s"/g' $HOME/.arkond/config/config.toml
      sed -i '' 's/timeout_commit = "5s"/timeout_commit = "150s"/g' $HOME/.arkond/config/config.toml
      sed -i '' 's/timeout_broadcast_tx_commit = "10s"/timeout_broadcast_tx_commit = "150s"/g' $HOME/.arkond/config/config.toml
  else
      sed -i 's/create_empty_blocks_interval = "0s"/create_empty_blocks_interval = "5s"/g' $HOME/.arkond/config/config.toml
      sed -i 's/timeout_propose = "3s"/timeout_propose = "30s"/g' $HOME/.arkond/config/config.toml
      sed -i 's/timeout_propose_delta = "500ms"/timeout_propose_delta = "5s"/g' $HOME/.arkond/config/config.toml
      sed -i 's/timeout_prevote = "1s"/timeout_prevote = "10s"/g' $HOME/.arkond/config/config.toml
      sed -i 's/timeout_prevote_delta = "500ms"/timeout_prevote_delta = "5s"/g' $HOME/.arkond/config/config.toml
      sed -i 's/timeout_precommit = "1s"/timeout_precommit = "10s"/g' $HOME/.arkond/config/config.toml
      sed -i 's/timeout_precommit_delta = "500ms"/timeout_precommit_delta = "5s"/g' $HOME/.arkond/config/config.toml
      sed -i 's/timeout_commit = "5s"/timeout_commit = "150s"/g' $HOME/.arkond/config/config.toml
      sed -i 's/timeout_broadcast_tx_commit = "10s"/timeout_broadcast_tx_commit = "150s"/g' $HOME/.arkond/config/config.toml
  fi
fi

# Allocate genesis accounts (cosmos formatted addresses)
arkond add-genesis-account $KEY 10000000000000000000000000000arkon --keyring-backend $KEYRING

# Update total supply with claim values
validators_supply=$(cat $HOME/.arkond/config/genesis.json | jq -r '.app_state["bank"]["supply"][0]["amount"]')
# Bc is required to add this big numbers
# total_supply=$(bc <<< "$amount_to_claim+$validators_supply")
total_supply=10000000000000000000000000000
cat $HOME/.arkond/config/genesis.json | jq -r --arg total_supply "$total_supply" '.app_state["bank"]["supply"][0]["amount"]=$total_supply' > $HOME/.arkond/config/tmp_genesis.json && mv $HOME/.arkond/config/tmp_genesis.json $HOME/.arkond/config/genesis.json

# Sign genesis transaction
arkond gentx $KEY 10000000000000000000000000arkon --keyring-backend $KEYRING --chain-id $CHAINID

# Collect genesis tx
arkond collect-gentxs

# Run this to ensure everything worked and that the genesis file is setup correctly
arkond validate-genesis

if [[ $1 == "pending" ]]; then
  echo "pending mode is on, please wait for the first block committed."
fi

# Start the node (remove the --pruning=nothing flag if historical queries are not needed)
arkond start --pruning=nothing $TRACE --log_level $LOGLEVEL --minimum-gas-prices=0.0001arkon --json-rpc.api eth,txpool,personal,net,debug,web3
