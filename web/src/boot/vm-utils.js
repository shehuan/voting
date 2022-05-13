// import something here

// more info on params: https://quasar.dev/quasar-cli/boot-files

import Vue from 'vue'
import { Notify } from 'quasar'
import { ethers } from 'ethers'

export default ({ app, router, store }) => {
  Vue.filter('addressFmt', function (val, start = 6, end = 4) {
    if (!val) return ''
    const reg = new RegExp('^(\\w{' + start + '})\\w+(\\w{' + end + '})$', 'gi')
    return val.toString().replace(reg, '$1...$2')
  })
  Vue.prototype.$message = {
    success (message) {
      Notify.create({
        type: 'positive',
        message: message,
        color: 'primary'
      })
    },
    error (message) {
      Notify.create({
        type: 'negative',
        message: message
      })
    },
    info (message) {
      Notify.create({
        message: message,
        color: 'info'
      })
    }
  }
  Vue.filter('formatEther', function (val) {
    if (!val) return '0'
    return ethers.utils.formatEther('0x' + val.toString(16))
  })
}
