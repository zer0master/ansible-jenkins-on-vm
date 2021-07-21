# just can't escape it, can we?
#

VAULT_PASSWD_FILE := ~/.ssh/.vp

# currently supported tags (if used, quote list with comma delimiters, no spaces):
# - certspull
# - certupdate
# - java
# - jenkins
# - makekeypair
# - nginx
ifdef TAGS
TAGOPT := --tags "$(TAGS)"
endif


.PHONY: \
	help \
	pull-certs \
	setup-jenkins \
	update-certs

jenkins-revproxy: install-role-deps pull-certs
	ansible-playbook $(TAGOPT) \
		-vv \
		--inventory hosts.yml \
		--vault-password-file ${VAULT_PASSWD_FILE} \
		site.yml

# show available targets
help:
	@awk '/^[-a-z]+:/' Makefile | cut -f1 -d\  | sort

install-role-deps:
	ansible-galaxy role install -vv --role-file requirements.yml --roles-path roles/

#NOTE: recipe-specific condition (FQDN), as opposed to file-level approach (TAGS)
pull-certs:
	$(if $(FQDN),,$(error FQDN must be set))
	ansible-playbook \
		-vv \
		--inventory hosts.yml \
		--vault-password-file ${VAULT_PASSWD_FILE} \
		--extra-vars server_fqdn=${FQDN} \
		pullcerts.yml

remove-installed-roles:
	ansible-galaxy role remove --roles-path roles/ revproxy certupdate certspull

update-certs:
	@echo update-certs
