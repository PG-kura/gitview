require 'sinatra'
$:.unshift File.join(File.dirname(__FILE__), '.')
require 'example'

configure do
  set :port, 3000
end

get '/hi' do
  e = Example::Example.new
  e.toUpper('aaa bbb ccc')
end

