# just can't escape it, can we?
#

#DRYRUN?=""
VAULT_PASSWD_FILE := ~/.ssh/.vp

ifdef TAGS
TAGOPT := --tags "$(TAGS)"
endif

.PHONY: \
	pull-certs \
	setup-jenkins \
	update-certs


# general "pull certs-as-is" based on FQDN setting
pull-certs:
	ansible-playbook \
		-vv \
		--inventory hosts.yml \
		--vault-password-file ${VAULT_PASSWD_FILE} \
		--extra-vars server_fqdn=${FQDN} \
		pullcerts.yml

setup-jenkins:
	ansible-playbook $(TAGOPT) \
		-vv \
		--inventory hosts.yml \
		--vault-password-file ${VAULT_PASSWD_FILE} \
		site.yml

update-certs:
	@echo update-certs
