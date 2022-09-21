// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.10;

// Uncomment this line to use console.log
import "hardhat/console.sol";

import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import "./interfaces/ComptrollerInterfaces.sol";


contract Compound_borrow is AccessControl{
    using SafeERC20 for IERC20;
    ICErc20 public cToken;
    CEth public cTokenETH; 
    ComptrollerInterfaces public comptroller;
    PriceFeed public priceFeed;
    
    struct User{
        mapping(address=>uint) suppliedCTokens;//for c Token
        mapping(address=>uint) borrowedCTokens;//borrowed from compound
        mapping(address=>uint) tokenDeposited;// for Origin token
    }

    mapping(address => User) userInfo;
    mapping(address => address)public tokenForCtoken;
    mapping(address => address)public cTOKENforToken;
    event CTokenInfo(uint exchangeRateMantissa,uint supplyRateMantisssa,address ctoken);
    event CETHInfo(uint exchangeRateMantissa,uint supplyRateMantisssa);

    receive()external payable{
    }
    constructor(CEth cTokenETh, ComptrollerInterfaces comprtoller,PriceFeed oracle){
        cTokenETH = cTokenETh;
        comptroller = comprtoller;
        priceFeed = oracle;
        _setupRole(DEFAULT_ADMIN_ROLE, _msgSender());
    }
    function getUserSuppliedToken(address _user,address _cToken)public view returns(uint){
        User storage user = userInfo[_user];
        return user.suppliedCTokens[_cToken];
    }
    function getUserBorrowedToken(address _user,address borowedToken)public view returns(uint){
        User storage user = userInfo[_user];
        return user.borrowedCTokens[borowedToken];
    }
    function getUserDepositedToken(address _user,address depositToken)public view returns(uint){
        User storage user = userInfo[_user];
        return user.tokenDeposited[depositToken];
    }
    function createAssetForCtoken(address _token,address _cToken)public onlyRole(DEFAULT_ADMIN_ROLE){
        tokenForCtoken[_token] = _cToken;
    }
    function supplyERC20ToCompound(address _token,uint _numTokenForSupply) external returns(uint,uint,uint){
        User storage user = userInfo[msg.sender];
        address _ctoken = tokenForCtoken[_token];
        IERC20(_token).transferFrom(msg.sender, address(this), _numTokenForSupply);
        user.tokenDeposited[_token] = _numTokenForSupply;
        uint exchangerRateStored = ICErc20(_ctoken).exchangeRateStored();
        uint exchangeRateMantissa = ICErc20(_ctoken).exchangeRateCurrent();
        uint supplyRatemantissa = ICErc20(_ctoken).supplyRatePerBlock();
        IERC20(_token).approve(_ctoken, _numTokenForSupply);
        uint mintCTokens = _numTokenForSupply / exchangerRateStored;
        uint mintResult = ICErc20(_ctoken).mint(_numTokenForSupply);
        user.suppliedCTokens[_token] = mintCTokens; 
        require(mintResult == 0 ,"Mint has failed");
        emit CTokenInfo(exchangeRateMantissa,supplyRatemantissa,_ctoken);
        return (exchangeRateMantissa,supplyRatemantissa,mintResult);      
    }

    function redeemERC20FromCompound(uint amountCTK,bool reddemType,address _cToken)public returns(uint){
        User storage user = userInfo[msg.sender];
        uint TokenSupplied = user.suppliedCTokens[_cToken];
        //max value for suplpied asset
        uint maxExchangeRedeemERC = ICErc20(_cToken).exchangeRateCurrent() * TokenSupplied;
        require(TokenSupplied > 0,"Did not supply before using redeem");
        uint balanceNow = TokenSupplied - amountCTK;
        user.suppliedCTokens[_cToken] = balanceNow;
        uint redeedmReslt;
        if (reddemType == true){
            redeedmReslt = ICErc20(_cToken).redeem(amountCTK);
        } else {
            redeedmReslt = ICErc20(_cToken).redeemUnderlying(amountCTK);
        }
        require(redeedmReslt == 0,"Redeem c Token unsuccesfful");
        address Token = cTOKENforToken[_cToken];
        uint ExchangeRedeemERC = ICErc20(_cToken).exchangeRateCurrent() * amountCTK;
        user.tokenDeposited[Token] = ExchangeRedeemERC;
        return maxExchangeRedeemERC;
    }
    ///need to calculate liquidity for amount what token user deposit to contract
    function calculateMaxPriceForBorrow(address _user,address tokenC)public view returns(uint){
        User storage user = userInfo[_user];
        uint amountCTokens = user.suppliedCTokens[tokenC];
        //get total price of Ctoken buy the deposited Origin token
        uint PriceamountDeposited = (priceFeed.getUnderlyingPrice(tokenC) * amountCTokens)/1e18;
        (,uint value,) = comptroller.markets(tokenC);
        uint maxBorrowPrice = (value/1e18)*PriceamountDeposited;
        return maxBorrowPrice;    
    }
   

    // function borrowERCFromCompoundForERC(address tokenForLiquidityCalc,uint amountOfCollateral,uint _decimals)public returns (uint){
    //     User storage user = userInfo[msg.sender];
    //     address _cTokenBorrowed = tokenForCtoken[tokenForLiquidityCalc];
    //     //require(usertokensSuppliedToCompound[msg.sender][_cTokenBorrowed] > 0,"Did not supply before using redeem");
    //     address[] memory _cTokens = new address[](1);
    //     _cTokens[0] = _cTokenBorrowed;
    //     uint deposited = user.tokenDeposited[tokenForLiquidityCalc];
    //     uint liquidity = 
        
    //     uint underlingPriceUsd = getCTokenprice(_cTokenBorrowed);
    //     require(underlingPriceUsd > liquidity,"");
    //     uint maxBorrow = (liquidity * (10** _decimals)) / underlingPriceUsd;
    //     require(maxBorrow > 0 ,"max borrow = 0");
    //     require(ICErc20(_cTokenBorrowed).totalSupply() <= amountOfCollateral);
    //     require(ICErc20(_cTokenBorrowed).borrow(maxBorrow) == 0, "borrow failed");
    //     uint borrows = ICErc20(_cTokenBorrowed).borrowBalanceCurrent(msg.sender);
    //     user.borrowedCTokens[_cTokenBorrowed];
    //     return borrows;
    // }
    function repayERCBorrow(address repayUserBalance,uint amountOfBorrow,address _cTokenBorrowed) public returns(uint){
        ICErc20(_cTokenBorrowed).repayBorrow(amountOfBorrow);
        uint borrows = ICErc20(_cTokenBorrowed).borrowBalanceCurrent(repayUserBalance);
        return borrows; 
    }
    function enterToMarket(address _cToken)public {
        address[] memory _cTokens = new address[](1);
        _cTokens[0] = _cToken;
        uint[] memory errors1 = comptroller.enterMarkets(_cTokens);
        require(errors1[0] == 0,"Failed to enter market");
        (uint error2,uint liquidity,uint shortfall) = comptroller.getAccountLiquidity(address(this));
        require(error2 == 0,"Failed to get liquidity");
        require(shortfall == 0, "Account underwater");
        require(liquidity > 0, "Empty liquidity in account");//error
    }
    // function exitMarketWithToken(address token)public {
    //     User storage user = userInfo[msg.sender];
    //     require(user.tokenDeposited[token]>0);
    //     comptroller.exitMarkets[]
    // }
    function getBorrowAmount(address _user,address _cTokenBorrowed)public view returns(uint){
        User storage user = userInfo[_user];
        return user.borrowedCTokens[_cTokenBorrowed];
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