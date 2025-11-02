# frozen_string_literal: true

require 'dotenv/load'
require 'sinatra'
require 'json'
require_relative 'line_reader/line_reader'

Dotenv.load

FILE_PATH = File.join(__dir__, '..', ENV['SOURCE_FILE'])

# The file is loaded on the application load time
# File index is built after the file is loaded
LINE_READER = LineReader.new(FILE_PATH)

get '/' do
  'To access the API, use the following URLs: http://localhost:3000/lines/1'
end

get '/healthcheck' do
  {status: 'ok'}.to_json
end

get '/lines/:index' do
  content_type 'application/json'
  # index will always be a number when converted to integer
  index = params['index'].to_i

  if index.negative? || index > LINE_READER.line_count
    status 413
    return {
      index: index,
      line_count: LINE_READER.line_count,
      error: 'Line index out of bounds'
    }.to_json
  end

  {
    index: index,
    line_count: LINE_READER.line_count,
    line: LINE_READER.get_line(index)
  }.to_json
end
