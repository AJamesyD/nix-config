BINARY = bin/network_load

all: $(BINARY)

$(BINARY): network_load.c network.h ../sketchybar.h | bin
	clang -std=c99 -O3 network_load.c -o $(BINARY)

bin:
	mkdir -p bin

clean:
	rm -f $(BINARY)

.PHONY: all clean
