pragma solidity ^0.5.16;

contract SwapXPTStorage {
    mapping (address => uint256) internal _balances;
    mapping (address => mapping (address => uint256)) internal _allowances;
    uint256 internal _totalSupply;
    uint256 internal _maxSupply;
    string internal _name;
    string internal _symbol;
    uint8 internal _decimals;
    address owner;
    mapping(address => bool) internal issuer;
}
