# Hats challenge solution

This repo contains a solution for the Hats CTF challenge. A `Capture` smart
contract exploits a series of vulnerabilities in the ERC4266ETH contract in
order to drain it of all of the ETH (sending them to the contract's owner),
letting the contract itself claim the `msg.sender` as the flag holder (i.e.
capturing the flag).

The simulation of the attack is carried out by `test/CaptureFlag.sol`. It is
performed using a Goerli fork at block `7621724` (if you don't trust it you can
use any Goerli fork of your liking by replacing the RPC endpoint at line 11 of
the file), exactly the same block the `Vault` contract was deployed.

In order to run the simulation and potentially analyze traces, make sure you
follow these steps:

- Clone the repo with submodule recursion in order to install foundry
  dependencies (`git clone --recurse-submodules`). On a standard, non recursive
  clone, remember to run `git submodule update --init --recursive` in order to
  install dependencies (`forge-std`).
- Install Foundry (you can get it [here](https://getfoundry.sh/)).
- Run `forge test -vvvv`

In order to better understand what's going on, please check the
`src/Capture.sol` contract code, since it's well commented to help explain
exactly what happens step by step.
