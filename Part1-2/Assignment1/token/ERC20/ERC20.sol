// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./IERC20.sol";
import "./extensions/IERC20Metadata.sol";
import "./utils/Context.sol";

/**
 * @dev Implementation of the {IERC20} interface.
 *
 * This implementation is agnostic to the way tokens are created. This means
 * that a supply mechanism has to be added in a derived contract using {_mint}.
 * For a generic mechanism see {ERC20PresetMinterPauser}.
 *
 * TIP: For a detailed writeup see our guide
 * https://forum.openzeppelin.com/t/how-to-implement-erc20-supply-mechanisms/226[How
 * to implement supply mechanisms].
 *
 * The default value of {decimals} is 18. To change this, you should override
 * this function so it returns a different value.
 *
 * We have followed general OpenZeppelin Contracts guidelines: functions revert
 * instead returning `false` on failure. This behavior is nonetheless
 * conventional and does not conflict with the expectations of ERC20
 * applications.
 *
 * Additionally, an {Approval} event is emitted on calls to {transferFrom}.
 * This allows applications to reconstruct the allowance for all accounts just
 * by listening to said events. Other implementations of the EIP may not emit
 * these events, as it isn't required by the specification.
 *
 * Finally, the non-standard {decreaseAllowance} and {increaseAllowance}
 * functions have been added to mitigate the well-known issues around setting
 * allowances. See {IERC20-approve}.
 */
contract ERC20 is Context, IERC20, IERC20Metadata {
    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;

    uint256 private _totalSupply;
    string private _name;
    string private _symbol;

    modifier isValidAddress(address account) {
        require(account != address(0), "is Zero Address");
        _;
    }

    modifier isAllValidAddress(address accountA, address accountB) {
        require(accountA != address(0), "is Zero Address");
        require(accountB != address(0), "is Zero Address");
        _;
    }

    function name() external view virtual override returns (string memory) {
        return _name;
    }

    function symbol() external view virtual override returns (string memory) {
        return _symbol;
    }

    function decimals() external view virtual override returns (uint8) {
        return 18;
    }

    function totalSupply() external view returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address account) external view returns (uint256) {
        return _balances[account];
    }

    function _transfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual isAllValidAddress(from, to) {
        uint256 senderBalance = _balances[from];

        // 검증 과정을 생략하고 연산
        unchecked {
            _balances[from] = senderBalance - amount;
            _balances[to] += amount;
        }

        emit Transfer(from, to, amount);
    }

    function _mint(
        address account,
        uint256 amount
    ) internal virtual isValidAddress(account) {
        _totalSupply += amount;
        _balances[account] += amount;
    }

    function _burn(
        address account,
        uint256 amount
    ) internal virtual isValidAddress(account) {
        unchecked {
            _balances[account] -= amount;
        }
        _totalSupply -= amount;
    }

    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual isAllValidAddress(owner, spender) {
        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _spendAllowance(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual isAllValidAddress(owner, spender) {
        uint256 ownerAllowance = _allowances[owner][spender];

        _allowances[owner][spender] = ownerAllowance - amount;
    }

    function transfer(
        address recipient,
        uint256 amount
    ) external virtual override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    function allowance(
        address owner,
        address spender
    ) external view virtual override returns (uint256) {
        return _allowances[owner][spender];
    }

    function approve(
        address spender,
        uint256 amount
    ) external virtual override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external virtual override returns (bool) {
        _spendAllowance(sender, _msgSender(), amount);
        _transfer(sender, recipient, amount);
        return true;
    }

    function increaseAllowance(
        address spender,
        uint256 addedValue
    ) external virtual returns (bool) {
        _approve(
            _msgSender(),
            spender,
            _allowances[_msgSender()][spender] + addedValue
        );
        return true;
    }

    function decreaseAllowance(
        address spender,
        uint256 subtractedValue
    ) external virtual returns (bool) {
        _approve(
            _msgSender(),
            spender,
            _allowances[_msgSender()][spender] - subtractedValue
        );
        return true;
    }
}
