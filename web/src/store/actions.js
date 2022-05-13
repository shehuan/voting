import ModalWallet from '../util/modal-wallet'
import Contract from 'src/util/contract'

export function connectWallet (context) {
  return new Promise((resolve, reject) => {
    ModalWallet.connect().then(res => {
      context.commit('setWallet', { account: res, connector: ModalWallet })
      Contract.withSigner(ModalWallet.provider.getSigner())
      Contract.voting.getRole().then(res => {
        context.commit('setRole', res)
      })
      resolve(true)
    }).catch(error => reject(error))
  })
}
