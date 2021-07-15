# ansible-jenkins-on-vm
Evolving setup of controller behind Nginx reverse proxy, assuming Ubuntu 20 VM (`jenkins-ctrl`). Since this is being used in my home lab, there are some references to hosts (`knowhere` and `jenkins-ctrl`) as well as a domain (`ld-projects.com`) that others will have to change. I may genericize that in an update soon.

Agent spinup may be addressed later once I get task tags better sorted out; the Makefile already allows it if a quoted comma-delimited form is supplied for TAGS (`--tags` is added if so).

For the present, no warranty expressed or implied. ;)
