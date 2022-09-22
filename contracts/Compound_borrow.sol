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
        mapping(address=>uint) suppliedTokens;//for  Token
        mapping(address=>uint) borrowedTokens;//borrowed from compound
        mapping(address=>uint) tokenReceivedSupply;// for C token
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
    function getUserSuppliedToken(address _user,address _Token)public view returns(uint){
        User storage user = userInfo[_user];
        return user.suppliedTokens[_Token];
    }
    function getUserBorrowedToken(address _user,address borowedToken)public view returns(uint){
        User storage user = userInfo[_user];
        return user.borrowedTokens[borowedToken];
    }
    function getUserReceivedToken(address _user,address receivedToken)public view returns(uint){
        User storage user = userInfo[_user];
        return user.tokenReceivedSupply[receivedToken];
    }
    function setUserSuppliedToken(address _user,address _token,uint amount)internal {
        User storage user = userInfo[_user];
        user.suppliedTokens[_token] = amount;
    }
    function setUserBorrowedToken(address _user,address _token,uint amount)internal {
        User storage user = userInfo[_user];
        user.borrowedTokens[_token] = amount;
    }
    function setUserReceivedToken(address _user,address _token,uint amount)internal {
        User storage user = userInfo[_user];
        user.tokenReceivedSupply[_token] = amount;
    }
    function createAssetForCtoken(address _token,address _cToken)public onlyRole(DEFAULT_ADMIN_ROLE){
        tokenForCtoken[_token] = _cToken;
    }
    function createAssetForToken(address _cToken,address _token)public onlyRole(DEFAULT_ADMIN_ROLE){
        cTOKENforToken[_cToken] = _token;
    }
    function supplyERC20ToCompound(address _token,uint _numTokenForSupply) external returns(uint,uint,uint){
        // User storage user = userInfo[msg.sender];
        address _ctoken = tokenForCtoken[_token];
        uint balanceUserBefore = getUserSuppliedToken(msg.sender, _token);
        IERC20(_token).transferFrom(msg.sender, address(this), _numTokenForSupply);
        uint totalBalanceUser = balanceUserBefore + _numTokenForSupply;
        setUserSuppliedToken(msg.sender, _token, totalBalanceUser);
        //////////////////////////////////////////////////////////
        uint exchangerRateStored = ICErc20(_ctoken).exchangeRateStored();
        uint exchangeRateMantissa = ICErc20(_ctoken).exchangeRateCurrent();
        uint supplyRatemantissa = ICErc20(_ctoken).supplyRatePerBlock();
        //////////////////////////////////////////////////////////
        uint balanceBefore = ICErc20(_ctoken).balanceOf(address(this));
        IERC20(_token).approve(_ctoken, _numTokenForSupply);
        uint mintResult = ICErc20(_ctoken).mint(_numTokenForSupply);
        require(mintResult == 0 ,"Mint has failed");
        uint balanceAfter = ICErc20(_ctoken).balanceOf(address(this));
        uint tokenreceived = balanceAfter - balanceBefore;
        setUserReceivedToken(msg.sender, _ctoken, tokenreceived);
        emit CTokenInfo(exchangeRateMantissa,supplyRatemantissa,_ctoken);
        return (exchangeRateMantissa,supplyRatemantissa,exchangerRateStored);      
    }

    function redeemERC20FromCompound(uint amountcToken,bool reddemType,address _cToken)public returns(uint){
        address tokenRec = cTOKENforToken[_cToken];
        uint totalReceivedTokens = getUserReceivedToken(msg.sender, _cToken);
        require(amountcToken<=totalReceivedTokens,"IDI NAHUY");
        uint balanceTokenBefore = IERC20(tokenRec).balanceOf(address(this));
        uint redeedmReslt;
        uint balBefore = ICErc20(_cToken).balanceOf(address(this));
        if (reddemType == true){
            redeedmReslt = ICErc20(_cToken).redeem(amountcToken);
        } else {
            redeedmReslt = ICErc20(_cToken).redeemUnderlying(amountcToken);
        }
        require(redeedmReslt == 0,"Redeem c Token unsuccesfful");
        uint balanceTokenAfter = IERC20(tokenRec).balanceOf(address(this));
        setUserSuppliedToken(msg.sender, tokenRec, (balanceTokenAfter - balanceTokenBefore));
        uint balAfter = ICErc20(_cToken).balanceOf(address(this));
        setUserReceivedToken(msg.sender, _cToken, (balBefore - balAfter));
        uint ExchangeRedeemERC = ICErc20(_cToken).exchangeRateCurrent() * amountcToken;
        return ExchangeRedeemERC;
    }
    ///need to calculate liquidity for amount what token user deposit to contract
    function calculateMaxPriceForBorrow(address _user,address _cToken)public view returns(uint,uint){
        uint amountCToken = getUserReceivedToken(_user,_cToken);
        //get total price of Ctoken buy the deposited Origin token
        uint PriceamountDeposited = (priceFeed.getUnderlyingPrice(_cToken)/1*(10**18)) * amountCToken;//6030000000000000000 * amountCToken
        (,uint value,) = comptroller.markets(_cToken);//750000000000000000
        uint maxBorrowPrice = (value/(1*(10**18)))*PriceamountDeposited;//(6030000000000000000 * amountCToken)*750000000000000000
        uint currentBorrowactual = (maxBorrowPrice/5)*4;
        return (maxBorrowPrice,currentBorrowactual);    
    }
   
        //string memory tokenBorrow in mainnet
    function borrowERCFromCompoundForERC(address _cToken,address tokenBorrow,uint amountOfBorrow)public returns (uint,uint){
        address BorrowCToken = tokenForCtoken[tokenBorrow];
        (uint maxBoro,uint ActualLimit) = calculateMaxPriceForBorrow(msg.sender, _cToken);
        uint priceTokenBrr = priceFeed.assetPrices(tokenBorrow);
        uint amountOfTokenBor = (ActualLimit / priceTokenBrr);
        require(ICErc20(BorrowCToken).borrow(amountOfBorrow)==0,"Ne rabotaet nihuya");
        setUserBorrowedToken(msg.sender, BorrowCToken, amountOfTokenBor);
        return (maxBoro,ActualLimit);
    }

    function repayERCBorrow(address repayUserBalance,uint amountOfBorrow,address _cTokenBorrowed) public returns(uint){
        ICErc20(_cTokenBorrowed).repayBorrow(amountOfBorrow);
        uint borrows = ICErc20(_cTokenBorrowed).borrowBalanceCurrent(repayUserBalance);
        return borrows; 
    }
    function enterToMarket(address _cToken)public onlyRole(DEFAULT_ADMIN_ROLE){
        address[] memory _cTokens = new address[](1);
        _cTokens[0] = _cToken;
        uint[] memory errors1 = comptroller.enterMarkets(_cTokens);
        require(errors1[0] == 0,"Failed to enter market");
    }
    // function exitMarketWithToken(address token)public {
    //     User storage user = userInfo[msg.sender];
    //     require(user.tokenDeposited[token]>0);
    //     comptroller.exitMarkets[]
    // }    

    ///////////////////////////////////////////////////////////////////////////
//      function supplyETHtoCompound()public payable returns(bool){
//         uint exchangeRateMantissa = CEth(cTokenETH).exchangeRateCurrent();
//         uint supplyRatemantissa = CEth(cTokenETH).supplyRatePerBlock();
//         CEth(cTokenETH).mint{value: msg.value, gas: 250000};
//         emit CETHInfo(exchangeRateMantissa,supplyRatemantissa);
//         return true;       
//     }
//     function borrowTokenForETH(address _cTokenBorrowing)external payable returns(uint){
//         CEth(cTokenETH).mint{value:msg.value,gas:25000}();
//         address[] memory _cTokens = new address[](1);
//         _cTokens[0] = _cTokenBorrowing;
//         uint[] memory errors1 = comptroller.enterMarkets(_cTokens);
//         require(errors1[0] == 0,"Failed to enter market");
//         (uint error2,uint liquidity,uint shortfall) = comptroller.getAccountLiquidity(address(this));
//         require(error2 == 0,"Failed to get liquidity");
//         require(shortfall == 0, "account underwater");
//         require(liquidity > 0, "account has excess collateral");
//         uint256 underlyingPrice = priceFeed.getUnderlyingPrice(_cTokenBorrowing);
//         uint256 maxBorrowUnderlying = liquidity / underlyingPrice;
//         cToken.borrow(maxBorrowUnderlying);
//         uint256 borrows = cToken.borrowBalanceCurrent(address(this));
//         return borrows;    
//     }
//     function calculateRedeemAmountETH(address _user)public view returns(uint){
//         uint balance = CEth(cTokenETH).balanceOf(_user);
//         return balance * 1e8;
//     }
//     function redeemCETH(uint amount,bool redeemType) public returns(uint){
//         uint redeemResult;
//         if (redeemType == true) {
//             redeemResult = CEth(cTokenETH).redeem(amount);
//         } else {
//             redeemResult = CEth(cTokenETH).redeemUnderlying(amount);
//         }
//         return calculateRedeemAmountETH(msg.sender);
//     }
//     function repayETH(uint _amount)payable public {
//         CEth(cTokenETH).repayBorrow{ value:_amount, gas:25000}();
//     }
// ///////////////////////////////////////////////
//     function ExchangeRate(address _token,uint decimalsToken,uint _amount)public returns(uint){
//         address _cToken = tokenForCtoken[_token];
//         uint oneCtokenInunderlying = ICErc20(_cToken).exchangeRateCurrent()/(1*10^(18 + decimalsToken - 8));
//         return _amount*oneCtokenInunderlying;
//     }
//     function getCTokenprice(address _cToken)public view returns(uint){
//         return priceFeed.getUnderlyingPrice(_cToken);
//     }

}