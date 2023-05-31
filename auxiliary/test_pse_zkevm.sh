#!/bin/sh
echo "[+] The super circuit aggregates all other circuit, 
    currently, it has a bug and can not be tested."

CIRCUITS="bytecode_circuit
copy_circuit
evm_circuit
exp_circuit
keccak_circuit
state_circuit
tx_circuit"
# super_circuit"

TESTS="
multiple_erc20_openzeppelin_transfers
multiple_keccak256_recursive_computes"

for circuit in $CIRCUITS; do
    for test in $TESTS; do
        cargo test --release --test circuits real_prover::serial_test_${circuit}_${test} -- --nocapture
    done
done