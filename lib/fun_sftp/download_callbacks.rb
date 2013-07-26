module FunSftp
  class DownloadCallbacks
    def on_open(downloader, file)
      FunSftp.logger.info "starting download: #{file.remote} -> #{file.local} (#{file.size} bytes)"
    end

    def on_get(downloader, file, offset, data)
      FunSftp.logger.info "writing #{data.length} bytes to #{file.local} starting at #{offset}"
    end

    def on_close(downloader, file)
      FunSftp.logger.info "finished with #{file.remote}"
    end

    def on_mkdir(downloader, path)
      FunSftp.logger.info "creating directory #{path}"
    end

    def on_finish(downloader)
      FunSftp.logger.info "all done!"
    end
  end
end