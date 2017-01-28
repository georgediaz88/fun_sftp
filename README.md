[![Gem Version](https://badge.fury.io/rb/fun_sftp.png)](http://badge.fury.io/rb/fun_sftp)

FunSftp
=======

FunSftp is a ruby gem that provides a nice and easy to use wrapper for the Net::SFTP library.

Reference: [net-sftp](http://net-ssh.github.com/sftp/v2/api/index.html)

Installation
------------

```ruby
gem 'fun_sftp'
```

Usage
-----

Let's say you need to send a file or directory to a remote host. Well, you can upload it to the remote host via the following:

Setup the connection and specify a `source` directory if desired:

```ruby
include FunSftp
conn = SFTPClient.new(server, username, password)
# For authentication via keys
conn = SFTPClient.new(server, username, password, keys: [/path/to/key], host_key: 'ssh-rsa')
conn.source = 'projects/awesome_project' #optional
```

Changing directories `chdir` and listing all files `ll` can be useful when working in a console. FunSftp now allows you to change your location on the remote host. This saves you from constantly entering long absolute paths.

```ruby
conn.chdir("projects")
# Changes Directory
# => "Current Path changed to => ./projects"

conn.ll
# Lists all files in current location
# => file1
#    file2
#    Directory1
#    Directory2

conn.pwd
# Returns the current working directory
# => "./projects"
```

If you need to start from scratch then reset to the base path:

```ruby
conn.reset_path!
# => "Path Reset!"
```

Now, you can upload your file:

```ruby
conn.upload!("my_local_file_name.txt", "some_remote_directory/give_a_name.txt")
```

or directory

```ruby
conn.upload!("my_awesome_local_directory", "desired_remote_directory_name")
```

That's it! Check the remote host to see that your file posted.

You can also download a remote file to your local machine:

```ruby
conn.download!("some_remote_directory/file_to_download_name.txt", "desired_local_name.txt")
```

or directory

```ruby
conn.download!("some_remote_directory", "desired_local_directory_name")
```

Need to read a file on the remote host? Ah, it's no biggie...

```ruby
conn.read("path/to/file_name.txt")
# => Hello World!
```

It is also possible to read the attributes size, access time and modified time.

```ruby
conn.size("path/to/file_name.txt")
# => 1413455562
# works also for directories

conn.atime("path/to/file_name.txt")
# => 2014-10-16 12:32:42 +0200

conn.mtime("path/to/file_name.txt")
#=> 2014-10-16 12:32:42 +0200
```

When investigating items on the remote host, these commands can be handy:

```ruby
conn.has_directory?("directory_name")
# returns true or false if the directory exists

conn.entries("directory_name")
# outputs a nice array of entries in the specified directory
# Pass true as a second argument if you would like to see '.' files
# => ["test1", "test2", "some_directory_here"]

conn.items_in("directory_name")
# Traverses the provided directory returning an array of directories and files
# => ["test1", "test1/h1.rb", "test2", "test2/h2.txt"]

conn.print_directory_items("directory_name")
# a print out of contained directories/files one line at a time
# => test1.txt
#    test2.png
#    fun_directory_1

conn.glob("directory_name", "**/*.rb")
# Traverses the directory specified using the second argument/matcher
# So, you can get things like...
# => ["some_directory_here/hello_world.rb", "sftp_is_fun.rb"]
```

FileUtils
---------

FileUtilities are handy for doing some dirty work on the remote host.

So far, you can make/remove directories, remove/rename files

```ruby
conn.mkdir!("new_directory_name_here")
```

Removing a directory is the same as above except you would swap mkdir! for rmdir!:

```ruby
conn.rmdir!("directory_name_to_remove")
```

Files can be removed and renamed off the remote host:

```ruby
conn.rm("file.txt")

conn.rename("old_file_name.txt", "new_file_name.txt")
# old_file_name.txt is now named new_file_name.txt on the remote host.
```

Hopefully, this is easy enough to work with and transfer files!!

Logging
-------

By default, logging is turned on and will use the Rails logger if within a Rails projects. If not logging will defer to STDOUT. Logging is prominent when downloading or uploading. To turn off logging, you can create an initializer and modify the configuration by:

```ruby
FunSftp.configure do |config|
  config.log = false
end
```

You can also define your own logger if you'd like.

```ruby
FunSftp.configure do |config|
  config.logger = MyAwesomeLogger.new
end
```

Contribute
-------------------

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Added some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request

License
-------

Copyright (c) 2017 George Diaz

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
