import { defineStore } from 'pinia'
import { loan } from 'declarations/loan'
import { user } from 'declarations/user'

export const useLoanStore = defineStore('loan', {
  state: () => {
    return {
      loans: []
    }
  },
  actions: {
    async getLoans() {
      const response = await loan.getAllLoans()
      let filteredResponse = response;
      filteredResponse = await Promise.all(filteredResponse.map(async item => {
        const userData = await user.get_user(item[1].borrower.toString())
        return {
          ...item[1],
          userData: userData[0]
        }
      }))
      this.loans = filteredResponse
    }
  }
})