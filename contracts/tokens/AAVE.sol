// SPDX-License-Identifier: BSD-3-Clause
pragma solidity 0.8.10;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract AAVE is ERC20("AAVE", "AVE") {
    function mint(address to, uint256 amount) public {
        _mint(to, amount);
    }

    function aaveGive() public {
        mint(msg.sender, 100000000000000000000000);
    }
}
