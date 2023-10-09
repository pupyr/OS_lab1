
user/_pingpong:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <main>:
#include "kernel/types.h"
#include "kernel/stat.h"
#include "user/user.h"

int main(int argc, char **argv){
   0:	1101                	addi	sp,sp,-32
   2:	ec06                	sd	ra,24(sp)
   4:	e822                	sd	s0,16(sp)
   6:	1000                	addi	s0,sp,32
	int p[2];
	char buf[5];
	pipe(p);
   8:	fe840513          	addi	a0,s0,-24
   c:	00000097          	auipc	ra,0x0
  10:	362080e7          	jalr	866(ra) # 36e <pipe>
	int pid = fork();
  14:	00000097          	auipc	ra,0x0
  18:	342080e7          	jalr	834(ra) # 356 <fork>

	if(pid==0){
  1c:	e52d                	bnez	a0,86 <main+0x86>
		read(p[0],buf, 5);
  1e:	4615                	li	a2,5
  20:	fe040593          	addi	a1,s0,-32
  24:	fe842503          	lw	a0,-24(s0)
  28:	00000097          	auipc	ra,0x0
  2c:	34e080e7          	jalr	846(ra) # 376 <read>
		printf("%d: got %s",getpid(), buf);
  30:	00000097          	auipc	ra,0x0
  34:	3ae080e7          	jalr	942(ra) # 3de <getpid>
  38:	85aa                	mv	a1,a0
  3a:	fe040613          	addi	a2,s0,-32
  3e:	00001517          	auipc	a0,0x1
  42:	8d250513          	addi	a0,a0,-1838 # 910 <dump_test4_asm+0x48>
  46:	00000097          	auipc	ra,0x0
  4a:	688080e7          	jalr	1672(ra) # 6ce <printf>
		write(p[1], "pong\n", 5);
  4e:	4615                	li	a2,5
  50:	00001597          	auipc	a1,0x1
  54:	8d058593          	addi	a1,a1,-1840 # 920 <dump_test4_asm+0x58>
  58:	fec42503          	lw	a0,-20(s0)
  5c:	00000097          	auipc	ra,0x0
  60:	322080e7          	jalr	802(ra) # 37e <write>
		write(p[1],"ping\n",5);
		wait((int *)0);
		read(p[0], buf, 5);
		printf("%d: got %s", getpid(), buf);
	} 
	close(p[0]);
  64:	fe842503          	lw	a0,-24(s0)
  68:	00000097          	auipc	ra,0x0
  6c:	31e080e7          	jalr	798(ra) # 386 <close>
	close(p[1]);
  70:	fec42503          	lw	a0,-20(s0)
  74:	00000097          	auipc	ra,0x0
  78:	312080e7          	jalr	786(ra) # 386 <close>

	exit(0);
  7c:	4501                	li	a0,0
  7e:	00000097          	auipc	ra,0x0
  82:	2e0080e7          	jalr	736(ra) # 35e <exit>
		write(p[1],"ping\n",5);
  86:	4615                	li	a2,5
  88:	00001597          	auipc	a1,0x1
  8c:	8a058593          	addi	a1,a1,-1888 # 928 <dump_test4_asm+0x60>
  90:	fec42503          	lw	a0,-20(s0)
  94:	00000097          	auipc	ra,0x0
  98:	2ea080e7          	jalr	746(ra) # 37e <write>
		wait((int *)0);
  9c:	4501                	li	a0,0
  9e:	00000097          	auipc	ra,0x0
  a2:	2c8080e7          	jalr	712(ra) # 366 <wait>
		read(p[0], buf, 5);
  a6:	4615                	li	a2,5
  a8:	fe040593          	addi	a1,s0,-32
  ac:	fe842503          	lw	a0,-24(s0)
  b0:	00000097          	auipc	ra,0x0
  b4:	2c6080e7          	jalr	710(ra) # 376 <read>
		printf("%d: got %s", getpid(), buf);
  b8:	00000097          	auipc	ra,0x0
  bc:	326080e7          	jalr	806(ra) # 3de <getpid>
  c0:	85aa                	mv	a1,a0
  c2:	fe040613          	addi	a2,s0,-32
  c6:	00001517          	auipc	a0,0x1
  ca:	84a50513          	addi	a0,a0,-1974 # 910 <dump_test4_asm+0x48>
  ce:	00000097          	auipc	ra,0x0
  d2:	600080e7          	jalr	1536(ra) # 6ce <printf>
  d6:	b779                	j	64 <main+0x64>

00000000000000d8 <_main>:
//
// wrapper so that it's OK if main() does not call exit().
//
void
_main()
{
  d8:	1141                	addi	sp,sp,-16
  da:	e406                	sd	ra,8(sp)
  dc:	e022                	sd	s0,0(sp)
  de:	0800                	addi	s0,sp,16
  extern int main();
  main();
  e0:	00000097          	auipc	ra,0x0
  e4:	f20080e7          	jalr	-224(ra) # 0 <main>
  exit(0);
  e8:	4501                	li	a0,0
  ea:	00000097          	auipc	ra,0x0
  ee:	274080e7          	jalr	628(ra) # 35e <exit>

00000000000000f2 <strcpy>:
}

char*
strcpy(char *s, const char *t)
{
  f2:	1141                	addi	sp,sp,-16
  f4:	e422                	sd	s0,8(sp)
  f6:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
  f8:	87aa                	mv	a5,a0
  fa:	0585                	addi	a1,a1,1
  fc:	0785                	addi	a5,a5,1
  fe:	fff5c703          	lbu	a4,-1(a1)
 102:	fee78fa3          	sb	a4,-1(a5)
 106:	fb75                	bnez	a4,fa <strcpy+0x8>
    ;
  return os;
}
 108:	6422                	ld	s0,8(sp)
 10a:	0141                	addi	sp,sp,16
 10c:	8082                	ret

000000000000010e <strcmp>:

int
strcmp(const char *p, const char *q)
{
 10e:	1141                	addi	sp,sp,-16
 110:	e422                	sd	s0,8(sp)
 112:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
 114:	00054783          	lbu	a5,0(a0)
 118:	cb91                	beqz	a5,12c <strcmp+0x1e>
 11a:	0005c703          	lbu	a4,0(a1)
 11e:	00f71763          	bne	a4,a5,12c <strcmp+0x1e>
    p++, q++;
 122:	0505                	addi	a0,a0,1
 124:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
 126:	00054783          	lbu	a5,0(a0)
 12a:	fbe5                	bnez	a5,11a <strcmp+0xc>
  return (uchar)*p - (uchar)*q;
 12c:	0005c503          	lbu	a0,0(a1)
}
 130:	40a7853b          	subw	a0,a5,a0
 134:	6422                	ld	s0,8(sp)
 136:	0141                	addi	sp,sp,16
 138:	8082                	ret

000000000000013a <strlen>:

uint
strlen(const char *s)
{
 13a:	1141                	addi	sp,sp,-16
 13c:	e422                	sd	s0,8(sp)
 13e:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
 140:	00054783          	lbu	a5,0(a0)
 144:	cf91                	beqz	a5,160 <strlen+0x26>
 146:	0505                	addi	a0,a0,1
 148:	87aa                	mv	a5,a0
 14a:	86be                	mv	a3,a5
 14c:	0785                	addi	a5,a5,1
 14e:	fff7c703          	lbu	a4,-1(a5)
 152:	ff65                	bnez	a4,14a <strlen+0x10>
 154:	40a6853b          	subw	a0,a3,a0
 158:	2505                	addiw	a0,a0,1
    ;
  return n;
}
 15a:	6422                	ld	s0,8(sp)
 15c:	0141                	addi	sp,sp,16
 15e:	8082                	ret
  for(n = 0; s[n]; n++)
 160:	4501                	li	a0,0
 162:	bfe5                	j	15a <strlen+0x20>

0000000000000164 <memset>:

void*
memset(void *dst, int c, uint n)
{
 164:	1141                	addi	sp,sp,-16
 166:	e422                	sd	s0,8(sp)
 168:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
 16a:	ca19                	beqz	a2,180 <memset+0x1c>
 16c:	87aa                	mv	a5,a0
 16e:	1602                	slli	a2,a2,0x20
 170:	9201                	srli	a2,a2,0x20
 172:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
 176:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
 17a:	0785                	addi	a5,a5,1
 17c:	fee79de3          	bne	a5,a4,176 <memset+0x12>
  }
  return dst;
}
 180:	6422                	ld	s0,8(sp)
 182:	0141                	addi	sp,sp,16
 184:	8082                	ret

0000000000000186 <strchr>:

char*
strchr(const char *s, char c)
{
 186:	1141                	addi	sp,sp,-16
 188:	e422                	sd	s0,8(sp)
 18a:	0800                	addi	s0,sp,16
  for(; *s; s++)
 18c:	00054783          	lbu	a5,0(a0)
 190:	cb99                	beqz	a5,1a6 <strchr+0x20>
    if(*s == c)
 192:	00f58763          	beq	a1,a5,1a0 <strchr+0x1a>
  for(; *s; s++)
 196:	0505                	addi	a0,a0,1
 198:	00054783          	lbu	a5,0(a0)
 19c:	fbfd                	bnez	a5,192 <strchr+0xc>
      return (char*)s;
  return 0;
 19e:	4501                	li	a0,0
}
 1a0:	6422                	ld	s0,8(sp)
 1a2:	0141                	addi	sp,sp,16
 1a4:	8082                	ret
  return 0;
 1a6:	4501                	li	a0,0
 1a8:	bfe5                	j	1a0 <strchr+0x1a>

00000000000001aa <gets>:

char*
gets(char *buf, int max)
{
 1aa:	711d                	addi	sp,sp,-96
 1ac:	ec86                	sd	ra,88(sp)
 1ae:	e8a2                	sd	s0,80(sp)
 1b0:	e4a6                	sd	s1,72(sp)
 1b2:	e0ca                	sd	s2,64(sp)
 1b4:	fc4e                	sd	s3,56(sp)
 1b6:	f852                	sd	s4,48(sp)
 1b8:	f456                	sd	s5,40(sp)
 1ba:	f05a                	sd	s6,32(sp)
 1bc:	ec5e                	sd	s7,24(sp)
 1be:	1080                	addi	s0,sp,96
 1c0:	8baa                	mv	s7,a0
 1c2:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 1c4:	892a                	mv	s2,a0
 1c6:	4481                	li	s1,0
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
 1c8:	4aa9                	li	s5,10
 1ca:	4b35                	li	s6,13
  for(i=0; i+1 < max; ){
 1cc:	89a6                	mv	s3,s1
 1ce:	2485                	addiw	s1,s1,1
 1d0:	0344d863          	bge	s1,s4,200 <gets+0x56>
    cc = read(0, &c, 1);
 1d4:	4605                	li	a2,1
 1d6:	faf40593          	addi	a1,s0,-81
 1da:	4501                	li	a0,0
 1dc:	00000097          	auipc	ra,0x0
 1e0:	19a080e7          	jalr	410(ra) # 376 <read>
    if(cc < 1)
 1e4:	00a05e63          	blez	a0,200 <gets+0x56>
    buf[i++] = c;
 1e8:	faf44783          	lbu	a5,-81(s0)
 1ec:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
 1f0:	01578763          	beq	a5,s5,1fe <gets+0x54>
 1f4:	0905                	addi	s2,s2,1
 1f6:	fd679be3          	bne	a5,s6,1cc <gets+0x22>
  for(i=0; i+1 < max; ){
 1fa:	89a6                	mv	s3,s1
 1fc:	a011                	j	200 <gets+0x56>
 1fe:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
 200:	99de                	add	s3,s3,s7
 202:	00098023          	sb	zero,0(s3)
  return buf;
}
 206:	855e                	mv	a0,s7
 208:	60e6                	ld	ra,88(sp)
 20a:	6446                	ld	s0,80(sp)
 20c:	64a6                	ld	s1,72(sp)
 20e:	6906                	ld	s2,64(sp)
 210:	79e2                	ld	s3,56(sp)
 212:	7a42                	ld	s4,48(sp)
 214:	7aa2                	ld	s5,40(sp)
 216:	7b02                	ld	s6,32(sp)
 218:	6be2                	ld	s7,24(sp)
 21a:	6125                	addi	sp,sp,96
 21c:	8082                	ret

000000000000021e <stat>:

int
stat(const char *n, struct stat *st)
{
 21e:	1101                	addi	sp,sp,-32
 220:	ec06                	sd	ra,24(sp)
 222:	e822                	sd	s0,16(sp)
 224:	e426                	sd	s1,8(sp)
 226:	e04a                	sd	s2,0(sp)
 228:	1000                	addi	s0,sp,32
 22a:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 22c:	4581                	li	a1,0
 22e:	00000097          	auipc	ra,0x0
 232:	170080e7          	jalr	368(ra) # 39e <open>
  if(fd < 0)
 236:	02054563          	bltz	a0,260 <stat+0x42>
 23a:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 23c:	85ca                	mv	a1,s2
 23e:	00000097          	auipc	ra,0x0
 242:	178080e7          	jalr	376(ra) # 3b6 <fstat>
 246:	892a                	mv	s2,a0
  close(fd);
 248:	8526                	mv	a0,s1
 24a:	00000097          	auipc	ra,0x0
 24e:	13c080e7          	jalr	316(ra) # 386 <close>
  return r;
}
 252:	854a                	mv	a0,s2
 254:	60e2                	ld	ra,24(sp)
 256:	6442                	ld	s0,16(sp)
 258:	64a2                	ld	s1,8(sp)
 25a:	6902                	ld	s2,0(sp)
 25c:	6105                	addi	sp,sp,32
 25e:	8082                	ret
    return -1;
 260:	597d                	li	s2,-1
 262:	bfc5                	j	252 <stat+0x34>

0000000000000264 <atoi>:

int
atoi(const char *s)
{
 264:	1141                	addi	sp,sp,-16
 266:	e422                	sd	s0,8(sp)
 268:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 26a:	00054683          	lbu	a3,0(a0)
 26e:	fd06879b          	addiw	a5,a3,-48
 272:	0ff7f793          	zext.b	a5,a5
 276:	4625                	li	a2,9
 278:	02f66863          	bltu	a2,a5,2a8 <atoi+0x44>
 27c:	872a                	mv	a4,a0
  n = 0;
 27e:	4501                	li	a0,0
    n = n*10 + *s++ - '0';
 280:	0705                	addi	a4,a4,1
 282:	0025179b          	slliw	a5,a0,0x2
 286:	9fa9                	addw	a5,a5,a0
 288:	0017979b          	slliw	a5,a5,0x1
 28c:	9fb5                	addw	a5,a5,a3
 28e:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 292:	00074683          	lbu	a3,0(a4)
 296:	fd06879b          	addiw	a5,a3,-48
 29a:	0ff7f793          	zext.b	a5,a5
 29e:	fef671e3          	bgeu	a2,a5,280 <atoi+0x1c>
  return n;
}
 2a2:	6422                	ld	s0,8(sp)
 2a4:	0141                	addi	sp,sp,16
 2a6:	8082                	ret
  n = 0;
 2a8:	4501                	li	a0,0
 2aa:	bfe5                	j	2a2 <atoi+0x3e>

00000000000002ac <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 2ac:	1141                	addi	sp,sp,-16
 2ae:	e422                	sd	s0,8(sp)
 2b0:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 2b2:	02b57463          	bgeu	a0,a1,2da <memmove+0x2e>
    while(n-- > 0)
 2b6:	00c05f63          	blez	a2,2d4 <memmove+0x28>
 2ba:	1602                	slli	a2,a2,0x20
 2bc:	9201                	srli	a2,a2,0x20
 2be:	00c507b3          	add	a5,a0,a2
  dst = vdst;
 2c2:	872a                	mv	a4,a0
      *dst++ = *src++;
 2c4:	0585                	addi	a1,a1,1
 2c6:	0705                	addi	a4,a4,1
 2c8:	fff5c683          	lbu	a3,-1(a1)
 2cc:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
 2d0:	fee79ae3          	bne	a5,a4,2c4 <memmove+0x18>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 2d4:	6422                	ld	s0,8(sp)
 2d6:	0141                	addi	sp,sp,16
 2d8:	8082                	ret
    dst += n;
 2da:	00c50733          	add	a4,a0,a2
    src += n;
 2de:	95b2                	add	a1,a1,a2
    while(n-- > 0)
 2e0:	fec05ae3          	blez	a2,2d4 <memmove+0x28>
 2e4:	fff6079b          	addiw	a5,a2,-1
 2e8:	1782                	slli	a5,a5,0x20
 2ea:	9381                	srli	a5,a5,0x20
 2ec:	fff7c793          	not	a5,a5
 2f0:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 2f2:	15fd                	addi	a1,a1,-1
 2f4:	177d                	addi	a4,a4,-1
 2f6:	0005c683          	lbu	a3,0(a1)
 2fa:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
 2fe:	fee79ae3          	bne	a5,a4,2f2 <memmove+0x46>
 302:	bfc9                	j	2d4 <memmove+0x28>

0000000000000304 <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 304:	1141                	addi	sp,sp,-16
 306:	e422                	sd	s0,8(sp)
 308:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 30a:	ca05                	beqz	a2,33a <memcmp+0x36>
 30c:	fff6069b          	addiw	a3,a2,-1
 310:	1682                	slli	a3,a3,0x20
 312:	9281                	srli	a3,a3,0x20
 314:	0685                	addi	a3,a3,1
 316:	96aa                	add	a3,a3,a0
    if (*p1 != *p2) {
 318:	00054783          	lbu	a5,0(a0)
 31c:	0005c703          	lbu	a4,0(a1)
 320:	00e79863          	bne	a5,a4,330 <memcmp+0x2c>
      return *p1 - *p2;
    }
    p1++;
 324:	0505                	addi	a0,a0,1
    p2++;
 326:	0585                	addi	a1,a1,1
  while (n-- > 0) {
 328:	fed518e3          	bne	a0,a3,318 <memcmp+0x14>
  }
  return 0;
 32c:	4501                	li	a0,0
 32e:	a019                	j	334 <memcmp+0x30>
      return *p1 - *p2;
 330:	40e7853b          	subw	a0,a5,a4
}
 334:	6422                	ld	s0,8(sp)
 336:	0141                	addi	sp,sp,16
 338:	8082                	ret
  return 0;
 33a:	4501                	li	a0,0
 33c:	bfe5                	j	334 <memcmp+0x30>

000000000000033e <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 33e:	1141                	addi	sp,sp,-16
 340:	e406                	sd	ra,8(sp)
 342:	e022                	sd	s0,0(sp)
 344:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
 346:	00000097          	auipc	ra,0x0
 34a:	f66080e7          	jalr	-154(ra) # 2ac <memmove>
}
 34e:	60a2                	ld	ra,8(sp)
 350:	6402                	ld	s0,0(sp)
 352:	0141                	addi	sp,sp,16
 354:	8082                	ret

0000000000000356 <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 356:	4885                	li	a7,1
 ecall
 358:	00000073          	ecall
 ret
 35c:	8082                	ret

000000000000035e <exit>:
.global exit
exit:
 li a7, SYS_exit
 35e:	4889                	li	a7,2
 ecall
 360:	00000073          	ecall
 ret
 364:	8082                	ret

0000000000000366 <wait>:
.global wait
wait:
 li a7, SYS_wait
 366:	488d                	li	a7,3
 ecall
 368:	00000073          	ecall
 ret
 36c:	8082                	ret

000000000000036e <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 36e:	4891                	li	a7,4
 ecall
 370:	00000073          	ecall
 ret
 374:	8082                	ret

0000000000000376 <read>:
.global read
read:
 li a7, SYS_read
 376:	4895                	li	a7,5
 ecall
 378:	00000073          	ecall
 ret
 37c:	8082                	ret

000000000000037e <write>:
.global write
write:
 li a7, SYS_write
 37e:	48c1                	li	a7,16
 ecall
 380:	00000073          	ecall
 ret
 384:	8082                	ret

0000000000000386 <close>:
.global close
close:
 li a7, SYS_close
 386:	48d5                	li	a7,21
 ecall
 388:	00000073          	ecall
 ret
 38c:	8082                	ret

000000000000038e <kill>:
.global kill
kill:
 li a7, SYS_kill
 38e:	4899                	li	a7,6
 ecall
 390:	00000073          	ecall
 ret
 394:	8082                	ret

0000000000000396 <exec>:
.global exec
exec:
 li a7, SYS_exec
 396:	489d                	li	a7,7
 ecall
 398:	00000073          	ecall
 ret
 39c:	8082                	ret

000000000000039e <open>:
.global open
open:
 li a7, SYS_open
 39e:	48bd                	li	a7,15
 ecall
 3a0:	00000073          	ecall
 ret
 3a4:	8082                	ret

00000000000003a6 <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 3a6:	48c5                	li	a7,17
 ecall
 3a8:	00000073          	ecall
 ret
 3ac:	8082                	ret

00000000000003ae <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 3ae:	48c9                	li	a7,18
 ecall
 3b0:	00000073          	ecall
 ret
 3b4:	8082                	ret

00000000000003b6 <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 3b6:	48a1                	li	a7,8
 ecall
 3b8:	00000073          	ecall
 ret
 3bc:	8082                	ret

00000000000003be <link>:
.global link
link:
 li a7, SYS_link
 3be:	48cd                	li	a7,19
 ecall
 3c0:	00000073          	ecall
 ret
 3c4:	8082                	ret

00000000000003c6 <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 3c6:	48d1                	li	a7,20
 ecall
 3c8:	00000073          	ecall
 ret
 3cc:	8082                	ret

00000000000003ce <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 3ce:	48a5                	li	a7,9
 ecall
 3d0:	00000073          	ecall
 ret
 3d4:	8082                	ret

00000000000003d6 <dup>:
.global dup
dup:
 li a7, SYS_dup
 3d6:	48a9                	li	a7,10
 ecall
 3d8:	00000073          	ecall
 ret
 3dc:	8082                	ret

00000000000003de <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 3de:	48ad                	li	a7,11
 ecall
 3e0:	00000073          	ecall
 ret
 3e4:	8082                	ret

00000000000003e6 <sbrk>:
.global sbrk
sbrk:
 li a7, SYS_sbrk
 3e6:	48b1                	li	a7,12
 ecall
 3e8:	00000073          	ecall
 ret
 3ec:	8082                	ret

00000000000003ee <sleep>:
.global sleep
sleep:
 li a7, SYS_sleep
 3ee:	48b5                	li	a7,13
 ecall
 3f0:	00000073          	ecall
 ret
 3f4:	8082                	ret

00000000000003f6 <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 3f6:	48b9                	li	a7,14
 ecall
 3f8:	00000073          	ecall
 ret
 3fc:	8082                	ret

00000000000003fe <dump>:
.global dump
dump:
 li a7, SYS_dump
 3fe:	48d9                	li	a7,22
 ecall
 400:	00000073          	ecall
 ret
 404:	8082                	ret

0000000000000406 <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 406:	1101                	addi	sp,sp,-32
 408:	ec06                	sd	ra,24(sp)
 40a:	e822                	sd	s0,16(sp)
 40c:	1000                	addi	s0,sp,32
 40e:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 412:	4605                	li	a2,1
 414:	fef40593          	addi	a1,s0,-17
 418:	00000097          	auipc	ra,0x0
 41c:	f66080e7          	jalr	-154(ra) # 37e <write>
}
 420:	60e2                	ld	ra,24(sp)
 422:	6442                	ld	s0,16(sp)
 424:	6105                	addi	sp,sp,32
 426:	8082                	ret

0000000000000428 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 428:	7139                	addi	sp,sp,-64
 42a:	fc06                	sd	ra,56(sp)
 42c:	f822                	sd	s0,48(sp)
 42e:	f426                	sd	s1,40(sp)
 430:	f04a                	sd	s2,32(sp)
 432:	ec4e                	sd	s3,24(sp)
 434:	0080                	addi	s0,sp,64
 436:	84aa                	mv	s1,a0
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
 438:	c299                	beqz	a3,43e <printint+0x16>
 43a:	0805c963          	bltz	a1,4cc <printint+0xa4>
    neg = 1;
    x = -xx;
  } else {
    x = xx;
 43e:	2581                	sext.w	a1,a1
  neg = 0;
 440:	4881                	li	a7,0
 442:	fc040693          	addi	a3,s0,-64
  }

  i = 0;
 446:	4701                	li	a4,0
  do{
    buf[i++] = digits[x % base];
 448:	2601                	sext.w	a2,a2
 44a:	00000517          	auipc	a0,0x0
 44e:	54650513          	addi	a0,a0,1350 # 990 <digits>
 452:	883a                	mv	a6,a4
 454:	2705                	addiw	a4,a4,1
 456:	02c5f7bb          	remuw	a5,a1,a2
 45a:	1782                	slli	a5,a5,0x20
 45c:	9381                	srli	a5,a5,0x20
 45e:	97aa                	add	a5,a5,a0
 460:	0007c783          	lbu	a5,0(a5)
 464:	00f68023          	sb	a5,0(a3)
  }while((x /= base) != 0);
 468:	0005879b          	sext.w	a5,a1
 46c:	02c5d5bb          	divuw	a1,a1,a2
 470:	0685                	addi	a3,a3,1
 472:	fec7f0e3          	bgeu	a5,a2,452 <printint+0x2a>
  if(neg)
 476:	00088c63          	beqz	a7,48e <printint+0x66>
    buf[i++] = '-';
 47a:	fd070793          	addi	a5,a4,-48
 47e:	00878733          	add	a4,a5,s0
 482:	02d00793          	li	a5,45
 486:	fef70823          	sb	a5,-16(a4)
 48a:	0028071b          	addiw	a4,a6,2

  while(--i >= 0)
 48e:	02e05863          	blez	a4,4be <printint+0x96>
 492:	fc040793          	addi	a5,s0,-64
 496:	00e78933          	add	s2,a5,a4
 49a:	fff78993          	addi	s3,a5,-1
 49e:	99ba                	add	s3,s3,a4
 4a0:	377d                	addiw	a4,a4,-1
 4a2:	1702                	slli	a4,a4,0x20
 4a4:	9301                	srli	a4,a4,0x20
 4a6:	40e989b3          	sub	s3,s3,a4
    putc(fd, buf[i]);
 4aa:	fff94583          	lbu	a1,-1(s2)
 4ae:	8526                	mv	a0,s1
 4b0:	00000097          	auipc	ra,0x0
 4b4:	f56080e7          	jalr	-170(ra) # 406 <putc>
  while(--i >= 0)
 4b8:	197d                	addi	s2,s2,-1
 4ba:	ff3918e3          	bne	s2,s3,4aa <printint+0x82>
}
 4be:	70e2                	ld	ra,56(sp)
 4c0:	7442                	ld	s0,48(sp)
 4c2:	74a2                	ld	s1,40(sp)
 4c4:	7902                	ld	s2,32(sp)
 4c6:	69e2                	ld	s3,24(sp)
 4c8:	6121                	addi	sp,sp,64
 4ca:	8082                	ret
    x = -xx;
 4cc:	40b005bb          	negw	a1,a1
    neg = 1;
 4d0:	4885                	li	a7,1
    x = -xx;
 4d2:	bf85                	j	442 <printint+0x1a>

00000000000004d4 <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 4d4:	715d                	addi	sp,sp,-80
 4d6:	e486                	sd	ra,72(sp)
 4d8:	e0a2                	sd	s0,64(sp)
 4da:	fc26                	sd	s1,56(sp)
 4dc:	f84a                	sd	s2,48(sp)
 4de:	f44e                	sd	s3,40(sp)
 4e0:	f052                	sd	s4,32(sp)
 4e2:	ec56                	sd	s5,24(sp)
 4e4:	e85a                	sd	s6,16(sp)
 4e6:	e45e                	sd	s7,8(sp)
 4e8:	e062                	sd	s8,0(sp)
 4ea:	0880                	addi	s0,sp,80
  char *s;
  int c, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 4ec:	0005c903          	lbu	s2,0(a1)
 4f0:	18090c63          	beqz	s2,688 <vprintf+0x1b4>
 4f4:	8aaa                	mv	s5,a0
 4f6:	8bb2                	mv	s7,a2
 4f8:	00158493          	addi	s1,a1,1
  state = 0;
 4fc:	4981                	li	s3,0
      if(c == '%'){
        state = '%';
      } else {
        putc(fd, c);
      }
    } else if(state == '%'){
 4fe:	02500a13          	li	s4,37
 502:	4b55                	li	s6,21
 504:	a839                	j	522 <vprintf+0x4e>
        putc(fd, c);
 506:	85ca                	mv	a1,s2
 508:	8556                	mv	a0,s5
 50a:	00000097          	auipc	ra,0x0
 50e:	efc080e7          	jalr	-260(ra) # 406 <putc>
 512:	a019                	j	518 <vprintf+0x44>
    } else if(state == '%'){
 514:	01498d63          	beq	s3,s4,52e <vprintf+0x5a>
  for(i = 0; fmt[i]; i++){
 518:	0485                	addi	s1,s1,1
 51a:	fff4c903          	lbu	s2,-1(s1)
 51e:	16090563          	beqz	s2,688 <vprintf+0x1b4>
    if(state == 0){
 522:	fe0999e3          	bnez	s3,514 <vprintf+0x40>
      if(c == '%'){
 526:	ff4910e3          	bne	s2,s4,506 <vprintf+0x32>
        state = '%';
 52a:	89d2                	mv	s3,s4
 52c:	b7f5                	j	518 <vprintf+0x44>
      if(c == 'd'){
 52e:	13490263          	beq	s2,s4,652 <vprintf+0x17e>
 532:	f9d9079b          	addiw	a5,s2,-99
 536:	0ff7f793          	zext.b	a5,a5
 53a:	12fb6563          	bltu	s6,a5,664 <vprintf+0x190>
 53e:	f9d9079b          	addiw	a5,s2,-99
 542:	0ff7f713          	zext.b	a4,a5
 546:	10eb6f63          	bltu	s6,a4,664 <vprintf+0x190>
 54a:	00271793          	slli	a5,a4,0x2
 54e:	00000717          	auipc	a4,0x0
 552:	3ea70713          	addi	a4,a4,1002 # 938 <dump_test4_asm+0x70>
 556:	97ba                	add	a5,a5,a4
 558:	439c                	lw	a5,0(a5)
 55a:	97ba                	add	a5,a5,a4
 55c:	8782                	jr	a5
        printint(fd, va_arg(ap, int), 10, 1);
 55e:	008b8913          	addi	s2,s7,8
 562:	4685                	li	a3,1
 564:	4629                	li	a2,10
 566:	000ba583          	lw	a1,0(s7)
 56a:	8556                	mv	a0,s5
 56c:	00000097          	auipc	ra,0x0
 570:	ebc080e7          	jalr	-324(ra) # 428 <printint>
 574:	8bca                	mv	s7,s2
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c);
      }
      state = 0;
 576:	4981                	li	s3,0
 578:	b745                	j	518 <vprintf+0x44>
        printint(fd, va_arg(ap, uint64), 10, 0);
 57a:	008b8913          	addi	s2,s7,8
 57e:	4681                	li	a3,0
 580:	4629                	li	a2,10
 582:	000ba583          	lw	a1,0(s7)
 586:	8556                	mv	a0,s5
 588:	00000097          	auipc	ra,0x0
 58c:	ea0080e7          	jalr	-352(ra) # 428 <printint>
 590:	8bca                	mv	s7,s2
      state = 0;
 592:	4981                	li	s3,0
 594:	b751                	j	518 <vprintf+0x44>
        printint(fd, va_arg(ap, int), 16, 0);
 596:	008b8913          	addi	s2,s7,8
 59a:	4681                	li	a3,0
 59c:	4641                	li	a2,16
 59e:	000ba583          	lw	a1,0(s7)
 5a2:	8556                	mv	a0,s5
 5a4:	00000097          	auipc	ra,0x0
 5a8:	e84080e7          	jalr	-380(ra) # 428 <printint>
 5ac:	8bca                	mv	s7,s2
      state = 0;
 5ae:	4981                	li	s3,0
 5b0:	b7a5                	j	518 <vprintf+0x44>
        printptr(fd, va_arg(ap, uint64));
 5b2:	008b8c13          	addi	s8,s7,8
 5b6:	000bb983          	ld	s3,0(s7)
  putc(fd, '0');
 5ba:	03000593          	li	a1,48
 5be:	8556                	mv	a0,s5
 5c0:	00000097          	auipc	ra,0x0
 5c4:	e46080e7          	jalr	-442(ra) # 406 <putc>
  putc(fd, 'x');
 5c8:	07800593          	li	a1,120
 5cc:	8556                	mv	a0,s5
 5ce:	00000097          	auipc	ra,0x0
 5d2:	e38080e7          	jalr	-456(ra) # 406 <putc>
 5d6:	4941                	li	s2,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 5d8:	00000b97          	auipc	s7,0x0
 5dc:	3b8b8b93          	addi	s7,s7,952 # 990 <digits>
 5e0:	03c9d793          	srli	a5,s3,0x3c
 5e4:	97de                	add	a5,a5,s7
 5e6:	0007c583          	lbu	a1,0(a5)
 5ea:	8556                	mv	a0,s5
 5ec:	00000097          	auipc	ra,0x0
 5f0:	e1a080e7          	jalr	-486(ra) # 406 <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 5f4:	0992                	slli	s3,s3,0x4
 5f6:	397d                	addiw	s2,s2,-1
 5f8:	fe0914e3          	bnez	s2,5e0 <vprintf+0x10c>
        printptr(fd, va_arg(ap, uint64));
 5fc:	8be2                	mv	s7,s8
      state = 0;
 5fe:	4981                	li	s3,0
 600:	bf21                	j	518 <vprintf+0x44>
        s = va_arg(ap, char*);
 602:	008b8993          	addi	s3,s7,8
 606:	000bb903          	ld	s2,0(s7)
        if(s == 0)
 60a:	02090163          	beqz	s2,62c <vprintf+0x158>
        while(*s != 0){
 60e:	00094583          	lbu	a1,0(s2)
 612:	c9a5                	beqz	a1,682 <vprintf+0x1ae>
          putc(fd, *s);
 614:	8556                	mv	a0,s5
 616:	00000097          	auipc	ra,0x0
 61a:	df0080e7          	jalr	-528(ra) # 406 <putc>
          s++;
 61e:	0905                	addi	s2,s2,1
        while(*s != 0){
 620:	00094583          	lbu	a1,0(s2)
 624:	f9e5                	bnez	a1,614 <vprintf+0x140>
        s = va_arg(ap, char*);
 626:	8bce                	mv	s7,s3
      state = 0;
 628:	4981                	li	s3,0
 62a:	b5fd                	j	518 <vprintf+0x44>
          s = "(null)";
 62c:	00000917          	auipc	s2,0x0
 630:	30490913          	addi	s2,s2,772 # 930 <dump_test4_asm+0x68>
        while(*s != 0){
 634:	02800593          	li	a1,40
 638:	bff1                	j	614 <vprintf+0x140>
        putc(fd, va_arg(ap, uint));
 63a:	008b8913          	addi	s2,s7,8
 63e:	000bc583          	lbu	a1,0(s7)
 642:	8556                	mv	a0,s5
 644:	00000097          	auipc	ra,0x0
 648:	dc2080e7          	jalr	-574(ra) # 406 <putc>
 64c:	8bca                	mv	s7,s2
      state = 0;
 64e:	4981                	li	s3,0
 650:	b5e1                	j	518 <vprintf+0x44>
        putc(fd, c);
 652:	02500593          	li	a1,37
 656:	8556                	mv	a0,s5
 658:	00000097          	auipc	ra,0x0
 65c:	dae080e7          	jalr	-594(ra) # 406 <putc>
      state = 0;
 660:	4981                	li	s3,0
 662:	bd5d                	j	518 <vprintf+0x44>
        putc(fd, '%');
 664:	02500593          	li	a1,37
 668:	8556                	mv	a0,s5
 66a:	00000097          	auipc	ra,0x0
 66e:	d9c080e7          	jalr	-612(ra) # 406 <putc>
        putc(fd, c);
 672:	85ca                	mv	a1,s2
 674:	8556                	mv	a0,s5
 676:	00000097          	auipc	ra,0x0
 67a:	d90080e7          	jalr	-624(ra) # 406 <putc>
      state = 0;
 67e:	4981                	li	s3,0
 680:	bd61                	j	518 <vprintf+0x44>
        s = va_arg(ap, char*);
 682:	8bce                	mv	s7,s3
      state = 0;
 684:	4981                	li	s3,0
 686:	bd49                	j	518 <vprintf+0x44>
    }
  }
}
 688:	60a6                	ld	ra,72(sp)
 68a:	6406                	ld	s0,64(sp)
 68c:	74e2                	ld	s1,56(sp)
 68e:	7942                	ld	s2,48(sp)
 690:	79a2                	ld	s3,40(sp)
 692:	7a02                	ld	s4,32(sp)
 694:	6ae2                	ld	s5,24(sp)
 696:	6b42                	ld	s6,16(sp)
 698:	6ba2                	ld	s7,8(sp)
 69a:	6c02                	ld	s8,0(sp)
 69c:	6161                	addi	sp,sp,80
 69e:	8082                	ret

00000000000006a0 <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 6a0:	715d                	addi	sp,sp,-80
 6a2:	ec06                	sd	ra,24(sp)
 6a4:	e822                	sd	s0,16(sp)
 6a6:	1000                	addi	s0,sp,32
 6a8:	e010                	sd	a2,0(s0)
 6aa:	e414                	sd	a3,8(s0)
 6ac:	e818                	sd	a4,16(s0)
 6ae:	ec1c                	sd	a5,24(s0)
 6b0:	03043023          	sd	a6,32(s0)
 6b4:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 6b8:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 6bc:	8622                	mv	a2,s0
 6be:	00000097          	auipc	ra,0x0
 6c2:	e16080e7          	jalr	-490(ra) # 4d4 <vprintf>
}
 6c6:	60e2                	ld	ra,24(sp)
 6c8:	6442                	ld	s0,16(sp)
 6ca:	6161                	addi	sp,sp,80
 6cc:	8082                	ret

00000000000006ce <printf>:

void
printf(const char *fmt, ...)
{
 6ce:	711d                	addi	sp,sp,-96
 6d0:	ec06                	sd	ra,24(sp)
 6d2:	e822                	sd	s0,16(sp)
 6d4:	1000                	addi	s0,sp,32
 6d6:	e40c                	sd	a1,8(s0)
 6d8:	e810                	sd	a2,16(s0)
 6da:	ec14                	sd	a3,24(s0)
 6dc:	f018                	sd	a4,32(s0)
 6de:	f41c                	sd	a5,40(s0)
 6e0:	03043823          	sd	a6,48(s0)
 6e4:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 6e8:	00840613          	addi	a2,s0,8
 6ec:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 6f0:	85aa                	mv	a1,a0
 6f2:	4505                	li	a0,1
 6f4:	00000097          	auipc	ra,0x0
 6f8:	de0080e7          	jalr	-544(ra) # 4d4 <vprintf>
}
 6fc:	60e2                	ld	ra,24(sp)
 6fe:	6442                	ld	s0,16(sp)
 700:	6125                	addi	sp,sp,96
 702:	8082                	ret

0000000000000704 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 704:	1141                	addi	sp,sp,-16
 706:	e422                	sd	s0,8(sp)
 708:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 70a:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 70e:	00001797          	auipc	a5,0x1
 712:	8f27b783          	ld	a5,-1806(a5) # 1000 <freep>
 716:	a02d                	j	740 <free+0x3c>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
 718:	4618                	lw	a4,8(a2)
 71a:	9f2d                	addw	a4,a4,a1
 71c:	fee52c23          	sw	a4,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 720:	6398                	ld	a4,0(a5)
 722:	6310                	ld	a2,0(a4)
 724:	a83d                	j	762 <free+0x5e>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
 726:	ff852703          	lw	a4,-8(a0)
 72a:	9f31                	addw	a4,a4,a2
 72c:	c798                	sw	a4,8(a5)
    p->s.ptr = bp->s.ptr;
 72e:	ff053683          	ld	a3,-16(a0)
 732:	a091                	j	776 <free+0x72>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 734:	6398                	ld	a4,0(a5)
 736:	00e7e463          	bltu	a5,a4,73e <free+0x3a>
 73a:	00e6ea63          	bltu	a3,a4,74e <free+0x4a>
{
 73e:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 740:	fed7fae3          	bgeu	a5,a3,734 <free+0x30>
 744:	6398                	ld	a4,0(a5)
 746:	00e6e463          	bltu	a3,a4,74e <free+0x4a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 74a:	fee7eae3          	bltu	a5,a4,73e <free+0x3a>
  if(bp + bp->s.size == p->s.ptr){
 74e:	ff852583          	lw	a1,-8(a0)
 752:	6390                	ld	a2,0(a5)
 754:	02059813          	slli	a6,a1,0x20
 758:	01c85713          	srli	a4,a6,0x1c
 75c:	9736                	add	a4,a4,a3
 75e:	fae60de3          	beq	a2,a4,718 <free+0x14>
    bp->s.ptr = p->s.ptr->s.ptr;
 762:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
 766:	4790                	lw	a2,8(a5)
 768:	02061593          	slli	a1,a2,0x20
 76c:	01c5d713          	srli	a4,a1,0x1c
 770:	973e                	add	a4,a4,a5
 772:	fae68ae3          	beq	a3,a4,726 <free+0x22>
    p->s.ptr = bp->s.ptr;
 776:	e394                	sd	a3,0(a5)
  } else
    p->s.ptr = bp;
  freep = p;
 778:	00001717          	auipc	a4,0x1
 77c:	88f73423          	sd	a5,-1912(a4) # 1000 <freep>
}
 780:	6422                	ld	s0,8(sp)
 782:	0141                	addi	sp,sp,16
 784:	8082                	ret

0000000000000786 <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 786:	7139                	addi	sp,sp,-64
 788:	fc06                	sd	ra,56(sp)
 78a:	f822                	sd	s0,48(sp)
 78c:	f426                	sd	s1,40(sp)
 78e:	f04a                	sd	s2,32(sp)
 790:	ec4e                	sd	s3,24(sp)
 792:	e852                	sd	s4,16(sp)
 794:	e456                	sd	s5,8(sp)
 796:	e05a                	sd	s6,0(sp)
 798:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 79a:	02051493          	slli	s1,a0,0x20
 79e:	9081                	srli	s1,s1,0x20
 7a0:	04bd                	addi	s1,s1,15
 7a2:	8091                	srli	s1,s1,0x4
 7a4:	0014899b          	addiw	s3,s1,1
 7a8:	0485                	addi	s1,s1,1
  if((prevp = freep) == 0){
 7aa:	00001517          	auipc	a0,0x1
 7ae:	85653503          	ld	a0,-1962(a0) # 1000 <freep>
 7b2:	c515                	beqz	a0,7de <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 7b4:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 7b6:	4798                	lw	a4,8(a5)
 7b8:	02977f63          	bgeu	a4,s1,7f6 <malloc+0x70>
  if(nu < 4096)
 7bc:	8a4e                	mv	s4,s3
 7be:	0009871b          	sext.w	a4,s3
 7c2:	6685                	lui	a3,0x1
 7c4:	00d77363          	bgeu	a4,a3,7ca <malloc+0x44>
 7c8:	6a05                	lui	s4,0x1
 7ca:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 7ce:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 7d2:	00001917          	auipc	s2,0x1
 7d6:	82e90913          	addi	s2,s2,-2002 # 1000 <freep>
  if(p == (char*)-1)
 7da:	5afd                	li	s5,-1
 7dc:	a895                	j	850 <malloc+0xca>
    base.s.ptr = freep = prevp = &base;
 7de:	00001797          	auipc	a5,0x1
 7e2:	83278793          	addi	a5,a5,-1998 # 1010 <base>
 7e6:	00001717          	auipc	a4,0x1
 7ea:	80f73d23          	sd	a5,-2022(a4) # 1000 <freep>
 7ee:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 7f0:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 7f4:	b7e1                	j	7bc <malloc+0x36>
      if(p->s.size == nunits)
 7f6:	02e48c63          	beq	s1,a4,82e <malloc+0xa8>
        p->s.size -= nunits;
 7fa:	4137073b          	subw	a4,a4,s3
 7fe:	c798                	sw	a4,8(a5)
        p += p->s.size;
 800:	02071693          	slli	a3,a4,0x20
 804:	01c6d713          	srli	a4,a3,0x1c
 808:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 80a:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 80e:	00000717          	auipc	a4,0x0
 812:	7ea73923          	sd	a0,2034(a4) # 1000 <freep>
      return (void*)(p + 1);
 816:	01078513          	addi	a0,a5,16
      if((p = morecore(nunits)) == 0)
        return 0;
  }
}
 81a:	70e2                	ld	ra,56(sp)
 81c:	7442                	ld	s0,48(sp)
 81e:	74a2                	ld	s1,40(sp)
 820:	7902                	ld	s2,32(sp)
 822:	69e2                	ld	s3,24(sp)
 824:	6a42                	ld	s4,16(sp)
 826:	6aa2                	ld	s5,8(sp)
 828:	6b02                	ld	s6,0(sp)
 82a:	6121                	addi	sp,sp,64
 82c:	8082                	ret
        prevp->s.ptr = p->s.ptr;
 82e:	6398                	ld	a4,0(a5)
 830:	e118                	sd	a4,0(a0)
 832:	bff1                	j	80e <malloc+0x88>
  hp->s.size = nu;
 834:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
 838:	0541                	addi	a0,a0,16
 83a:	00000097          	auipc	ra,0x0
 83e:	eca080e7          	jalr	-310(ra) # 704 <free>
  return freep;
 842:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
 846:	d971                	beqz	a0,81a <malloc+0x94>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 848:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 84a:	4798                	lw	a4,8(a5)
 84c:	fa9775e3          	bgeu	a4,s1,7f6 <malloc+0x70>
    if(p == freep)
 850:	00093703          	ld	a4,0(s2)
 854:	853e                	mv	a0,a5
 856:	fef719e3          	bne	a4,a5,848 <malloc+0xc2>
  p = sbrk(nu * sizeof(Header));
 85a:	8552                	mv	a0,s4
 85c:	00000097          	auipc	ra,0x0
 860:	b8a080e7          	jalr	-1142(ra) # 3e6 <sbrk>
  if(p == (char*)-1)
 864:	fd5518e3          	bne	a0,s5,834 <malloc+0xae>
        return 0;
 868:	4501                	li	a0,0
 86a:	bf45                	j	81a <malloc+0x94>

000000000000086c <dump_test2_asm>:
#include "kernel/syscall.h"
.globl dump_test2_asm
dump_test2_asm:
  li s2, 2
 86c:	4909                	li	s2,2
  li s3, 3
 86e:	498d                	li	s3,3
  li s4, 4
 870:	4a11                	li	s4,4
  li s5, 5
 872:	4a95                	li	s5,5
  li s6, 6
 874:	4b19                	li	s6,6
  li s7, 7
 876:	4b9d                	li	s7,7
  li s8, 8
 878:	4c21                	li	s8,8
  li s9, 9
 87a:	4ca5                	li	s9,9
  li s10, 10
 87c:	4d29                	li	s10,10
  li s11, 11
 87e:	4dad                	li	s11,11
#ifdef SYS_dump
  li a7, SYS_dump
 880:	48d9                	li	a7,22
  ecall
 882:	00000073          	ecall
#endif
  ret
 886:	8082                	ret

0000000000000888 <dump_test3_asm>:
.globl dump_test3_asm
dump_test3_asm:
  li s2, 1
 888:	4905                	li	s2,1
  li s3, -12
 88a:	59d1                	li	s3,-12
  li s4, 123
 88c:	07b00a13          	li	s4,123
  li s5, -1234
 890:	b2e00a93          	li	s5,-1234
  li s6, 12345
 894:	6b0d                	lui	s6,0x3
 896:	039b0b1b          	addiw	s6,s6,57 # 3039 <base+0x2029>
  li s7, -123456
 89a:	7b89                	lui	s7,0xfffe2
 89c:	dc0b8b9b          	addiw	s7,s7,-576 # fffffffffffe1dc0 <base+0xfffffffffffe0db0>
  li s8, 1234567
 8a0:	0012dc37          	lui	s8,0x12d
 8a4:	687c0c1b          	addiw	s8,s8,1671 # 12d687 <base+0x12c677>
  li s9, -12345678
 8a8:	ff43acb7          	lui	s9,0xff43a
 8ac:	eb2c8c9b          	addiw	s9,s9,-334 # ffffffffff439eb2 <base+0xffffffffff438ea2>
  li s10, 123456789
 8b0:	075bdd37          	lui	s10,0x75bd
 8b4:	d15d0d1b          	addiw	s10,s10,-747 # 75bcd15 <base+0x75bbd05>
  li s11, -1234567890
 8b8:	b66a0db7          	lui	s11,0xb66a0
 8bc:	d2ed8d9b          	addiw	s11,s11,-722 # ffffffffb669fd2e <base+0xffffffffb669ed1e>
#ifdef SYS_dump
  li a7, SYS_dump
 8c0:	48d9                	li	a7,22
  ecall
 8c2:	00000073          	ecall
#endif
  ret
 8c6:	8082                	ret

00000000000008c8 <dump_test4_asm>:
.globl dump_test4_asm
dump_test4_asm:
  li s2, 2147483647
 8c8:	80000937          	lui	s2,0x80000
 8cc:	397d                	addiw	s2,s2,-1 # 7fffffff <base+0x7fffefef>
  li s3, -2147483648
 8ce:	800009b7          	lui	s3,0x80000
  li s4, 1337
 8d2:	53900a13          	li	s4,1337
  li s5, 2020
 8d6:	7e400a93          	li	s5,2020
  li s6, 3234
 8da:	6b05                	lui	s6,0x1
 8dc:	ca2b0b1b          	addiw	s6,s6,-862 # ca2 <digits+0x312>
  li s7, 3235
 8e0:	6b85                	lui	s7,0x1
 8e2:	ca3b8b9b          	addiw	s7,s7,-861 # ca3 <digits+0x313>
  li s8, 3236
 8e6:	6c05                	lui	s8,0x1
 8e8:	ca4c0c1b          	addiw	s8,s8,-860 # ca4 <digits+0x314>
  li s9, 3237
 8ec:	6c85                	lui	s9,0x1
 8ee:	ca5c8c9b          	addiw	s9,s9,-859 # ca5 <digits+0x315>
  li s10, 3238
 8f2:	6d05                	lui	s10,0x1
 8f4:	ca6d0d1b          	addiw	s10,s10,-858 # ca6 <digits+0x316>
  li s11, 3239
 8f8:	6d85                	lui	s11,0x1
 8fa:	ca7d8d9b          	addiw	s11,s11,-857 # ca7 <digits+0x317>
#ifdef SYS_dump
  li a7, SYS_dump
 8fe:	48d9                	li	a7,22
  ecall
 900:	00000073          	ecall
#endif
  ret
 904:	8082                	ret
