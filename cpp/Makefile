CC      = g++
CFLAGS  = -std=c++11 -O2
LDFLAGS = `pkg-config --libs opencv`
FILES   = filters.o main.o
all: ctex

ctex: $(FILES)
	$(CC) $(LDFLAGS) -o $@ $(FILES)

%.o: %.cc
	$(CC) $(CFLAGS) -o $@ -c $<

.PHONY: all ctex
