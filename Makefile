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

CONTAINERS:=container-noble container-noble-usr-local container-jammy container-jammy-usr-local container-focal container-focal-usr-local
.PHONY: containers $(CONTAINERS)

containers: $(CONTAINERS)

container-noble:
	docker build -t "stkaes/logjam-libs:noble-latest-$(ARCH)" -f Dockerfile.noble --build-arg prefix=/opt/logjam --build-arg arch=$(LIBARCH) bin
container-jammy:
	docker build -t "stkaes/logjam-libs:jammy-latest-$(ARCH)" -f Dockerfile.jammy --build-arg prefix=/opt/logjam --build-arg arch=$(LIBARCH) bin
container-focal:
	docker build -t "stkaes/logjam-libs:focal-latest-$(ARCH)" -f Dockerfile.focal --build-arg prefix=/opt/logjam --build-arg arch=$(LIBARCH) bin
container-noble-usr-local:
	docker build -t "stkaes/logjam-libs:noble-usr-local-latest-$(ARCH)" -f Dockerfile.noble --build-arg prefix=/usr/local --build-arg arch=$(LIBARCH) bin
container-jammy-usr-local:
	docker build -t "stkaes/logjam-libs:jammy-usr-local-latest-$(ARCH)" -f Dockerfile.jammy --build-arg prefix=/usr/local --build-arg arch=$(LIBARCH) bin
container-focal-usr-local:
	docker build -t "stkaes/logjam-libs:focal-usr-local-latest-$(ARCH)" -f Dockerfile.focal --build-arg prefix=/usr/local --build-arg arch=$(LIBARCH) bin

TAG ?= latest
VERSION ?= $(shell ./bin/version)

RELEASE:=release-noble release-noble-usr-local release-jammy release-jammy-usr-local release-focal release-focal-usr-local
.PHONY: release $(RELEASE)

release: $(RELEASE)

release-noble:
	$(MAKE) $(MFLAGS) tag-noble push-noble TAG=$(VERSION) ARCH=$(ARCH)
release-jammy:
	$(MAKE) $(MFLAGS) tag-jammy push-jammy TAG=$(VERSION) ARCH=$(ARCH)
release-focal:
	$(MAKE) $(MFLAGS) tag-focal push-focal TAG=$(VERSION) ARCH=$(ARCH)
release-noble-usr-local:
	$(MAKE) $(MFLAGS) tag-noble-usr-local push-noble-usr-local TAG=$(VERSION) ARCH=$(ARCH)
release-jammy-usr-local:
	$(MAKE) $(MFLAGS) tag-jammy-usr-local push-jammy-usr-local TAG=$(VERSION) ARCH=$(ARCH)
release-focal-usr-local:
	$(MAKE) $(MFLAGS) tag-focal-usr-local push-focal-usr-local TAG=$(VERSION) ARCH=$(ARCH)

TAGS:=tag-noble tag-noble-usr-local tag-jammy tag-jammy-usr-local tag-focal tag-focal-usr-local
.PHONY: tag $(TAGS)

tag: $(TAGS)

tag-noble:
	docker tag "stkaes/logjam-libs:noble-latest" "stkaes/logjam-libs:noble-$(TAG)-$(ARCH)"
tag-jammy:
	docker tag "stkaes/logjam-libs:jammy-latest" "stkaes/logjam-libs:jammy-$(TAG)-$(ARCH)"
tag-focal:
	docker tag "stkaes/logjam-libs:focal-latest" "stkaes/logjam-libs:focal-$(TAG)-$(ARCH)"
tag-noble-usr-local:
	docker tag "stkaes/logjam-libs:noble-usr-local-latest" "stkaes/logjam-libs:noble-usr-local-$(TAG)-$(ARCH)"
tag-jammy-usr-local:
	docker tag "stkaes/logjam-libs:jammy-usr-local-latest" "stkaes/logjam-libs:jammy-usr-local-$(TAG)-$(ARCH)"
tag-focal-usr-local:
	docker tag "stkaes/logjam-libs:focal-usr-local-latest" "stkaes/logjam-libs:focal-usr-local-$(TAG)-$(ARCH)"


PUSHES:=push-noble push-jammy push-focal push-noble-usr-local push-jammy-usr-local push-focal-usr-local
.PHONY: push $(PUSHES)

push: $(PUSHES)

push-noble:
	docker push "stkaes/logjam-libs:noble-$(TAG)-$(ARCH)"
push-jammy:
	docker push "stkaes/logjam-libs:jammy-$(TAG)-$(ARCH)"
push-focal:
	docker push "stkaes/logjam-libs:focal-$(TAG)-$(ARCH)"
push-noble-usr-local:
	docker push "stkaes/logjam-libs:noble-usr-local-$(TAG)-$(ARCH)"
push-jammy-usr-local:
	docker push "stkaes/logjam-libs:jammy-usr-local-$(TAG)-$(ARCH)"
push-focal-usr-local:
	docker push "stkaes/logjam-libs:focal-usr-local-$(TAG)-$(ARCH)"


PACKAGES:=package-noble package-noble-usr-local package-jammy package-jammy-usr-local package-focal package-focal-usr-local
.PHONY: packages $(PACKAGES)

packages: $(PACKAGES)

ifeq ($(V),1)
override V:=--verbose
else
override V:=
endif

package-noble:
	LOGJAM_PREFIX=/opt/logjam bundle exec fpm-fry cook $(V) $(PLATFORM) --update=always stkaes/logjam-libs:noble-latest-$(ARCH) build_libs.rb
	mkdir -p packages/ubuntu/noble && mv *.deb packages/ubuntu/noble
package-jammy:
	LOGJAM_PREFIX=/opt/logjam bundle exec fpm-fry cook $(V) $(PLATFORM) --update=always stkaes/logjam-libs:jammy-latest-$(ARCH) build_libs.rb
	mkdir -p packages/ubuntu/jammy && mv *.deb packages/ubuntu/jammy
package-focal:
	LOGJAM_PREFIX=/opt/logjam bundle exec fpm-fry cook $(V) $(PLATFORM) --update=always stkaes/logjam-libs:focal-latest-$(ARCH) build_libs.rb
	mkdir -p packages/ubuntu/focal && mv *.deb packages/ubuntu/focal
package-noble-usr-local:
	LOGJAM_PREFIX=/usr/local bundle exec fpm-fry cook $(V) $(PLATFORM) --update=always stkaes/logjam-libs:noble-usr-local-latest-$(ARCH) build_libs.rb
	mkdir -p packages/ubuntu/noble && mv *.deb packages/ubuntu/noble
package-jammy-usr-local:
	LOGJAM_PREFIX=/usr/local bundle exec fpm-fry cook $(V) $(PLATFORM) --update=always stkaes/logjam-libs:jammy-usr-local-latest-$(ARCH) build_libs.rb
	mkdir -p packages/ubuntu/jammy && mv *.deb packages/ubuntu/jammy
package-focal-usr-local:
	LOGJAM_PREFIX=/usr/local bundle exec fpm-fry cook $(V) $(PLATFORM) --update=always stkaes/logjam-libs:focal-usr-local-latest-$(ARCH) build_libs.rb
	mkdir -p packages/ubuntu/focal && mv *.deb packages/ubuntu/focal


LOGJAM_PACKAGE_HOST:=railsexpress.de
LOGJAM_PACKAGE_USER:=uploader

.PHONY: publish publish-focal publish-jammy publish-focal-usr-local publish-jammy-usr-local
publish: publish-jammy publish-focal publish-jammy-usr-local publish-focal-usr-local

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

publish-noble:
	$(call upload-package,noble,$(PACKAGE_NAME))
publish-jammy:
	$(call upload-package,jammy,$(PACKAGE_NAME))
publish-focal:
	$(call upload-package,focal,$(PACKAGE_NAME))
publish-noble-usr-local:
	$(call upload-package,noble,$(PACKAGE_NAME_USR_LOCAL))
publish-jammy-usr-local:
	$(call upload-package,jammy,$(PACKAGE_NAME_USR_LOCAL))
publish-focal-usr-local:
	$(call upload-package,focal,$(PACKAGE_NAME_USR_LOCAL))
