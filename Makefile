.PHONY: up down reset logs passwords test help

help:           ## show targets
	@grep -E '^[a-z-]+:.*##' $(MAKEFILE_LIST) | sed 's/:.*##/ -/'

up:             ## build and start the lab boxes
	docker compose up -d --build

down:           ## stop the boxes (friends' files are kept)
	docker compose down

reset:          ## DANGER: stop and delete ALL friends' files and progress
	docker compose down -v

logs:           ## follow the logs of all boxes
	docker compose logs -f

passwords:      ## print the (generated) passwords of the boxes
	@docker compose logs 2>/dev/null | grep "GENERATED STUDENT PASSWORD" || echo "no generated passwords (you set your own in .env)"

test:           ## run the app tests (needs Python 3.12)
	cd startup/app && python3 -m venv .venv && .venv/bin/pip install -q -r requirements-dev.txt && .venv/bin/python -m pytest -q
