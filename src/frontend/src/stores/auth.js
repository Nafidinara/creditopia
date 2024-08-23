import { defineStore } from 'pinia'
import { user } from 'declarations/user/index';

export const useAuthStore = defineStore('auth', {
  state: () => {
    return {
      user: null,
      userAgent: window.localStorage.getItem('userAgent') || null,
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
    async onConnectionUpdate () {
      console.log(window.ic.plug.sessionManager.sessionData)
    },
    // async isWalletConnected() {
    //   const result = await window.ic.plug.isConnected();
    // console.log(`Plug connection is ${result}`);
    // },
    async connectToWallet() {
      try {
        if (window.ic && window.ic.plug) {
          // Request connection to the Bitfinity wallet
          const publicKey = await window.ic.plug.requestConnect();
          console.log(`The connected user's public key is:`, publicKey);

          // Get the principal string
          const userPrincipal = await window.ic.plug.agent.getPrincipal();
          const userAgent = await window.ic.plug.agent;

          console.log(`The connected user's principal is:`, userPrincipal);
          console.log(`The connected user's agent is:`, userAgent);

          const userData = await user.get_user(userPrincipal.toString())

          if (userData.length) {
            this.user = userData[0]
            window.localStorage.setItem('principalId', userPrincipal.toString())
            this.principalId = userPrincipal.toString()
            this.useAuthStore = userAgent

            window.localStorage.setItem('userAgent', JSON.stringify(userAgent))
            this.userAgent = JSON.stringify(userAgent)
          } else {
            window.localStorage.setItem('principalId', userPrincipal.toString())
            this.principalId = userPrincipal.toString()
            this.useAuthStore = userAgent

            window.localStorage.setItem('userAgent', JSON.stringify(userAgent))
            this.userAgent = JSON.stringify(userAgent)
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