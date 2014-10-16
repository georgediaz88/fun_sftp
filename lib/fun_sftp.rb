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
    attr_accessor :server, :user, :password, :client, :source

    def initialize(server, user, password)
      @server, @user, @password = server, user, password
      @source = '.'
      @client = setup_login
    end

    def source=(path)
      @source = clean_path(path)
    end

    def setup_login
      Net::SFTP.start(@server, @user, :password => @password)
    end

    def upload!(source, target) #send to remote
      #target example: 'some_directory/some_name.txt'
      opts = {:progress => UploadCallbacks.new, :recursive => true}
      converted_target = join_to_pwd(target)
      opts.delete(:progress) unless FunSftp.loggable?
      opts.delete(:recursive) unless has_directory?(converted_target)
      @client.upload!(source, converted_target, opts)
    end

    def download!(target, source) #fetch locally from remote
      opts = {:progress => DownloadCallbacks.new, :recursive => true}
      converted_target = join_to_pwd(target)
      opts.delete(:progress) unless FunSftp.loggable?
      opts.delete(:recursive) unless has_directory?(converted_target)
      @client.download!(converted_target, source, opts)
    end

    def read(path) #read a file
      file = @client.file.open(join_to_pwd(path))
      while !file.eof?
        puts file.gets
      end
    end

    def size(path) #returns the size of a file. ex: => 1413455562
      @client.file.open(join_to_pwd(path)).stat.size
    end

    def glob(path, pattern) # ex: ('some_directory', '**/*.rb')
      @client.dir.glob(join_to_pwd(path), pattern).collect(&:name)
    end

    def entries(dir, show_dot_files = false) #array of directory entries not caring for '.' files
      entries_arr = @client.dir.entries(join_to_pwd(dir)).collect(&:name)
      entries_arr.reject!{|a| a.match(/^\..*$/)} unless show_dot_files
      entries_arr
    end

    def has_directory?(dir) #returns true if directory exists
      begin
        true if entries(dir)
      rescue Net::SFTP::StatusException => e
        false
      end
    end

    def print_directory_items(dir) #printout of directory's items
      @client.dir.foreach(join_to_pwd(dir)) { |file| puts "#{file.name}" }
    end

    def items_in(root_dir) #array of *all* directories & files inside provided root directory
      glob(root_dir, '**/*').sort
    end

    #################################
    # Some Handy File Util Methods  #
    #################################

    def mkdir!(path) #make directory
      @client.mkdir!(join_to_pwd(path))
    end

    def rm(path) #remove a file
      @client.remove!(join_to_pwd(path))
    end

    def rmdir!(path) #remove directory
      @client.rmdir!(join_to_pwd(path))
    end

    def rename(name, new_name) #rename a file
      previous, renamed = join_to_pwd(name), join_to_pwd(new_name)
      @client.rename!(previous, renamed)
    end

    def ll
      print_directory_items('.')
    end

    def chdir(path)
      if path =~ /~/
        new_path = clean_path(path)
        change_directory_check(new_path, path)
      else
        change_directory_check(join_to_pwd(path), path)
      end
    end

    def pwd
      @source
    end

    def reset_path!
      @source = '.'
      "Path Reset and set to => #{@source}"
    end

    private

    def join_to_pwd(path)
      File.join(@source, path)
    end

    def clean_path(path)
      tilda_ith = path.rindex(/~/)
      new_path = path[tilda_ith..-1].gsub(/~/, '.')
    end

    def change_directory_check(converted_path, entered_path)
      if has_directory? converted_path
        @source = converted_path
        "Current Path changed to => #{@source}"
      else
        "Sorry Path => #{entered_path} not found"
      end
    end

  end
end