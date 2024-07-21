.PHONY: package

.EXPORT_ALL_VARIABLES:

RELEASE_VER=dev

NVD_API_KEY=aac132db-0b5e-46cb-af91-efefc2f5a674
UPDATE_INTERVALL="0/5 * * * *"

buildImageAmd64:
	docker buildx build --platform linux/amd64 --tag nauni1977/owasp-db-cache:${RELEASE_VER} --load .

buildImageArm64:
	docker buildx build --platform linux/arm64 --tag nauni1977/owasp-db-cache:${RELEASE_VER} --load .

buildImageMultiArch:
	docker buildx build --platform linux/arm64,linux/amd64 --tag nauni1977/owasp-db-cache:${RELEASE_VER} --push .

runLocalPullAndStart:
	docker pull nauni1977/owasp-db-cache:dev
	docker run --rm --name owasp-db -p 3306:3306 -v owasp-db:/var/lib/mysql -v owasp-config:/var/lib/owasp-db-cache -e NVD_API_KEY=${NVD_API_KEY} -e UPDATE_INTERVALL=${UPDATE_INTERVALL} nauni1977/owasp-db-cache:${RELEASE_VER}

runLocalBuildAndStart: buildImageArm64
	docker run --rm --name owasp-db -p 3306:3306 -v owasp-db:/var/lib/mysql -v owasp-config:/var/lib/owasp-db-cache -e NVD_API_KEY=${NVD_API_KEY} -e UPDATE_INTERVALL=${UPDATE_INTERVALL} nauni1977/owasp-db-cache:${RELEASE_VER}

stopLocalContainer:
	docker stop owasp-db

rmVolumeData:
	docker volume rm owasp-config owasp-db