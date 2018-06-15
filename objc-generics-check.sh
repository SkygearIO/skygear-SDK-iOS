#!/bin/sh -e

function print_violations() {
    grep -R --include "*.h" --exclude "*_Private.h" "\(NSArray\|NSMutableArray\|NSDictionary\|NSMutableDictionary\|NSSet\|NSMutableSet\) \*" Pod | sort
}

function print_new_violations() {
    print_violations | comm -13 .objc-generics-exception.txt -
}

function new_violations_count() {
    print_new_violations | head -c1 | wc -c
}

touch .objc-generics-exception.txt

if [ $(new_violations_count) -gt 0 ]; then
    echo "ERROR: The following lines are changed but they lack lightweight generics on collection classes:"
    print_new_violations
    exit 1
fi
