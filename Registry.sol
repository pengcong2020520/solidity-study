pragma solidity ^0.5.1;

contract Registry {
    address current;
    address[] prevoious;
    
    function updata(address newAddress) public {
        if (newAddress != current) {
                prevoious.push(current);
                current = newAddress;
        }
    }
    
    function getCurrent() public view returns (address) {
        return current;
    }
}