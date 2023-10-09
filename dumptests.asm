
user/_dumptests:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <test1>:
  exit(0);
}

#ifdef SYS_dump

void test1() {
   0:	1141                	addi	sp,sp,-16
   2:	e406                	sd	ra,8(sp)
   4:	e022                	sd	s0,0(sp)
   6:	0800                	addi	s0,sp,16
  printf("#####################\n");
   8:	00001517          	auipc	a0,0x1
   c:	cf850513          	addi	a0,a0,-776 # d00 <dump_test4_asm+0x3e>
  10:	00001097          	auipc	ra,0x1
  14:	ab8080e7          	jalr	-1352(ra) # ac8 <printf>
  printf("#                   #\n");
  18:	00001517          	auipc	a0,0x1
  1c:	d0050513          	addi	a0,a0,-768 # d18 <dump_test4_asm+0x56>
  20:	00001097          	auipc	ra,0x1
  24:	aa8080e7          	jalr	-1368(ra) # ac8 <printf>
  printf("#   initial state   #\n");
  28:	00001517          	auipc	a0,0x1
  2c:	d0850513          	addi	a0,a0,-760 # d30 <dump_test4_asm+0x6e>
  30:	00001097          	auipc	ra,0x1
  34:	a98080e7          	jalr	-1384(ra) # ac8 <printf>
  printf("#                   #\n");
  38:	00001517          	auipc	a0,0x1
  3c:	ce050513          	addi	a0,a0,-800 # d18 <dump_test4_asm+0x56>
  40:	00001097          	auipc	ra,0x1
  44:	a88080e7          	jalr	-1400(ra) # ac8 <printf>
  printf("#####################\n");
  48:	00001517          	auipc	a0,0x1
  4c:	cb850513          	addi	a0,a0,-840 # d00 <dump_test4_asm+0x3e>
  50:	00001097          	auipc	ra,0x1
  54:	a78080e7          	jalr	-1416(ra) # ac8 <printf>
  dump();
  58:	00000097          	auipc	ra,0x0
  5c:	7a0080e7          	jalr	1952(ra) # 7f8 <dump>
}
  60:	60a2                	ld	ra,8(sp)
  62:	6402                	ld	s0,0(sp)
  64:	0141                	addi	sp,sp,16
  66:	8082                	ret

0000000000000068 <test2>:

int dump_test2_asm();

void test2() {
  68:	1141                	addi	sp,sp,-16
  6a:	e406                	sd	ra,8(sp)
  6c:	e022                	sd	s0,0(sp)
  6e:	0800                	addi	s0,sp,16
  printf("#####################\n");
  70:	00001517          	auipc	a0,0x1
  74:	c9050513          	addi	a0,a0,-880 # d00 <dump_test4_asm+0x3e>
  78:	00001097          	auipc	ra,0x1
  7c:	a50080e7          	jalr	-1456(ra) # ac8 <printf>
  printf("#                   #\n");
  80:	00001517          	auipc	a0,0x1
  84:	c9850513          	addi	a0,a0,-872 # d18 <dump_test4_asm+0x56>
  88:	00001097          	auipc	ra,0x1
  8c:	a40080e7          	jalr	-1472(ra) # ac8 <printf>
  printf("#       test 1      #\n");
  90:	00001517          	auipc	a0,0x1
  94:	cb850513          	addi	a0,a0,-840 # d48 <dump_test4_asm+0x86>
  98:	00001097          	auipc	ra,0x1
  9c:	a30080e7          	jalr	-1488(ra) # ac8 <printf>
  printf("#                   #\n");
  a0:	00001517          	auipc	a0,0x1
  a4:	c7850513          	addi	a0,a0,-904 # d18 <dump_test4_asm+0x56>
  a8:	00001097          	auipc	ra,0x1
  ac:	a20080e7          	jalr	-1504(ra) # ac8 <printf>
  printf("#####################\n");
  b0:	00001517          	auipc	a0,0x1
  b4:	c5050513          	addi	a0,a0,-944 # d00 <dump_test4_asm+0x3e>
  b8:	00001097          	auipc	ra,0x1
  bc:	a10080e7          	jalr	-1520(ra) # ac8 <printf>
  printf("#                   #\n");
  c0:	00001517          	auipc	a0,0x1
  c4:	c5850513          	addi	a0,a0,-936 # d18 <dump_test4_asm+0x56>
  c8:	00001097          	auipc	ra,0x1
  cc:	a00080e7          	jalr	-1536(ra) # ac8 <printf>
  printf("#  expected values  #\n");
  d0:	00001517          	auipc	a0,0x1
  d4:	c9050513          	addi	a0,a0,-880 # d60 <dump_test4_asm+0x9e>
  d8:	00001097          	auipc	ra,0x1
  dc:	9f0080e7          	jalr	-1552(ra) # ac8 <printf>
  printf("#                   #\n");
  e0:	00001517          	auipc	a0,0x1
  e4:	c3850513          	addi	a0,a0,-968 # d18 <dump_test4_asm+0x56>
  e8:	00001097          	auipc	ra,0x1
  ec:	9e0080e7          	jalr	-1568(ra) # ac8 <printf>
  printf("#####################\n");
  f0:	00001517          	auipc	a0,0x1
  f4:	c1050513          	addi	a0,a0,-1008 # d00 <dump_test4_asm+0x3e>
  f8:	00001097          	auipc	ra,0x1
  fc:	9d0080e7          	jalr	-1584(ra) # ac8 <printf>
  printf("# s2  = 2           #\n");
 100:	00001517          	auipc	a0,0x1
 104:	c7850513          	addi	a0,a0,-904 # d78 <dump_test4_asm+0xb6>
 108:	00001097          	auipc	ra,0x1
 10c:	9c0080e7          	jalr	-1600(ra) # ac8 <printf>
  printf("# s3  = 3           #\n");
 110:	00001517          	auipc	a0,0x1
 114:	c8050513          	addi	a0,a0,-896 # d90 <dump_test4_asm+0xce>
 118:	00001097          	auipc	ra,0x1
 11c:	9b0080e7          	jalr	-1616(ra) # ac8 <printf>
  printf("# s4  = 4           #\n");
 120:	00001517          	auipc	a0,0x1
 124:	c8850513          	addi	a0,a0,-888 # da8 <dump_test4_asm+0xe6>
 128:	00001097          	auipc	ra,0x1
 12c:	9a0080e7          	jalr	-1632(ra) # ac8 <printf>
  printf("# s5  = 5           #\n");
 130:	00001517          	auipc	a0,0x1
 134:	c9050513          	addi	a0,a0,-880 # dc0 <dump_test4_asm+0xfe>
 138:	00001097          	auipc	ra,0x1
 13c:	990080e7          	jalr	-1648(ra) # ac8 <printf>
  printf("# s6  = 6           #\n");
 140:	00001517          	auipc	a0,0x1
 144:	c9850513          	addi	a0,a0,-872 # dd8 <dump_test4_asm+0x116>
 148:	00001097          	auipc	ra,0x1
 14c:	980080e7          	jalr	-1664(ra) # ac8 <printf>
  printf("# s7  = 7           #\n");
 150:	00001517          	auipc	a0,0x1
 154:	ca050513          	addi	a0,a0,-864 # df0 <dump_test4_asm+0x12e>
 158:	00001097          	auipc	ra,0x1
 15c:	970080e7          	jalr	-1680(ra) # ac8 <printf>
  printf("# s8  = 8           #\n");
 160:	00001517          	auipc	a0,0x1
 164:	ca850513          	addi	a0,a0,-856 # e08 <dump_test4_asm+0x146>
 168:	00001097          	auipc	ra,0x1
 16c:	960080e7          	jalr	-1696(ra) # ac8 <printf>
  printf("# s9  = 9           #\n");
 170:	00001517          	auipc	a0,0x1
 174:	cb050513          	addi	a0,a0,-848 # e20 <dump_test4_asm+0x15e>
 178:	00001097          	auipc	ra,0x1
 17c:	950080e7          	jalr	-1712(ra) # ac8 <printf>
  printf("# s10 = 10          #\n");
 180:	00001517          	auipc	a0,0x1
 184:	cb850513          	addi	a0,a0,-840 # e38 <dump_test4_asm+0x176>
 188:	00001097          	auipc	ra,0x1
 18c:	940080e7          	jalr	-1728(ra) # ac8 <printf>
  printf("# s11 = 11          #\n");
 190:	00001517          	auipc	a0,0x1
 194:	cc050513          	addi	a0,a0,-832 # e50 <dump_test4_asm+0x18e>
 198:	00001097          	auipc	ra,0x1
 19c:	930080e7          	jalr	-1744(ra) # ac8 <printf>
  printf("#####################\n");
 1a0:	00001517          	auipc	a0,0x1
 1a4:	b6050513          	addi	a0,a0,-1184 # d00 <dump_test4_asm+0x3e>
 1a8:	00001097          	auipc	ra,0x1
 1ac:	920080e7          	jalr	-1760(ra) # ac8 <printf>
  dump_test2_asm();
 1b0:	00001097          	auipc	ra,0x1
 1b4:	ab6080e7          	jalr	-1354(ra) # c66 <dump_test2_asm>
}
 1b8:	60a2                	ld	ra,8(sp)
 1ba:	6402                	ld	s0,0(sp)
 1bc:	0141                	addi	sp,sp,16
 1be:	8082                	ret

00000000000001c0 <test3>:

int dump_test3_asm();

void test3() {
 1c0:	1141                	addi	sp,sp,-16
 1c2:	e406                	sd	ra,8(sp)
 1c4:	e022                	sd	s0,0(sp)
 1c6:	0800                	addi	s0,sp,16
  printf("#####################\n");
 1c8:	00001517          	auipc	a0,0x1
 1cc:	b3850513          	addi	a0,a0,-1224 # d00 <dump_test4_asm+0x3e>
 1d0:	00001097          	auipc	ra,0x1
 1d4:	8f8080e7          	jalr	-1800(ra) # ac8 <printf>
  printf("#                   #\n");
 1d8:	00001517          	auipc	a0,0x1
 1dc:	b4050513          	addi	a0,a0,-1216 # d18 <dump_test4_asm+0x56>
 1e0:	00001097          	auipc	ra,0x1
 1e4:	8e8080e7          	jalr	-1816(ra) # ac8 <printf>
  printf("#      test 2       #\n");
 1e8:	00001517          	auipc	a0,0x1
 1ec:	c8050513          	addi	a0,a0,-896 # e68 <dump_test4_asm+0x1a6>
 1f0:	00001097          	auipc	ra,0x1
 1f4:	8d8080e7          	jalr	-1832(ra) # ac8 <printf>
  printf("#                   #\n");
 1f8:	00001517          	auipc	a0,0x1
 1fc:	b2050513          	addi	a0,a0,-1248 # d18 <dump_test4_asm+0x56>
 200:	00001097          	auipc	ra,0x1
 204:	8c8080e7          	jalr	-1848(ra) # ac8 <printf>
  printf("#####################\n");
 208:	00001517          	auipc	a0,0x1
 20c:	af850513          	addi	a0,a0,-1288 # d00 <dump_test4_asm+0x3e>
 210:	00001097          	auipc	ra,0x1
 214:	8b8080e7          	jalr	-1864(ra) # ac8 <printf>
  printf("#                   #\n");
 218:	00001517          	auipc	a0,0x1
 21c:	b0050513          	addi	a0,a0,-1280 # d18 <dump_test4_asm+0x56>
 220:	00001097          	auipc	ra,0x1
 224:	8a8080e7          	jalr	-1880(ra) # ac8 <printf>
  printf("#  expected values  #\n");
 228:	00001517          	auipc	a0,0x1
 22c:	b3850513          	addi	a0,a0,-1224 # d60 <dump_test4_asm+0x9e>
 230:	00001097          	auipc	ra,0x1
 234:	898080e7          	jalr	-1896(ra) # ac8 <printf>
  printf("#                   #\n");
 238:	00001517          	auipc	a0,0x1
 23c:	ae050513          	addi	a0,a0,-1312 # d18 <dump_test4_asm+0x56>
 240:	00001097          	auipc	ra,0x1
 244:	888080e7          	jalr	-1912(ra) # ac8 <printf>
  printf("#####################\n");
 248:	00001517          	auipc	a0,0x1
 24c:	ab850513          	addi	a0,a0,-1352 # d00 <dump_test4_asm+0x3e>
 250:	00001097          	auipc	ra,0x1
 254:	878080e7          	jalr	-1928(ra) # ac8 <printf>
  printf("# s2 = 1            #\n");
 258:	00001517          	auipc	a0,0x1
 25c:	c2850513          	addi	a0,a0,-984 # e80 <dump_test4_asm+0x1be>
 260:	00001097          	auipc	ra,0x1
 264:	868080e7          	jalr	-1944(ra) # ac8 <printf>
  printf("# s3 = -12          #\n");
 268:	00001517          	auipc	a0,0x1
 26c:	c3050513          	addi	a0,a0,-976 # e98 <dump_test4_asm+0x1d6>
 270:	00001097          	auipc	ra,0x1
 274:	858080e7          	jalr	-1960(ra) # ac8 <printf>
  printf("# s4 = 123          #\n");
 278:	00001517          	auipc	a0,0x1
 27c:	c3850513          	addi	a0,a0,-968 # eb0 <dump_test4_asm+0x1ee>
 280:	00001097          	auipc	ra,0x1
 284:	848080e7          	jalr	-1976(ra) # ac8 <printf>
  printf("# s5 = -1234        #\n");
 288:	00001517          	auipc	a0,0x1
 28c:	c4050513          	addi	a0,a0,-960 # ec8 <dump_test4_asm+0x206>
 290:	00001097          	auipc	ra,0x1
 294:	838080e7          	jalr	-1992(ra) # ac8 <printf>
  printf("# s6 = 12345        #\n");
 298:	00001517          	auipc	a0,0x1
 29c:	c4850513          	addi	a0,a0,-952 # ee0 <dump_test4_asm+0x21e>
 2a0:	00001097          	auipc	ra,0x1
 2a4:	828080e7          	jalr	-2008(ra) # ac8 <printf>
  printf("# s7 = -123456      #\n");
 2a8:	00001517          	auipc	a0,0x1
 2ac:	c5050513          	addi	a0,a0,-944 # ef8 <dump_test4_asm+0x236>
 2b0:	00001097          	auipc	ra,0x1
 2b4:	818080e7          	jalr	-2024(ra) # ac8 <printf>
  printf("# s8 = 1234567      #\n");
 2b8:	00001517          	auipc	a0,0x1
 2bc:	c5850513          	addi	a0,a0,-936 # f10 <dump_test4_asm+0x24e>
 2c0:	00001097          	auipc	ra,0x1
 2c4:	808080e7          	jalr	-2040(ra) # ac8 <printf>
  printf("# s9 = -12345678    #\n");
 2c8:	00001517          	auipc	a0,0x1
 2cc:	c6050513          	addi	a0,a0,-928 # f28 <dump_test4_asm+0x266>
 2d0:	00000097          	auipc	ra,0x0
 2d4:	7f8080e7          	jalr	2040(ra) # ac8 <printf>
  printf("# s10 = 123456789   #\n");
 2d8:	00001517          	auipc	a0,0x1
 2dc:	c6850513          	addi	a0,a0,-920 # f40 <dump_test4_asm+0x27e>
 2e0:	00000097          	auipc	ra,0x0
 2e4:	7e8080e7          	jalr	2024(ra) # ac8 <printf>
  printf("# s11 = -1234567890 #\n");
 2e8:	00001517          	auipc	a0,0x1
 2ec:	c7050513          	addi	a0,a0,-912 # f58 <dump_test4_asm+0x296>
 2f0:	00000097          	auipc	ra,0x0
 2f4:	7d8080e7          	jalr	2008(ra) # ac8 <printf>
  printf("#####################\n");
 2f8:	00001517          	auipc	a0,0x1
 2fc:	a0850513          	addi	a0,a0,-1528 # d00 <dump_test4_asm+0x3e>
 300:	00000097          	auipc	ra,0x0
 304:	7c8080e7          	jalr	1992(ra) # ac8 <printf>
  dump_test3_asm();
 308:	00001097          	auipc	ra,0x1
 30c:	97a080e7          	jalr	-1670(ra) # c82 <dump_test3_asm>
}
 310:	60a2                	ld	ra,8(sp)
 312:	6402                	ld	s0,0(sp)
 314:	0141                	addi	sp,sp,16
 316:	8082                	ret

0000000000000318 <test4>:

int dump_test4_asm();

void test4() {
 318:	1141                	addi	sp,sp,-16
 31a:	e406                	sd	ra,8(sp)
 31c:	e022                	sd	s0,0(sp)
 31e:	0800                	addi	s0,sp,16
  printf("#####################\n");
 320:	00001517          	auipc	a0,0x1
 324:	9e050513          	addi	a0,a0,-1568 # d00 <dump_test4_asm+0x3e>
 328:	00000097          	auipc	ra,0x0
 32c:	7a0080e7          	jalr	1952(ra) # ac8 <printf>
  printf("#                   #\n");
 330:	00001517          	auipc	a0,0x1
 334:	9e850513          	addi	a0,a0,-1560 # d18 <dump_test4_asm+0x56>
 338:	00000097          	auipc	ra,0x0
 33c:	790080e7          	jalr	1936(ra) # ac8 <printf>
  printf("#      test 3       #\n");
 340:	00001517          	auipc	a0,0x1
 344:	c3050513          	addi	a0,a0,-976 # f70 <dump_test4_asm+0x2ae>
 348:	00000097          	auipc	ra,0x0
 34c:	780080e7          	jalr	1920(ra) # ac8 <printf>
  printf("#                   #\n");
 350:	00001517          	auipc	a0,0x1
 354:	9c850513          	addi	a0,a0,-1592 # d18 <dump_test4_asm+0x56>
 358:	00000097          	auipc	ra,0x0
 35c:	770080e7          	jalr	1904(ra) # ac8 <printf>
  printf("#####################\n");
 360:	00001517          	auipc	a0,0x1
 364:	9a050513          	addi	a0,a0,-1632 # d00 <dump_test4_asm+0x3e>
 368:	00000097          	auipc	ra,0x0
 36c:	760080e7          	jalr	1888(ra) # ac8 <printf>
  printf("#                   #\n");
 370:	00001517          	auipc	a0,0x1
 374:	9a850513          	addi	a0,a0,-1624 # d18 <dump_test4_asm+0x56>
 378:	00000097          	auipc	ra,0x0
 37c:	750080e7          	jalr	1872(ra) # ac8 <printf>
  printf("#  expected values  #\n");
 380:	00001517          	auipc	a0,0x1
 384:	9e050513          	addi	a0,a0,-1568 # d60 <dump_test4_asm+0x9e>
 388:	00000097          	auipc	ra,0x0
 38c:	740080e7          	jalr	1856(ra) # ac8 <printf>
  printf("#                   #\n");
 390:	00001517          	auipc	a0,0x1
 394:	98850513          	addi	a0,a0,-1656 # d18 <dump_test4_asm+0x56>
 398:	00000097          	auipc	ra,0x0
 39c:	730080e7          	jalr	1840(ra) # ac8 <printf>
  printf("#####################\n");
 3a0:	00001517          	auipc	a0,0x1
 3a4:	96050513          	addi	a0,a0,-1696 # d00 <dump_test4_asm+0x3e>
 3a8:	00000097          	auipc	ra,0x0
 3ac:	720080e7          	jalr	1824(ra) # ac8 <printf>
  printf("# s2 = 2147483647   #\n");
 3b0:	00001517          	auipc	a0,0x1
 3b4:	bd850513          	addi	a0,a0,-1064 # f88 <dump_test4_asm+0x2c6>
 3b8:	00000097          	auipc	ra,0x0
 3bc:	710080e7          	jalr	1808(ra) # ac8 <printf>
  printf("# s3 = -2147483648  #\n");
 3c0:	00001517          	auipc	a0,0x1
 3c4:	be050513          	addi	a0,a0,-1056 # fa0 <dump_test4_asm+0x2de>
 3c8:	00000097          	auipc	ra,0x0
 3cc:	700080e7          	jalr	1792(ra) # ac8 <printf>
  printf("# s4 = 1337         #\n");
 3d0:	00001517          	auipc	a0,0x1
 3d4:	be850513          	addi	a0,a0,-1048 # fb8 <dump_test4_asm+0x2f6>
 3d8:	00000097          	auipc	ra,0x0
 3dc:	6f0080e7          	jalr	1776(ra) # ac8 <printf>
  printf("# s5 = 2020         #\n");
 3e0:	00001517          	auipc	a0,0x1
 3e4:	bf050513          	addi	a0,a0,-1040 # fd0 <dump_test4_asm+0x30e>
 3e8:	00000097          	auipc	ra,0x0
 3ec:	6e0080e7          	jalr	1760(ra) # ac8 <printf>
  printf("# s6 = 3234         #\n");
 3f0:	00001517          	auipc	a0,0x1
 3f4:	bf850513          	addi	a0,a0,-1032 # fe8 <dump_test4_asm+0x326>
 3f8:	00000097          	auipc	ra,0x0
 3fc:	6d0080e7          	jalr	1744(ra) # ac8 <printf>
  printf("# s7 = 3235         #\n");
 400:	00001517          	auipc	a0,0x1
 404:	c0050513          	addi	a0,a0,-1024 # 1000 <dump_test4_asm+0x33e>
 408:	00000097          	auipc	ra,0x0
 40c:	6c0080e7          	jalr	1728(ra) # ac8 <printf>
  printf("# s8 = 3236         #\n");
 410:	00001517          	auipc	a0,0x1
 414:	c0850513          	addi	a0,a0,-1016 # 1018 <dump_test4_asm+0x356>
 418:	00000097          	auipc	ra,0x0
 41c:	6b0080e7          	jalr	1712(ra) # ac8 <printf>
  printf("# s9 = 3237         #\n");
 420:	00001517          	auipc	a0,0x1
 424:	c1050513          	addi	a0,a0,-1008 # 1030 <dump_test4_asm+0x36e>
 428:	00000097          	auipc	ra,0x0
 42c:	6a0080e7          	jalr	1696(ra) # ac8 <printf>
  printf("# s10 = 3238        #\n");
 430:	00001517          	auipc	a0,0x1
 434:	c1850513          	addi	a0,a0,-1000 # 1048 <dump_test4_asm+0x386>
 438:	00000097          	auipc	ra,0x0
 43c:	690080e7          	jalr	1680(ra) # ac8 <printf>
  printf("# s11 = 3239        #\n");
 440:	00001517          	auipc	a0,0x1
 444:	c2050513          	addi	a0,a0,-992 # 1060 <dump_test4_asm+0x39e>
 448:	00000097          	auipc	ra,0x0
 44c:	680080e7          	jalr	1664(ra) # ac8 <printf>
  printf("#####################\n");
 450:	00001517          	auipc	a0,0x1
 454:	8b050513          	addi	a0,a0,-1872 # d00 <dump_test4_asm+0x3e>
 458:	00000097          	auipc	ra,0x0
 45c:	670080e7          	jalr	1648(ra) # ac8 <printf>
  dump_test4_asm();
 460:	00001097          	auipc	ra,0x1
 464:	862080e7          	jalr	-1950(ra) # cc2 <dump_test4_asm>
}
 468:	60a2                	ld	ra,8(sp)
 46a:	6402                	ld	s0,0(sp)
 46c:	0141                	addi	sp,sp,16
 46e:	8082                	ret

0000000000000470 <main>:
int main(void) {
 470:	1141                	addi	sp,sp,-16
 472:	e406                	sd	ra,8(sp)
 474:	e022                	sd	s0,0(sp)
 476:	0800                	addi	s0,sp,16
  printf("dump tests started\n");
 478:	00001517          	auipc	a0,0x1
 47c:	c0050513          	addi	a0,a0,-1024 # 1078 <dump_test4_asm+0x3b6>
 480:	00000097          	auipc	ra,0x0
 484:	648080e7          	jalr	1608(ra) # ac8 <printf>
  printf("dump syscall found. Start testing\n");
 488:	00001517          	auipc	a0,0x1
 48c:	c0850513          	addi	a0,a0,-1016 # 1090 <dump_test4_asm+0x3ce>
 490:	00000097          	auipc	ra,0x0
 494:	638080e7          	jalr	1592(ra) # ac8 <printf>
  test1();
 498:	00000097          	auipc	ra,0x0
 49c:	b68080e7          	jalr	-1176(ra) # 0 <test1>
  test2();
 4a0:	00000097          	auipc	ra,0x0
 4a4:	bc8080e7          	jalr	-1080(ra) # 68 <test2>
  test3();
 4a8:	00000097          	auipc	ra,0x0
 4ac:	d18080e7          	jalr	-744(ra) # 1c0 <test3>
  test4();
 4b0:	00000097          	auipc	ra,0x0
 4b4:	e68080e7          	jalr	-408(ra) # 318 <test4>
  printf("4 tests were ran\n");
 4b8:	00001517          	auipc	a0,0x1
 4bc:	c0050513          	addi	a0,a0,-1024 # 10b8 <dump_test4_asm+0x3f6>
 4c0:	00000097          	auipc	ra,0x0
 4c4:	608080e7          	jalr	1544(ra) # ac8 <printf>
  exit(0);
 4c8:	4501                	li	a0,0
 4ca:	00000097          	auipc	ra,0x0
 4ce:	28e080e7          	jalr	654(ra) # 758 <exit>

00000000000004d2 <_main>:
//
// wrapper so that it's OK if main() does not call exit().
//
void
_main()
{
 4d2:	1141                	addi	sp,sp,-16
 4d4:	e406                	sd	ra,8(sp)
 4d6:	e022                	sd	s0,0(sp)
 4d8:	0800                	addi	s0,sp,16
  extern int main();
  main();
 4da:	00000097          	auipc	ra,0x0
 4de:	f96080e7          	jalr	-106(ra) # 470 <main>
  exit(0);
 4e2:	4501                	li	a0,0
 4e4:	00000097          	auipc	ra,0x0
 4e8:	274080e7          	jalr	628(ra) # 758 <exit>

00000000000004ec <strcpy>:
}

char*
strcpy(char *s, const char *t)
{
 4ec:	1141                	addi	sp,sp,-16
 4ee:	e422                	sd	s0,8(sp)
 4f0:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
 4f2:	87aa                	mv	a5,a0
 4f4:	0585                	addi	a1,a1,1
 4f6:	0785                	addi	a5,a5,1
 4f8:	fff5c703          	lbu	a4,-1(a1)
 4fc:	fee78fa3          	sb	a4,-1(a5)
 500:	fb75                	bnez	a4,4f4 <strcpy+0x8>
    ;
  return os;
}
 502:	6422                	ld	s0,8(sp)
 504:	0141                	addi	sp,sp,16
 506:	8082                	ret

0000000000000508 <strcmp>:

int
strcmp(const char *p, const char *q)
{
 508:	1141                	addi	sp,sp,-16
 50a:	e422                	sd	s0,8(sp)
 50c:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
 50e:	00054783          	lbu	a5,0(a0)
 512:	cb91                	beqz	a5,526 <strcmp+0x1e>
 514:	0005c703          	lbu	a4,0(a1)
 518:	00f71763          	bne	a4,a5,526 <strcmp+0x1e>
    p++, q++;
 51c:	0505                	addi	a0,a0,1
 51e:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
 520:	00054783          	lbu	a5,0(a0)
 524:	fbe5                	bnez	a5,514 <strcmp+0xc>
  return (uchar)*p - (uchar)*q;
 526:	0005c503          	lbu	a0,0(a1)
}
 52a:	40a7853b          	subw	a0,a5,a0
 52e:	6422                	ld	s0,8(sp)
 530:	0141                	addi	sp,sp,16
 532:	8082                	ret

0000000000000534 <strlen>:

uint
strlen(const char *s)
{
 534:	1141                	addi	sp,sp,-16
 536:	e422                	sd	s0,8(sp)
 538:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
 53a:	00054783          	lbu	a5,0(a0)
 53e:	cf91                	beqz	a5,55a <strlen+0x26>
 540:	0505                	addi	a0,a0,1
 542:	87aa                	mv	a5,a0
 544:	86be                	mv	a3,a5
 546:	0785                	addi	a5,a5,1
 548:	fff7c703          	lbu	a4,-1(a5)
 54c:	ff65                	bnez	a4,544 <strlen+0x10>
 54e:	40a6853b          	subw	a0,a3,a0
 552:	2505                	addiw	a0,a0,1
    ;
  return n;
}
 554:	6422                	ld	s0,8(sp)
 556:	0141                	addi	sp,sp,16
 558:	8082                	ret
  for(n = 0; s[n]; n++)
 55a:	4501                	li	a0,0
 55c:	bfe5                	j	554 <strlen+0x20>

000000000000055e <memset>:

void*
memset(void *dst, int c, uint n)
{
 55e:	1141                	addi	sp,sp,-16
 560:	e422                	sd	s0,8(sp)
 562:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
 564:	ca19                	beqz	a2,57a <memset+0x1c>
 566:	87aa                	mv	a5,a0
 568:	1602                	slli	a2,a2,0x20
 56a:	9201                	srli	a2,a2,0x20
 56c:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
 570:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
 574:	0785                	addi	a5,a5,1
 576:	fee79de3          	bne	a5,a4,570 <memset+0x12>
  }
  return dst;
}
 57a:	6422                	ld	s0,8(sp)
 57c:	0141                	addi	sp,sp,16
 57e:	8082                	ret

0000000000000580 <strchr>:

char*
strchr(const char *s, char c)
{
 580:	1141                	addi	sp,sp,-16
 582:	e422                	sd	s0,8(sp)
 584:	0800                	addi	s0,sp,16
  for(; *s; s++)
 586:	00054783          	lbu	a5,0(a0)
 58a:	cb99                	beqz	a5,5a0 <strchr+0x20>
    if(*s == c)
 58c:	00f58763          	beq	a1,a5,59a <strchr+0x1a>
  for(; *s; s++)
 590:	0505                	addi	a0,a0,1
 592:	00054783          	lbu	a5,0(a0)
 596:	fbfd                	bnez	a5,58c <strchr+0xc>
      return (char*)s;
  return 0;
 598:	4501                	li	a0,0
}
 59a:	6422                	ld	s0,8(sp)
 59c:	0141                	addi	sp,sp,16
 59e:	8082                	ret
  return 0;
 5a0:	4501                	li	a0,0
 5a2:	bfe5                	j	59a <strchr+0x1a>

00000000000005a4 <gets>:

char*
gets(char *buf, int max)
{
 5a4:	711d                	addi	sp,sp,-96
 5a6:	ec86                	sd	ra,88(sp)
 5a8:	e8a2                	sd	s0,80(sp)
 5aa:	e4a6                	sd	s1,72(sp)
 5ac:	e0ca                	sd	s2,64(sp)
 5ae:	fc4e                	sd	s3,56(sp)
 5b0:	f852                	sd	s4,48(sp)
 5b2:	f456                	sd	s5,40(sp)
 5b4:	f05a                	sd	s6,32(sp)
 5b6:	ec5e                	sd	s7,24(sp)
 5b8:	1080                	addi	s0,sp,96
 5ba:	8baa                	mv	s7,a0
 5bc:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 5be:	892a                	mv	s2,a0
 5c0:	4481                	li	s1,0
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
 5c2:	4aa9                	li	s5,10
 5c4:	4b35                	li	s6,13
  for(i=0; i+1 < max; ){
 5c6:	89a6                	mv	s3,s1
 5c8:	2485                	addiw	s1,s1,1
 5ca:	0344d863          	bge	s1,s4,5fa <gets+0x56>
    cc = read(0, &c, 1);
 5ce:	4605                	li	a2,1
 5d0:	faf40593          	addi	a1,s0,-81
 5d4:	4501                	li	a0,0
 5d6:	00000097          	auipc	ra,0x0
 5da:	19a080e7          	jalr	410(ra) # 770 <read>
    if(cc < 1)
 5de:	00a05e63          	blez	a0,5fa <gets+0x56>
    buf[i++] = c;
 5e2:	faf44783          	lbu	a5,-81(s0)
 5e6:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
 5ea:	01578763          	beq	a5,s5,5f8 <gets+0x54>
 5ee:	0905                	addi	s2,s2,1
 5f0:	fd679be3          	bne	a5,s6,5c6 <gets+0x22>
  for(i=0; i+1 < max; ){
 5f4:	89a6                	mv	s3,s1
 5f6:	a011                	j	5fa <gets+0x56>
 5f8:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
 5fa:	99de                	add	s3,s3,s7
 5fc:	00098023          	sb	zero,0(s3)
  return buf;
}
 600:	855e                	mv	a0,s7
 602:	60e6                	ld	ra,88(sp)
 604:	6446                	ld	s0,80(sp)
 606:	64a6                	ld	s1,72(sp)
 608:	6906                	ld	s2,64(sp)
 60a:	79e2                	ld	s3,56(sp)
 60c:	7a42                	ld	s4,48(sp)
 60e:	7aa2                	ld	s5,40(sp)
 610:	7b02                	ld	s6,32(sp)
 612:	6be2                	ld	s7,24(sp)
 614:	6125                	addi	sp,sp,96
 616:	8082                	ret

0000000000000618 <stat>:

int
stat(const char *n, struct stat *st)
{
 618:	1101                	addi	sp,sp,-32
 61a:	ec06                	sd	ra,24(sp)
 61c:	e822                	sd	s0,16(sp)
 61e:	e426                	sd	s1,8(sp)
 620:	e04a                	sd	s2,0(sp)
 622:	1000                	addi	s0,sp,32
 624:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 626:	4581                	li	a1,0
 628:	00000097          	auipc	ra,0x0
 62c:	170080e7          	jalr	368(ra) # 798 <open>
  if(fd < 0)
 630:	02054563          	bltz	a0,65a <stat+0x42>
 634:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 636:	85ca                	mv	a1,s2
 638:	00000097          	auipc	ra,0x0
 63c:	178080e7          	jalr	376(ra) # 7b0 <fstat>
 640:	892a                	mv	s2,a0
  close(fd);
 642:	8526                	mv	a0,s1
 644:	00000097          	auipc	ra,0x0
 648:	13c080e7          	jalr	316(ra) # 780 <close>
  return r;
}
 64c:	854a                	mv	a0,s2
 64e:	60e2                	ld	ra,24(sp)
 650:	6442                	ld	s0,16(sp)
 652:	64a2                	ld	s1,8(sp)
 654:	6902                	ld	s2,0(sp)
 656:	6105                	addi	sp,sp,32
 658:	8082                	ret
    return -1;
 65a:	597d                	li	s2,-1
 65c:	bfc5                	j	64c <stat+0x34>

000000000000065e <atoi>:

int
atoi(const char *s)
{
 65e:	1141                	addi	sp,sp,-16
 660:	e422                	sd	s0,8(sp)
 662:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 664:	00054683          	lbu	a3,0(a0)
 668:	fd06879b          	addiw	a5,a3,-48
 66c:	0ff7f793          	zext.b	a5,a5
 670:	4625                	li	a2,9
 672:	02f66863          	bltu	a2,a5,6a2 <atoi+0x44>
 676:	872a                	mv	a4,a0
  n = 0;
 678:	4501                	li	a0,0
    n = n*10 + *s++ - '0';
 67a:	0705                	addi	a4,a4,1
 67c:	0025179b          	slliw	a5,a0,0x2
 680:	9fa9                	addw	a5,a5,a0
 682:	0017979b          	slliw	a5,a5,0x1
 686:	9fb5                	addw	a5,a5,a3
 688:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 68c:	00074683          	lbu	a3,0(a4)
 690:	fd06879b          	addiw	a5,a3,-48
 694:	0ff7f793          	zext.b	a5,a5
 698:	fef671e3          	bgeu	a2,a5,67a <atoi+0x1c>
  return n;
}
 69c:	6422                	ld	s0,8(sp)
 69e:	0141                	addi	sp,sp,16
 6a0:	8082                	ret
  n = 0;
 6a2:	4501                	li	a0,0
 6a4:	bfe5                	j	69c <atoi+0x3e>

00000000000006a6 <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 6a6:	1141                	addi	sp,sp,-16
 6a8:	e422                	sd	s0,8(sp)
 6aa:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 6ac:	02b57463          	bgeu	a0,a1,6d4 <memmove+0x2e>
    while(n-- > 0)
 6b0:	00c05f63          	blez	a2,6ce <memmove+0x28>
 6b4:	1602                	slli	a2,a2,0x20
 6b6:	9201                	srli	a2,a2,0x20
 6b8:	00c507b3          	add	a5,a0,a2
  dst = vdst;
 6bc:	872a                	mv	a4,a0
      *dst++ = *src++;
 6be:	0585                	addi	a1,a1,1
 6c0:	0705                	addi	a4,a4,1
 6c2:	fff5c683          	lbu	a3,-1(a1)
 6c6:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
 6ca:	fee79ae3          	bne	a5,a4,6be <memmove+0x18>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 6ce:	6422                	ld	s0,8(sp)
 6d0:	0141                	addi	sp,sp,16
 6d2:	8082                	ret
    dst += n;
 6d4:	00c50733          	add	a4,a0,a2
    src += n;
 6d8:	95b2                	add	a1,a1,a2
    while(n-- > 0)
 6da:	fec05ae3          	blez	a2,6ce <memmove+0x28>
 6de:	fff6079b          	addiw	a5,a2,-1
 6e2:	1782                	slli	a5,a5,0x20
 6e4:	9381                	srli	a5,a5,0x20
 6e6:	fff7c793          	not	a5,a5
 6ea:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 6ec:	15fd                	addi	a1,a1,-1
 6ee:	177d                	addi	a4,a4,-1
 6f0:	0005c683          	lbu	a3,0(a1)
 6f4:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
 6f8:	fee79ae3          	bne	a5,a4,6ec <memmove+0x46>
 6fc:	bfc9                	j	6ce <memmove+0x28>

00000000000006fe <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 6fe:	1141                	addi	sp,sp,-16
 700:	e422                	sd	s0,8(sp)
 702:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 704:	ca05                	beqz	a2,734 <memcmp+0x36>
 706:	fff6069b          	addiw	a3,a2,-1
 70a:	1682                	slli	a3,a3,0x20
 70c:	9281                	srli	a3,a3,0x20
 70e:	0685                	addi	a3,a3,1
 710:	96aa                	add	a3,a3,a0
    if (*p1 != *p2) {
 712:	00054783          	lbu	a5,0(a0)
 716:	0005c703          	lbu	a4,0(a1)
 71a:	00e79863          	bne	a5,a4,72a <memcmp+0x2c>
      return *p1 - *p2;
    }
    p1++;
 71e:	0505                	addi	a0,a0,1
    p2++;
 720:	0585                	addi	a1,a1,1
  while (n-- > 0) {
 722:	fed518e3          	bne	a0,a3,712 <memcmp+0x14>
  }
  return 0;
 726:	4501                	li	a0,0
 728:	a019                	j	72e <memcmp+0x30>
      return *p1 - *p2;
 72a:	40e7853b          	subw	a0,a5,a4
}
 72e:	6422                	ld	s0,8(sp)
 730:	0141                	addi	sp,sp,16
 732:	8082                	ret
  return 0;
 734:	4501                	li	a0,0
 736:	bfe5                	j	72e <memcmp+0x30>

0000000000000738 <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 738:	1141                	addi	sp,sp,-16
 73a:	e406                	sd	ra,8(sp)
 73c:	e022                	sd	s0,0(sp)
 73e:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
 740:	00000097          	auipc	ra,0x0
 744:	f66080e7          	jalr	-154(ra) # 6a6 <memmove>
}
 748:	60a2                	ld	ra,8(sp)
 74a:	6402                	ld	s0,0(sp)
 74c:	0141                	addi	sp,sp,16
 74e:	8082                	ret

0000000000000750 <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 750:	4885                	li	a7,1
 ecall
 752:	00000073          	ecall
 ret
 756:	8082                	ret

0000000000000758 <exit>:
.global exit
exit:
 li a7, SYS_exit
 758:	4889                	li	a7,2
 ecall
 75a:	00000073          	ecall
 ret
 75e:	8082                	ret

0000000000000760 <wait>:
.global wait
wait:
 li a7, SYS_wait
 760:	488d                	li	a7,3
 ecall
 762:	00000073          	ecall
 ret
 766:	8082                	ret

0000000000000768 <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 768:	4891                	li	a7,4
 ecall
 76a:	00000073          	ecall
 ret
 76e:	8082                	ret

0000000000000770 <read>:
.global read
read:
 li a7, SYS_read
 770:	4895                	li	a7,5
 ecall
 772:	00000073          	ecall
 ret
 776:	8082                	ret

0000000000000778 <write>:
.global write
write:
 li a7, SYS_write
 778:	48c1                	li	a7,16
 ecall
 77a:	00000073          	ecall
 ret
 77e:	8082                	ret

0000000000000780 <close>:
.global close
close:
 li a7, SYS_close
 780:	48d5                	li	a7,21
 ecall
 782:	00000073          	ecall
 ret
 786:	8082                	ret

0000000000000788 <kill>:
.global kill
kill:
 li a7, SYS_kill
 788:	4899                	li	a7,6
 ecall
 78a:	00000073          	ecall
 ret
 78e:	8082                	ret

0000000000000790 <exec>:
.global exec
exec:
 li a7, SYS_exec
 790:	489d                	li	a7,7
 ecall
 792:	00000073          	ecall
 ret
 796:	8082                	ret

0000000000000798 <open>:
.global open
open:
 li a7, SYS_open
 798:	48bd                	li	a7,15
 ecall
 79a:	00000073          	ecall
 ret
 79e:	8082                	ret

00000000000007a0 <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 7a0:	48c5                	li	a7,17
 ecall
 7a2:	00000073          	ecall
 ret
 7a6:	8082                	ret

00000000000007a8 <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 7a8:	48c9                	li	a7,18
 ecall
 7aa:	00000073          	ecall
 ret
 7ae:	8082                	ret

00000000000007b0 <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 7b0:	48a1                	li	a7,8
 ecall
 7b2:	00000073          	ecall
 ret
 7b6:	8082                	ret

00000000000007b8 <link>:
.global link
link:
 li a7, SYS_link
 7b8:	48cd                	li	a7,19
 ecall
 7ba:	00000073          	ecall
 ret
 7be:	8082                	ret

00000000000007c0 <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 7c0:	48d1                	li	a7,20
 ecall
 7c2:	00000073          	ecall
 ret
 7c6:	8082                	ret

00000000000007c8 <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 7c8:	48a5                	li	a7,9
 ecall
 7ca:	00000073          	ecall
 ret
 7ce:	8082                	ret

00000000000007d0 <dup>:
.global dup
dup:
 li a7, SYS_dup
 7d0:	48a9                	li	a7,10
 ecall
 7d2:	00000073          	ecall
 ret
 7d6:	8082                	ret

00000000000007d8 <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 7d8:	48ad                	li	a7,11
 ecall
 7da:	00000073          	ecall
 ret
 7de:	8082                	ret

00000000000007e0 <sbrk>:
.global sbrk
sbrk:
 li a7, SYS_sbrk
 7e0:	48b1                	li	a7,12
 ecall
 7e2:	00000073          	ecall
 ret
 7e6:	8082                	ret

00000000000007e8 <sleep>:
.global sleep
sleep:
 li a7, SYS_sleep
 7e8:	48b5                	li	a7,13
 ecall
 7ea:	00000073          	ecall
 ret
 7ee:	8082                	ret

00000000000007f0 <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 7f0:	48b9                	li	a7,14
 ecall
 7f2:	00000073          	ecall
 ret
 7f6:	8082                	ret

00000000000007f8 <dump>:
.global dump
dump:
 li a7, SYS_dump
 7f8:	48d9                	li	a7,22
 ecall
 7fa:	00000073          	ecall
 ret
 7fe:	8082                	ret

0000000000000800 <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 800:	1101                	addi	sp,sp,-32
 802:	ec06                	sd	ra,24(sp)
 804:	e822                	sd	s0,16(sp)
 806:	1000                	addi	s0,sp,32
 808:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 80c:	4605                	li	a2,1
 80e:	fef40593          	addi	a1,s0,-17
 812:	00000097          	auipc	ra,0x0
 816:	f66080e7          	jalr	-154(ra) # 778 <write>
}
 81a:	60e2                	ld	ra,24(sp)
 81c:	6442                	ld	s0,16(sp)
 81e:	6105                	addi	sp,sp,32
 820:	8082                	ret

0000000000000822 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 822:	7139                	addi	sp,sp,-64
 824:	fc06                	sd	ra,56(sp)
 826:	f822                	sd	s0,48(sp)
 828:	f426                	sd	s1,40(sp)
 82a:	f04a                	sd	s2,32(sp)
 82c:	ec4e                	sd	s3,24(sp)
 82e:	0080                	addi	s0,sp,64
 830:	84aa                	mv	s1,a0
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
 832:	c299                	beqz	a3,838 <printint+0x16>
 834:	0805c963          	bltz	a1,8c6 <printint+0xa4>
    neg = 1;
    x = -xx;
  } else {
    x = xx;
 838:	2581                	sext.w	a1,a1
  neg = 0;
 83a:	4881                	li	a7,0
 83c:	fc040693          	addi	a3,s0,-64
  }

  i = 0;
 840:	4701                	li	a4,0
  do{
    buf[i++] = digits[x % base];
 842:	2601                	sext.w	a2,a2
 844:	00001517          	auipc	a0,0x1
 848:	8ec50513          	addi	a0,a0,-1812 # 1130 <digits>
 84c:	883a                	mv	a6,a4
 84e:	2705                	addiw	a4,a4,1
 850:	02c5f7bb          	remuw	a5,a1,a2
 854:	1782                	slli	a5,a5,0x20
 856:	9381                	srli	a5,a5,0x20
 858:	97aa                	add	a5,a5,a0
 85a:	0007c783          	lbu	a5,0(a5)
 85e:	00f68023          	sb	a5,0(a3)
  }while((x /= base) != 0);
 862:	0005879b          	sext.w	a5,a1
 866:	02c5d5bb          	divuw	a1,a1,a2
 86a:	0685                	addi	a3,a3,1
 86c:	fec7f0e3          	bgeu	a5,a2,84c <printint+0x2a>
  if(neg)
 870:	00088c63          	beqz	a7,888 <printint+0x66>
    buf[i++] = '-';
 874:	fd070793          	addi	a5,a4,-48
 878:	00878733          	add	a4,a5,s0
 87c:	02d00793          	li	a5,45
 880:	fef70823          	sb	a5,-16(a4)
 884:	0028071b          	addiw	a4,a6,2

  while(--i >= 0)
 888:	02e05863          	blez	a4,8b8 <printint+0x96>
 88c:	fc040793          	addi	a5,s0,-64
 890:	00e78933          	add	s2,a5,a4
 894:	fff78993          	addi	s3,a5,-1
 898:	99ba                	add	s3,s3,a4
 89a:	377d                	addiw	a4,a4,-1
 89c:	1702                	slli	a4,a4,0x20
 89e:	9301                	srli	a4,a4,0x20
 8a0:	40e989b3          	sub	s3,s3,a4
    putc(fd, buf[i]);
 8a4:	fff94583          	lbu	a1,-1(s2)
 8a8:	8526                	mv	a0,s1
 8aa:	00000097          	auipc	ra,0x0
 8ae:	f56080e7          	jalr	-170(ra) # 800 <putc>
  while(--i >= 0)
 8b2:	197d                	addi	s2,s2,-1
 8b4:	ff3918e3          	bne	s2,s3,8a4 <printint+0x82>
}
 8b8:	70e2                	ld	ra,56(sp)
 8ba:	7442                	ld	s0,48(sp)
 8bc:	74a2                	ld	s1,40(sp)
 8be:	7902                	ld	s2,32(sp)
 8c0:	69e2                	ld	s3,24(sp)
 8c2:	6121                	addi	sp,sp,64
 8c4:	8082                	ret
    x = -xx;
 8c6:	40b005bb          	negw	a1,a1
    neg = 1;
 8ca:	4885                	li	a7,1
    x = -xx;
 8cc:	bf85                	j	83c <printint+0x1a>

00000000000008ce <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 8ce:	715d                	addi	sp,sp,-80
 8d0:	e486                	sd	ra,72(sp)
 8d2:	e0a2                	sd	s0,64(sp)
 8d4:	fc26                	sd	s1,56(sp)
 8d6:	f84a                	sd	s2,48(sp)
 8d8:	f44e                	sd	s3,40(sp)
 8da:	f052                	sd	s4,32(sp)
 8dc:	ec56                	sd	s5,24(sp)
 8de:	e85a                	sd	s6,16(sp)
 8e0:	e45e                	sd	s7,8(sp)
 8e2:	e062                	sd	s8,0(sp)
 8e4:	0880                	addi	s0,sp,80
  char *s;
  int c, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 8e6:	0005c903          	lbu	s2,0(a1)
 8ea:	18090c63          	beqz	s2,a82 <vprintf+0x1b4>
 8ee:	8aaa                	mv	s5,a0
 8f0:	8bb2                	mv	s7,a2
 8f2:	00158493          	addi	s1,a1,1
  state = 0;
 8f6:	4981                	li	s3,0
      if(c == '%'){
        state = '%';
      } else {
        putc(fd, c);
      }
    } else if(state == '%'){
 8f8:	02500a13          	li	s4,37
 8fc:	4b55                	li	s6,21
 8fe:	a839                	j	91c <vprintf+0x4e>
        putc(fd, c);
 900:	85ca                	mv	a1,s2
 902:	8556                	mv	a0,s5
 904:	00000097          	auipc	ra,0x0
 908:	efc080e7          	jalr	-260(ra) # 800 <putc>
 90c:	a019                	j	912 <vprintf+0x44>
    } else if(state == '%'){
 90e:	01498d63          	beq	s3,s4,928 <vprintf+0x5a>
  for(i = 0; fmt[i]; i++){
 912:	0485                	addi	s1,s1,1
 914:	fff4c903          	lbu	s2,-1(s1)
 918:	16090563          	beqz	s2,a82 <vprintf+0x1b4>
    if(state == 0){
 91c:	fe0999e3          	bnez	s3,90e <vprintf+0x40>
      if(c == '%'){
 920:	ff4910e3          	bne	s2,s4,900 <vprintf+0x32>
        state = '%';
 924:	89d2                	mv	s3,s4
 926:	b7f5                	j	912 <vprintf+0x44>
      if(c == 'd'){
 928:	13490263          	beq	s2,s4,a4c <vprintf+0x17e>
 92c:	f9d9079b          	addiw	a5,s2,-99
 930:	0ff7f793          	zext.b	a5,a5
 934:	12fb6563          	bltu	s6,a5,a5e <vprintf+0x190>
 938:	f9d9079b          	addiw	a5,s2,-99
 93c:	0ff7f713          	zext.b	a4,a5
 940:	10eb6f63          	bltu	s6,a4,a5e <vprintf+0x190>
 944:	00271793          	slli	a5,a4,0x2
 948:	00000717          	auipc	a4,0x0
 94c:	79070713          	addi	a4,a4,1936 # 10d8 <dump_test4_asm+0x416>
 950:	97ba                	add	a5,a5,a4
 952:	439c                	lw	a5,0(a5)
 954:	97ba                	add	a5,a5,a4
 956:	8782                	jr	a5
        printint(fd, va_arg(ap, int), 10, 1);
 958:	008b8913          	addi	s2,s7,8
 95c:	4685                	li	a3,1
 95e:	4629                	li	a2,10
 960:	000ba583          	lw	a1,0(s7)
 964:	8556                	mv	a0,s5
 966:	00000097          	auipc	ra,0x0
 96a:	ebc080e7          	jalr	-324(ra) # 822 <printint>
 96e:	8bca                	mv	s7,s2
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c);
      }
      state = 0;
 970:	4981                	li	s3,0
 972:	b745                	j	912 <vprintf+0x44>
        printint(fd, va_arg(ap, uint64), 10, 0);
 974:	008b8913          	addi	s2,s7,8
 978:	4681                	li	a3,0
 97a:	4629                	li	a2,10
 97c:	000ba583          	lw	a1,0(s7)
 980:	8556                	mv	a0,s5
 982:	00000097          	auipc	ra,0x0
 986:	ea0080e7          	jalr	-352(ra) # 822 <printint>
 98a:	8bca                	mv	s7,s2
      state = 0;
 98c:	4981                	li	s3,0
 98e:	b751                	j	912 <vprintf+0x44>
        printint(fd, va_arg(ap, int), 16, 0);
 990:	008b8913          	addi	s2,s7,8
 994:	4681                	li	a3,0
 996:	4641                	li	a2,16
 998:	000ba583          	lw	a1,0(s7)
 99c:	8556                	mv	a0,s5
 99e:	00000097          	auipc	ra,0x0
 9a2:	e84080e7          	jalr	-380(ra) # 822 <printint>
 9a6:	8bca                	mv	s7,s2
      state = 0;
 9a8:	4981                	li	s3,0
 9aa:	b7a5                	j	912 <vprintf+0x44>
        printptr(fd, va_arg(ap, uint64));
 9ac:	008b8c13          	addi	s8,s7,8
 9b0:	000bb983          	ld	s3,0(s7)
  putc(fd, '0');
 9b4:	03000593          	li	a1,48
 9b8:	8556                	mv	a0,s5
 9ba:	00000097          	auipc	ra,0x0
 9be:	e46080e7          	jalr	-442(ra) # 800 <putc>
  putc(fd, 'x');
 9c2:	07800593          	li	a1,120
 9c6:	8556                	mv	a0,s5
 9c8:	00000097          	auipc	ra,0x0
 9cc:	e38080e7          	jalr	-456(ra) # 800 <putc>
 9d0:	4941                	li	s2,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 9d2:	00000b97          	auipc	s7,0x0
 9d6:	75eb8b93          	addi	s7,s7,1886 # 1130 <digits>
 9da:	03c9d793          	srli	a5,s3,0x3c
 9de:	97de                	add	a5,a5,s7
 9e0:	0007c583          	lbu	a1,0(a5)
 9e4:	8556                	mv	a0,s5
 9e6:	00000097          	auipc	ra,0x0
 9ea:	e1a080e7          	jalr	-486(ra) # 800 <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 9ee:	0992                	slli	s3,s3,0x4
 9f0:	397d                	addiw	s2,s2,-1
 9f2:	fe0914e3          	bnez	s2,9da <vprintf+0x10c>
        printptr(fd, va_arg(ap, uint64));
 9f6:	8be2                	mv	s7,s8
      state = 0;
 9f8:	4981                	li	s3,0
 9fa:	bf21                	j	912 <vprintf+0x44>
        s = va_arg(ap, char*);
 9fc:	008b8993          	addi	s3,s7,8
 a00:	000bb903          	ld	s2,0(s7)
        if(s == 0)
 a04:	02090163          	beqz	s2,a26 <vprintf+0x158>
        while(*s != 0){
 a08:	00094583          	lbu	a1,0(s2)
 a0c:	c9a5                	beqz	a1,a7c <vprintf+0x1ae>
          putc(fd, *s);
 a0e:	8556                	mv	a0,s5
 a10:	00000097          	auipc	ra,0x0
 a14:	df0080e7          	jalr	-528(ra) # 800 <putc>
          s++;
 a18:	0905                	addi	s2,s2,1
        while(*s != 0){
 a1a:	00094583          	lbu	a1,0(s2)
 a1e:	f9e5                	bnez	a1,a0e <vprintf+0x140>
        s = va_arg(ap, char*);
 a20:	8bce                	mv	s7,s3
      state = 0;
 a22:	4981                	li	s3,0
 a24:	b5fd                	j	912 <vprintf+0x44>
          s = "(null)";
 a26:	00000917          	auipc	s2,0x0
 a2a:	6aa90913          	addi	s2,s2,1706 # 10d0 <dump_test4_asm+0x40e>
        while(*s != 0){
 a2e:	02800593          	li	a1,40
 a32:	bff1                	j	a0e <vprintf+0x140>
        putc(fd, va_arg(ap, uint));
 a34:	008b8913          	addi	s2,s7,8
 a38:	000bc583          	lbu	a1,0(s7)
 a3c:	8556                	mv	a0,s5
 a3e:	00000097          	auipc	ra,0x0
 a42:	dc2080e7          	jalr	-574(ra) # 800 <putc>
 a46:	8bca                	mv	s7,s2
      state = 0;
 a48:	4981                	li	s3,0
 a4a:	b5e1                	j	912 <vprintf+0x44>
        putc(fd, c);
 a4c:	02500593          	li	a1,37
 a50:	8556                	mv	a0,s5
 a52:	00000097          	auipc	ra,0x0
 a56:	dae080e7          	jalr	-594(ra) # 800 <putc>
      state = 0;
 a5a:	4981                	li	s3,0
 a5c:	bd5d                	j	912 <vprintf+0x44>
        putc(fd, '%');
 a5e:	02500593          	li	a1,37
 a62:	8556                	mv	a0,s5
 a64:	00000097          	auipc	ra,0x0
 a68:	d9c080e7          	jalr	-612(ra) # 800 <putc>
        putc(fd, c);
 a6c:	85ca                	mv	a1,s2
 a6e:	8556                	mv	a0,s5
 a70:	00000097          	auipc	ra,0x0
 a74:	d90080e7          	jalr	-624(ra) # 800 <putc>
      state = 0;
 a78:	4981                	li	s3,0
 a7a:	bd61                	j	912 <vprintf+0x44>
        s = va_arg(ap, char*);
 a7c:	8bce                	mv	s7,s3
      state = 0;
 a7e:	4981                	li	s3,0
 a80:	bd49                	j	912 <vprintf+0x44>
    }
  }
}
 a82:	60a6                	ld	ra,72(sp)
 a84:	6406                	ld	s0,64(sp)
 a86:	74e2                	ld	s1,56(sp)
 a88:	7942                	ld	s2,48(sp)
 a8a:	79a2                	ld	s3,40(sp)
 a8c:	7a02                	ld	s4,32(sp)
 a8e:	6ae2                	ld	s5,24(sp)
 a90:	6b42                	ld	s6,16(sp)
 a92:	6ba2                	ld	s7,8(sp)
 a94:	6c02                	ld	s8,0(sp)
 a96:	6161                	addi	sp,sp,80
 a98:	8082                	ret

0000000000000a9a <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 a9a:	715d                	addi	sp,sp,-80
 a9c:	ec06                	sd	ra,24(sp)
 a9e:	e822                	sd	s0,16(sp)
 aa0:	1000                	addi	s0,sp,32
 aa2:	e010                	sd	a2,0(s0)
 aa4:	e414                	sd	a3,8(s0)
 aa6:	e818                	sd	a4,16(s0)
 aa8:	ec1c                	sd	a5,24(s0)
 aaa:	03043023          	sd	a6,32(s0)
 aae:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 ab2:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 ab6:	8622                	mv	a2,s0
 ab8:	00000097          	auipc	ra,0x0
 abc:	e16080e7          	jalr	-490(ra) # 8ce <vprintf>
}
 ac0:	60e2                	ld	ra,24(sp)
 ac2:	6442                	ld	s0,16(sp)
 ac4:	6161                	addi	sp,sp,80
 ac6:	8082                	ret

0000000000000ac8 <printf>:

void
printf(const char *fmt, ...)
{
 ac8:	711d                	addi	sp,sp,-96
 aca:	ec06                	sd	ra,24(sp)
 acc:	e822                	sd	s0,16(sp)
 ace:	1000                	addi	s0,sp,32
 ad0:	e40c                	sd	a1,8(s0)
 ad2:	e810                	sd	a2,16(s0)
 ad4:	ec14                	sd	a3,24(s0)
 ad6:	f018                	sd	a4,32(s0)
 ad8:	f41c                	sd	a5,40(s0)
 ada:	03043823          	sd	a6,48(s0)
 ade:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 ae2:	00840613          	addi	a2,s0,8
 ae6:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 aea:	85aa                	mv	a1,a0
 aec:	4505                	li	a0,1
 aee:	00000097          	auipc	ra,0x0
 af2:	de0080e7          	jalr	-544(ra) # 8ce <vprintf>
}
 af6:	60e2                	ld	ra,24(sp)
 af8:	6442                	ld	s0,16(sp)
 afa:	6125                	addi	sp,sp,96
 afc:	8082                	ret

0000000000000afe <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 afe:	1141                	addi	sp,sp,-16
 b00:	e422                	sd	s0,8(sp)
 b02:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 b04:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 b08:	00001797          	auipc	a5,0x1
 b0c:	4f87b783          	ld	a5,1272(a5) # 2000 <freep>
 b10:	a02d                	j	b3a <free+0x3c>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
 b12:	4618                	lw	a4,8(a2)
 b14:	9f2d                	addw	a4,a4,a1
 b16:	fee52c23          	sw	a4,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 b1a:	6398                	ld	a4,0(a5)
 b1c:	6310                	ld	a2,0(a4)
 b1e:	a83d                	j	b5c <free+0x5e>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
 b20:	ff852703          	lw	a4,-8(a0)
 b24:	9f31                	addw	a4,a4,a2
 b26:	c798                	sw	a4,8(a5)
    p->s.ptr = bp->s.ptr;
 b28:	ff053683          	ld	a3,-16(a0)
 b2c:	a091                	j	b70 <free+0x72>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 b2e:	6398                	ld	a4,0(a5)
 b30:	00e7e463          	bltu	a5,a4,b38 <free+0x3a>
 b34:	00e6ea63          	bltu	a3,a4,b48 <free+0x4a>
{
 b38:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 b3a:	fed7fae3          	bgeu	a5,a3,b2e <free+0x30>
 b3e:	6398                	ld	a4,0(a5)
 b40:	00e6e463          	bltu	a3,a4,b48 <free+0x4a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 b44:	fee7eae3          	bltu	a5,a4,b38 <free+0x3a>
  if(bp + bp->s.size == p->s.ptr){
 b48:	ff852583          	lw	a1,-8(a0)
 b4c:	6390                	ld	a2,0(a5)
 b4e:	02059813          	slli	a6,a1,0x20
 b52:	01c85713          	srli	a4,a6,0x1c
 b56:	9736                	add	a4,a4,a3
 b58:	fae60de3          	beq	a2,a4,b12 <free+0x14>
    bp->s.ptr = p->s.ptr->s.ptr;
 b5c:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
 b60:	4790                	lw	a2,8(a5)
 b62:	02061593          	slli	a1,a2,0x20
 b66:	01c5d713          	srli	a4,a1,0x1c
 b6a:	973e                	add	a4,a4,a5
 b6c:	fae68ae3          	beq	a3,a4,b20 <free+0x22>
    p->s.ptr = bp->s.ptr;
 b70:	e394                	sd	a3,0(a5)
  } else
    p->s.ptr = bp;
  freep = p;
 b72:	00001717          	auipc	a4,0x1
 b76:	48f73723          	sd	a5,1166(a4) # 2000 <freep>
}
 b7a:	6422                	ld	s0,8(sp)
 b7c:	0141                	addi	sp,sp,16
 b7e:	8082                	ret

0000000000000b80 <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 b80:	7139                	addi	sp,sp,-64
 b82:	fc06                	sd	ra,56(sp)
 b84:	f822                	sd	s0,48(sp)
 b86:	f426                	sd	s1,40(sp)
 b88:	f04a                	sd	s2,32(sp)
 b8a:	ec4e                	sd	s3,24(sp)
 b8c:	e852                	sd	s4,16(sp)
 b8e:	e456                	sd	s5,8(sp)
 b90:	e05a                	sd	s6,0(sp)
 b92:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 b94:	02051493          	slli	s1,a0,0x20
 b98:	9081                	srli	s1,s1,0x20
 b9a:	04bd                	addi	s1,s1,15
 b9c:	8091                	srli	s1,s1,0x4
 b9e:	0014899b          	addiw	s3,s1,1
 ba2:	0485                	addi	s1,s1,1
  if((prevp = freep) == 0){
 ba4:	00001517          	auipc	a0,0x1
 ba8:	45c53503          	ld	a0,1116(a0) # 2000 <freep>
 bac:	c515                	beqz	a0,bd8 <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 bae:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 bb0:	4798                	lw	a4,8(a5)
 bb2:	02977f63          	bgeu	a4,s1,bf0 <malloc+0x70>
  if(nu < 4096)
 bb6:	8a4e                	mv	s4,s3
 bb8:	0009871b          	sext.w	a4,s3
 bbc:	6685                	lui	a3,0x1
 bbe:	00d77363          	bgeu	a4,a3,bc4 <malloc+0x44>
 bc2:	6a05                	lui	s4,0x1
 bc4:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 bc8:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 bcc:	00001917          	auipc	s2,0x1
 bd0:	43490913          	addi	s2,s2,1076 # 2000 <freep>
  if(p == (char*)-1)
 bd4:	5afd                	li	s5,-1
 bd6:	a895                	j	c4a <malloc+0xca>
    base.s.ptr = freep = prevp = &base;
 bd8:	00001797          	auipc	a5,0x1
 bdc:	43878793          	addi	a5,a5,1080 # 2010 <base>
 be0:	00001717          	auipc	a4,0x1
 be4:	42f73023          	sd	a5,1056(a4) # 2000 <freep>
 be8:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 bea:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 bee:	b7e1                	j	bb6 <malloc+0x36>
      if(p->s.size == nunits)
 bf0:	02e48c63          	beq	s1,a4,c28 <malloc+0xa8>
        p->s.size -= nunits;
 bf4:	4137073b          	subw	a4,a4,s3
 bf8:	c798                	sw	a4,8(a5)
        p += p->s.size;
 bfa:	02071693          	slli	a3,a4,0x20
 bfe:	01c6d713          	srli	a4,a3,0x1c
 c02:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 c04:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 c08:	00001717          	auipc	a4,0x1
 c0c:	3ea73c23          	sd	a0,1016(a4) # 2000 <freep>
      return (void*)(p + 1);
 c10:	01078513          	addi	a0,a5,16
      if((p = morecore(nunits)) == 0)
        return 0;
  }
}
 c14:	70e2                	ld	ra,56(sp)
 c16:	7442                	ld	s0,48(sp)
 c18:	74a2                	ld	s1,40(sp)
 c1a:	7902                	ld	s2,32(sp)
 c1c:	69e2                	ld	s3,24(sp)
 c1e:	6a42                	ld	s4,16(sp)
 c20:	6aa2                	ld	s5,8(sp)
 c22:	6b02                	ld	s6,0(sp)
 c24:	6121                	addi	sp,sp,64
 c26:	8082                	ret
        prevp->s.ptr = p->s.ptr;
 c28:	6398                	ld	a4,0(a5)
 c2a:	e118                	sd	a4,0(a0)
 c2c:	bff1                	j	c08 <malloc+0x88>
  hp->s.size = nu;
 c2e:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
 c32:	0541                	addi	a0,a0,16
 c34:	00000097          	auipc	ra,0x0
 c38:	eca080e7          	jalr	-310(ra) # afe <free>
  return freep;
 c3c:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
 c40:	d971                	beqz	a0,c14 <malloc+0x94>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 c42:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 c44:	4798                	lw	a4,8(a5)
 c46:	fa9775e3          	bgeu	a4,s1,bf0 <malloc+0x70>
    if(p == freep)
 c4a:	00093703          	ld	a4,0(s2)
 c4e:	853e                	mv	a0,a5
 c50:	fef719e3          	bne	a4,a5,c42 <malloc+0xc2>
  p = sbrk(nu * sizeof(Header));
 c54:	8552                	mv	a0,s4
 c56:	00000097          	auipc	ra,0x0
 c5a:	b8a080e7          	jalr	-1142(ra) # 7e0 <sbrk>
  if(p == (char*)-1)
 c5e:	fd5518e3          	bne	a0,s5,c2e <malloc+0xae>
        return 0;
 c62:	4501                	li	a0,0
 c64:	bf45                	j	c14 <malloc+0x94>

0000000000000c66 <dump_test2_asm>:
#include "kernel/syscall.h"
.globl dump_test2_asm
dump_test2_asm:
  li s2, 2
 c66:	4909                	li	s2,2
  li s3, 3
 c68:	498d                	li	s3,3
  li s4, 4
 c6a:	4a11                	li	s4,4
  li s5, 5
 c6c:	4a95                	li	s5,5
  li s6, 6
 c6e:	4b19                	li	s6,6
  li s7, 7
 c70:	4b9d                	li	s7,7
  li s8, 8
 c72:	4c21                	li	s8,8
  li s9, 9
 c74:	4ca5                	li	s9,9
  li s10, 10
 c76:	4d29                	li	s10,10
  li s11, 11
 c78:	4dad                	li	s11,11
#ifdef SYS_dump
  li a7, SYS_dump
 c7a:	48d9                	li	a7,22
  ecall
 c7c:	00000073          	ecall
#endif
  ret
 c80:	8082                	ret

0000000000000c82 <dump_test3_asm>:
.globl dump_test3_asm
dump_test3_asm:
  li s2, 1
 c82:	4905                	li	s2,1
  li s3, -12
 c84:	59d1                	li	s3,-12
  li s4, 123
 c86:	07b00a13          	li	s4,123
  li s5, -1234
 c8a:	b2e00a93          	li	s5,-1234
  li s6, 12345
 c8e:	6b0d                	lui	s6,0x3
 c90:	039b0b1b          	addiw	s6,s6,57 # 3039 <base+0x1029>
  li s7, -123456
 c94:	7b89                	lui	s7,0xfffe2
 c96:	dc0b8b9b          	addiw	s7,s7,-576 # fffffffffffe1dc0 <base+0xfffffffffffdfdb0>
  li s8, 1234567
 c9a:	0012dc37          	lui	s8,0x12d
 c9e:	687c0c1b          	addiw	s8,s8,1671 # 12d687 <base+0x12b677>
  li s9, -12345678
 ca2:	ff43acb7          	lui	s9,0xff43a
 ca6:	eb2c8c9b          	addiw	s9,s9,-334 # ffffffffff439eb2 <base+0xffffffffff437ea2>
  li s10, 123456789
 caa:	075bdd37          	lui	s10,0x75bd
 cae:	d15d0d1b          	addiw	s10,s10,-747 # 75bcd15 <base+0x75bad05>
  li s11, -1234567890
 cb2:	b66a0db7          	lui	s11,0xb66a0
 cb6:	d2ed8d9b          	addiw	s11,s11,-722 # ffffffffb669fd2e <base+0xffffffffb669dd1e>
#ifdef SYS_dump
  li a7, SYS_dump
 cba:	48d9                	li	a7,22
  ecall
 cbc:	00000073          	ecall
#endif
  ret
 cc0:	8082                	ret

0000000000000cc2 <dump_test4_asm>:
.globl dump_test4_asm
dump_test4_asm:
  li s2, 2147483647
 cc2:	80000937          	lui	s2,0x80000
 cc6:	397d                	addiw	s2,s2,-1 # 7fffffff <base+0x7fffdfef>
  li s3, -2147483648
 cc8:	800009b7          	lui	s3,0x80000
  li s4, 1337
 ccc:	53900a13          	li	s4,1337
  li s5, 2020
 cd0:	7e400a93          	li	s5,2020
  li s6, 3234
 cd4:	6b05                	lui	s6,0x1
 cd6:	ca2b0b1b          	addiw	s6,s6,-862 # ca2 <dump_test3_asm+0x20>
  li s7, 3235
 cda:	6b85                	lui	s7,0x1
 cdc:	ca3b8b9b          	addiw	s7,s7,-861 # ca3 <dump_test3_asm+0x21>
  li s8, 3236
 ce0:	6c05                	lui	s8,0x1
 ce2:	ca4c0c1b          	addiw	s8,s8,-860 # ca4 <dump_test3_asm+0x22>
  li s9, 3237
 ce6:	6c85                	lui	s9,0x1
 ce8:	ca5c8c9b          	addiw	s9,s9,-859 # ca5 <dump_test3_asm+0x23>
  li s10, 3238
 cec:	6d05                	lui	s10,0x1
 cee:	ca6d0d1b          	addiw	s10,s10,-858 # ca6 <dump_test3_asm+0x24>
  li s11, 3239
 cf2:	6d85                	lui	s11,0x1
 cf4:	ca7d8d9b          	addiw	s11,s11,-857 # ca7 <dump_test3_asm+0x25>
#ifdef SYS_dump
  li a7, SYS_dump
 cf8:	48d9                	li	a7,22
  ecall
 cfa:	00000073          	ecall
#endif
  ret
 cfe:	8082                	ret
