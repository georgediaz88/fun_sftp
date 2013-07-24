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

    context 'file utilities' do
      it "should return entries without prepended '.' " do
        dir1 = double("sftp_dir", :name => ".")
        dir2 = double("sftp_dir", :name => "import_docs")
        dir3 = double("sftp_dir", :name => "training_docs")
        sftp_mock.stub_chain(:dir, :entries).with(anything()).and_return([dir1, dir2, dir3])
        @sftp_cli = SFTPClient.new('localhost', 'user1', 'pass')
        expect(@sftp_cli.entries('Desktop')).to eq([dir2.name, dir3.name])
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
    end

  end
end