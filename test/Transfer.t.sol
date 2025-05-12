// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import {Test, console} from "forge-std/Test.sol";
import {Transfer} from "../src/Transfer.sol";
import {ERC20Mock} from "../lib/openzeppelin-contracts/contracts/mocks/token/ERC20Mock.sol";

contract TransferTest is Test {
    Transfer public transfer;
    ERC20Mock public token;
    address public user = address(0x1);
    address public receiver = address(0x2);
    address public dev = address(0x3);

    function setUp() public {
        token = new ERC20Mock();
        transfer = new Transfer(address(token));
        // Mint tokens to user
        token.mint(user, 2000);
        // Approve Transfer contract to spend user's tokens
        vm.prank(user);
        token.approve(address(transfer), 2000);
    }

    function testSplitTransfer() public {
        uint256 totalAmount = 1010; // 10.10 tokens
        uint256 devAmount = (totalAmount * 1) / 100;
        uint256 receiverAmount = totalAmount - devAmount;
        console.log("Before transfer:");
        console.log("User balance: %s", token.balanceOf(user));
        console.log("Receiver balance: %s", token.balanceOf(receiver));
        console.log("Dev balance: %s", token.balanceOf(dev));
        console.log("totalAmount: %s", totalAmount);
        console.log("devAmount: %s", devAmount);
        console.log("receiverAmount: %s", receiverAmount);
        vm.prank(user);
        transfer.splitTransfer(user, receiver, dev, totalAmount);
        console.log("After transfer:");
        console.log("User balance: %s", token.balanceOf(user));
        console.log("Receiver balance: %s", token.balanceOf(receiver));
        console.log("Dev balance: %s", token.balanceOf(dev));
        // 1% to dev = 10, 1000 to receiver
        assertEq(token.balanceOf(receiver), 1000);
        assertEq(token.balanceOf(dev), 10);
        assertEq(token.balanceOf(user), 990);
    }

    function testSplitTransfer_RevertOnZeroAmount() public {
        vm.prank(user);
        vm.expectRevert("Amount must be greater than 0");
        transfer.splitTransfer(user, receiver, dev, 0);
    }

    function testSplitTransfer_RevertOnZeroReceiver() public {
        vm.prank(user);
        vm.expectRevert("Invalid receiver address");
        transfer.splitTransfer(user, address(0), dev, 1000);
    }

    function testSplitTransfer_RevertOnZeroDev() public {
        vm.prank(user);
        vm.expectRevert("Invalid dev address");
        transfer.splitTransfer(user, receiver, address(0), 1000);
    }

    function testSplitTransfer_RevertOnZeroSender() public {
        vm.expectRevert("Invalid sender address");
        transfer.splitTransfer(address(0), receiver, dev, 1000);
    }
}
