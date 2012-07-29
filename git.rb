
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

def self.cmd_branch_r()
  exec_command('git branch -r')
end

def self.cmd_branch()
  exec_command('git branch')
end

end

