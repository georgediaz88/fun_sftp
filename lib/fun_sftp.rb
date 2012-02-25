require 'fun_sftp/version'

#safe require to avoid any 'constant already init msg'
orig_verbose = $VERBOSE
$VERBOSE = nil
require 'net/sftp'
$VERBOSE = orig_verbose

module FunSftp

  class SFTPClient
    attr_accessor :server, :user, :password, :client

    def initialize(server, user, password)
      @server, @user, @password = server, user, password
      @client = setup_login
    end
  
    def setup_login
      Net::SFTP.start(@server, @user, :password => @password)
    end
  
    def upload!(source, target) #send to remote
      @client.upload!(source, target) #target example: 'some_directory/some_name.txt'
    end
  
    def download!(target, source) #fetch locally from remote
      @client.download!(target, source)
    end
  
    def read(path)
      file = @client.file.open(path)
      while !file.eof?
        puts file.gets
      end
    end

    def glob(path, pattern) # ex: ('some_directory', '**/*.rb')
      @client.dir.glob(path, pattern).collect(&:name)
    end

    def entries(dir) #array of directory items
      @client.dir.entries(dir).collect(&:name).reject!{|a| a.match(/^\.+$/)}
    end

    def has_directory?(dir) #returns true if directory exists
      begin
        true if entries(dir)
      rescue Exception => e
        false
      end
    end

    def print_directory_items(dir) #printout of directory items
      @client.dir.foreach(dir) { |file| print "#{file.name}\n" }
    end

    def items_in(root_dir) #array of *all* directories & files inside provided root directory
      @client.glob(root_dir, '**/*').sort
    end
  
    #### Some Handy File Util Methods
    def mkdir!(path) #make directory
      @client.mkdir! path
    end
  
    def rm(path) #remove a file
      @client.remove!(path)
    end
  
    def rmdir!(path) #remove directory
      @client.rmdir!(path)
    end
  
    def rename(name, new_name) #rename a file
      @client.rename!(name, new_name)
    end
    ##################################

  end
end