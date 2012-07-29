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

def pjax_container_name()
  if params.has_key?('_pjax')
    params['_pjax'][1..params['_pjax'].size]
  else
    nil
  end 
end

def pjax_dispatch_render(partial)
  if is_pjax?
    haml partial
  else
    @partial = partial
    haml :default_layout
  end
end

get '/bootstrap.css' do
  File.read('views/bootstrap.css')
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

get '/bootstrap.js' do
  Fle.read('public/bootstrap.js')
end

get '/pjax.js' do
  File.read('public/pjax.jx')
end

not_found do
  pjax_dispatch_render(:not_found)
end

module Layouter

  class Renderer
    def initialize(param)
      @param = param
      @name = nil
    end
    
    def evaluated_param(sinatra)
      valued_param = {}
      @param.each do |k, v|
        valued_param[k] = v.render(sinatra)
      end
      valued_param
    end

    def render(sinatra)
      renderer = self
      if sinatra.params.has_key?('_pjax')
        begin
          s_container = sinatra.params['_pjax']
          sym_container = s_container[1..s_container.length].to_sym
          renderer = search_container_in_param(sym_container)
        rescue
        end
      end
      e_param = renderer.evaluated_param(sinatra) 
      render_result = renderer.specific_render(e_param, sinatra)
      class << render_result
        attr_accessor :name
      end
      render_result.name = @name
      render_result
    end

    attr_reader :param
    attr_accessor :name

  private
    def search_container_in_param(pjax_container, scope = nil)
      throw_if_not_found = false
      if scope.nil?
        scope = @param
        throw_if_not_found = true
      end
      return scope[pjax_container] if scope.has_key?(pjax_container)
      scope.values.each do |v|
        if renderer = search_container_in_param(pjax_container, v)
          return renderer
        end
      end
      if throw_if_not_found
        raise "Not found"
      else
        return nil
      end
    end
  end

  class WithMethod < Renderer
    def initialize(method, param)
      super(param)
      @method = method
    end

    def specific_render(param, sinatra)
      @method.call(param)
    end

    attr_reader :method, :param
  end

  class WithHaml < Renderer
    def initialize(haml_name, param)
      super(param)
      @haml_name = haml_name
    end

    def specific_render(param, sinatra)
      sinatra.haml @haml_name, :locals => param
    end

    attr_reader :haml_name, :param
  end
end

def layout_with(organizer, param)
  wrapped_param = {}
  param.each do |k, v|
    wrapped_param[k] = case v
    when Symbol then Layouter::WithHaml.new(v, {})
    when Method then Layouter::WithMethod.new(v, {})
    when Layouter::Renderer then v
    else raise "Not supported type."
    end.tap{|renderer| renderer.name = k}
  end
  case organizer
  when Symbol then Layouter::WithHaml.new(organizer, wrapped_param)
  when Method then Layouter::WithMethod.new(organizer, wrapped_param)
  else raise "Not supported type."
  end
end

helpers do
  # params[:text] => content
  # params[:updates] => updates container on pjax
  def pjax_link_options(href, update_container)
    {
      :href    => href,
      :onclick => "go('#{href}', '#{update_container}'); return false;"
    }
  end

  def pjax_wrap(content, opts = {})
    if opts.has_key?(:id)
      raise "pjax_wrap() can't accept options[:id]"
    end
    tag_type = opts.delete(:tag) || :div
    opts[:id] = content.name if content.respond_to?(:name)
    stringified_opts = opts.map {|k, v| " #{k}=\"#{v}\""}
    "<#{tag_type}#{stringified_opts.join}>#{content}</#{tag_type}>"
  end
end


def render_remote_pane(param)
  haml :remote_pane
end


def default_mapping
  layout_with :default_layout, {
    :log_pane => (layout_with :log_pane, {
      :remote_pane  => method(:render_remote_pane),
      :local_pane   => :local_pane
    }),
    :fileview_pane  => :fileview_pane,
    :diff_pane      => :diff_pane
  }
end

def combined_mapping
  layout_with :default_layout, {
    :log_pane       => :combined_log_pane,
    :fileview_pane  => :fileview_pane,
    :diff_pane      => :diff_pane
  }
end

get '/show2.html' do
  second_mapping.render(self)
end

class RequestParam
  def initialize(params)
    @remote_branch = params['rb'] || 'master'
    @local_branch = params['lb'] || 'master'
  end

  def modified_url(hash)
    source = {}
    source[:rb] = hash.delete(:remote_branch) || @remote_branch
    source[:lb] = hash.delete(:local_branch) || @local_branch
    s_param = source.map {|k, v| "#{k}=#{v}"}.join('&')
    URI.encode("/?#{s_param}")
  end

  attr_reader :remote_branch, :local_branch
end

get '/' do
  @request = RequestParam.new(params)
  @r_branches = Git::cmd_branch_r().parse
  @l_branches = Git::cmd_branch().parse

  origin_head = nil
  if found = @r_branches['origin'].find(&:is_head?)
    origin_head = found.name
  else
    origin_head = @r_branches['origin'].first.name
  end

  #if same_branch = @l_branches.find {|b| b.name == origin_head }
  #  combined_mapping.render(self)
  #else
    default_mapping.render(self)
  #end

  #Git::cmd_fetch
  #@commits = Git::cmd_recent_hash_10.map do |hash|
  #  Git::cmd_show_raw(hash).parse
  #end
  #d = @commits[0][:author][:date]
  #@commits.each do |commit|
  #  commit[:date_s] = Time.at(commit[:author][:date].to_i).strftime('%Y/%m/%d %H:%M:%d')
  #end

  #pjax_dispatch_render(:commit_index)
end



# require 'example'
#get '/' do
#  e = Example::Example.new
#  e.toUpper('aaa bbb ccc')
#end
