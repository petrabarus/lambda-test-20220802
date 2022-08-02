package main

import (
	"context"
	"fmt"
	"io/ioutil"
	"log"
	"net/http"

	"github.com/aws/aws-lambda-go/lambda"
)

func init() {
	fmt.Println("Cold start")
}

func Handler(ctx context.Context) (string, error) {
	resp, err := http.Get("https://example.com")
	if err != nil {
		log.Fatalln(err)
	}
	body, err := ioutil.ReadAll(resp.Body)
	if err != nil {
		log.Fatalln(err)
	}
	sb := string(body)
	return fmt.Sprintf("Hello World! %s", sb), nil
}

func main() {
	lambda.Start(Handler)
}
