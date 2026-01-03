import { defineStore } from 'pinia'

export const useMatchingSelectionStore = defineStore('matchingSelection', {
  state: () => ({
    recipient: null,
    caregiver: null,

    recipientId: null,
    caregiverId: null,

    refreshTick: 0,
  }),

  actions: {
    refresh() {
      this.refreshTick += 1
    },

    setRecipient(recipient) {
      const id = recipient?.beneficiaryId ?? recipient?.id ?? null
      const prevId = this.recipientId

      this.recipient = recipient
      this.recipientId = id

      if (prevId !== id) {
        this.caregiver = null
        this.caregiverId = null
      }
    },

    setCaregiver(caregiver) {
      const id = caregiver?.careWorkerId ?? caregiver?.id ?? null

      this.caregiver = caregiver
      this.caregiverId = id
    },

    syncRecipient(recipient) {
      if (!recipient) return
      const id = recipient?.beneficiaryId ?? recipient?.id ?? null
      if (id !== this.recipientId) return
      this.recipient = recipient
    },

    syncCaregiver(caregiver) {
      if (!caregiver) return
      const id = caregiver?.careWorkerId ?? caregiver?.id ?? null
      if (id !== this.caregiverId) return
      this.caregiver = caregiver
    },

    clear() {
      this.recipient = null
      this.caregiver = null
      this.recipientId = null
      this.caregiverId = null
    },
  },
})