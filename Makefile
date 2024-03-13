all: asm result

result: main.cpp my_printf.o
	g++ -no-pie main.cpp my_printf.o -o result

asm: my_printf.asm
	nasm -f elf64 my_printf.asm -o my_printf.o

.PHONY: clean

clean:
	rm -rf *.o result
