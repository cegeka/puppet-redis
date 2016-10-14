require 'spec_helper_acceptance'

describe 'redis' do
  it 'should run successfully' do
    case fact('osfamily')
    when 'Debian'
      redis_name = 'redis-server'
    else
      redis_name = 'redis'
    end

    pp = <<-EOS
    Exec {
      path => [ '/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin', ]
    }

    class { '::redis':
      manage_repo => true,
    }
    EOS

    # Apply twice to ensure no errors the second time.
    apply_manifest(pp, :catch_failures => true)
    apply_manifest(pp, :catch_changes => true)
  end

  describe package(redis_name) do
    it { should be_installed }
  end

  describe service(redis_name) do
    it { should be_running }
  end
end
