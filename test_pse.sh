#!/bin/bash

echo "[+] start testing pse zkevm-circuits ..."
cd ./zkevm-circuits/integration-tests
chmod +x ./test_pse_zkevm.sh
./test_pse_zkevm.sh
cd ../../
