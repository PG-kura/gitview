$:.unshift File.join(File.dirname(__FILE__), '.')
require 'rubygems'
require 'enumerator'
require 'sinatra'
require 'haml'
require 'sass'

require 'git'

configure do 
  Git::set_repository(ARGV[0])
end

configure :development do
  set :port, 3000
end

configure :production do
  set :port, 80
end

def is_pjax?()
  !(params[:_pjax].nil? or params[:_pjax] == "")
end

def pjax_dispatch_render(partial)
  if is_pjax?
    haml partial
  else
    @partial = partial
    haml :default_layout
  end
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
  pjax_dispatch_render(:not_found)
end

get '/' do
  @commits = Git::cmd_recent_hash_10.map do |hash|
    Git::cmd_show_raw(hash).parse
  end
  d = @commits[0][:author][:date]
  @commits.each do |commit|
    commit[:date_s] = Time.at(commit[:author][:date].to_i).strftime('%Y/%m/%d %H:%M:%d')
  end
  pjax_dispatch_render(:commit_index)
end




# require 'example'
#get '/' do
#  e = Example::Example.new
#  e.toUpper('aaa bbb ccc')
#end


