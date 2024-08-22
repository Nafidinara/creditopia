import { defineStore } from 'pinia'
import { loan } from 'declarations/loan'

export const useLoanStore = defineStore('loan', {
  state: () => {
    return {
      loans: []
    }
  },
  actions: {
    async getLoans() {
    }
  }
})