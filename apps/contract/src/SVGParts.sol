// SPDX-License-Identifier: MIT
pragma solidity 0.8.29;

import {Strings} from "@openzeppelin/contracts/utils/Strings.sol";
import {FixedPointString} from "src/FixedPointString.sol";

library SVGParts {
    function getBackgroundColor(uint256 index) private pure returns (string memory) {
        string[3] memory colors = ["#0e204a", "#043431", "#2e2b03"];
        return colors[index];
    }

    function getAnimatedStars(uint256 index) private pure returns (string memory) {
        string[2] memory animatedStars = [
            '<circle cx="3.12" cy="2.03" r="0.013"><animate attributeName="opacity" values="0.3;0.9;0.3" dur="3.6s" repeatCount="indefinite"/><animate attributeName="cx" values="3.12;3.15;3.12" dur="8s" repeatCount="indefinite"/><animate attributeName="cy" values="2.03;2.00;2.03" dur="7s" repeatCount="indefinite"/></circle><circle cx="5.40" cy="3.30" r="0.020"><animate attributeName="opacity" values="0.3;1;0.3" dur="3.9s" repeatCount="indefinite"/><animate attributeName="cx" values="5.40;5.43;5.40" dur="13s" repeatCount="indefinite"/><animate attributeName="cy" values="3.30;3.35;3.30" dur="15s" repeatCount="indefinite"/></circle><circle cx="1.70" cy="0.95" r="0.018"><animate attributeName="opacity" values="0.4;1;0.4" dur="4.5s" repeatCount="indefinite"/><animate attributeName="cx" values="1.70;1.68;1.70" dur="9s" repeatCount="indefinite"/><animate attributeName="cy" values="0.95;0.92;0.95" dur="8s" repeatCount="indefinite"/></circle><circle cx="1.22" cy="4.32" r="0.008"><animate attributeName="opacity" values="0.4;1;0.4" dur="4.5s" repeatCount="indefinite"/><animate attributeName="cx" values="1.70;1.68;1.70" dur="9s" repeatCount="indefinite"/><animate attributeName="cy" values="0.95;0.92;0.95" dur="8s" repeatCount="indefinite"/></circle><circle cx="3" cy="6" r="0.03" fill="#dcdcdc"><animate attributeName="opacity" values="0.4;1;0.4" dur="4.5s" repeatCount="indefinite"/><animate attributeName="cx" values="4.5;3.4;2.5;3;" dur="100s" repeatCount="indefinite"/><animate attributeName="cy" values="6;5.5;4.0;6.3;6" dur="100s" repeatCount="indefinite"/></circle>',
            '<circle cx="5.8" cy="4.1" r="0.020"><animate attributeName="opacity" values="0.3;1;0.3" dur="4.1s" repeatCount="indefinite" /><animate attributeName="cx" values="5.8;5.77;5.82;5.85;5.8" dur="14s" repeatCount="indefinite" /><animate attributeName="cy" values="4.1;4.12;4.05;4.08;4.1" dur="16s" repeatCount="indefinite" /></circle><circle cx="2.1" cy="0.7" r="0.018"><animate attributeName="opacity" values="0.4;1;0.4" dur="5.1s" repeatCount="indefinite" /><animate attributeName="cx" values="2.1;2.15;2.08;2.13;2.1" dur="10s" repeatCount="indefinite" /><animate attributeName="cy" values="0.7;0.68;0.72;0.69;0.7" dur="9s" repeatCount="indefinite" /></circle><circle cx="1.5" cy="3.9" r="0.008"><animate attributeName="opacity" values="0.4;1;0.4" dur="4.8s" repeatCount="indefinite" /><animate attributeName="cx" values="1.5;1.52;1.47;1.54;1.5" dur="13s" repeatCount="indefinite" /><animate attributeName="cy" values="3.9;3.88;3.94;3.92;3.9" dur="15s" repeatCount="indefinite" /></circle><circle cx="3.8" cy="6.2" r="0.02"><animate attributeName="opacity" values="0.4;1;0.4" dur="5.2s" repeatCount="indefinite" /><animate attributeName="cx" values="3.8;3.05;2.80;3.05;3.8" dur="85s" repeatCount="indefinite" /><animate attributeName="cy" values="6.2;6.15;5.25;6.18;6.2" dur="90s" repeatCount="indefinite" /></circle>'
        ];

        return index == 2 ? animatedStars[1] : animatedStars[index];
    }

    function getStaticStars(uint256 index) private pure returns (string memory) {
        string[2] memory staticStars = [
            '<circle cx="1.04" cy="1.78" r="0.016"><animate attributeName="opacity" values="0.3;1;0.3" dur="3.1s" repeatCount="indefinite"/></circle><circle cx="4.82" cy="5.10" r="0.009"><animate attributeName="opacity" values="0.2;0.8;0.2" dur="2.5s" repeatCount="indefinite"/></circle><circle cx="5.95" cy="0.56" r="0.007"><animate attributeName="opacity" values="0.1;0.7;0.1" dur="1.9s" repeatCount="indefinite"/></circle><circle cx="0.40" cy="6.40" r="0.011"><animate attributeName="opacity" values="0.2;0.7;0.2" dur="2.8s" repeatCount="indefinite"/></circle><circle cx="1.70" cy="0.95" r="0.018"><animate attributeName="opacity" values="0.4;1;0.4" dur="4.5s" repeatCount="indefinite"/></circle><circle cx="0.90" cy="2.10" r="0.012"><animate attributeName="opacity" values="0.2;0.9;0.2" dur="3.7s" repeatCount="indefinite"/></circle><circle cx="2.60" cy="1.30" r="0.008"><animate attributeName="opacity" values="0.1;0.7;0.1" dur="2.1s" repeatCount="indefinite"/></circle><circle cx="6.10" cy="4.90" r="0.017"><animate attributeName="opacity" values="0.3;1;0.3" dur="4.1s" repeatCount="indefinite"/></circle><circle cx="3.40" cy="0.60" r="0.010"><animate attributeName="opacity" values="0.1;0.7;0.1" dur="2.9s" repeatCount="indefinite"/></circle><circle cx="5.80" cy="1.20" r="0.022"><animate attributeName="opacity" values="0.4;1;0.4" dur="4.8s" repeatCount="indefinite"/></circle><circle cx="0.60" cy="0.90" r="0.013"><animate attributeName="opacity" values="0.3;0.9;0.3" dur="3.8s" repeatCount="indefinite"/></circle><circle cx="4.30" cy="3.10" r="0.009"><animate attributeName="opacity" values="0.2;0.7;0.2" dur="2.0s" repeatCount="indefinite"/></circle><circle cx="3.00" cy="5.30" r="0.016"></circle><circle cx="6.50" cy="2.00" r="0.011"><animate attributeName="opacity" values="0.3;0.8;0.3" dur="3.2s" repeatCount="indefinite"/></circle>',
            '<circle cx="1.02" cy="0.78" r="0.016"><animate attributeName="opacity" values="0.3;1;0.3" dur="3.1s" repeatCount="indefinite"/></circle><circle cx="6.11" cy="6.22" r="0.009"><animate attributeName="opacity" values="0.2;0.8;0.2" dur="2.5s" repeatCount="indefinite"/></circle><circle cx="6.41" cy="0.33" r="0.007"><animate attributeName="opacity" values="0.1;0.7;0.1" dur="1.9s" repeatCount="indefinite"/></circle><circle cx="0.22" cy="6.42" r="0.011"><animate attributeName="opacity" values="0.2;0.7;0.2" dur="2.8s" repeatCount="indefinite"/></circle><circle cx="1.11" cy="2.19" r="0.012"><animate attributeName="opacity" values="0.2;0.9;0.2" dur="3.7s" repeatCount="indefinite"/></circle><circle cx="2.55" cy="0.75" r="0.008"><animate attributeName="opacity" values="0.1;0.7;0.1" dur="2.1s" repeatCount="indefinite"/></circle><circle cx="6.52" cy="5.91" r="0.017"><animate attributeName="opacity" values="0.3;1;0.3" dur="4.1s" repeatCount="indefinite"/></circle><circle cx="5.72" cy="0.48" r="0.010"><animate attributeName="opacity" values="0.1;0.7;0.1" dur="2.9s" repeatCount="indefinite"/></circle><circle cx="5.62" cy="1.01" r="0.022"><animate attributeName="opacity" values="0.4;1;0.4" dur="4.8s" repeatCount="indefinite"/></circle><circle cx="0.12" cy="1.28" r="0.013"><animate attributeName="opacity" values="0.3;0.9;0.3" dur="3.8s" repeatCount="indefinite"/></circle><circle cx="4.98" cy="2.40" r="0.009"><animate attributeName="opacity" values="0.2;0.7;0.2" dur="2.0s" repeatCount="indefinite"/></circle><circle cx="2.42" cy="6.03" r="0.016"><animate attributeName="opacity" values="0.3;1;0.3" dur="3.5s" repeatCount="indefinite"/></circle><circle cx="6.63" cy="1.93" r="0.011"><animate attributeName="opacity" values="0.3;0.8;0.3" dur="3.2s" repeatCount="indefinite"/></circle>'
        ];

        return index == 2 ? staticStars[1] : staticStars[index];
    }

    function header() external pure returns (string memory) {
        return
        '<svg xmlns="http://www.w3.org/2000/svg" width="6.82666in" height="6.82666in" viewBox="0 0 6.82666 6.82666" xml:space="preserve" style="shape-rendering:geometricPrecision;text-rendering:geometricPrecision;image-rendering:optimizeQuality;fill-rule:evenodd;clip-rule:evenodd" xmlns:xlink="http://www.w3.org/1999/xlink"><defs>';
    }

    function styles(string memory baseColor) external pure returns (string memory) {
        return string.concat(
            '<style type="text/css"><![CDATA[',
            ".fil0{fill:hsl(",
            baseColor,
            ",80%,50%)}",
            ".fil1{fill:hsl(",
            baseColor,
            ",80%,30%)}",
            ".fil2{fill:hsl(",
            baseColor,
            ",80%,20%)}",
            ".fil3{fill:hsl(",
            baseColor,
            ",80%,60%)}",
            ".fil4{fill:hsl(",
            baseColor,
            ",80%,70%)}",
            ".fil5{fill:hsl(",
            baseColor,
            ",80%,80%)}",
            ".fil7{fill:none}]]></style>"
        );
    }

    function additionalStyles(string memory startColor, string memory endColor, uint256 seed)
        external
        pure
        returns (string memory)
    {
        return string.concat(
            '<linearGradient id="ringGradient" x1="0%" y1="0%" x2="100%" y2="0%"><stop offset="0%" stop-color="',
            startColor,
            '" /><stop offset="100%" stop-color="',
            endColor,
            '" /></linearGradient>',
            '<radialGradient id="bgGradient" cx="50%" cy="50%" r="70%"><stop offset="0%" stop-color="',
            getBackgroundColor(seed),
            '" /><stop offset="100%" stop-color="#000010" /></radialGradient>',
            '<filter id="glow" x="-50%" y="-50%" width="200%" height="200%"><feDropShadow dx="0" dy="0" stdDeviation="0.02" flood-color="white" flood-opacity="0.8" /><feDropShadow dx="0" dy="0" stdDeviation="0.1" flood-color="white" flood-opacity="0.4" /></filter>',
            '<filter id="glow-planet" x="-10%" y="-10%" width="200%" height="200%"><feDropShadow dx="0" dy="0" stdDeviation="0.1" flood-color="#ffffff" flood-opacity="0.3" /></filter>',
            "</defs>",
            '<rect width="6.82666" height="6.82666" fill="url(#bgGradient)" />',
            '<g fill="white" filter="url(#glow)">',
            getAnimatedStars(seed),
            getStaticStars(seed),
            "</g>"
        );
    }

    function planet() external pure returns (string memory) {
        return string.concat(
            '<g filter="url(#glow-planet)">',
            '<animateTransform attributeName="transform" type="translate" values="0 0; 0.01 -0.01; -0.01 0.01; 0.01 0.01; -0.01 -0.01; 0 0" dur="6s" repeatCount="indefinite"/><animateTransform attributeName="transform" additive="sum" type="rotate" values="17 3.41333 3.41333; 18 3.41333 3.41333; 17 3.41333 3.41333; 16 3.41333 3.41333; 17 3.41333 3.41333" dur="8s" repeatCount="indefinite"/>',
            '<metadata filter="url(#glow-planet)"/>',
            '<circle class="fil0" cx="3.31372" cy="3.41333" r="1.68496"/>',
            '<path class="fil1" d="M2.16044 2.1806c0.542063,-0.111701 1.04973,-0.254992 1.53093,-0.414004 -0.122126,-0.0281378 -0.249343,-0.0430197 -0.380071,-0.0430197 -0.468594,0 -0.86237,0.179024 -1.15085,0.457024z"/>',
            '<path class="fil2" d="M1.94365 2.4355c0.744469,-0.139732 1.42429,-0.340819 2.05902,-0.564134 -0.0990512,-0.044563 -0.203181,-0.0798661 -0.311299,-0.104776 -0.481197,0.159012 -0.988862,0.302303 -1.53093,0.414004 -0.0807362,0.0778031 -0.15322,0.163354 -0.216795,0.254906z"/>',
            '<path class="fil3" d="M1.78356 2.71918c0.917335,-0.159059 1.73686,-0.413134 2.49383,-0.691717 -0.0860472,-0.0601693 -0.177957,-0.112551 -0.274717,-0.156091 -0.634732,0.223315 -1.31455,0.424402 -2.05902,0.564134 -0.0620709,0.0893858 -0.115638,0.184484 -0.160091,0.283673z"/>',
            '<path class="fil0" d="M4.65807 2.39375c-0.106909,-0.140941 -0.235437,-0.26472 -0.380681,-0.366291 -0.756969,0.278583 -1.57649,0.532657 -2.49383,0.691717 -0.0756181,0.168732 -0.124846,0.349287 -0.144622,0.533626 1.13379,-0.181756 2.11872,-0.510988 3.01913,-0.859051z"/>',
            '<path class="fil4" d="M4.83385 2.68072c-0.0286772,-0.059378 -0.0607323,-0.11685 -0.0959173,-0.172157 -0.0250669,-0.0394016 -0.0517126,-0.0776969 -0.0798661,-0.114807 -0.900409,0.348063 -1.88534,0.677295 -3.01913,0.859051 -0.00532283,0.0496339 -0.00851575,0.0995433 -0.00950394,0.149567 -0.0013622,0.068311 0.00137402,0.136846 0.00835827,0.205197 0.0206417,-0.00329921 0.0412283,-0.00664567 0.0617717,-0.0100433 1.14809,-0.189815 2.14331,-0.529957 3.05335,-0.885098 0.0270512,-0.0105591 0.0540276,-0.021126 0.0809331,-0.0317087z"/>',
            '<path class="fil5" d="M4.95961 3.04063c-0.026185,-0.115933 -0.0643465,-0.227445 -0.113122,-0.333142 -0.00414173,-0.00896457 -0.00835039,-0.0178898 -0.0126417,-0.0267717 -0.0269055,0.0105827 -0.0538819,0.0211496 -0.0809331,0.0317087 -0.910039,0.355142 -1.90527,0.695283 -3.05335,0.885098 -0.0205433,0.00339764 -0.0411299,0.00674409 -0.0617717,0.0100433 0.00080315,0.00788189 0.00166535,0.0157598 0.00258268,0.0236339 0.0146102,0.125315 0.0435669,0.24987 0.0878189,0.371193 1.22336,-0.205366 2.27303,-0.580898 3.23142,-0.961764z"/>',
            '<path class="fil4" d="M4.99836 3.31848c-0.00525197,-0.0948504 -0.018374,-0.187685 -0.0387441,-0.277846 -0.958394,0.380866 -2.00806,0.756398 -3.23142,0.961764 0.032752,0.089811 0.0738858,0.177846 0.12378,0.26311 0.202783,-0.00940551 0.407063,-0.0348819 0.606193,-0.0678425 0.292067,-0.0483386 0.582173,-0.115343 0.867134,-0.19535 0.0355315,-0.00998031 0.0710236,-0.020122 0.106433,-0.0305276 0.297488,-0.0874173 0.592122,-0.189752 0.878091,-0.309732 0.233669,-0.0980394 0.467583,-0.209642 0.684449,-0.341098l0.00408661 -0.00247638z"/>',
            '<path class="fil3" d="M4.46624 4.0259c-0.300508,0.126374 -0.610055,0.234232 -0.922768,0.32613 -0.0369646,0.0108622 -0.0739724,0.0215551 -0.111063,0.0319685 -0.300189,0.0842756 -0.605803,0.154496 -0.913516,0.205126 -0.122106,0.0200906 -0.245839,0.0374449 -0.370039,0.0505197 0.0650315,0.0616732 0.134965,0.118228 0.209154,0.169024 0.929969,-0.193079 1.75867,-0.478866 2.5263,-0.776953 0.0299213,-0.0760472 0.0544882,-0.154791 0.0732323,-0.235764 -0.160287,0.0842638 -0.325677,0.160295 -0.491299,0.229949z"/>',
            '<path class="fil2" d="M4.64363 4.45276c0.099248,-0.127039 0.18072,-0.268634 0.240685,-0.421047 -0.767634,0.298087 -1.59633,0.583874 -2.5263,0.776953 0.141217,0.0966732 0.297858,0.172469 0.465472,0.222933 0.651409,-0.16152 1.25298,-0.364744 1.82014,-0.578839z"/><path id="_311090624" class="fil1" d="M3.3113 5.10309c0.541256,0 1.02307,-0.254484 1.33233,-0.650323 -0.567157,0.214094 -1.16873,0.417319 -1.82014,0.578839 0.154449,0.0464961 0.318213,0.0714843 0.487815,0.0714843z"/>',
            '<path fill="url(#ringGradient)" d="M0.872035 4.36719l-0.000866142 -0.00172835 -0.00716535 -0.0249961 0 -0.00175591c-0.0489646,-0.204122 0.078689,-0.393646 0.217756,-0.531315 0.143193,-0.141752 0.324909,-0.262933 0.498358,-0.364248l0.0491181 -0.028689c-0.000826772,0.0643071 0.00198425,0.128787 0.00855512,0.193106 0.00080315,0.00788189 0.00166535,0.0157598 0.00258268,0.0236339 0.00891732,0.0764724 0.0231772,0.152661 0.0429882,0.228004 -0.109496,0.0688386 -0.222579,0.148563 -0.313496,0.238563 -0.0234016,0.0231654 -0.103744,0.108776 -0.107307,0.146244 0.016063,0.0271378 0.116606,0.0541378 0.141972,0.0597677 0.136323,0.0302598 0.295311,0.0337717 0.434512,0.031689 0.239831,-0.00359055 0.483563,-0.0321693 0.720012,-0.0713071 0.291835,-0.0483031 0.581713,-0.115256 0.866445,-0.195201 0.0355118,-0.0099685 0.0709724,-0.0201024 0.106358,-0.0305039 0.29726,-0.0873504 0.591669,-0.189606 0.877421,-0.309496 0.233378,-0.0979173 0.467016,-0.209374 0.68361,-0.340669 0.128445,-0.0778583 0.272724,-0.172756 0.379665,-0.278898 0.0190866,-0.0189449 0.0984055,-0.10502 0.092752,-0.136189 -0.00481102,-0.00941339 -0.0305394,-0.023563 -0.0390866,-0.0277362 -0.0437598,-0.0213701 -0.0986457,-0.0340394 -0.146311,-0.0427047 -0.137469,-0.0249882 -0.288878,-0.0257756 -0.428114,-0.0201102 -0.0118583,0.000480315 -0.0237126,0.00102756 -0.035563,0.00162598 -0.0199843,-0.0604882 -0.0433031,-0.119496 -0.0697402,-0.176791 -0.00414173,-0.00896457 -0.00835039,-0.0178898 -0.0126417,-0.0267717 -0.0286772,-0.059378 -0.0607323,-0.11685 -0.0959173,-0.172157 -0.00455906,-0.00716535 -0.00917323,-0.0143031 -0.0138386,-0.0213976l0.052063 -0.00397244c0.0179173,-0.00136614 0.0358425,-0.0026378 0.0537717,-0.00379921 0.202358,-0.0131024 0.422504,-0.0153346 0.622618,0.0210433 0.213063,0.0387283 0.442807,0.134283 0.506724,0.361953 0.103724,0.369445 -0.391764,0.71615 -0.654602,0.875476 -0.23287,0.141161 -0.483173,0.261264 -0.734016,0.366752 -0.300724,0.126461 -0.6105,0.234402 -0.923441,0.32637 -0.0369882,0.0108661 -0.0740236,0.0215669 -0.111138,0.0319882 -0.300417,0.0843346 -0.60626,0.15461 -0.914205,0.205276 -0.255547,0.0420433 -0.518217,0.0721614 -0.777362,0.0760394 -0.298319,0.00446063 -0.859984,-0.0272953 -0.972472,-0.377094z"/>',
            '<animate attributeName="cx" values="1.04;2.10;3.04" dur="10s" repeatCount="indefinite"/>',
            "</g>"
        );
    }

    function footer(uint256 tokenId, string calldata pair, string calldata collateralValueUsd)
        external
        pure
        returns (string memory)
    {
        return string.concat(
            '<text x="50%" y="6.6" text-anchor="middle" font-size="0.1" fill="rgba(255,255,255,0.299)" font-family="sans-serif">Planet NFT #',
            Strings.toString(tokenId),
            " is synced to ",
            pair,
            " pair and the collateral is valued ",
            collateralValueUsd,
            ' USD</text><rect class="fil7" width="6.82666" height="6.82666"/></svg>'
        );
    }
}
