#!/bin/bash

echo "[+] start testing evm inside risc0 ..."
cd ./risc0/examples/evm/
echo "[*] erc20 transfer inside risc0 ..."
chmod +x ./test_risc0_zkevm.sh
./test_risc0_zkevm.sh
cd ../../../
