require './accounts'

describe 'Accounts' do
  let(:account) { Account.new }

  it "allows reading and writing for :name" do
    account.name = 'Test'
    expect(account.name).to eq('Test')
  end

  it "allows reading and writing for :balance" do
    account.balance = 9999
    expect(account.balance).to eq(9999)
  end

  it "allows reading and writing for :currency" do
    account.currency = 'EUR'
    expect(account.currency).to eq('EUR')
  end

  it "allows reading and writing for :nature" do
    account.nature = 'EUR'
    expect(account.nature).to eq('EUR')
  end

  it "allows reading and writing for :transactions" do
    account.transactions = [1,2,3]
    expect(account.transactions).to eq([1,2,3])
  end

end


#:balance, :currency, :nature, :transactions
