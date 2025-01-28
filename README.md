## NexoCore
Name : NexTo

Ticker : NEXT

Maximum Supply : 21.000.000 NEXT

Liquidity Staking : 25%

Emission Fee Perblock : 100 - 1000 byte

TPS : 200-2000

Transaction Load(consensus) : 7.150.000 Transaction Speed

Block Reward : 50 NEXT

Halving : Yes

Modular : NexTo Core

NickMod : NTC-00

SmartChain : NSC(Coming Soon)

POW : 100.000 Block

POS : >100.000 Block

DPOS : 500.000 Block

Hashing : CPU or Smaller(GPU not tested)

## Requirement Installation

- Ubuntu/Debian OS latest version(12)
- Server

Specification Server

- Core : 2 core
- Ram : 4 GB
- Storage : 80 GB
- Traffic : Unlimited

## Guide

<details>
<summary>
Installation
</summary>
create folder blockchain at ~/

```sh
mkdir coins
```

Install Depedencies(choose maintainer)

```sh
apt install -y software-properties-common net-tools build-essential
```

Chmod all inside(skip if you using root)

```sh
chmod 777 -R /builder/plugins.sh &&
chmod 777 -R /builder/core.sh &&
chmod 777 -R /builder/core_qt.sh &&
chmod 777 -R fresh_install_core.sh &&
chmod 777 -R fresh_install_qt.sh &&
chmod 777 -R upgrade_core.sh &&
chmod 777 -R upgrade_qt.sh
```

Run the fresh install

```sh
./fresh_install_core.sh
```

Run the fresh install qt

```sh
./fresh_install_qt.sh
```

</details>
