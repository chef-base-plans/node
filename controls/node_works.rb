title 'Tests to confirm node works as expected'

plan_origin = ENV['HAB_ORIGIN']
plan_name = input('plan_name', value: 'node')

control 'core-plans-node-works' do
  impact 1.0
  title 'Ensure node works as expected'
  desc '
  Verify node by ensuring that
  (1) its installation directory exists 
  (2) it returns the expected version
  '
  
  hab_path = input('hab_path', value: 'hab')
  plan_installation_directory = command("hab pkg path #{plan_origin}/#{plan_name}")
  describe plan_installation_directory do
    its('exit_status') { should eq 0 }
    its('stdout') { should_not be_empty }
    its('stderr') { should be_empty }
  end
  
  expected_node_version = plan_installation_directory.stdout.split("/")[5]
  expected_npm_version = input('expected_npm_version', value: '6.13.4')
  {
    "node" => { pattern: "v#{expected_node_version}" },
    "npm" => { pattern: "#{expected_npm_version}" },
    "npx" => { pattern: "#{expected_npm_version}" },
  }.each do |binary_name, version|
    command_full_path = File.join(plan_installation_directory.stdout.strip, "bin", binary_name)
    describe command("#{command_full_path} --version") do
      its('exit_status') { should eq 0 }
      its('stdout') { should_not be_empty }
      its('stdout') { should match version[:pattern] }
      its('stderr') { should be_empty }
    end
  end
end