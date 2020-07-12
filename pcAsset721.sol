pragma solidity ^0.5.1;

import './erc721.sol';
import './pxCoin.sol';
import './AddressUtils.sol';
import './ERC721TokenReceiver.sol';
import './SafeMath.sol';

contract pcAsset721 is ERC721{
    
    using AddressUtils for address;
    using SafetyMath for uint256;
    
    address payable public foundation;
    pxCoin pxcoin;
   
    mapping(address=>uint256) _ownerTokenCount; // owner -> balance  
    mapping(uint256=>address) public _tokenOwner; // tokenId -> owner 
    mapping(uint256=>address) _tokenApprovals;//tokenId -> approved 
    mapping(address=>mapping(address=>bool)) _operatorApprovals;//owner => operator => bool
    
    bytes4 constant MAGIC_ON_ERC721_RECEIVED = 0x150b7a02;
    
    struct Asset{
        string contentHash;// photo hash only 
        uint256 price; //photo price  
        uint256 weight; //photo amount
        string metaData; //origional info
    }
    
    Asset[] public assets; //slice of photo asset

    constructor() public payable{
        foundation = msg.sender;
        pxcoin = new pxCoin(1000000000, msg.sender);
    }
    
    modifier canTransfer(uint256 _tokenId){
        address tokenOwner = _tokenOwner[_tokenId];
        require(tokenOwner == msg.sender ||
                //_tokenApprovals[_tokenId] == msg.sender ||
                _getApproved(_tokenId) == msg.sender ||
                _operatorApprovals[tokenOwner][msg.sender]);
        _;
    }
    
    modifier canApprove(uint256 _tokenId) {
        address tokenOwner = _tokenOwner[_tokenId];
         require(tokenOwner == msg.sender ||
                _operatorApprovals[tokenOwner][msg.sender]);       
        _;
    }
    
    modifier validToken(uint256 _tokenId) {
        
        require(_tokenOwner[_tokenId] != address(0));
       // require(_ownerTokenCount[tokenOwner] > 0);
        _;
    }
    
    modifier onlyOwner(){
        require(foundation == msg.sender);
        _;
    }
    
    
    function balanceOf(address _owner) external view returns(uint256){
        require(address(0) != _owner);
        return _ownerTokenCount[_owner];
    }
    function ownerOf(uint256 _tokenId) external view returns(address){
        //address tokenOwner = _tokenOwner[_tokenId];
        require(address(0) != _tokenOwner[_tokenId]);
        return _tokenOwner[_tokenId];
    }
    
    //defined function to change mapping
    // function changeToken(address _from, address _to, uint256 _tokenId) private;
    
    //defined function to remove mapping(tokenId => owner)
    function removeToken(address _from, uint256 tokenId) private {
        require(_tokenOwner[tokenId] == _from);
        assert(_ownerTokenCount[_from] > 0);
        
        _ownerTokenCount[_from] -= 1;
        delete _tokenOwner[tokenId];
    }
    
    function addToken(address _to, uint256 tokenId) private {
        require(_tokenOwner[tokenId] == address(0));
        require(address(0) != _to);
        
        _ownerTokenCount[_to] = _ownerTokenCount[_to].add(1);
        _tokenOwner[tokenId] = _to;
    }
    
    //defined function to clear Approval
    function clearApproval(uint256 _tokenId) private {
        if (_tokenApprovals[_tokenId] != address(0)){
            delete _tokenApprovals[_tokenId];
        }
    }
    
    
    function _transfer(address _to, uint256 _tokenId) private{
        address tokenOwner = _tokenOwner[_tokenId];
        //function -> clear Approval
        clearApproval(_tokenId);
        //function -> change mapping
        removeToken(tokenOwner, _tokenId);
        addToken(_to, _tokenId);
        
        
        emit Transfer(tokenOwner, _to, _tokenId);
    }
    
    function transferFrom(address _from, address _to, uint256 _tokenId) canTransfer(_tokenId) validToken(_tokenId) external payable{
        address tokenOwner = _tokenOwner[_tokenId];
        require(address(0) != _to);
        if (_from == msg.sender ||
            _from == _tokenApprovals[_tokenId] ||
            _operatorApprovals[tokenOwner][_from]
            ) {
                _transfer(_to, _tokenId);
            }

    }
    
    
    function _safeTransferFrom(address _from, address _to, uint256 _tokenId, byte data) canTransfer(_tokenId) validToken(_tokenId) private{
        address tokenOwner = _tokenOwner[_tokenId];
        require(address(0) != _to);
        _transfer(_to, _tokenId);
        if(_to.isContract()) {
            bytes4 retval = ERC721TokenReceiver(_to).onERC721Received(msg.sender, _from, _tokenId, data);
            require(retval == MAGIC_ON_ERC721_RECEIVED);
        }
        
    }
    
    function safeTransferFrom(address _from, address _to, uint256 _tokenId, byte data) external payable{
        _safeTransferFrom(_from, _to, _tokenId, data);
    }
    
    function safeTransferFrom(address _from, address _to, uint256 _tokenId) external payable{
        _safeTransferFrom(_from, _to, _tokenId, "");
    }
    
    
    function approve(address _approved, uint256 _tokenId) canApprove(_tokenId) validToken(_tokenId) external payable{
        //address tokenOwner = _tokenOwner[_tokenId];
        require(address(0) != _approved);
        _tokenApprovals[_tokenId] = _approved;
    }
    
    
    function _getApproved(uint256 _tokenId) validToken(_tokenId) private view returns(address){
        return _tokenApprovals[_tokenId];
    }


    function getApproved(uint256 _tokenId) external view returns(address){
        return _getApproved(_tokenId);
    }
    
    // function getApproved(uint256 _tokenId) external view returns(address){
    //  return _tokenApprovals[_tokenId];
    // }
    
    function setApprovalForAll(address _operator, bool _approved) external{
        require(address(0) != _operator);
        require(_ownerTokenCount[msg.sender] > 0);
        _operatorApprovals[msg.sender][_operator] = _approved;// @the _approved is true or fasle, get Approved or lose Approved
        emit ApprovalForAll(msg.sender, _operator, _approved);
    }
    
    function isApprovalForAll(address _owner, address _operator) external view returns(bool) {
        return _operatorApprovals[_owner][_operator];
    }
    
    event Transfer(address indexed _from, address indexed _to, uint256 indexed _tokenId);
    event Approval(address indexed _owner, address indexed _approved, uint256 indexed _tokenId);
    event ApprovalForAll(address indexed _owner, address indexed _operator, bool _approved);
    
    function newAsset(string memory contentHash, uint256 price, uint256 weight, string memory metaData) private returns(uint256){
        Asset memory a = Asset(contentHash, price, weight, metaData);
        uint256 tokenId = assets.push(a) - 1; // push method return len of assets, get tokeId 
        _tokenOwner[tokenId] = msg.sender;
        return tokenId;
        
    }
    
    //put photo to net is mint 
    function mint(string calldata contentHash, uint256 price, uint256 weight, string calldata metaData) external returns(uint256){
        // new asset
        uint256 tokenId = newAsset(contentHash, price, weight, metaData);
        
        //updata mapping
        
        _ownerTokenCount[msg.sender] =_ownerTokenCount[msg.sender].add(1);
        pxcoin.transfer(msg.sender, 100);
        return tokenId;
    }
    
    function splitAsset(uint256 _tokenId, uint256 _weight, address _buyer) validToken(_tokenId) onlyOwner() external returns(uint256) {
     
        
        require(_weight < 100);
        require(address(0) != _buyer);
        
        Asset storage a = assets[_tokenId];
        require(a.weight > _weight);
        
        uint256 tokenId = assets.push(a) - 1;
        a = assets[tokenId];
        a.weight = _weight;
        addToken(_buyer, tokenId);
        
        a = assets[_tokenId];
        a.weight = a.weight.sub(_weight);
        assets[tokenId] = a;
        
        return tokenId;
        
        
        
        
        // require(_weight < 100);
        // require(address(0) != _buyer);
       
        // // new asset
        // Asset storage a = assets[_tokenId];
        // require(_weight < a.weight);
        
        // uint256 tokenIdforBuyer = assets.push(a) - 1;
        // //updata old asset
        // assets[tokenIdforBuyer].weight = _weight;
        // a.weight = a.weight.sub(_weight);
        // addToken(_buyer, tokenIdforBuyer);
        
        // return tokenIdforBuyer;
    }
    
    
    
    
    
    

    //get PXC balance 
    function getPXCBalance(address _owner) public view returns(uint256){
        return pxcoin.balanceOf(_owner);
    }
    //get PXC contract address
    function getPXCAddr() public view returns(address){
        return pxcoin.getAddr();
    }
}
