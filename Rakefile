
require 'rake/testtask'

Rake::TestTask.new do |t|
  t.warning = true
  t.verbose = true
  t.test_files = FileList['t/*.rb']
end

Rake::TestTask.new do |t|
  t.name = 'test:validation'
  t.verbose = true
  t.test_files = FileList['t/full/*.rb']
end

Rake::TestTask.new do |t|
  t.name = 'test:all'
  t.verbose = true
  t.test_files = FileList['t/**/*.rb']
end
