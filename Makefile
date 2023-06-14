.PHONY: install install-usr-local install-opt-logjam uninstall uninstall-usr-local uninstall-opt-logjam clean

install: install-usr-local

install-usr-local:
	./bin/install-libs install

install-opt-logjam:
	./bin/install-libs --prefix=/opt/logjam install

uninstall: uninstall-usr-local

uninstall-usr-local:
	./bin/install-libs uninstall

uninstall-opt-logjam:
	./bin/install-libs --prefix=/opt/logjam uninstall

clean:
	rm -rf builds/repos/*
	docker ps -a | awk '/Exited/ {print $$1;}' | xargs docker rm
	docker images | awk '/none|fpm-(fry|dockery)/ {print $$3;}' | xargs docker rmi

ARCH := amd64

ifeq ($(ARCH),)
PLATFORM :=
LIBARCH :=
else
PLATFORM := --platform $(ARCH)
LIBARCH := $(ARCH:arm64=arm64v8)/
endif

CONTAINERS:=container-jammy container-jammy-usr-local container-focal container-bionic container-focal-usr-local container-bionic-usr-local
.PHONY: containers $(CONTAINERS)

containers: $(CONTAINERS)

container-jammy:
	docker build -t "stkaes/logjam-libs:jammy-latest-$(ARCH)" -f Dockerfile.jammy --build-arg prefix=/opt/logjam --build-arg arch=$(LIBARCH) bin
container-focal:
	docker build -t "stkaes/logjam-libs:focal-latest-$(ARCH)" -f Dockerfile.focal --build-arg prefix=/opt/logjam --build-arg arch=$(LIBARCH) bin
container-bionic:
	docker build -t "stkaes/logjam-libs:bionic-latest-$(ARCH)" -f Dockerfile.bionic --build-arg prefix=/opt/logjam --build-arg arch=$(LIBARCH) bin
container-jammy-usr-local:
	docker build -t "stkaes/logjam-libs:jammy-usr-local-latest-$(ARCH)" -f Dockerfile.jammy --build-arg prefix=/usr/local --build-arg arch=$(LIBARCH) bin
container-focal-usr-local:
	docker build -t "stkaes/logjam-libs:focal-usr-local-latest-$(ARCH)" -f Dockerfile.focal --build-arg prefix=/usr/local --build-arg arch=$(LIBARCH) bin
container-bionic-usr-local:
	docker build -t "stkaes/logjam-libs:bionic-usr-local-latest-$(ARCH)" -f Dockerfile.bionic --build-arg prefix=/usr/local --build-arg arch=$(LIBARCH) bin

TAG ?= latest
VERSION ?= $(shell ./bin/version)

RELEASE:=release-jammy release-jammy-usr-local release-focal release-bionic release-focal-usr-local release-bionic-usr-local
.PHONY: release $(RELEASE)

release: $(RELEASE)

release-jammy:
	$(MAKE) $(MFLAGS) tag-jammy push-jammy TAG=$(VERSION) ARCH=$(ARCH)
release-focal:
	$(MAKE) $(MFLAGS) tag-focal push-focal TAG=$(VERSION) ARCH=$(ARCH)
release-bionic:
	$(MAKE) $(MFLAGS) tag-bionic push-bionic TAG=$(VERSION) ARCH=$(ARCH)
release-jammy-usr-local:
	$(MAKE) $(MFLAGS) tag-jammy-usr-local push-jammy-usr-local TAG=$(VERSION) ARCH=$(ARCH)
release-focal-usr-local:
	$(MAKE) $(MFLAGS) tag-focal-usr-local push-focal-usr-local TAG=$(VERSION) ARCH=$(ARCH)
release-bionic-usr-local:
	$(MAKE) $(MFLAGS) tag-bionic-usr-local push-bionic-usr-local TAG=$(VERSION) ARCH=$(ARCH)

TAGS:=tag-jammy tag-jammy-usr-local tag-focal tag-bionic  tag-focal-usr-local tag-bionic-usr-local
.PHONY: tag $(TAGS)

tag: $(TAGS)

tag-jammy:
	docker tag "stkaes/logjam-libs:jammy-latest" "stkaes/logjam-libs:jammy-$(TAG)-$(ARCH)"
tag-focal:
	docker tag "stkaes/logjam-libs:focal-latest" "stkaes/logjam-libs:focal-$(TAG)-$(ARCH)"
tag-bionic:
	docker tag "stkaes/logjam-libs:bionic-latest" "stkaes/logjam-libs:bionic-$(TAG)-$(ARCH)"
tag-jammy-usr-local:
	docker tag "stkaes/logjam-libs:jammy-usr-local-latest" "stkaes/logjam-libs:jammy-usr-local-$(TAG)-$(ARCH)"
tag-focal-usr-local:
	docker tag "stkaes/logjam-libs:focal-usr-local-latest" "stkaes/logjam-libs:focal-usr-local-$(TAG)-$(ARCH)"
tag-bionic-usr-local:
	docker tag "stkaes/logjam-libs:bionic-usr-local-latest" "stkaes/logjam-libs:bionic-usr-local-$(TAG)-$(ARCH)"


PUSHES:=push-jammy push-focal push-bionic push-jammy-usr-local push-focal-usr-local push-bionic-usr-local
.PHONY: push $(PUSHES)

push: $(PUSHES)

push-jammy:
	docker push "stkaes/logjam-libs:jammy-$(TAG)-$(ARCH)"
push-focal:
	docker push "stkaes/logjam-libs:focal-$(TAG)-$(ARCH)"
push-bionic:
	docker push "stkaes/logjam-libs:bionic-$(TAG)-$(ARCH)"
push-jammy-usr-local:
	docker push "stkaes/logjam-libs:jammy-usr-local-$(TAG)-$(ARCH)"
push-focal-usr-local:
	docker push "stkaes/logjam-libs:focal-usr-local-$(TAG)-$(ARCH)"
push-bionic-usr-local:
	docker push "stkaes/logjam-libs:bionic-usr-local-$(TAG)-$(ARCH)"


PACKAGES:=package-jammy package-jammy-usr-local package-focal package-focal-usr-local package-bionic package-bionic-usr-local
.PHONY: packages $(PACKAGES)

packages: $(PACKAGES)

ifeq ($(V),1)
override V:=--verbose
else
override V:=
endif

package-jammy:
	LOGJAM_PREFIX=/opt/logjam bundle exec fpm-fry cook $(V) $(PLATFORM) --update=always stkaes/logjam-libs:jammy-latest-$(ARCH) build_libs.rb
	mkdir -p packages/ubuntu/jammy && mv *.deb packages/ubuntu/jammy
package-focal:
	LOGJAM_PREFIX=/opt/logjam bundle exec fpm-fry cook $(V) $(PLATFORM) --update=always stkaes/logjam-libs:focal-latest-$(ARCH) build_libs.rb
	mkdir -p packages/ubuntu/focal && mv *.deb packages/ubuntu/focal
package-bionic:
	LOGJAM_PREFIX=/opt/logjam bundle exec fpm-fry cook $(V) $(PLATFORM) --update=always stkaes/logjam-libs:bionic-latest-$(ARCH) build_libs.rb
	mkdir -p packages/ubuntu/bionic && mv *.deb packages/ubuntu/bionic
package-jammy-usr-local:
	LOGJAM_PREFIX=/usr/local bundle exec fpm-fry cook $(V) $(PLATFORM) --update=always stkaes/logjam-libs:jammy-usr-local-latest-$(ARCH) build_libs.rb
	mkdir -p packages/ubuntu/jammy && mv *.deb packages/ubuntu/jammy
package-focal-usr-local:
	LOGJAM_PREFIX=/usr/local bundle exec fpm-fry cook $(V) $(PLATFORM) --update=always stkaes/logjam-libs:focal-usr-local-latest-$(ARCH) build_libs.rb
	mkdir -p packages/ubuntu/focal && mv *.deb packages/ubuntu/focal
package-bionic-usr-local:
	LOGJAM_PREFIX=/usr/local bundle exec fpm-fry cook $(V) $(PLATFORM) --update=always stkaes/logjam-libs:bionic-usr-local-latest-$(ARCH) build_libs.rb
	mkdir -p packages/ubuntu/bionic && mv *.deb packages/ubuntu/bionic


LOGJAM_PACKAGE_HOST:=railsexpress.de
LOGJAM_PACKAGE_USER:=uploader

.PHONY: publish publish-focal publish-bionic publish-jammy publish-focal-usr-local publish-bionic-usr-local publish-jammy-usr-local
publish: publish-jammy publish-focal publish-bionic publish-jammy-usr-local publish-focal-usr-local publish-bionic-usr-local

VERSION:=$(shell bin/version)
PACKAGE_NAME:=logjam-libs_$(VERSION)_$(ARCH).deb
PACKAGE_NAME_USR_LOCAL:=logjam-libs-usr-local_$(VERSION)_$(ARCH).deb

define upload-package
@if ssh $(LOGJAM_PACKAGE_USER)@$(LOGJAM_PACKAGE_HOST) debian-package-exists $(1) $(2); then\
  echo package $(2) already exists on the server;\
else\
  tmpdir=`ssh $(LOGJAM_PACKAGE_USER)@$(LOGJAM_PACKAGE_HOST) mktemp -d` &&\
  rsync -vrlptDz -e "ssh -l $(LOGJAM_PACKAGE_USER)" packages/ubuntu/$(1)/$(2) $(LOGJAM_PACKAGE_HOST):$$tmpdir &&\
  ssh $(LOGJAM_PACKAGE_USER)@$(LOGJAM_PACKAGE_HOST) add-new-debian-packages $(1) $$tmpdir;\
fi
endef

publish-jammy:
	$(call upload-package,jammy,$(PACKAGE_NAME))
publish-focal:
	$(call upload-package,focal,$(PACKAGE_NAME))
publish-bionic:
	$(call upload-package,bionic,$(PACKAGE_NAME))
publish-jammy-usr-local:
	$(call upload-package,jammy,$(PACKAGE_NAME_USR_LOCAL))
publish-focal-usr-local:
	$(call upload-package,focal,$(PACKAGE_NAME_USR_LOCAL))
publish-bionic-usr-local:
	$(call upload-package,bionic,$(PACKAGE_NAME_USR_LOCAL))
