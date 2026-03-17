// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";

interface IToken is IERC20 {
    function mint(address to, uint256 amount) external;
    function burnFrom(address from, uint256 amount) external;
}

/**
 * @title Treasury
 * @dev Core engine managing the algorithmic peg.
 */
contract Treasury is Ownable, ReentrancyGuard {
    address public stableToken;
    address public bondToken;
    address public shareToken;

    uint256 public constant PERIOD = 8 hours;
    uint256 public startTime;
    uint256 public epoch = 0;

    event TreasuryFunded(uint256 timestamp, uint256 seigniorage);
    event PostExpansion(uint256 epoch, uint256 price);

    constructor(
        address _stable,
        address _bond,
        address _share,
        uint256 _startTime
    ) Ownable(msg.sender) {
        stableToken = _stable;
        bondToken = _bond;
        shareToken = _share;
        startTime = _startTime;
    }

    modifier checkEpoch() {
        require(block.timestamp >= nextEpochPoint(), "Treasury: not allowed yet");
        _;
        epoch++;
    }

    function nextEpochPoint() public view returns (uint256) {
        return startTime + (epoch * PERIOD);
    }

    /**
     * @dev Simple expansion logic: if price > 1, mint to shares.
     * In production, 'price' would come from an Oracle.
     */
    function allocateSeigniorage(uint256 oraclePrice) external onlyOwner checkEpoch nonReentrant {
        if (oraclePrice > 1e18) { // 1e18 = $1.00
            uint256 percentage = oraclePrice - 1e18;
            uint256 supply = IERC20(stableToken).totalSupply();
            uint256 amountToMint = (supply * percentage) / 1e18;
            
            IToken(stableToken).mint(shareToken, amountToMint);
            emit TreasuryFunded(block.timestamp, amountToMint);
        }
        emit PostExpansion(epoch, oraclePrice);
    }

    /**
     * @dev Users burn stable tokens for bonds when price < $1.
     */
    function buyBonds(uint256 amount, uint256 targetPrice) external nonReentrant {
        require(targetPrice < 1e18, "Treasury: not in contraction");
        require(amount > 0, "Treasury: zero amount");

        IToken(stableToken).burnFrom(msg.sender, amount);
        IToken(bondToken).mint(msg.sender, amount);
    }
}
