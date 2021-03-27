pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract TestToken is ERC20 {
    uint256 totalSupply;

    constructor() ERC20("Test", "TST") {
        _mint(10000, "0x57f9A3a483d7D14c755175153b195Aa1e68Fd928");
    }
}
