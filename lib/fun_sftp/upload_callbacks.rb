module FunSftp
  class UploadCallbacks
    def on_open(uploader, file)
      FunSftp.logger.info "starting upload: #{file.local} -> #{file.remote} (#{file.size} bytes)"
    end

    def on_put(uploader, file, offset, data)
      FunSftp.logger.info "writing #{data.length} bytes to #{file.remote} starting at #{offset}"
    end

    def on_close(uploader, file)
      FunSftp.logger.info "finished with #{file.remote}"
    end

    def on_mkdir(uploader, path)
      FunSftp.logger.info "creating directory #{path}"
    end

    def on_finish(uploader)
      FunSftp.logger.info "all done!"
    end
  end
end