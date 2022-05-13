import { ethers } from 'ethers'
const votingAbi = [
  'function setTargetVotes(uint32 votes) external',
  'function getTargetVotes() external view returns (uint32)',
  'function setConsensusRatio(uint8 ratio) external',
  'function getConsensusRatio() external view returns (uint8)',
  'function addVoter(address voter) external',
  'function setVoterStatus(address voter) external',
  'function addNoOptionReason(string reason) external',
  'function removeNoOptionReason(string reason) external',
  'function getNoOptionReasons() external view returns (string[])',
  'function addCandidate(uint cid, string mediaUrl, string webUrl, string title, string desc) external',
  'function getCandidate() external view onlyVoter returns (tuple(uint cid, string mediaUrl, string webUrl, string title, string desc))',
  'function vote(uint cid, uint8 option, string reason) external',
  'function getVotingResult(uint cid) external view returns (tuple(uint cid, address[] yesVotes, address[] noVotes, uint32 currentVotes, uint8 result))',
  'function getVoterOption(uint cid) external view returns (tuple(uint cid, uint8 option, string reason))',
  'function getVoterCandidates(uint pageNum) external view returns (tuple(uint cid, string mediaUrl, string webUrl, string title, string desc)[])',
  'function containsNoOptionReason(string reason) public view returns (bool)',
  'function getRole() external view returns(uint8)',
  'function addAdministrator(address administrator) public'
]

const defaultProvider = ethers.getDefaultProvider()
export default {
  voting: new ethers.Contract(process.env.voting.address, votingAbi, defaultProvider),
  withSigner (signer) {
    this.voting = this.voting.connect(signer)
  }
}
