pragma solidity >=0.5.0;

interface ISwapXToken {
    function initialize(string calldata name, string calldata sym, uint maxSupply) external;

    function transferOwnership(address newOwner) external;

    function verify(bool verified) external;

    function verified() external returns (bool);

    function addIssuer(address _addr) external returns (bool);

    function removeIssuer(address _addr) external returns (bool);

    function issue(address account, uint256 amount) external returns (bool);
}
