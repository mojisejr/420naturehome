//SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";


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
    uint256 customerCount = 0;

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
        customerCount++;
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

    function getAmountsToPay(uint256 _itemId, uint256 g) public view returns(uint256) {
        uint256 price = items[_itemId].price;
        return price * g;
    }

    function getCustomerByWallet(address _wallet) public view returns(Customer memory) {
        return customers[_wallet];
    }

    function getAllCustomers() public view returns(Customer[] memory) {

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