# frozen_string_literal: true

require 'rake/testtask'

task default: :test

Rake.add_rakelib 'lib/tasks'

Rake::TestTask.new do |t|
  t.libs << 'test'
  t.test_files = FileList['test/test*.rb']
  t.verbose = true
end
