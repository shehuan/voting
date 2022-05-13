import { BigNumber, ethers } from 'ethers'
import Web3Modal from 'web3modal'
import WalletConnectProvider from '@walletconnect/web3-provider'
const providerOptions = {
  walletconnect: {
    package: WalletConnectProvider, // required
    options: {
      infuraId: process.env.chain.infuraid, // required
      qrcodeModalOptions: {
        mobileLinks: [
          'rainbow',
          'metamask',
          'argent',
          'trust',
          'imtoken',
          'pillar'
        ]
      }
    }
  }
}
const web3Modal = new Web3Modal({
  // disableInjectedProvider:true,
  cacheProvider: true, // optional
  providerOptions
})
async function metamaskBlockChain (provider) {
  if (!process.env.chain.id || !provider.isMetaMask || provider.networkVersion === process.env.chain.id) {
    return
  }
  const ethereum = window.ethereum
  const chainId = BigNumber.from(process.env.chain.id).toHexString().replace(/^0x0+/, '0x')
  try {
    await ethereum.request({
      method: 'wallet_switchEthereumChain',
      params: [{ chainId }]
    })
  } catch (err) {
    if (err.code === 4902) {
      await ethereum.request({
        method: 'wallet_addEthereumChain',
        params: [
          {
            chainId,
            chainName: process.env.chain.name,
            rpcUrls: [process.env.chain.rpc]
          }
        ]
      })
    }
    throw err
  }
}

const ModalWallet = {
  async connect () {
    if (process.env.chain.id) {
      const rpc = {}
      rpc[process.env.chain.id] = process.env.chain.rpc
      providerOptions.walletconnect.options.rpc = rpc
    }

    return new Promise((resolve, reject) => {
      web3Modal.connect().then(async provider => {
        this.provider = new ethers.providers.Web3Provider(provider)
        provider.on('accountsChanged', (accounts) => {
          if (!accounts || accounts.length < 1) {
            web3Modal.clearCachedProvider()
          }
          location.reload()
        })

        provider.on('chainChanged', (chainId) => {
          console.log(chainId)
          location.reload()
        })

        provider.on('connect', (info) => {
          console.log(info)
        })
        provider.on('disconnect', (error) => {
          console.log(error)
          web3Modal.clearCachedProvider()
          location.reload()
        })
        try {
          await metamaskBlockChain(provider)
          resolve(provider.isMetaMask ? provider.selectedAddress : provider.accounts[0])
        } catch (error) {
          reject(error)
        }
      }).catch(error => reject(error))
    })
  },
  sign (message) {
    return this.provider.getSigner().signMessage(message)
  },
  getAccounts () {
    return this.provider.send('eth_accounts')
  },
  connected () {
    return web3Modal.cachedProvider
  }
}

export default ModalWallet
