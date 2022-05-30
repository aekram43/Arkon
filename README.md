<!--
parent:
  order: false
-->

<div align="center">
  <h1> Arkon </h1>
</div>

<!-- TODO: add banner -->
<!-- ![banner](docs/ethermint.jpg) -->

<div align="center">
  <a href="https://github.com/tharsis/evmos/releases/latest">
    <img alt="Version" src="https://img.shields.io/github/tag/tharsis/evmos.svg" />
  </a>
  <a href="https://github.com/tharsis/evmos/blob/main/LICENSE">
    <img alt="License: Apache-2.0" src="https://img.shields.io/github/license/tharsis/evmos.svg" />
  </a>
  <a href="https://pkg.go.dev/github.com/tharsis/evmos">
    <img alt="GoDoc" src="https://godoc.org/github.com/tharsis/evmos?status.svg" />
  </a>
  <a href="https://goreportcard.com/report/github.com/tharsis/evmos">
    <img alt="Go report card" src="https://goreportcard.com/badge/github.com/tharsis/evmos"/>
  </a>
  <a href="https://bestpractices.coreinfrastructure.org/projects/5018">
    <img alt="Lines of code" src="https://img.shields.io/tokei/lines/github/tharsis/evmos">
  </a>
</div>
<div align="center">
  <a href="https://discord.gg/evmos">
    <img alt="Discord" src="https://img.shields.io/discord/809048090249134080.svg" />
  </a>
  <a href="https://github.com/tharsis/evmos/actions?query=branch%3Amain+workflow%3ALint">
    <img alt="Lint Status" src="https://github.com/tharsis/evmos/actions/workflows/lint.yml/badge.svg?branch=main" />
  </a>
  <a href="https://codecov.io/gh/tharsis/evmos">
    <img alt="Code Coverage" src="https://codecov.io/gh/tharsis/evmos/branch/main/graph/badge.svg" />
  </a>
  <a href="https://twitter.com/EvmosOrg">
    <img alt="Twitter Follow Evmos" src="https://img.shields.io/twitter/follow/EvmosOrg"/>
  </a>
</div>

Evmos is a scalable, high-throughput Proof-of-Stake blockchain that is fully compatible and
interoperable with Ethereum. It's built using the [Cosmos SDK](https://github.com/cosmos/cosmos-sdk/) which runs on top of [Tendermint Core](https://github.com/tendermint/tendermint) consensus engine.

**Minimum Specification**<br>
Cloud or Physical server.<br>
CPU Intel Core i7 10th Gen, Xeon 3.0 Ghz, 4 Cores or above<br>
Memory 8GB or above<br>
Storage HDD, SSD 1TB or above (SSD Recommended)<br>
Network static WAN IP required, Speed 100Mbps or faster<br>

**Note**: Requires [Go 1.17.5+](https://golang.org/dl/)

## Install Go 1.17.7

```bash
wget https://go.dev/dl/go1.17.7.linux-amd64.tar.gz
rm -rf /usr/local/go && tar -C /usr/local -xzf go1.17.7.linux-amd64.tar.gz
export PATH=$PATH:/usr/local/go/bin
go version

export PATH=$PATH:$(go env GOPATH)/bin
```

## Installation

For prerequisites and detailed build instructions please read the [Installation](https://evmos.dev/quickstart/installation.html) instructions. Once the dependencies are installed, run:

```bash
make install
```

Or check out the latest [release](https://github.com/aekram43/Arkon).

## Chain Configuration

For validator. Please contact our administrator for allow network conneciton to consensus. And provided chain-id.

```bash
evmosd config chain-id {chain-id}
evmosd init {moniker} --chain-id {chain-id}
```
Replace our genesis.json.<br>
Add our seed and persistent peers in config.toml
```bash
Add seed_node 8357faf6ce3784cbb26d71f2e656ee3d5c155cde@34.126.163.145:26656
Add persistent_peers 8357faf6ce3784cbb26d71f2e656ee3d5c155cde@34.126.163.145:26656
```
Then run the node.
```bash
evmosd start --json-rpc.enable=true --json-rpc.api="eth,web3,net,debug,txpool"
```

## Become our validator

After node running. It's time to become our validator with Arkon by stake some of assessment.
First we need wallet key.
Don't forget write down your mmemonic after this step.

```bash
evmosd keys add (keyname)
```
Promote this node to be validator. Don't forget to transfer some arkon to this key.

```bash
evmosd tx staking create-validator \
  --amount=10000000000000000000000000arkon \
  --pubkey=$(evmosd tendermint show-validator) \
  --moniker="{your moniker}" \
  --chain-id={chain-id} \
  --commission-rate="0.05" \
  --commission-max-rate="0.10" \
  --commission-max-change-rate="0.01" \
  --min-self-delegation="1000000" \
  --gas="1000000" \
  --gas-prices="0.025arkon" \
  --from={key name}
```
After everything going fine. You can query validator to see it's working.
```bash
evmosd query staking validators
```

## Quick Start

To learn how the Evmos works from a high-level perspective, go to the [Introduction](https://evmos.dev/intro/overview.html) section from the documentation. You can also check the instructions to [Run a Node](https://evmos.dev/quickstart/run_node.html).
