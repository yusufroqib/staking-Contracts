import { buildModule } from "@nomicfoundation/hardhat-ignition/modules";

const tokenAddress = "0xfc04Cb7392147636162c660c144783763538fe69";

const StakeERC20Module = buildModule("StakeERC20Module", (m) => {

    const stake = m.contract("StakeERC20", [tokenAddress]);

    return { stake };
});

export default StakeERC20Module;

// Deployed StakeERC20: 0x99c9565F3769D40641429967604144a7Ba48AAA4
