import { defineStore } from 'pinia'
import { user } from 'declarations/user/index';

export const useAuthStore = defineStore('auth', {
  state: () => {
    return {
      user: null,
      principalId: window.localStorage.getItem('principalId') || null,
      status: {
        severity: '',
        summary: '',
        detail: ''
      }
    }
  },
  getters: {
    isWalletConnected: (state) => !!state.principalId,
    isAuth: (state) => !!state.user
  },
  actions: {
    async connectToWallet() {
      try {
        if (window.ic && window.ic.plug) {
          // Request connection to the Bitfinity wallet
          await window.ic.plug.requestConnect();

          // Get the principal string
          const userPrincipal = await window.ic.plug.agent.getPrincipal();

          const userData = await user.get_user(userPrincipal.toString())

          if (userData.length) {
            this.user = userData[0]
            window.localStorage.setItem('principalId', userPrincipal.toString())
            this.principalId = userPrincipal.toString()
          } else {
            window.localStorage.setItem('principalId', userPrincipal.toString())
            this.principalId = userPrincipal.toString()
          }
          this.status = {
            severity: 'success',
            summary: 'Connected Wallet',
            detail: 'Your wallet already connected'
          }
        } else {
          this.status = {
            severity: 'error',
            summary: 'Error',
            detail: 'Please install wallet extensions'
          }
        }
      } catch (error) {
        this.status = {
          severity: 'error',
          summary: 'Error',
          detail: 'Failed to connecting wallet'
        }
      }
    },
    async createUser(params) {
      try {
        const userData = await user.create_user(this.principalId.toString(), params.name, params.email, params.phone, params.address);
        if (userData) {
          this.user = userData
          this.status = {
            severity: 'success',
            summary: 'Connected Wallet',
            detail: 'Success Creating User'
          }
        }
      } catch (err) {
        this.status = {
          severity: 'error',
          summary: 'Error',
          detail: err
        }
      }
    },
    async getUser() {
      if (this.principalId) {
        const userData = await user.get_user(this.principalId.toString())
        if (userData.length) {
          this.user = userData[0]
        }
      }
    },
    async logout() {
      this.user = null
      this.principalId = null
      window.localStorage.clear()
    }
  },
})