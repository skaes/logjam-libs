.PHONY: install install-usr-local install-opt-logjam clean release publish tag push

install: install-usr-local

install-usr-local:
	./bin/install-libs

install-opt-logjam:
	./bin/install-libs --prefix=/opt/logjam

clean:
	rm -rf builds/repos/*
	docker ps -a | awk '/Exited/ {print $$1;}' | xargs docker rm
	docker images | awk '/none|fpm-(fry|dockery)/ {print $$3;}' | xargs docker rmi

CONTAINERS:=container-bionic container-xenial container-bionic-usr-local container-xenial-usr-local
.PHONY: containers $(CONTAINERS)

containers: $(CONTAINERS)

container-bionic:
	docker build -t "stkaes/logjam-libs:bionic-latest" -f Dockerfile.bionic --build-arg prefix=/opt/logjam bin
container-xenial:
	docker build -t "stkaes/logjam-libs:xenial-latest" -f Dockerfile.xenial --build-arg prefix=/opt/logjam bin
container-bionic-usr-local:
	docker build -t "stkaes/logjam-libs:bionic-usr-local-latest" -f Dockerfile.bionic --build-arg prefix=/usr/local bin
container-xenial-usr-local:
	docker build -t "stkaes/logjam-libs:xenial-usr-local-latest" -f Dockerfile.xenial --build-arg prefix=/usr/local bin

TAG ?= latest
VERSION ?= $(shell ./bin/version)

release: containers push
	$(MAKE) $(MFLAGS) tag push TAG=$(VERSION)

tag:
	docker tag "stkaes/logjam-libs:bionic-latest" "stkaes/logjam-libs:bionic-$(TAG)"
	docker tag "stkaes/logjam-libs:xenial-latest" "stkaes/logjam-libs:xenial-$(TAG)"
	docker tag "stkaes/logjam-libs:bionic-usr-local-latest" "stkaes/logjam-libs:bionic-usr-local-$(TAG)"
	docker tag "stkaes/logjam-libs:xenial-usr-local-latest" "stkaes/logjam-libs:xenial-usr-local-$(TAG)"

push:
	docker push "stkaes/logjam-libs:bionic-$(TAG)"
	docker push "stkaes/logjam-libs:xenial-$(TAG)"
	docker push "stkaes/logjam-libs:bionic-usr-local-$(TAG)"
	docker push "stkaes/logjam-libs:xenial-usr-local-$(TAG)"


PACKAGES:= package-bionic package-bionic-usr-local package-xenial package-xenial-usr-local
.PHONY: packages $(PACKAGES)

packages: $(PACKAGES)

package-bionic:
	LOGJAM_PREFIX=/opt/logjam bundle exec fpm-fry cook --update=always stkaes/logjam-libs:bionic-latest build_libs.rb
	mkdir -p packages/ubuntu/bionic && mv *.deb packages/ubuntu/bionic
package-xenial:
	LOGJAM_PREFIX=/opt/logjam bundle exec fpm-fry cook --update=always stkaes/logjam-libs:xenial-latest build_libs.rb
	mkdir -p packages/ubuntu/xenial && mv *.deb packages/ubuntu/xenial
package-bionic-usr-local:
	LOGJAM_PREFIX=/usr/local bundle exec fpm-fry cook --update=always stkaes/logjam-libs:bionic-usr-local-latest build_libs.rb
	mkdir -p packages/ubuntu/bionic && mv *.deb packages/ubuntu/bionic
package-xenial-usr-local:
	LOGJAM_PREFIX=/usr/local bundle exec fpm-fry cook --update=always stkaes/logjam-libs:xenial-usr-local-latest build_libs.rb
	mkdir -p packages/ubuntu/xenial && mv *.deb packages/ubuntu/xenial


LOGJAM_PACKAGE_HOST:=railsexpress.de
LOGJAM_PACKAGE_USER:=uploader
publish:
	rsync -vrlptDz -e "ssh -l $(LOGJAM_PACKAGE_USER)" packages/ubuntu/bionic/* $(LOGJAM_PACKAGE_HOST):/var/www/packages/ubuntu/bionic/
	ssh $(LOGJAM_PACKAGE_USER)@$(LOGJAM_PACKAGE_HOST) 'cd /var/www/packages/ubuntu/bionic && (dpkg-scanpackages . /dev/null | gzip >Packages.gz)'
	rsync -vrlptDz -e "ssh -l $(LOGJAM_PACKAGE_USER)" packages/ubuntu/xenial/* $(LOGJAM_PACKAGE_HOST):/var/www/packages/ubuntu/xenial/
	ssh $(LOGJAM_PACKAGE_USER)@$(LOGJAM_PACKAGE_HOST) 'cd /var/www/packages/ubuntu/xenial && (dpkg-scanpackages . /dev/null | gzip >Packages.gz)'
