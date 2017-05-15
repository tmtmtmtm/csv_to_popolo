require 'csv_to_popolo'
require 'minitest/autorun'

describe 'Puerto Rico' do
  let(:contact_details) { member[:contact_details] }
  let(:tty) { contact_details.find { |contact| contact[:type] == 'tty' } }

  describe 'Source data with TTY column' do
    subject { Popolo::CSV.new('t/data/puerto-rico.csv') }

    describe 'Member with TTY info' do
      let(:member) { subject.data[:persons].first }
      it 'handles a member’s TTY contact number' do
        tty[:value].must_equal '(787) 721-1109'
      end
    end

    describe 'Member without TTY info' do
      let(:member) { subject.data[:persons].last }
      it 'returns nil for TTY' do
        tty.must_be_nil
      end
    end
  end

  describe 'Source data with TDD column' do
    subject { Popolo::CSV.new('t/data/puerto-rico-tdd.csv') }

    describe 'Member with TDD info' do
      let(:member) { subject.data[:persons].first }
      it 'handles member’s TDD column as a TTY number' do
        tty[:value].must_equal '(787) 721-1109'
      end
    end

    describe 'Member without TDD info' do
      let(:member) { subject.data[:persons].last }
      it 'returns nil for TTY' do
        tty.must_be_nil
      end
    end
  end
end
