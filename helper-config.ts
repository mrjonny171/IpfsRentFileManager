import { ethers } from 'hardhat'

export interface networkConfigItem {
    name?: string
    blockConfirmations?: number
    gasLane?: string
    callbackGasLimit?: string
    timeInterval?: string
}

export interface networkConfigInfo {
    [key: string]: networkConfigItem
}

export const networkConfig: networkConfigInfo = {
    5: {
        name: 'goerli',
        blockConfirmations: 6,
        gasLane: '0x79d3d8832d904592c0bf9818b621522c988bb8b0c05cdc3b15aea1b6e8db0c15',
        callbackGasLimit: '500000',
        timeInterval: '30',
    },
    137: {
        name: 'polygon',
        blockConfirmations: 6,
        gasLane: '0x4b09e658ed251bcafeebbc69400383d49f344ace09b9576fe248bb02c003fe9f',
        callbackGasLimit: '500000',
        timeInterval: '30',
    },
    31337: {
        gasLane: '0xd89b2bf150e3b9e13446986e571fb9cab24b13cea0a43ea20a6049a85cc807cc', // 30 gwei
        callbackGasLimit: '500000',
        timeInterval: '30',
    },
}

export const developmentChains = ['hardhat', 'localhost']
