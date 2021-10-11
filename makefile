build:
	docker build -t docker-snapcraft .

clean:
	git reset --hard
	git pull
	git --no-pager log -1
