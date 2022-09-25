pragma solidity 0.8.12;

import {Test} from "forge-std/Test.sol";
import {Capture, IVault} from "../src/Capture.sol";

// SPDX-License-Identifier: GPL-3.0-or-later
contract CaptureFlag is Test {
    function testCapture() public {
        // the fork is on goerli at block 7621730 (a few blocks after the vault contract's deployment).
        vm.createSelectFork(
            "https://rpc.tenderly.co/fork/af98d3be-dc90-497d-9652-9631f933bc53"
        );

        // capture the flag on the goerli vault!
        IVault _vault = IVault(
            address(0x8043e6836416d13095567ac645be7C629715885c)
        );
        new Capture().capture{value: address(_vault).balance}(_vault);

        // check that we are the flag holder
        assertEq(_vault.flagHolder(), address(this));
    }
}
