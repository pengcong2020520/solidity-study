pragma solidity ^0.5.1;

/*
 * @dev Math operations with safety checks that throw on error. 
 */
 
library SafetyMath{

/*
 * @dev Multiplies two numbers, throw on overflow.
 * @param _a Factor number.
 * @param _b Factor number.
 */
 
 function mul(uint256 _a, uint256 _b) internal pure returns(uint256) {
     if (_a == 0){
         return 0;
     }
     uint256 c = _a * _b;
     assert(c / _a == _b);
     return c;
 }
 
 function div(uint256 _a, uint256 _b) internal pure returns(uint256) {
     uint256 c = _a / _b;
     assert(_b > 0);
     assert(_a == _b * c + _a % _b);
     return c;
 }
 
 function sub(uint256 _a, uint256 _b) internal pure returns(uint256){
     assert(_a >= _b);
     return _a - _b;
 }
 
 function add(uint256 _a, uint256 _b) internal pure returns(uint256) {
     uint256 c = _a + _b;
     assert(c >= _a);
     return c;
 }
 

 
 
    
}
