const sourceCode = `pragma solidity ^0.8.20;

import "../lib/openzeppelin-contracts/contracts/token/ERC20/ERC20.sol";
import "../lib/openzeppelin-contracts/contracts/token/ERC20/extensions/ERC20Burnable.sol";
import "../lib/openzeppelin-contracts/contracts/access/AccessControl.sol";

contract IDRX is ERC20, ERC20Burnable, AccessControl {
    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");

    constructor(address defaultAdmin, address minter) ERC20("IDRX", "IDRX") {
        _mint(msg.sender, 10000000000000000000000000000 * 10 ** decimals());
        _grantRole(DEFAULT_ADMIN_ROLE, defaultAdmin);
        _grantRole(MINTER_ROLE, minter);
    }

    function mint(address to, uint256 amount) public onlyRole(MINTER_ROLE) {
        _mint(to, amount);
    }

    function decimals() public pure override returns (uint8) {
        return 2;
    }
}
`;

async function verifySourceCode() {
  const url = "https://api.basescan.org/api";

  const params = new URLSearchParams({
    module: "contract",
    action: "verifysourcecode",
    apikey: "N4Q6N1DM1KZWMUBP6B4VS2BPXS4VJH47A5",
  });

  const data = new URLSearchParams({
    chainId: "8453",
    codeformat: "solidity-single-file",
    sourceCode: sourceCode,
    contractaddress: "0xDA76705ADE18F3ecd5cF5E90861dB160F4AE7F34",
    contractname: "IDRX",
    compilerversion: "v0.8.20+commit.418d5f8f",
    optimizationUsed: 0,
    evmversion: "paris",
  });

  try {
    const response = await fetch(url + "?" + params.toString(), {
      method: "POST",
      headers: {
        "Content-Type": "application/x-www-form-urlencoded",
      },
      body: data.toString(),
    });

    if (!response.ok) {
      throw new Error(`HTTP error! status: ${response.status}`);
    }

    const result = await response.json();
    console.log(result);
    return result;
  } catch (error) {
    console.error("Error:", error);
    throw error;
  }
}

verifySourceCode().catch((error) => console.error("Unhandled error:", error));
