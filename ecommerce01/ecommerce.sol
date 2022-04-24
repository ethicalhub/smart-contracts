//SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.5.0 <0.9.0;


contract ECommerce{

    struct Product{
        string title;
        string desc;
        uint price;
        uint productID;
        bool delivered;
        address payable seller;
        address buyer;
    }

    address payable public manager;
    bool destroyed = false;
    uint count = 1;
    Product[] public products;

    event registered(string title, uint productID, address payable seller);
    event bought(uint productID, address Buyers);
    event delivered(uint productID);

    modifier isNotDestroyed{
        require(!destroyed, "Contract Does Not Exist");
        _;
    }

    constructor(){
        manager = payable(msg.sender);
    }


    function registerProduct(
        string memory _title,
        string memory _desc,
        uint _price
        ) public isNotDestroyed{
            require(_price >0 , "Price must be greater than 0, not free");

            Product memory newProduct;
            newProduct.title = _title;
            newProduct.desc = _desc;
            newProduct.price = _price * 10**18;
            newProduct.productID = count;
            newProduct.seller = payable(msg.sender);
            products.push(newProduct);
            count++;
            emit registered(_title, newProduct.productID, payable(msg.sender));
    }

    function buy(uint _productID) payable public isNotDestroyed{
        require(products[_productID-1].price == msg.value, "Send the exact price only");
        require(products[_productID-1].seller != msg.sender, "Sender cannot be the buyer");

        products[_productID-1].buyer = msg.sender;
        emit bought(_productID, msg.sender );
    }

    function delivery(uint _productID) public isNotDestroyed{
        require(products[_productID-1].buyer == msg.sender , "Only Buyers are allowed to verify delivery");
        products[_productID-1].delivered = true;
        products[_productID-1].seller.transfer(products[_productID-1].price);
        emit delivered(_productID);
    }

    // function destroy() public{
    //     require(msg.sender == manager , "Only Manager can destroy the contract");
    //     selfdestruct(manager);
    // }
    // @@@ above function has many issue, ether could be lost

    function destroy1() public isNotDestroyed{
        require(msg.sender == manager , "Only Manager can destroy the contract");
        manager.transfer(address(this).balance);
        destroyed = true;
    }

    function getBalance() public view returns(uint)  {
        return address(this).balance;
    }

    fallback() payable external{
        payable(msg.sender).transfer(msg.value);
    }
}
