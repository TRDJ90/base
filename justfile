default:
    just --list

prepare:
    zigup 0.13.0-dev.46+3648d7df1

build: 
    zig build

run:
    zig build run-gui

test: 
    zig build test
