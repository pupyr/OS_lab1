#include "kernel/types.h"
#include "kernel/stat.h"
#include "user/user.h"

int main(int argc, char **argv){
	int p[2];
	char buf[5];
	pipe(p);
	int pid = fork();

	if(pid==0){
		read(p[0],buf, 5);
		printf("%d: got %s",getpid(), buf);
		write(p[1], "pong\n", 5);
	}else{
		write(p[1],"ping\n",5);
		wait((int *)0);
		read(p[0], buf, 5);
		printf("%d: got %s", getpid(), buf);
	} 
	close(p[0]);
	close(p[1]);

	exit(0);
}
