# ansible-jenkins-on-vm
Evolving setup of controller behind Nginx reverse proxy, using the following assumptions:
* Ubuntu 20 VM (`jenkins-ctrl`) on VMWareESXi (might work on AWS EC2 as well, not tried yet)
* separate host (`knowhere`) renewing certs via LetsEncrypt

Since this is being used in my home lab, there are some references to hosts (`knowhere` and `jenkins-ctrl`) as well as a domain (`ld-projects.com`) that others will have to change. I may genericize that in an update soon.

I use the AWS DNS approach to certificate maintenance myself: Route 53 as the SOA; my hosting service has its records changed to match. At present, user `tivan` stores the certs under `~/tivan/certs` by fqdn; that needs to be externalized.

You'll need to create the `vault` file for the following secrets, and locate the password for it in a secure location; I chose `~/.ssh/.vp` since my VBox VM doesn't permit any incoming connections. Content as follows:
```
ansible_become_pass: (remote ansible user password)
ansible_ssh_pass: (same as ansible_become_pass)
certhost_ssh_pass: (password for host renewing certs)
```
TODOs:
* cert update is a placeholder in the Makefile,; it already is part of the `certupdate` `copy certs to target` task, which should be broken out appropriately
* agent spinup may be addressed later once I get task tags better sorted out; the Makefile already allows it if a quoted comma-delimited form is supplied for TAGS (`--tags` is added if so).

For the present, no warranty expressed or implied. ;)
