import { buildModule } from "@nomicfoundation/hardhat-ignition/modules";

const StakeETHModule = buildModule("StakeETHModule", (m) => {
	const stake = m.contract("StakeETH");

	return { stake };
});

export default StakeETHModule;

// Deployed StakeETH: 0x8c5ACDD9D041E9A84900a7C09D264b2a8a3DD8f1
