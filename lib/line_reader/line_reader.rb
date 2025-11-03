# frozen_string_literal: true

# Reads line from a file, creating a index by line for easy access
class LineReader
  ##
  # Creates a new LineReader instance
  #
  # @param +filepath+ [String] The path to the file to read
  # @return [LineReader] A new LineReader instance
  def initialize(filepath)
    @filepath = filepath
    @file_index = build_index
  end

  def get_line(index)
    return nil if index.negative? || index >= @file_index.length

    # Read the specific line using the precomputed offset
    start_offset = @file_index[index]

    # Read file from the offset in a binary-safe manner
    File.open(@filepath, 'rb') do |file|
      file.seek(start_offset)
      line = file.gets("\n")
      line&.chomp("\n")
    end
  end

  def line_count
    @file_index.length
  end

  private

  def build_index
    # this creates an enumerator that yields the byte offset of each line start
    offset_enumerator = Enumerator.new do |yielder|
      File.open(@filepath, 'rb') do |file|
        until file.eof?
          yielder.yield(file.pos)
          file.gets("\n")
        end
      end
    end

    offset_enumerator.to_a
  end
end
