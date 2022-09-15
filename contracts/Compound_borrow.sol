// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

// Uncomment this line to use console.log
import "hardhat/console.sol";

import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import "./interfaces/ComptrollerInterfaces.sol";


contract Compound_borrow is AccessControl{
    using SafeERC20 for IERC20;
    ICErc20 public cToken;
    CEth public cTokenETH; 
    ComptrollerInterfaces public comptroller ;
    PriceFeed public priceFeed ;
    

    mapping(address=>mapping(address=>uint)) public usertokensSuppliedToCompound;
    mapping(address=>mapping(address=>uint)) public userBorrowedFromCompound;

    event CTokenInfo(uint exchangeRateMantissa,uint supplyRateMantisssa,address ctoken);
    event CETHInfo(uint exchangeRateMantissa,uint supplyRateMantisssa);
    
    mapping (address=> address)public tokenForCtoken;

    receive()external payable{

    }
    constructor(CEth cTokenETh, ComptrollerInterfaces comprtoller,PriceFeed oracle){
        cTokenETH = cTokenETh;
        comptroller = comprtoller;
        priceFeed = oracle;
        _setupRole(DEFAULT_ADMIN_ROLE, _msgSender());
    }
    function createAssetForCtoken(address _token,address _cToken)public onlyRole(DEFAULT_ADMIN_ROLE){
        tokenForCtoken[_token] = _cToken;
    }

    

    function supplyERC20ToCompound(address _token,uint _numTokenForSupply) external returns(uint,uint,uint){

        address _ctoken = tokenForCtoken[_token];
        usertokensSuppliedToCompound[msg.sender][_ctoken] = _numTokenForSupply;
        uint exchangeRateMantissa = ICErc20(_ctoken).exchangeRateCurrent();
        uint supplyRatemantissa = ICErc20(_ctoken).supplyRatePerBlock();
        IERC20(_token).transfer(address(this), _numTokenForSupply);
        IERC20(_token).approve(_ctoken, _numTokenForSupply);
        uint mintResult = ICErc20(_ctoken).mint(_numTokenForSupply);
        emit CTokenInfo(exchangeRateMantissa,supplyRatemantissa,_ctoken);
        return (exchangeRateMantissa,supplyRatemantissa,mintResult);      
    }

    function calculateRedeemAmountERC20(address _ctoken,address _user)public view returns(uint){
        uint balance = ICErc20(_ctoken).balanceOf(_user);
        return balance;
    }
    function redeemERC20FromCompound(uint amount,bool reddemType,address _cToken)public returns(uint){
        uint redeedmReslt;
        //uint suppliedBalance = usertokensSuppliedToCompound[msg.sender][_cToken];
        if (reddemType == true){
            redeedmReslt = ICErc20(_cToken).redeem(amount);
        } else {
            redeedmReslt = ICErc20(_cToken).redeemUnderlying(amount);
        }

        return 1;
    }
   

    function borrowERCFromCompoundForERC(address tokenForLiquidityCalc,uint amountOfCollateral,uint _decimals)public returns (uint){
        address _cTokenBorrowed = tokenForCtoken[tokenForLiquidityCalc];
        //uint error = CErc20(_cTokenBorrowed).mint(amountOfCollateral);
        //require(error == 0,"Error on minting");
        address[] memory _cTokens = new address[](1);
        _cTokens[0] = _cTokenBorrowed;
        uint[] memory errors1 = comptroller.enterMarkets(_cTokens);
        require(errors1[0] == 0,"Failed to enter market");
        (uint error2,uint liquidity,uint shortfall) = comptroller.getAccountLiquidity(address(this));
        require(error2 == 0,"Failed to get liquidity");
        require(shortfall == 0, "account underwater");
        require(liquidity > 0, "account has excess collateral");//error
        uint underlingPriceUsd = priceFeed.getUnderlyingPrice(_cTokenBorrowed);
        require(underlingPriceUsd > liquidity,"");
        uint maxBorrow = (liquidity * (10** _decimals)) / underlingPriceUsd;
        require(maxBorrow > 0, "max borrow = 0");
        require(ICErc20(_cTokenBorrowed).totalSupply() <= amountOfCollateral);
        require(ICErc20(_cTokenBorrowed).borrow(maxBorrow) == 0, "borrow failed");
        uint borrows = ICErc20(_cTokenBorrowed).borrowBalanceCurrent(msg.sender);
        return borrows;
    }
    function repayERCBorrow(address repayUserBalance,uint amountOfCollateral,address _cTokenBorrowed) public returns(uint){
        ICErc20(_cTokenBorrowed).repayBorrow(amountOfCollateral);
        uint borrows = ICErc20(_cTokenBorrowed).borrowBalanceCurrent(repayUserBalance);
        return borrows; 
    }
    function getBorrowAmount(address user,address _cTokenBorrowed)public view returns(uint){
        uint borrows = ICErc20(_cTokenBorrowed).borrowBalanceStored(user);
        return borrows;
    }
    

    ///////////////////////////////////////////////////////////////////////////
     function supplyETHtoCompound()public payable returns(bool){
        uint exchangeRateMantissa = CEth(cTokenETH).exchangeRateCurrent();
        uint supplyRatemantissa = CEth(cTokenETH).supplyRatePerBlock();
        CEth(cTokenETH).mint{value: msg.value, gas: 250000};
        emit CETHInfo(exchangeRateMantissa,supplyRatemantissa);
        return true;       
    }
    function borrowTokenForETH(address _cTokenBorrowing)external payable returns(uint){
        CEth(cTokenETH).mint{value:msg.value,gas:25000}();
        address[] memory _cTokens = new address[](1);
        _cTokens[0] = _cTokenBorrowing;
        uint[] memory errors1 = comptroller.enterMarkets(_cTokens);
        require(errors1[0] == 0,"Failed to enter market");
        (uint error2,uint liquidity,uint shortfall) = comptroller.getAccountLiquidity(address(this));
        require(error2 == 0,"Failed to get liquidity");
        require(shortfall == 0, "account underwater");
        require(liquidity > 0, "account has excess collateral");
        uint256 underlyingPrice = priceFeed.getUnderlyingPrice(_cTokenBorrowing);
        uint256 maxBorrowUnderlying = liquidity / underlyingPrice;
        cToken.borrow(maxBorrowUnderlying);
        uint256 borrows = cToken.borrowBalanceCurrent(address(this));
        return borrows;    
    }
    function calculateRedeemAmountETH(address _user)public view returns(uint){
        uint balance = CEth(cTokenETH).balanceOf(_user);
        return balance * 1e8;
    }
    function redeemCETH(uint amount,bool redeemType) public returns(uint){
        uint redeemResult;
        if (redeemType == true) {
            redeemResult = CEth(cTokenETH).redeem(amount);
        } else {
            redeemResult = CEth(cTokenETH).redeemUnderlying(amount);
        }
        return calculateRedeemAmountETH(msg.sender);
    }
    function repayETH(uint _amount)payable public {
        CEth(cTokenETH).repayBorrow{ value:_amount, gas:25000}();
    }
///////////////////////////////////////////////
    function ExchangeRate(address _token,uint decimalsToken,uint _amount)public returns(uint){
        address _cToken = tokenForCtoken[_token];
        uint oneCtokenInunderlying = ICErc20(_cToken).exchangeRateCurrent()/(1*10^(18 + decimalsToken - 8));
        return _amount*oneCtokenInunderlying;
    }
    function getCTokenprice(address _cToken)public view returns(uint){
        return priceFeed.getUnderlyingPrice(_cToken);
    }

}