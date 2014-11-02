require 'fun_sftp/version'
require 'fun_sftp/configuration'
require 'fun_sftp/upload_callbacks'
require 'fun_sftp/download_callbacks'

# safe require
# avoids any 'constant already init msg'
orig_verbose = $VERBOSE
$VERBOSE = nil
require 'net/sftp'
$VERBOSE = orig_verbose

# Reference: http://net-ssh.rubyforge.org/sftp/v2/api/
module FunSftp
  class SFTPClient

    attr_accessor :source

    attr_reader :server, :user, :password, :client

    alias_method :pwd, :source

    def initialize(server, user, password)
      @server, @user, @password = server, user, password
      self.source = '.'
      @client = setup_login
    end

    def setup_login
      Net::SFTP.start(server, user, password: password)
    end

    def upload!(src, target) #send to remote
      #target example: 'some_directory/some_name.txt'
      opts = { progress: UploadCallbacks.new, recursive: true }
      converted_target = clean_path(target)
      opts.delete(:progress) unless FunSftp.loggable?
      opts.delete(:recursive) unless has_directory?(target)
      client.upload!(src, converted_target, opts)
    end

    def download!(target, src) #fetch locally from remote
      opts = { progress: DownloadCallbacks.new, recursive: true}
      converted_target = clean_path(target)
      opts.delete(:progress) unless FunSftp.loggable?
      opts.delete(:recursive) unless has_directory?(target)
      client.download!(converted_target, src, opts)
    end

    def read(path) #read a file
      file = client.file.open(clean_path(path))
      while !file.eof?
        puts file.gets
      end
    end

    def size(path) #returns the size of a file. ex: => 1413455562
      client.file.open(clean_path(path)).stat.size
    end

    def atime(path) #returns the atime (access time) of a file. ex: => 2014-10-16 12:32:42 +0200
      Time.at(client.file.open(clean_path(path)).stat.atime)
    end

    def mtime(path) #returns the mtime (modified time) of a file. ex: => 2014-10-16 12:32:42 +0200
      Time.at(client.file.open(clean_path(path)).stat.mtime)
    end

    def glob(path, pattern='**/*') # ex: ('some_directory', '**/*.rb')
      client.dir.glob(clean_path(path), pattern).collect(&:name)
    end
    alias_method :items_in, :glob

    def entries(dir, show_dot_files = false) #array of directory entries not caring for '.' files
      entries_arr = client.dir.entries(clean_path(dir)).collect(&:name)
      entries_arr.reject!{|a| a.match(/^\..*$/)} unless show_dot_files
      entries_arr
    end

    def has_directory?(dir)
      begin
        true if client.dir.entries(clean_path(dir)).any?
      rescue Net::SFTP::StatusException => e
        false
      end
    end

    def print_directory_items(dir='.') #printout of directory's items
      client.dir.foreach(clean_path(dir)) { |file| puts "#{file.name}" }
    end
    alias_method :ll, :print_directory_items

    def mkdir!(path) #make directory
      client.mkdir!(clean_path(path))
    end

    def rm(path) #remove a file
      client.remove!(clean_path(path))
    end

    def rmdir!(path) #remove directory
      client.rmdir!(clean_path(path))
    end

    def rename(name, new_name) #rename a file
      previous, renamed = clean_path(name), clean_path(new_name)
      client.rename!(previous, renamed)
    end

    def chdir(path)
      clean_path = clean_path(path)
      if has_directory? path
        self.source = clean_path
        "Current Path change to => #{source}"
      else
        "Sorry Path => #{path} not found"
      end
    end

    def reset_path!
      self.source = '.'
      "Path Reset!"
    end

    private

    def join_to_pwd(path)
      File.join(source, path)
    end

    def clean_path(path)
      if path.start_with? '~'
        path.sub(/~/, '.')
      else
        Pathname(join_to_pwd(path)).cleanpath.to_path
      end
    end

  end
end
