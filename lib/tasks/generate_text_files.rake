# ./lib/tasks/generate_text_files.rake

require 'faker'

ROOTDIR = File.expand_path('../..', __dir__)

desc 'Create a new document of a determinate size and populate it with fake data'
task :generate_data, [:size] do |t, args|
  args.with_defaults(size: 10)
  file_size = args[:size].to_i * 1024 * 1024

  filename = "sample_data_#{args.size}mb.txt"
  filepath = File.join(ROOTDIR, 'data', filename)

  File.open(filepath, 'w', encoding: 'ASCII-8BIT') do |file|
    bytes_in_file = 0
    line_count = 0

    while bytes_in_file < file_size
      line = "#{line_count} - #{Faker::Lorem.paragraph_by_chars(number: 120)}\n"
      file.write(line)
      bytes_in_file += line.bytesize
      line_count += 1
    end
  end

  puts "File generated with the size of #{File.size(filepath)} bytes at #{filepath}"
end
