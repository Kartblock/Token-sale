pragma solidity ^0.4.23;

import './Ownable.sol';
import './SafeMath.sol';
import './MintableToken.sol';
import './Whitelist.sol';
import './Crowdsale.sol';


contract KartblockCrowdsale is Ownable, Crowdsale, Whitelist, MintableToken {
    using SafeMath for uint256;


    // ===== Cap & Goal Management =====
    uint256 public constant presaleCap = 10000 * (10 ** uint256(decimals));
    uint256 public constant mainsaleCap = 175375 * (10 ** uint256(decimals));
    uint256 public constant mainsaleGoal = 11700 * (10 ** uint256(decimals));

    // ============= Token Distribution ================
    uint256 public constant INITIAL_SUPPLY = 1000000000 * (10 ** uint256(decimals));
    uint256 public constant totalTokensForSale = 195500000 * (10 ** uint256(decimals));
    uint256 public constant tokensForFuture = 760000000 * (10 ** uint256(decimals));
    uint256 public constant tokensForswap = 4500000 * (10 ** uint256(decimals));
    uint256 public constant tokensForInvester1 = 16000000 * (10 ** uint256(decimals));
    uint256 public constant tokensForInvester2 = 16000000 * (10 ** uint256(decimals));
    uint256 public constant tokensForInvester3 = 8000000 * (10 ** uint256(decimals));

    // how many token units a buyer gets per wei
    uint256 public rate;
    mapping (address => uint256) public deposited;
    address[] investors;

    event TokenPurchase(address indexed beneficiary, uint256 value, uint256 amount);
    event TokenLimitReached(uint256 tokenRaised, uint256 purchasedToken);
    event Finalized();

    constructor(
      address _owner,
      address _wallet
      ) public Crowdsale(_wallet) {

        require(_wallet != address(0));
        require(_owner != address(0));
        owner = _owner;
        mintingFinished = false;
        totalSupply = INITIAL_SUPPLY;
        rate = 1140;
        bool resultMintForOwner = mintForOwner(owner);
        require(resultMintForOwner);
        balances[0x9AF6043d1B74a7c9EC7e3805Bc10e41230537A8B] = balances[0x9AF6043d1B74a7c9EC7e3805Bc10e41230537A8B].add(tokensForswap);
        mainsaleWeiRaised.add(tokensForswap);
        balances[investor1] = balances[investor1].add(tokensForInvester1);
        balances[investor2] = balances[investor1].add(tokensForInvester2);
        balances[investor3] = balances[investor1].add(tokensForInvester3);
    }

    // fallback function can be used to buy tokens
    function() payable public {
        buyTokens(msg.sender);
    }

    // low level token purchase function
    function buyTokens(address _investor) public  payable returns (uint256){
        require(_investor != address(0));
        require(validPurchase());
        uint256 weiAmount = msg.value;
        uint256 tokens = _getTokenAmount(weiAmount);
        if (tokens == 0) {revert();}

        // update state
        if (isPresalePeriod())  {
          PresaleWeiRaised = PresaleWeiRaised.add(weiAmount);
        } else if (isMainsalePeriod()) {
          mainsaleWeiRaised = mainsaleWeiRaised.add(weiAmount);
        }
        tokenAllocated = tokenAllocated.add(tokens);
        if (verifiedAddresses[_investor]) {
           mint(_investor, tokens, owner);
        }else {
          investors.push(_investor);
          deposited[_investor] = deposited[_investor].add(tokens);
        }
        emit TokenPurchase(_investor, weiAmount, tokens);
        wallet.transfer(weiAmount);
        return tokens;
    }

    function _getTokenAmount(uint256 _weiAmount) internal view returns(uint256) {
      return _weiAmount.mul(rate);
    }

    // ====================== Price Management =================
    function setPrice() public onlyOwner {
      if (isPresalePeriod()) {
        rate = 1140;
      } else if (isMainsalePeriod()) {
        rate = 1597;
      }
    }

    function isPresalePeriod() public view returns (bool) {
      if (now >= presaleStartTime && now < presaleEndTime) {
        return true;
      }
      return false;
    }

    function isMainsalePeriod() public view returns (bool) {
      if (now >= mainsaleStartTime && now < mainsaleEndTime) {
        return true;
      }
      return false;
    }

    function mintForOwner(address _wallet) internal returns (bool result) {
        result = false;
        require(_wallet != address(0));
        balances[_wallet] = balances[_wallet].add(INITIAL_SUPPLY);
        result = true;
    }

    function getDeposited(address _investor) public view returns (uint256){
        return deposited[_investor];
    }

    // @return true if the transaction can buy tokens
    function validPurchase() internal view returns (bool) {
      bool withinCap =  true;
      if (isPresalePeriod()) {
        withinCap = PresaleWeiRaised.add(msg.value) <= presaleCap;
      } else if (isMainsalePeriod()) {
        withinCap = mainsaleWeiRaised.add(msg.value) <= mainsaleCap;
      }
      bool withinPeriod = isPresalePeriod() || isMainsalePeriod();
      bool minimumContribution = msg.value >= 0.5 ether;
      return withinPeriod && minimumContribution && withinCap;
    }

    function readyForFinish() internal view returns(bool) {
      bool endPeriod = now < mainsaleEndTime;
      bool reachCap = tokenAllocated <= mainsaleCap;
      return endPeriod || reachCap;
    }


    // Finish: Mint Extra Tokens as needed before finalizing the Crowdsale.
    function finalize(
      address _tokensForFuture
      ) public onlyOwner returns (bool result) {
        require(_tokensForFuture != address(0));
        require(readyForFinish());
        result = false;
        mint(_tokensForFuture, tokensForFuture, owner);
        address contractBalance = this;
        wallet.transfer(contractBalance.balance);
        finishMinting();
        emit Finalized();
        result = true;
    }

    function transferToInvester() public onlyOwner returns (bool result) {
        require( now >= 1548363600);
        for (uint cnt = 0; cnt < investors.length; cnt++) {
            mint(investors[cnt], deposited[investors[cnt]], owner);
        }
        result = true;
    }

}
