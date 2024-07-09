#include <stdio.h>

/* Linking our zig to libc results in the following undefined symbols:
	mmap64
	dl_iterate_phdr
	getcontext
	sigaction
	write
	close
	realpath
	read
	msync
	munmap
	environ
	openat64
	flock
	fstat64
	dl_iterate_phdr
	getenv
	isatty
 */

// Provide stubs for missing functions
#define UNUSED(x) (void)(x)
#define SEGFAULT() {int *ptr = 0; *ptr = 42;}
void *mmap64(void *addr, size_t length, int prot, int flags,
                  int fd, long int offset){
	UNUSED(addr);
	UNUSED(length);
	UNUSED(prot);
	UNUSED(flags);
	UNUSED(flags);
	UNUSED(fd);
	UNUSED(offset);
	puts("unsupported function mmap called");
	// force a seg fault
  SEGFAULT();
	return 0; // unreachable
}

int dl_iterate_phdr(
                 int (*callback)(struct dl_phdr_info *info,
                                 size_t size, void *data),
                 void *data){
	UNUSED(callback);
	UNUSED(data);
	puts("unsupported function dl_iterate_phdr called");
  SEGFAULT();
  return 0;
}
int getcontext(void *ucp) {
	UNUSED(ucp);
	puts("unsupported function getcontext called");
  SEGFAULT();
  return 0;
 }

int sigaction(int signum, void* act, void* oldact) {
	UNUSED(signum);
	UNUSED(act);
	UNUSED(oldact);
                     // const struct sigaction *_Nullable restrict act,
                     // struct sigaction *_Nullable restrict oldact) {
	puts("unsupported function sigaction called");
  SEGFAULT();
  return 0;
}

#define ANSI_COLOR_RED     "\x1b[31m"
#define ANSI_COLOR_GREEN   "\x1b[32m"
#define ANSI_COLOR_YELLOW  "\x1b[33m"
#define ANSI_COLOR_BLUE    "\x1b[34m"
#define ANSI_COLOR_MAGENTA "\x1b[35m"
#define ANSI_COLOR_CYAN    "\x1b[36m"
#define ANSI_COLOR_RESET   "\x1b[0m"

// TODO: This if is not correct
#if !(defined(CONFIG_LIBPOSIX_TTY) || defined(CONFIG_LIBSYSCALL_SHIM))
	size_t write(int fd, const char *buf, size_t count){
		UNUSED(fd);
		UNUSED(buf);
		UNUSED(count);
		char *color;
		switch (fd) {
			case 1: // stdout
				color = ANSI_COLOR_RESET;
				break;
			case 2:
				color = ANSI_COLOR_RED;
				break;
			default:
				printf("write called on unsupported file descriptor: ");
				char fd_buf[10] = "fd = ";
				fd_buf[5] = '0' + fd;
				fd_buf[6] = 0;
				puts(fd_buf);
				SEGFAULT();
				break;
		}
		if (fd != 1) printf(color);
		if (fd == 2) printf("(stderr): ");
		printf("%.*s", (int)count, buf);
		if (fd != 1) printf(ANSI_COLOR_RESET);
		return count;
	}

	int close(int fd) {
		UNUSED(fd);
											 // const struct sigaction *_Nullable restrict act,
											 // struct sigaction *_Nullable restrict oldact) {
		puts("unsupported function close called");
		SEGFAULT();
		return 0;
	}
	size_t read(int fd, void *buf, size_t count) {
		UNUSED(fd);
		UNUSED(buf);
		UNUSED(count);
		puts("unsupported function read called");
		SEGFAULT();
		return 0;
	}
#endif

char *realpath(const char *path,
                      char *resolved_path) {
	UNUSED(path);
	UNUSED(resolved_path);
                     // const struct sigaction *_Nullable restrict act,
                     // struct sigaction *_Nullable restrict oldact) {
	puts("unsupported function realpath called");
  SEGFAULT();
  return 0;
}

int msync(void *addr, size_t length, int flags) {
	UNUSED(addr);
	UNUSED(length);
	UNUSED(flags);
	puts("unsupported function msync called");
  SEGFAULT();
  return 0;
}
int munmap(void *addr, size_t length) {
	UNUSED(addr);
	UNUSED(length);
	puts("unsupported function munmap called");
  SEGFAULT();
  return 0;
}

int openat64(int fd, const char * path, int oflag, ...) {
	UNUSED(fd);
	UNUSED(path);
	UNUSED(oflag);
	puts("unsupported function openat64 called");
  SEGFAULT();
  return 0;
}

int flock(int fd, int operation) {
	UNUSED(fd);
	UNUSED(operation);
	puts("unsupported function flock called");
  SEGFAULT();
  return 0;
}

int fstat64(int fd, void *statbuf) {
	UNUSED(fd);
	UNUSED(statbuf);
	puts("unsupported function fstat called");
  SEGFAULT();
  return 0;
}
// If .config... file has environment support (CONFIG_LIBPOSIX_ENVIRON=y)
// defined, these variable are handled
#ifndef CONFIG_LIBPOSIX_ENVIRON
	char **environ = 0;
	char *getenv(const char *name) {
		UNUSED(name);
		puts(ANSI_COLOR_RED);
		puts("unsupported function getenv called. use `kraft menu` to configure environment variable support");
		puts("or set CONFIG_LIBPOSIX_ENVIRON in .config.<appname>_<system>-<architecture>");
		puts(ANSI_COLOR_RESET);
		SEGFAULT();
		return 0;
	}
#endif

int isatty(int fd) {
	UNUSED(fd);
	puts("unsupported function isatty called");
  SEGFAULT();
  return 0;
}
