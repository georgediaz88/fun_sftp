require 'spec_helper'

module FunSftp
  describe 'sftp client' do

    let(:sftp_mock) { double('sftp') }

    before do
      allow(Net::SFTP).to receive(:start).and_return(sftp_mock)
    end

    context 'initialization' do
      it 'should initialize with creds' do
        expect(SFTPClient).to receive(:new).with('localhost', 'user1', 'pass')
        SFTPClient.new('localhost', 'user1', 'pass')
      end
    end

    context 'file utilities' do
      let(:sftp_cli) { SFTPClient.new('localhost', 'user1', 'pass') }
      let(:test_file) { File.expand_path('../../support/test1.txt', __FILE__) }
      let(:file_1) { double('sftp_dir', name: '.') }
      let(:dir_1) { double('sftp_dir', name: 'import_docs') }
      let(:dir_2) { double('sftp_dir', name: 'training_docs') }

      before do
        allow(sftp_mock).to receive_message_chain(:file, :open).with(anything()).and_return(File.open(test_file))
      end

      describe '#entries' do
        before do
          allow(sftp_mock).to receive_message_chain(:dir, :entries).with('Desktop').and_return([file_1, dir_1, dir_2])
        end

        it "should return entries without prepended '.' " do
          expect(sftp_cli.entries('Desktop')).to eq([dir_1.name, dir_2.name])
        end

        it "should return with all files including '.' " do
          expect(sftp_cli.entries('Desktop', true)).to eq([file_1.name, dir_1.name, dir_2.name])
        end
      end

      describe '#download!' do
        before do
          allow(sftp_mock).to receive(:download!)
        end

        it 'respects passed in options' do
          expect(sftp_mock).to receive(:download!).with('remote_file', 'local_file', hash_not_including(:recursive))
          sftp_cli.download!('remote_file', 'local_file', recursive: false)
        end
      end

      describe '#upload!' do
        before do
          allow(sftp_mock).to receive(:upload!)
        end

        it 'respects passed in options' do
          expect(sftp_mock).to receive(:upload!).with('src', 'target', hash_not_including(:recursive))
          sftp_cli.upload!('src', 'target', recursive: false)
        end
      end

      describe '#read' do
        it 'should read both lines from test file' do
          expect(sftp_cli).to receive(:puts).twice
          sftp_cli.read(test_file)
        end
      end

      describe '#size' do
        it 'should get the size from test file' do
          expect(sftp_cli.size(test_file)).to eq(File.size(test_file))
        end
      end

      describe '#atime' do
        it 'should get the atime from test file' do
          expect(sftp_cli.atime(test_file)).to eq(File.atime(test_file))
        end
      end

      describe '#mtime' do
        it 'should get the mtime from test file' do
          expect(sftp_cli.mtime(test_file)).to eq(File.mtime(test_file))
        end
      end

      describe '#has_directory?' do
        it 'should return false for directory not found' do
          sftp_response = Object.new
          def sftp_response.code; code = 2 end
          def sftp_response.message; message = 'no such file' end
          allow(sftp_mock).to receive_message_chain(:dir, :entries, :any?).and_raise(Net::SFTP::StatusException.new(sftp_response))
          expect(sftp_cli.has_directory?('bogus_directory')).to eql(false)
        end
      end

      describe '#chdir' do
        before do
          allow(sftp_cli).to receive(:has_directory?).with(anything()).and_return(true)
        end

        it 'should change directory source path' do
          sftp_cli.chdir('projects')
          expect(sftp_cli.source).to eq('projects')
        end

        it 'should sub tilda for period in path' do
          sftp_cli.chdir('~/some_dir/working_dir')
          expect(sftp_cli.source).to eq('./some_dir/working_dir')
        end
      end

      describe '#reset_path!' do
        it 'resets source' do
          sftp_cli.source = 'some_dir/one'
          sftp_cli.reset_path!
          expect(sftp_cli.source).to eq('.')
        end
      end
    end

  end
end
