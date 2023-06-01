#!/bin/sh
echo "[*] success transfer"
RUST_LOG=info ../target/release/evm  --rpc-url http://127.0.0.1:8545 --tx-hash 0x1f759dad2631d26e4dc5399a3fc1aeec947236e9dde6b168ca181db2a1eb9b7c --chain-id 1337
RUST_LOG=info ../target/release/evm  --rpc-url http://127.0.0.1:8545 --tx-hash 0x765e7ec6e72e97b76ce3b79017870718ae6a137d24b5bd79b55498fa7e900120 --chain-id 1337
echo "[*] failed transfer"
RUST_LOG=info ../target/release/evm  --rpc-url http://127.0.0.1:8545 --tx-hash 0x3a068779c909394933759e5bc006caf0d7a0258842f248bd434aededcd53b8c2 --chain-id 1337
RUST_LOG=info ../target/release/evm  --rpc-url http://127.0.0.1:8545 --tx-hash 0xa62b1b5378fb98ab22d93a2aab4d8cc3bc226dd02ab3cbf0b77f40e95a994463 --chain-id 1337

echo "[*] keccak256 compute inside risc0 ..."
RUST_LOG=info ../target/release/evm  --rpc-url http://127.0.0.1:8545 --tx-hash 0x4235c71475c0163a7cf39739294d1a7fa2880d69e84c2598725d8570bc80b242 --chain-id 1337
RUST_LOG=info ../target/release/evm  --rpc-url http://127.0.0.1:8545 --tx-hash 0x2da76d4c93b61a8a2946962441384cdfc25d4f90ffb529d249cc7f4efdea0357 --chain-id 1337
RUST_LOG=info ../target/release/evm  --rpc-url http://127.0.0.1:8545 --tx-hash 0x33cd3a5d3767abd245c503fd3ea8325aa7047e09e7047df305714d2bafb36a4c --chain-id 1337
RUST_LOG=info ../target/release/evm  --rpc-url http://127.0.0.1:8545 --tx-hash 0xe8526d863f3372616905d1b8a0e754fa12c6f1edbc300e289892db3fb23f4728 --chain-id 1337
RUST_LOG=info ../target/release/evm  --rpc-url http://127.0.0.1:8545 --tx-hash 0xe13a8a2d94fa71f83f12a62dc909765c06891c7dc981d4f0327b37116fc84303 --chain-id 1337
