pragma solidity ^0.4.25;

import "./zombiefeeding.sol";

contract ZombieHelper is ZombieFeeding {

  uint levelUpFee = 0.001 ether;

  event ZombieDeleted(uint indexed zombieId, address indexed owner);

  modifier aboveLevel(uint _level, uint _zombieId) {
    require(zombies[_zombieId].level >= _level);
    _;
  }

  function withdraw() external onlyOwner {
    address _owner = owner();
    _owner.transfer(address(this).balance);
  }

  function setLevelUpFee(uint _fee) external onlyOwner {
    levelUpFee = _fee;
  }

  function levelUp(uint _zombieId) external payable {
    require(msg.value == levelUpFee);
    zombies[_zombieId].level = zombies[_zombieId].level.add(1);
  }

  // ✏️ Updated changeName — removed aboveLevel restriction
  function changeName(uint _zombieId, string _newName)
    external
    onlyOwnerOf(_zombieId)
  {
    require(bytes(_newName).length > 0, "Name cannot be empty");
    zombies[_zombieId].name = _newName;
  }

  function changeDna(uint _zombieId, uint _newDna)
    external
    aboveLevel(20, _zombieId)
    onlyOwnerOf(_zombieId)
  {
    zombies[_zombieId].dna = _newDna;
  }

  function getZombiesByOwner(address _owner) external view returns (uint[]) {
    uint[] memory result = new uint[](ownerZombieCount[_owner]);
    uint counter = 0;
    for (uint i = 0; i < zombies.length; i++) {
      if (zombieToOwner[i] == _owner) {
        result[counter] = i;
        counter++;
      }
    }
    return result;
  }

  // 🗑️ Delete Zombie
  function deleteZombie(uint _zombieId) external onlyOwnerOf(_zombieId) {
    // decrease owner's zombie count
    ownerZombieCount[msg.sender] = ownerZombieCount[msg.sender].sub(1);

    uint lastId = zombies.length - 1;

    if (_zombieId != lastId) {
      // Move the last zombie into the slot being deleted
      Zombie storage lastZombie = zombies[lastId];
      zombies[_zombieId] = lastZombie;
      zombieToOwner[_zombieId] = zombieToOwner[lastId];
    }

    // Clear mapping and shrink array
    delete zombieToOwner[lastId];
    zombies.length--;

    emit ZombieDeleted(_zombieId, msg.sender);
  }
}
