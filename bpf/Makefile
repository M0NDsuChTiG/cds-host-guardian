TARGET := shield.bpf.o
SRC := shield.bpf.c

# Флаги компилятора clang для целевой архитектуры BPF
CFLAGS := -O2 -g -target bpf -D__TARGET_ARCH_x86

all: $(TARGET)

$(TARGET): $(SRC)
	clang $(CFLAGS) -c $< -o $@

clean:
	rm -f $(TARGET)
