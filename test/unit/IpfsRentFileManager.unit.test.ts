import { SignerWithAddress } from '@nomiclabs/hardhat-ethers/signers'
import { assert, expect } from 'chai'
import { deployments, ethers, network } from 'hardhat'
import { developmentChains, networkConfig } from '../../helper-config'
import { IpfsRentFileManager } from '../../typechain-types'
import { BigNumber } from 'ethers'
import { PromiseOrValue } from '../../typechain-types/common'

!developmentChains.includes(network.name)
    ? describe.skip
    : describe('IpfsManager Unit Tests', async () => {
          let ipfsManager: IpfsRentFileManager
          let deployer: SignerWithAddress
          let account2: SignerWithAddress
          let hashFile: PromiseOrValue<string>
          let defaultSize: BigNumber
          let defaultCategory: BigNumber

          beforeEach(async () => {
              const accounts = await ethers.getSigners()
              deployer = accounts[0]
              account2 = accounts[1]
              hashFile = '123'

              defaultSize = BigNumber.from(10)

              defaultCategory = BigNumber.from(2)

              await deployments.fixture(['all'])

              ipfsManager = await ethers.getContract('IpfsRentFileManager', deployer)
          })

          describe('Upload File', () => {
              it('Sets the file information correctly', async () => {
                  const transactionReceipt = await ipfsManager.uploadFile(
                      hashFile,
                      defaultSize,
                      defaultCategory
                  )

                  await transactionReceipt.wait()

                  const fileOwner = await ipfsManager.callStatic.getFileOwner(hashFile)
                  const fileCategory = await ipfsManager.callStatic.getFileCategory(hashFile)
                  const fileSize = await ipfsManager.callStatic.getFileSize(hashFile)
                  const fileNumberOfAccesses = await ipfsManager.callStatic.getFileNumberAccesses(
                      hashFile
                  )

                  assert.equal(fileOwner.toString(), deployer.address.toString())
                  assert.equal(fileCategory.toString(), defaultCategory.toString())
                  assert.equal(fileSize.toString(), defaultSize.toString())
                  assert.equal(fileNumberOfAccesses.toString(), '1')
              })

              it('File already exists', async () => {
                  const transactionReceipt = await ipfsManager.uploadFile(
                      hashFile,
                      defaultSize,
                      defaultCategory
                  )

                  await transactionReceipt.wait()

                  await expect(
                      ipfsManager.uploadFile(hashFile, defaultSize, defaultCategory)
                  ).to.be.revertedWithCustomError(ipfsManager, 'FileAlreadyExists')
              })
          })
          describe('Delete File', () => {
              it('Deletes the file', async () => {
                  const transactionUploadReceipt = await ipfsManager.uploadFile(
                      hashFile,
                      defaultSize,
                      defaultCategory
                  )

                  await transactionUploadReceipt.wait()

                  const transactionDeleteReceipt = await ipfsManager.deleteFile(hashFile)

                  await transactionDeleteReceipt.wait()

                  await expect(ipfsManager.getFileOwner(hashFile)).to.be.revertedWithCustomError(
                      ipfsManager,
                      'FileDoesNotExist'
                  )
              })

              it('File does not exist', async () => {
                  await expect(ipfsManager.deleteFile(hashFile)).to.be.revertedWithCustomError(
                      ipfsManager,
                      'FileDoesNotExist'
                  )
              })

              it('File exists but stranger tries to delete it', async () => {
                  const stranger = await ipfsManager.connect(account2)

                  const transactionReceipt = await ipfsManager.uploadFile(
                      hashFile,
                      defaultSize,
                      defaultCategory
                  )

                  await transactionReceipt.wait()

                  await expect(stranger.deleteFile(hashFile)).to.be.revertedWithCustomError(
                      ipfsManager,
                      'NotOwner'
                  )
              })
          })
      })
