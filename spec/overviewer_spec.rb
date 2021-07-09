require 'dockerspec/serverspec'

# Check some properties of the image (Not Running)
describe 'mide/minecraft-overviewer' do
  describe docker_build('.') do
 	it { should have_maintainer 'Mark Ide Jr (https://www.mide.io)' }
  	it { should have_cmd ["bash", "/home/minecraft/entrypoint.sh"] }
  	it { should have_user 'minecraft' }

  	# Check the defaults have the expected values
  	it { should have_env 'CONFIG_LOCATION' => '/home/minecraft/config.py' }
  	it { should have_env 'RENDER_MAP' => 'true' }
  	it { should have_env 'RENDER_POI' => 'true' }
  	it { should have_env 'RENDER_SIGNS_FILTER' => '-- RENDER --' }
  	it { should have_env 'RENDER_SIGNS_HIDE_FILTER' => 'false' }
  	it { should have_env 'RENDER_SIGNS_JOINER' => '<br />' }
  	it { should_not have_env 'ADDITIONAL_ARGS'}
  	it { should_not have_env 'ADDITIONAL_ARGS_POI'}

    # Check that we didn't suddenly make it into an enormous image
    its(:size) { should be < 2**28 } # 256 MiB
  end
end

# Check against running container
describe docker_compose('spec/docker-compose-test.yaml', wait: 5, container: :render) do
    describe file('/home/minecraft/config.py') do
        it { should be_file }
    end

    empty_dirs = %w(/var/lib/apt/lists/ /tmp/ /var/tmp/)
    empty_dirs.each do |dir|
        describe file(dir) do
            it { should exist }
            it { should be_directory }
            its(:size) { should eq 4096 } # Empty
        end
    end

    describe group('minecraft') do
        it {should exist }
        it { should have_gid 1000 }
    end

    describe user('minecraft') do
        it { should exist }
        it { should belong_to_group 'minecraft' }
        it { should have_uid 1000 }
        it { should have_home_directory '/home/minecraft' }
    end

    # Check installed packages
    packages = %w(minecraft-overviewer optipng wget python3)
    packages.each do |p|
        describe package(p) do
            it { should be_installed }
        end
    end

    # Check that our tooling can get Minecraft client URLs
    describe command("python3 /home/minecraft/download_url.py $MINECRAFT_VERSION") do
        its(:stdout) { should match "https:\/\/" }
        its(:exit_status) { should eq 0 }
    end

end
