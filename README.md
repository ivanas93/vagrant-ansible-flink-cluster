# Flink clusters with Vagrant and Ansible

## About The Project

The goal of this project is to create a fully functional Flink cluster by virtualization the nodes. 
When the cluster is active, Flink jobs can be deployed in the same way as in a real cluster..

### Built With

* [VirtualBox](https://www.virtualbox.org/)
* [Vagrant](https://github.com/hashicorp/vagrant)
* [Ansible](https://github.com/ansible/ansible)
* [Flink](https://flink.apache.org/)

### Pre-requisites

* It's necessary to have **VirtualBox** installed.
* The project uses **Vagrant** for creating virtual nodes, so It's necessary to have Vagrant installed.
* For the creation of the virtual node, Vagrant uses the Ubuntu 20.04 [box](https://www.vagrantup.com/docs/boxes), 
  therefore the box is necessary to have it installed. Command: `vagrant box add bento/ubuntu-20.04`
* The last step is to provision the nodes. **Ansible** is used to automate this task, so you need to have it installed as well.
* While the Flink cluster is being created, use the ssh ports to communicate the nodes. By default, the ssh port is 22, 
  but the host contains more than one virtual node, for this reason it is necessary to map the ssh ports on the host machine to others ports. 
  The mapped ports are defined in Vagrantfile by default and are mapped to **2220,2221,2221**. For this reason, 
  it is very important that these ports are free.
  Note: We can also use these ports to communicate with virtual nodes through ssh.
* Other ports that flink need free are: **6123,8080,8081**

## Getting Started
If you meet all the prerequisites, just run `./cluster-up.sh`in your favorite terminal emulator.

## Project architecture

### Vagrant
The Vagrant folder contains the Vagrant configuration file. This file defines the number of virtual nodes and their configuration. 
In this case, the file defines three nodes with Ubuntu 20.04 (one as Flink's Jobmanager and two as Flink's Taskmanager)

For each node, Vagrant calls the Ansible pipeline to provision the node.

### Ansible 

When Ansible is called by Vagrant the entrypoint is [site.yml](ansible/site.yml). 
This yml define pipeline per [roles](https://docs.ansible.com/ansible/latest/user_guide/playbooks_reuse_roles.html) /hosts.
The hosts(nodegroup or single node), with their hostname , are defined in [inventory](ansible/inventory). Hostnames are the same of Vagrantfile.
Inventory file also contain ssh properties, for example: `jobmanager ansible_ssh_host=127.0.0.1 ansible_ssh_port=2220 ansible_ssh_user=vagrant ansible_ssh_pass=vagrant`

The project folder structure follows the best practices proposed by Ansible ([directory-layout](https://docs.ansible.com/ansible/2.8/user_guide/playbooks_best_practices.html#directory-layout)).

#### Step-By-Step provisioning
##### Common role

The common role runs for all nodes:
* The first part downloads the JDK and adds the environmental variable to the path.
* The second downloads the Flink and adds the environmental variable to the route.
* Finally, the Flink configuration files ([flink-conf.yaml](ansible/roles/common/files/flink-conf.yaml),[master](ansible/roles/common/files/masters), [slave](ansible/roles/common/files/masters)) are added.

##### Start-cluster role 

The cluster startup role is only executed by the Jobmanager node although some tasks are delegated to the taskmanager nodes.
The task managers and jobmanager are registered in the cluster. 

##### Workaround
If you don't want to download the JDK and Flink, you can add the .zip files to the [files](ansible/roles/common/files) folder.
Ansible will detect zip files and skip downloads

## Health check
Finally, if everything is correct, the browser accesses the GUI.  `localhost:8081`