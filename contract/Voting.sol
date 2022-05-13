// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./ReasonMapping.sol";
import "./CandidateMapping.sol";
import "./Data.sol";

contract Voting {
    // 合约持有人
    address private owner;
	// 目标票数
	uint32 private targetVotes = 4;
	// 通过时肯定票百分比
    uint8 private consensusRatio = 70;
    // 分页查询时每页数据量
    uint8 private pageSize = 10;

    // 管理员
    mapping(address => bool) administrators;
    // 投票人 => 投票人具体信息
    mapping(address => Voter) private voters;
    // 资源id => 投票结果
    mapping(uint => VotingResult) private votingResults;
    // 投票人 => (资源id => 投的内容)
    mapping(address => mapping(uint => OptionDetail)) private voterOptions;
    // 投票人 => 投过的资源id数组
    mapping(address => uint[]) private voterCandidates;

    using ReasonMapping for ReasonData;
    // 投否定票可以选择的原因
    ReasonData private noOptionReasons;

    using CandidateMapping for CandidateData;
    // 正在进行投票的资源 
    CandidateData private votingCandidates;
    // 已完成投票的资源 
    CandidateData private overCandidates;

    constructor() {
        owner = msg.sender;
        addAdministrator(owner);
    }

    modifier onlyOwner() {
        require(owner == msg.sender, "Only the owner can operate!");
        _;
    }

    modifier onlyVoter() {
        require(voters[msg.sender].enabled == true, "Only the voter can operate!");
        _;
    }

    modifier onlyAdministrator() {
        require(administrators[msg.sender] == true, "Only the administrator can operate!");
        _;
    }

    modifier onlyAdministratorOrVoter() {
        require(administrators[msg.sender] == true || voters[msg.sender].enabled == true, "Only the administrator or voter can operate!");
        _;
    }

    /*
    * 添加管理员
    */
    function addAdministrator(address administrator) public onlyOwner {
        administrators[administrator] = true;
    }

    /*
    * 删除管理员
    */
    function removeAdministrator(address administrator) external onlyOwner {
        delete administrators[administrator];
    }

    /*
    * 判断当前用户角色
    */
    function getRole() external view returns(uint8) {
        if (owner == msg.sender) {
            return 1;
        } else if (administrators[msg.sender]) {
            return 2;
        } else {
            return 3;
        }
    }

    /*
    * 修改目标票数
    */
    function setTargetVotes(uint32 votes) external onlyAdministrator {
        targetVotes = votes;
    }

    /*
    * 查询目标票数
    */
    function getTargetVotes() external view onlyAdministrator returns(uint32) {
        return targetVotes;
    }

    /*
    * 修改通过时肯定票百分比
    */
    function setConsensusRatio(uint8 ratio) external onlyAdministrator {
        consensusRatio = ratio;
    }

    /*
    * 查询通过时肯定票百分比
    */
    function getConsensusRatio() external view onlyAdministrator returns(uint8) {
        return consensusRatio;
    }

    /*
    * 设置每页数据量
    */
    function setPageSize(uint8 size) external onlyAdministrator {
        pageSize = size;
    }

    /*
    * 添加投票人
    */
    function addVoter(address voter) external onlyAdministrator {
        require(voters[voter].voter == address(0), "Voter already exist!");
        voters[voter] = Voter({voter: voter, enabled: true});
    }

    /*
    * 切换投票人状态（启用/禁用）
    */
    function setVoterStatus(address voter) external onlyAdministrator {
        require(voters[voter].voter != address(0), "Voter is not exist!");
        voters[voter].enabled = !voters[voter].enabled;
    }

    /*
    * 查询投票人
    */
    function getVoter(address voter) external view onlyAdministrator returns(Voter memory) {
        return voters[voter];
    }

    /*
    * 添加投否定票的原因
    */
    function addNoOptionReason(string memory reason) external onlyAdministrator {
        noOptionReasons.add(reason, true);
    }

    /*
    * 移除投否定票的原因
    */
    function removeNoOptionReason(string memory reason) external onlyAdministrator {
        noOptionReasons.remove(reason);
    }

    /*
    * 查询全部投否定票的原因
    */
    function getNoOptionReasons() external view onlyAdministratorOrVoter returns(string[] memory) {
        return noOptionReasons.getKeys();
    }

    /*
    * 检查否定票的原因是否存在
    */
    function containsNoOptionReason(string memory reason) public view onlyAdministratorOrVoter returns(bool) {
        return noOptionReasons.contains(reason);
    }

    /*
    * 添加资源
    */
    function addCandidate(uint cid, string memory mediaUrl, string memory webUrl, string memory title, string memory desc) external onlyAdministrator {
        require(!votingCandidates.contains(cid), "Candidate already exist!");
        Candidate memory candidate = Candidate({cid: cid, mediaUrl: mediaUrl, webUrl: webUrl, title: title, desc: desc});
        votingCandidates.add(candidate);
    }

    /*
    * 查询某个正在投票的资源
    */
    function getVotingCandidate(uint cid) external view onlyAdministratorOrVoter returns(Candidate memory) {
        return votingCandidates.getValue(cid);
    }

    /*
    * 查询某个已有投票结果的资源
    */
    function getOverCandidate(uint cid) external view onlyAdministratorOrVoter returns(Candidate memory) {
        return overCandidates.getValue(cid);
    }

    /*
    * 查询全部可以投票的资源
    */
    function getAllVotingCandidates() external view onlyAdministrator returns(Candidate[] memory) {
        return votingCandidates.getValues();
    }

    /*
    * 投票人取一个资源去投票
    */
    function getCandidate() external view onlyVoter returns(Candidate memory) {
        Candidate[] memory candidates = votingCandidates.getValues();
        Candidate memory result;
        for (uint i = 0; i < candidates.length; i++ ) {
            uint cid = candidates[i].cid;
            // 当前 voter 没有给该资源投过票
            if (voterOptions[msg.sender][cid].option == Option.INVALID) {
                result = candidates[i];
                break;
            }
        }
        return result;
    }

    /*
    * 投票
    */
    function vote(uint cid, Option option, string memory reason) external onlyVoter {
        // 检查投票结果
        require(votingResults[cid].result == Result.INVALID, "Voting result have been calculated");
        // 检查资源是否存在
        require(votingCandidates.contains(cid), "Candidate is not exist!");
        // 检查是否已投过票
        require(voterOptions[msg.sender][cid].option ==  Option.INVALID, "Voter have already voted!");
        // 检查票数
        require(votingResults[cid].currentVotes < targetVotes, "Max votes has bean reached!");
        
        // 记录投票信息
        votingResults[cid].cid = cid;
        if (option == Option.YES) {
            reason = "";
            votingResults[cid].yesVotes.push(msg.sender);
        } else if (option == Option.NO) {
            if (!containsNoOptionReason(reason)) {
                revert("Reason is not exist!");
            }
            votingResults[cid].noVotes.push(msg.sender);
        } else {
            revert("Option is error!");
        }
        // 总票数加1
        votingResults[cid].currentVotes += 1;
        // 记录投票人当前的投票
        voterOptions[msg.sender][cid] = OptionDetail({cid: cid, option: option, reason: reason});
        voterCandidates[msg.sender].push(cid);

        if (votingResults[cid].currentVotes >= targetVotes) {
            // 计算投票结果
            calculateResult(cid);
            // 转移已完成投票的资源到其它集合
            Candidate memory candidate = votingCandidates.getValue(cid);
            overCandidates.add(candidate);
            votingCandidates.remove(cid);
        }
    }

    /*
    * 计算资源的投票结果
    */
    function calculateResult(uint cid) private {
        // // 检查资源是否存在
        // require(votingCandidates.contains(cid), "Candidate is not exist!");
        // // 检查票数
        // require(votingResults[cid].currentVotes >= targetVotes, "Target number of votes was not reached!");
        // // 检查投票结果
        // require(votingResults[cid].result == Result.INVALID, "Voting result have been calculated");
    
        uint _requiredYesVotes = consensusRatio * votingResults[cid].currentVotes;
        uint _yesVotes = votingResults[cid].yesVotes.length * 100;
        if (_yesVotes >= _requiredYesVotes) {
            // 通过
            votingResults[cid].result = Result.APPROVED;
        } else {
            // 拒绝
            votingResults[cid].result = Result.REJECTED;
        }
    }

    /*
    * 查询某个资源的投票结果
    */
    function getVotingResult(uint cid) external view onlyAdministratorOrVoter returns(VotingResult memory) {
        if (votingResults[cid].result == Result.INVALID && voters[msg.sender].enabled == true) {
            VotingResult memory result;
            return result;
        }
        return votingResults[cid];
    }

    /*
    * 查询投票人给某个资源投的票
    */
    function getVoterOption(uint cid) external view onlyVoter returns(OptionDetail memory) {
        return voterOptions[msg.sender][cid];
    }

    /*
    * 分页查询投票人投过的资源
    */
    function getVoterCandidates(uint pageNum) external view onlyVoter returns(Candidate[] memory) {
        require(pageNum > 0, "PageNum must be greater than 0!");
        uint[] memory cids = voterCandidates[msg.sender];
        if (cids.length == 0) {
            return new Candidate[](0);
        }
        if (cids.length <= (pageNum - 1) * pageSize) {
            return new Candidate[](0);
        }
        // 已遍历后剩余的数量
        uint rest = cids.length - (pageNum - 1) * pageSize;
        Candidate[] memory result = new Candidate[](rest >= pageSize ? pageSize : rest);
        for (uint i = 0; i < result.length; i++) {
            rest = rest - 1;
            uint cid = cids[rest];
            if (votingResults[cid].result == Result.INVALID) {
                result[i] = votingCandidates.getValue(cid);
            } else {
                result[i] = overCandidates.getValue(cid);
            }
            // result[i] = overCandidates.getValue(cid);
            // if (result[i].cid == 0) {
            //     result[i] = votingCandidates.getValue(cid);
            // }
        }
        return result;
    }
}