// SPDX-License-Identifier: MIT
pragma solidity 0.8.29;

// import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {Strings} from "@openzeppelin/contracts/utils/Strings.sol";
import {AggregatorV3Interface} from
    "chainlink-brownie-contracts/contracts/src/v0.8/shared/interfaces/AggregatorV3Interface.sol";
import {TokenMetadata, CollateralTokenConfig} from "src/IEngine.sol";
import {FixedPointString} from "src/FixedPointString.sol";
import {SVGParts} from "src/SVGParts.sol";
import {CodeConstants} from "src/CodeConstants.sol";

contract NFTEngine is CodeConstants {
    // using FixedPointString for int256;

    error NFTEngine__PricefeedPairsHaveDifferentLengths();
    error NFTEngine__UnsupportedPricefeedPair();

    function _get24hRelativePriceChange(address pricefeedAddress, uint256 collateralAmount)
        private
        view
        returns (int256 relativeChange, int256 collateralValueUsd)
    {
        uint8 decimals = AggregatorV3Interface(pricefeedAddress).decimals();
        (uint80 latestRoundId, int256 latestPrice,, uint256 latestTimestamp,) =
            AggregatorV3Interface(pricefeedAddress).latestRoundData();

        // collateralAmount is 1e18. therefore collateralValueUsd is also 1e18.
        collateralValueUsd = (latestPrice * int256(collateralAmount)) / int256(10 ** uint256(decimals));

        // get 1 day old data from latestTimestamp
        uint80 roundId = latestRoundId;
        uint256 targetTimestamp = latestTimestamp - 1 days;
        int256 oldPrice = latestPrice;

        while (true) {
            if (roundId == 0) break;

            roundId -= 1;

            (, int256 price,, uint256 timestamp,) = AggregatorV3Interface(pricefeedAddress).getRoundData(roundId);
            if (timestamp <= targetTimestamp) {
                oldPrice = price;
                break;
            }
        }

        // get the precentage
        int256 diff = latestPrice - oldPrice;
        relativeChange = (diff * int256(PRECISION)) / (oldPrice); // scaled by 1e18

        return (relativeChange, collateralValueUsd);
    }

    function getRingColorFromRelativePrice(int256 relativePriceChange)
        internal
        pure
        returns (string memory startColor, string memory endColor)
    {
        bool isPositive = relativePriceChange >= 0;
        uint256 absRelativePrice = isPositive ? uint256(relativePriceChange) : uint256(-relativePriceChange);

        if (absRelativePrice == 0) {
            return ("rgba(255,255,255,0.4)", "rgba(255,255,255,0.01)");
        }

        // relativePriceChange is the relative price * 1e18
        if (isPositive) {
            startColor = absRelativePrice < 1e15
                ? "rgba(51,195,26,0)" // <0.1%
                : absRelativePrice < 5e15
                    ? "rgba(51,195,26,0.1)" // 0.1-0.5%
                    : absRelativePrice < 1e16
                        ? "rgba(51,195,26,0.2)" // 0.5-1%
                        : absRelativePrice < 3e16
                            ? "rgba(51,195,26,0.3)" // 1% - 3%
                            : absRelativePrice < 5e16
                                ? "rgba(51,195,26,0.5)" // 3% - 5%
                                : absRelativePrice < 8e16
                                    ? "rgba(51,195,26,0.7)" // 5% - 8%
                                    : absRelativePrice < 1e17
                                        ? "rgba(51,195,26,0.9)" // 8-10%
                                        : "rgba(51,195,26,1)"; // >10%
            endColor = "#33c31a";
        } else {
            startColor = "#c31a1a";
            endColor = absRelativePrice < 1e15
                ? "rgba(195,26,26,0)" // <0.1%
                : absRelativePrice < 5e15
                    ? "rgba(195,26,26,0.1)" // 0.1-0.5%
                    : absRelativePrice < 1e16
                        ? "rgba(195,26,26,0.2)" // 0.5-1%
                        : absRelativePrice < 3e16
                            ? "rgba(195,26,26,0.3)" // 1% - 3%
                            : absRelativePrice < 5e16
                                ? "rgba(195,26,26,0.5)" // 3% - 5%
                                : absRelativePrice < 8e16
                                    ? "rgba(195,26,26,0.7)" // 5% - 8%
                                    : absRelativePrice < 1e17
                                        ? "rgba(195,26,26,0.9)" // 8-10%
                                        : "rgba(195,26,26,1)"; // >10%
        }

        return (startColor, endColor);
    }

    function generateWithMeta(
        uint256 tokenId,
        string memory tokenBase,
        string memory collateralPair,
        address pricefeed,
        uint256 collateralAmount
    ) external view returns (string memory) {
        (int256 relativePriceChange, int256 collateralValueUsd) =
            _get24hRelativePriceChange(pricefeed, collateralAmount);
        (string memory startColor, string memory endColor) = getRingColorFromRelativePrice(relativePriceChange);
        uint256 seed = uint256(keccak256(abi.encode(tokenId, tokenBase, block.prevrandao))) % 3;

        return _combineSvgParts(tokenId, collateralPair, collateralValueUsd, tokenBase, startColor, endColor, seed);
    }

    function _combineSvgParts(
        uint256 tokenId,
        string memory pair,
        int256 collateralValueUsd,
        string memory base,
        string memory startColor,
        string memory endColor,
        uint256 seed
    ) private pure returns (string memory) {
        return string(
            abi.encodePacked(
                SVGParts.header(),
                SVGParts.styles(base),
                SVGParts.additionalStyles(startColor, endColor, seed),
                SVGParts.planet(),
                SVGParts.footer(tokenId, pair, FixedPointString.toFixedStringSigned(collateralValueUsd, 18, 2))
            )
        );
    }
}
