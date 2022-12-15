mkdir -p out
cd out

if [ ! -f "ptau28_15.ptau" ]; then
  echo Downloading Powers of Tau
  curl https://hermezptau.blob.core.windows.net/ptau/powersOfTau28_hez_final_15.ptau > ptau28_15.ptau
fi

echo Compile the circuit
circom --r1cs --wasm --sym --json ../circuits/substr.circom || exit

echo View information about the circuit
snarkjs r1cs info substr.r1cs || exit

echo Print the constraints
snarkjs r1cs print substr.r1cs substr.sym || exit

echo Export r1cs to json
snarkjs r1cs export json substr.r1cs substr.r1cs.json || exit
cat substr.r1cs.json

echo Calculate the witness
cat <<EOT > substr_input.json
{"str": [1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16], "substr": [7,8,9,10,11]}
EOT
node substr_js/generate_witness.js substr_js/substr.wasm substr_input.json substr_witness.wtns || exit

echo Setup - Plonk
snarkjs plonk setup substr.r1cs ptau28_15.ptau substr_final.zkey || exit

#echo Verify the final zkey
#(not working for plonk for some reason)
#snarkjs zkey verify circuit.r1cs ptau28_15.ptau circuit_final.zkey

echo Export the verification key
snarkjs zkey export verificationkey substr_final.zkey substr_verification_key.json

echo Create the proof - Plonk
snarkjs plonk prove substr_final.zkey substr_witness.wtns substr_proof.json substr_public.json

echo Verify the proof - Plonk
snarkjs plonk verify substr_verification_key.json substr_public.json substr_proof.json

cd -
