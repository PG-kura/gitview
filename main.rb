$:.unshift File.join(File.dirname(__FILE__), '.')
require 'rubygems'
require 'enumerator'
require 'sinatra'
require 'haml'
require 'sass'

require 'git'

configure :development do
  set :port, 3000
end

configure :production do
  set :port, 80
end

def is_pjax?()
  !(params[:_pjax].nil? or params[:_pjax] == "")
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

not_found do
  if is_pjax?
    haml :not_found
  else
    @partial = :not_found
    haml :default_layout
  end
end

get '/' do
  @commits = []
  Git::cmd_log_10.split("\n").each_slice(6) do |lines|
    @commits << Git::parse_commit(lines)
  end
 
  if is_pjax?
    haml :log_10
  else
    @partial = :log_10
    haml :default_layout
  end
end

get '/1' do
  if is_pjax?
    haml :first
  else
    @partial = :first
    haml :default_layout
  end
end




# require 'example'
#get '/' do
#  @v = 1
#  haml :index
#  e = Example::Example.new
#  e.toUpper('aaa bbb ccc')
#end


