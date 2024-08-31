import { buildModule } from "@nomicfoundation/hardhat-ignition/modules";

const StakeETHModule = buildModule("StakeETHModule", (m) => {
	const stake = m.contract("StakeETH");

	return { stake };
});

export default StakeETHModule;

// Deployed StakeETH: 0x99c9565F3769D40641429967604144a7Ba48AAA4
