// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// 资源
struct Candidate {
    uint cid;
    string mediaUrl;
    string webUrl;
    string title;
    string desc;
}

// 投票人
struct Voter {
	address voter;
    bool enabled;
}

// 投票结果
struct VotingResult {
    uint cid;
    address[] yesVotes;
    address[] noVotes;
    uint32 currentVotes;
    Result result;
}

// 投票详情
struct OptionDetail {
    uint cid;
    Option option;
    string reason;
}

// 投票选项分类
enum Option {INVALID, NO, YES}

// 投票结果分类
enum Result {INVALID, REJECTED, APPROVED}