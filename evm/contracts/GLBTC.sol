// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./layerzero/token/oft/v2/ProxyOFTV2.sol";

contract GLBTCOFT is ProxyOFTV2 {
    constructor(
        address _token,
        uint8 _sharedDecimals,
        address _lzEndpoint
    ) ProxyOFTV2(_token, _sharedDecimals, _lzEndpoint) {}
}