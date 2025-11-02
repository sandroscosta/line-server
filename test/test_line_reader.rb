# frozen_string_literal: true

require 'minitest/autorun'
require_relative '../lib/line_reader/line_reader'

class LineReaderTest < Minitest::Test
  def setup
    @temp_file = Tempfile.new('test_file')
    5.times { |idx| @temp_file.write("Line #{idx + 1}\n") }
    @temp_file.close

    @reader = LineReader.new(@temp_file.path)
  end

  def teardown
    @temp_file.unlink
  end

  # Initialization tests
  def test_initialize_creates_instance
    assert_instance_of LineReader, @reader
  end

  def test_initialize_with_nonexistent_file
    assert_raises Errno::ENOENT do
      LineReader.new('/link/to/fake/directory/file.txt')
    end
  end

  # Line count tests
  def test_line_count_returns_correct_number
    assert_equal 5, @reader.line_count
  end

  def test_line_count_with_empty_file
    temp_file = Tempfile.new('empty')
    temp_file.close
    reader = LineReader.new(temp_file.path)

    assert_equal 0, reader.line_count
  ensure
    temp_file.unlink
  end

  def test_line_count_with_single_line
    temp_file = Tempfile.new('single_line')
    temp_file.write('Single line')
    temp_file.close
    reader = LineReader.new(temp_file.path)

    assert_equal 1, reader.line_count
  ensure
    temp_file.unlink
  end

  # Get line tests
  def test_get_line_returns_first_line
    assert_equal 'Line 1', @reader.get_line(0)
  end

  def test_get_line_returns_last_line
    assert_equal 'Line 5', @reader.get_line(4)
  end

  def test_get_line_with_negative_index
    assert_nil @reader.get_line(-1)
    assert_nil @reader.get_line(-5)
  end

  def test_get_line_with_out_of_bounds_index
    assert_nil @reader.get_line(5)
    assert_nil @reader.get_line(100)
  end

  def test_get_line_with_zero_index_is_valid
    refute_nil @reader.get_line(0)
  end

  # Empty file cases
  def test_get_line_on_empty_file
    temp_file = Tempfile.new('empty')
    temp_file.close
    reader = LineReader.new(temp_file.path)

    assert_nil reader.get_line(0)
  ensure
    temp_file.unlink
  end

  def test_get_line_removes_trailing_newline
    line = @reader.get_line(0)
    refute_match '/\n$/', line
  end

  def test_get_line_handles_lines_with_spaces
    temp_file = Tempfile.new('spaces')
    temp_file.write("  Leading spaces\n")
    temp_file.write("Trailing spaces  \n")
    temp_file.write("Mixed  spaces  inside\n")
    temp_file.close
    reader = LineReader.new(temp_file.path)

    assert_equal "  Leading spaces", reader.get_line(0)
    assert_equal "Trailing spaces  ", reader.get_line(1)
    assert_equal "Mixed  spaces  inside", reader.get_line(2)
  ensure
    temp_file.unlink
  end

  def test_get_line_handles_empty_lines
    temp_file = Tempfile.new('empty_lines')
    temp_file.write("First line\n")
    temp_file.write("\n")
    temp_file.write("Third line\n")
    temp_file.close
    reader = LineReader.new(temp_file.path)

    assert_equal "First line", reader.get_line(0)
    assert_equal "", reader.get_line(1)
    assert_equal "Third line", reader.get_line(2)
  ensure
    temp_file.unlink
  end

  def test_get_line_handles_special_characters
    temp_file = Tempfile.new('special_chars')
    temp_file.write("Line with @#$% special chars\n")
    temp_file.write("Line with symbols !@#$%^&*()\n")
    temp_file.close
    reader = LineReader.new(temp_file.path)

    assert_equal "Line with @#$% special chars", reader.get_line(0)
    assert_equal "Line with symbols !@#$%^&*()", reader.get_line(1)
  ensure
    temp_file.unlink
  end

  def test_get_line_handles_long_lines
    temp_file = Tempfile.new('long_lines')
    long_line = 'a' * 10_000
    temp_file.write("#{long_line}\n")
    temp_file.close
    reader = LineReader.new(temp_file.path)

    assert_equal long_line, reader.get_line(0)
  ensure
    temp_file.unlink
  end

  def test_can_read_multiple_lines_in_random_order
    assert_equal "Line 5", @reader.get_line(4)
    assert_equal "Line 1", @reader.get_line(0)
    assert_equal "Line 3", @reader.get_line(2)
  end

  def test_handles_windows_line_endings
    temp_file = Tempfile.new('windows_endings')
    temp_file.write("Line 1\r\n")
    temp_file.write("Line 2\r\n")
    temp_file.write("Line 3")
    temp_file.close
    reader = LineReader.new(temp_file.path)

    line = reader.get_line(0)
    assert line.include?("Line 1")
  ensure
    temp_file.unlink
  end
end
