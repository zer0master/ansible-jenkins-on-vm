# just can't escape it, can we?
#

VAULT_PASSWD_FILE := ~/.ssh/.vp

# currently supported tags (if used, quote list with comma delimiters, no spaces):
# - certspull
# - certupdate
# - java
# - jenkins
# - nginx
ifdef TAGS
TAGOPT := --tags "$(TAGS)"
endif


.PHONY: \
	help \
	pull-certs \
	setup-jenkins \
	update-certs

setup-jenkins: pull-certs
	ansible-playbook $(TAGOPT) \
		-vv \
		--inventory hosts.yml \
		--vault-password-file ${VAULT_PASSWD_FILE} \
		site.yml

# show available targets
help:
	@awk '/^[-a-z]+:/' Makefile | cut -f1 -d\  | sort

# general "pull certs-as-is" based on FQDN setting
pull-certs:
	$(if $(FQDN),,$(error FQDN must be set))
	ansible-playbook \
		-vv \
		--inventory hosts.yml \
		--vault-password-file ${VAULT_PASSWD_FILE} \
		--extra-vars server_fqdn=${FQDN} \
		pullcerts.yml

update-certs:
	@echo update-certs
