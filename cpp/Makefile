CC=g++
CFLAGS=-std=c++11 -O2 `pkg-config opencv --cflags`
LDFLAGS=`pkg-config opencv --cflags --libs`

all: ctex

ctex: filters.o main.o
	$(CC) $(LDFLAGS) $<

debug

.PHONY: all debug
