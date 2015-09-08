CC=gcc
SOURCES=svm-r_classify.c svm-r_learn.c
BINARIES=$(SOURCES:.c=)

all: 
	$(CC) svm-r_learn.c -O3 -I. -lm -o svm-r_learn
	$(CC) svm-r_classify.c -O3 -I. -lm -o svm-r_classify


clean:
	-rm -rfv $(BINARIES) *~ *.o