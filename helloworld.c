#include <stdio.h>
#include <unistd.h>

extern int add(int, int);
extern int gettid(void);

int main(void)
{
	int result = add(2, 2);
	/* write(1, "from helloworld", 15); */
	printf("Hello, World! 2+2=");
	char buffer[10];
	for (int i = 0; i < 10; i++ ) buffer[i] = 0;
	buffer[0] = '0' + result;
	puts(buffer);

	// requires posix-process, process and thread ids
	puts("Attempting gettid()");
	printf("tid=%d\n", gettid());

	return 0;
}
