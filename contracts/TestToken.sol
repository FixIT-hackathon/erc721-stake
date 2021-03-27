pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract TestToken is ERC20 {
    constructor(address[] memory receivers, uint256[] memory amounts) ERC20("Test", "TST") {
        for (uint i = 0; i < receivers.length; i++) {
            _mint(receivers[i], amounts[i]);
        }
    }
}
