// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol"; // For price oracles
import "@uniswap/v2-periphery/contracts/interfaces/IUniswapV2Router02.sol"; // For Uniswap interaction
import "@openzeppelin/contracts/access/Ownable.sol"; // To manage ownership (set price)

contract PriceBasedTrading is Ownable {

    // Oracle Variables
    AggregatorV3Interface internal priceFeed; // Chronicle or Chainlink Oracle
    uint256 public userDefinedPrice; // Price set by the user

    // Uniswap Variables
    IUniswapV2Router02 public uniswapRouter;
    address public USDC;
    address public WETH;

    // Events
    event PriceUpdated(uint256 newPrice);
    event SwapExecuted(uint256 usdcAmount, uint256 ethReceived);

    constructor(address _priceFeed, address _uniswapRouter, address _usdc, address _weth) {
        priceFeed = AggregatorV3Interface(_priceFeed);
        uniswapRouter = IUniswapV2Router02(_uniswapRouter);
        USDC = _usdc;
        WETH = _weth;
    }

    // Allow the user to set the desired price
    function setUserDefinedPrice(uint256 _price) external onlyOwner {
        userDefinedPrice = _price;
        emit PriceUpdated(_price);
    }

    // Function to fetch the current price from Oracle
    function getLatestPrice() public view returns (uint256) {
        (
            , 
            int256 price,
            ,
            ,
            
        ) = priceFeed.latestRoundData();
        return uint256(price);
    }

    // Main function to check the price and swap if conditions met
    function checkPriceAndSwap(uint256 usdcAmount) external onlyOwner {
        uint256 latestPrice = getLatestPrice();

        // If oracle price is below the user-defined price, perform the swap
        if (latestPrice < userDefinedPrice) {
            swapUSDCForETH(usdcAmount);
        }
    }

    // Swap USDC for ETH using Uniswap
    function swapUSDCForETH(uint256 usdcAmount) internal {
        require(usdcAmount > 0, "Insufficient USDC amount");

        // Approve the Uniswap Router to spend USDC
        IERC20(USDC).approve(address(uniswapRouter), usdcAmount);

        address;
        path[0] = USDC; // Token to swap from (USDC)
        path[1] = WETH; // Token to swap to (WETH)

        // Execute the swap
        uniswapRouter.swapExactTokensForETH(
            usdcAmount,
            0, // Accept any amount of ETH
            path,
            msg.sender,
            block.timestamp
        );

        emit SwapExecuted(usdcAmount, address(this).balance);
    }

    // Optional function to withdraw ETH balance
    function withdraw() external onlyOwner {
        payable(msg.sender).transfer(address(this).balance);
    }

    // Receive ETH fallback function
    receive() external payable {}

}