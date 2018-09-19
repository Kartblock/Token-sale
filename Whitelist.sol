pragma solidity ^0.4.23;

import './Ownable.sol';

contract Whitelist is Ownable {

    mapping (address => bool) verifiedAddresses;

    function isAddressWhitelist(address _address) public view returns (bool) {
        return verifiedAddresses[_address];
    }

    function whitelistAddress(address _newAddress) external onlyOwner {
        verifiedAddresses[_newAddress] = true;
    }

    function removeWhitelistAddress(address _oldAddress) external onlyOwner {
        require(verifiedAddresses[_oldAddress]);
        verifiedAddresses[_oldAddress] = false;
    }

    function batchWhitelistAddresses(address[] _addresses) external onlyOwner {
        for (uint cnt = 0; cnt < _addresses.length; cnt++) {
            assert(!verifiedAddresses[_addresses[cnt]]);
            verifiedAddresses[_addresses[cnt]] = true;
        }
    }
}
