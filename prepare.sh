#!/bin/bash

should_install_rust=false
# Check if rust is installed
if ! command -v rustc >/dev/null; then
  should_install_rust=true
fi

if [ "$should_install_rust" = false ]; then
  # Get the current rust version
  rust_version=$(rustc -V | awk '{print $2}')

  # Check if the rust version is larger than or equal to 1.69.0
  if [[ "$(printf '%s\n' "$rust_version" "1.69.0" | sort -V | head -n 1)" = "1.69.0" ]]; then
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
  if [[ "$(printf '%s\n' "$go_version" "go1.19" | sort -V | head -n 1)" = "go1.19" ]]; then
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

sudo add-apt-repository ppa:ethereum/ethereum -y
sudo apt-get update
sudo apt-get install build-essential cmake pkg-config libfontconfig libfontconfig1-dev docker.io solc libssl-dev -y

git submodule update --init --recursive
cd risc0
git checkout v0.15.1
cd ..
cd zkevm-circuits
git checkout 96d2e3c58d19423d062eb78ba3bd2310b9de6b31
cd ..

cp ./auxiliary/pse-lib.rs ./zkevm-circuits/integration-tests/src/lib.rs
cp ./auxiliary/pse-gen-block-data ./zkevm-circuits/integration-tests/src/bin/gen_blockchain_data.rs
cp ./auxiliary/pse-test-circuits.rs ./zkevm-circuits/integration-tests/tests/circuits.rs
cp ./auxiliary/pse-test-circuit-input-builder.rs ./zkevm-circuits/integration-tests/tests/circuit_input_builder.rs
cp ./auxiliary/pse-run.sh ./zkevm-circuits/integration-tests/run.sh
cp ./auxiliary/test_pse_zkevm.sh ./zkevm-circuits/integration-tests/test_pse_zkevm.sh
mkdir -p ./zkevm-circuits/integration-tests/contracts/keccak256
cp ./contracts/keccak/Keccak256Recursive.sol ./zkevm-circuits/integration-tests/contracts/keccak256/Keccak256Recursive.sol

cp ./auxiliary/risc0_main.rs ./risc0/examples/evm/src/main.rs
cp ./auxiliary/test_risc0_zkevm.sh ./risc0/examples/evm/test_risc0_zkevm.sh
cd ./risc0/examples/evm/
cargo build --release
cd ../../../

cd ./zkevm-circuits/integration-tests
chmod +x ./run.sh
./run.sh --sudo --steps "setup gendata"
chmod +x ./test_pse_zkevm.sh
cd ../../

echo "[+] done prepare work"
