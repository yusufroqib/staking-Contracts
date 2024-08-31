import { buildModule } from "@nomicfoundation/hardhat-ignition/modules";

const tokenAddress = "0x93532eB8DA4B43BC9E88b1f11eDbc295607ab693";

const StakeERC20Module = buildModule("StakeERC20Module", (m) => {

    const stake = m.contract("StakeERC20", [tokenAddress]);

    return { stake };
});

export default StakeERC20Module;

// Deployed StakeERC20: 0x184a253699B4D3a26A4EE09608Bc9400F965d2Fb
