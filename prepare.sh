#!/bin/sh

should_install_rust=false
# Check if rust is installed
if ! command -v rustc >/dev/null; then
  should_install_rust=true
fi

if [ "$should_install_rust" = false ]; then
  # Get the current rust version
  rust_version=$(rustc -V | awk '{print $2}')

  # Check if the rust version is larger than or equal to 1.69.0
  if [[ "$(printf '%s\n' "$rust_version" "1.69.0" | sort -V | tail -n 1)" = "1.69.0" ]]; then
    echo "[+] rust already installed."
  else
    should_install_rust=true
  fi
fi

if [ "$should_install_rust" = true ]; then
  curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
  source "$HOME/.cargo/env"
fi

should_install_go=false
# Check if Go is installed
if ! command -v go >/dev/null; then
  should_install_go=true
fi

if [ "$should_install_go" = false ]; then
  # Get the current Go version
  go_version=$(go version | awk '{print $3}')

  # Check if the go version is larger than or equal to 1.19
  if [[ "$(printf '%s\n' "$go_version" "go1.19" | sort -V | tail -n 1)" = "go1.19" ]]; then
    echo "[+] go already installed."
  else
    should_install_go=true
  fi
fi

if [ "$should_install_go" = true ]; then
  wget https://go.dev/dl/go1.20.4.linux-amd64.tar.gz
  sudo rm -rf /usr/local/go && tar -C /usr/local -xzf go1.20.4.linux-amd64.tar.gz
  echo 'export PATH=$PATH:/usr/local/go/bin' >> ~/.bashrc
  source ~/.bashrc
fi

sudo add-apt-repository ppa:ethereum/ethereum
sudo apt-get update
sudo apt-get install build-essential cmake png-config libfontconfig libfontconfig1-dev docker.io solc libssl-dev

git submodule update --init --recursive
cd risc0
git checkout v0.15.1
cd ..
cd zkevm-circuits
git checkout 96d2e3c58d19423d062eb78ba3bd2310b9de6b31
cd ..

copy ./auxiliary/pse-lib.rs ./zkevm-circuits/integration-tests/src/lib.rs
copy ./auxiliary/pse-gen-block-data ./zkevm-circuits/integration-tests/src/bin/gen_blockchain_data.rs
copy ./auxiliary/pse-test-circuits.rs ./zkevm-circuits/integration-tests/tests/circuits.rs
copy ./auxiliary/pse-test-circuit-input-builder.rs ./zkevm-circuits/integration-tests/tests/circuit_input_builder.rs
copy ./test_pse_zkevm.sh ./zkevm-circuits/integration-tests/test_pse_zkevm.sh

copy ./auxiliary/risc0_main.rs ./risc0/examples/evm/src/main.rs
cd ./risc0/examples/evm/
cargo build --release
cd ../../../

cd ./zkevm-circuits/integration-tests
chmod +x ./run.sh
./run.sh --sudo --steps "setup gendata"
chmod +x ./test_pse_zkevm.sh
echo "[+] done prepare work"
echo "[+] start testing pse zkevm-circuits ..."
./test_pse_zkevm.sh
cd ../../

echo "[+] start testing evm inside risc0 ..."
cd ./risc0/examples/evm/
echo "[*] erc20 transfer inside risc0 ..."
echo "[+] success transfer"
RUST_LOG=info ./target/release/evm  --rpc-url http://127.0.0.1:8545 --tx-hash 0x1f759dad2631d26e4dc5399a3fc1aeec947236e9dde6b168ca181db2a1eb9b7c --chain-id 1337
RUST_LOG=info ./target/release/evm  --rpc-url http://127.0.0.1:8545 --tx-hash 0x765e7ec6e72e97b76ce3b79017870718ae6a137d24b5bd79b55498fa7e900120 --chain-id 1337
echo "[+] failed transfer"
RUST_LOG=info ./target/release/evm  --rpc-url http://127.0.0.1:8545 --tx-hash 0x3a068779c909394933759e5bc006caf0d7a0258842f248bd434aededcd53b8c2 --chain-id 1337
RUST_LOG=info ./target/release/evm  --rpc-url http://127.0.0.1:8545 --tx-hash 0xa62b1b5378fb98ab22d93a2aab4d8cc3bc226dd02ab3cbf0b77f40e95a994463 --chain-id 1337

echo "[*] keccak256 compute inside risc0 ..."
RUST_LOG=info ./target/release/evm  --rpc-url http://127.0.0.1:8545 --tx-hash 0x4235c71475c0163a7cf39739294d1a7fa2880d69e84c2598725d8570bc80b242 --chain-id 1337
RUST_LOG=info ./target/release/evm  --rpc-url http://127.0.0.1:8545 --tx-hash 0x2da76d4c93b61a8a2946962441384cdfc25d4f90ffb529d249cc7f4efdea0357 --chain-id 1337
RUST_LOG=info ./target/release/evm  --rpc-url http://127.0.0.1:8545 --tx-hash 0x33cd3a5d3767abd245c503fd3ea8325aa7047e09e7047df305714d2bafb36a4c --chain-id 1337
RUST_LOG=info ./target/release/evm  --rpc-url http://127.0.0.1:8545 --tx-hash 0xe8526d863f3372616905d1b8a0e754fa12c6f1edbc300e289892db3fb23f4728 --chain-id 1337
RUST_LOG=info ./target/release/evm  --rpc-url http://127.0.0.1:8545 --tx-hash 0xe13a8a2d94fa71f83f12a62dc909765c06891c7dc981d4f0327b37116fc84303 --chain-id 1337
cd ../../../
