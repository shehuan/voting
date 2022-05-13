<template>
  <q-page class="main">
    <div class="ad" v-if="candidate.cid > 0">
      <q-img :src="candidate.mediaUrl" width="400px" height="400px" contain/>
      <div>
        <q-list>
          <q-item :key="index" v-for="(value, key, index) in candidate">
            {{key}}：{{value}}
          </q-item>
        </q-list>
      </div>
    </div>
    <div v-if="candidate.cid > 0" style="margin-top: 100px">
      <q-btn label="NO" color="dark" no-caps @click="showNoOptionDialog = true" />
      <q-btn label="YES" color="primary" no-caps @click="showYesOptionDialog = true" style="margin-left: 100px" />
    </div>
    <q-btn label="Get Candidate" color="dark" size="20px" no-caps @click="getCandidate" style="position: fixed; bottom: 300px; left: 50px; padding: 10px"/>
    <q-btn label="Voting History" color="dark" no-caps @click="getVoterCandidates" style="position: fixed; bottom: 200px; left: 50px"/>
    <q-btn label="Get Voting Result" color="dark" no-caps @click="getResultDialog = true" style="position: fixed; bottom: 100px; left: 50px"/>
    <q-dialog v-model="showNoOptionDialog">
      <q-card>
        <q-card-section>
          <div>choose reason</div>
        </q-card-section>
        <q-card-section>
          <q-option-group
            type="radio"
            color="secondary"
            v-model="reason"
            :options="reasons"
          />
        </q-card-section>
        <q-card-actions>
          <q-btn no-caps label="cancel" @click="showNoOptionDialog = false"/>
          <q-btn no-caps color="primary" label="confirm" @click="voteNo"/>
        </q-card-actions>
      </q-card>
    </q-dialog>

    <q-dialog v-model="showYesOptionDialog">
      <q-card>
        <q-card-section>
          <div>please confirm</div>
        </q-card-section>
        <q-card-actions>
          <q-btn no-caps label="cancel" @click="showYesOptionDialog = false"/>
          <q-btn no-caps color="primary" label="confirm" @click="voteYes"/>
        </q-card-actions>
      </q-card>
    </q-dialog>

    <q-dialog v-model="votingHistoryDialog">
      <q-card>
        <q-card-section>
          <div style="width: 600px">
            <q-list>
              <q-item :key="index" v-for="(value, key, index) in votingHistory">
                <ul style="cursor:pointer">
                  <li :key="index1" v-for="(value1, key1, index1) in value">
                    {{key1}}：{{value1}}
                  </li>
                  <q-btn dense no-caps label="My Option" @click="getVoterOption(value.cid)"/> <q-btn dense no-caps label="Voting Result" @click="getVotingResult(value.cid)" style="margin-left: 10px;"/>
                </ul>
              </q-item>
            </q-list>
          </div>
        </q-card-section>
      </q-card>
    </q-dialog>

    <q-dialog v-model="getResultDialog">
      <q-card>
        <q-card-section>
          <div style="width: 300px">
            <q-input type="number" v-model="cid" stack-label label="cid" />
          </div>
        </q-card-section>
        <q-card-actions class="flex flex-center">
          <q-btn no-caps label="cancel" @click="getResultDialog = false"/>
          <q-btn no-caps color="primary" label="confirm" @click="getVotingResult(cid)"/>
        </q-card-actions>
      </q-card>
    </q-dialog>

    <q-dialog v-model="resultDialog">
      <q-card>
        <q-card-section>
          <div style="width: 400px">
            <q-list>
              <q-item :key="index" v-for="(value, key, index) in result">
                {{key}}：{{value}}
              </q-item>
            </q-list>
          </div>
        </q-card-section>
        <q-card-actions class="flex flex-center">
          <q-btn no-caps color="primary" label="confirm" @click="resultDialog = false"/>
        </q-card-actions>
      </q-card>
    </q-dialog>

    <q-dialog v-model="optionDialog">
      <q-card>
        <q-card-section>
          <div style="width: 400px">
            <q-list>
              <q-item :key="index" v-for="(value, key, index) in optionDetail">
                {{key}}：{{value}}
              </q-item>
            </q-list>
          </div>
        </q-card-section>
        <q-card-actions class="flex flex-center">
          <q-btn no-caps color="primary" label="confirm" @click="optionDialog = false"/>
        </q-card-actions>
      </q-card>
    </q-dialog>
  </q-page>
</template>

<script>

import Contract from '../util/contract'

export default {
  name: 'PageIndex',
  data () {
    return {
      showNoOptionDialog: false,
      showYesOptionDialog: false,
      option: 0,
      reason: '',
      reasons: [],
      candidate: {},
      votingHistory: [],
      votingHistoryDialog: false,
      result: {},
      resultDialog: false,
      getResultDialog: false,
      cid: null,
      optionDetail: {},
      optionDialog: false
    }
  },
  computed: {
  },
  methods: {
    getNoOptionReasons () {
      Contract.voting.getNoOptionReasons().then(res => {
        console.log(`getNoOptionReasons==>${JSON.stringify(res)}`)
        this.reasons = []
        res.forEach(r => {
          this.reasons.push({ label: r, value: r })
        })
      }).catch(res => {
        console.log(`getNoOptionReasons-error==>${res}`)
      })
    },

    getCandidate () {
      this.getNoOptionReasons()
      Contract.voting.getCandidate().then(res => {
        console.log(`getCandidate==>${JSON.stringify(res)}`)
        this.candidate = { cid: res[0], mediaUrl: res[1], webUrl: res[2], title: res[3], desc: res[4] }
        if (this.candidate.cid.toNumber() === 0) {
          this.$message.success('no candidate！')
        }
      }).catch(res => {
        console.log(`getCandidate-error==>${res.data.message}`)
        this.$message.error(`${res.errorArgs[0]}`)
      })
    },
    voteYes () {
      if (this.candidate == null) {
        this.$message.error('no ad！')
        return
      }
      this.option = 2

      Contract.voting.vote(this.candidate.cid, this.option, '').then(res => {
        console.log('vote success')
        this.showYesOptionDialog = false
        this.option = 0
        this.$message.success('vote success！')
      }).catch(res => {
        console.log(`vote-error==>${JSON.stringify(res)}`)
        this.$message.error(`${res.data.message}`)
      })
    },
    voteNo () {
      if (this.candidate == null) {
        this.$message.error('no ad！')
        return
      }
      if (this.reason === '') {
        this.$message.error('please choose reason！')
        return
      }
      this.option = 1

      Contract.voting.vote(this.candidate.cid, this.option, this.reason).then(res => {
        console.log('vote success')
        this.showNoOptionDialog = false
        this.option = 0
        this.reason = ''
        this.$message.success('vote success！')
      }).catch(res => {
        console.log(`vote-error==>${JSON.stringify(res)}`)
        this.$message.error(`${res.data.message}`)
      })
    },
    getVoterCandidates () {
      this.votingHistory = []
      Contract.voting.getVoterCandidates(1).then(res => {
        console.log(`getVoterCandidates==>${JSON.stringify(res)}`)
        res.forEach(r => {
          this.votingHistory.push({ cid: r[0], mediaUrl: r[1], webUrl: r[2], title: r[3], desc: r[4] })
        })
        if (this.votingHistory.length === 0) {
          this.$message.success('no voting history!')
          return
        }
        this.votingHistoryDialog = true
      }).catch(res => {
        console.log(`getVoterCandidates-error==>${JSON.stringify(res)}`)
        this.$message.error(`${res.errorArgs[0]}`)
      })
    },
    getVotingResult (cid) {
      Contract.voting.getVotingResult(cid).then(res => {
        console.log(`getVotingResult==>${res}`)
        this.getResultDialog = false
        this.result = { cid: res[0], yesVotes: res[1], noVotes: res[2], currentVotes: res[3], result: res[4] }
        if (this.result.cid.toNumber() === 0) {
          this.$message.success('no result！')
        } else {
          this.$message.success('get voting result success!')
          if (this.result.result === 0) {
            this.result.result = 'INVALID'
          } else if (this.result.result === 1) {
            this.result.result = 'REJECTED'
          } else if (this.result.result === 2) {
            this.result.result = 'APPROVED'
          }
          this.resultDialog = true
        }
      }).catch(res => {
        console.log(`getVotingResult-error==>${res}`)
        this.$message.error('get voting result error!')
      })
    },
    getVoterOption (cid) {
      Contract.voting.getVoterOption(cid).then(res => {
        console.log(`getVoterOption==>${res}`)
        this.optionDialog = false
        this.optionDetail = {
          cid: res[0],
          option: res[1],
          reason: res[2]
        }
        if (this.optionDetail.cid.toNumber() === 0) {
          this.$message.success('no option！')
        } else {
          this.$message.success('get voter option success!')
          if (this.optionDetail.option === 0) {
            this.optionDetail.option = 'INVALID'
          } else if (this.optionDetail.option === 1) {
            this.optionDetail.option = 'NO'
          } else if (this.optionDetail.option === 2) {
            this.optionDetail.option = 'YES'
          }
          this.optionDialog = true
        }
      }).catch(res => {
        console.log(`getVoterOption-error==>${res}`)
        this.$message.error('get voter option error!')
      })
    }
  }
}
</script>
<style>
  .main {
    display: flex;
    flex-direction: column;
    justify-content: flex-start;
    align-items: center;
  }
  .ad {
    display: flex;
    flex-direction: row;
    justify-content: center;
    align-items: center;
    margin-top: 100px;
  }
</style>
