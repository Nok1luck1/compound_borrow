// SPDX-License-Identifier: MIT
pragma solidity 0.8.10;

interface ICErc20 {
  function mint(uint) external returns (uint);//
  function redeem(uint) external returns (uint);//
  function redeemUnderlying(uint) external returns (uint);//
  function borrow(uint) external returns (uint);//
  function repayBorrow(uint) external returns (uint);//
  function liquidateBorrow(address borrower,uint amount,address collateral) external returns (uint);//
  function transfer(address dst, uint amount)  external returns (bool);//
  function transferFrom(address src, address dst, uint amount)  external returns (bool);//
  function approve(address spender, uint amount)  external returns (bool);//
  function allowance(address owner, address spender)  external view returns (uint);//
  function balanceOf(address owner)  external view returns (uint);//
  function balanceOfUnderlying(address owner)  external returns (uint);//
  function getAccountSnapshot(address account)  external view returns (uint, uint, uint, uint);//
  function borrowRatePerBlock()  external view returns (uint);//
  function supplyRatePerBlock()  external view returns (uint);//
  function totalBorrowsCurrent()  external returns (uint);//
  function borrowBalanceCurrent(address account)  external returns (uint);//
  function borrowBalanceStored(address account)  external view returns (uint);//
  function exchangeRateCurrent()  external returns (uint);//
  function exchangeRateStored()  external view returns (uint);//
  function getCash()  external view returns (uint);//
  function accrueInterest()  external returns (uint);//
  function seize(address liquidator, address borrower, uint seizeTokens)  external returns (uint);//
  function totalSupply()external returns (uint);//
}

interface CEth {
  function approve(address spender, uint amount)  external returns (bool);//
  function balanceOf(address) external view returns (uint);
  function mint() external payable;
  function exchangeRateCurrent() external returns (uint);
  function supplyRatePerBlock() external returns (uint);
  function balanceOfUnderlying(address) external returns (uint);
  function redeem(uint) external returns (uint);
  function redeemUnderlying(uint) external returns (uint);
  function borrow(uint) external returns (uint);
  function borrowBalanceCurrent(address) external returns (uint);
  function borrowRatePerBlock() external view returns (uint);
  function repayBorrow() external payable;
}

interface ComptrollerInterfaces {
  function markets(address)
    external
    view
    returns (
      bool,
      uint,
      bool
    );

  function enterMarkets(address[] calldata) external returns (uint[] memory);

  function getAccountLiquidity(address)
    external
    view
    returns (
      uint,
      uint,
      uint
    );

  function closeFactorMantissa() external view returns (uint);

  function liquidationIncentiveMantissa() external view returns (uint);

  function liquidateCalculateSeizeTokens(
    address cTokenBorrowed,
    address cTokenCollateral,
    uint actualRepayAmount
  ) external view returns (uint, uint);
}

interface PriceFeed {
  function getUnderlyingPrice(address cToken) external view returns (uint);
  function assetPrices(address asset) external view returns (uint);
}