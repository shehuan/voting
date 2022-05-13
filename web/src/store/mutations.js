
export default {
  setWallet (state, wallet) {
    state.wallet = { account: wallet.account, connector: Object.freeze(wallet.connector) }
  },
  setRole (state, role) {
    state.role = role
  }
}
