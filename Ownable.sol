pragma solidity ^0.4.23;

/**
 * @title Ownable
 * @dev The Ownable contract has an owner address, and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".
 */
contract Ownable {
    address public owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }

     /**
      * @dev Allows the current owner to transfer control of the contract to a newOwner.
      * @param newOwner The address to transfer ownership to.
      */
    function transferOwnership(address newOwner) public onlyOwner {
      _transferOwnership(newOwner);
    }

     /**
      * @dev Transfers control of the contract to a newOwner.
      * @param newOwner The address to transfer ownership to.
      */
    function _transferOwnership(address newOwner) internal {
      require(newOwner != address(0));
      emit OwnershipTransferred(owner, newOwner);
      owner = newOwner;
  }

}
