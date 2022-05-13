<template>
  <q-layout view="lHh Lpr lFf">
    <q-header elevated>
      <q-toolbar>
        <q-toolbar-title>
          Voting
        </q-toolbar-title>
        <q-btn no-caps color="dark" label="Set Target Votes" @click="role === 1 || role === 2 ? setTargetVotesDialog = true : noPermission()" style="margin-right: 10px"/>
        <q-btn no-caps color="dark" label="Set Consensus Ratio" @click="role === 1 || role === 2 ? setConsensusRatioDialog = true : noPermission()" style="margin-right: 10px"/>
        <q-btn no-caps color="dark" label="Add Voter" @click="role === 1 || role === 2 ? addVoterDialog = true : noPermission()" style="margin-right: 10px"/>
        <q-btn no-caps color="dark" label="Add No Reason" @click="role === 1 || role === 2 ? addReasonDialog = true : noPermission()" style="margin-right: 10px"/>
        <q-btn no-caps color="dark" label="Add Candidate" @click="role === 1 || role === 2 ? addCandidateDialog = true : noPermission()" style="margin-right: 10px"/>
        <q-btn no-caps color="dark" label="Add Administrator" @click="role === 1 ? addAdministratorDialog = true : noPermission()" style="margin-right: 10px"/>

        <div>{{wallet.account}}</div>
      </q-toolbar>
    </q-header>
    <q-page-container>
      <router-view />
    </q-page-container>
    <q-dialog v-model="addVoterDialog">
      <q-card>
        <q-card-section>
          <div style="width: 300px">
            <q-input v-model="voterAddress" stack-label label="Voter Address" />
          </div>
        </q-card-section>
        <q-card-actions class="flex flex-center">
          <q-btn no-caps label="cancel" @click="addVoterDialog = false"/>
          <q-btn no-caps color="primary" label="confirm" @click="addVoter"/>
        </q-card-actions>
      </q-card>
    </q-dialog>
    <q-dialog v-model="addReasonDialog">
      <q-card>
        <q-card-section>
          <div style="width: 300px">
            <q-input v-model="reason" stack-label label="Reason" />
          </div>
        </q-card-section>
        <q-card-actions class="flex flex-center">
          <q-btn no-caps label="cancel" @click="addReasonDialog = false"/>
          <q-btn no-caps color="primary" label="confirm" @click="addNoOptionReason"/>
        </q-card-actions>
      </q-card>
    </q-dialog>
    <q-dialog v-model="addCandidateDialog">
      <q-card>
        <q-card-section>
          <div style="width: 300px">
            <q-input type="number" v-model="candidate.cid" stack-label label="cid" />
            <q-input v-model="candidate.mediaUrl" stack-label label="mediaUrl" />
            <q-input v-model="candidate.webUrl" stack-label label="webUrl" />
            <q-input v-model="candidate.title" stack-label label="title" />
            <q-input v-model="candidate.desc" stack-label label="desc" />
          </div>
        </q-card-section>
        <q-card-actions class="flex flex-center">
          <q-btn no-caps label="cancel" @click="addCandidateDialog = false"/>
          <q-btn no-caps color="primary" label="confirm" @click="addCandidate"/>
        </q-card-actions>
      </q-card>
    </q-dialog>
    <q-dialog v-model="setTargetVotesDialog">
      <q-card>
        <q-card-section>
          <div style="width: 300px">
            <q-input type="number" v-model="targetVotes" stack-label label="Target Votes" />
          </div>
        </q-card-section>
        <q-card-actions class="flex flex-center">
          <q-btn no-caps label="cancel" @click="setTargetVotesDialog = false"/>
          <q-btn no-caps color="primary" label="confirm" @click="setTargetVotes"/>
        </q-card-actions>
      </q-card>
    </q-dialog>
    <q-dialog v-model="setConsensusRatioDialog">
      <q-card>
        <q-card-section>
          <div style="width: 300px">
            <q-input type="number" v-model="consensusRatio" stack-label label="Consensus Ratio" />
          </div>
        </q-card-section>
        <q-card-actions class="flex flex-center">
          <q-btn no-caps label="cancel" @click="setConsensusRatioDialog = false"/>
          <q-btn no-caps color="primary" label="confirm" @click="setConsensusRatio"/>
        </q-card-actions>
      </q-card>
    </q-dialog>
    <q-dialog v-model="addAdministratorDialog">
      <q-card>
        <q-card-section>
          <div style="width: 300px">
            <q-input v-model="administrator" stack-label label="Administrator Address" />
          </div>
        </q-card-section>
        <q-card-actions class="flex flex-center">
          <q-btn no-caps label="cancel" @click="addAdministratorDialog = false"/>
          <q-btn no-caps color="primary" label="confirm" @click="addAdministrator"/>
        </q-card-actions>
      </q-card>
    </q-dialog>
  </q-layout>
</template>

<script>
import { mapState } from 'vuex'
import Contract from 'src/util/contract'

export default {
  name: 'MainLayout',
  data () {
    return {
      addVoterDialog: false,
      voterAddress: '',
      addReasonDialog: false,
      reason: '',
      addCandidateDialog: false,
      candidate: {},
      setTargetVotesDialog: false,
      targetVotes: '',
      setConsensusRatioDialog: false,
      consensusRatio: '',
      addAdministratorDialog: false,
      administrator: ''
    }
  },
  computed: {
    ...mapState(['wallet']),
    ...mapState(['role'])
  },
  methods: {
    noPermission () {
      this.$message.error('no permission!')
    },
    addVoter () {
      if (this.voterAddress === '' || this.voterAddress.length !== 42 || !this.voterAddress.startsWith('0x')) {
        this.$message.error('voter address error!')
        return
      }
      Contract.voting.addVoter(this.voterAddress).then(res => {
        console.log('addVoter==>success')
        this.$message.success('add voter success!')
        this.voterAddress = ''
        this.addVoterDialog = false
      }).catch(res => {
        console.log(`addVoter-error==>${res}`)
        this.$message.error('add voter error!')
      })
    },
    addCandidate () {
      if (this.candidate.cid <= 0) {
        this.$message.error('candidate error!')
        return
      }
      Contract.voting.addCandidate(this.candidate.cid, this.candidate.mediaUrl, this.candidate.webUrl, this.candidate.title, this.candidate.desc).then(res => {
        console.log('addCandidate==>success')
        this.$message.success('add candidate success!')
        this.candidate = {}
        this.addCandidateDialog = false
      }).catch(res => {
        console.log(`addCandidate-error==>${res}`)
        this.$message.error('add candidate error!')
      })
    },
    setTargetVotes () {
      if (this.targetVotes == null || this.targetVotes <= 0) {
        this.$message.error('target votes error！')
        return
      }
      Contract.voting.setTargetVotes(this.targetVotes).then(res => {
        console.log('setTargetVotes==>success')
        this.$message.success('set target votes success!')
        this.targetVotes = 0
        this.setTargetVotesDialog = false
      }).catch(res => {
        console.log(`setTargetVotes-error==>${res}`)
        this.$message.error('set target votes error!')
      })
    },
    setConsensusRatio () {
      if (this.consensusRatio == null || this.consensusRatio > 100 || this.consensusRatio <= 0) {
        this.$message.error('consensus ratio error！')
        return
      }
      Contract.voting.setConsensusRatio(this.consensusRatio).then(res => {
        console.log('setConsensusRatio==>success')
        this.$message.success('set consensus ratio success!')
        this.consensusRatio = 0
        this.setConsensusRatioDialog = false
      }).catch(res => {
        console.log(`setConsensusRatio-error==>${res}`)
        this.$message.error('set consensus ratio error!')
      })
    },
    addNoOptionReason () {
      if (this.reason === '') {
        this.$message.error('reason error！')
        return
      }
      Contract.voting.addNoOptionReason(this.reason).then(res => {
        console.log('addNoOptionReason==>success')
        this.$message.success('add reason success!')
        this.reason = ''
        this.addReasonDialog = false
      }).catch(res => {
        console.log(`addNoOptionReason-error==>${res}`)
        this.$message.error('add reason error!')
      })
    },
    addAdministrator () {
      if (this.administrator === '' || this.administrator.length !== 42 || !this.administrator.startsWith('0x')) {
        this.$message.error('administrator address error!')
        return
      }
      Contract.voting.addAdministrator(this.administrator).then(res => {
        console.log('addAdministrator==>success')
        this.$message.success('add administrator success!')
        this.administrator = ''
        this.addAdministratorDialog = false
      }).catch(res => {
        console.log(`addAdministrator-error==>${res}`)
        this.$message.error('add administrator error!')
      })
    }
  }
}
</script>
