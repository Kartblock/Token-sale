pragma solidity ^0.4.23;

import './ERC20Basic.sol';
import './SafeMath.sol';

/**
 * @title Basic token
 * @dev Basic version of StandardToken, with no allowances.
 */
 contract BasicToken is ERC20Basic {
     using SafeMath for uint256;

     mapping (address => uint256) balances;

     // 2018-09-24 00:00:00 AST - start time for pre sale
     uint256 public presaleStartTime = 1537736400;

     // 2018-10-24 23:59:59 AST - end time for pre sale
     uint256 public presaleEndTime = 1540414799;

     // 2018-11-04 00:00:00 AST - start time for main sale
     uint256 public mainsaleStartTime = 1541278800;

     // 2019-01-04 23:59:59 AST - end time for main sale
     uint256 public mainsaleEndTime = 1546635599;

     address public constant investor1 = 0x8013e8F85C9bE7baA19B9Fd9a5Bc5C6C8D617446;
     address public constant investor2 = 0xf034E5dB3ed5Cb26282d2DC5802B21DB3205B882;
     address public constant investor3 = 0x1A7dD28A461D7e0D75b89b214d5188E0304E5726;

     /**
     * @dev transfer token for a specified address
     * @param _to The address to transfer to.
     * @param _value The amount to be transferred.
     */
     function transfer(address _to, uint256 _value) public returns (bool) {
         require(_to != address(0));
         require(_value <= balances[msg.sender]);
         if (( (msg.sender == investor1) || (msg.sender == investor2) || (msg.sender == investor3)) && (now < (presaleStartTime + 300 days))) {
           revert();
         }
         // SafeMath.sub will throw if there is not enough balance.
         balances[msg.sender] = balances[msg.sender].sub(_value);
         balances[_to] = balances[_to].add(_value);
         emit Transfer(msg.sender, _to, _value);
         return true;
     }

     /**
     * @dev Gets the balance of the specified address.
     * @param _owner The address to query the the balance of.
     * @return An uint256 representing the amount owned by the passed address.
     */
     function balanceOf(address _owner) public constant returns (uint256 balance) {
         return balances[_owner];
     }

 }
