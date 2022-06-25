import { BigNumber } from "ethers";
import { ethers } from "hardhat";

export const gasEstimate = (t3:any) => { 
    const gasUsed = t3.gasUsed;
    const gasPrice = BigNumber.from(50 * 1.0E9); // 50gwei
    const gasCost = gasUsed.mul(gasPrice);
    const gasCostEth = Math.round(Number.parseFloat(ethers.utils.formatEther(gasCost)) * 100000)/100000;
    const ETHUSD = 1000; // assume eth is $1000 usd
    const gasCostUsd = Math.round(gasCostEth * ETHUSD * 100) / 100;
    return { Unit: gasUsed.toNumber(), ETH: gasCostEth, USD: gasCostUsd };
};