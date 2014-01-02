CC      = c++
CFLAGS  = -std=c++11
LDFLAGS = `pkg-config --libs opencv`
FILES   = filters.o clustering.o main.o

all: CFLAGS += -O2
all: ctex

debug: CFLAGS += -g
debug: ctex

ctex: $(FILES)
	$(CC) $(LDFLAGS) -o $@ $(FILES)

%.o: %.cc
	$(CC) $(CFLAGS) -o $@ -c $<

clean:
	rm -f *.o

.PHONY: all ctex clean
