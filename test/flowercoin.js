const FlowerCoin = artifacts.require("FlowerCoin.sol");

contract("FlowerCoin", () => {
  it("Should have 10000 coins in the minter", async () => {
    const FlowerCoinInstance = await FlowerCoin.new();
    const minter = await FlowerCoinInstance.minter();
    console.log(minter);

    const balance = await FlowerCoinInstance.balanceOf(minter);
    assert.equal(
      balance.toNumber(),
      100000,
      "100000 wasn't in the first account"
    );
  });
  it("should send coin correctly", async () => {
    const FlowerCoinInstance = await FlowerCoin.new();
    const minter = await FlowerCoinInstance.minter();

    // Setup 2 accounts.
    // 99ba9865b29c9a47b5a7328c8a4572b4bf837fae74ba0d8a840da1fb91b6bcb3
    // and 5019483426d213c025c2d2bf9144b6aaa87bde168a1b4856e035b67a2c41d8c7
    accounts = [
      "0x78c1233c6771c4b5397643dd97b6a8712b7dc89e",
      "0x182be3f3f7874d95901ee7e6a5be46e72560c10f",
    ];
    const accountOne = accounts[0];
    const accountTwo = accounts[1];

    // Get initial balances of first and second account.
    const accountOneStartingBalance = (
      await FlowerCoinInstance.balanceOf(accountOne)
    ).toNumber();

    // Mint 10 to accountOne
    const amount = 10000;
    await FlowerCoinInstance.mint(accountOne, amount, { from: minter });

    const accountOneMintedBalance = (
      await FlowerCoinInstance.balanceOf(accountOne)
    ).toNumber();

    assert.equal(
      accountOneMintedBalance,
      amount,
      "amount wasn't in the first account"
    );

    const accountTwoStartingBalance = (
      await FlowerCoinInstance.balanceOf(accountTwo)
    ).toNumber();

    await FlowerCoinInstance.transfer(accountTwo, amount, { from: accountOne });
    // Get balances of first and second account after the transactions.
    const accountOneEndingBalance = (
      await FlowerCoinInstance.balanceOf(accountOne)
    ).toNumber();
    const accountTwoEndingBalance = (
      await FlowerCoinInstance.balanceOf(accountTwo)
    ).toNumber();

    console.log(accountOneEndingBalance);
    console.log(accountTwoEndingBalance);

    assert.equal(
      accountTwoEndingBalance,
      accountTwoStartingBalance + amount,
      "Amount wasn't correctly sent to the receiver"
    );
    assert.equal(
      accountOneEndingBalance,
      accountOneMintedBalance - amount,
      "Amount wasn't correctly taken from the sender"
    );
  });
});
