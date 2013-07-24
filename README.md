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

Let's say you need to send a file to a remote host. Well, you can upload it to the remote host using these steps:

* First setup the connection:

```ruby
include FunSftp
conn = SFTPClient.new(server, username, password)
```

* Now, you can upload your file:

```ruby
conn.upload!("my_file_name.txt", "some_remote_directory/give_a_name.txt")
```

That's it! Check the remote host to see that your file posted.

You can also download a remote file to your local machine:

```ruby
conn.download!("some_remote_directory/file_to_download_name.txt", "give_desired_local_name.txt")
```

Need to read a file on the remote host? Ah, it's no biggie...

```ruby
conn.read("path/to/file_name.txt")
#=> Hello World!
```

When investigating items on the remote host, these commands can be handy:

```ruby
conn.has_directory?("directory_name")
# returns true or false if the directory exists

conn.items_in("directory_name")
# returns an array of every directory and file within the provided directory
# => ["test1", "test1/h1.rb", "test2", "test2/h2.txt"]

conn.print_directory_items("directory_name")
# outputs directories one line at a time
# => test1
#    test2
#    some_directory_here

conn.entries("directory_name")
# outputs a nice array of entries in the specified directory
# => ["test1", "test2", "some_directory_here"]

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
conn.mkdir!("some_remote_directory/a_new_directory_name_here")
# makes a_new_directory_name_here under some_remote_directory if it exists
```

Removing a directory is the same as above except you would swap mkdir! for rmdir!:

```ruby
conn.rmdir!("...")
```

Files can be removed and renamed off the remote host:

```ruby
conn.rm("path/to/file.txt") # would remove file.txt

conn.rename("old_file_name.txt", "new_file_name.txt")
# old_file_name.txt is now named new_file_name.txt on the remote host.
```

Hopefully, this is easy enough to work with and transfer files!!
Look for new helpful method calls in future releases.

Licence
-------

Copyright (c) 2013 George Diaz

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
