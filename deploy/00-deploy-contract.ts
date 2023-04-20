import { DeployFunction } from 'hardhat-deploy/dist/types'
import { HardhatRuntimeEnvironment } from 'hardhat/types'
import { ethers, network } from 'hardhat'
import { networkConfig } from '../helper-config'
import verify from '../utils/verify'

const deployipfsManager: DeployFunction = async function (hre: HardhatRuntimeEnvironment) {
    const { getNamedAccounts, deployments } = hre

    const { deploy, log } = deployments
    const { deployer } = await getNamedAccounts()

    const chainId = network.config.chainId!

    const ipfsManager = await deploy('IpfsRentFileManager', {
        from: deployer,
        args: [],
        log: true,
        waitConfirmations: networkConfig[chainId].blockConfirmations || 1,
    })

    if (chainId != 31337 && process.env.ETHERSCAN_API_KEY) {
        log('Verifying contract...')
        await verify(ipfsManager.address, [])
    }
}

export default deployipfsManager
deployipfsManager.tags = ['all', 'raffle']
