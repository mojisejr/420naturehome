// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/Context.sol)

pragma solidity ^0.8.0;

/**
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}


// File @openzeppelin/contracts/access/Ownable.sol@v4.8.0

// OpenZeppelin Contracts (last updated v4.7.0) (access/Ownable.sol)

pragma solidity ^0.8.0;

/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * By default, the owner account will be the one that deploys the contract. This
 * can later be changed with {transferOwnership}.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be applied to your functions to restrict their use to
 * the owner.
 */
abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor() {
        _transferOwnership(_msgSender());
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        _checkOwner();
        _;
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if the sender is not the owner.
     */
    function _checkOwner() internal view virtual {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _transferOwnership(newOwner);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Internal function without access restriction.
     */
    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}


// File @openzeppelin/contracts/token/ERC20/IERC20.sol@v4.8.0

// OpenZeppelin Contracts (last updated v4.6.0) (token/ERC20/IERC20.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {
    /**
     * @dev Emitted when `value` tokens are moved from one account (`from`) to
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
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `to`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address to, uint256 amount) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address spender) external view returns (uint256);

    /**
     * @dev Sets `amount` as the allowance of `spender` over the caller's tokens.
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
     * @dev Moves `amount` tokens from `from` to `to` using the
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


// File contracts/PayWay420.sol

pragma solidity ^0.8.9;


contract PayWay420 is Ownable {

    enum Types {
        SATIVA,
        INDICA,
        HYBRID
    }

    enum Grades {
        B,
        A,
        AA,
        AAA,
        AAAA,
        S
    }

    struct Item {
        string name;
        Types types;
        uint256 ERC20price;
        uint256 price;
        uint8 stars;
        Grades grade;
        string description;
        string imageUrl;
        bool have;
    }

    struct Payment {
        Customer customer;
        uint256 itemId;
        uint256 paid;
        string memo;
        uint256 timestamp;
    }

    struct Customer {
        address wallet;
        uint256 discordId;
        string title;
        uint256 exp;
        bool active;
        bool registered;
        uint256 paymentCount;
    }

    IERC20 token;
    mapping(address => Customer) customers;
    mapping(uint256 => Payment) payments;
    mapping(uint256 => Item) items;

    uint256 currentPaymentId = 0;
    uint256 currentItemId = 0;
    address[] customerAddr;

    constructor(IERC20 _token) {
        token = _token;
    }

    function getCurrentPaymentId() public view returns(uint256) {
        return currentPaymentId + 1;
    }

    function getCurrentItemId() public view returns(uint256) {
        return currentItemId + 1;
        
    }

    function _increasePaymentId() internal {
        currentPaymentId += 1;
    }

    function _increaseItemId() internal {
        currentItemId += 1;
    }

    function register(uint256 _discordId) public {
        require(!customers[msg.sender].registered, "register: this wallet already registered");
        require(customers[msg.sender].discordId != _discordId, "register: this discordId already used");

        customers[msg.sender].discordId = _discordId;
        customers[msg.sender].wallet = msg.sender;
        customers[msg.sender].title = "CanabisBoy";
        customers[msg.sender].exp = 0;
        customers[msg.sender].active = true;
        customers[msg.sender].registered = true;
        customerAddr.push(msg.sender);
    }

    function payWithERC20 (uint256 itemId, uint256 _discordId, uint256 _amounts, uint256 g, string memory _memo)  public {

        require(customers[msg.sender].discordId == _discordId, "pay: invalid discordId");
        require(customers[msg.sender].wallet == msg.sender, "pay: invlaid wallet");
        require(_amounts > 0, "pay: invalid amounts");

        uint256 price = items[itemId].ERC20price;
        uint256 amountsToPay = price * g;
        require(amountsToPay == _amounts, "pay: invalid amount to pay");

        uint256 currentId = getCurrentPaymentId();
        token.transferFrom(msg.sender, address(this), _amounts);

        payments[currentId].customer = customers[msg.sender];
        payments[currentId].itemId = itemId;
        payments[currentId].paid = _amounts;
        payments[currentId].memo = _memo;
        payments[currentId].timestamp = block.timestamp;

        customers[msg.sender].paymentCount += 1;
        customers[msg.sender].exp += g;

        _increasePaymentId();
    }

    function pay (uint256 itemId, uint256 _discordId, uint256 g, string memory _memo)  public payable {

        require(customers[msg.sender].discordId == _discordId, "pay: invalid discordId");
        require(customers[msg.sender].wallet == msg.sender, "pay: invlaid wallet");
        require(msg.value > 0, "pay: invalid amounts");

        uint256 price = items[itemId].price;
        uint256 amountsToPay = price * g;
        require(amountsToPay == msg.value, "pay: invalid amount to pay");

        uint256 currentId = getCurrentPaymentId();

        (bool sent, bytes memory data) = address(this).call{value: msg.value}("");
        require(sent, "pay: payment error.");



        payments[currentId].customer = customers[msg.sender];
        payments[currentId].itemId = itemId;
        payments[currentId].paid = msg.value;
        payments[currentId].memo = _memo;
        payments[currentId].timestamp = block.timestamp;

        customers[msg.sender].paymentCount += 1;
        customers[msg.sender].exp += g;

        _increasePaymentId();
    }

//          string name;
//         Types types;
//         uint256 ERC20price;
//         uint256 price;
//         uint8 stars;
//         Grades grade;
//         string description;
//         bool have;
    function addItem(string memory _name, uint256 _type, uint256 _ERC20price, uint256 _price, uint8 _stars, uint256 _grade, string memory _desc, string memory _imageUrl, bool _have) public onlyOwner {
        uint256 itemId = getCurrentItemId();
        items[itemId].name = _name;
        items[itemId].types = Types(_type);
        items[itemId].ERC20price = _ERC20price;
        items[itemId].price = _price;
        items[itemId].stars = _stars;
        items[itemId].grade = Grades(_grade);
        items[itemId].imageUrl = _imageUrl;
        items[itemId].description = _desc;
        items[itemId].have = _have;
        _increaseItemId();
    }

    function getAmountsEthToPay(uint256 _itemId, uint256 g) public view returns(uint256) {
        uint256 price = items[_itemId].price;
        return price * g;
    }

    function getAmountsERC20ToPay(uint256 _itemId, uint256 g) public view returns(uint256) {
        uint256 price = items[_itemId].ERC20price;
        return price * g;
    }

    function getCustomerByWallet(address _wallet) public view returns(Customer memory) {
        return customers[_wallet];
    }

    function getAllCustomers() public view returns(Customer[] memory) {
        uint256 customerLen = customerAddr.length;
        Customer[] memory list = new Customer[](customerLen);
        require(customerLen > 0, "getAllCustomers: no customer");
        for(uint256 i = 1; i < customerLen; i++) {
            list[i] = customers[customerAddr[i]];
        }

        return list;
    }

    function getPaymentOf(address _wallet) public view returns(Payment[] memory) {
        uint256 totalPayments = customers[_wallet].paymentCount;
        Payment[] memory list = new Payment[](totalPayments);
        for(uint256 i = 0; i < totalPayments; i++){
            if(payments[i].customer.wallet == _wallet) {
                list[i] = payments[i];
            }
        }

        return list;
    }

    function getAllPayments() public view onlyOwner returns(Payment[] memory) {
        uint256 totalPayments = getCurrentPaymentId();
        Payment[] memory list = new Payment[](totalPayments);
        require(currentPaymentId > 0, "getAllPayments: no payment");
        for(uint256 i = 1; i < totalPayments; i++) {
            list[i] = payments[i];
        }

        return list;
    }

    function getAllItems() public view onlyOwner returns(Item[] memory) {
        uint256 totalItems = getCurrentItemId();
        Item[] memory list = new Item[](totalItems);
        require(currentItemId > 0, "getAllItems: no item");
        for(uint256 i = 1; i < totalItems; i++) {
            list[i] = items[i];
        }

        return list;
    }

    function setActive(address _wallet, bool _value) public onlyOwner {
        customers[_wallet].active = _value;
    }

    function getBalance() public view returns(uint256) {
        return address(this).balance;
    }

    function getERC20Balance() public view returns(uint256) {
        return token.balanceOf(address(this));
    }

    function withdrawERC20(address _to) public onlyOwner {
        token.transferFrom(address(this), _to, token.balanceOf(address(this)));
    }

    function withdraw(address _to) public onlyOwner {
        (bool sent, bytes memory data) = _to.call{value: address(this).balance}("");
        require(sent, 'withdraw failed.');
    }

    receive() external payable {}
}
