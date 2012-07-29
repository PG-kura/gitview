
module Git

def self.set_repository(path)
  @@repository = path
end

def self.exec_command(cmd)
  repository = FileTest::directory?(@@repository) ? @@repository : './'
  `cd #{repository}; #{cmd}`.split("\n")
end

def self.cmd_recent_hash_10
  exec_command('git log --pretty=format:%H')
end

def self.cmd_show_raw(hash)
  lines = exec_command("git show -s --pretty=raw #{hash}")
  def lines.parse
    commit = {}
    index = 0
    if self[index] =~ /commit ([\w]{40})/
      commit[:hash] = $1
      index = index + 1
    end
    if self[index] =~ /tree ([\w]{40})/
      commit[:tree] = $1
      index = index + 1
    end
    if self[index] =~ /parent ([\w]{40})/
      commit[:parent] = $1
      index = index + 1
    end
    if self[index] =~ /author (.*) <(.*)> ([\d]{10}) ([+,-])([\d]{2})([\d]{2})/
      commit[:author] = {
        :name => $1,
        :email => $2,
        :date => $3,
        :timezone_diff => {
          :is_plus => ($4 == '+'),
          :hour => $5.to_i,
          :min => $6.to_i
        }
      }
      index = index + 1
    end
    if self[index] =~ /committer (.*) <(.*)> ([\d]{10}) ([+,-])([\d]{2})([\d]{2})/
      commit[:author] = {
        :name => $1,
        :email => $2,
        :date => $3,
        :timezone_diff => {
          :is_plus => ($4 == '+'),
          :hour => $5.to_i,
          :min => $6.to_i
        }
      }
      index = index + 1
    end
    
    index = index + 1
    commit[:message] = []
    while index < self.size
      commit[:message] << self[index][4..self[index].size]
      index = index + 1
    end
    commit
  end
  lines
end

def self.cmd_fetch()
  exec_command('git fetch')
end

def self.cmd_remote()
  exec_command('git remote')
end

class Branch
  def initialize(name, is_head = false)
    @name = name
    @commits = []
    @is_head = is_head
  end

  def is_head?
    @is_head
  end
 
  attr_reader :name
  attr_writer :is_head
  attr_accessor :commits
end

def self.cmd_branch_r(remotes = nil)
  remotes = cmd_remote().map(&:strip)
  lines = exec_command('git branch -r').map(&:strip)
  
  class << lines
    attr_accessor :remotes

    def parse
      ret = {}
      @remotes.each do |remote|
        ret[remote] = []
      end
      head = {}
      self.each do |line|
        if line =~ /([\w]+)\/([\w+]) -> ([\w]+)\/([\w]+)/
          head[$1] = $4
        elsif line =~ /([\w]+)\/([\w]+)/
          ret[$1] << Branch.new($2)
        end
      end
      head.each do |remote, branch|
        ret[remote].each do |r|
          if r.name == branch
            r.is_head = true
            break
          end
        end
      end
      ret
    end
 
  end
  lines.remotes = remotes
  lines
end

def self.cmd_branch()
  lines = exec_command('git branch')
  def lines.parse
    ret = []
    self.each do |line|
      if line =~ /\* ([\w]+)/
        ret << Branch.new($1, true)
      elsif line =~ /([\w]+)/
        ret << Branch.new($1)
      end
    end
    ret
  end
  lines
end

end

