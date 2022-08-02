all: lambda.zip

lambda.zip: main
	zip -r $@ $<

main: main.go
	GOARCH=amd64 GOOS=linux go build -o $@ $<

clean:
	rm -rfv lambda.zip main

install:
	go get ./...