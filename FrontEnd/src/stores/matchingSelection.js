import { defineStore } from 'pinia'

export const useMatchingSelectionStore = defineStore('matchingSelection', {
  state: () => ({
    recipient: null,
    caregiver: null,
  }),
  actions: {
    setRecipient(recipient) {
      this.recipient = recipient
      this.caregiver = null
    },
    setCaregiver(caregiver) {
      this.caregiver = caregiver
    },
    clear() {
      this.recipient = null
      this.caregiver = null
    },
  },
})