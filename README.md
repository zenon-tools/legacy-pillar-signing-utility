# Legacy Pillar Signing Utility

This program will output the signature and public key needed to spawn a legacy Pillar on Alphanet.

Copy your `wallet.dat` file (exported from legacy wallet) into the same folder as this program. The program generates a .swp file from the .dat file. The .swp file is then parsed by the program to get the required information to create a valid signature.

When running the program the legacy Pillar address and the new Alphanet Pillar address are required as parameters. Your legacy wallet password will be asked for when running the program.
If you don't remember your legacy Pillar address you can use the Pillar spawning UI in Syrius to view the legacy Pillar entries in your `wallet.dat` file.

## Building from source
The Dart SDK is required to build the program from source (https://dart.dev/get-dart).
Use the Dart SDK to install the dependencies and compile the program by running the following commands:
```
dart pub get
dart compile exe main.dart
```

## Running the program (Windows)
```
.\main.exe "LEGACY_PILLAR_ADDRESS" "NEW_ALPHANET_PILLAR_ADDRESS"
```
The signature and legacy address public key are written into the `output.txt` file. These are needed to spawn the legacy Pillar on Alphanet.

## Troubleshooting

If you get the following error:
```
Unhandled exception:
Could not find the ExportWallet shared library
```
Download the [ExportWallet library](https://github.com/zenon-network/znn_swap_utility/tree/master/lib/src/export_wallet/blobs) (choose the one for your operating system) and put it into the same folder as where the program is.

## Spawning the Pillar
Spawning the Pillar has to be done manually and requires technical understanding of how to do it. Please make sure you know what you are doing.

A pseudocode example of spawning the Pillar:

```
// 1. Init ZNN SDK and get a handle to the keystore you want to use

// 2. Set the Pillar address from the keystore (the signature is only valid for this address!)
zenonClient.defaultKeyPair = zenonClient.getKeyPair(0);

// 3. Deposit 150,000 QSR to the embedded pillar contract
final deposit = zenonClient.embedded.pillar.depositQsr(150000 * 100000000);
await zenonClient.send(deposit);

// 4. Make sure the QSR is deposited in the contract before continuing

// 5. Spawn the pillar
final register = zenonClient.embedded.pillar.registerLegacy(PILLAR_NAME, PRODUCER_ADDRESS, REWARD_ADDRESS, LEGACY_PILLAR_PUBLIC_KEY, THE_SIGNATURE);
await zenonClient.send(register);
```
