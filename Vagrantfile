# -*- mode: ruby -*-
# vi: set ft=ruby :

# Ensure yaml module is loaded
require 'yaml'

# Read yaml node definitions to create
nodes = YAML.load_file(File.join(File.dirname(__FILE__), 'nodes.yml'))

# Define global variables
VAGRANTFILE_API_VERSION = "2"
# Define if provisioners should run (true|false)
provision_nodes = true


Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
  # Iterate over nodes to get a count
  # Define as 0 for counting the number of nodes to create from nodes.yml
  groups = [] # Define array to hold ansible groups
  num_nodes = 0
  populated_ansible_groups = Hash.new # Create hash to contain iterated groups
  # Create array of Ansible Groups from iterated nodes
  nodes.each do |node|
    num_nodes = node
    node['ansible_groups'].each do |group|
      groups.push(group)
    end
  end
  # Remove duplicate Ansible Groups
  groups = groups.uniq
  # Iterate through array of Ansible Groups
  groups.each do |group|
    group_nodes = []
    # Iterate list of nodes
    nodes.each do |node|
      node['ansible_groups'].each do |nodegroup|
        # Check if node is a member of iterated group
        if nodegroup == group
          group_nodes.push(node['name'])
        end
      end
      populated_ansible_groups[group] = group_nodes
    end
  end

  # Dynamic Ansible Groups iterated from nodes.yml
  ansible_groups = populated_ansible_groups

  #Iterate over nodes
  nodes.each do |node_id|
    # Below is needed if not using Guest Additions
    config.vm.define node_id['name'] do |node|
      node.vm.box = node_id['box']
      node.vm.hostname = node_id['name']
      node.vm.provider "virtualbox" do |vb|
        vb.memory = node_id['mem']
        vb.cpus = node_id['vcpu']

      # Provision network interfaces
      if not node_id['interfaces'].nil?
        node_id['interfaces'].each do |int|
          if int['method'] == 'dhcp'
            if int['network_name'] == "None"
              node.vm.network :private_network, \
              type: "dhcp"
            end
            if int['network_name'] != "None"
              node.vm.network :private_network, \
              virtualbox__intnet: int['network_name'], \
              type: "dhcp"
            end
          end
          if int['method'] == "static"
            if int['network_name'] == "None"
              node.vm.network :private_network, \
              ip: int['ip'], \
              auto_config: int['auto_config']
            end
            if int['network_name'] != "None"
              node.vm.network :private_network, \
              virtualbox__intnet: int['network_name'], \
              ip: int['ip'], \
              auto_config: int['auto_config']
            end
          end
        end
      end

      # Port Forwards
      if not node_id['port_forwards'].nil?
        node_id['port_forwards'].each do |pf|
          node.vm.network :forwarded_port, \
          guest: pf['guest'], \
          host: pf['host']
        end
      end

      # Provisioners
      if provision_nodes
        if node_id == num_nodes
          node.vm.provision "ansible" do |ansible|
            ansible.limit = "all"
            #runs bootstrap Ansible playbook
            ansible.playbook = "bootstrap.yml"
          end
            node.vm.provision "ansible" do |ansible|
            ansible.limit = "all"
            #runs Ansible playbook for installing roles/executing tasks
            ansible.playbook = "playbook.yml"
            ansible.groups = ansible_groups
          end
        end
         node.vm.provision :ansible_local do |ansible|
            #runs Ansible playbook for installing roles/executing tasks
            ansible.playbook = 'provision.yml'
            ansible.inventory_path = 'hosts'
            ansible.limit = 'node0'
            ansible.verbose        = true
            ansible.install        = true
          end
      end

    end
  end

  #runs initial shell script
  if provision_nodes
    config.vm.provision :shell, path: "bootstrap.sh", keep_color: "true"
  end

 end
end
