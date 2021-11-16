all: build push

build:
	docker build . -t cr.yandex/$(REGISTRY_ID)/satisfy:latest 

push:
	docker push cr.yandex/$(REGISTRY_ID)/satisfy:latest 

run: build
	docker run --env APP_DEBUG=0 -p 8080:80 cr.yandex/$(REGISTRY_ID)/satisfy:latest 
