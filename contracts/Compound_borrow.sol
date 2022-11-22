// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.10;

// Uncomment this line to use console.log
import "hardhat/console.sol";

import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/security/PausableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/AccessControlUpgradeable.sol";
import "./interfaces/ComptrollerInterfaces.sol";

contract Compound_borrow is
    Initializable,
    UUPSUpgradeable,
    AccessControlUpgradeable,
    PausableUpgradeable
{
    using SafeERC20 for IERC20;
    ICErc20 public cToken;
    CEth public cTokenETH;
    ComptrollerInterfaces public comptroller;
    PriceFeed public priceFeed;

    struct User {
        mapping(address => uint256) suppliedTokens; //for Token
        mapping(address => uint256) borrowedTokens; //borrowed from compound
        mapping(address => uint256) tokenReceivedSupply; // for C token
    }

    mapping(address => User) userInfo;
    mapping(address => address) public tokenForCtoken;
    mapping(address => address) public cTOKENforToken;
    mapping(address => bool) public marketEnter;
    event CTokenInfo(
        uint256 exchangeRateMantissa,
        uint256 supplyRateMantisssa,
        address ctoken
    );
    event CETHInfo(uint256 exchangeRateMantissa, uint256 supplyRateMantisssa);

    receive() external payable {}

    function initialize(
        CEth cTokenEth,
        ComptrollerInterfaces comtroller,
        PriceFeed oracle
    ) public {
        cTokenEth = cTokenETH;
        comptroller = comtroller;
        priceFeed = oracle;
        createAssetForCtoken(
            0x87ac1f4C6b65B015714275F9AA47561252111CDC,
            0xa51f602380B29D3bbbabf6D25e2d3bD842C3C762
        );
        _setupRole(DEFAULT_ADMIN_ROLE, _msgSender());
    }

    function comMarketsForCtoken(address _cToken)
        public
        view
        returns (uint256)
    {
        (, uint256 value, ) = comptroller.markets(_cToken);
        return value;
    }

    function getUserSuppliedToken(address _user, address _Token)
        public
        view
        returns (uint256)
    {
        User storage user = userInfo[_user];
        return user.suppliedTokens[_Token];
    }

    function getUserBorrowedToken(address _user, address borowedToken)
        public
        view
        returns (uint256)
    {
        User storage user = userInfo[_user];
        return user.borrowedTokens[borowedToken];
    }

    function getUserReceivedToken(address _user, address receivedToken)
        public
        view
        returns (uint256)
    {
        User storage user = userInfo[_user];
        return user.tokenReceivedSupply[receivedToken];
    }

    function setUserSuppliedToken(
        address _user,
        address _token,
        uint256 amount
    ) internal {
        User storage user = userInfo[_user];
        user.suppliedTokens[_token] = amount;
    }

    function setUserBorrowedToken(
        address _user,
        address _token,
        uint256 amount
    ) internal {
        User storage user = userInfo[_user];
        user.borrowedTokens[_token] = amount;
    }

    function setUserReceivedToken(
        address _user,
        address _token,
        uint256 amount
    ) internal {
        User storage user = userInfo[_user];
        user.tokenReceivedSupply[_token] = amount;
    }

    function createAssetForCtoken(address _token, address _cToken)
        public
        onlyRole(DEFAULT_ADMIN_ROLE)
    {
        tokenForCtoken[_token] = _cToken;
    }

    function createAssetForToken(address _cToken, address _token)
        public
        onlyRole(DEFAULT_ADMIN_ROLE)
    {
        cTOKENforToken[_cToken] = _token;
    }

    function withdrawToUser(address token, uint256 amount) public {
        require(getUserSuppliedToken(msg.sender, token) >= amount);
        IERC20(token).transferFrom(address(this), msg.sender, amount);
    }

    ///to calculate income amount need multiply income amount of token for exhcnageRateMantissa
    function supplyERC20ToCompound(address _token, uint256 _numTokenForSupply)
        external
    {
        // User storage user = userInfo[msg.sender];
        address _ctoken = tokenForCtoken[_token];
        uint256 balanceUserBefore = getUserSuppliedToken(msg.sender, _token);
        IERC20(_token).transferFrom(
            msg.sender,
            address(this),
            _numTokenForSupply
        );
        uint256 totalBalanceUser = balanceUserBefore + _numTokenForSupply;
        setUserSuppliedToken(msg.sender, _token, totalBalanceUser);
        uint256 exchangerRateStored = ICErc20(_ctoken).exchangeRateStored();
        uint256 usercTokenReceived = (_numTokenForSupply /
            exchangerRateStored) * 1e11;

        IERC20(_token).approve(_ctoken, _numTokenForSupply);
        uint256 mintResult = ICErc20(_ctoken).mint(_numTokenForSupply);
        require(mintResult == 0, "Mint has failed");
        require(mintResult == usercTokenReceived);
        setUserReceivedToken(msg.sender, _ctoken, usercTokenReceived);
    }

    function redeemERC20FromCompound(
        uint256 amountcToken,
        bool reddemType,
        address _cToken
    ) public returns (uint256) {
        address tokenRec = cTOKENforToken[_cToken];
        uint256 totalReceivedTokens = getUserReceivedToken(msg.sender, _cToken);
        require(amountcToken <= totalReceivedTokens, "IDI NAHUY");
        uint256 balanceTokenBefore = IERC20(tokenRec).balanceOf(address(this));
        uint256 redeedmReslt;
        uint256 balBefore = ICErc20(_cToken).balanceOf(address(this));
        if (reddemType == true) {
            redeedmReslt = ICErc20(_cToken).redeem(amountcToken);
        } else {
            redeedmReslt = ICErc20(_cToken).redeemUnderlying(amountcToken);
        }
        require(redeedmReslt == 0, "Redeem c Token unsuccesfful");
        uint256 balanceTokenAfter = IERC20(tokenRec).balanceOf(address(this));
        setUserSuppliedToken(
            msg.sender,
            tokenRec,
            (balanceTokenAfter - balanceTokenBefore)
        );
        uint256 balAfter = ICErc20(_cToken).balanceOf(address(this));
        setUserReceivedToken(msg.sender, _cToken, (balBefore - balAfter));
        uint256 ExchangeRedeemERC = updateExchangeRateForCtoken(_cToken) *
            amountcToken;
        return ExchangeRedeemERC;
    }

    //368,731,042,715,470,781,352,000,947.929963162104900339
    ///to calculate total supply balance need to exchange cToken amount for

    //1000,0000,0001,1494,9999.9604,5427  = amount of token
    function calculateMaxPriceForBorrow(address _user, address _cToken)
        public
        returns (uint256)
    {
        uint256 amountCToken = getUserReceivedToken(_user, _cToken);
        // uint256 underlyingPrice = priceFeed.getUnderlyingPrice(_cToken);
        // uint amountOfToken = ((amountCToken)/1*(10**18) * (updateExchangeRateForCtoken(_cToken)/(1*(10**12))));
        // uint256 maxBorrowUnderlying = amountOfToken * underlyingPrice;
        // emit zalupa(amountOfToken,maxBorrowUnderlying);
        // return maxBorrowUnderlying;
    }

    function updateExchangeRateForCtoken(address _cToken)
        internal
        returns (uint256)
    {
        return ICErc20(_cToken).exchangeRateCurrent();
    }

    function calculateAmountOfBorrowToken(
        uint256 balanceInUSD,
        address _tokenBorrow
    ) public view returns (uint256) {
        if (_tokenBorrow == 0x79C950C7446B234a6Ad53B908fBF342b01c4d446) {
            uint256 tokenCost = priceFeed.assetPrices(_tokenBorrow);
            uint256 amountofToken = ((balanceInUSD / tokenCost) / 1) * (10**18);
            return amountofToken;
        } else {}

        //return
    }

    function borrowERCFromCompoundForERC(
        address _cToken,
        address tokenBorrow,
        uint256 amountOfBorrow
    ) public returns (uint256) {
        address BorrowCToken = tokenForCtoken[tokenBorrow];
        uint256 ActualLimit = calculateMaxPriceForBorrow(msg.sender, _cToken);
        uint256 priceTokenBrr = priceFeed.assetPrices(tokenBorrow);
        uint256 amountOfTokenBor = (ActualLimit / priceTokenBrr);
        require(
            ICErc20(BorrowCToken).borrow(amountOfBorrow) == 0,
            "Ne rabotaet nihuya"
        );
        setUserBorrowedToken(msg.sender, BorrowCToken, amountOfTokenBor);
        return (ActualLimit);
    }

    function repayERCBorrow(
        address repayUserBalance,
        uint256 amountOfBorrow,
        address _cTokenBorrowed
    ) public returns (uint256) {
        ICErc20(_cTokenBorrowed).repayBorrow(amountOfBorrow);
        uint256 borrows = ICErc20(_cTokenBorrowed).borrowBalanceCurrent(
            repayUserBalance
        );
        return borrows;
    }

    function enterToMarket(address _cToken)
        public
        onlyRole(DEFAULT_ADMIN_ROLE)
    {
        address[] memory _cTokens = new address[](1);
        _cTokens[0] = _cToken;
        uint256[] memory errors1 = comptroller.enterMarkets(_cTokens);
        require(errors1[0] == 0, "Failed to enter market");
    }

    function exitMarketWithToken(address _cToken)
        public
        onlyRole(DEFAULT_ADMIN_ROLE)
        returns (uint256)
    {
        address[] memory _cTokens = new address[](1);
        _cTokens[0] = _cToken;
        uint256[] memory errors1 = comptroller.exitMarket(_cTokens);
        require(errors1[0] == 0, "Exit market failed");
        return errors1[0];
    }

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
    function _authorizeUpgrade(address newImplementation)
        internal
        override
        onlyRole(DEFAULT_ADMIN_ROLE)
    {}
}
