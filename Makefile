PIP := $(shell command -v pip || command -v pip3)

# Default target
.DEFAULT_GOAL := bootstrap

#
# Bootstrap
#

.PHONY: bootstrap
bootstrap: pip-deps galaxy-update

.PHONY: update
update: galaxy-update

.PHONY: pip-deps
pip-deps:
	$(PIP) install -r requirements.txt

.PHONY: galaxy
galaxy:
	ansible-galaxy install -r requirements.yml

.PHONY: galaxy-update
galaxy-update:
	ansible-galaxy install -f -r requirements.yml

#
# Provision
#

INTERNAL_ANSIBLE_ARGS =

ifeq ($(INVENTORY),production)
INTERNAL_ANSIBLE_ARGS += --ask-become-pass
endif

ifeq ($(INVENTORY),staging)
INTERNAL_ANSIBLE_ARGS += --ask-become-pass
endif

ifdef ANSIBLE_USER
INTERNAL_ANSIBLE_ARGS += -e "ansible_user=$(ANSIBLE_USER)"
endif

ifdef APT_UPGRADE
INTERNAL_ANSIBLE_ARGS += -e "packages_apt_upgrade=true"
endif

ifdef APT_DIST_UPGRADE
INTERNAL_ANSIBLE_ARGS += -e "packages_apt_dist_upgrade=true"
endif

ifdef TAGS
INTERNAL_ANSIBLE_ARGS += --tags "$(TAGS)"
endif

ifdef GROUP
INTERNAL_ANSIBLE_ARGS += --limit "$(GROUP)"
endif

ifneq ($(ANSIBLE_ARGS),)
INTERNAL_ANSIBLE_ARGS += $(ANSIBLE_ARGS)
endif

.PHONY: ping
ping:
	$(if $(INVENTORY),,$(error INVENTORY environment variable is not set))
	$(if $(shell test -e inventories/$(INVENTORY) && echo "yes"),,\
		$(error "inventories/$(INVENTORY)" does not exist))
	ansible -i inventories/$(INVENTORY) $(INTERNAL_ANSIBLE_ARGS) -m ping all

.PHONY: provision
provision:
	$(if $(INVENTORY),,$(error INVENTORY environment variable is not set))
	$(if $(shell test -e inventories/$(INVENTORY) && echo "yes"),,\
		$(error "inventories/$(INVENTORY)" does not exist))
	ansible-playbook -i inventories/$(INVENTORY) \
		site.yml $(INTERNAL_ANSIBLE_ARGS)

.PHONY: deploy
deploy:
	$(if $(INVENTORY),,$(error INVENTORY environment variable is not set))
	$(if $(shell test -e inventories/$(INVENTORY) && echo "yes"),,\
		$(error "inventories/$(INVENTORY)" does not exist))
	ansible-playbook -i inventories/$(INVENTORY) \
		deploy.yml $(INTERNAL_ANSIBLE_ARGS)
