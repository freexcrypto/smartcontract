// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import "../lib/openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";

contract Transfer {
    address public immutable IDRX_TOKEN;
    uint8 public constant DECIMALS = 2;

    constructor(address token) {
        IDRX_TOKEN = token;
    }

    /// @notice Transfers tokens from sender to receiver and dev address according to the split
    /// @param from The address sending the tokens (must have approved this contract)
    /// @param to The receiver address
    /// @param totalAmount The total amount to split (in smallest unit, e.g., 1010 for 10.10 IDRX)
    function splitTransfer(
        address from,
        address to,
        uint256 totalAmount
    ) external {
        require(totalAmount > 0, "Amount must be greater than 0");
        require(to != address(0), "Invalid receiver address");
        require(from != address(0), "Invalid sender address");

        uint256 devAmount = (totalAmount * 1) / 1000; // 10 in your example (last 2 digits)
        uint256 receiverAmount = totalAmount - devAmount; // 1000 in your example
        address dev = 0x91472E17C35e0674236E369f13f161990C656686;

        require(receiverAmount > 0, "Receiver amount must be greater than 0");
        require(devAmount > 0, "Dev amount must be greater than 0");

        IERC20 token = IERC20(IDRX_TOKEN);
        // Transfer to receiver
        require(
            token.transferFrom(from, to, receiverAmount),
            "Transfer to receiver failed"
        );
        // Transfer to dev
        require(
            token.transferFrom(from, dev, devAmount),
            "Transfer to dev failed"
        );
    }
}
