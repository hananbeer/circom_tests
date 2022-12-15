# Circom circuit for substring

## JUST RUN:

`./test.sh`

## Compilation steps (based on snarkjs github readme)

10. Compile the circuit
circom --r1cs --wasm --sym --json ./circuits/substr.circom

11. View information about the circuit
snarkjs r1cs info substr.r1cs

12. Print the constraints
snarkjs r1cs print substr.r1cs substr.sym

13. Export r1cs to json
snarkjs r1cs export json substr.r1cs substr.r1cs.json
cat substr.r1cs.json

14. Calculate the witness
cat <<EOT > substr_input.json
{"str": [1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16], "substr": [7,8,9,10,11]}
EOT
node substr_js/generate_witness.js substr_js/substr.wasm substr_input.json substr_witness.wtns

15. Setup
Plonk
snarkjs plonk setup substr.r1cs ./artifacts/circom/hermezptau.blob.core.windows.net_ptau_powersOfTau28_hez_final_15.ptau substr_final.zkey

21. Verify the final zkey
(not working for plonk for some reason)
snarkjs zkey verify circuit.r1cs pot12_final.ptau circuit_final.zkey

22. Export the verification key
snarkjs zkey export verificationkey substr_final.zkey substr_verification_key.json

23. Create the proof
PLONK
snarkjs plonk prove substr_final.zkey substr_witness.wtns substr_proof.json substr_public.json

24. Verify the proof
PLONK
snarkjs plonk verify substr_verification_key.json substr_public.json substr_proof.json