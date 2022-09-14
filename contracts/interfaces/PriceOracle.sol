// SPDX-License-Identifier: BSD-3-Clause
pragma solidity ^0.8.9;

//import "../compound/CToken.sol";


interface PriceFeed {

  function getUnderlyingPrice(address cToken) external view returns (uint);
}

