require 'fun_sftp/version'
require 'fun_sftp/configuration'
require 'fun_sftp/upload_callbacks'
require 'fun_sftp/download_callbacks'

#safe require to avoid any 'constant already init msg'
orig_verbose = $VERBOSE
$VERBOSE = nil
require 'net/sftp'
$VERBOSE = orig_verbose

# Ref: http://net-ssh.rubyforge.org/sftp/v2/api/
# TD: Set a default source point??
# TD: Setup any aliases
# TD: Write More Tests!!
module FunSftp
  class SFTPClient
    attr_accessor :server, :user, :password, :client, :source

    def initialize(server, user, password)
      @server, @user, @password = server, user, password
      @source = '.'
      @client = setup_login
    end

    #DRY? #new method to cleanup?
    def source=(path)
      tilda_ith = path.rindex(/~/)
      new_path = path[tilda_ith..-1].gsub(/~/, '.')
      @source = new_path
    end

    def setup_login
      Net::SFTP.start(@server, @user, :password => @password)
    end

    def upload!(source, target) #send to remote
      #target example: 'some_directory/some_name.txt'
      opts = {:progress => UploadCallbacks.new, :recursive => true}
      converted_target = join_to_pwd(target)
      opts.delete(:progress) unless loggable?
      opts.delete(:recursive) unless has_directory?(target)
      @client.upload!(source, converted_target, opts)
    end

    def download!(target, source) #fetch locally from remote
      opts = {:progress => DownloadCallbacks.new, :recursive => true}
      converted_target = join_to_pwd(target)
      opts.delete(:progress) unless loggable?
      opts.delete(:recursive) unless has_directory?(target)
      @client.download!(converted_target, source, opts)
    end

    def read(path) #read a file
      file = @client.file.open(join_to_pwd(path))
      while !file.eof?
        puts file.gets
      end
    end

    def glob(path, pattern) # ex: ('some_directory', '**/*.rb')
      @client.dir.glob(join_to_pwd(path), pattern).collect(&:name)
    end

    def entries(dir) #array of directory entries not caring for '.' files
      @client.dir.entries(dir).collect(&:name).reject!{|a| a.match(/^\..*$/)}
      #@client.dir.entries(join_to_pwd(dir)).collect(&:name).reject!{|a| a.match(/^\..*$/)}
    end

    def has_directory?(dir) #returns true if directory exists
      begin
        true if entries(dir)
      rescue Net::SFTP::StatusException => e
        false
      end
    end

    def print_directory_items(dir) #printout of directory's items
      @client.dir.foreach(join_to_pwd(dir)) { |file| print "#{file.name}\n" }
    end

    def items_in(root_dir) #array of *all* directories & files inside provided root directory
      glob(root_dir, '**/*').sort
    end

    #################################
    # Some Handy File Util Methods  #
    #################################

    def mkdir!(path) #make directory
      @client.mkdir! converted_path(join_to_pwd(path))
    end

    def rm(path) #remove a file
      @client.remove!(join_to_pwd(path))
    end

    def rmdir!(path) #remove directory
      @client.rmdir!(join_to_pwd(path))
    end

    def rename(name, new_name) #rename a file
      previous = join_to_pwd(name)
      renamed = join_to_pwd(new_name)
      @client.rename!(previous, renamed)
    end

    def ll
      print_directory_items('.')
    end

    def chdir(path)
      if path =~ /~/
        tilda_ith = path.rindex(/~/)
        new_path = path[tilda_ith..-1].gsub(/~/, '.')

        if has_directory? new_path
          @source = new_path
          puts "Current Path changed to => #{@source}"
        else
          "Sorry Path => #{path} not found"
        end
      else
        if has_directory? join_to_pwd(path)
          @source = join_to_pwd(path)
          puts "Current Path changed to => #{@source}"
        else
          "Sorry Path => #{path} not found"
        end
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

    def loggable?
      (FunSftp.configuration and !FunSftp.configuration.log) ? false : true
    end

  end
end