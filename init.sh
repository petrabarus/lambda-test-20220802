#!/usr/bin/env bash

cd lambda1 
make
cd ..

cd lambda2
make
cd ..

cp lambda1/lambda.zip terraform/dist/lambda1.zip
cp lambda2/lambda.zip terraform/dist/lambda2.zip
