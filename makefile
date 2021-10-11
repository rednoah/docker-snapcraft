build:
	docker build -t docker-snapcraft .
	docker run -it docker-snapcraft --version

clean:
	git reset --hard
	git pull
	git --no-pager log -1
