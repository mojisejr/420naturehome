pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract MyToken is ERC20 {
    constructor(address _w1, address _w2, address _w3) ERC20("MyToken", "MTK") {
        _mint(msg.sender, 10000 * 10 ** decimals());
        _mint(_w1, 10000 * 10 ** decimals());
        _mint(_w2, 10000 * 10 ** decimals());
        _mint(_w3, 10000 * 10 ** decimals());
    }
}