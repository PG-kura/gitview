
module Git

def self.cmd_prevlog
  `git log --pretty=format:\"%h - %an, %ar : %s\"`
end

end

