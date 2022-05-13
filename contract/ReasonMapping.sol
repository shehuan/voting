// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

struct ReasonData {
    mapping(string => ReasonValue) datas;
    string[] keys;
}

struct ReasonValue {
    bool value;
    uint keyIndex;
}

library ReasonMapping {
    function add(ReasonData storage self, string memory key, bool value) internal {
        // 已存在
        if (self.datas[key].value) {
            return;
        }
        self.keys.push(key);
        self.datas[key] = ReasonValue({value: value, keyIndex: self.keys.length -1});
    }

    function remove(ReasonData storage self, string memory key) internal {
        // 不存在
        if (!self.datas[key].value) {
            return;
        }
        for (uint i = self.datas[key].keyIndex; i < self.keys.length - 1; i++) {
             self.keys[i] =  self.keys[i+1];
        }
        self.keys.pop();
        delete self.datas[key];
    }

    function getKeys(ReasonData storage self) internal view returns(string[] memory) {
        return self.keys;
    }

    function contains(ReasonData storage self, string memory key) internal view returns(bool) {
        return self.datas[key].value;
    }
}