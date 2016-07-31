
require 'csv_to_popolo'
require 'minitest/autorun'
require 'pry'
require 'json'

describe 'monaco' do
  subject { Popolo::CSV.new('t/data/uganda.csv') }

  def memberships(id)
    subject.data[:memberships].select { |m| m[:person_id] == id }
  end

  it 'should have no Post for a normal membership' do
    alero = memberships('mp_277').first
    alero[:post_id].must_be_nil
    alero[:area_id].must_equal 'area/west_moyo'
  end

  it 'should have a Woman Representative post with an Area' do
    ameede = memberships('mp_292').first
    ameede[:post_id].must_equal 'woman_representative'
    ameede[:area_id].must_equal 'area/pallisa'
  end

  it 'should have a PWD post with no Area' do
    ndeezi = memberships('mp_419').first
    ndeezi[:post_id].must_equal 'pwd'
    ndeezi[:area_id].must_be_nil
  end

  it 'should have two Posts' do
    posts = subject.data[:posts].sort_by { |p| p[:id] }
    posts.count.must_equal 2
    posts.first[:id].must_equal 'pwd'
    posts.first[:label].must_equal 'PWD'
    posts.first[:organization_id].must_equal 'legislature'

    posts.last[:id].must_equal 'woman_representative'
    posts.last[:label].must_equal 'Woman Representative'
  end

  it 'should have no warnings' do
    subject.data[:warnings].must_be_nil
  end
end
