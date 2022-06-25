import { ethers } from "hardhat";

export const gasEstimate = (t3:any) => { 
    const gasUsed = t3.gasUsed;
    const gasPrice = t3.effectiveGasPrice;
    const gasCost = gasUsed.mul(gasPrice);
    const gasCostEth = Number.parseFloat(ethers.utils.formatEther(gasCost));
    const ETHUSD = 1000; // assume eth is $1000 usd
    const gasCostUsd = gasCostEth * ETHUSD;
    return { ETH: gasCostEth, USD: gasCostUsd };
};