$:.unshift File.join(File.dirname(__FILE__), '.')
require 'rubygems'
# require 'example'

require 'sinatra'
require 'haml'
require 'sass'

require 'git'

configure do
  set :port, 80
end

get '/styles.css' do
  sass :styles
end

get '/jquery.js' do
  File.read('public/jquery-1.7.2.min.js')
end

get '/jquery.pjax.js' do
  File.read('public/jquery.pjax.js')
end

get '/pjax.js' do
  File.read('public/pjax.jx')
end

get '/' do
  @lines = []
  @lines = Git::cmd_prevlog.split("\n")
  haml :index
end

get '/1' do
  if params[:_pjax].nil? or params[:_pjax] == ""
    @partial = :first
    haml :default_layout
  else
    haml :first
  end
end



#get '/' do
#  @v = 1
#  haml :index
#  e = Example::Example.new
#  e.toUpper('aaa bbb ccc')
#end



