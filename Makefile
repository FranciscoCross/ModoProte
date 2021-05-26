all: clean asm asmedit

asm: 	
	as -g -o main.o main.S
	ld --oformat binary -o main.img -T link.ld main.o

run_asm:
	qemu-system-i386 -fda main.img -boot a -s -S -monitor stdio

asmedit:
	as -g -o main_edited.o main_edited.S
	ld --oformat binary -o main_edited.img -T link.ld main_edited.o

run_asmedit:
	qemu-system-i386 -fda main_edited.img -boot a -s -S -monitor stdio

clean:
	rm -f *.img
	rm -f *.o
	rm -f *.out