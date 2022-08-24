// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "./Context.sol";
 
// Safe Math interface 
contract SafeMath {
 
    function safeAdd(uint a, uint b) public pure returns (uint c) {
        c = a + b;
        require(c >= a);
    }
 
    function safeSub(uint a, uint b) public pure returns (uint c) {
        require(b <= a);
        c = a - b;
    }
 
    function safeMul(uint a, uint b) public pure returns (uint c) {
        c = a * b;
        require(a == 0 || c / a == b);
    }
 
    function safeDiv(uint a, uint b) public pure returns (uint c) {
        require(b > 0);
        c = a / b;
    }
}
 
// source: https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC20/IERC20.sol
interface IERC20 {
    /**
     * @dev Emitted when `value` amount are moved from one account (`from`) to
     * another (`to`).
     *
     * Note that `value` may be zero.
     */
    event Transfer(address indexed from, address indexed to, uint256 value);

    /**
     * @dev Emitted when the allowance of a `spender` for an `owner` is set by
     * a call to {approve}. `value` is the new allowance.
     */
    event Approval(address indexed owner, address indexed spender, uint256 value);

    /**
     * @dev Returns the amount of amount in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of amount owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` amount from the caller's account to `to`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address to, uint256 amount) external returns (bool);

    /**
     * @dev Returns the remaining number of amount that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address spender) external view returns (uint256);

    /**
     * @dev Sets `amount` as the allowance of `spender` over the caller's amount.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * IMPORTANT: Beware that changing an allowance with this method brings the risk
     * that someone may use both the old and the new allowance by unfortunate
     * transaction ordering. One possible solution to mitigate this race
     * condition is to first reduce the spender's allowance to 0 and set the
     * desired value afterwards:
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     *
     * Emits an {Approval} event.
     */
    function approve(address spender, uint256 amount) external returns (bool);

    /**
     * @dev Moves `amount` amount from `from` to `to` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);
}

// Based off: https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC20/ERC20.sol
contract FlowerCoin is IERC20, SafeMath {
    string public symbol = "FC";
    string public name  = "FlowerCoin";
    uint8 public decimals = 2;
    uint public _totalSupply;
    
    address public minter;
    mapping(address => uint) private _balances;
    mapping(address => mapping(address => uint)) _allowed;
 
    constructor() {
        minter = msg.sender;
        _totalSupply = 100000000;
        _balances[minter] = _totalSupply;
        emit Transfer(address(0), minter, _totalSupply);
    }

    function mint(address receiver, uint256 amount) public virtual returns (bool success) {
        require(receiver != address(0), "ERC20: mint to the zero address");
        require(msg.sender == minter, "Only the minter can use this function.");
        _totalSupply = safeAdd(amount, _totalSupply);
        _balances[receiver] = safeAdd(_balances[receiver], amount);

        emit Transfer(address(0), receiver, amount);
        return true;
    }
 
    function totalSupply() public view returns (uint) {
        return _totalSupply  - _balances[address(0)];
    }
 
    function balanceOf(address account) public view returns (uint balance) {
        return _balances[account];
    }
 
    function transfer(address to, uint amount) public returns (bool success) {
        _balances[msg.sender] = safeSub(_balances[msg.sender], amount);
        _balances[to] = safeAdd(_balances[to], amount);
        emit Transfer(msg.sender, to, amount);
        return true;
    }
 
    function approve(address spender, uint amount) public returns (bool success) {
        _allowed[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true;
    }
 
    function transferFrom(address from, address to, uint amount) public returns (bool success) {
        _balances[from] = safeSub(_balances[from], amount);
        _allowed[from][msg.sender] = safeSub(_allowed[from][msg.sender], amount);
        _balances[to] = safeAdd(_balances[to], amount);
        emit Transfer(from, to, amount);
        return true;
    }
 
    function allowance(address owner, address spender) public view returns (uint remaining) {
        return _allowed[owner][spender];
    }


    fallback() external payable {
        revert();
    }

    receive() external payable {
        revert();
    }
}