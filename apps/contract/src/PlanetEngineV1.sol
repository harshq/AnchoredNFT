// SPDX-License-Identifier: MIT
pragma solidity 0.8.29;

import {IEngine} from "src/IEngine.sol";
import {Strings} from "@openzeppelin/contracts/utils/Strings.sol";
import {FixedPointString} from "src/FixedPointString.sol";
import {SVGParts} from "src/SVGParts.sol";
import {Constants} from "src/Constants.sol";
import {UniswapCalculations} from "src/UniswapCalculations.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

contract PlanetEngineV1 is IEngine, Ownable {
    error PlanetEngineV1__PricefeedPairsHaveDifferentLengths();
    error PlanetEngineV1__UnsupportedPricefeedPair();

    constructor() Ownable(msg.sender) {}

    function getRingColorFromRelativePrice(int256 relativePriceChange)
        internal
        view
        onlyOwner
        returns (string memory startColor, string memory endColor)
    {
        bool isPositive = relativePriceChange >= 0;
        uint256 absRelativePrice = isPositive ? uint256(relativePriceChange) : uint256(-relativePriceChange);

        if (absRelativePrice == 0) {
            return ("rgba(255,255,255,0.4)", "rgba(255,255,255,0.01)");
        }

        // relativePriceChange is the relative price scaled to 1e18
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
        address collateralBase,
        address collateralToken,
        address collateralPool,
        uint256 collateralAmount
    ) external view onlyOwner returns (string memory) {
        (int256 relativePriceChange, int256 collateralValueUsd) = UniswapCalculations.getRelativePriceChange(
            collateralBase, collateralToken, collateralPool, collateralAmount
        );

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
    ) private view onlyOwner returns (string memory) {
        return string(
            abi.encodePacked(
                SVGParts.header(),
                SVGParts.styles(base),
                SVGParts.additionalStyles(startColor, endColor, seed),
                SVGParts.planet(),
                SVGParts.footer(
                    tokenId,
                    pair,
                    FixedPointString.toFixedStringSigned(
                        collateralValueUsd, Constants.DECIMALS, Constants.AMOUNT_PRECISION_SVG
                    )
                )
            )
        );
    }

    function name() external pure returns (string memory) {
        return "PlanetEngineV1";
    }

    function description() external pure returns (string memory) {
        return "A procedurally generated planet that changes color with each glance.";
    }
}
