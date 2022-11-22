// SPDX-License-Identifier: BSD-3-Clause
pragma solidity 0.8.10;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract USDC is ERC20("USDC", "USD") {
    function mint(address to, uint256 amount) public {
        _mint(to, amount);
    }

    function decimals() public view virtual override returns (uint8) {
        return 6;
    }

    function USDCGive() public {
        mint(msg.sender, 100000000000000000000000);
    }
}
