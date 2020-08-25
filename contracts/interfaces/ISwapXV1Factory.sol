pragma solidity >=0.5.0;

interface ISwapXV1Factory {
    event PairCreated(address indexed token0, address indexed token1, address pair, address pToken, uint);

    function feeTo() external view returns (address);

    function setter() external view returns (address);

    function miner() external view returns (address);

    function token2Pair(address token) external view returns (address pair);

    function pair2Token(address pair) external view returns (address pToken);

    function getPair(address tokenA, address tokenB) external view returns (address pair);

    function allPairs(uint) external view returns (address pair);

    function pairTokens(uint) external view returns (address pair);

    function allPairsLength() external view returns (uint);

    function createPair(address tokenA, address tokenB) external returns (address pair, address pToken);

    function setFeeTo(address) external;

    function setSetter(address) external;

    function setMiner(address) external;

}
