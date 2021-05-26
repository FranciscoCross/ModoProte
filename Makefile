
ASM: 	
	as -g -o main.o main.S
	ld --oformat binary -o main.img -T link.ld main.o
	qemu-system-i386 -fda main.img -boot a -s -S -monitor stdio

ASMEDIT:
	as -g -o main_edited.o main_edited.S
	ld --oformat binary -o main_edited.img -T link.ld main_edited.o
	qemu-system-i386 -fda main_edited.img -boot a -s -S -monitor stdio

CLEAN:
	rm -f *.img
	rm -f *.o
	rm -f *.out