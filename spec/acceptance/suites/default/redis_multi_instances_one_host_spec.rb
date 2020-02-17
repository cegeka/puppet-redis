require 'spec_helper_acceptance'

describe 'redis::instance' do
  case fact('osfamily')
  when 'Debian'
    config_path = '/etc/redis'
    redis_name = 'redis-server'
  else
    redis_name = 'redis'
    config_path = '/etc'
  end

  it 'runs successfully' do
    pp = <<-EOS
    class { 'redis':
      default_install => false,
    }

    redis::instance {'redis1':
      port => 7777,
    }

    redis::instance {'redis2':
      port => 8888,
    }
    EOS

    # Apply twice to ensure no errors the second time.
    apply_manifest(pp, catch_failures: true)
    apply_manifest(pp, catch_changes: true)
  end

  describe package(redis_name) do
    it { is_expected.to be_installed }
  end

  describe service('redis-server-redis1') do
    it { is_expected.to be_running }
  end

  describe service('redis-server-redis2') do
    it { is_expected.to be_running }
  end

  describe file("#{config_path}/redis-server-redis1.conf") do
    its(:content) { is_expected.to match %r{port 7777} }
  end

  describe file("#{config_path}/redis-server-redis2.conf") do
    its(:content) { is_expected.to match %r{port 8888} }
  end

  context 'redis should respond to ping command' do
    describe command('redis-cli -h 127.0.0.1 -p 7777 ping') do
      its(:stdout) { is_expected.to match %r{PONG} }
    end

    describe command('redis-cli -h 127.0.0.1 -p 8888 ping') do
      its(:stdout) { is_expected.to match %r{PONG} }
    end
  end
end
