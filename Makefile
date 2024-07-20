.PHONY: package

.EXPORT_ALL_VARIABLES:

RELEASE_VER = dev

buildImageAmd64:
	docker buildx build --platform linux/amd64 --tag nauni1977/owasp-db-cache:${RELEASE_VER} --load .

buildImageArm64:
	docker buildx build --platform linux/arm64 --tag nauni1977/owasp-db-cache:${RELEASE_VER} --load .

buildImageMultiArch:
	docker buildx build --platform linux/arm64,linux/amd64 --tag nauni1977/owasp-db-cache:${RELEASE_VER} --push .

runLocalPullAndStart:
	docker pull nauni1977/owasp-db-cache:dev
	docker run --rm --name owasp-db -p 3306:3306 -v owasp-db:/var/lib/mysql -v owasp-config:/var/lib/owasp-db-cache -e NVD_API_KEY=6e54e143-9350-4615-971d-7b7a7242ab48 -e UPDATE_INTERVALL="0/5 * * * *" nauni1977/owasp-db-cache:${RELEASE_VER}

runLocalBuildAndStart: buildImageArm64
	docker run --rm --name owasp-db -p 3306:3306 -v owasp-db:/var/lib/mysql -v owasp-config:/var/lib/owasp-db-cache -e NVD_API_KEY=6e54e143-9350-4615-971d-7b7a7242ab48 -e UPDATE_INTERVALL="0/5 * * * *" nauni1977/owasp-db-cache:${RELEASE_VER}

stopLocalContainer:
	docker stop owasp-db

rmVolumeData:
	docker volume rm owasp-config owasp-db