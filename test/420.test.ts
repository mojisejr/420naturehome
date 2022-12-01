import { expect } from "chai";
import { ethers } from "hardhat";
import { isGeneratorFunction } from "util/types";
import { contracts } from "../typechain-types";

describe("PayWay Contract test", async () => {
  async function deploy() {
    const [dev, w1, w2, w3] = await ethers.getSigners();
    const tfac = await ethers.getContractFactory("MyToken");
    const token = await tfac
      .connect(dev)
      .deploy(w1.address, w2.address, w3.address);
    await token.deployed();
    const fac = await ethers.getContractFactory("PayWay420");
    const contract = await fac.connect(dev).deploy(token.address);
    await contract.deployed();

    const w1Discord = 1111;
    const w2Discord = 2222;
    const w3Discord = 3333;

    await contract.connect(w1).register(w1Discord);
    await contract.connect(w2).register(w2Discord);
    await contract.connect(w3).register(w3Discord);

    const items = [
      {
        name: "Gorllia",
        types: 0,
        ERC20price: 10000,
        price: ethers.utils.parseUnits("3", "ether"),
        stars: 1,
        grade: 1,
        description: "Level 1",
        imageUrl: "",
        have: true,
      },
      {
        name: "Blue Dream",
        types: 1,
        ERC20price: 20000,
        price: ethers.utils.parseUnits("2", "ether"),
        stars: 2,
        grade: 2,
        description: "Level 2",
        imageUrl: "",
        have: true,
      },
    ];

    await contract
      .connect(dev)
      .addItem(
        items[0].name,
        items[0].types,
        items[0].ERC20price,
        items[0].price,
        items[0].grade,
        items[0].stars,
        items[0].description,
        items[0].imageUrl,
        items[0].have
      );
    await contract
      .connect(dev)
      .addItem(
        items[1].name,
        items[1].types,
        items[1].ERC20price,
        items[1].price,
        items[1].grade,
        items[1].stars,
        items[1].description,
        items[1].imageUrl,
        items[1].have
      );

    return {
      dev,
      w1,
      w2,
      w3,
      token,
      contract,
      items,
    };
  }

  // string name;
  // Types types;
  // uint256 ERC20price;
  // uint256 price;
  // uint8 stars;
  // Grades grade;
  // string description;
  // string imageUrl;
  // bool have;

  it("should be able to add item", async () => {
    const { dev, w1, w2, w3, token, contract } = await deploy();

    const items = [
      {
        name: "Gorllia",
        types: 0,
        ERC20price: 10000,
        price: 3,
        stars: 1,
        grade: 1,
        description: "Level 1",
        imageUrl: "",
        have: true,
      },
      {
        name: "Blue Dream",
        types: 1,
        ERC20price: 20000,
        price: 5,
        stars: 2,
        grade: 2,
        description: "Level 2",
        imageUrl: "",
        have: true,
      },
    ];

    await contract
      .connect(dev)
      .addItem(
        items[0].name,
        items[0].types,
        items[0].ERC20price,
        items[0].price,
        items[0].grade,
        items[0].stars,
        items[0].description,
        items[0].imageUrl,
        items[0].have
      );
    await contract
      .connect(dev)
      .addItem(
        items[1].name,
        items[1].types,
        items[1].ERC20price,
        items[1].price,
        items[1].grade,
        items[1].stars,
        items[1].description,
        items[1].imageUrl,
        items[1].have
      );

    const currentId = await contract.getCurrentItemId();
    expect(currentId.toString()).to.equal("5");
  });

  it("should be able to pay with ERC20", async () => {
    const { dev, w1, w2, w3, token, contract, items } = await deploy();

    await token.connect(w1).approve(contract.address, items[0].ERC20price);
    await contract
      .connect(w1)
      .payWithERC20(1, 1111, items[0].ERC20price, 1, "need packing");

    const balance = await contract.getERC20Balance();
    expect(balance.toString()).to.equal(items[0].ERC20price.toString());
  });

  it("should be able to pay with Ether", async () => {
    const { dev, w1, w2, w3, token, contract, items } = await deploy();

    await contract.connect(w1).pay(1, 1111, 1, "need packing", {
      value: items[0].price,
    });

    const balance = await contract.getBalance();
    expect(balance.toString()).to.equal(items[0].price.toString());
  });

  it("should be able to get All Item List", async () => {
    const { dev, w1, w2, w3, token, contract, items } = await deploy();

    const list = await contract.getAllCustomers();
    expect(list.length).greaterThan(0);
  });

  it("should be able to get All Payment List", async () => {
    const { dev, w1, w2, w3, token, contract, items } = await deploy();

    await token.connect(w1).approve(contract.address, items[0].ERC20price);
    await contract
      .connect(w1)
      .payWithERC20(1, 1111, items[0].ERC20price, 1, "need packing");

    await token.connect(w2).approve(contract.address, items[0].ERC20price);
    await contract
      .connect(w2)
      .payWithERC20(1, 2222, items[0].ERC20price, 1, "need packing");

    await token.connect(w1).approve(contract.address, items[0].ERC20price);
    await contract
      .connect(w1)
      .payWithERC20(1, 1111, items[0].ERC20price, 1, "need packing");

    await token.connect(w3).approve(contract.address, items[0].ERC20price);
    await contract
      .connect(w3)
      .payWithERC20(1, 3333, items[0].ERC20price, 1, "need packing");

    const list = await contract.getAllPayments();
    expect(list.length).greaterThan(0);
  });

  it("should get all payments of specific wallet", async () => {
    const { dev, w1, w2, w3, token, contract, items } = await deploy();

    await token.connect(w1).approve(contract.address, items[0].ERC20price);
    await contract
      .connect(w1)
      .payWithERC20(1, 1111, items[0].ERC20price, 1, "need packing");

    await token.connect(w2).approve(contract.address, items[0].ERC20price);
    await contract
      .connect(w2)
      .payWithERC20(1, 2222, items[0].ERC20price, 1, "need packing");

    await token.connect(w1).approve(contract.address, items[0].ERC20price);
    await contract
      .connect(w1)
      .payWithERC20(1, 1111, items[0].ERC20price, 1, "need packing");

    const payments = await contract.getPaymentOf(w1.address);
    expect(payments.length).to.equal(2);
  });

  it("should be able to get  All Customer List", async () => {
    const { dev, w1, w2, w3, token, contract, items } = await deploy();
    const list = await contract.getAllItems();
    expect(list.length).greaterThan(0);
  });

  it("should get item by id", async () => {
    const { dev, w1, w2, w3, token, contract, items } = await deploy();
    const item = await contract.getItemsById(1);
    expect(item[0].toString()).to.equal("Gorllia");
  });
});
