require 'csv_to_popolo'
require 'minitest/autorun'

describe 'Puerto Rico' do
  subject { Popolo::CSV.new('t/data/puerto-rico.csv') }
  let(:contact_details) { member[:contact_details] }
  let(:tty) { contact_details.find { |contact| contact[:type] == 'tty' } }

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
