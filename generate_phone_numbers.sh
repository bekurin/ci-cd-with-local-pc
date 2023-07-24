#!/bin/sh

numbers=$(for i in {1..1000000}; do printf "%011d\n" $i; done)

echo "$numbers" > phone_numbers.txt

echo "Successfully generated 10,000,000 random numbers."
