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
erc20_openzeppelin_transfer_succeed
erc20_openzeppelin_transfer_fail
keccak256_recursive_100_computes
keccak256_recursive_500_computes
keccak256_recursive_1000_computes
keccak256_recursive_3000_computes
keccak256_recursive_5000_computes"

for circuit in $CIRCUITS; do
    for test in $TESTS; do
        cargo test --release --test circuits real_prover::serial_test_${circuit}_${test} -- --nocapture
    done
done