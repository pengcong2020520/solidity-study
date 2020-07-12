pragma solidity ^0.5.1; 

contract ERC721{
    
    function balanceOf(address _owner) external view returns(uint256);
    function ownerOf(uint256 _tokenId) external view returns(address);
    function transferFrom(address _from, address _to, uint256 _tokenId) external payable;
    function safeTransferFrom(address _from, address _to, uint256 _tokenId, byte data) external payable;
    function safeTransferFrom(address _from, address _to, uint256 _tokenId) external payable;
    function approve(address _to, uint256 _tokenId) external payable;
    function getApproved(uint256 _tokenId) external view returns(address);
    function setApprovalForAll(address _operator, bool _approved) external;
    function isApprovalForAll(address _owner, address _operator) external view returns(bool);
    
    event Transfer(address indexed _from, address indexed _to, uint256 indexed _tokenId);
    event Approval(address indexed _owner, address indexed _approved, uint256 indexed _tokenId);
    event ApprovalForAll(address indexed _owner, address indexed _operator, bool _approved);
    
    
}
