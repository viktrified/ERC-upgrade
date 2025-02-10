// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.28;

import './lib/Events.sol';
import './lib/Errors.sol';

contract KWAG {
    string public name;
    string public symbol; 
    uint8 public decimals; 
    uint public totalSupply; 
    address public owner;
    bool public paused;

    mapping(address => uint) private balances;
    mapping(address => mapping(address => uint)) private allowances;
    mapping(address => bool) private holders;
    uint private holderCount;

    modifier onlyOwner() {
        require(msg.sender == owner, "Not the owner");
        _;
    }

    modifier whenNotPaused() {
        require(!paused, "Token transfers are paused");
        _;
    }

    constructor() {
        owner = msg.sender;
        name = "Kwagarelly Token";
        symbol = "KWAG";
        decimals = 18;
        totalSupply = 1000000 * 10**decimals;
        balances[owner] = totalSupply;
        holders[owner] = true;
        holderCount = 1;
    }

    function multiTransfer(uint _value, address[] memory _recipients, bool _evenly) public whenNotPaused {
        uint totalAmount = _value * _recipients.length;
        require(balances[msg.sender] >= totalAmount, "Insufficient balance");

        if (_evenly) {
            uint amountPerRecipient = _value;
            for (uint i = 0; i < _recipients.length; i++) {
                _transfer(msg.sender, _recipients[i], amountPerRecipient);
            }
        } else {
            for (uint i = 0; i < _recipients.length; i++) {
                _transfer(msg.sender, _recipients[i], _value);
            }
        }
    }

    function multiApproval(uint _value, address[] memory _recipients, bool _evenly) public {
        require(_recipients.length > 0, "No recipients provided");

        if (_evenly) {
            uint amountPerRecipient = _value;
            for (uint i = 0; i < _recipients.length; i++) {
                allowances[msg.sender][_recipients[i]] = amountPerRecipient;
                emit Events.Approval(msg.sender, _recipients[i], amountPerRecipient);
            }
        } else {
            for (uint i = 0; i < _recipients.length; i++) {
                allowances[msg.sender][_recipients[i]] = _value;
                emit Events.Approval(msg.sender, _recipients[i], _value);
            }
        }
    }

    function mint(address to, uint256 amount) external onlyOwner {
        require(to != address(0), "Invalid address");

        totalSupply += amount;
        balances[to] += amount;
        if (!holders[to]) {
            holders[to] = true;
            holderCount++;
        }

        emit Events.Transfer(address(0), to, amount);
    }

    function burn(uint256 amount) external {
        require(balances[msg.sender] >= amount, "Insufficient balance");

        balances[msg.sender] -= amount;
        totalSupply -= amount;

        emit Events.Transfer(msg.sender, address(0), amount);
    }

    function transfer(address to, uint256 value) external whenNotPaused returns (bool) {
        _transfer(msg.sender, to, value);
        return true;
    }

    function approve(address spender, uint256 value) external whenNotPaused returns (bool) {
        require(balances[msg.sender] >= value, "Insufficient balance");

        allowances[msg.sender][spender] = value;
        emit Events.Approval(msg.sender, spender, value);
        return true;
    }

    function transferFrom(address from, address to, uint256 value) external whenNotPaused returns (bool) {
        require(balances[from] >= value, "Insufficient balance");
        require(allowances[from][msg.sender] >= value, "Allowance exceeded");

        allowances[from][msg.sender] -= value;
        _transfer(from, to, value);

        return true;
    }

    function _transfer(address from, address to, uint256 value) internal {
        require(to != address(0), "Invalid address");
        require(balances[from] >= value, "Insufficient balance");

        balances[from] -= value;
        balances[to] += value;

        if (!holders[to]) {
            holders[to] = true;
            holderCount++;
        }

        if (balances[from] == 0) {
            holders[from] = false;
            holderCount--;
        }

        emit Events.Transfer(from, to, value);
    }

    function pause() external onlyOwner {
        paused = true;
    }

    function unpause() external onlyOwner {
        paused = false;
    }

    function changeOwner(address newOwner) external onlyOwner {
        require(newOwner != address(0), "Invalid address");
        owner = newOwner;
    }

    function getTotalHolders() external view returns (uint256) {
        return holderCount;
    }

    function balanceOf(address account) external view returns (uint256) {
        return balances[account];
    }

    function allowance(address _owner, address spender) external view returns (uint256) {
        return allowances[_owner][spender];
    }
}
