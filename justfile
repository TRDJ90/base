default:
    just --list

build: 
    zig build

run:
    zig build run

test: 
    zig build test
