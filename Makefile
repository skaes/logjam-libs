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

CONTAINERS:=container-focal container-bionic container-xenial container-focal-usr-local container-bionic-usr-local container-xenial-usr-local
.PHONY: containers $(CONTAINERS)

containers: $(CONTAINERS)

container-focal:
	docker build -t "stkaes/logjam-libs:focal-latest" -f Dockerfile.focal --build-arg prefix=/opt/logjam bin
container-bionic:
	docker build -t "stkaes/logjam-libs:bionic-latest" -f Dockerfile.bionic --build-arg prefix=/opt/logjam bin
container-xenial:
	docker build -t "stkaes/logjam-libs:xenial-latest" -f Dockerfile.xenial --build-arg prefix=/opt/logjam bin
container-focal-usr-local:
	docker build -t "stkaes/logjam-libs:focal-usr-local-latest" -f Dockerfile.focal --build-arg prefix=/usr/local bin
container-bionic-usr-local:
	docker build -t "stkaes/logjam-libs:bionic-usr-local-latest" -f Dockerfile.bionic --build-arg prefix=/usr/local bin
container-xenial-usr-local:
	docker build -t "stkaes/logjam-libs:xenial-usr-local-latest" -f Dockerfile.xenial --build-arg prefix=/usr/local bin

TAG ?= latest
VERSION ?= $(shell ./bin/version)

RELEASE:=release-focal release-bionic release-xenial release-focal-usr-local release-bionic-usr-local release-xenial-usr-local
.PHONY: release $(RELEASE)

release: $(RELEASE)

release-focal:
	$(MAKE) $(MFLAGS) tag-focal push-focal TAG=$(VERSION)
release-bionic:
	$(MAKE) $(MFLAGS) tag-bionic push-bionic TAG=$(VERSION)
release-xenial:
	$(MAKE) $(MFLAGS) tag-xenial push-xenial TAG=$(VERSION)
release-focal-usr-local:
	$(MAKE) $(MFLAGS) tag-focal-usr-local push-focal-usr-local TAG=$(VERSION)
release-bionic-usr-local:
	$(MAKE) $(MFLAGS) tag-bionic-usr-local push-bionic-usr-local TAG=$(VERSION)
release-xenial-usr-local:
	$(MAKE) $(MFLAGS) tag-xenial-usr-local push-xenial-usr-local TAG=$(VERSION)

TAGS:=tag-focal tag-bionic tag-xenial tag-focal-usr-local tag-bionic-usr-local tag-xenial-usr-local
.PHONY: tag $(TAGS)

tag: $(TAGS)

tag-focal:
	docker tag "stkaes/logjam-libs:focal-latest" "stkaes/logjam-libs:focal-$(TAG)"
tag-bionic:
	docker tag "stkaes/logjam-libs:bionic-latest" "stkaes/logjam-libs:bionic-$(TAG)"
tag-xenial:
	docker tag "stkaes/logjam-libs:xenial-latest" "stkaes/logjam-libs:xenial-$(TAG)"
tag-focal-usr-local:
	docker tag "stkaes/logjam-libs:focal-usr-local-latest" "stkaes/logjam-libs:focal-usr-local-$(TAG)"
tag-bionic-usr-local:
	docker tag "stkaes/logjam-libs:bionic-usr-local-latest" "stkaes/logjam-libs:bionic-usr-local-$(TAG)"
tag-xenial-usr-local:
	docker tag "stkaes/logjam-libs:xenial-usr-local-latest" "stkaes/logjam-libs:xenial-usr-local-$(TAG)"


PUSHES:=push-focal push-bionic push-xenial push-focal-usr-local push-bionic-usr-local push-xenial-usr-local
.PHONY: push $(PUSHES)

push: $(PUSHES)

push-focal:
	docker push "stkaes/logjam-libs:focal-$(TAG)"
push-bionic:
	docker push "stkaes/logjam-libs:bionic-$(TAG)"
push-xenial:
	docker push "stkaes/logjam-libs:xenial-$(TAG)"
push-focal-usr-local:
	docker push "stkaes/logjam-libs:focal-usr-local-$(TAG)"
push-bionic-usr-local:
	docker push "stkaes/logjam-libs:bionic-usr-local-$(TAG)"
push-xenial-usr-local:
	docker push "stkaes/logjam-libs:xenial-usr-local-$(TAG)"


PACKAGES:=package-focal package-focal-usr-local package-bionic package-bionic-usr-local package-xenial package-xenial-usr-local
.PHONY: packages $(PACKAGES)

packages: $(PACKAGES)

package-focal:
	LOGJAM_PREFIX=/opt/logjam bundle exec fpm-fry cook --update=always stkaes/logjam-libs:focal-latest build_libs.rb
	mkdir -p packages/ubuntu/focal && mv *.deb packages/ubuntu/focal
package-bionic:
	LOGJAM_PREFIX=/opt/logjam bundle exec fpm-fry cook --update=always stkaes/logjam-libs:bionic-latest build_libs.rb
	mkdir -p packages/ubuntu/bionic && mv *.deb packages/ubuntu/bionic
package-xenial:
	LOGJAM_PREFIX=/opt/logjam bundle exec fpm-fry cook --update=always stkaes/logjam-libs:xenial-latest build_libs.rb
	mkdir -p packages/ubuntu/xenial && mv *.deb packages/ubuntu/xenial
package-focal-usr-local:
	LOGJAM_PREFIX=/usr/local bundle exec fpm-fry cook --update=always stkaes/logjam-libs:focal-usr-local-latest build_libs.rb
	mkdir -p packages/ubuntu/focal && mv *.deb packages/ubuntu/focal
package-bionic-usr-local:
	LOGJAM_PREFIX=/usr/local bundle exec fpm-fry cook --update=always stkaes/logjam-libs:bionic-usr-local-latest build_libs.rb
	mkdir -p packages/ubuntu/bionic && mv *.deb packages/ubuntu/bionic
package-xenial-usr-local:
	LOGJAM_PREFIX=/usr/local bundle exec fpm-fry cook --update=always stkaes/logjam-libs:xenial-usr-local-latest build_libs.rb
	mkdir -p packages/ubuntu/xenial && mv *.deb packages/ubuntu/xenial


LOGJAM_PACKAGE_HOST:=railsexpress.de
LOGJAM_PACKAGE_USER:=uploader

.PHONY: publish publish-focal publish-bionic publish-xenial publish-focal-usr-local publish-bionic-usr-local publish-xenial-usr-local
publish: publish-focal publish-bionic publish-xenial publish-focal-usr-local publish-bionic-usr-local publish-xenial-usr-local

VERSION:=$(shell bin/version)
PACKAGE_NAME:=logjam-libs_$(VERSION)_amd64.deb
PACKAGE_NAME_USR_LOCAL:=logjam-libs-usr-local_$(VERSION)_amd64.deb

define upload-package
@if ssh $(LOGJAM_PACKAGE_USER)@$(LOGJAM_PACKAGE_HOST) debian-package-exists $(1) $(2); then\
  echo package $(2) already exists on the server;\
else\
  tmpdir=`ssh $(LOGJAM_PACKAGE_USER)@$(LOGJAM_PACKAGE_HOST) mktemp -d` &&\
  rsync -vrlptDz -e "ssh -l $(LOGJAM_PACKAGE_USER)" packages/ubuntu/$(1)/$(2) $(LOGJAM_PACKAGE_HOST):$$tmpdir &&\
  ssh $(LOGJAM_PACKAGE_USER)@$(LOGJAM_PACKAGE_HOST) add-new-debian-packages $(1) $$tmpdir;\
fi
endef

publish-focal:
	$(call upload-package,focal,$(PACKAGE_NAME))

publish-bionic:
	$(call upload-package,bionic,$(PACKAGE_NAME))

publish-xenial:
	$(call upload-package,xenial,$(PACKAGE_NAME))

publish-focal-usr-local:
	$(call upload-package,focal,$(PACKAGE_NAME_USR_LOCAL))

publish-bionic-usr-local:
	$(call upload-package,bionic,$(PACKAGE_NAME_USR_LOCAL))

publish-xenial-usr-local:
	$(call upload-package,xenial,$(PACKAGE_NAME_USR_LOCAL))
