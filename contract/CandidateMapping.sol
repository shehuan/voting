// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./Data.sol";

struct CandidateData {
    mapping(uint => CandidateValue) datas;
    uint[] keys;
}

struct CandidateValue {
    Candidate value;
    uint keyIndex;
}

library CandidateMapping {
    function add(CandidateData storage self, Candidate memory c) internal {
        // 已存在
        if (self.datas[c.cid].value.cid > 0) {
            return;
        }
        self.keys.push(c.cid);
        self.datas[c.cid] = CandidateValue({value: c, keyIndex: self.keys.length -1});
    }

    function remove(CandidateData storage self, uint key) internal {
        // 不存在
        if (self.datas[key].value.cid == 0) {
            return;
        }
        for (uint i = self.datas[key].keyIndex; i < self.keys.length - 1; i++) {
             self.keys[i] =  self.keys[i+1];
        }
        self.keys.pop();
        delete self.datas[key];
    }

    function contains(CandidateData storage self, uint key) internal view returns(bool) {
        return self.datas[key].value.cid > 0;
    }

    function getValues(CandidateData storage self) internal view returns(Candidate[] memory) {
        Candidate[] memory candidates = new Candidate[](self.keys.length);
        for (uint i = 0; i < self.keys.length; i++) {
            candidates[i] = self.datas[self.keys[i]].value;
        }
        return candidates;
    }

    function getValue(CandidateData storage self, uint key) internal view returns(Candidate memory) {
        return self.datas[key].value;
    }

    function getLength(CandidateData storage self) internal view returns(uint) {
        return self.keys.length;
    }
}