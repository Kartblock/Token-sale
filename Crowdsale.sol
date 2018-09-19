pragma solidity ^0.4.23;

import './Ownable.sol';
import './SafeMath.sol';

/**
 * @title Crowdsale
 * @dev Crowdsale is a base contract for managing a token crowdsale.
 * Crowdsales have a start and end timestamps, where investors can make
 * token purchases. Funds collected are forwarded to a wallet
 * as they arrive.
 */
contract Crowdsale is Ownable {
    using SafeMath for uint256;
    // address where funds are collected
    address public wallet;

    // amount of raised money in wei
    uint256 public PresaleWeiRaised;
    uint256 public mainsaleWeiRaised;
    uint256 public tokenAllocated;

    event WalletChanged(address indexed previousWallet, address indexed newWallet);

    constructor(address _wallet) public {
        require(_wallet != address(0));
        wallet = _wallet;
    }

    function transferWallet(address newWallet) public onlyOwner {
      _transferOwnership(newWallet);
    }

    function _transferWallet(address newWallet) internal {
      require(newWallet != address(0));
      emit WalletChanged(owner, newWallet);
      wallet = newWallet;
    }
}
