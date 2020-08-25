pragma solidity >=0.5.0;

interface ISwapXPTV1{
    function initialize(string calldata name, string calldata sym, uint maxSupply) external;
    function transferOwnership(address newOwner) external;
    function verify(bool verified) external;
}
