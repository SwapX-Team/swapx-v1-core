pragma solidity ^0.5.16;

import './SwapXPTStorage.sol';

import '../libraries/SafeMath.sol';

import "../interfaces/IERC20.sol";

contract CustomToken is SwapXPTStorage, IERC20  {
    using SafeMath for uint256;

    /*
     * Non-Standard Events
     */
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /*
     * Modifyiers
     */
    modifier onlyOwner() {
        require(isOwner(), "Caller is not the owner");
        _;
    }

    modifier onlyIssuer() {
        require(issuer[msg.sender], "The caller does not have issuer role privileges");
        _;
    }

    /**
      * @dev We don't set any data apart from the proxy address here, as we are in the
      * wrong context if deployed through the proxy.
      * @param initialSupply Initial token supply that is minted to the contract owner.
      */
    constructor (string memory name, string memory sym, uint initialSupply) public {
        _name = name;
        _symbol = sym;
        _decimals = 18;

        if (initialSupply >= 0) _mint(msg.sender, initialSupply);

        owner = msg.sender;
        issuer[msg.sender] = true;
    }

    /**
     * Checks if the caller of an transaction is the owner of the contract
     * @return true or false
     */
    function isOwner() public view returns (bool) {
        return msg.sender == owner;
    }

    /**
     * Allows the current contract owner to transfer ownership to a new address.
     * @param newOwner The new contract owner
     */
    function transferOwnership(address newOwner) external onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(owner, newOwner);
        owner = newOwner;
    }


    /**
     * Returns the name of the token
     */
    function name() external view returns (string memory) {
        return _name;
    }

    /**
     * Returns the symbol of the token
     */
    function symbol() external view returns (string memory) {
        return _symbol;
    }

    /**
     * Returns the number of decimals
     */
    function decimals() external view returns (uint8) {
        return _decimals;
    }

    /**
     * Returns the total supply.
     */
    function totalSupply() external view returns (uint256) {
        return _totalSupply;
    }

    /**
     * Returns the balance of an address.
     * @param account The address to check the balance of
     */
    function balanceOf(address account) public view returns (uint256) {
        return _balances[account];
    }

    /**
     * Transfers balance from the message sender to the recipient
     * @param recipient The address to send the balance to
     * @param amount The balance to transfer
     */
    function transfer(address recipient, uint256 amount) external returns (bool) {
        _transfer(msg.sender, recipient, amount);
        return true;
    }

    /**
     * Returns the allowance that the owner has given to a spender.
     * @param _owner The address that is giving the allowance.
     * @param spender The address that is granted the allowance.
     */
    function allowance(address _owner, address spender) external view returns (uint256) {
        return _allowances[_owner][spender];
    }

    /**
     * Grants an allowance to the spender.
     * @param spender The address that is granted the allowance.
     * @param value The amount that is granted to the spender.
     */
    function approve(address spender, uint256 value) external returns (bool) {
        _approve(msg.sender, spender, value);
        return true;
    }

    /**
     * Transfers balance from the address that has granted allowance.
     * @param sender The address that has granted the allowance.
     * @param recipient The address to transfer the balance to.
     * @param amount The amount that is transfered.
     */
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool) {
        //        require(!frozen[sender] && !frozen[recipient] && !frozen[msg.sender], "address frozen");
        _transfer(sender, recipient, amount);
        _approve(sender, msg.sender, _allowances[sender][msg.sender].sub(amount));
        return true;
    }

    /**
     * Increases the allowance to the spender.
     * @param spender The address that is granted the allowance.
     * @param addedValue The amount that is granted.
     */
    function increaseAllowance(address spender, uint256 addedValue) external returns (bool) {
        //        require(!frozen[spender] && !frozen[msg.sender], "address frozen");
        _approve(msg.sender, spender, _allowances[msg.sender][spender].add(addedValue));
        return true;
    }

    /**
     * Decreases the allowance to the spender.
     * @param spender The address that is granted the allowance.
     * @param subtractedValue The amount that is reduced.
     */
    function decreaseAllowance(address spender, uint256 subtractedValue) external returns (bool) {
        //        require(!frozen[spender] && !frozen[msg.sender], "address frozen");
        _approve(msg.sender, spender, _allowances[msg.sender][spender].sub(subtractedValue));
        return true;
    }

    /**
     * Allows an authorized issuer to isue new tokens
     * @param account The account to be credited
     * @param amount The balance to issue.
     */
    function issue(address account, uint256 amount) external onlyIssuer returns (bool) {
        _mint(account, amount);
        return true;
    }

    /**
     * Allows an authorized issuer to remove tokens from circulation
     * @param account The account that will have its balance reduced.
     * @param amount The balance to reduce.
     */
    function redeem(address account, uint256 amount) external onlyIssuer returns (bool) {
        _burn(account, amount);
        return true;
    }

    /**
    * @dev Adds a complianceRole address with specific regulatory compliance privileges.
    * @param _addr The address to be added
    */
    function addIssuer(address _addr) public onlyOwner returns (bool){
        require(_addr != address(0), "address cannot be 0");
        if(issuer[_addr] == false) {
            issuer[_addr] = true;
            return true;
        }
        return false;
    }

    /**
     * @dev Removes complianceRole address with specific regulatory compliance privileges.
     * @param _addr The address to be removed
     */
    function removeIssuer(address _addr) public onlyOwner returns (bool) {
        require(_addr != address(0), "address cannot be 0");
        if(issuer[_addr] == true) {
            issuer[_addr] = false;
            return true;
        }
        return false;
    }

    /*
     *Internal functions
     */

    /**
     * Transfers balance from the sender to the recipient.
     * @param sender The sender to reduce balance from
     * @param recipient The recipient to increase balance
     * @param amount The amount to transfer
     */
    function _transfer(address sender, address recipient, uint256 amount) internal {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

        _balances[sender] = _balances[sender].sub(amount);
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
    }

    /**
     * Increases the balance of the account.
     * @param account The account to increase balance from
     * @param amount The amount to mint
     */
    function _mint(address account, uint256 amount) internal {
        require(account != address(0), "ERC20: mint to the zero address");

        _totalSupply = _totalSupply.add(amount);
        _balances[account] = _balances[account].add(amount);
        emit Transfer(address(0), account, amount);
    }

    /**
     * Decreases the balance of the account.
     * @param account The account to increase balance from
     * @param value The amount to burn
     */
    function _burn(address account, uint256 value) internal {
        require(account != address(0), "ERC20: burn from the zero address");

        _totalSupply = _totalSupply.sub(value);
        _balances[account] = _balances[account].sub(value);
        emit Transfer(account, address(0), value);
    }

    /**
     * Sets the allowance of the owner and spender.
     * @param _owner The account to authorize from
     * @param value The amount to burn
     */
    function _approve(address _owner, address spender, uint256 value) internal {
        require(_owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[_owner][spender] = value;
        emit Approval(_owner, spender, value);
    }


    /**
     * Internal burn function to reduce account balance.
     * @param account The account to decrease balance from
     * @param amount The amount to burn
     */
    function _burnFrom(address account, uint256 amount) internal {
        _burn(account, amount);
        _approve(account, msg.sender, _allowances[account][msg.sender].sub(amount));
    }
}