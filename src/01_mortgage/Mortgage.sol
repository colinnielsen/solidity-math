// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

uint256 constant MONTHS = 30 days;

contract Mortgage {
    uint256 public principal;
    uint256 public rate_BPS;
    uint256 public length;

    constructor(
        uint256 _principal,
        uint256 _rate_BPS,
        uint256 _length
    ) {
        principal = _principal;
        rate_BPS = _rate_BPS;
        length = _length;
    }

    function calculateMonthlyPayments() public view returns (uint256) {}
}
