// SPDX-License-Identifier: BSD-3-Clause
pragma solidity 0.8.10;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract MyToken is ERC20 ("PEDRIL","PDRL"){


function mint(address to,uint amount)public {
    _mint(to, amount);
}

}