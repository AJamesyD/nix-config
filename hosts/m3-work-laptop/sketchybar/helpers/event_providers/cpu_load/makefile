BINARY = bin/cpu_load

all: $(BINARY)

$(BINARY): cpu_load.c cpu.h ../sketchybar.h | bin
	clang -std=c99 -O3 cpu_load.c -o $(BINARY)

bin:
	mkdir -p bin

clean:
	rm -f $(BINARY)

.PHONY: all clean
