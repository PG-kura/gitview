
module Git

def self.cmd_prevlog
  `git log --pretty=format:\"%h - %an, %ar : %s\"`
end

def self.cmd_log_10
  `git log -10`
end

def self.parse_commit(lines)
  commit = {}

  if lines[0] =~ /commit (.*)/
    commit[:hash] = $1.strip
  end

  if lines[1] =~ /Author:([\s]+)(.*) <(.*)>/
    commit[:author] = $2.strip
    commit[:email] = $3.strip
  end

  if lines[2] =~ /Date:([\s]+)(.*)/
    commit[:date] = $2.strip
  end

  commit[:message] = lines[4].strip

  commit
end 

end

