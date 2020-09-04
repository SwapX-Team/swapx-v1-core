pragma solidity =0.5.16;

import './interfaces/ISwapXV1Factory.sol';
import './libraries/PairNamer.sol';
import './token/SwapXToken.sol';
import './SwapXV1Pair.sol';


contract SwapXV1Factory is ISwapXV1Factory {
    address public feeTo;
    address public setter;
    address public miner;

    mapping(address => mapping(address => address)) public getPair;
    mapping(address => address) public token2Pair;
    mapping(address => address) public pair2Token;
    address[] public allPairs;
    address[] public pairTokens;

    event PairCreated(address indexed token0, address indexed token1, address pair, address indexed ptoken, uint);

    constructor(address _setter) public {
        require(_setter != address(0), 'SwapxV1: SETTER INVALID');
        setter = _setter;
    }

    function allPairsLength() external view returns (uint) {
        return allPairs.length;
    }

    function createPair(address tokenA, address tokenB) external returns (address pair, address pToken) {
        require(miner != address(0), 'SwapxV1: MINER INVALID');
        require(tokenA != tokenB, 'SwapxV1: IDENTICAL_ADDRESSES');
        (address token0, address token1) = tokenA < tokenB ? (tokenA, tokenB) : (tokenB, tokenA);
        require(token0 != address(0), 'SwapxV1: ZERO_ADDRESS');
        require(getPair[token0][token1] == address(0), 'SwapxV1: PAIR_EXISTS');

        // single check is sufficient
        bytes memory bytecode = type(SwapXV1Pair).creationCode;
        bytes32 salt = keccak256(abi.encodePacked(token0, token1));
        bytes memory bytecode1 = type(SwapXToken).creationCode;

        assembly {
            pair := create2(0, add(bytecode, 32), mload(bytecode), salt)
            pToken := create2(0, add(bytecode1, 32), mload(bytecode1), salt)
        }
        ISwapXV1Pair(pair).initialize(token0, token1);
        ISwapXToken(pToken).initialize("Pair Token", PairNamer.pairPtSymbol(tokenA, tokenB, "X"), 5760000 * 10 ** 18);
        ISwapXToken(pToken).addIssuer(miner);
        ISwapXToken(pToken).transferOwnership(setter);
        getPair[token0][token1] = pair;
        getPair[token1][token0] = pair;
        token2Pair[pToken] = pair;
        pair2Token[pair] = pToken;
        // populate mapping in the reverse direction
        allPairs.push(pair);
        pairTokens.push(pToken);
        emit PairCreated(token0, token1, pair, pToken, allPairs.length);
    }

    function setMiner(address _miner) external {
        require(isContract(_miner), "SwapXV1: MINER MUST BE CONTRACT");
        require(msg.sender == setter, 'SwapXV1: FORBIDDEN');
        miner = _miner;
    }

    function setFeeTo(address _feeTo) external {
        require(msg.sender == setter, 'SwapXV1: FORBIDDEN');
        feeTo = _feeTo;
    }


    function setSetter(address _setter) external {
        require(false,"SwapXV1: NOT SUPPORT");
    }

    function isContract(address addr) internal view returns (bool) {
        uint size;
        assembly {size := extcodesize(addr)}
        return size > 0;
    }
}
