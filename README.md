# zkevm-benchs
Benchmarks for different approaches to implementing a zkEVM.
1. EVM inside risc0: [risc0](https://github.com/risc0/risc0) is a 32-bit RISC-V virtual machine based on zkSTARK that generates zero-knowledge proofs for programs. In this solution, we run an Ethereum Virtual Machine (EVM) on risc0 to achieve zkEVM.

2. PSE zkEVM-circuits: Ethereum Foundation's [zkEVM](https://github.com/privacy-scaling-explorations/zkevm-circuits) project, using halo2, KZG polynomial commitment, bn256 curve, build circuits.

## 📑 Report
Here we test representative ERC20 transfer transactions, followed by iterative calculations using keccak256 to test the maximum computational capacity supported by zkevm.

**ERC20 contract**
```solidity
contract OpenZeppelinERC20TestToken is ERC20 {
    constructor(address owner) ERC20("TestToken1", "TT1") {
        _mint(owner, 999999 * 18 ** decimals());
    }
}
```

**Keccak256 Contract**

```solidity
contract Keccak256Recursive {
  bytes32 _x;
  
  constructor(bytes32 x) {
    _x = x;
  }
  
  function compute(uint k) public returns(bytes32) {
    if (k == 0) {
      return _x;
    } else {
      bytes memory res = new bytes(32);
      assembly {
        mstore(add(res, 32), sload(_x.slot))
      }
      for (uint i = 0; i < k; i++) {
        bytes32 hash;
        assembly {
          hash := keccak256(add(res, 32), 32)
        }
        assembly {
          mstore(add(res, 32), hash)
        }
      }
      bytes32 finalResult;
      assembly {
        finalResult := mload(add(res, 32))
      }
      _x = finalResult;
      return finalResult;
    }
  }
}
```

test environment: 16 cores, 128GB RAM

### 1️⃣ EVM inside risc0
- erc20 transfer (successful): 3m25s
- erc20 transfer (failed): failed to generate proof
- keccak256 computes (100): 6m47s
- keccak256 computes (500): 28m51s
- keccak256 computes (1000): failed to generate proof (limit exceeded)
- keccak256 computes (3000): failed to generate proof (limit exceeded)
- keccak256 computes (5000): failed to generate proof (limit exceeded)

### 2️⃣ PSE zkEVM-circuits
Due to the proof generation of PSE/zkevm-circuits is composed of multiple modules, its `super circuit` is responsible for combining proofs from individual sub-modules (sub-circuits). However, currently, the `super circuit` has a issue and fails the test. Therefore, here we are conducting separate tests for each sub-module, which are as follows:
- bytecode_circuit
- copy_circuit
- evm_circuit
- exp_circuit
- keccak_circuit
- state_circuit
- tx_circuit

As we know, zkevm-circuits are written using `Halo2`, which utilizes the `Plonkish` frontend, and proves the execution trace. This process requires converting the trace columns into polynomials using `fft`. As a result, the proof generation time is directly proportional to the length of the trace.

For the first test, we set the parameters as below.
```rust
const MAX_RWS: usize = 5888;
const MAX_BYTECODE: usize = 5000;
const MAX_COPY_ROWS: usize = 5888;
const MAX_EVM_ROWS: usize = 10000;
const MAX_EXP_STEPS: usize = 1000;
const MAX_KECCAK_ROWS: usize = 15000;
```
| Sub-Circuit | ERC20-transfer (success) | ERC20-transfer (fail) | Keccak256 (100) | Keccak256 (500) | Keccak256 (1000) | Keccak256 (3000) | Keccak256 (5000) |
| ----------- | ------------------------ | --------------------- | --------------- | --------------- | ---------------- | ---------------- | ---------------- |
| Bytecode    | 13.4s                    | 13.2s                 | failed          | failed          | failed           | failed           | failed           |
| Copy        | 25s                      | 24.8s                 | failed          | failed          | failed           | failed           | failed           |
| EVM         | 11m5s                    | 9m40s                 | failed          | failed          | failed           | failed           | failed           |
| Exp         | 6.59s                    | 6.59s                 | failed          | failed          | failed           | failed           | failed           |
| Keccak      | 3m8s                     | 3m49s                 | failed          | failed          | failed           | failed           | failed           |
| State       | 2m21s                    | 2m3s                  | failed          | failed          | failed           | failed           | failed           |
| Tx          | 4m55s                    | 5m1s                  | failed          | failed          | failed           | failed           | failed           |


Then we make the parameters larger as below.

```rust
const MAX_RWS: usize = 58888;
const MAX_BYTECODE: usize = 58888;
const MAX_COPY_ROWS: usize = 58888;
const MAX_EVM_ROWS: usize = 58888;
const MAX_EXP_STEPS: usize = 1000;
const MAX_KECCAK_ROWS: usize = 58888;
```

| Sub-Circuit | ERC20-transfer (success) | ERC20-transfer (fail) | Keccak256 (100) | Keccak256 (500)    | Keccak256 (1000)    | Keccak256 (3000)    | Keccak256 (5000)    |
| ----------- | ------------------------ | --------------------- | --------------- | ------------------ | ------------------- | ------------------- | ------------------- |
| Bytecode    | 51.56s                   | 50.57s                | 50.56s          | failed (rws=91828) | failed (rws=182828) | failed (rws=546828) | failed (rws=910828) |
| Copy        | 28.63s                   | 26.51s                | 27.00s          | failed             | failed              | failed              | failed              |
| EVM         | 9m11s                    | 8m52s                 | 9m2s            | failed             | failed              | failed              | failed              |
| Exp         | 6.6s                     | 6.6s                  | 6.6s            | failed             | failed              | failed              | failed              |
| Keccak      | 2m41s                    | 2m32s                 | 3m28s           | failed             | failed              | failed              | failed              |
| State       | 2m59s                    | 3m31s                 | 2m40s           | failed             | failed              | failed              | failed              |
| Tx          | 4m58s                    | 5m2s                  | 4m44s           | failed             | failed              | failed              | failed              |
