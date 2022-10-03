pragma solidity 0.8.16;

import "hardhat/console.sol";

library IterableMapping {
    struct Map {
        address[] keys;
        mapping(address => uint) values;
        mapping(address => uint) indexOf;
    }

    function get(Map storage map, address key) internal view returns (uint) {
        if (_checkIfKeyExist(map, key)) return map.values[key];
        return 0;
    }

    function getKeyAtIndex(Map storage map, uint index)
        internal
        view
        returns (address)
    {
        return map.keys[index];
    }

    function size(Map storage map) internal view returns (uint) {
        return map.keys.length;
    }

    function set(
        Map storage map,
        address key,
        uint val
    ) internal {
        if (_checkIfKeyExist(map, key)) {
            map.values[key] += val;
        } else {
            map.values[key] = val;
            map.indexOf[key] = map.keys.length;
            map.keys.push(key);
        }
    }

    function remove(Map storage map, address key) internal {
        if (map.values[key] == 0) return;
        delete map.values[key];

        uint index = map.indexOf[key];
        uint lastIndex = map.keys.length - 1;
        address lastKey = map.keys[lastIndex];

        map.indexOf[lastKey] = index;
        delete map.indexOf[key];

        map.keys[index] = lastKey;
        map.keys.pop();
    }

    function _checkIfKeyExist(Map storage map, address key)
        private
        view
        returns (bool)
    {
        if (map.keys.length == 0) return false;
        uint index = map.indexOf[key];
        if (map.keys[index] == key) return true;
        return false;
    }
}
