//SPDX-License-Identifier: MIT
pragma solidity =0.7.6;
pragma abicoder v2;

import "hardhat/console.sol";
import "@uniswap/v3-core/contracts/interfaces/IUniswapV3Factory.sol";
import "@uniswap/v3-periphery/contracts/libraries/OracleLibrary.sol";

contract UniswapV3Twap {
    // WETH GOERLI
    address public immutable token0_goerli = 0xB4FBF271143F4FBf7B91A5ded31805e42b2208d6;
    // WETH SEPOLIA
    address public immutable token0_sepolia = 0xfFf9976782d46CC05630D1f6eBAb18b2324d6B14;
    // UNI SEPOLIA
    address public immutable token1_sepolia = 0x1f9840a85d5aF5bf1D1762F925BDADdC4201F984;
    // WETH
    address public immutable token0 = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;
    // USDC
    address public immutable token1 = 0x7EA2be2df7BA6E54B1A9C70676f668455E329d29;
    // WETH-USDC POOL
    address public pool;
    // GOERLI FACTORY
    address public immutable factory = 0x1F98431c8aD98523631AE4a59f267346ea31F984;

    uint32 private interval;

    PriceOracle public oracle;

    struct Price {
        uint256 time;
        uint256 price;
    }

    struct PriceOracle {
        mapping (uint256 => Price) _data;
        uint256 first;
        uint256 last;
        uint256 size;
    }

    // Parameters are constants
    constructor(uint256 _size/*, bool _mainnet*/, uint32 _interval) {
        // if (_mainnet) {
        //     pool = 0x88e6A0c2dDD26FEEb64F039a2c41296FcB3f5640;
        // } else  {
        //     pool = IUniswapV3Factory(factory).getPool(
        //         token0_goerli,

        //     )
        // }
        require(_size > 0);
        pool = 0x224Cc4e5b50036108C1d862442365054600c260C;
        oracle.first = 1;
        oracle.last = 0;
        oracle.size = _size;
        interval = _interval;
    }
    /**
     * @dev Computes a TWAP for the token pair
     * @param amountIn The amount of WETH to trade
     * @param secondsAgo The length of the TWAP to compute the oracle
     */
    function estimateAmountOut(
        uint128 amountIn,
        uint32 secondsAgo
    ) public view returns (uint amountOut) {
        (int24 tick, ) = OracleLibrary.consult(pool, secondsAgo);
        amountOut = OracleLibrary.getQuoteAtTick(
            tick,
            amountIn,
            token0_sepolia,
            token1_sepolia
        );
    }
    /**
     * @dev Gets the length of the queue
     */
    function length() public view returns (uint256) {
        if (oracle.last < oracle.first) {
            return 0;
        }
        return oracle.last - oracle.first + 1;
    }

    /**
     * @dev Gets a list of prices from the oracle
     */
    function getOracle(
        uint256 len
    ) public view returns (Price[] memory) {
        require(len <= length(), "output length must be less than current oracle length");
        Price[] memory arr = new Price[](len);
        for (uint i = 0; i < len; i++) {
            arr[i] = oracle._data[i + oracle.first];
        }
        return arr;
    }

    /**
     * @dev Updates the oracle by requesting a quote
     */
    function updateOracle() public {
        if (length() == oracle.size) {
            delete oracle._data[oracle.first++];
        }
        oracle._data[++oracle.last] = Price(
            block.timestamp,
            estimateAmountOut(1 ether, interval));
    }

    /**
     * @dev Updates the size of the array //TODO not functional
     */
    function updateSize(uint256 _size) public {
        require(_size > 0);
        oracle.size = _size;
    }
}
