build:
	docker build -t mide/minecraft-overviewer:latest -f Dockerfile .

test-dive:
	docker build -t mide/minecraft-overviewer:latest -f Dockerfile .
	docker run --rm -it \
		-v /var/run/docker.sock:/var/run/docker.sock \
		-e CI=true \
		wagoodman/dive:latest "mide/minecraft-overviewer:latest"

test-render:
	@make build
	# TODO get test-data into this directory.
	rm -rvf test-data-output/
	docker run --rm -it \
		-e MINECRAFT_VERSION="1.15.2" \
		-v "$(shell pwd)/test-data:/home/minecraft/server/:ro" \
		-v "$(shell pwd)/test-data-output:/home/minecraft/render/:rw" \
		mide/minecraft-overviewer:latest

test-image:
	@make build
	bundle exec rspec

lint:
	docker pull github/super-linter
	docker run -e RUN_LOCAL=true -v $(shell pwd):/tmp/lint github/super-linter
