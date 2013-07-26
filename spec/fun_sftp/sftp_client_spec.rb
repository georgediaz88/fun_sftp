require 'spec_helper'

module FunSftp
  describe 'sftp client' do

    let(:sftp_mock) {double('sftp')} #sftp_mock is the @client var

    before do
      Net::SFTP.stub(:start => sftp_mock)
    end

    context 'initialization' do
      it 'should initialize with creds' do
        expect(SFTPClient).to receive(:new).with('localhost', 'user1', 'pass')
        @sftp_cli = SFTPClient.new('localhost', 'user1', 'pass')
      end
    end

    describe 'file utilities' do
      let(:file_1) {double("sftp_dir", :name => ".")}
      let(:dir_1) {double("sftp_dir", :name => "import_docs")}
      let(:dir_2) {double("sftp_dir", :name => "training_docs")}

      it "should return entries without prepended '.' " do
        sftp_mock.stub_chain(:dir, :entries).with(anything()).and_return([file_1, dir_1, dir_2])
        @sftp_cli = SFTPClient.new('localhost', 'user1', 'pass')
        expect(@sftp_cli.entries('Desktop')).to eq([dir_1.name, dir_2.name])
      end

      it "should return with all files including '.' " do
        sftp_mock.stub_chain(:dir, :entries).with(anything()).and_return([file_1, dir_1, dir_2])
        @sftp_cli = SFTPClient.new('localhost', 'user1', 'pass')
        expect(@sftp_cli.entries('Desktop', true)).to eq([file_1.name, dir_1.name, dir_2.name])
      end

      it 'should read both lines from test file' do
        file = File.expand_path('../../support/test1.txt', __FILE__)
        sftp_mock.stub_chain(:file, :open).with(anything()).and_return(File.open(file))
        @sftp_cli = SFTPClient.new('localhost', 'user1', 'pass')
        expect(@sftp_cli).to receive(:puts).twice
        @sftp_cli.read(file)
      end

      it 'should return false for directory not found' do
        sftp_response = Object.new
        def sftp_response.code; code = 2 end
        def sftp_response.message; message = 'no such file' end
        @sftp_cli = SFTPClient.new('localhost', 'user1', 'pass')
        @sftp_cli.stub(:entries).and_raise(Net::SFTP::StatusException.new(sftp_response))
        expect(@sftp_cli.has_directory?('bogus_directory')).to eql(false)
      end

      it 'should change directory source path' do
        @sftp_cli = SFTPClient.new('localhost', 'user1', 'pass')
        @sftp_cli.stub(:has_directory?).with(anything()).and_return(true)
        @sftp_cli.chdir('projects')
        expect(@sftp_cli.source).to eql('./projects')
      end

      it 'should sub tilda in path' do
        @sftp_cli = SFTPClient.new('localhost', 'user1', 'pass')
        @sftp_cli.stub(:has_directory?).with(anything()).and_return(true)
        @sftp_cli.chdir('~/some_dir/working_dir')
        expect(@sftp_cli.source).to eql('./some_dir/working_dir')
      end
    end

  end
end