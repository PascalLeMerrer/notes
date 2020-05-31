
build:
	elm-live src/Main.elm -- --debug --output=build/elm.js

deploy:
	./dark-cli-apple  --canvas pascal-notes build

test:
	elm-test

test-watch:
	elm-test --watch


.PHONY: build

