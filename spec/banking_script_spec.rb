require './MicbBanking'

describe MicbBanking do
  let(:subject) { MicbBanking.new }

  context 'testing accounts page' do
    let(:html) { IO.read("spec/accounts.html") }
    it '#get_accounts' do
      subject.send(:get_accounts, html)
      expect(subject.accounts.length).to eq 2
      expect(subject.accounts[0].name).to eq('2259A3613041')
      expect(subject.accounts[0].balance).to eq('-2,64')
      expect(subject.accounts[0].currency).to eq('USD')
      expect(subject.accounts[0].nature).to eq('Carduri și conturi')
    end
  end

  context 'testing transactions page' do
    let(:html) {IO.read("spec/transactions1.html")}
    it "#get_transactions_from_html" do
      result = subject.send(:get_transactions_from_html, html)
      expect(result.length).to eq 3
      expect(result[0].date).to eq '16:22 31 martie 2019'
      expect(result[0].description).to eq('RF: Taxa lunara deservire cont')
      expect(result[0].amount).to eq "0,29"
      expect(result[0].currency).to eq "USD"
    end
  end

end
