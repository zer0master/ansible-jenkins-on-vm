# ansible-jenkins-on-vm
Evolving setup of a controller (and maybe agents later) behind Nginx reverse proxy.

## Background
I use the AWS DNS approach to certificate maintenance: Route 53 as the SOA, with the hosting service's records changed to match. The certs are stored under fqdn-named folders; localized assumptions need cleaning up.

## Prerequisites
The following assumptions are in play:
* Ubuntu 20 (currently virtual) on VMWare ESXi; EC2 will probably work as well, but is unverified
* your controller's FQDN and signed certificate must correspond
*  a separate host renews certs via LetsEncrypt

Create a `vault` file in your checkout for the following secrets, and locate the password for it in a secure location; I chose `~/.ssh/.vp` since my laptop VM disallows any incoming connections. Content as follows:
```
ansible_become_pass: (remote sudo-enabled user password)
ansible_ssh_pass: (same as ansible_become_pass)
certhost_ssh_pass: (password for host renewing certs)
```
Another thing to consider is the occasional problem of a previously used target that's recreated, but the prior host key remains in `$HOME/.ssh/known_hosts`, which fails the playbook with a message similar to:
```
{"msg": "Using a SSH password instead of a key is not possible because Host Key checking is enabled and sshpass does not support this.  Please add this host's fingerprint to your known_hosts file to manage this host."}
```
The tasks below can be used for a "first-contact" exception rather than setting `host_key_checking = False` in the relevant ansible config:
```
    - name: Check SSH known_hosts for {{ inventory_hostname }}
      local_action: shell ssh-keygen -F {{ inventory_hostname }}
      register: checkForKnownHostsEntry
      failed_when: false
      changed_when: false
      ignore_errors: yes
    - name: Add {{ inventory_hostname }} to SSH known hosts automatically
      when: checkForKnownHostsEntry.rc == 1
      changed_when: checkForKnownHostsEntry.rc == 1
      set_fact:
        ansible_ssh_common_args: '-o StrictHostKeyChecking=no'
```

## Usage
Simply execute `make FQDN=(yours)` to setup the controller; this pulls in the other modular roles (certificate management and nginx setup), and assumes you've already got a signed certificate chain and passwordless private key pointed to by the `certs_remote_folder` variable.

To setup one or more agents (assuming one or more running VMs), execute `make install-agents` with appropriate inventory.

You may limit tasks based on one or more of the following tags as well, by adding `TAGS="name,..."` to the make command line:
* certspull
* certupdate
* java
* jenkins
* makekeypair
* nginx

## TODOs:
The timetable for any of these remains indeterminate at present:
* add the following packages:
  * `net-tools`
  * `unzip`
  * `dos2unix`
  * `git`
* can the initial password be programmatically entered for the controller?
* the controller public key should be copied to agents' `.ssh/authorized_keys` with correct ownership/permissions
* aspects of the Jenkins CLI should be investigated (install plugins, add agents, etc.)
* look into supporting additional per-agent package installations, such as
  * [Terraform](https://releases.hashicorp.com/terraform/) (with optional determination of latest stable zipfile)
  * [Node JS](https://github.com/nodesource/distributions/blob/master/README.md#debinstall)
  * etc.
* investigate the (allegedly) more flexible approach of using containers for agents based in part on [jenkins/ssh-agent](https://hub.docker.com/r/jenkins/ssh-agent/)
  * it seems that a Java version might be needed on the host as well as in the container
  * investigate how to host toolsets on the host rather than making containers specialized, though there may be advantages to each; `rsync` has possibilities in that regard (and possibly a separate jenkins network for the VMs)
  * if specialized containers are built, the container must have an existing target when providing mount points for files; this requires the use of `touch` in the image's build
* the [distributed builds](https://wiki.jenkins.io/display/JENKINS/Distributed+builds) writeup is also a valuable reference
* if a local dockerhub is used, building specialized containers based on `jenkins/ssh-agent` is probably worthwhile; the simplest validation would be verifying tool versions can be displayed as a test job

As this is used in my home lab, there might still be some cruft that needs tracking down; more when there is more.

As always, no warranty expressed or implied. ;)
