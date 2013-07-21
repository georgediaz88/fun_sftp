module FunSftp
  class DownloadCallbacks
    def on_open(downloader, file)
      puts "starting download: #{file.remote} -> #{file.local} (#{file.size} bytes)"
    end

    def on_get(downloader, file, offset, data)
      puts "writing #{data.length} bytes to #{file.local} starting at #{offset}"
    end

    def on_close(downloader, file)
      puts "finished with #{file.remote}"
    end

    def on_mkdir(downloader, path)
      puts "creating directory #{path}"
    end

    def on_finish(downloader)
      puts "all done!"
    end
  end
end