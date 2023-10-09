
kernel/kernel:     file format elf64-littleriscv


Disassembly of section .text:

0000000080000000 <_entry>:
    80000000:	00009117          	auipc	sp,0x9
    80000004:	a2010113          	addi	sp,sp,-1504 # 80008a20 <stack0>
    80000008:	6505                	lui	a0,0x1
    8000000a:	f14025f3          	csrr	a1,mhartid
    8000000e:	0585                	addi	a1,a1,1
    80000010:	02b50533          	mul	a0,a0,a1
    80000014:	912a                	add	sp,sp,a0
    80000016:	076000ef          	jal	ra,8000008c <start>

000000008000001a <spin>:
    8000001a:	a001                	j	8000001a <spin>

000000008000001c <timerinit>:
// at timervec in kernelvec.S,
// which turns them into software interrupts for
// devintr() in trap.c.
void
timerinit()
{
    8000001c:	1141                	addi	sp,sp,-16
    8000001e:	e422                	sd	s0,8(sp)
    80000020:	0800                	addi	s0,sp,16
// which hart (core) is this?
static inline uint64
r_mhartid()
{
  uint64 x;
  asm volatile("csrr %0, mhartid" : "=r" (x) );
    80000022:	f14027f3          	csrr	a5,mhartid
  // each CPU has a separate source of timer interrupts.
  int id = r_mhartid();
    80000026:	0007859b          	sext.w	a1,a5

  // ask the CLINT for a timer interrupt.
  int interval = 1000000; // cycles; about 1/10th second in qemu.
  *(uint64*)CLINT_MTIMECMP(id) = *(uint64*)CLINT_MTIME + interval;
    8000002a:	0037979b          	slliw	a5,a5,0x3
    8000002e:	02004737          	lui	a4,0x2004
    80000032:	97ba                	add	a5,a5,a4
    80000034:	0200c737          	lui	a4,0x200c
    80000038:	ff873703          	ld	a4,-8(a4) # 200bff8 <_entry-0x7dff4008>
    8000003c:	000f4637          	lui	a2,0xf4
    80000040:	24060613          	addi	a2,a2,576 # f4240 <_entry-0x7ff0bdc0>
    80000044:	9732                	add	a4,a4,a2
    80000046:	e398                	sd	a4,0(a5)

  // prepare information in scratch[] for timervec.
  // scratch[0..2] : space for timervec to save registers.
  // scratch[3] : address of CLINT MTIMECMP register.
  // scratch[4] : desired interval (in cycles) between timer interrupts.
  uint64 *scratch = &timer_scratch[id][0];
    80000048:	00259693          	slli	a3,a1,0x2
    8000004c:	96ae                	add	a3,a3,a1
    8000004e:	068e                	slli	a3,a3,0x3
    80000050:	00009717          	auipc	a4,0x9
    80000054:	89070713          	addi	a4,a4,-1904 # 800088e0 <timer_scratch>
    80000058:	9736                	add	a4,a4,a3
  scratch[3] = CLINT_MTIMECMP(id);
    8000005a:	ef1c                	sd	a5,24(a4)
  scratch[4] = interval;
    8000005c:	f310                	sd	a2,32(a4)
}

static inline void 
w_mscratch(uint64 x)
{
  asm volatile("csrw mscratch, %0" : : "r" (x));
    8000005e:	34071073          	csrw	mscratch,a4
  asm volatile("csrw mtvec, %0" : : "r" (x));
    80000062:	00006797          	auipc	a5,0x6
    80000066:	b3e78793          	addi	a5,a5,-1218 # 80005ba0 <timervec>
    8000006a:	30579073          	csrw	mtvec,a5
  asm volatile("csrr %0, mstatus" : "=r" (x) );
    8000006e:	300027f3          	csrr	a5,mstatus

  // set the machine-mode trap handler.
  w_mtvec((uint64)timervec);

  // enable machine-mode interrupts.
  w_mstatus(r_mstatus() | MSTATUS_MIE);
    80000072:	0087e793          	ori	a5,a5,8
  asm volatile("csrw mstatus, %0" : : "r" (x));
    80000076:	30079073          	csrw	mstatus,a5
  asm volatile("csrr %0, mie" : "=r" (x) );
    8000007a:	304027f3          	csrr	a5,mie

  // enable machine-mode timer interrupts.
  w_mie(r_mie() | MIE_MTIE);
    8000007e:	0807e793          	ori	a5,a5,128
  asm volatile("csrw mie, %0" : : "r" (x));
    80000082:	30479073          	csrw	mie,a5
}
    80000086:	6422                	ld	s0,8(sp)
    80000088:	0141                	addi	sp,sp,16
    8000008a:	8082                	ret

000000008000008c <start>:
{
    8000008c:	1141                	addi	sp,sp,-16
    8000008e:	e406                	sd	ra,8(sp)
    80000090:	e022                	sd	s0,0(sp)
    80000092:	0800                	addi	s0,sp,16
  asm volatile("csrr %0, mstatus" : "=r" (x) );
    80000094:	300027f3          	csrr	a5,mstatus
  x &= ~MSTATUS_MPP_MASK;
    80000098:	7779                	lui	a4,0xffffe
    8000009a:	7ff70713          	addi	a4,a4,2047 # ffffffffffffe7ff <end+0xffffffff7ffdcaaf>
    8000009e:	8ff9                	and	a5,a5,a4
  x |= MSTATUS_MPP_S;
    800000a0:	6705                	lui	a4,0x1
    800000a2:	80070713          	addi	a4,a4,-2048 # 800 <_entry-0x7ffff800>
    800000a6:	8fd9                	or	a5,a5,a4
  asm volatile("csrw mstatus, %0" : : "r" (x));
    800000a8:	30079073          	csrw	mstatus,a5
  asm volatile("csrw mepc, %0" : : "r" (x));
    800000ac:	00001797          	auipc	a5,0x1
    800000b0:	dc678793          	addi	a5,a5,-570 # 80000e72 <main>
    800000b4:	34179073          	csrw	mepc,a5
  asm volatile("csrw satp, %0" : : "r" (x));
    800000b8:	4781                	li	a5,0
    800000ba:	18079073          	csrw	satp,a5
  asm volatile("csrw medeleg, %0" : : "r" (x));
    800000be:	67c1                	lui	a5,0x10
    800000c0:	17fd                	addi	a5,a5,-1 # ffff <_entry-0x7fff0001>
    800000c2:	30279073          	csrw	medeleg,a5
  asm volatile("csrw mideleg, %0" : : "r" (x));
    800000c6:	30379073          	csrw	mideleg,a5
  asm volatile("csrr %0, sie" : "=r" (x) );
    800000ca:	104027f3          	csrr	a5,sie
  w_sie(r_sie() | SIE_SEIE | SIE_STIE | SIE_SSIE);
    800000ce:	2227e793          	ori	a5,a5,546
  asm volatile("csrw sie, %0" : : "r" (x));
    800000d2:	10479073          	csrw	sie,a5
  asm volatile("csrw pmpaddr0, %0" : : "r" (x));
    800000d6:	57fd                	li	a5,-1
    800000d8:	83a9                	srli	a5,a5,0xa
    800000da:	3b079073          	csrw	pmpaddr0,a5
  asm volatile("csrw pmpcfg0, %0" : : "r" (x));
    800000de:	47bd                	li	a5,15
    800000e0:	3a079073          	csrw	pmpcfg0,a5
  timerinit();
    800000e4:	00000097          	auipc	ra,0x0
    800000e8:	f38080e7          	jalr	-200(ra) # 8000001c <timerinit>
  asm volatile("csrr %0, mhartid" : "=r" (x) );
    800000ec:	f14027f3          	csrr	a5,mhartid
  w_tp(id);
    800000f0:	2781                	sext.w	a5,a5
}

static inline void 
w_tp(uint64 x)
{
  asm volatile("mv tp, %0" : : "r" (x));
    800000f2:	823e                	mv	tp,a5
  asm volatile("mret");
    800000f4:	30200073          	mret
}
    800000f8:	60a2                	ld	ra,8(sp)
    800000fa:	6402                	ld	s0,0(sp)
    800000fc:	0141                	addi	sp,sp,16
    800000fe:	8082                	ret

0000000080000100 <consolewrite>:
//
// user write()s to the console go here.
//
int
consolewrite(int user_src, uint64 src, int n)
{
    80000100:	715d                	addi	sp,sp,-80
    80000102:	e486                	sd	ra,72(sp)
    80000104:	e0a2                	sd	s0,64(sp)
    80000106:	fc26                	sd	s1,56(sp)
    80000108:	f84a                	sd	s2,48(sp)
    8000010a:	f44e                	sd	s3,40(sp)
    8000010c:	f052                	sd	s4,32(sp)
    8000010e:	ec56                	sd	s5,24(sp)
    80000110:	0880                	addi	s0,sp,80
  int i;

  for(i = 0; i < n; i++){
    80000112:	04c05763          	blez	a2,80000160 <consolewrite+0x60>
    80000116:	8a2a                	mv	s4,a0
    80000118:	84ae                	mv	s1,a1
    8000011a:	89b2                	mv	s3,a2
    8000011c:	4901                	li	s2,0
    char c;
    if(either_copyin(&c, user_src, src+i, 1) == -1)
    8000011e:	5afd                	li	s5,-1
    80000120:	4685                	li	a3,1
    80000122:	8626                	mv	a2,s1
    80000124:	85d2                	mv	a1,s4
    80000126:	fbf40513          	addi	a0,s0,-65
    8000012a:	00002097          	auipc	ra,0x2
    8000012e:	3ce080e7          	jalr	974(ra) # 800024f8 <either_copyin>
    80000132:	01550d63          	beq	a0,s5,8000014c <consolewrite+0x4c>
      break;
    uartputc(c);
    80000136:	fbf44503          	lbu	a0,-65(s0)
    8000013a:	00000097          	auipc	ra,0x0
    8000013e:	780080e7          	jalr	1920(ra) # 800008ba <uartputc>
  for(i = 0; i < n; i++){
    80000142:	2905                	addiw	s2,s2,1
    80000144:	0485                	addi	s1,s1,1
    80000146:	fd299de3          	bne	s3,s2,80000120 <consolewrite+0x20>
    8000014a:	894e                	mv	s2,s3
  }

  return i;
}
    8000014c:	854a                	mv	a0,s2
    8000014e:	60a6                	ld	ra,72(sp)
    80000150:	6406                	ld	s0,64(sp)
    80000152:	74e2                	ld	s1,56(sp)
    80000154:	7942                	ld	s2,48(sp)
    80000156:	79a2                	ld	s3,40(sp)
    80000158:	7a02                	ld	s4,32(sp)
    8000015a:	6ae2                	ld	s5,24(sp)
    8000015c:	6161                	addi	sp,sp,80
    8000015e:	8082                	ret
  for(i = 0; i < n; i++){
    80000160:	4901                	li	s2,0
    80000162:	b7ed                	j	8000014c <consolewrite+0x4c>

0000000080000164 <consoleread>:
// user_dist indicates whether dst is a user
// or kernel address.
//
int
consoleread(int user_dst, uint64 dst, int n)
{
    80000164:	711d                	addi	sp,sp,-96
    80000166:	ec86                	sd	ra,88(sp)
    80000168:	e8a2                	sd	s0,80(sp)
    8000016a:	e4a6                	sd	s1,72(sp)
    8000016c:	e0ca                	sd	s2,64(sp)
    8000016e:	fc4e                	sd	s3,56(sp)
    80000170:	f852                	sd	s4,48(sp)
    80000172:	f456                	sd	s5,40(sp)
    80000174:	f05a                	sd	s6,32(sp)
    80000176:	ec5e                	sd	s7,24(sp)
    80000178:	1080                	addi	s0,sp,96
    8000017a:	8aaa                	mv	s5,a0
    8000017c:	8a2e                	mv	s4,a1
    8000017e:	89b2                	mv	s3,a2
  uint target;
  int c;
  char cbuf;

  target = n;
    80000180:	00060b1b          	sext.w	s6,a2
  acquire(&cons.lock);
    80000184:	00011517          	auipc	a0,0x11
    80000188:	89c50513          	addi	a0,a0,-1892 # 80010a20 <cons>
    8000018c:	00001097          	auipc	ra,0x1
    80000190:	a46080e7          	jalr	-1466(ra) # 80000bd2 <acquire>
  while(n > 0){
    // wait until interrupt handler has put some
    // input into cons.buffer.
    while(cons.r == cons.w){
    80000194:	00011497          	auipc	s1,0x11
    80000198:	88c48493          	addi	s1,s1,-1908 # 80010a20 <cons>
      if(killed(myproc())){
        release(&cons.lock);
        return -1;
      }
      sleep(&cons.r, &cons.lock);
    8000019c:	00011917          	auipc	s2,0x11
    800001a0:	91c90913          	addi	s2,s2,-1764 # 80010ab8 <cons+0x98>
  while(n > 0){
    800001a4:	09305263          	blez	s3,80000228 <consoleread+0xc4>
    while(cons.r == cons.w){
    800001a8:	0984a783          	lw	a5,152(s1)
    800001ac:	09c4a703          	lw	a4,156(s1)
    800001b0:	02f71763          	bne	a4,a5,800001de <consoleread+0x7a>
      if(killed(myproc())){
    800001b4:	00001097          	auipc	ra,0x1
    800001b8:	7f2080e7          	jalr	2034(ra) # 800019a6 <myproc>
    800001bc:	00002097          	auipc	ra,0x2
    800001c0:	186080e7          	jalr	390(ra) # 80002342 <killed>
    800001c4:	ed2d                	bnez	a0,8000023e <consoleread+0xda>
      sleep(&cons.r, &cons.lock);
    800001c6:	85a6                	mv	a1,s1
    800001c8:	854a                	mv	a0,s2
    800001ca:	00002097          	auipc	ra,0x2
    800001ce:	ed0080e7          	jalr	-304(ra) # 8000209a <sleep>
    while(cons.r == cons.w){
    800001d2:	0984a783          	lw	a5,152(s1)
    800001d6:	09c4a703          	lw	a4,156(s1)
    800001da:	fcf70de3          	beq	a4,a5,800001b4 <consoleread+0x50>
    }

    c = cons.buf[cons.r++ % INPUT_BUF_SIZE];
    800001de:	00011717          	auipc	a4,0x11
    800001e2:	84270713          	addi	a4,a4,-1982 # 80010a20 <cons>
    800001e6:	0017869b          	addiw	a3,a5,1
    800001ea:	08d72c23          	sw	a3,152(a4)
    800001ee:	07f7f693          	andi	a3,a5,127
    800001f2:	9736                	add	a4,a4,a3
    800001f4:	01874703          	lbu	a4,24(a4)
    800001f8:	00070b9b          	sext.w	s7,a4

    if(c == C('D')){  // end-of-file
    800001fc:	4691                	li	a3,4
    800001fe:	06db8463          	beq	s7,a3,80000266 <consoleread+0x102>
      }
      break;
    }

    // copy the input byte to the user-space buffer.
    cbuf = c;
    80000202:	fae407a3          	sb	a4,-81(s0)
    if(either_copyout(user_dst, dst, &cbuf, 1) == -1)
    80000206:	4685                	li	a3,1
    80000208:	faf40613          	addi	a2,s0,-81
    8000020c:	85d2                	mv	a1,s4
    8000020e:	8556                	mv	a0,s5
    80000210:	00002097          	auipc	ra,0x2
    80000214:	292080e7          	jalr	658(ra) # 800024a2 <either_copyout>
    80000218:	57fd                	li	a5,-1
    8000021a:	00f50763          	beq	a0,a5,80000228 <consoleread+0xc4>
      break;

    dst++;
    8000021e:	0a05                	addi	s4,s4,1
    --n;
    80000220:	39fd                	addiw	s3,s3,-1

    if(c == '\n'){
    80000222:	47a9                	li	a5,10
    80000224:	f8fb90e3          	bne	s7,a5,800001a4 <consoleread+0x40>
      // a whole line has arrived, return to
      // the user-level read().
      break;
    }
  }
  release(&cons.lock);
    80000228:	00010517          	auipc	a0,0x10
    8000022c:	7f850513          	addi	a0,a0,2040 # 80010a20 <cons>
    80000230:	00001097          	auipc	ra,0x1
    80000234:	a56080e7          	jalr	-1450(ra) # 80000c86 <release>

  return target - n;
    80000238:	413b053b          	subw	a0,s6,s3
    8000023c:	a811                	j	80000250 <consoleread+0xec>
        release(&cons.lock);
    8000023e:	00010517          	auipc	a0,0x10
    80000242:	7e250513          	addi	a0,a0,2018 # 80010a20 <cons>
    80000246:	00001097          	auipc	ra,0x1
    8000024a:	a40080e7          	jalr	-1472(ra) # 80000c86 <release>
        return -1;
    8000024e:	557d                	li	a0,-1
}
    80000250:	60e6                	ld	ra,88(sp)
    80000252:	6446                	ld	s0,80(sp)
    80000254:	64a6                	ld	s1,72(sp)
    80000256:	6906                	ld	s2,64(sp)
    80000258:	79e2                	ld	s3,56(sp)
    8000025a:	7a42                	ld	s4,48(sp)
    8000025c:	7aa2                	ld	s5,40(sp)
    8000025e:	7b02                	ld	s6,32(sp)
    80000260:	6be2                	ld	s7,24(sp)
    80000262:	6125                	addi	sp,sp,96
    80000264:	8082                	ret
      if(n < target){
    80000266:	0009871b          	sext.w	a4,s3
    8000026a:	fb677fe3          	bgeu	a4,s6,80000228 <consoleread+0xc4>
        cons.r--;
    8000026e:	00011717          	auipc	a4,0x11
    80000272:	84f72523          	sw	a5,-1974(a4) # 80010ab8 <cons+0x98>
    80000276:	bf4d                	j	80000228 <consoleread+0xc4>

0000000080000278 <consputc>:
{
    80000278:	1141                	addi	sp,sp,-16
    8000027a:	e406                	sd	ra,8(sp)
    8000027c:	e022                	sd	s0,0(sp)
    8000027e:	0800                	addi	s0,sp,16
  if(c == BACKSPACE){
    80000280:	10000793          	li	a5,256
    80000284:	00f50a63          	beq	a0,a5,80000298 <consputc+0x20>
    uartputc_sync(c);
    80000288:	00000097          	auipc	ra,0x0
    8000028c:	560080e7          	jalr	1376(ra) # 800007e8 <uartputc_sync>
}
    80000290:	60a2                	ld	ra,8(sp)
    80000292:	6402                	ld	s0,0(sp)
    80000294:	0141                	addi	sp,sp,16
    80000296:	8082                	ret
    uartputc_sync('\b'); uartputc_sync(' '); uartputc_sync('\b');
    80000298:	4521                	li	a0,8
    8000029a:	00000097          	auipc	ra,0x0
    8000029e:	54e080e7          	jalr	1358(ra) # 800007e8 <uartputc_sync>
    800002a2:	02000513          	li	a0,32
    800002a6:	00000097          	auipc	ra,0x0
    800002aa:	542080e7          	jalr	1346(ra) # 800007e8 <uartputc_sync>
    800002ae:	4521                	li	a0,8
    800002b0:	00000097          	auipc	ra,0x0
    800002b4:	538080e7          	jalr	1336(ra) # 800007e8 <uartputc_sync>
    800002b8:	bfe1                	j	80000290 <consputc+0x18>

00000000800002ba <consoleintr>:
// do erase/kill processing, append to cons.buf,
// wake up consoleread() if a whole line has arrived.
//
void
consoleintr(int c)
{
    800002ba:	1101                	addi	sp,sp,-32
    800002bc:	ec06                	sd	ra,24(sp)
    800002be:	e822                	sd	s0,16(sp)
    800002c0:	e426                	sd	s1,8(sp)
    800002c2:	e04a                	sd	s2,0(sp)
    800002c4:	1000                	addi	s0,sp,32
    800002c6:	84aa                	mv	s1,a0
  acquire(&cons.lock);
    800002c8:	00010517          	auipc	a0,0x10
    800002cc:	75850513          	addi	a0,a0,1880 # 80010a20 <cons>
    800002d0:	00001097          	auipc	ra,0x1
    800002d4:	902080e7          	jalr	-1790(ra) # 80000bd2 <acquire>

  switch(c){
    800002d8:	47d5                	li	a5,21
    800002da:	0af48663          	beq	s1,a5,80000386 <consoleintr+0xcc>
    800002de:	0297ca63          	blt	a5,s1,80000312 <consoleintr+0x58>
    800002e2:	47a1                	li	a5,8
    800002e4:	0ef48763          	beq	s1,a5,800003d2 <consoleintr+0x118>
    800002e8:	47c1                	li	a5,16
    800002ea:	10f49a63          	bne	s1,a5,800003fe <consoleintr+0x144>
  case C('P'):  // Print process list.
    procdump();
    800002ee:	00002097          	auipc	ra,0x2
    800002f2:	260080e7          	jalr	608(ra) # 8000254e <procdump>
      }
    }
    break;
  }
  
  release(&cons.lock);
    800002f6:	00010517          	auipc	a0,0x10
    800002fa:	72a50513          	addi	a0,a0,1834 # 80010a20 <cons>
    800002fe:	00001097          	auipc	ra,0x1
    80000302:	988080e7          	jalr	-1656(ra) # 80000c86 <release>
}
    80000306:	60e2                	ld	ra,24(sp)
    80000308:	6442                	ld	s0,16(sp)
    8000030a:	64a2                	ld	s1,8(sp)
    8000030c:	6902                	ld	s2,0(sp)
    8000030e:	6105                	addi	sp,sp,32
    80000310:	8082                	ret
  switch(c){
    80000312:	07f00793          	li	a5,127
    80000316:	0af48e63          	beq	s1,a5,800003d2 <consoleintr+0x118>
    if(c != 0 && cons.e-cons.r < INPUT_BUF_SIZE){
    8000031a:	00010717          	auipc	a4,0x10
    8000031e:	70670713          	addi	a4,a4,1798 # 80010a20 <cons>
    80000322:	0a072783          	lw	a5,160(a4)
    80000326:	09872703          	lw	a4,152(a4)
    8000032a:	9f99                	subw	a5,a5,a4
    8000032c:	07f00713          	li	a4,127
    80000330:	fcf763e3          	bltu	a4,a5,800002f6 <consoleintr+0x3c>
      c = (c == '\r') ? '\n' : c;
    80000334:	47b5                	li	a5,13
    80000336:	0cf48763          	beq	s1,a5,80000404 <consoleintr+0x14a>
      consputc(c);
    8000033a:	8526                	mv	a0,s1
    8000033c:	00000097          	auipc	ra,0x0
    80000340:	f3c080e7          	jalr	-196(ra) # 80000278 <consputc>
      cons.buf[cons.e++ % INPUT_BUF_SIZE] = c;
    80000344:	00010797          	auipc	a5,0x10
    80000348:	6dc78793          	addi	a5,a5,1756 # 80010a20 <cons>
    8000034c:	0a07a683          	lw	a3,160(a5)
    80000350:	0016871b          	addiw	a4,a3,1
    80000354:	0007061b          	sext.w	a2,a4
    80000358:	0ae7a023          	sw	a4,160(a5)
    8000035c:	07f6f693          	andi	a3,a3,127
    80000360:	97b6                	add	a5,a5,a3
    80000362:	00978c23          	sb	s1,24(a5)
      if(c == '\n' || c == C('D') || cons.e-cons.r == INPUT_BUF_SIZE){
    80000366:	47a9                	li	a5,10
    80000368:	0cf48563          	beq	s1,a5,80000432 <consoleintr+0x178>
    8000036c:	4791                	li	a5,4
    8000036e:	0cf48263          	beq	s1,a5,80000432 <consoleintr+0x178>
    80000372:	00010797          	auipc	a5,0x10
    80000376:	7467a783          	lw	a5,1862(a5) # 80010ab8 <cons+0x98>
    8000037a:	9f1d                	subw	a4,a4,a5
    8000037c:	08000793          	li	a5,128
    80000380:	f6f71be3          	bne	a4,a5,800002f6 <consoleintr+0x3c>
    80000384:	a07d                	j	80000432 <consoleintr+0x178>
    while(cons.e != cons.w &&
    80000386:	00010717          	auipc	a4,0x10
    8000038a:	69a70713          	addi	a4,a4,1690 # 80010a20 <cons>
    8000038e:	0a072783          	lw	a5,160(a4)
    80000392:	09c72703          	lw	a4,156(a4)
          cons.buf[(cons.e-1) % INPUT_BUF_SIZE] != '\n'){
    80000396:	00010497          	auipc	s1,0x10
    8000039a:	68a48493          	addi	s1,s1,1674 # 80010a20 <cons>
    while(cons.e != cons.w &&
    8000039e:	4929                	li	s2,10
    800003a0:	f4f70be3          	beq	a4,a5,800002f6 <consoleintr+0x3c>
          cons.buf[(cons.e-1) % INPUT_BUF_SIZE] != '\n'){
    800003a4:	37fd                	addiw	a5,a5,-1
    800003a6:	07f7f713          	andi	a4,a5,127
    800003aa:	9726                	add	a4,a4,s1
    while(cons.e != cons.w &&
    800003ac:	01874703          	lbu	a4,24(a4)
    800003b0:	f52703e3          	beq	a4,s2,800002f6 <consoleintr+0x3c>
      cons.e--;
    800003b4:	0af4a023          	sw	a5,160(s1)
      consputc(BACKSPACE);
    800003b8:	10000513          	li	a0,256
    800003bc:	00000097          	auipc	ra,0x0
    800003c0:	ebc080e7          	jalr	-324(ra) # 80000278 <consputc>
    while(cons.e != cons.w &&
    800003c4:	0a04a783          	lw	a5,160(s1)
    800003c8:	09c4a703          	lw	a4,156(s1)
    800003cc:	fcf71ce3          	bne	a4,a5,800003a4 <consoleintr+0xea>
    800003d0:	b71d                	j	800002f6 <consoleintr+0x3c>
    if(cons.e != cons.w){
    800003d2:	00010717          	auipc	a4,0x10
    800003d6:	64e70713          	addi	a4,a4,1614 # 80010a20 <cons>
    800003da:	0a072783          	lw	a5,160(a4)
    800003de:	09c72703          	lw	a4,156(a4)
    800003e2:	f0f70ae3          	beq	a4,a5,800002f6 <consoleintr+0x3c>
      cons.e--;
    800003e6:	37fd                	addiw	a5,a5,-1
    800003e8:	00010717          	auipc	a4,0x10
    800003ec:	6cf72c23          	sw	a5,1752(a4) # 80010ac0 <cons+0xa0>
      consputc(BACKSPACE);
    800003f0:	10000513          	li	a0,256
    800003f4:	00000097          	auipc	ra,0x0
    800003f8:	e84080e7          	jalr	-380(ra) # 80000278 <consputc>
    800003fc:	bded                	j	800002f6 <consoleintr+0x3c>
    if(c != 0 && cons.e-cons.r < INPUT_BUF_SIZE){
    800003fe:	ee048ce3          	beqz	s1,800002f6 <consoleintr+0x3c>
    80000402:	bf21                	j	8000031a <consoleintr+0x60>
      consputc(c);
    80000404:	4529                	li	a0,10
    80000406:	00000097          	auipc	ra,0x0
    8000040a:	e72080e7          	jalr	-398(ra) # 80000278 <consputc>
      cons.buf[cons.e++ % INPUT_BUF_SIZE] = c;
    8000040e:	00010797          	auipc	a5,0x10
    80000412:	61278793          	addi	a5,a5,1554 # 80010a20 <cons>
    80000416:	0a07a703          	lw	a4,160(a5)
    8000041a:	0017069b          	addiw	a3,a4,1
    8000041e:	0006861b          	sext.w	a2,a3
    80000422:	0ad7a023          	sw	a3,160(a5)
    80000426:	07f77713          	andi	a4,a4,127
    8000042a:	97ba                	add	a5,a5,a4
    8000042c:	4729                	li	a4,10
    8000042e:	00e78c23          	sb	a4,24(a5)
        cons.w = cons.e;
    80000432:	00010797          	auipc	a5,0x10
    80000436:	68c7a523          	sw	a2,1674(a5) # 80010abc <cons+0x9c>
        wakeup(&cons.r);
    8000043a:	00010517          	auipc	a0,0x10
    8000043e:	67e50513          	addi	a0,a0,1662 # 80010ab8 <cons+0x98>
    80000442:	00002097          	auipc	ra,0x2
    80000446:	cbc080e7          	jalr	-836(ra) # 800020fe <wakeup>
    8000044a:	b575                	j	800002f6 <consoleintr+0x3c>

000000008000044c <consoleinit>:

void
consoleinit(void)
{
    8000044c:	1141                	addi	sp,sp,-16
    8000044e:	e406                	sd	ra,8(sp)
    80000450:	e022                	sd	s0,0(sp)
    80000452:	0800                	addi	s0,sp,16
  initlock(&cons.lock, "cons");
    80000454:	00008597          	auipc	a1,0x8
    80000458:	bbc58593          	addi	a1,a1,-1092 # 80008010 <etext+0x10>
    8000045c:	00010517          	auipc	a0,0x10
    80000460:	5c450513          	addi	a0,a0,1476 # 80010a20 <cons>
    80000464:	00000097          	auipc	ra,0x0
    80000468:	6de080e7          	jalr	1758(ra) # 80000b42 <initlock>

  uartinit();
    8000046c:	00000097          	auipc	ra,0x0
    80000470:	32c080e7          	jalr	812(ra) # 80000798 <uartinit>

  // connect read and write system calls
  // to consoleread and consolewrite.
  devsw[CONSOLE].read = consoleread;
    80000474:	00020797          	auipc	a5,0x20
    80000478:	74478793          	addi	a5,a5,1860 # 80020bb8 <devsw>
    8000047c:	00000717          	auipc	a4,0x0
    80000480:	ce870713          	addi	a4,a4,-792 # 80000164 <consoleread>
    80000484:	eb98                	sd	a4,16(a5)
  devsw[CONSOLE].write = consolewrite;
    80000486:	00000717          	auipc	a4,0x0
    8000048a:	c7a70713          	addi	a4,a4,-902 # 80000100 <consolewrite>
    8000048e:	ef98                	sd	a4,24(a5)
}
    80000490:	60a2                	ld	ra,8(sp)
    80000492:	6402                	ld	s0,0(sp)
    80000494:	0141                	addi	sp,sp,16
    80000496:	8082                	ret

0000000080000498 <printint>:

static char digits[] = "0123456789abcdef";

static void
printint(int xx, int base, int sign)
{
    80000498:	7179                	addi	sp,sp,-48
    8000049a:	f406                	sd	ra,40(sp)
    8000049c:	f022                	sd	s0,32(sp)
    8000049e:	ec26                	sd	s1,24(sp)
    800004a0:	e84a                	sd	s2,16(sp)
    800004a2:	1800                	addi	s0,sp,48
  char buf[16];
  int i;
  uint x;

  if(sign && (sign = xx < 0))
    800004a4:	c219                	beqz	a2,800004aa <printint+0x12>
    800004a6:	08054763          	bltz	a0,80000534 <printint+0x9c>
    x = -xx;
  else
    x = xx;
    800004aa:	2501                	sext.w	a0,a0
    800004ac:	4881                	li	a7,0
    800004ae:	fd040693          	addi	a3,s0,-48

  i = 0;
    800004b2:	4701                	li	a4,0
  do {
    buf[i++] = digits[x % base];
    800004b4:	2581                	sext.w	a1,a1
    800004b6:	00008617          	auipc	a2,0x8
    800004ba:	b8a60613          	addi	a2,a2,-1142 # 80008040 <digits>
    800004be:	883a                	mv	a6,a4
    800004c0:	2705                	addiw	a4,a4,1
    800004c2:	02b577bb          	remuw	a5,a0,a1
    800004c6:	1782                	slli	a5,a5,0x20
    800004c8:	9381                	srli	a5,a5,0x20
    800004ca:	97b2                	add	a5,a5,a2
    800004cc:	0007c783          	lbu	a5,0(a5)
    800004d0:	00f68023          	sb	a5,0(a3)
  } while((x /= base) != 0);
    800004d4:	0005079b          	sext.w	a5,a0
    800004d8:	02b5553b          	divuw	a0,a0,a1
    800004dc:	0685                	addi	a3,a3,1
    800004de:	feb7f0e3          	bgeu	a5,a1,800004be <printint+0x26>

  if(sign)
    800004e2:	00088c63          	beqz	a7,800004fa <printint+0x62>
    buf[i++] = '-';
    800004e6:	fe070793          	addi	a5,a4,-32
    800004ea:	00878733          	add	a4,a5,s0
    800004ee:	02d00793          	li	a5,45
    800004f2:	fef70823          	sb	a5,-16(a4)
    800004f6:	0028071b          	addiw	a4,a6,2

  while(--i >= 0)
    800004fa:	02e05763          	blez	a4,80000528 <printint+0x90>
    800004fe:	fd040793          	addi	a5,s0,-48
    80000502:	00e784b3          	add	s1,a5,a4
    80000506:	fff78913          	addi	s2,a5,-1
    8000050a:	993a                	add	s2,s2,a4
    8000050c:	377d                	addiw	a4,a4,-1
    8000050e:	1702                	slli	a4,a4,0x20
    80000510:	9301                	srli	a4,a4,0x20
    80000512:	40e90933          	sub	s2,s2,a4
    consputc(buf[i]);
    80000516:	fff4c503          	lbu	a0,-1(s1)
    8000051a:	00000097          	auipc	ra,0x0
    8000051e:	d5e080e7          	jalr	-674(ra) # 80000278 <consputc>
  while(--i >= 0)
    80000522:	14fd                	addi	s1,s1,-1
    80000524:	ff2499e3          	bne	s1,s2,80000516 <printint+0x7e>
}
    80000528:	70a2                	ld	ra,40(sp)
    8000052a:	7402                	ld	s0,32(sp)
    8000052c:	64e2                	ld	s1,24(sp)
    8000052e:	6942                	ld	s2,16(sp)
    80000530:	6145                	addi	sp,sp,48
    80000532:	8082                	ret
    x = -xx;
    80000534:	40a0053b          	negw	a0,a0
  if(sign && (sign = xx < 0))
    80000538:	4885                	li	a7,1
    x = -xx;
    8000053a:	bf95                	j	800004ae <printint+0x16>

000000008000053c <panic>:
    release(&pr.lock);
}

void
panic(char *s)
{
    8000053c:	1101                	addi	sp,sp,-32
    8000053e:	ec06                	sd	ra,24(sp)
    80000540:	e822                	sd	s0,16(sp)
    80000542:	e426                	sd	s1,8(sp)
    80000544:	1000                	addi	s0,sp,32
    80000546:	84aa                	mv	s1,a0
  pr.locking = 0;
    80000548:	00010797          	auipc	a5,0x10
    8000054c:	5807ac23          	sw	zero,1432(a5) # 80010ae0 <pr+0x18>
  printf("panic: ");
    80000550:	00008517          	auipc	a0,0x8
    80000554:	ac850513          	addi	a0,a0,-1336 # 80008018 <etext+0x18>
    80000558:	00000097          	auipc	ra,0x0
    8000055c:	02e080e7          	jalr	46(ra) # 80000586 <printf>
  printf(s);
    80000560:	8526                	mv	a0,s1
    80000562:	00000097          	auipc	ra,0x0
    80000566:	024080e7          	jalr	36(ra) # 80000586 <printf>
  printf("\n");
    8000056a:	00008517          	auipc	a0,0x8
    8000056e:	b5e50513          	addi	a0,a0,-1186 # 800080c8 <digits+0x88>
    80000572:	00000097          	auipc	ra,0x0
    80000576:	014080e7          	jalr	20(ra) # 80000586 <printf>
  panicked = 1; // freeze uart output from other CPUs
    8000057a:	4785                	li	a5,1
    8000057c:	00008717          	auipc	a4,0x8
    80000580:	32f72223          	sw	a5,804(a4) # 800088a0 <panicked>
  for(;;)
    80000584:	a001                	j	80000584 <panic+0x48>

0000000080000586 <printf>:
{
    80000586:	7131                	addi	sp,sp,-192
    80000588:	fc86                	sd	ra,120(sp)
    8000058a:	f8a2                	sd	s0,112(sp)
    8000058c:	f4a6                	sd	s1,104(sp)
    8000058e:	f0ca                	sd	s2,96(sp)
    80000590:	ecce                	sd	s3,88(sp)
    80000592:	e8d2                	sd	s4,80(sp)
    80000594:	e4d6                	sd	s5,72(sp)
    80000596:	e0da                	sd	s6,64(sp)
    80000598:	fc5e                	sd	s7,56(sp)
    8000059a:	f862                	sd	s8,48(sp)
    8000059c:	f466                	sd	s9,40(sp)
    8000059e:	f06a                	sd	s10,32(sp)
    800005a0:	ec6e                	sd	s11,24(sp)
    800005a2:	0100                	addi	s0,sp,128
    800005a4:	8a2a                	mv	s4,a0
    800005a6:	e40c                	sd	a1,8(s0)
    800005a8:	e810                	sd	a2,16(s0)
    800005aa:	ec14                	sd	a3,24(s0)
    800005ac:	f018                	sd	a4,32(s0)
    800005ae:	f41c                	sd	a5,40(s0)
    800005b0:	03043823          	sd	a6,48(s0)
    800005b4:	03143c23          	sd	a7,56(s0)
  locking = pr.locking;
    800005b8:	00010d97          	auipc	s11,0x10
    800005bc:	528dad83          	lw	s11,1320(s11) # 80010ae0 <pr+0x18>
  if(locking)
    800005c0:	020d9b63          	bnez	s11,800005f6 <printf+0x70>
  if (fmt == 0)
    800005c4:	040a0263          	beqz	s4,80000608 <printf+0x82>
  va_start(ap, fmt);
    800005c8:	00840793          	addi	a5,s0,8
    800005cc:	f8f43423          	sd	a5,-120(s0)
  for(i = 0; (c = fmt[i] & 0xff) != 0; i++){
    800005d0:	000a4503          	lbu	a0,0(s4)
    800005d4:	14050f63          	beqz	a0,80000732 <printf+0x1ac>
    800005d8:	4981                	li	s3,0
    if(c != '%'){
    800005da:	02500a93          	li	s5,37
    switch(c){
    800005de:	07000b93          	li	s7,112
  consputc('x');
    800005e2:	4d41                	li	s10,16
    consputc(digits[x >> (sizeof(uint64) * 8 - 4)]);
    800005e4:	00008b17          	auipc	s6,0x8
    800005e8:	a5cb0b13          	addi	s6,s6,-1444 # 80008040 <digits>
    switch(c){
    800005ec:	07300c93          	li	s9,115
    800005f0:	06400c13          	li	s8,100
    800005f4:	a82d                	j	8000062e <printf+0xa8>
    acquire(&pr.lock);
    800005f6:	00010517          	auipc	a0,0x10
    800005fa:	4d250513          	addi	a0,a0,1234 # 80010ac8 <pr>
    800005fe:	00000097          	auipc	ra,0x0
    80000602:	5d4080e7          	jalr	1492(ra) # 80000bd2 <acquire>
    80000606:	bf7d                	j	800005c4 <printf+0x3e>
    panic("null fmt");
    80000608:	00008517          	auipc	a0,0x8
    8000060c:	a2050513          	addi	a0,a0,-1504 # 80008028 <etext+0x28>
    80000610:	00000097          	auipc	ra,0x0
    80000614:	f2c080e7          	jalr	-212(ra) # 8000053c <panic>
      consputc(c);
    80000618:	00000097          	auipc	ra,0x0
    8000061c:	c60080e7          	jalr	-928(ra) # 80000278 <consputc>
  for(i = 0; (c = fmt[i] & 0xff) != 0; i++){
    80000620:	2985                	addiw	s3,s3,1
    80000622:	013a07b3          	add	a5,s4,s3
    80000626:	0007c503          	lbu	a0,0(a5)
    8000062a:	10050463          	beqz	a0,80000732 <printf+0x1ac>
    if(c != '%'){
    8000062e:	ff5515e3          	bne	a0,s5,80000618 <printf+0x92>
    c = fmt[++i] & 0xff;
    80000632:	2985                	addiw	s3,s3,1
    80000634:	013a07b3          	add	a5,s4,s3
    80000638:	0007c783          	lbu	a5,0(a5)
    8000063c:	0007849b          	sext.w	s1,a5
    if(c == 0)
    80000640:	cbed                	beqz	a5,80000732 <printf+0x1ac>
    switch(c){
    80000642:	05778a63          	beq	a5,s7,80000696 <printf+0x110>
    80000646:	02fbf663          	bgeu	s7,a5,80000672 <printf+0xec>
    8000064a:	09978863          	beq	a5,s9,800006da <printf+0x154>
    8000064e:	07800713          	li	a4,120
    80000652:	0ce79563          	bne	a5,a4,8000071c <printf+0x196>
      printint(va_arg(ap, int), 16, 1);
    80000656:	f8843783          	ld	a5,-120(s0)
    8000065a:	00878713          	addi	a4,a5,8
    8000065e:	f8e43423          	sd	a4,-120(s0)
    80000662:	4605                	li	a2,1
    80000664:	85ea                	mv	a1,s10
    80000666:	4388                	lw	a0,0(a5)
    80000668:	00000097          	auipc	ra,0x0
    8000066c:	e30080e7          	jalr	-464(ra) # 80000498 <printint>
      break;
    80000670:	bf45                	j	80000620 <printf+0x9a>
    switch(c){
    80000672:	09578f63          	beq	a5,s5,80000710 <printf+0x18a>
    80000676:	0b879363          	bne	a5,s8,8000071c <printf+0x196>
      printint(va_arg(ap, int), 10, 1);
    8000067a:	f8843783          	ld	a5,-120(s0)
    8000067e:	00878713          	addi	a4,a5,8
    80000682:	f8e43423          	sd	a4,-120(s0)
    80000686:	4605                	li	a2,1
    80000688:	45a9                	li	a1,10
    8000068a:	4388                	lw	a0,0(a5)
    8000068c:	00000097          	auipc	ra,0x0
    80000690:	e0c080e7          	jalr	-500(ra) # 80000498 <printint>
      break;
    80000694:	b771                	j	80000620 <printf+0x9a>
      printptr(va_arg(ap, uint64));
    80000696:	f8843783          	ld	a5,-120(s0)
    8000069a:	00878713          	addi	a4,a5,8
    8000069e:	f8e43423          	sd	a4,-120(s0)
    800006a2:	0007b903          	ld	s2,0(a5)
  consputc('0');
    800006a6:	03000513          	li	a0,48
    800006aa:	00000097          	auipc	ra,0x0
    800006ae:	bce080e7          	jalr	-1074(ra) # 80000278 <consputc>
  consputc('x');
    800006b2:	07800513          	li	a0,120
    800006b6:	00000097          	auipc	ra,0x0
    800006ba:	bc2080e7          	jalr	-1086(ra) # 80000278 <consputc>
    800006be:	84ea                	mv	s1,s10
    consputc(digits[x >> (sizeof(uint64) * 8 - 4)]);
    800006c0:	03c95793          	srli	a5,s2,0x3c
    800006c4:	97da                	add	a5,a5,s6
    800006c6:	0007c503          	lbu	a0,0(a5)
    800006ca:	00000097          	auipc	ra,0x0
    800006ce:	bae080e7          	jalr	-1106(ra) # 80000278 <consputc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
    800006d2:	0912                	slli	s2,s2,0x4
    800006d4:	34fd                	addiw	s1,s1,-1
    800006d6:	f4ed                	bnez	s1,800006c0 <printf+0x13a>
    800006d8:	b7a1                	j	80000620 <printf+0x9a>
      if((s = va_arg(ap, char*)) == 0)
    800006da:	f8843783          	ld	a5,-120(s0)
    800006de:	00878713          	addi	a4,a5,8
    800006e2:	f8e43423          	sd	a4,-120(s0)
    800006e6:	6384                	ld	s1,0(a5)
    800006e8:	cc89                	beqz	s1,80000702 <printf+0x17c>
      for(; *s; s++)
    800006ea:	0004c503          	lbu	a0,0(s1)
    800006ee:	d90d                	beqz	a0,80000620 <printf+0x9a>
        consputc(*s);
    800006f0:	00000097          	auipc	ra,0x0
    800006f4:	b88080e7          	jalr	-1144(ra) # 80000278 <consputc>
      for(; *s; s++)
    800006f8:	0485                	addi	s1,s1,1
    800006fa:	0004c503          	lbu	a0,0(s1)
    800006fe:	f96d                	bnez	a0,800006f0 <printf+0x16a>
    80000700:	b705                	j	80000620 <printf+0x9a>
        s = "(null)";
    80000702:	00008497          	auipc	s1,0x8
    80000706:	91e48493          	addi	s1,s1,-1762 # 80008020 <etext+0x20>
      for(; *s; s++)
    8000070a:	02800513          	li	a0,40
    8000070e:	b7cd                	j	800006f0 <printf+0x16a>
      consputc('%');
    80000710:	8556                	mv	a0,s5
    80000712:	00000097          	auipc	ra,0x0
    80000716:	b66080e7          	jalr	-1178(ra) # 80000278 <consputc>
      break;
    8000071a:	b719                	j	80000620 <printf+0x9a>
      consputc('%');
    8000071c:	8556                	mv	a0,s5
    8000071e:	00000097          	auipc	ra,0x0
    80000722:	b5a080e7          	jalr	-1190(ra) # 80000278 <consputc>
      consputc(c);
    80000726:	8526                	mv	a0,s1
    80000728:	00000097          	auipc	ra,0x0
    8000072c:	b50080e7          	jalr	-1200(ra) # 80000278 <consputc>
      break;
    80000730:	bdc5                	j	80000620 <printf+0x9a>
  if(locking)
    80000732:	020d9163          	bnez	s11,80000754 <printf+0x1ce>
}
    80000736:	70e6                	ld	ra,120(sp)
    80000738:	7446                	ld	s0,112(sp)
    8000073a:	74a6                	ld	s1,104(sp)
    8000073c:	7906                	ld	s2,96(sp)
    8000073e:	69e6                	ld	s3,88(sp)
    80000740:	6a46                	ld	s4,80(sp)
    80000742:	6aa6                	ld	s5,72(sp)
    80000744:	6b06                	ld	s6,64(sp)
    80000746:	7be2                	ld	s7,56(sp)
    80000748:	7c42                	ld	s8,48(sp)
    8000074a:	7ca2                	ld	s9,40(sp)
    8000074c:	7d02                	ld	s10,32(sp)
    8000074e:	6de2                	ld	s11,24(sp)
    80000750:	6129                	addi	sp,sp,192
    80000752:	8082                	ret
    release(&pr.lock);
    80000754:	00010517          	auipc	a0,0x10
    80000758:	37450513          	addi	a0,a0,884 # 80010ac8 <pr>
    8000075c:	00000097          	auipc	ra,0x0
    80000760:	52a080e7          	jalr	1322(ra) # 80000c86 <release>
}
    80000764:	bfc9                	j	80000736 <printf+0x1b0>

0000000080000766 <printfinit>:
    ;
}

void
printfinit(void)
{
    80000766:	1101                	addi	sp,sp,-32
    80000768:	ec06                	sd	ra,24(sp)
    8000076a:	e822                	sd	s0,16(sp)
    8000076c:	e426                	sd	s1,8(sp)
    8000076e:	1000                	addi	s0,sp,32
  initlock(&pr.lock, "pr");
    80000770:	00010497          	auipc	s1,0x10
    80000774:	35848493          	addi	s1,s1,856 # 80010ac8 <pr>
    80000778:	00008597          	auipc	a1,0x8
    8000077c:	8c058593          	addi	a1,a1,-1856 # 80008038 <etext+0x38>
    80000780:	8526                	mv	a0,s1
    80000782:	00000097          	auipc	ra,0x0
    80000786:	3c0080e7          	jalr	960(ra) # 80000b42 <initlock>
  pr.locking = 1;
    8000078a:	4785                	li	a5,1
    8000078c:	cc9c                	sw	a5,24(s1)
}
    8000078e:	60e2                	ld	ra,24(sp)
    80000790:	6442                	ld	s0,16(sp)
    80000792:	64a2                	ld	s1,8(sp)
    80000794:	6105                	addi	sp,sp,32
    80000796:	8082                	ret

0000000080000798 <uartinit>:

void uartstart();

void
uartinit(void)
{
    80000798:	1141                	addi	sp,sp,-16
    8000079a:	e406                	sd	ra,8(sp)
    8000079c:	e022                	sd	s0,0(sp)
    8000079e:	0800                	addi	s0,sp,16
  // disable interrupts.
  WriteReg(IER, 0x00);
    800007a0:	100007b7          	lui	a5,0x10000
    800007a4:	000780a3          	sb	zero,1(a5) # 10000001 <_entry-0x6fffffff>

  // special mode to set baud rate.
  WriteReg(LCR, LCR_BAUD_LATCH);
    800007a8:	f8000713          	li	a4,-128
    800007ac:	00e781a3          	sb	a4,3(a5)

  // LSB for baud rate of 38.4K.
  WriteReg(0, 0x03);
    800007b0:	470d                	li	a4,3
    800007b2:	00e78023          	sb	a4,0(a5)

  // MSB for baud rate of 38.4K.
  WriteReg(1, 0x00);
    800007b6:	000780a3          	sb	zero,1(a5)

  // leave set-baud mode,
  // and set word length to 8 bits, no parity.
  WriteReg(LCR, LCR_EIGHT_BITS);
    800007ba:	00e781a3          	sb	a4,3(a5)

  // reset and enable FIFOs.
  WriteReg(FCR, FCR_FIFO_ENABLE | FCR_FIFO_CLEAR);
    800007be:	469d                	li	a3,7
    800007c0:	00d78123          	sb	a3,2(a5)

  // enable transmit and receive interrupts.
  WriteReg(IER, IER_TX_ENABLE | IER_RX_ENABLE);
    800007c4:	00e780a3          	sb	a4,1(a5)

  initlock(&uart_tx_lock, "uart");
    800007c8:	00008597          	auipc	a1,0x8
    800007cc:	89058593          	addi	a1,a1,-1904 # 80008058 <digits+0x18>
    800007d0:	00010517          	auipc	a0,0x10
    800007d4:	31850513          	addi	a0,a0,792 # 80010ae8 <uart_tx_lock>
    800007d8:	00000097          	auipc	ra,0x0
    800007dc:	36a080e7          	jalr	874(ra) # 80000b42 <initlock>
}
    800007e0:	60a2                	ld	ra,8(sp)
    800007e2:	6402                	ld	s0,0(sp)
    800007e4:	0141                	addi	sp,sp,16
    800007e6:	8082                	ret

00000000800007e8 <uartputc_sync>:
// use interrupts, for use by kernel printf() and
// to echo characters. it spins waiting for the uart's
// output register to be empty.
void
uartputc_sync(int c)
{
    800007e8:	1101                	addi	sp,sp,-32
    800007ea:	ec06                	sd	ra,24(sp)
    800007ec:	e822                	sd	s0,16(sp)
    800007ee:	e426                	sd	s1,8(sp)
    800007f0:	1000                	addi	s0,sp,32
    800007f2:	84aa                	mv	s1,a0
  push_off();
    800007f4:	00000097          	auipc	ra,0x0
    800007f8:	392080e7          	jalr	914(ra) # 80000b86 <push_off>

  if(panicked){
    800007fc:	00008797          	auipc	a5,0x8
    80000800:	0a47a783          	lw	a5,164(a5) # 800088a0 <panicked>
    for(;;)
      ;
  }

  // wait for Transmit Holding Empty to be set in LSR.
  while((ReadReg(LSR) & LSR_TX_IDLE) == 0)
    80000804:	10000737          	lui	a4,0x10000
  if(panicked){
    80000808:	c391                	beqz	a5,8000080c <uartputc_sync+0x24>
    for(;;)
    8000080a:	a001                	j	8000080a <uartputc_sync+0x22>
  while((ReadReg(LSR) & LSR_TX_IDLE) == 0)
    8000080c:	00574783          	lbu	a5,5(a4) # 10000005 <_entry-0x6ffffffb>
    80000810:	0207f793          	andi	a5,a5,32
    80000814:	dfe5                	beqz	a5,8000080c <uartputc_sync+0x24>
    ;
  WriteReg(THR, c);
    80000816:	0ff4f513          	zext.b	a0,s1
    8000081a:	100007b7          	lui	a5,0x10000
    8000081e:	00a78023          	sb	a0,0(a5) # 10000000 <_entry-0x70000000>

  pop_off();
    80000822:	00000097          	auipc	ra,0x0
    80000826:	404080e7          	jalr	1028(ra) # 80000c26 <pop_off>
}
    8000082a:	60e2                	ld	ra,24(sp)
    8000082c:	6442                	ld	s0,16(sp)
    8000082e:	64a2                	ld	s1,8(sp)
    80000830:	6105                	addi	sp,sp,32
    80000832:	8082                	ret

0000000080000834 <uartstart>:
// called from both the top- and bottom-half.
void
uartstart()
{
  while(1){
    if(uart_tx_w == uart_tx_r){
    80000834:	00008797          	auipc	a5,0x8
    80000838:	0747b783          	ld	a5,116(a5) # 800088a8 <uart_tx_r>
    8000083c:	00008717          	auipc	a4,0x8
    80000840:	07473703          	ld	a4,116(a4) # 800088b0 <uart_tx_w>
    80000844:	06f70a63          	beq	a4,a5,800008b8 <uartstart+0x84>
{
    80000848:	7139                	addi	sp,sp,-64
    8000084a:	fc06                	sd	ra,56(sp)
    8000084c:	f822                	sd	s0,48(sp)
    8000084e:	f426                	sd	s1,40(sp)
    80000850:	f04a                	sd	s2,32(sp)
    80000852:	ec4e                	sd	s3,24(sp)
    80000854:	e852                	sd	s4,16(sp)
    80000856:	e456                	sd	s5,8(sp)
    80000858:	0080                	addi	s0,sp,64
      // transmit buffer is empty.
      return;
    }
    
    if((ReadReg(LSR) & LSR_TX_IDLE) == 0){
    8000085a:	10000937          	lui	s2,0x10000
      // so we cannot give it another byte.
      // it will interrupt when it's ready for a new byte.
      return;
    }
    
    int c = uart_tx_buf[uart_tx_r % UART_TX_BUF_SIZE];
    8000085e:	00010a17          	auipc	s4,0x10
    80000862:	28aa0a13          	addi	s4,s4,650 # 80010ae8 <uart_tx_lock>
    uart_tx_r += 1;
    80000866:	00008497          	auipc	s1,0x8
    8000086a:	04248493          	addi	s1,s1,66 # 800088a8 <uart_tx_r>
    if(uart_tx_w == uart_tx_r){
    8000086e:	00008997          	auipc	s3,0x8
    80000872:	04298993          	addi	s3,s3,66 # 800088b0 <uart_tx_w>
    if((ReadReg(LSR) & LSR_TX_IDLE) == 0){
    80000876:	00594703          	lbu	a4,5(s2) # 10000005 <_entry-0x6ffffffb>
    8000087a:	02077713          	andi	a4,a4,32
    8000087e:	c705                	beqz	a4,800008a6 <uartstart+0x72>
    int c = uart_tx_buf[uart_tx_r % UART_TX_BUF_SIZE];
    80000880:	01f7f713          	andi	a4,a5,31
    80000884:	9752                	add	a4,a4,s4
    80000886:	01874a83          	lbu	s5,24(a4)
    uart_tx_r += 1;
    8000088a:	0785                	addi	a5,a5,1
    8000088c:	e09c                	sd	a5,0(s1)
    
    // maybe uartputc() is waiting for space in the buffer.
    wakeup(&uart_tx_r);
    8000088e:	8526                	mv	a0,s1
    80000890:	00002097          	auipc	ra,0x2
    80000894:	86e080e7          	jalr	-1938(ra) # 800020fe <wakeup>
    
    WriteReg(THR, c);
    80000898:	01590023          	sb	s5,0(s2)
    if(uart_tx_w == uart_tx_r){
    8000089c:	609c                	ld	a5,0(s1)
    8000089e:	0009b703          	ld	a4,0(s3)
    800008a2:	fcf71ae3          	bne	a4,a5,80000876 <uartstart+0x42>
  }
}
    800008a6:	70e2                	ld	ra,56(sp)
    800008a8:	7442                	ld	s0,48(sp)
    800008aa:	74a2                	ld	s1,40(sp)
    800008ac:	7902                	ld	s2,32(sp)
    800008ae:	69e2                	ld	s3,24(sp)
    800008b0:	6a42                	ld	s4,16(sp)
    800008b2:	6aa2                	ld	s5,8(sp)
    800008b4:	6121                	addi	sp,sp,64
    800008b6:	8082                	ret
    800008b8:	8082                	ret

00000000800008ba <uartputc>:
{
    800008ba:	7179                	addi	sp,sp,-48
    800008bc:	f406                	sd	ra,40(sp)
    800008be:	f022                	sd	s0,32(sp)
    800008c0:	ec26                	sd	s1,24(sp)
    800008c2:	e84a                	sd	s2,16(sp)
    800008c4:	e44e                	sd	s3,8(sp)
    800008c6:	e052                	sd	s4,0(sp)
    800008c8:	1800                	addi	s0,sp,48
    800008ca:	8a2a                	mv	s4,a0
  acquire(&uart_tx_lock);
    800008cc:	00010517          	auipc	a0,0x10
    800008d0:	21c50513          	addi	a0,a0,540 # 80010ae8 <uart_tx_lock>
    800008d4:	00000097          	auipc	ra,0x0
    800008d8:	2fe080e7          	jalr	766(ra) # 80000bd2 <acquire>
  if(panicked){
    800008dc:	00008797          	auipc	a5,0x8
    800008e0:	fc47a783          	lw	a5,-60(a5) # 800088a0 <panicked>
    800008e4:	e7c9                	bnez	a5,8000096e <uartputc+0xb4>
  while(uart_tx_w == uart_tx_r + UART_TX_BUF_SIZE){
    800008e6:	00008717          	auipc	a4,0x8
    800008ea:	fca73703          	ld	a4,-54(a4) # 800088b0 <uart_tx_w>
    800008ee:	00008797          	auipc	a5,0x8
    800008f2:	fba7b783          	ld	a5,-70(a5) # 800088a8 <uart_tx_r>
    800008f6:	02078793          	addi	a5,a5,32
    sleep(&uart_tx_r, &uart_tx_lock);
    800008fa:	00010997          	auipc	s3,0x10
    800008fe:	1ee98993          	addi	s3,s3,494 # 80010ae8 <uart_tx_lock>
    80000902:	00008497          	auipc	s1,0x8
    80000906:	fa648493          	addi	s1,s1,-90 # 800088a8 <uart_tx_r>
  while(uart_tx_w == uart_tx_r + UART_TX_BUF_SIZE){
    8000090a:	00008917          	auipc	s2,0x8
    8000090e:	fa690913          	addi	s2,s2,-90 # 800088b0 <uart_tx_w>
    80000912:	00e79f63          	bne	a5,a4,80000930 <uartputc+0x76>
    sleep(&uart_tx_r, &uart_tx_lock);
    80000916:	85ce                	mv	a1,s3
    80000918:	8526                	mv	a0,s1
    8000091a:	00001097          	auipc	ra,0x1
    8000091e:	780080e7          	jalr	1920(ra) # 8000209a <sleep>
  while(uart_tx_w == uart_tx_r + UART_TX_BUF_SIZE){
    80000922:	00093703          	ld	a4,0(s2)
    80000926:	609c                	ld	a5,0(s1)
    80000928:	02078793          	addi	a5,a5,32
    8000092c:	fee785e3          	beq	a5,a4,80000916 <uartputc+0x5c>
  uart_tx_buf[uart_tx_w % UART_TX_BUF_SIZE] = c;
    80000930:	00010497          	auipc	s1,0x10
    80000934:	1b848493          	addi	s1,s1,440 # 80010ae8 <uart_tx_lock>
    80000938:	01f77793          	andi	a5,a4,31
    8000093c:	97a6                	add	a5,a5,s1
    8000093e:	01478c23          	sb	s4,24(a5)
  uart_tx_w += 1;
    80000942:	0705                	addi	a4,a4,1
    80000944:	00008797          	auipc	a5,0x8
    80000948:	f6e7b623          	sd	a4,-148(a5) # 800088b0 <uart_tx_w>
  uartstart();
    8000094c:	00000097          	auipc	ra,0x0
    80000950:	ee8080e7          	jalr	-280(ra) # 80000834 <uartstart>
  release(&uart_tx_lock);
    80000954:	8526                	mv	a0,s1
    80000956:	00000097          	auipc	ra,0x0
    8000095a:	330080e7          	jalr	816(ra) # 80000c86 <release>
}
    8000095e:	70a2                	ld	ra,40(sp)
    80000960:	7402                	ld	s0,32(sp)
    80000962:	64e2                	ld	s1,24(sp)
    80000964:	6942                	ld	s2,16(sp)
    80000966:	69a2                	ld	s3,8(sp)
    80000968:	6a02                	ld	s4,0(sp)
    8000096a:	6145                	addi	sp,sp,48
    8000096c:	8082                	ret
    for(;;)
    8000096e:	a001                	j	8000096e <uartputc+0xb4>

0000000080000970 <uartgetc>:

// read one input character from the UART.
// return -1 if none is waiting.
int
uartgetc(void)
{
    80000970:	1141                	addi	sp,sp,-16
    80000972:	e422                	sd	s0,8(sp)
    80000974:	0800                	addi	s0,sp,16
  if(ReadReg(LSR) & 0x01){
    80000976:	100007b7          	lui	a5,0x10000
    8000097a:	0057c783          	lbu	a5,5(a5) # 10000005 <_entry-0x6ffffffb>
    8000097e:	8b85                	andi	a5,a5,1
    80000980:	cb81                	beqz	a5,80000990 <uartgetc+0x20>
    // input data is ready.
    return ReadReg(RHR);
    80000982:	100007b7          	lui	a5,0x10000
    80000986:	0007c503          	lbu	a0,0(a5) # 10000000 <_entry-0x70000000>
  } else {
    return -1;
  }
}
    8000098a:	6422                	ld	s0,8(sp)
    8000098c:	0141                	addi	sp,sp,16
    8000098e:	8082                	ret
    return -1;
    80000990:	557d                	li	a0,-1
    80000992:	bfe5                	j	8000098a <uartgetc+0x1a>

0000000080000994 <uartintr>:
// handle a uart interrupt, raised because input has
// arrived, or the uart is ready for more output, or
// both. called from devintr().
void
uartintr(void)
{
    80000994:	1101                	addi	sp,sp,-32
    80000996:	ec06                	sd	ra,24(sp)
    80000998:	e822                	sd	s0,16(sp)
    8000099a:	e426                	sd	s1,8(sp)
    8000099c:	1000                	addi	s0,sp,32
  // read and process incoming characters.
  while(1){
    int c = uartgetc();
    if(c == -1)
    8000099e:	54fd                	li	s1,-1
    800009a0:	a029                	j	800009aa <uartintr+0x16>
      break;
    consoleintr(c);
    800009a2:	00000097          	auipc	ra,0x0
    800009a6:	918080e7          	jalr	-1768(ra) # 800002ba <consoleintr>
    int c = uartgetc();
    800009aa:	00000097          	auipc	ra,0x0
    800009ae:	fc6080e7          	jalr	-58(ra) # 80000970 <uartgetc>
    if(c == -1)
    800009b2:	fe9518e3          	bne	a0,s1,800009a2 <uartintr+0xe>
  }

  // send buffered characters.
  acquire(&uart_tx_lock);
    800009b6:	00010497          	auipc	s1,0x10
    800009ba:	13248493          	addi	s1,s1,306 # 80010ae8 <uart_tx_lock>
    800009be:	8526                	mv	a0,s1
    800009c0:	00000097          	auipc	ra,0x0
    800009c4:	212080e7          	jalr	530(ra) # 80000bd2 <acquire>
  uartstart();
    800009c8:	00000097          	auipc	ra,0x0
    800009cc:	e6c080e7          	jalr	-404(ra) # 80000834 <uartstart>
  release(&uart_tx_lock);
    800009d0:	8526                	mv	a0,s1
    800009d2:	00000097          	auipc	ra,0x0
    800009d6:	2b4080e7          	jalr	692(ra) # 80000c86 <release>
}
    800009da:	60e2                	ld	ra,24(sp)
    800009dc:	6442                	ld	s0,16(sp)
    800009de:	64a2                	ld	s1,8(sp)
    800009e0:	6105                	addi	sp,sp,32
    800009e2:	8082                	ret

00000000800009e4 <kfree>:
// which normally should have been returned by a
// call to kalloc().  (The exception is when
// initializing the allocator; see kinit above.)
void
kfree(void *pa)
{
    800009e4:	1101                	addi	sp,sp,-32
    800009e6:	ec06                	sd	ra,24(sp)
    800009e8:	e822                	sd	s0,16(sp)
    800009ea:	e426                	sd	s1,8(sp)
    800009ec:	e04a                	sd	s2,0(sp)
    800009ee:	1000                	addi	s0,sp,32
  struct run *r;

  if(((uint64)pa % PGSIZE) != 0 || (char*)pa < end || (uint64)pa >= PHYSTOP)
    800009f0:	03451793          	slli	a5,a0,0x34
    800009f4:	ebb9                	bnez	a5,80000a4a <kfree+0x66>
    800009f6:	84aa                	mv	s1,a0
    800009f8:	00021797          	auipc	a5,0x21
    800009fc:	35878793          	addi	a5,a5,856 # 80021d50 <end>
    80000a00:	04f56563          	bltu	a0,a5,80000a4a <kfree+0x66>
    80000a04:	47c5                	li	a5,17
    80000a06:	07ee                	slli	a5,a5,0x1b
    80000a08:	04f57163          	bgeu	a0,a5,80000a4a <kfree+0x66>
    panic("kfree");

  // Fill with junk to catch dangling refs.
  memset(pa, 1, PGSIZE);
    80000a0c:	6605                	lui	a2,0x1
    80000a0e:	4585                	li	a1,1
    80000a10:	00000097          	auipc	ra,0x0
    80000a14:	2be080e7          	jalr	702(ra) # 80000cce <memset>

  r = (struct run*)pa;

  acquire(&kmem.lock);
    80000a18:	00010917          	auipc	s2,0x10
    80000a1c:	10890913          	addi	s2,s2,264 # 80010b20 <kmem>
    80000a20:	854a                	mv	a0,s2
    80000a22:	00000097          	auipc	ra,0x0
    80000a26:	1b0080e7          	jalr	432(ra) # 80000bd2 <acquire>
  r->next = kmem.freelist;
    80000a2a:	01893783          	ld	a5,24(s2)
    80000a2e:	e09c                	sd	a5,0(s1)
  kmem.freelist = r;
    80000a30:	00993c23          	sd	s1,24(s2)
  release(&kmem.lock);
    80000a34:	854a                	mv	a0,s2
    80000a36:	00000097          	auipc	ra,0x0
    80000a3a:	250080e7          	jalr	592(ra) # 80000c86 <release>
}
    80000a3e:	60e2                	ld	ra,24(sp)
    80000a40:	6442                	ld	s0,16(sp)
    80000a42:	64a2                	ld	s1,8(sp)
    80000a44:	6902                	ld	s2,0(sp)
    80000a46:	6105                	addi	sp,sp,32
    80000a48:	8082                	ret
    panic("kfree");
    80000a4a:	00007517          	auipc	a0,0x7
    80000a4e:	61650513          	addi	a0,a0,1558 # 80008060 <digits+0x20>
    80000a52:	00000097          	auipc	ra,0x0
    80000a56:	aea080e7          	jalr	-1302(ra) # 8000053c <panic>

0000000080000a5a <freerange>:
{
    80000a5a:	7179                	addi	sp,sp,-48
    80000a5c:	f406                	sd	ra,40(sp)
    80000a5e:	f022                	sd	s0,32(sp)
    80000a60:	ec26                	sd	s1,24(sp)
    80000a62:	e84a                	sd	s2,16(sp)
    80000a64:	e44e                	sd	s3,8(sp)
    80000a66:	e052                	sd	s4,0(sp)
    80000a68:	1800                	addi	s0,sp,48
  p = (char*)PGROUNDUP((uint64)pa_start);
    80000a6a:	6785                	lui	a5,0x1
    80000a6c:	fff78713          	addi	a4,a5,-1 # fff <_entry-0x7ffff001>
    80000a70:	00e504b3          	add	s1,a0,a4
    80000a74:	777d                	lui	a4,0xfffff
    80000a76:	8cf9                	and	s1,s1,a4
  for(; p + PGSIZE <= (char*)pa_end; p += PGSIZE)
    80000a78:	94be                	add	s1,s1,a5
    80000a7a:	0095ee63          	bltu	a1,s1,80000a96 <freerange+0x3c>
    80000a7e:	892e                	mv	s2,a1
    kfree(p);
    80000a80:	7a7d                	lui	s4,0xfffff
  for(; p + PGSIZE <= (char*)pa_end; p += PGSIZE)
    80000a82:	6985                	lui	s3,0x1
    kfree(p);
    80000a84:	01448533          	add	a0,s1,s4
    80000a88:	00000097          	auipc	ra,0x0
    80000a8c:	f5c080e7          	jalr	-164(ra) # 800009e4 <kfree>
  for(; p + PGSIZE <= (char*)pa_end; p += PGSIZE)
    80000a90:	94ce                	add	s1,s1,s3
    80000a92:	fe9979e3          	bgeu	s2,s1,80000a84 <freerange+0x2a>
}
    80000a96:	70a2                	ld	ra,40(sp)
    80000a98:	7402                	ld	s0,32(sp)
    80000a9a:	64e2                	ld	s1,24(sp)
    80000a9c:	6942                	ld	s2,16(sp)
    80000a9e:	69a2                	ld	s3,8(sp)
    80000aa0:	6a02                	ld	s4,0(sp)
    80000aa2:	6145                	addi	sp,sp,48
    80000aa4:	8082                	ret

0000000080000aa6 <kinit>:
{
    80000aa6:	1141                	addi	sp,sp,-16
    80000aa8:	e406                	sd	ra,8(sp)
    80000aaa:	e022                	sd	s0,0(sp)
    80000aac:	0800                	addi	s0,sp,16
  initlock(&kmem.lock, "kmem");
    80000aae:	00007597          	auipc	a1,0x7
    80000ab2:	5ba58593          	addi	a1,a1,1466 # 80008068 <digits+0x28>
    80000ab6:	00010517          	auipc	a0,0x10
    80000aba:	06a50513          	addi	a0,a0,106 # 80010b20 <kmem>
    80000abe:	00000097          	auipc	ra,0x0
    80000ac2:	084080e7          	jalr	132(ra) # 80000b42 <initlock>
  freerange(end, (void*)PHYSTOP);
    80000ac6:	45c5                	li	a1,17
    80000ac8:	05ee                	slli	a1,a1,0x1b
    80000aca:	00021517          	auipc	a0,0x21
    80000ace:	28650513          	addi	a0,a0,646 # 80021d50 <end>
    80000ad2:	00000097          	auipc	ra,0x0
    80000ad6:	f88080e7          	jalr	-120(ra) # 80000a5a <freerange>
}
    80000ada:	60a2                	ld	ra,8(sp)
    80000adc:	6402                	ld	s0,0(sp)
    80000ade:	0141                	addi	sp,sp,16
    80000ae0:	8082                	ret

0000000080000ae2 <kalloc>:
// Allocate one 4096-byte page of physical memory.
// Returns a pointer that the kernel can use.
// Returns 0 if the memory cannot be allocated.
void *
kalloc(void)
{
    80000ae2:	1101                	addi	sp,sp,-32
    80000ae4:	ec06                	sd	ra,24(sp)
    80000ae6:	e822                	sd	s0,16(sp)
    80000ae8:	e426                	sd	s1,8(sp)
    80000aea:	1000                	addi	s0,sp,32
  struct run *r;

  acquire(&kmem.lock);
    80000aec:	00010497          	auipc	s1,0x10
    80000af0:	03448493          	addi	s1,s1,52 # 80010b20 <kmem>
    80000af4:	8526                	mv	a0,s1
    80000af6:	00000097          	auipc	ra,0x0
    80000afa:	0dc080e7          	jalr	220(ra) # 80000bd2 <acquire>
  r = kmem.freelist;
    80000afe:	6c84                	ld	s1,24(s1)
  if(r)
    80000b00:	c885                	beqz	s1,80000b30 <kalloc+0x4e>
    kmem.freelist = r->next;
    80000b02:	609c                	ld	a5,0(s1)
    80000b04:	00010517          	auipc	a0,0x10
    80000b08:	01c50513          	addi	a0,a0,28 # 80010b20 <kmem>
    80000b0c:	ed1c                	sd	a5,24(a0)
  release(&kmem.lock);
    80000b0e:	00000097          	auipc	ra,0x0
    80000b12:	178080e7          	jalr	376(ra) # 80000c86 <release>

  if(r)
    memset((char*)r, 5, PGSIZE); // fill with junk
    80000b16:	6605                	lui	a2,0x1
    80000b18:	4595                	li	a1,5
    80000b1a:	8526                	mv	a0,s1
    80000b1c:	00000097          	auipc	ra,0x0
    80000b20:	1b2080e7          	jalr	434(ra) # 80000cce <memset>
  return (void*)r;
}
    80000b24:	8526                	mv	a0,s1
    80000b26:	60e2                	ld	ra,24(sp)
    80000b28:	6442                	ld	s0,16(sp)
    80000b2a:	64a2                	ld	s1,8(sp)
    80000b2c:	6105                	addi	sp,sp,32
    80000b2e:	8082                	ret
  release(&kmem.lock);
    80000b30:	00010517          	auipc	a0,0x10
    80000b34:	ff050513          	addi	a0,a0,-16 # 80010b20 <kmem>
    80000b38:	00000097          	auipc	ra,0x0
    80000b3c:	14e080e7          	jalr	334(ra) # 80000c86 <release>
  if(r)
    80000b40:	b7d5                	j	80000b24 <kalloc+0x42>

0000000080000b42 <initlock>:
#include "proc.h"
#include "defs.h"

void
initlock(struct spinlock *lk, char *name)
{
    80000b42:	1141                	addi	sp,sp,-16
    80000b44:	e422                	sd	s0,8(sp)
    80000b46:	0800                	addi	s0,sp,16
  lk->name = name;
    80000b48:	e50c                	sd	a1,8(a0)
  lk->locked = 0;
    80000b4a:	00052023          	sw	zero,0(a0)
  lk->cpu = 0;
    80000b4e:	00053823          	sd	zero,16(a0)
}
    80000b52:	6422                	ld	s0,8(sp)
    80000b54:	0141                	addi	sp,sp,16
    80000b56:	8082                	ret

0000000080000b58 <holding>:
// Interrupts must be off.
int
holding(struct spinlock *lk)
{
  int r;
  r = (lk->locked && lk->cpu == mycpu());
    80000b58:	411c                	lw	a5,0(a0)
    80000b5a:	e399                	bnez	a5,80000b60 <holding+0x8>
    80000b5c:	4501                	li	a0,0
  return r;
}
    80000b5e:	8082                	ret
{
    80000b60:	1101                	addi	sp,sp,-32
    80000b62:	ec06                	sd	ra,24(sp)
    80000b64:	e822                	sd	s0,16(sp)
    80000b66:	e426                	sd	s1,8(sp)
    80000b68:	1000                	addi	s0,sp,32
  r = (lk->locked && lk->cpu == mycpu());
    80000b6a:	6904                	ld	s1,16(a0)
    80000b6c:	00001097          	auipc	ra,0x1
    80000b70:	e1e080e7          	jalr	-482(ra) # 8000198a <mycpu>
    80000b74:	40a48533          	sub	a0,s1,a0
    80000b78:	00153513          	seqz	a0,a0
}
    80000b7c:	60e2                	ld	ra,24(sp)
    80000b7e:	6442                	ld	s0,16(sp)
    80000b80:	64a2                	ld	s1,8(sp)
    80000b82:	6105                	addi	sp,sp,32
    80000b84:	8082                	ret

0000000080000b86 <push_off>:
// it takes two pop_off()s to undo two push_off()s.  Also, if interrupts
// are initially off, then push_off, pop_off leaves them off.

void
push_off(void)
{
    80000b86:	1101                	addi	sp,sp,-32
    80000b88:	ec06                	sd	ra,24(sp)
    80000b8a:	e822                	sd	s0,16(sp)
    80000b8c:	e426                	sd	s1,8(sp)
    80000b8e:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80000b90:	100024f3          	csrr	s1,sstatus
    80000b94:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    80000b98:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80000b9a:	10079073          	csrw	sstatus,a5
  int old = intr_get();

  intr_off();
  if(mycpu()->noff == 0)
    80000b9e:	00001097          	auipc	ra,0x1
    80000ba2:	dec080e7          	jalr	-532(ra) # 8000198a <mycpu>
    80000ba6:	5d3c                	lw	a5,120(a0)
    80000ba8:	cf89                	beqz	a5,80000bc2 <push_off+0x3c>
    mycpu()->intena = old;
  mycpu()->noff += 1;
    80000baa:	00001097          	auipc	ra,0x1
    80000bae:	de0080e7          	jalr	-544(ra) # 8000198a <mycpu>
    80000bb2:	5d3c                	lw	a5,120(a0)
    80000bb4:	2785                	addiw	a5,a5,1
    80000bb6:	dd3c                	sw	a5,120(a0)
}
    80000bb8:	60e2                	ld	ra,24(sp)
    80000bba:	6442                	ld	s0,16(sp)
    80000bbc:	64a2                	ld	s1,8(sp)
    80000bbe:	6105                	addi	sp,sp,32
    80000bc0:	8082                	ret
    mycpu()->intena = old;
    80000bc2:	00001097          	auipc	ra,0x1
    80000bc6:	dc8080e7          	jalr	-568(ra) # 8000198a <mycpu>
  return (x & SSTATUS_SIE) != 0;
    80000bca:	8085                	srli	s1,s1,0x1
    80000bcc:	8885                	andi	s1,s1,1
    80000bce:	dd64                	sw	s1,124(a0)
    80000bd0:	bfe9                	j	80000baa <push_off+0x24>

0000000080000bd2 <acquire>:
{
    80000bd2:	1101                	addi	sp,sp,-32
    80000bd4:	ec06                	sd	ra,24(sp)
    80000bd6:	e822                	sd	s0,16(sp)
    80000bd8:	e426                	sd	s1,8(sp)
    80000bda:	1000                	addi	s0,sp,32
    80000bdc:	84aa                	mv	s1,a0
  push_off(); // disable interrupts to avoid deadlock.
    80000bde:	00000097          	auipc	ra,0x0
    80000be2:	fa8080e7          	jalr	-88(ra) # 80000b86 <push_off>
  if(holding(lk))
    80000be6:	8526                	mv	a0,s1
    80000be8:	00000097          	auipc	ra,0x0
    80000bec:	f70080e7          	jalr	-144(ra) # 80000b58 <holding>
  while(__sync_lock_test_and_set(&lk->locked, 1) != 0)
    80000bf0:	4705                	li	a4,1
  if(holding(lk))
    80000bf2:	e115                	bnez	a0,80000c16 <acquire+0x44>
  while(__sync_lock_test_and_set(&lk->locked, 1) != 0)
    80000bf4:	87ba                	mv	a5,a4
    80000bf6:	0cf4a7af          	amoswap.w.aq	a5,a5,(s1)
    80000bfa:	2781                	sext.w	a5,a5
    80000bfc:	ffe5                	bnez	a5,80000bf4 <acquire+0x22>
  __sync_synchronize();
    80000bfe:	0ff0000f          	fence
  lk->cpu = mycpu();
    80000c02:	00001097          	auipc	ra,0x1
    80000c06:	d88080e7          	jalr	-632(ra) # 8000198a <mycpu>
    80000c0a:	e888                	sd	a0,16(s1)
}
    80000c0c:	60e2                	ld	ra,24(sp)
    80000c0e:	6442                	ld	s0,16(sp)
    80000c10:	64a2                	ld	s1,8(sp)
    80000c12:	6105                	addi	sp,sp,32
    80000c14:	8082                	ret
    panic("acquire");
    80000c16:	00007517          	auipc	a0,0x7
    80000c1a:	45a50513          	addi	a0,a0,1114 # 80008070 <digits+0x30>
    80000c1e:	00000097          	auipc	ra,0x0
    80000c22:	91e080e7          	jalr	-1762(ra) # 8000053c <panic>

0000000080000c26 <pop_off>:

void
pop_off(void)
{
    80000c26:	1141                	addi	sp,sp,-16
    80000c28:	e406                	sd	ra,8(sp)
    80000c2a:	e022                	sd	s0,0(sp)
    80000c2c:	0800                	addi	s0,sp,16
  struct cpu *c = mycpu();
    80000c2e:	00001097          	auipc	ra,0x1
    80000c32:	d5c080e7          	jalr	-676(ra) # 8000198a <mycpu>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80000c36:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80000c3a:	8b89                	andi	a5,a5,2
  if(intr_get())
    80000c3c:	e78d                	bnez	a5,80000c66 <pop_off+0x40>
    panic("pop_off - interruptible");
  if(c->noff < 1)
    80000c3e:	5d3c                	lw	a5,120(a0)
    80000c40:	02f05b63          	blez	a5,80000c76 <pop_off+0x50>
    panic("pop_off");
  c->noff -= 1;
    80000c44:	37fd                	addiw	a5,a5,-1
    80000c46:	0007871b          	sext.w	a4,a5
    80000c4a:	dd3c                	sw	a5,120(a0)
  if(c->noff == 0 && c->intena)
    80000c4c:	eb09                	bnez	a4,80000c5e <pop_off+0x38>
    80000c4e:	5d7c                	lw	a5,124(a0)
    80000c50:	c799                	beqz	a5,80000c5e <pop_off+0x38>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80000c52:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80000c56:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80000c5a:	10079073          	csrw	sstatus,a5
    intr_on();
}
    80000c5e:	60a2                	ld	ra,8(sp)
    80000c60:	6402                	ld	s0,0(sp)
    80000c62:	0141                	addi	sp,sp,16
    80000c64:	8082                	ret
    panic("pop_off - interruptible");
    80000c66:	00007517          	auipc	a0,0x7
    80000c6a:	41250513          	addi	a0,a0,1042 # 80008078 <digits+0x38>
    80000c6e:	00000097          	auipc	ra,0x0
    80000c72:	8ce080e7          	jalr	-1842(ra) # 8000053c <panic>
    panic("pop_off");
    80000c76:	00007517          	auipc	a0,0x7
    80000c7a:	41a50513          	addi	a0,a0,1050 # 80008090 <digits+0x50>
    80000c7e:	00000097          	auipc	ra,0x0
    80000c82:	8be080e7          	jalr	-1858(ra) # 8000053c <panic>

0000000080000c86 <release>:
{
    80000c86:	1101                	addi	sp,sp,-32
    80000c88:	ec06                	sd	ra,24(sp)
    80000c8a:	e822                	sd	s0,16(sp)
    80000c8c:	e426                	sd	s1,8(sp)
    80000c8e:	1000                	addi	s0,sp,32
    80000c90:	84aa                	mv	s1,a0
  if(!holding(lk))
    80000c92:	00000097          	auipc	ra,0x0
    80000c96:	ec6080e7          	jalr	-314(ra) # 80000b58 <holding>
    80000c9a:	c115                	beqz	a0,80000cbe <release+0x38>
  lk->cpu = 0;
    80000c9c:	0004b823          	sd	zero,16(s1)
  __sync_synchronize();
    80000ca0:	0ff0000f          	fence
  __sync_lock_release(&lk->locked);
    80000ca4:	0f50000f          	fence	iorw,ow
    80000ca8:	0804a02f          	amoswap.w	zero,zero,(s1)
  pop_off();
    80000cac:	00000097          	auipc	ra,0x0
    80000cb0:	f7a080e7          	jalr	-134(ra) # 80000c26 <pop_off>
}
    80000cb4:	60e2                	ld	ra,24(sp)
    80000cb6:	6442                	ld	s0,16(sp)
    80000cb8:	64a2                	ld	s1,8(sp)
    80000cba:	6105                	addi	sp,sp,32
    80000cbc:	8082                	ret
    panic("release");
    80000cbe:	00007517          	auipc	a0,0x7
    80000cc2:	3da50513          	addi	a0,a0,986 # 80008098 <digits+0x58>
    80000cc6:	00000097          	auipc	ra,0x0
    80000cca:	876080e7          	jalr	-1930(ra) # 8000053c <panic>

0000000080000cce <memset>:
#include "types.h"

void*
memset(void *dst, int c, uint n)
{
    80000cce:	1141                	addi	sp,sp,-16
    80000cd0:	e422                	sd	s0,8(sp)
    80000cd2:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
    80000cd4:	ca19                	beqz	a2,80000cea <memset+0x1c>
    80000cd6:	87aa                	mv	a5,a0
    80000cd8:	1602                	slli	a2,a2,0x20
    80000cda:	9201                	srli	a2,a2,0x20
    80000cdc:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
    80000ce0:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
    80000ce4:	0785                	addi	a5,a5,1
    80000ce6:	fee79de3          	bne	a5,a4,80000ce0 <memset+0x12>
  }
  return dst;
}
    80000cea:	6422                	ld	s0,8(sp)
    80000cec:	0141                	addi	sp,sp,16
    80000cee:	8082                	ret

0000000080000cf0 <memcmp>:

int
memcmp(const void *v1, const void *v2, uint n)
{
    80000cf0:	1141                	addi	sp,sp,-16
    80000cf2:	e422                	sd	s0,8(sp)
    80000cf4:	0800                	addi	s0,sp,16
  const uchar *s1, *s2;

  s1 = v1;
  s2 = v2;
  while(n-- > 0){
    80000cf6:	ca05                	beqz	a2,80000d26 <memcmp+0x36>
    80000cf8:	fff6069b          	addiw	a3,a2,-1 # fff <_entry-0x7ffff001>
    80000cfc:	1682                	slli	a3,a3,0x20
    80000cfe:	9281                	srli	a3,a3,0x20
    80000d00:	0685                	addi	a3,a3,1
    80000d02:	96aa                	add	a3,a3,a0
    if(*s1 != *s2)
    80000d04:	00054783          	lbu	a5,0(a0)
    80000d08:	0005c703          	lbu	a4,0(a1)
    80000d0c:	00e79863          	bne	a5,a4,80000d1c <memcmp+0x2c>
      return *s1 - *s2;
    s1++, s2++;
    80000d10:	0505                	addi	a0,a0,1
    80000d12:	0585                	addi	a1,a1,1
  while(n-- > 0){
    80000d14:	fed518e3          	bne	a0,a3,80000d04 <memcmp+0x14>
  }

  return 0;
    80000d18:	4501                	li	a0,0
    80000d1a:	a019                	j	80000d20 <memcmp+0x30>
      return *s1 - *s2;
    80000d1c:	40e7853b          	subw	a0,a5,a4
}
    80000d20:	6422                	ld	s0,8(sp)
    80000d22:	0141                	addi	sp,sp,16
    80000d24:	8082                	ret
  return 0;
    80000d26:	4501                	li	a0,0
    80000d28:	bfe5                	j	80000d20 <memcmp+0x30>

0000000080000d2a <memmove>:

void*
memmove(void *dst, const void *src, uint n)
{
    80000d2a:	1141                	addi	sp,sp,-16
    80000d2c:	e422                	sd	s0,8(sp)
    80000d2e:	0800                	addi	s0,sp,16
  const char *s;
  char *d;

  if(n == 0)
    80000d30:	c205                	beqz	a2,80000d50 <memmove+0x26>
    return dst;
  
  s = src;
  d = dst;
  if(s < d && s + n > d){
    80000d32:	02a5e263          	bltu	a1,a0,80000d56 <memmove+0x2c>
    s += n;
    d += n;
    while(n-- > 0)
      *--d = *--s;
  } else
    while(n-- > 0)
    80000d36:	1602                	slli	a2,a2,0x20
    80000d38:	9201                	srli	a2,a2,0x20
    80000d3a:	00c587b3          	add	a5,a1,a2
{
    80000d3e:	872a                	mv	a4,a0
      *d++ = *s++;
    80000d40:	0585                	addi	a1,a1,1
    80000d42:	0705                	addi	a4,a4,1 # fffffffffffff001 <end+0xffffffff7ffdd2b1>
    80000d44:	fff5c683          	lbu	a3,-1(a1)
    80000d48:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
    80000d4c:	fef59ae3          	bne	a1,a5,80000d40 <memmove+0x16>

  return dst;
}
    80000d50:	6422                	ld	s0,8(sp)
    80000d52:	0141                	addi	sp,sp,16
    80000d54:	8082                	ret
  if(s < d && s + n > d){
    80000d56:	02061693          	slli	a3,a2,0x20
    80000d5a:	9281                	srli	a3,a3,0x20
    80000d5c:	00d58733          	add	a4,a1,a3
    80000d60:	fce57be3          	bgeu	a0,a4,80000d36 <memmove+0xc>
    d += n;
    80000d64:	96aa                	add	a3,a3,a0
    while(n-- > 0)
    80000d66:	fff6079b          	addiw	a5,a2,-1
    80000d6a:	1782                	slli	a5,a5,0x20
    80000d6c:	9381                	srli	a5,a5,0x20
    80000d6e:	fff7c793          	not	a5,a5
    80000d72:	97ba                	add	a5,a5,a4
      *--d = *--s;
    80000d74:	177d                	addi	a4,a4,-1
    80000d76:	16fd                	addi	a3,a3,-1
    80000d78:	00074603          	lbu	a2,0(a4)
    80000d7c:	00c68023          	sb	a2,0(a3)
    while(n-- > 0)
    80000d80:	fee79ae3          	bne	a5,a4,80000d74 <memmove+0x4a>
    80000d84:	b7f1                	j	80000d50 <memmove+0x26>

0000000080000d86 <memcpy>:

// memcpy exists to placate GCC.  Use memmove.
void*
memcpy(void *dst, const void *src, uint n)
{
    80000d86:	1141                	addi	sp,sp,-16
    80000d88:	e406                	sd	ra,8(sp)
    80000d8a:	e022                	sd	s0,0(sp)
    80000d8c:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
    80000d8e:	00000097          	auipc	ra,0x0
    80000d92:	f9c080e7          	jalr	-100(ra) # 80000d2a <memmove>
}
    80000d96:	60a2                	ld	ra,8(sp)
    80000d98:	6402                	ld	s0,0(sp)
    80000d9a:	0141                	addi	sp,sp,16
    80000d9c:	8082                	ret

0000000080000d9e <strncmp>:

int
strncmp(const char *p, const char *q, uint n)
{
    80000d9e:	1141                	addi	sp,sp,-16
    80000da0:	e422                	sd	s0,8(sp)
    80000da2:	0800                	addi	s0,sp,16
  while(n > 0 && *p && *p == *q)
    80000da4:	ce11                	beqz	a2,80000dc0 <strncmp+0x22>
    80000da6:	00054783          	lbu	a5,0(a0)
    80000daa:	cf89                	beqz	a5,80000dc4 <strncmp+0x26>
    80000dac:	0005c703          	lbu	a4,0(a1)
    80000db0:	00f71a63          	bne	a4,a5,80000dc4 <strncmp+0x26>
    n--, p++, q++;
    80000db4:	367d                	addiw	a2,a2,-1
    80000db6:	0505                	addi	a0,a0,1
    80000db8:	0585                	addi	a1,a1,1
  while(n > 0 && *p && *p == *q)
    80000dba:	f675                	bnez	a2,80000da6 <strncmp+0x8>
  if(n == 0)
    return 0;
    80000dbc:	4501                	li	a0,0
    80000dbe:	a809                	j	80000dd0 <strncmp+0x32>
    80000dc0:	4501                	li	a0,0
    80000dc2:	a039                	j	80000dd0 <strncmp+0x32>
  if(n == 0)
    80000dc4:	ca09                	beqz	a2,80000dd6 <strncmp+0x38>
  return (uchar)*p - (uchar)*q;
    80000dc6:	00054503          	lbu	a0,0(a0)
    80000dca:	0005c783          	lbu	a5,0(a1)
    80000dce:	9d1d                	subw	a0,a0,a5
}
    80000dd0:	6422                	ld	s0,8(sp)
    80000dd2:	0141                	addi	sp,sp,16
    80000dd4:	8082                	ret
    return 0;
    80000dd6:	4501                	li	a0,0
    80000dd8:	bfe5                	j	80000dd0 <strncmp+0x32>

0000000080000dda <strncpy>:

char*
strncpy(char *s, const char *t, int n)
{
    80000dda:	1141                	addi	sp,sp,-16
    80000ddc:	e422                	sd	s0,8(sp)
    80000dde:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while(n-- > 0 && (*s++ = *t++) != 0)
    80000de0:	87aa                	mv	a5,a0
    80000de2:	86b2                	mv	a3,a2
    80000de4:	367d                	addiw	a2,a2,-1
    80000de6:	00d05963          	blez	a3,80000df8 <strncpy+0x1e>
    80000dea:	0785                	addi	a5,a5,1
    80000dec:	0005c703          	lbu	a4,0(a1)
    80000df0:	fee78fa3          	sb	a4,-1(a5)
    80000df4:	0585                	addi	a1,a1,1
    80000df6:	f775                	bnez	a4,80000de2 <strncpy+0x8>
    ;
  while(n-- > 0)
    80000df8:	873e                	mv	a4,a5
    80000dfa:	9fb5                	addw	a5,a5,a3
    80000dfc:	37fd                	addiw	a5,a5,-1
    80000dfe:	00c05963          	blez	a2,80000e10 <strncpy+0x36>
    *s++ = 0;
    80000e02:	0705                	addi	a4,a4,1
    80000e04:	fe070fa3          	sb	zero,-1(a4)
  while(n-- > 0)
    80000e08:	40e786bb          	subw	a3,a5,a4
    80000e0c:	fed04be3          	bgtz	a3,80000e02 <strncpy+0x28>
  return os;
}
    80000e10:	6422                	ld	s0,8(sp)
    80000e12:	0141                	addi	sp,sp,16
    80000e14:	8082                	ret

0000000080000e16 <safestrcpy>:

// Like strncpy but guaranteed to NUL-terminate.
char*
safestrcpy(char *s, const char *t, int n)
{
    80000e16:	1141                	addi	sp,sp,-16
    80000e18:	e422                	sd	s0,8(sp)
    80000e1a:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  if(n <= 0)
    80000e1c:	02c05363          	blez	a2,80000e42 <safestrcpy+0x2c>
    80000e20:	fff6069b          	addiw	a3,a2,-1
    80000e24:	1682                	slli	a3,a3,0x20
    80000e26:	9281                	srli	a3,a3,0x20
    80000e28:	96ae                	add	a3,a3,a1
    80000e2a:	87aa                	mv	a5,a0
    return os;
  while(--n > 0 && (*s++ = *t++) != 0)
    80000e2c:	00d58963          	beq	a1,a3,80000e3e <safestrcpy+0x28>
    80000e30:	0585                	addi	a1,a1,1
    80000e32:	0785                	addi	a5,a5,1
    80000e34:	fff5c703          	lbu	a4,-1(a1)
    80000e38:	fee78fa3          	sb	a4,-1(a5)
    80000e3c:	fb65                	bnez	a4,80000e2c <safestrcpy+0x16>
    ;
  *s = 0;
    80000e3e:	00078023          	sb	zero,0(a5)
  return os;
}
    80000e42:	6422                	ld	s0,8(sp)
    80000e44:	0141                	addi	sp,sp,16
    80000e46:	8082                	ret

0000000080000e48 <strlen>:

int
strlen(const char *s)
{
    80000e48:	1141                	addi	sp,sp,-16
    80000e4a:	e422                	sd	s0,8(sp)
    80000e4c:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
    80000e4e:	00054783          	lbu	a5,0(a0)
    80000e52:	cf91                	beqz	a5,80000e6e <strlen+0x26>
    80000e54:	0505                	addi	a0,a0,1
    80000e56:	87aa                	mv	a5,a0
    80000e58:	86be                	mv	a3,a5
    80000e5a:	0785                	addi	a5,a5,1
    80000e5c:	fff7c703          	lbu	a4,-1(a5)
    80000e60:	ff65                	bnez	a4,80000e58 <strlen+0x10>
    80000e62:	40a6853b          	subw	a0,a3,a0
    80000e66:	2505                	addiw	a0,a0,1
    ;
  return n;
}
    80000e68:	6422                	ld	s0,8(sp)
    80000e6a:	0141                	addi	sp,sp,16
    80000e6c:	8082                	ret
  for(n = 0; s[n]; n++)
    80000e6e:	4501                	li	a0,0
    80000e70:	bfe5                	j	80000e68 <strlen+0x20>

0000000080000e72 <main>:
volatile static int started = 0;

// start() jumps here in supervisor mode on all CPUs.
void
main()
{
    80000e72:	1141                	addi	sp,sp,-16
    80000e74:	e406                	sd	ra,8(sp)
    80000e76:	e022                	sd	s0,0(sp)
    80000e78:	0800                	addi	s0,sp,16
  if(cpuid() == 0){
    80000e7a:	00001097          	auipc	ra,0x1
    80000e7e:	b00080e7          	jalr	-1280(ra) # 8000197a <cpuid>
    virtio_disk_init(); // emulated hard disk
    userinit();      // first user process
    __sync_synchronize();
    started = 1;
  } else {
    while(started == 0)
    80000e82:	00008717          	auipc	a4,0x8
    80000e86:	a3670713          	addi	a4,a4,-1482 # 800088b8 <started>
  if(cpuid() == 0){
    80000e8a:	c139                	beqz	a0,80000ed0 <main+0x5e>
    while(started == 0)
    80000e8c:	431c                	lw	a5,0(a4)
    80000e8e:	2781                	sext.w	a5,a5
    80000e90:	dff5                	beqz	a5,80000e8c <main+0x1a>
      ;
    __sync_synchronize();
    80000e92:	0ff0000f          	fence
    printf("hart %d starting\n", cpuid());
    80000e96:	00001097          	auipc	ra,0x1
    80000e9a:	ae4080e7          	jalr	-1308(ra) # 8000197a <cpuid>
    80000e9e:	85aa                	mv	a1,a0
    80000ea0:	00007517          	auipc	a0,0x7
    80000ea4:	21850513          	addi	a0,a0,536 # 800080b8 <digits+0x78>
    80000ea8:	fffff097          	auipc	ra,0xfffff
    80000eac:	6de080e7          	jalr	1758(ra) # 80000586 <printf>
    kvminithart();    // turn on paging
    80000eb0:	00000097          	auipc	ra,0x0
    80000eb4:	0d8080e7          	jalr	216(ra) # 80000f88 <kvminithart>
    trapinithart();   // install kernel trap vector
    80000eb8:	00001097          	auipc	ra,0x1
    80000ebc:	7d8080e7          	jalr	2008(ra) # 80002690 <trapinithart>
    plicinithart();   // ask PLIC for device interrupts
    80000ec0:	00005097          	auipc	ra,0x5
    80000ec4:	d20080e7          	jalr	-736(ra) # 80005be0 <plicinithart>
  }

  scheduler();        
    80000ec8:	00001097          	auipc	ra,0x1
    80000ecc:	020080e7          	jalr	32(ra) # 80001ee8 <scheduler>
    consoleinit();
    80000ed0:	fffff097          	auipc	ra,0xfffff
    80000ed4:	57c080e7          	jalr	1404(ra) # 8000044c <consoleinit>
    printfinit();
    80000ed8:	00000097          	auipc	ra,0x0
    80000edc:	88e080e7          	jalr	-1906(ra) # 80000766 <printfinit>
    printf("\n");
    80000ee0:	00007517          	auipc	a0,0x7
    80000ee4:	1e850513          	addi	a0,a0,488 # 800080c8 <digits+0x88>
    80000ee8:	fffff097          	auipc	ra,0xfffff
    80000eec:	69e080e7          	jalr	1694(ra) # 80000586 <printf>
    printf("xv6 kernel is booting\n");
    80000ef0:	00007517          	auipc	a0,0x7
    80000ef4:	1b050513          	addi	a0,a0,432 # 800080a0 <digits+0x60>
    80000ef8:	fffff097          	auipc	ra,0xfffff
    80000efc:	68e080e7          	jalr	1678(ra) # 80000586 <printf>
    printf("\n");
    80000f00:	00007517          	auipc	a0,0x7
    80000f04:	1c850513          	addi	a0,a0,456 # 800080c8 <digits+0x88>
    80000f08:	fffff097          	auipc	ra,0xfffff
    80000f0c:	67e080e7          	jalr	1662(ra) # 80000586 <printf>
    kinit();         // physical page allocator
    80000f10:	00000097          	auipc	ra,0x0
    80000f14:	b96080e7          	jalr	-1130(ra) # 80000aa6 <kinit>
    kvminit();       // create kernel page table
    80000f18:	00000097          	auipc	ra,0x0
    80000f1c:	326080e7          	jalr	806(ra) # 8000123e <kvminit>
    kvminithart();   // turn on paging
    80000f20:	00000097          	auipc	ra,0x0
    80000f24:	068080e7          	jalr	104(ra) # 80000f88 <kvminithart>
    procinit();      // process table
    80000f28:	00001097          	auipc	ra,0x1
    80000f2c:	99e080e7          	jalr	-1634(ra) # 800018c6 <procinit>
    trapinit();      // trap vectors
    80000f30:	00001097          	auipc	ra,0x1
    80000f34:	738080e7          	jalr	1848(ra) # 80002668 <trapinit>
    trapinithart();  // install kernel trap vector
    80000f38:	00001097          	auipc	ra,0x1
    80000f3c:	758080e7          	jalr	1880(ra) # 80002690 <trapinithart>
    plicinit();      // set up interrupt controller
    80000f40:	00005097          	auipc	ra,0x5
    80000f44:	c8a080e7          	jalr	-886(ra) # 80005bca <plicinit>
    plicinithart();  // ask PLIC for device interrupts
    80000f48:	00005097          	auipc	ra,0x5
    80000f4c:	c98080e7          	jalr	-872(ra) # 80005be0 <plicinithart>
    binit();         // buffer cache
    80000f50:	00002097          	auipc	ra,0x2
    80000f54:	e98080e7          	jalr	-360(ra) # 80002de8 <binit>
    iinit();         // inode table
    80000f58:	00002097          	auipc	ra,0x2
    80000f5c:	536080e7          	jalr	1334(ra) # 8000348e <iinit>
    fileinit();      // file table
    80000f60:	00003097          	auipc	ra,0x3
    80000f64:	4ac080e7          	jalr	1196(ra) # 8000440c <fileinit>
    virtio_disk_init(); // emulated hard disk
    80000f68:	00005097          	auipc	ra,0x5
    80000f6c:	d80080e7          	jalr	-640(ra) # 80005ce8 <virtio_disk_init>
    userinit();      // first user process
    80000f70:	00001097          	auipc	ra,0x1
    80000f74:	d5a080e7          	jalr	-678(ra) # 80001cca <userinit>
    __sync_synchronize();
    80000f78:	0ff0000f          	fence
    started = 1;
    80000f7c:	4785                	li	a5,1
    80000f7e:	00008717          	auipc	a4,0x8
    80000f82:	92f72d23          	sw	a5,-1734(a4) # 800088b8 <started>
    80000f86:	b789                	j	80000ec8 <main+0x56>

0000000080000f88 <kvminithart>:

// Switch h/w page table register to the kernel's page table,
// and enable paging.
void
kvminithart()
{
    80000f88:	1141                	addi	sp,sp,-16
    80000f8a:	e422                	sd	s0,8(sp)
    80000f8c:	0800                	addi	s0,sp,16
// flush the TLB.
static inline void
sfence_vma()
{
  // the zero, zero means flush all TLB entries.
  asm volatile("sfence.vma zero, zero");
    80000f8e:	12000073          	sfence.vma
  // wait for any previous writes to the page table memory to finish.
  sfence_vma();

  w_satp(MAKE_SATP(kernel_pagetable));
    80000f92:	00008797          	auipc	a5,0x8
    80000f96:	92e7b783          	ld	a5,-1746(a5) # 800088c0 <kernel_pagetable>
    80000f9a:	83b1                	srli	a5,a5,0xc
    80000f9c:	577d                	li	a4,-1
    80000f9e:	177e                	slli	a4,a4,0x3f
    80000fa0:	8fd9                	or	a5,a5,a4
  asm volatile("csrw satp, %0" : : "r" (x));
    80000fa2:	18079073          	csrw	satp,a5
  asm volatile("sfence.vma zero, zero");
    80000fa6:	12000073          	sfence.vma

  // flush stale entries from the TLB.
  sfence_vma();
}
    80000faa:	6422                	ld	s0,8(sp)
    80000fac:	0141                	addi	sp,sp,16
    80000fae:	8082                	ret

0000000080000fb0 <walk>:
//   21..29 -- 9 bits of level-1 index.
//   12..20 -- 9 bits of level-0 index.
//    0..11 -- 12 bits of byte offset within the page.
pte_t *
walk(pagetable_t pagetable, uint64 va, int alloc)
{
    80000fb0:	7139                	addi	sp,sp,-64
    80000fb2:	fc06                	sd	ra,56(sp)
    80000fb4:	f822                	sd	s0,48(sp)
    80000fb6:	f426                	sd	s1,40(sp)
    80000fb8:	f04a                	sd	s2,32(sp)
    80000fba:	ec4e                	sd	s3,24(sp)
    80000fbc:	e852                	sd	s4,16(sp)
    80000fbe:	e456                	sd	s5,8(sp)
    80000fc0:	e05a                	sd	s6,0(sp)
    80000fc2:	0080                	addi	s0,sp,64
    80000fc4:	84aa                	mv	s1,a0
    80000fc6:	89ae                	mv	s3,a1
    80000fc8:	8ab2                	mv	s5,a2
  if(va >= MAXVA)
    80000fca:	57fd                	li	a5,-1
    80000fcc:	83e9                	srli	a5,a5,0x1a
    80000fce:	4a79                	li	s4,30
    panic("walk");

  for(int level = 2; level > 0; level--) {
    80000fd0:	4b31                	li	s6,12
  if(va >= MAXVA)
    80000fd2:	04b7f263          	bgeu	a5,a1,80001016 <walk+0x66>
    panic("walk");
    80000fd6:	00007517          	auipc	a0,0x7
    80000fda:	0fa50513          	addi	a0,a0,250 # 800080d0 <digits+0x90>
    80000fde:	fffff097          	auipc	ra,0xfffff
    80000fe2:	55e080e7          	jalr	1374(ra) # 8000053c <panic>
    pte_t *pte = &pagetable[PX(level, va)];
    if(*pte & PTE_V) {
      pagetable = (pagetable_t)PTE2PA(*pte);
    } else {
      if(!alloc || (pagetable = (pde_t*)kalloc()) == 0)
    80000fe6:	060a8663          	beqz	s5,80001052 <walk+0xa2>
    80000fea:	00000097          	auipc	ra,0x0
    80000fee:	af8080e7          	jalr	-1288(ra) # 80000ae2 <kalloc>
    80000ff2:	84aa                	mv	s1,a0
    80000ff4:	c529                	beqz	a0,8000103e <walk+0x8e>
        return 0;
      memset(pagetable, 0, PGSIZE);
    80000ff6:	6605                	lui	a2,0x1
    80000ff8:	4581                	li	a1,0
    80000ffa:	00000097          	auipc	ra,0x0
    80000ffe:	cd4080e7          	jalr	-812(ra) # 80000cce <memset>
      *pte = PA2PTE(pagetable) | PTE_V;
    80001002:	00c4d793          	srli	a5,s1,0xc
    80001006:	07aa                	slli	a5,a5,0xa
    80001008:	0017e793          	ori	a5,a5,1
    8000100c:	00f93023          	sd	a5,0(s2)
  for(int level = 2; level > 0; level--) {
    80001010:	3a5d                	addiw	s4,s4,-9 # ffffffffffffeff7 <end+0xffffffff7ffdd2a7>
    80001012:	036a0063          	beq	s4,s6,80001032 <walk+0x82>
    pte_t *pte = &pagetable[PX(level, va)];
    80001016:	0149d933          	srl	s2,s3,s4
    8000101a:	1ff97913          	andi	s2,s2,511
    8000101e:	090e                	slli	s2,s2,0x3
    80001020:	9926                	add	s2,s2,s1
    if(*pte & PTE_V) {
    80001022:	00093483          	ld	s1,0(s2)
    80001026:	0014f793          	andi	a5,s1,1
    8000102a:	dfd5                	beqz	a5,80000fe6 <walk+0x36>
      pagetable = (pagetable_t)PTE2PA(*pte);
    8000102c:	80a9                	srli	s1,s1,0xa
    8000102e:	04b2                	slli	s1,s1,0xc
    80001030:	b7c5                	j	80001010 <walk+0x60>
    }
  }
  return &pagetable[PX(0, va)];
    80001032:	00c9d513          	srli	a0,s3,0xc
    80001036:	1ff57513          	andi	a0,a0,511
    8000103a:	050e                	slli	a0,a0,0x3
    8000103c:	9526                	add	a0,a0,s1
}
    8000103e:	70e2                	ld	ra,56(sp)
    80001040:	7442                	ld	s0,48(sp)
    80001042:	74a2                	ld	s1,40(sp)
    80001044:	7902                	ld	s2,32(sp)
    80001046:	69e2                	ld	s3,24(sp)
    80001048:	6a42                	ld	s4,16(sp)
    8000104a:	6aa2                	ld	s5,8(sp)
    8000104c:	6b02                	ld	s6,0(sp)
    8000104e:	6121                	addi	sp,sp,64
    80001050:	8082                	ret
        return 0;
    80001052:	4501                	li	a0,0
    80001054:	b7ed                	j	8000103e <walk+0x8e>

0000000080001056 <walkaddr>:
walkaddr(pagetable_t pagetable, uint64 va)
{
  pte_t *pte;
  uint64 pa;

  if(va >= MAXVA)
    80001056:	57fd                	li	a5,-1
    80001058:	83e9                	srli	a5,a5,0x1a
    8000105a:	00b7f463          	bgeu	a5,a1,80001062 <walkaddr+0xc>
    return 0;
    8000105e:	4501                	li	a0,0
    return 0;
  if((*pte & PTE_U) == 0)
    return 0;
  pa = PTE2PA(*pte);
  return pa;
}
    80001060:	8082                	ret
{
    80001062:	1141                	addi	sp,sp,-16
    80001064:	e406                	sd	ra,8(sp)
    80001066:	e022                	sd	s0,0(sp)
    80001068:	0800                	addi	s0,sp,16
  pte = walk(pagetable, va, 0);
    8000106a:	4601                	li	a2,0
    8000106c:	00000097          	auipc	ra,0x0
    80001070:	f44080e7          	jalr	-188(ra) # 80000fb0 <walk>
  if(pte == 0)
    80001074:	c105                	beqz	a0,80001094 <walkaddr+0x3e>
  if((*pte & PTE_V) == 0)
    80001076:	611c                	ld	a5,0(a0)
  if((*pte & PTE_U) == 0)
    80001078:	0117f693          	andi	a3,a5,17
    8000107c:	4745                	li	a4,17
    return 0;
    8000107e:	4501                	li	a0,0
  if((*pte & PTE_U) == 0)
    80001080:	00e68663          	beq	a3,a4,8000108c <walkaddr+0x36>
}
    80001084:	60a2                	ld	ra,8(sp)
    80001086:	6402                	ld	s0,0(sp)
    80001088:	0141                	addi	sp,sp,16
    8000108a:	8082                	ret
  pa = PTE2PA(*pte);
    8000108c:	83a9                	srli	a5,a5,0xa
    8000108e:	00c79513          	slli	a0,a5,0xc
  return pa;
    80001092:	bfcd                	j	80001084 <walkaddr+0x2e>
    return 0;
    80001094:	4501                	li	a0,0
    80001096:	b7fd                	j	80001084 <walkaddr+0x2e>

0000000080001098 <mappages>:
// physical addresses starting at pa. va and size might not
// be page-aligned. Returns 0 on success, -1 if walk() couldn't
// allocate a needed page-table page.
int
mappages(pagetable_t pagetable, uint64 va, uint64 size, uint64 pa, int perm)
{
    80001098:	715d                	addi	sp,sp,-80
    8000109a:	e486                	sd	ra,72(sp)
    8000109c:	e0a2                	sd	s0,64(sp)
    8000109e:	fc26                	sd	s1,56(sp)
    800010a0:	f84a                	sd	s2,48(sp)
    800010a2:	f44e                	sd	s3,40(sp)
    800010a4:	f052                	sd	s4,32(sp)
    800010a6:	ec56                	sd	s5,24(sp)
    800010a8:	e85a                	sd	s6,16(sp)
    800010aa:	e45e                	sd	s7,8(sp)
    800010ac:	0880                	addi	s0,sp,80
  uint64 a, last;
  pte_t *pte;

  if(size == 0)
    800010ae:	c639                	beqz	a2,800010fc <mappages+0x64>
    800010b0:	8aaa                	mv	s5,a0
    800010b2:	8b3a                	mv	s6,a4
    panic("mappages: size");
  
  a = PGROUNDDOWN(va);
    800010b4:	777d                	lui	a4,0xfffff
    800010b6:	00e5f7b3          	and	a5,a1,a4
  last = PGROUNDDOWN(va + size - 1);
    800010ba:	fff58993          	addi	s3,a1,-1
    800010be:	99b2                	add	s3,s3,a2
    800010c0:	00e9f9b3          	and	s3,s3,a4
  a = PGROUNDDOWN(va);
    800010c4:	893e                	mv	s2,a5
    800010c6:	40f68a33          	sub	s4,a3,a5
    if(*pte & PTE_V)
      panic("mappages: remap");
    *pte = PA2PTE(pa) | perm | PTE_V;
    if(a == last)
      break;
    a += PGSIZE;
    800010ca:	6b85                	lui	s7,0x1
    800010cc:	012a04b3          	add	s1,s4,s2
    if((pte = walk(pagetable, a, 1)) == 0)
    800010d0:	4605                	li	a2,1
    800010d2:	85ca                	mv	a1,s2
    800010d4:	8556                	mv	a0,s5
    800010d6:	00000097          	auipc	ra,0x0
    800010da:	eda080e7          	jalr	-294(ra) # 80000fb0 <walk>
    800010de:	cd1d                	beqz	a0,8000111c <mappages+0x84>
    if(*pte & PTE_V)
    800010e0:	611c                	ld	a5,0(a0)
    800010e2:	8b85                	andi	a5,a5,1
    800010e4:	e785                	bnez	a5,8000110c <mappages+0x74>
    *pte = PA2PTE(pa) | perm | PTE_V;
    800010e6:	80b1                	srli	s1,s1,0xc
    800010e8:	04aa                	slli	s1,s1,0xa
    800010ea:	0164e4b3          	or	s1,s1,s6
    800010ee:	0014e493          	ori	s1,s1,1
    800010f2:	e104                	sd	s1,0(a0)
    if(a == last)
    800010f4:	05390063          	beq	s2,s3,80001134 <mappages+0x9c>
    a += PGSIZE;
    800010f8:	995e                	add	s2,s2,s7
    if((pte = walk(pagetable, a, 1)) == 0)
    800010fa:	bfc9                	j	800010cc <mappages+0x34>
    panic("mappages: size");
    800010fc:	00007517          	auipc	a0,0x7
    80001100:	fdc50513          	addi	a0,a0,-36 # 800080d8 <digits+0x98>
    80001104:	fffff097          	auipc	ra,0xfffff
    80001108:	438080e7          	jalr	1080(ra) # 8000053c <panic>
      panic("mappages: remap");
    8000110c:	00007517          	auipc	a0,0x7
    80001110:	fdc50513          	addi	a0,a0,-36 # 800080e8 <digits+0xa8>
    80001114:	fffff097          	auipc	ra,0xfffff
    80001118:	428080e7          	jalr	1064(ra) # 8000053c <panic>
      return -1;
    8000111c:	557d                	li	a0,-1
    pa += PGSIZE;
  }
  return 0;
}
    8000111e:	60a6                	ld	ra,72(sp)
    80001120:	6406                	ld	s0,64(sp)
    80001122:	74e2                	ld	s1,56(sp)
    80001124:	7942                	ld	s2,48(sp)
    80001126:	79a2                	ld	s3,40(sp)
    80001128:	7a02                	ld	s4,32(sp)
    8000112a:	6ae2                	ld	s5,24(sp)
    8000112c:	6b42                	ld	s6,16(sp)
    8000112e:	6ba2                	ld	s7,8(sp)
    80001130:	6161                	addi	sp,sp,80
    80001132:	8082                	ret
  return 0;
    80001134:	4501                	li	a0,0
    80001136:	b7e5                	j	8000111e <mappages+0x86>

0000000080001138 <kvmmap>:
{
    80001138:	1141                	addi	sp,sp,-16
    8000113a:	e406                	sd	ra,8(sp)
    8000113c:	e022                	sd	s0,0(sp)
    8000113e:	0800                	addi	s0,sp,16
    80001140:	87b6                	mv	a5,a3
  if(mappages(kpgtbl, va, sz, pa, perm) != 0)
    80001142:	86b2                	mv	a3,a2
    80001144:	863e                	mv	a2,a5
    80001146:	00000097          	auipc	ra,0x0
    8000114a:	f52080e7          	jalr	-174(ra) # 80001098 <mappages>
    8000114e:	e509                	bnez	a0,80001158 <kvmmap+0x20>
}
    80001150:	60a2                	ld	ra,8(sp)
    80001152:	6402                	ld	s0,0(sp)
    80001154:	0141                	addi	sp,sp,16
    80001156:	8082                	ret
    panic("kvmmap");
    80001158:	00007517          	auipc	a0,0x7
    8000115c:	fa050513          	addi	a0,a0,-96 # 800080f8 <digits+0xb8>
    80001160:	fffff097          	auipc	ra,0xfffff
    80001164:	3dc080e7          	jalr	988(ra) # 8000053c <panic>

0000000080001168 <kvmmake>:
{
    80001168:	1101                	addi	sp,sp,-32
    8000116a:	ec06                	sd	ra,24(sp)
    8000116c:	e822                	sd	s0,16(sp)
    8000116e:	e426                	sd	s1,8(sp)
    80001170:	e04a                	sd	s2,0(sp)
    80001172:	1000                	addi	s0,sp,32
  kpgtbl = (pagetable_t) kalloc();
    80001174:	00000097          	auipc	ra,0x0
    80001178:	96e080e7          	jalr	-1682(ra) # 80000ae2 <kalloc>
    8000117c:	84aa                	mv	s1,a0
  memset(kpgtbl, 0, PGSIZE);
    8000117e:	6605                	lui	a2,0x1
    80001180:	4581                	li	a1,0
    80001182:	00000097          	auipc	ra,0x0
    80001186:	b4c080e7          	jalr	-1204(ra) # 80000cce <memset>
  kvmmap(kpgtbl, UART0, UART0, PGSIZE, PTE_R | PTE_W);
    8000118a:	4719                	li	a4,6
    8000118c:	6685                	lui	a3,0x1
    8000118e:	10000637          	lui	a2,0x10000
    80001192:	100005b7          	lui	a1,0x10000
    80001196:	8526                	mv	a0,s1
    80001198:	00000097          	auipc	ra,0x0
    8000119c:	fa0080e7          	jalr	-96(ra) # 80001138 <kvmmap>
  kvmmap(kpgtbl, VIRTIO0, VIRTIO0, PGSIZE, PTE_R | PTE_W);
    800011a0:	4719                	li	a4,6
    800011a2:	6685                	lui	a3,0x1
    800011a4:	10001637          	lui	a2,0x10001
    800011a8:	100015b7          	lui	a1,0x10001
    800011ac:	8526                	mv	a0,s1
    800011ae:	00000097          	auipc	ra,0x0
    800011b2:	f8a080e7          	jalr	-118(ra) # 80001138 <kvmmap>
  kvmmap(kpgtbl, PLIC, PLIC, 0x400000, PTE_R | PTE_W);
    800011b6:	4719                	li	a4,6
    800011b8:	004006b7          	lui	a3,0x400
    800011bc:	0c000637          	lui	a2,0xc000
    800011c0:	0c0005b7          	lui	a1,0xc000
    800011c4:	8526                	mv	a0,s1
    800011c6:	00000097          	auipc	ra,0x0
    800011ca:	f72080e7          	jalr	-142(ra) # 80001138 <kvmmap>
  kvmmap(kpgtbl, KERNBASE, KERNBASE, (uint64)etext-KERNBASE, PTE_R | PTE_X);
    800011ce:	00007917          	auipc	s2,0x7
    800011d2:	e3290913          	addi	s2,s2,-462 # 80008000 <etext>
    800011d6:	4729                	li	a4,10
    800011d8:	80007697          	auipc	a3,0x80007
    800011dc:	e2868693          	addi	a3,a3,-472 # 8000 <_entry-0x7fff8000>
    800011e0:	4605                	li	a2,1
    800011e2:	067e                	slli	a2,a2,0x1f
    800011e4:	85b2                	mv	a1,a2
    800011e6:	8526                	mv	a0,s1
    800011e8:	00000097          	auipc	ra,0x0
    800011ec:	f50080e7          	jalr	-176(ra) # 80001138 <kvmmap>
  kvmmap(kpgtbl, (uint64)etext, (uint64)etext, PHYSTOP-(uint64)etext, PTE_R | PTE_W);
    800011f0:	4719                	li	a4,6
    800011f2:	46c5                	li	a3,17
    800011f4:	06ee                	slli	a3,a3,0x1b
    800011f6:	412686b3          	sub	a3,a3,s2
    800011fa:	864a                	mv	a2,s2
    800011fc:	85ca                	mv	a1,s2
    800011fe:	8526                	mv	a0,s1
    80001200:	00000097          	auipc	ra,0x0
    80001204:	f38080e7          	jalr	-200(ra) # 80001138 <kvmmap>
  kvmmap(kpgtbl, TRAMPOLINE, (uint64)trampoline, PGSIZE, PTE_R | PTE_X);
    80001208:	4729                	li	a4,10
    8000120a:	6685                	lui	a3,0x1
    8000120c:	00006617          	auipc	a2,0x6
    80001210:	df460613          	addi	a2,a2,-524 # 80007000 <_trampoline>
    80001214:	040005b7          	lui	a1,0x4000
    80001218:	15fd                	addi	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    8000121a:	05b2                	slli	a1,a1,0xc
    8000121c:	8526                	mv	a0,s1
    8000121e:	00000097          	auipc	ra,0x0
    80001222:	f1a080e7          	jalr	-230(ra) # 80001138 <kvmmap>
  proc_mapstacks(kpgtbl);
    80001226:	8526                	mv	a0,s1
    80001228:	00000097          	auipc	ra,0x0
    8000122c:	608080e7          	jalr	1544(ra) # 80001830 <proc_mapstacks>
}
    80001230:	8526                	mv	a0,s1
    80001232:	60e2                	ld	ra,24(sp)
    80001234:	6442                	ld	s0,16(sp)
    80001236:	64a2                	ld	s1,8(sp)
    80001238:	6902                	ld	s2,0(sp)
    8000123a:	6105                	addi	sp,sp,32
    8000123c:	8082                	ret

000000008000123e <kvminit>:
{
    8000123e:	1141                	addi	sp,sp,-16
    80001240:	e406                	sd	ra,8(sp)
    80001242:	e022                	sd	s0,0(sp)
    80001244:	0800                	addi	s0,sp,16
  kernel_pagetable = kvmmake();
    80001246:	00000097          	auipc	ra,0x0
    8000124a:	f22080e7          	jalr	-222(ra) # 80001168 <kvmmake>
    8000124e:	00007797          	auipc	a5,0x7
    80001252:	66a7b923          	sd	a0,1650(a5) # 800088c0 <kernel_pagetable>
}
    80001256:	60a2                	ld	ra,8(sp)
    80001258:	6402                	ld	s0,0(sp)
    8000125a:	0141                	addi	sp,sp,16
    8000125c:	8082                	ret

000000008000125e <uvmunmap>:
// Remove npages of mappings starting from va. va must be
// page-aligned. The mappings must exist.
// Optionally free the physical memory.
void
uvmunmap(pagetable_t pagetable, uint64 va, uint64 npages, int do_free)
{
    8000125e:	715d                	addi	sp,sp,-80
    80001260:	e486                	sd	ra,72(sp)
    80001262:	e0a2                	sd	s0,64(sp)
    80001264:	fc26                	sd	s1,56(sp)
    80001266:	f84a                	sd	s2,48(sp)
    80001268:	f44e                	sd	s3,40(sp)
    8000126a:	f052                	sd	s4,32(sp)
    8000126c:	ec56                	sd	s5,24(sp)
    8000126e:	e85a                	sd	s6,16(sp)
    80001270:	e45e                	sd	s7,8(sp)
    80001272:	0880                	addi	s0,sp,80
  uint64 a;
  pte_t *pte;

  if((va % PGSIZE) != 0)
    80001274:	03459793          	slli	a5,a1,0x34
    80001278:	e795                	bnez	a5,800012a4 <uvmunmap+0x46>
    8000127a:	8a2a                	mv	s4,a0
    8000127c:	892e                	mv	s2,a1
    8000127e:	8ab6                	mv	s5,a3
    panic("uvmunmap: not aligned");

  for(a = va; a < va + npages*PGSIZE; a += PGSIZE){
    80001280:	0632                	slli	a2,a2,0xc
    80001282:	00b609b3          	add	s3,a2,a1
    if((pte = walk(pagetable, a, 0)) == 0)
      panic("uvmunmap: walk");
    if((*pte & PTE_V) == 0)
      panic("uvmunmap: not mapped");
    if(PTE_FLAGS(*pte) == PTE_V)
    80001286:	4b85                	li	s7,1
  for(a = va; a < va + npages*PGSIZE; a += PGSIZE){
    80001288:	6b05                	lui	s6,0x1
    8000128a:	0735e263          	bltu	a1,s3,800012ee <uvmunmap+0x90>
      uint64 pa = PTE2PA(*pte);
      kfree((void*)pa);
    }
    *pte = 0;
  }
}
    8000128e:	60a6                	ld	ra,72(sp)
    80001290:	6406                	ld	s0,64(sp)
    80001292:	74e2                	ld	s1,56(sp)
    80001294:	7942                	ld	s2,48(sp)
    80001296:	79a2                	ld	s3,40(sp)
    80001298:	7a02                	ld	s4,32(sp)
    8000129a:	6ae2                	ld	s5,24(sp)
    8000129c:	6b42                	ld	s6,16(sp)
    8000129e:	6ba2                	ld	s7,8(sp)
    800012a0:	6161                	addi	sp,sp,80
    800012a2:	8082                	ret
    panic("uvmunmap: not aligned");
    800012a4:	00007517          	auipc	a0,0x7
    800012a8:	e5c50513          	addi	a0,a0,-420 # 80008100 <digits+0xc0>
    800012ac:	fffff097          	auipc	ra,0xfffff
    800012b0:	290080e7          	jalr	656(ra) # 8000053c <panic>
      panic("uvmunmap: walk");
    800012b4:	00007517          	auipc	a0,0x7
    800012b8:	e6450513          	addi	a0,a0,-412 # 80008118 <digits+0xd8>
    800012bc:	fffff097          	auipc	ra,0xfffff
    800012c0:	280080e7          	jalr	640(ra) # 8000053c <panic>
      panic("uvmunmap: not mapped");
    800012c4:	00007517          	auipc	a0,0x7
    800012c8:	e6450513          	addi	a0,a0,-412 # 80008128 <digits+0xe8>
    800012cc:	fffff097          	auipc	ra,0xfffff
    800012d0:	270080e7          	jalr	624(ra) # 8000053c <panic>
      panic("uvmunmap: not a leaf");
    800012d4:	00007517          	auipc	a0,0x7
    800012d8:	e6c50513          	addi	a0,a0,-404 # 80008140 <digits+0x100>
    800012dc:	fffff097          	auipc	ra,0xfffff
    800012e0:	260080e7          	jalr	608(ra) # 8000053c <panic>
    *pte = 0;
    800012e4:	0004b023          	sd	zero,0(s1)
  for(a = va; a < va + npages*PGSIZE; a += PGSIZE){
    800012e8:	995a                	add	s2,s2,s6
    800012ea:	fb3972e3          	bgeu	s2,s3,8000128e <uvmunmap+0x30>
    if((pte = walk(pagetable, a, 0)) == 0)
    800012ee:	4601                	li	a2,0
    800012f0:	85ca                	mv	a1,s2
    800012f2:	8552                	mv	a0,s4
    800012f4:	00000097          	auipc	ra,0x0
    800012f8:	cbc080e7          	jalr	-836(ra) # 80000fb0 <walk>
    800012fc:	84aa                	mv	s1,a0
    800012fe:	d95d                	beqz	a0,800012b4 <uvmunmap+0x56>
    if((*pte & PTE_V) == 0)
    80001300:	6108                	ld	a0,0(a0)
    80001302:	00157793          	andi	a5,a0,1
    80001306:	dfdd                	beqz	a5,800012c4 <uvmunmap+0x66>
    if(PTE_FLAGS(*pte) == PTE_V)
    80001308:	3ff57793          	andi	a5,a0,1023
    8000130c:	fd7784e3          	beq	a5,s7,800012d4 <uvmunmap+0x76>
    if(do_free){
    80001310:	fc0a8ae3          	beqz	s5,800012e4 <uvmunmap+0x86>
      uint64 pa = PTE2PA(*pte);
    80001314:	8129                	srli	a0,a0,0xa
      kfree((void*)pa);
    80001316:	0532                	slli	a0,a0,0xc
    80001318:	fffff097          	auipc	ra,0xfffff
    8000131c:	6cc080e7          	jalr	1740(ra) # 800009e4 <kfree>
    80001320:	b7d1                	j	800012e4 <uvmunmap+0x86>

0000000080001322 <uvmcreate>:

// create an empty user page table.
// returns 0 if out of memory.
pagetable_t
uvmcreate()
{
    80001322:	1101                	addi	sp,sp,-32
    80001324:	ec06                	sd	ra,24(sp)
    80001326:	e822                	sd	s0,16(sp)
    80001328:	e426                	sd	s1,8(sp)
    8000132a:	1000                	addi	s0,sp,32
  pagetable_t pagetable;
  pagetable = (pagetable_t) kalloc();
    8000132c:	fffff097          	auipc	ra,0xfffff
    80001330:	7b6080e7          	jalr	1974(ra) # 80000ae2 <kalloc>
    80001334:	84aa                	mv	s1,a0
  if(pagetable == 0)
    80001336:	c519                	beqz	a0,80001344 <uvmcreate+0x22>
    return 0;
  memset(pagetable, 0, PGSIZE);
    80001338:	6605                	lui	a2,0x1
    8000133a:	4581                	li	a1,0
    8000133c:	00000097          	auipc	ra,0x0
    80001340:	992080e7          	jalr	-1646(ra) # 80000cce <memset>
  return pagetable;
}
    80001344:	8526                	mv	a0,s1
    80001346:	60e2                	ld	ra,24(sp)
    80001348:	6442                	ld	s0,16(sp)
    8000134a:	64a2                	ld	s1,8(sp)
    8000134c:	6105                	addi	sp,sp,32
    8000134e:	8082                	ret

0000000080001350 <uvmfirst>:
// Load the user initcode into address 0 of pagetable,
// for the very first process.
// sz must be less than a page.
void
uvmfirst(pagetable_t pagetable, uchar *src, uint sz)
{
    80001350:	7179                	addi	sp,sp,-48
    80001352:	f406                	sd	ra,40(sp)
    80001354:	f022                	sd	s0,32(sp)
    80001356:	ec26                	sd	s1,24(sp)
    80001358:	e84a                	sd	s2,16(sp)
    8000135a:	e44e                	sd	s3,8(sp)
    8000135c:	e052                	sd	s4,0(sp)
    8000135e:	1800                	addi	s0,sp,48
  char *mem;

  if(sz >= PGSIZE)
    80001360:	6785                	lui	a5,0x1
    80001362:	04f67863          	bgeu	a2,a5,800013b2 <uvmfirst+0x62>
    80001366:	8a2a                	mv	s4,a0
    80001368:	89ae                	mv	s3,a1
    8000136a:	84b2                	mv	s1,a2
    panic("uvmfirst: more than a page");
  mem = kalloc();
    8000136c:	fffff097          	auipc	ra,0xfffff
    80001370:	776080e7          	jalr	1910(ra) # 80000ae2 <kalloc>
    80001374:	892a                	mv	s2,a0
  memset(mem, 0, PGSIZE);
    80001376:	6605                	lui	a2,0x1
    80001378:	4581                	li	a1,0
    8000137a:	00000097          	auipc	ra,0x0
    8000137e:	954080e7          	jalr	-1708(ra) # 80000cce <memset>
  mappages(pagetable, 0, PGSIZE, (uint64)mem, PTE_W|PTE_R|PTE_X|PTE_U);
    80001382:	4779                	li	a4,30
    80001384:	86ca                	mv	a3,s2
    80001386:	6605                	lui	a2,0x1
    80001388:	4581                	li	a1,0
    8000138a:	8552                	mv	a0,s4
    8000138c:	00000097          	auipc	ra,0x0
    80001390:	d0c080e7          	jalr	-756(ra) # 80001098 <mappages>
  memmove(mem, src, sz);
    80001394:	8626                	mv	a2,s1
    80001396:	85ce                	mv	a1,s3
    80001398:	854a                	mv	a0,s2
    8000139a:	00000097          	auipc	ra,0x0
    8000139e:	990080e7          	jalr	-1648(ra) # 80000d2a <memmove>
}
    800013a2:	70a2                	ld	ra,40(sp)
    800013a4:	7402                	ld	s0,32(sp)
    800013a6:	64e2                	ld	s1,24(sp)
    800013a8:	6942                	ld	s2,16(sp)
    800013aa:	69a2                	ld	s3,8(sp)
    800013ac:	6a02                	ld	s4,0(sp)
    800013ae:	6145                	addi	sp,sp,48
    800013b0:	8082                	ret
    panic("uvmfirst: more than a page");
    800013b2:	00007517          	auipc	a0,0x7
    800013b6:	da650513          	addi	a0,a0,-602 # 80008158 <digits+0x118>
    800013ba:	fffff097          	auipc	ra,0xfffff
    800013be:	182080e7          	jalr	386(ra) # 8000053c <panic>

00000000800013c2 <uvmdealloc>:
// newsz.  oldsz and newsz need not be page-aligned, nor does newsz
// need to be less than oldsz.  oldsz can be larger than the actual
// process size.  Returns the new process size.
uint64
uvmdealloc(pagetable_t pagetable, uint64 oldsz, uint64 newsz)
{
    800013c2:	1101                	addi	sp,sp,-32
    800013c4:	ec06                	sd	ra,24(sp)
    800013c6:	e822                	sd	s0,16(sp)
    800013c8:	e426                	sd	s1,8(sp)
    800013ca:	1000                	addi	s0,sp,32
  if(newsz >= oldsz)
    return oldsz;
    800013cc:	84ae                	mv	s1,a1
  if(newsz >= oldsz)
    800013ce:	00b67d63          	bgeu	a2,a1,800013e8 <uvmdealloc+0x26>
    800013d2:	84b2                	mv	s1,a2

  if(PGROUNDUP(newsz) < PGROUNDUP(oldsz)){
    800013d4:	6785                	lui	a5,0x1
    800013d6:	17fd                	addi	a5,a5,-1 # fff <_entry-0x7ffff001>
    800013d8:	00f60733          	add	a4,a2,a5
    800013dc:	76fd                	lui	a3,0xfffff
    800013de:	8f75                	and	a4,a4,a3
    800013e0:	97ae                	add	a5,a5,a1
    800013e2:	8ff5                	and	a5,a5,a3
    800013e4:	00f76863          	bltu	a4,a5,800013f4 <uvmdealloc+0x32>
    int npages = (PGROUNDUP(oldsz) - PGROUNDUP(newsz)) / PGSIZE;
    uvmunmap(pagetable, PGROUNDUP(newsz), npages, 1);
  }

  return newsz;
}
    800013e8:	8526                	mv	a0,s1
    800013ea:	60e2                	ld	ra,24(sp)
    800013ec:	6442                	ld	s0,16(sp)
    800013ee:	64a2                	ld	s1,8(sp)
    800013f0:	6105                	addi	sp,sp,32
    800013f2:	8082                	ret
    int npages = (PGROUNDUP(oldsz) - PGROUNDUP(newsz)) / PGSIZE;
    800013f4:	8f99                	sub	a5,a5,a4
    800013f6:	83b1                	srli	a5,a5,0xc
    uvmunmap(pagetable, PGROUNDUP(newsz), npages, 1);
    800013f8:	4685                	li	a3,1
    800013fa:	0007861b          	sext.w	a2,a5
    800013fe:	85ba                	mv	a1,a4
    80001400:	00000097          	auipc	ra,0x0
    80001404:	e5e080e7          	jalr	-418(ra) # 8000125e <uvmunmap>
    80001408:	b7c5                	j	800013e8 <uvmdealloc+0x26>

000000008000140a <uvmalloc>:
  if(newsz < oldsz)
    8000140a:	0ab66563          	bltu	a2,a1,800014b4 <uvmalloc+0xaa>
{
    8000140e:	7139                	addi	sp,sp,-64
    80001410:	fc06                	sd	ra,56(sp)
    80001412:	f822                	sd	s0,48(sp)
    80001414:	f426                	sd	s1,40(sp)
    80001416:	f04a                	sd	s2,32(sp)
    80001418:	ec4e                	sd	s3,24(sp)
    8000141a:	e852                	sd	s4,16(sp)
    8000141c:	e456                	sd	s5,8(sp)
    8000141e:	e05a                	sd	s6,0(sp)
    80001420:	0080                	addi	s0,sp,64
    80001422:	8aaa                	mv	s5,a0
    80001424:	8a32                	mv	s4,a2
  oldsz = PGROUNDUP(oldsz);
    80001426:	6785                	lui	a5,0x1
    80001428:	17fd                	addi	a5,a5,-1 # fff <_entry-0x7ffff001>
    8000142a:	95be                	add	a1,a1,a5
    8000142c:	77fd                	lui	a5,0xfffff
    8000142e:	00f5f9b3          	and	s3,a1,a5
  for(a = oldsz; a < newsz; a += PGSIZE){
    80001432:	08c9f363          	bgeu	s3,a2,800014b8 <uvmalloc+0xae>
    80001436:	894e                	mv	s2,s3
    if(mappages(pagetable, a, PGSIZE, (uint64)mem, PTE_R|PTE_U|xperm) != 0){
    80001438:	0126eb13          	ori	s6,a3,18
    mem = kalloc();
    8000143c:	fffff097          	auipc	ra,0xfffff
    80001440:	6a6080e7          	jalr	1702(ra) # 80000ae2 <kalloc>
    80001444:	84aa                	mv	s1,a0
    if(mem == 0){
    80001446:	c51d                	beqz	a0,80001474 <uvmalloc+0x6a>
    memset(mem, 0, PGSIZE);
    80001448:	6605                	lui	a2,0x1
    8000144a:	4581                	li	a1,0
    8000144c:	00000097          	auipc	ra,0x0
    80001450:	882080e7          	jalr	-1918(ra) # 80000cce <memset>
    if(mappages(pagetable, a, PGSIZE, (uint64)mem, PTE_R|PTE_U|xperm) != 0){
    80001454:	875a                	mv	a4,s6
    80001456:	86a6                	mv	a3,s1
    80001458:	6605                	lui	a2,0x1
    8000145a:	85ca                	mv	a1,s2
    8000145c:	8556                	mv	a0,s5
    8000145e:	00000097          	auipc	ra,0x0
    80001462:	c3a080e7          	jalr	-966(ra) # 80001098 <mappages>
    80001466:	e90d                	bnez	a0,80001498 <uvmalloc+0x8e>
  for(a = oldsz; a < newsz; a += PGSIZE){
    80001468:	6785                	lui	a5,0x1
    8000146a:	993e                	add	s2,s2,a5
    8000146c:	fd4968e3          	bltu	s2,s4,8000143c <uvmalloc+0x32>
  return newsz;
    80001470:	8552                	mv	a0,s4
    80001472:	a809                	j	80001484 <uvmalloc+0x7a>
      uvmdealloc(pagetable, a, oldsz);
    80001474:	864e                	mv	a2,s3
    80001476:	85ca                	mv	a1,s2
    80001478:	8556                	mv	a0,s5
    8000147a:	00000097          	auipc	ra,0x0
    8000147e:	f48080e7          	jalr	-184(ra) # 800013c2 <uvmdealloc>
      return 0;
    80001482:	4501                	li	a0,0
}
    80001484:	70e2                	ld	ra,56(sp)
    80001486:	7442                	ld	s0,48(sp)
    80001488:	74a2                	ld	s1,40(sp)
    8000148a:	7902                	ld	s2,32(sp)
    8000148c:	69e2                	ld	s3,24(sp)
    8000148e:	6a42                	ld	s4,16(sp)
    80001490:	6aa2                	ld	s5,8(sp)
    80001492:	6b02                	ld	s6,0(sp)
    80001494:	6121                	addi	sp,sp,64
    80001496:	8082                	ret
      kfree(mem);
    80001498:	8526                	mv	a0,s1
    8000149a:	fffff097          	auipc	ra,0xfffff
    8000149e:	54a080e7          	jalr	1354(ra) # 800009e4 <kfree>
      uvmdealloc(pagetable, a, oldsz);
    800014a2:	864e                	mv	a2,s3
    800014a4:	85ca                	mv	a1,s2
    800014a6:	8556                	mv	a0,s5
    800014a8:	00000097          	auipc	ra,0x0
    800014ac:	f1a080e7          	jalr	-230(ra) # 800013c2 <uvmdealloc>
      return 0;
    800014b0:	4501                	li	a0,0
    800014b2:	bfc9                	j	80001484 <uvmalloc+0x7a>
    return oldsz;
    800014b4:	852e                	mv	a0,a1
}
    800014b6:	8082                	ret
  return newsz;
    800014b8:	8532                	mv	a0,a2
    800014ba:	b7e9                	j	80001484 <uvmalloc+0x7a>

00000000800014bc <freewalk>:

// Recursively free page-table pages.
// All leaf mappings must already have been removed.
void
freewalk(pagetable_t pagetable)
{
    800014bc:	7179                	addi	sp,sp,-48
    800014be:	f406                	sd	ra,40(sp)
    800014c0:	f022                	sd	s0,32(sp)
    800014c2:	ec26                	sd	s1,24(sp)
    800014c4:	e84a                	sd	s2,16(sp)
    800014c6:	e44e                	sd	s3,8(sp)
    800014c8:	e052                	sd	s4,0(sp)
    800014ca:	1800                	addi	s0,sp,48
    800014cc:	8a2a                	mv	s4,a0
  // there are 2^9 = 512 PTEs in a page table.
  for(int i = 0; i < 512; i++){
    800014ce:	84aa                	mv	s1,a0
    800014d0:	6905                	lui	s2,0x1
    800014d2:	992a                	add	s2,s2,a0
    pte_t pte = pagetable[i];
    if((pte & PTE_V) && (pte & (PTE_R|PTE_W|PTE_X)) == 0){
    800014d4:	4985                	li	s3,1
    800014d6:	a829                	j	800014f0 <freewalk+0x34>
      // this PTE points to a lower-level page table.
      uint64 child = PTE2PA(pte);
    800014d8:	83a9                	srli	a5,a5,0xa
      freewalk((pagetable_t)child);
    800014da:	00c79513          	slli	a0,a5,0xc
    800014de:	00000097          	auipc	ra,0x0
    800014e2:	fde080e7          	jalr	-34(ra) # 800014bc <freewalk>
      pagetable[i] = 0;
    800014e6:	0004b023          	sd	zero,0(s1)
  for(int i = 0; i < 512; i++){
    800014ea:	04a1                	addi	s1,s1,8
    800014ec:	03248163          	beq	s1,s2,8000150e <freewalk+0x52>
    pte_t pte = pagetable[i];
    800014f0:	609c                	ld	a5,0(s1)
    if((pte & PTE_V) && (pte & (PTE_R|PTE_W|PTE_X)) == 0){
    800014f2:	00f7f713          	andi	a4,a5,15
    800014f6:	ff3701e3          	beq	a4,s3,800014d8 <freewalk+0x1c>
    } else if(pte & PTE_V){
    800014fa:	8b85                	andi	a5,a5,1
    800014fc:	d7fd                	beqz	a5,800014ea <freewalk+0x2e>
      panic("freewalk: leaf");
    800014fe:	00007517          	auipc	a0,0x7
    80001502:	c7a50513          	addi	a0,a0,-902 # 80008178 <digits+0x138>
    80001506:	fffff097          	auipc	ra,0xfffff
    8000150a:	036080e7          	jalr	54(ra) # 8000053c <panic>
    }
  }
  kfree((void*)pagetable);
    8000150e:	8552                	mv	a0,s4
    80001510:	fffff097          	auipc	ra,0xfffff
    80001514:	4d4080e7          	jalr	1236(ra) # 800009e4 <kfree>
}
    80001518:	70a2                	ld	ra,40(sp)
    8000151a:	7402                	ld	s0,32(sp)
    8000151c:	64e2                	ld	s1,24(sp)
    8000151e:	6942                	ld	s2,16(sp)
    80001520:	69a2                	ld	s3,8(sp)
    80001522:	6a02                	ld	s4,0(sp)
    80001524:	6145                	addi	sp,sp,48
    80001526:	8082                	ret

0000000080001528 <uvmfree>:

// Free user memory pages,
// then free page-table pages.
void
uvmfree(pagetable_t pagetable, uint64 sz)
{
    80001528:	1101                	addi	sp,sp,-32
    8000152a:	ec06                	sd	ra,24(sp)
    8000152c:	e822                	sd	s0,16(sp)
    8000152e:	e426                	sd	s1,8(sp)
    80001530:	1000                	addi	s0,sp,32
    80001532:	84aa                	mv	s1,a0
  if(sz > 0)
    80001534:	e999                	bnez	a1,8000154a <uvmfree+0x22>
    uvmunmap(pagetable, 0, PGROUNDUP(sz)/PGSIZE, 1);
  freewalk(pagetable);
    80001536:	8526                	mv	a0,s1
    80001538:	00000097          	auipc	ra,0x0
    8000153c:	f84080e7          	jalr	-124(ra) # 800014bc <freewalk>
}
    80001540:	60e2                	ld	ra,24(sp)
    80001542:	6442                	ld	s0,16(sp)
    80001544:	64a2                	ld	s1,8(sp)
    80001546:	6105                	addi	sp,sp,32
    80001548:	8082                	ret
    uvmunmap(pagetable, 0, PGROUNDUP(sz)/PGSIZE, 1);
    8000154a:	6785                	lui	a5,0x1
    8000154c:	17fd                	addi	a5,a5,-1 # fff <_entry-0x7ffff001>
    8000154e:	95be                	add	a1,a1,a5
    80001550:	4685                	li	a3,1
    80001552:	00c5d613          	srli	a2,a1,0xc
    80001556:	4581                	li	a1,0
    80001558:	00000097          	auipc	ra,0x0
    8000155c:	d06080e7          	jalr	-762(ra) # 8000125e <uvmunmap>
    80001560:	bfd9                	j	80001536 <uvmfree+0xe>

0000000080001562 <uvmcopy>:
  pte_t *pte;
  uint64 pa, i;
  uint flags;
  char *mem;

  for(i = 0; i < sz; i += PGSIZE){
    80001562:	c679                	beqz	a2,80001630 <uvmcopy+0xce>
{
    80001564:	715d                	addi	sp,sp,-80
    80001566:	e486                	sd	ra,72(sp)
    80001568:	e0a2                	sd	s0,64(sp)
    8000156a:	fc26                	sd	s1,56(sp)
    8000156c:	f84a                	sd	s2,48(sp)
    8000156e:	f44e                	sd	s3,40(sp)
    80001570:	f052                	sd	s4,32(sp)
    80001572:	ec56                	sd	s5,24(sp)
    80001574:	e85a                	sd	s6,16(sp)
    80001576:	e45e                	sd	s7,8(sp)
    80001578:	0880                	addi	s0,sp,80
    8000157a:	8b2a                	mv	s6,a0
    8000157c:	8aae                	mv	s5,a1
    8000157e:	8a32                	mv	s4,a2
  for(i = 0; i < sz; i += PGSIZE){
    80001580:	4981                	li	s3,0
    if((pte = walk(old, i, 0)) == 0)
    80001582:	4601                	li	a2,0
    80001584:	85ce                	mv	a1,s3
    80001586:	855a                	mv	a0,s6
    80001588:	00000097          	auipc	ra,0x0
    8000158c:	a28080e7          	jalr	-1496(ra) # 80000fb0 <walk>
    80001590:	c531                	beqz	a0,800015dc <uvmcopy+0x7a>
      panic("uvmcopy: pte should exist");
    if((*pte & PTE_V) == 0)
    80001592:	6118                	ld	a4,0(a0)
    80001594:	00177793          	andi	a5,a4,1
    80001598:	cbb1                	beqz	a5,800015ec <uvmcopy+0x8a>
      panic("uvmcopy: page not present");
    pa = PTE2PA(*pte);
    8000159a:	00a75593          	srli	a1,a4,0xa
    8000159e:	00c59b93          	slli	s7,a1,0xc
    flags = PTE_FLAGS(*pte);
    800015a2:	3ff77493          	andi	s1,a4,1023
    if((mem = kalloc()) == 0)
    800015a6:	fffff097          	auipc	ra,0xfffff
    800015aa:	53c080e7          	jalr	1340(ra) # 80000ae2 <kalloc>
    800015ae:	892a                	mv	s2,a0
    800015b0:	c939                	beqz	a0,80001606 <uvmcopy+0xa4>
      goto err;
    memmove(mem, (char*)pa, PGSIZE);
    800015b2:	6605                	lui	a2,0x1
    800015b4:	85de                	mv	a1,s7
    800015b6:	fffff097          	auipc	ra,0xfffff
    800015ba:	774080e7          	jalr	1908(ra) # 80000d2a <memmove>
    if(mappages(new, i, PGSIZE, (uint64)mem, flags) != 0){
    800015be:	8726                	mv	a4,s1
    800015c0:	86ca                	mv	a3,s2
    800015c2:	6605                	lui	a2,0x1
    800015c4:	85ce                	mv	a1,s3
    800015c6:	8556                	mv	a0,s5
    800015c8:	00000097          	auipc	ra,0x0
    800015cc:	ad0080e7          	jalr	-1328(ra) # 80001098 <mappages>
    800015d0:	e515                	bnez	a0,800015fc <uvmcopy+0x9a>
  for(i = 0; i < sz; i += PGSIZE){
    800015d2:	6785                	lui	a5,0x1
    800015d4:	99be                	add	s3,s3,a5
    800015d6:	fb49e6e3          	bltu	s3,s4,80001582 <uvmcopy+0x20>
    800015da:	a081                	j	8000161a <uvmcopy+0xb8>
      panic("uvmcopy: pte should exist");
    800015dc:	00007517          	auipc	a0,0x7
    800015e0:	bac50513          	addi	a0,a0,-1108 # 80008188 <digits+0x148>
    800015e4:	fffff097          	auipc	ra,0xfffff
    800015e8:	f58080e7          	jalr	-168(ra) # 8000053c <panic>
      panic("uvmcopy: page not present");
    800015ec:	00007517          	auipc	a0,0x7
    800015f0:	bbc50513          	addi	a0,a0,-1092 # 800081a8 <digits+0x168>
    800015f4:	fffff097          	auipc	ra,0xfffff
    800015f8:	f48080e7          	jalr	-184(ra) # 8000053c <panic>
      kfree(mem);
    800015fc:	854a                	mv	a0,s2
    800015fe:	fffff097          	auipc	ra,0xfffff
    80001602:	3e6080e7          	jalr	998(ra) # 800009e4 <kfree>
    }
  }
  return 0;

 err:
  uvmunmap(new, 0, i / PGSIZE, 1);
    80001606:	4685                	li	a3,1
    80001608:	00c9d613          	srli	a2,s3,0xc
    8000160c:	4581                	li	a1,0
    8000160e:	8556                	mv	a0,s5
    80001610:	00000097          	auipc	ra,0x0
    80001614:	c4e080e7          	jalr	-946(ra) # 8000125e <uvmunmap>
  return -1;
    80001618:	557d                	li	a0,-1
}
    8000161a:	60a6                	ld	ra,72(sp)
    8000161c:	6406                	ld	s0,64(sp)
    8000161e:	74e2                	ld	s1,56(sp)
    80001620:	7942                	ld	s2,48(sp)
    80001622:	79a2                	ld	s3,40(sp)
    80001624:	7a02                	ld	s4,32(sp)
    80001626:	6ae2                	ld	s5,24(sp)
    80001628:	6b42                	ld	s6,16(sp)
    8000162a:	6ba2                	ld	s7,8(sp)
    8000162c:	6161                	addi	sp,sp,80
    8000162e:	8082                	ret
  return 0;
    80001630:	4501                	li	a0,0
}
    80001632:	8082                	ret

0000000080001634 <uvmclear>:

// mark a PTE invalid for user access.
// used by exec for the user stack guard page.
void
uvmclear(pagetable_t pagetable, uint64 va)
{
    80001634:	1141                	addi	sp,sp,-16
    80001636:	e406                	sd	ra,8(sp)
    80001638:	e022                	sd	s0,0(sp)
    8000163a:	0800                	addi	s0,sp,16
  pte_t *pte;
  
  pte = walk(pagetable, va, 0);
    8000163c:	4601                	li	a2,0
    8000163e:	00000097          	auipc	ra,0x0
    80001642:	972080e7          	jalr	-1678(ra) # 80000fb0 <walk>
  if(pte == 0)
    80001646:	c901                	beqz	a0,80001656 <uvmclear+0x22>
    panic("uvmclear");
  *pte &= ~PTE_U;
    80001648:	611c                	ld	a5,0(a0)
    8000164a:	9bbd                	andi	a5,a5,-17
    8000164c:	e11c                	sd	a5,0(a0)
}
    8000164e:	60a2                	ld	ra,8(sp)
    80001650:	6402                	ld	s0,0(sp)
    80001652:	0141                	addi	sp,sp,16
    80001654:	8082                	ret
    panic("uvmclear");
    80001656:	00007517          	auipc	a0,0x7
    8000165a:	b7250513          	addi	a0,a0,-1166 # 800081c8 <digits+0x188>
    8000165e:	fffff097          	auipc	ra,0xfffff
    80001662:	ede080e7          	jalr	-290(ra) # 8000053c <panic>

0000000080001666 <copyout>:
int
copyout(pagetable_t pagetable, uint64 dstva, char *src, uint64 len)
{
  uint64 n, va0, pa0;

  while(len > 0){
    80001666:	c6bd                	beqz	a3,800016d4 <copyout+0x6e>
{
    80001668:	715d                	addi	sp,sp,-80
    8000166a:	e486                	sd	ra,72(sp)
    8000166c:	e0a2                	sd	s0,64(sp)
    8000166e:	fc26                	sd	s1,56(sp)
    80001670:	f84a                	sd	s2,48(sp)
    80001672:	f44e                	sd	s3,40(sp)
    80001674:	f052                	sd	s4,32(sp)
    80001676:	ec56                	sd	s5,24(sp)
    80001678:	e85a                	sd	s6,16(sp)
    8000167a:	e45e                	sd	s7,8(sp)
    8000167c:	e062                	sd	s8,0(sp)
    8000167e:	0880                	addi	s0,sp,80
    80001680:	8b2a                	mv	s6,a0
    80001682:	8c2e                	mv	s8,a1
    80001684:	8a32                	mv	s4,a2
    80001686:	89b6                	mv	s3,a3
    va0 = PGROUNDDOWN(dstva);
    80001688:	7bfd                	lui	s7,0xfffff
    pa0 = walkaddr(pagetable, va0);
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (dstva - va0);
    8000168a:	6a85                	lui	s5,0x1
    8000168c:	a015                	j	800016b0 <copyout+0x4a>
    if(n > len)
      n = len;
    memmove((void *)(pa0 + (dstva - va0)), src, n);
    8000168e:	9562                	add	a0,a0,s8
    80001690:	0004861b          	sext.w	a2,s1
    80001694:	85d2                	mv	a1,s4
    80001696:	41250533          	sub	a0,a0,s2
    8000169a:	fffff097          	auipc	ra,0xfffff
    8000169e:	690080e7          	jalr	1680(ra) # 80000d2a <memmove>

    len -= n;
    800016a2:	409989b3          	sub	s3,s3,s1
    src += n;
    800016a6:	9a26                	add	s4,s4,s1
    dstva = va0 + PGSIZE;
    800016a8:	01590c33          	add	s8,s2,s5
  while(len > 0){
    800016ac:	02098263          	beqz	s3,800016d0 <copyout+0x6a>
    va0 = PGROUNDDOWN(dstva);
    800016b0:	017c7933          	and	s2,s8,s7
    pa0 = walkaddr(pagetable, va0);
    800016b4:	85ca                	mv	a1,s2
    800016b6:	855a                	mv	a0,s6
    800016b8:	00000097          	auipc	ra,0x0
    800016bc:	99e080e7          	jalr	-1634(ra) # 80001056 <walkaddr>
    if(pa0 == 0)
    800016c0:	cd01                	beqz	a0,800016d8 <copyout+0x72>
    n = PGSIZE - (dstva - va0);
    800016c2:	418904b3          	sub	s1,s2,s8
    800016c6:	94d6                	add	s1,s1,s5
    800016c8:	fc99f3e3          	bgeu	s3,s1,8000168e <copyout+0x28>
    800016cc:	84ce                	mv	s1,s3
    800016ce:	b7c1                	j	8000168e <copyout+0x28>
  }
  return 0;
    800016d0:	4501                	li	a0,0
    800016d2:	a021                	j	800016da <copyout+0x74>
    800016d4:	4501                	li	a0,0
}
    800016d6:	8082                	ret
      return -1;
    800016d8:	557d                	li	a0,-1
}
    800016da:	60a6                	ld	ra,72(sp)
    800016dc:	6406                	ld	s0,64(sp)
    800016de:	74e2                	ld	s1,56(sp)
    800016e0:	7942                	ld	s2,48(sp)
    800016e2:	79a2                	ld	s3,40(sp)
    800016e4:	7a02                	ld	s4,32(sp)
    800016e6:	6ae2                	ld	s5,24(sp)
    800016e8:	6b42                	ld	s6,16(sp)
    800016ea:	6ba2                	ld	s7,8(sp)
    800016ec:	6c02                	ld	s8,0(sp)
    800016ee:	6161                	addi	sp,sp,80
    800016f0:	8082                	ret

00000000800016f2 <copyin>:
int
copyin(pagetable_t pagetable, char *dst, uint64 srcva, uint64 len)
{
  uint64 n, va0, pa0;

  while(len > 0){
    800016f2:	caa5                	beqz	a3,80001762 <copyin+0x70>
{
    800016f4:	715d                	addi	sp,sp,-80
    800016f6:	e486                	sd	ra,72(sp)
    800016f8:	e0a2                	sd	s0,64(sp)
    800016fa:	fc26                	sd	s1,56(sp)
    800016fc:	f84a                	sd	s2,48(sp)
    800016fe:	f44e                	sd	s3,40(sp)
    80001700:	f052                	sd	s4,32(sp)
    80001702:	ec56                	sd	s5,24(sp)
    80001704:	e85a                	sd	s6,16(sp)
    80001706:	e45e                	sd	s7,8(sp)
    80001708:	e062                	sd	s8,0(sp)
    8000170a:	0880                	addi	s0,sp,80
    8000170c:	8b2a                	mv	s6,a0
    8000170e:	8a2e                	mv	s4,a1
    80001710:	8c32                	mv	s8,a2
    80001712:	89b6                	mv	s3,a3
    va0 = PGROUNDDOWN(srcva);
    80001714:	7bfd                	lui	s7,0xfffff
    pa0 = walkaddr(pagetable, va0);
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (srcva - va0);
    80001716:	6a85                	lui	s5,0x1
    80001718:	a01d                	j	8000173e <copyin+0x4c>
    if(n > len)
      n = len;
    memmove(dst, (void *)(pa0 + (srcva - va0)), n);
    8000171a:	018505b3          	add	a1,a0,s8
    8000171e:	0004861b          	sext.w	a2,s1
    80001722:	412585b3          	sub	a1,a1,s2
    80001726:	8552                	mv	a0,s4
    80001728:	fffff097          	auipc	ra,0xfffff
    8000172c:	602080e7          	jalr	1538(ra) # 80000d2a <memmove>

    len -= n;
    80001730:	409989b3          	sub	s3,s3,s1
    dst += n;
    80001734:	9a26                	add	s4,s4,s1
    srcva = va0 + PGSIZE;
    80001736:	01590c33          	add	s8,s2,s5
  while(len > 0){
    8000173a:	02098263          	beqz	s3,8000175e <copyin+0x6c>
    va0 = PGROUNDDOWN(srcva);
    8000173e:	017c7933          	and	s2,s8,s7
    pa0 = walkaddr(pagetable, va0);
    80001742:	85ca                	mv	a1,s2
    80001744:	855a                	mv	a0,s6
    80001746:	00000097          	auipc	ra,0x0
    8000174a:	910080e7          	jalr	-1776(ra) # 80001056 <walkaddr>
    if(pa0 == 0)
    8000174e:	cd01                	beqz	a0,80001766 <copyin+0x74>
    n = PGSIZE - (srcva - va0);
    80001750:	418904b3          	sub	s1,s2,s8
    80001754:	94d6                	add	s1,s1,s5
    80001756:	fc99f2e3          	bgeu	s3,s1,8000171a <copyin+0x28>
    8000175a:	84ce                	mv	s1,s3
    8000175c:	bf7d                	j	8000171a <copyin+0x28>
  }
  return 0;
    8000175e:	4501                	li	a0,0
    80001760:	a021                	j	80001768 <copyin+0x76>
    80001762:	4501                	li	a0,0
}
    80001764:	8082                	ret
      return -1;
    80001766:	557d                	li	a0,-1
}
    80001768:	60a6                	ld	ra,72(sp)
    8000176a:	6406                	ld	s0,64(sp)
    8000176c:	74e2                	ld	s1,56(sp)
    8000176e:	7942                	ld	s2,48(sp)
    80001770:	79a2                	ld	s3,40(sp)
    80001772:	7a02                	ld	s4,32(sp)
    80001774:	6ae2                	ld	s5,24(sp)
    80001776:	6b42                	ld	s6,16(sp)
    80001778:	6ba2                	ld	s7,8(sp)
    8000177a:	6c02                	ld	s8,0(sp)
    8000177c:	6161                	addi	sp,sp,80
    8000177e:	8082                	ret

0000000080001780 <copyinstr>:
copyinstr(pagetable_t pagetable, char *dst, uint64 srcva, uint64 max)
{
  uint64 n, va0, pa0;
  int got_null = 0;

  while(got_null == 0 && max > 0){
    80001780:	c2dd                	beqz	a3,80001826 <copyinstr+0xa6>
{
    80001782:	715d                	addi	sp,sp,-80
    80001784:	e486                	sd	ra,72(sp)
    80001786:	e0a2                	sd	s0,64(sp)
    80001788:	fc26                	sd	s1,56(sp)
    8000178a:	f84a                	sd	s2,48(sp)
    8000178c:	f44e                	sd	s3,40(sp)
    8000178e:	f052                	sd	s4,32(sp)
    80001790:	ec56                	sd	s5,24(sp)
    80001792:	e85a                	sd	s6,16(sp)
    80001794:	e45e                	sd	s7,8(sp)
    80001796:	0880                	addi	s0,sp,80
    80001798:	8a2a                	mv	s4,a0
    8000179a:	8b2e                	mv	s6,a1
    8000179c:	8bb2                	mv	s7,a2
    8000179e:	84b6                	mv	s1,a3
    va0 = PGROUNDDOWN(srcva);
    800017a0:	7afd                	lui	s5,0xfffff
    pa0 = walkaddr(pagetable, va0);
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (srcva - va0);
    800017a2:	6985                	lui	s3,0x1
    800017a4:	a02d                	j	800017ce <copyinstr+0x4e>
      n = max;

    char *p = (char *) (pa0 + (srcva - va0));
    while(n > 0){
      if(*p == '\0'){
        *dst = '\0';
    800017a6:	00078023          	sb	zero,0(a5) # 1000 <_entry-0x7ffff000>
    800017aa:	4785                	li	a5,1
      dst++;
    }

    srcva = va0 + PGSIZE;
  }
  if(got_null){
    800017ac:	37fd                	addiw	a5,a5,-1
    800017ae:	0007851b          	sext.w	a0,a5
    return 0;
  } else {
    return -1;
  }
}
    800017b2:	60a6                	ld	ra,72(sp)
    800017b4:	6406                	ld	s0,64(sp)
    800017b6:	74e2                	ld	s1,56(sp)
    800017b8:	7942                	ld	s2,48(sp)
    800017ba:	79a2                	ld	s3,40(sp)
    800017bc:	7a02                	ld	s4,32(sp)
    800017be:	6ae2                	ld	s5,24(sp)
    800017c0:	6b42                	ld	s6,16(sp)
    800017c2:	6ba2                	ld	s7,8(sp)
    800017c4:	6161                	addi	sp,sp,80
    800017c6:	8082                	ret
    srcva = va0 + PGSIZE;
    800017c8:	01390bb3          	add	s7,s2,s3
  while(got_null == 0 && max > 0){
    800017cc:	c8a9                	beqz	s1,8000181e <copyinstr+0x9e>
    va0 = PGROUNDDOWN(srcva);
    800017ce:	015bf933          	and	s2,s7,s5
    pa0 = walkaddr(pagetable, va0);
    800017d2:	85ca                	mv	a1,s2
    800017d4:	8552                	mv	a0,s4
    800017d6:	00000097          	auipc	ra,0x0
    800017da:	880080e7          	jalr	-1920(ra) # 80001056 <walkaddr>
    if(pa0 == 0)
    800017de:	c131                	beqz	a0,80001822 <copyinstr+0xa2>
    n = PGSIZE - (srcva - va0);
    800017e0:	417906b3          	sub	a3,s2,s7
    800017e4:	96ce                	add	a3,a3,s3
    800017e6:	00d4f363          	bgeu	s1,a3,800017ec <copyinstr+0x6c>
    800017ea:	86a6                	mv	a3,s1
    char *p = (char *) (pa0 + (srcva - va0));
    800017ec:	955e                	add	a0,a0,s7
    800017ee:	41250533          	sub	a0,a0,s2
    while(n > 0){
    800017f2:	daf9                	beqz	a3,800017c8 <copyinstr+0x48>
    800017f4:	87da                	mv	a5,s6
    800017f6:	885a                	mv	a6,s6
      if(*p == '\0'){
    800017f8:	41650633          	sub	a2,a0,s6
    while(n > 0){
    800017fc:	96da                	add	a3,a3,s6
    800017fe:	85be                	mv	a1,a5
      if(*p == '\0'){
    80001800:	00f60733          	add	a4,a2,a5
    80001804:	00074703          	lbu	a4,0(a4) # fffffffffffff000 <end+0xffffffff7ffdd2b0>
    80001808:	df59                	beqz	a4,800017a6 <copyinstr+0x26>
        *dst = *p;
    8000180a:	00e78023          	sb	a4,0(a5)
      dst++;
    8000180e:	0785                	addi	a5,a5,1
    while(n > 0){
    80001810:	fed797e3          	bne	a5,a3,800017fe <copyinstr+0x7e>
    80001814:	14fd                	addi	s1,s1,-1
    80001816:	94c2                	add	s1,s1,a6
      --max;
    80001818:	8c8d                	sub	s1,s1,a1
      dst++;
    8000181a:	8b3e                	mv	s6,a5
    8000181c:	b775                	j	800017c8 <copyinstr+0x48>
    8000181e:	4781                	li	a5,0
    80001820:	b771                	j	800017ac <copyinstr+0x2c>
      return -1;
    80001822:	557d                	li	a0,-1
    80001824:	b779                	j	800017b2 <copyinstr+0x32>
  int got_null = 0;
    80001826:	4781                	li	a5,0
  if(got_null){
    80001828:	37fd                	addiw	a5,a5,-1
    8000182a:	0007851b          	sext.w	a0,a5
}
    8000182e:	8082                	ret

0000000080001830 <proc_mapstacks>:
// Allocate a page for each process's kernel stack.
// Map it high in memory, followed by an invalid
// guard page.
void
proc_mapstacks(pagetable_t kpgtbl)
{
    80001830:	7139                	addi	sp,sp,-64
    80001832:	fc06                	sd	ra,56(sp)
    80001834:	f822                	sd	s0,48(sp)
    80001836:	f426                	sd	s1,40(sp)
    80001838:	f04a                	sd	s2,32(sp)
    8000183a:	ec4e                	sd	s3,24(sp)
    8000183c:	e852                	sd	s4,16(sp)
    8000183e:	e456                	sd	s5,8(sp)
    80001840:	e05a                	sd	s6,0(sp)
    80001842:	0080                	addi	s0,sp,64
    80001844:	89aa                	mv	s3,a0
  struct proc *p;
  
  for(p = proc; p < &proc[NPROC]; p++) {
    80001846:	0000f497          	auipc	s1,0xf
    8000184a:	72a48493          	addi	s1,s1,1834 # 80010f70 <proc>
    char *pa = kalloc();
    if(pa == 0)
      panic("kalloc");
    uint64 va = KSTACK((int) (p - proc));
    8000184e:	8b26                	mv	s6,s1
    80001850:	00006a97          	auipc	s5,0x6
    80001854:	7b0a8a93          	addi	s5,s5,1968 # 80008000 <etext>
    80001858:	04000937          	lui	s2,0x4000
    8000185c:	197d                	addi	s2,s2,-1 # 3ffffff <_entry-0x7c000001>
    8000185e:	0932                	slli	s2,s2,0xc
  for(p = proc; p < &proc[NPROC]; p++) {
    80001860:	00015a17          	auipc	s4,0x15
    80001864:	110a0a13          	addi	s4,s4,272 # 80016970 <tickslock>
    char *pa = kalloc();
    80001868:	fffff097          	auipc	ra,0xfffff
    8000186c:	27a080e7          	jalr	634(ra) # 80000ae2 <kalloc>
    80001870:	862a                	mv	a2,a0
    if(pa == 0)
    80001872:	c131                	beqz	a0,800018b6 <proc_mapstacks+0x86>
    uint64 va = KSTACK((int) (p - proc));
    80001874:	416485b3          	sub	a1,s1,s6
    80001878:	858d                	srai	a1,a1,0x3
    8000187a:	000ab783          	ld	a5,0(s5)
    8000187e:	02f585b3          	mul	a1,a1,a5
    80001882:	2585                	addiw	a1,a1,1
    80001884:	00d5959b          	slliw	a1,a1,0xd
    kvmmap(kpgtbl, va, (uint64)pa, PGSIZE, PTE_R | PTE_W);
    80001888:	4719                	li	a4,6
    8000188a:	6685                	lui	a3,0x1
    8000188c:	40b905b3          	sub	a1,s2,a1
    80001890:	854e                	mv	a0,s3
    80001892:	00000097          	auipc	ra,0x0
    80001896:	8a6080e7          	jalr	-1882(ra) # 80001138 <kvmmap>
  for(p = proc; p < &proc[NPROC]; p++) {
    8000189a:	16848493          	addi	s1,s1,360
    8000189e:	fd4495e3          	bne	s1,s4,80001868 <proc_mapstacks+0x38>
  }
}
    800018a2:	70e2                	ld	ra,56(sp)
    800018a4:	7442                	ld	s0,48(sp)
    800018a6:	74a2                	ld	s1,40(sp)
    800018a8:	7902                	ld	s2,32(sp)
    800018aa:	69e2                	ld	s3,24(sp)
    800018ac:	6a42                	ld	s4,16(sp)
    800018ae:	6aa2                	ld	s5,8(sp)
    800018b0:	6b02                	ld	s6,0(sp)
    800018b2:	6121                	addi	sp,sp,64
    800018b4:	8082                	ret
      panic("kalloc");
    800018b6:	00007517          	auipc	a0,0x7
    800018ba:	92250513          	addi	a0,a0,-1758 # 800081d8 <digits+0x198>
    800018be:	fffff097          	auipc	ra,0xfffff
    800018c2:	c7e080e7          	jalr	-898(ra) # 8000053c <panic>

00000000800018c6 <procinit>:

// initialize the proc table.
void
procinit(void)
{
    800018c6:	7139                	addi	sp,sp,-64
    800018c8:	fc06                	sd	ra,56(sp)
    800018ca:	f822                	sd	s0,48(sp)
    800018cc:	f426                	sd	s1,40(sp)
    800018ce:	f04a                	sd	s2,32(sp)
    800018d0:	ec4e                	sd	s3,24(sp)
    800018d2:	e852                	sd	s4,16(sp)
    800018d4:	e456                	sd	s5,8(sp)
    800018d6:	e05a                	sd	s6,0(sp)
    800018d8:	0080                	addi	s0,sp,64
  struct proc *p;
  
  initlock(&pid_lock, "nextpid");
    800018da:	00007597          	auipc	a1,0x7
    800018de:	90658593          	addi	a1,a1,-1786 # 800081e0 <digits+0x1a0>
    800018e2:	0000f517          	auipc	a0,0xf
    800018e6:	25e50513          	addi	a0,a0,606 # 80010b40 <pid_lock>
    800018ea:	fffff097          	auipc	ra,0xfffff
    800018ee:	258080e7          	jalr	600(ra) # 80000b42 <initlock>
  initlock(&wait_lock, "wait_lock");
    800018f2:	00007597          	auipc	a1,0x7
    800018f6:	8f658593          	addi	a1,a1,-1802 # 800081e8 <digits+0x1a8>
    800018fa:	0000f517          	auipc	a0,0xf
    800018fe:	25e50513          	addi	a0,a0,606 # 80010b58 <wait_lock>
    80001902:	fffff097          	auipc	ra,0xfffff
    80001906:	240080e7          	jalr	576(ra) # 80000b42 <initlock>
  for(p = proc; p < &proc[NPROC]; p++) {
    8000190a:	0000f497          	auipc	s1,0xf
    8000190e:	66648493          	addi	s1,s1,1638 # 80010f70 <proc>
      initlock(&p->lock, "proc");
    80001912:	00007b17          	auipc	s6,0x7
    80001916:	8e6b0b13          	addi	s6,s6,-1818 # 800081f8 <digits+0x1b8>
      p->state = UNUSED;
      p->kstack = KSTACK((int) (p - proc));
    8000191a:	8aa6                	mv	s5,s1
    8000191c:	00006a17          	auipc	s4,0x6
    80001920:	6e4a0a13          	addi	s4,s4,1764 # 80008000 <etext>
    80001924:	04000937          	lui	s2,0x4000
    80001928:	197d                	addi	s2,s2,-1 # 3ffffff <_entry-0x7c000001>
    8000192a:	0932                	slli	s2,s2,0xc
  for(p = proc; p < &proc[NPROC]; p++) {
    8000192c:	00015997          	auipc	s3,0x15
    80001930:	04498993          	addi	s3,s3,68 # 80016970 <tickslock>
      initlock(&p->lock, "proc");
    80001934:	85da                	mv	a1,s6
    80001936:	8526                	mv	a0,s1
    80001938:	fffff097          	auipc	ra,0xfffff
    8000193c:	20a080e7          	jalr	522(ra) # 80000b42 <initlock>
      p->state = UNUSED;
    80001940:	0004ac23          	sw	zero,24(s1)
      p->kstack = KSTACK((int) (p - proc));
    80001944:	415487b3          	sub	a5,s1,s5
    80001948:	878d                	srai	a5,a5,0x3
    8000194a:	000a3703          	ld	a4,0(s4)
    8000194e:	02e787b3          	mul	a5,a5,a4
    80001952:	2785                	addiw	a5,a5,1
    80001954:	00d7979b          	slliw	a5,a5,0xd
    80001958:	40f907b3          	sub	a5,s2,a5
    8000195c:	e0bc                	sd	a5,64(s1)
  for(p = proc; p < &proc[NPROC]; p++) {
    8000195e:	16848493          	addi	s1,s1,360
    80001962:	fd3499e3          	bne	s1,s3,80001934 <procinit+0x6e>
  }
}
    80001966:	70e2                	ld	ra,56(sp)
    80001968:	7442                	ld	s0,48(sp)
    8000196a:	74a2                	ld	s1,40(sp)
    8000196c:	7902                	ld	s2,32(sp)
    8000196e:	69e2                	ld	s3,24(sp)
    80001970:	6a42                	ld	s4,16(sp)
    80001972:	6aa2                	ld	s5,8(sp)
    80001974:	6b02                	ld	s6,0(sp)
    80001976:	6121                	addi	sp,sp,64
    80001978:	8082                	ret

000000008000197a <cpuid>:
// Must be called with interrupts disabled,
// to prevent race with process being moved
// to a different CPU.
int
cpuid()
{
    8000197a:	1141                	addi	sp,sp,-16
    8000197c:	e422                	sd	s0,8(sp)
    8000197e:	0800                	addi	s0,sp,16
  asm volatile("mv %0, tp" : "=r" (x) );
    80001980:	8512                	mv	a0,tp
  int id = r_tp();
  return id;
}
    80001982:	2501                	sext.w	a0,a0
    80001984:	6422                	ld	s0,8(sp)
    80001986:	0141                	addi	sp,sp,16
    80001988:	8082                	ret

000000008000198a <mycpu>:

// Return this CPU's cpu struct.
// Interrupts must be disabled.
struct cpu*
mycpu(void)
{
    8000198a:	1141                	addi	sp,sp,-16
    8000198c:	e422                	sd	s0,8(sp)
    8000198e:	0800                	addi	s0,sp,16
    80001990:	8792                	mv	a5,tp
  int id = cpuid();
  struct cpu *c = &cpus[id];
    80001992:	2781                	sext.w	a5,a5
    80001994:	079e                	slli	a5,a5,0x7
  return c;
}
    80001996:	0000f517          	auipc	a0,0xf
    8000199a:	1da50513          	addi	a0,a0,474 # 80010b70 <cpus>
    8000199e:	953e                	add	a0,a0,a5
    800019a0:	6422                	ld	s0,8(sp)
    800019a2:	0141                	addi	sp,sp,16
    800019a4:	8082                	ret

00000000800019a6 <myproc>:

// Return the current struct proc *, or zero if none.
struct proc*
myproc(void)
{
    800019a6:	1101                	addi	sp,sp,-32
    800019a8:	ec06                	sd	ra,24(sp)
    800019aa:	e822                	sd	s0,16(sp)
    800019ac:	e426                	sd	s1,8(sp)
    800019ae:	1000                	addi	s0,sp,32
  push_off();
    800019b0:	fffff097          	auipc	ra,0xfffff
    800019b4:	1d6080e7          	jalr	470(ra) # 80000b86 <push_off>
    800019b8:	8792                	mv	a5,tp
  struct cpu *c = mycpu();
  struct proc *p = c->proc;
    800019ba:	2781                	sext.w	a5,a5
    800019bc:	079e                	slli	a5,a5,0x7
    800019be:	0000f717          	auipc	a4,0xf
    800019c2:	18270713          	addi	a4,a4,386 # 80010b40 <pid_lock>
    800019c6:	97ba                	add	a5,a5,a4
    800019c8:	7b84                	ld	s1,48(a5)
  pop_off();
    800019ca:	fffff097          	auipc	ra,0xfffff
    800019ce:	25c080e7          	jalr	604(ra) # 80000c26 <pop_off>
  return p;
}
    800019d2:	8526                	mv	a0,s1
    800019d4:	60e2                	ld	ra,24(sp)
    800019d6:	6442                	ld	s0,16(sp)
    800019d8:	64a2                	ld	s1,8(sp)
    800019da:	6105                	addi	sp,sp,32
    800019dc:	8082                	ret

00000000800019de <forkret>:

// A fork child's very first scheduling by scheduler()
// will swtch to forkret.
void
forkret(void)
{
    800019de:	1141                	addi	sp,sp,-16
    800019e0:	e406                	sd	ra,8(sp)
    800019e2:	e022                	sd	s0,0(sp)
    800019e4:	0800                	addi	s0,sp,16
  static int first = 1;

  // Still holding p->lock from scheduler.
  release(&myproc()->lock);
    800019e6:	00000097          	auipc	ra,0x0
    800019ea:	fc0080e7          	jalr	-64(ra) # 800019a6 <myproc>
    800019ee:	fffff097          	auipc	ra,0xfffff
    800019f2:	298080e7          	jalr	664(ra) # 80000c86 <release>

  if (first) {
    800019f6:	00007797          	auipc	a5,0x7
    800019fa:	e5a7a783          	lw	a5,-422(a5) # 80008850 <first.1>
    800019fe:	eb89                	bnez	a5,80001a10 <forkret+0x32>
    // be run from main().
    first = 0;
    fsinit(ROOTDEV);
  }

  usertrapret();
    80001a00:	00001097          	auipc	ra,0x1
    80001a04:	ca8080e7          	jalr	-856(ra) # 800026a8 <usertrapret>
}
    80001a08:	60a2                	ld	ra,8(sp)
    80001a0a:	6402                	ld	s0,0(sp)
    80001a0c:	0141                	addi	sp,sp,16
    80001a0e:	8082                	ret
    first = 0;
    80001a10:	00007797          	auipc	a5,0x7
    80001a14:	e407a023          	sw	zero,-448(a5) # 80008850 <first.1>
    fsinit(ROOTDEV);
    80001a18:	4505                	li	a0,1
    80001a1a:	00002097          	auipc	ra,0x2
    80001a1e:	9f4080e7          	jalr	-1548(ra) # 8000340e <fsinit>
    80001a22:	bff9                	j	80001a00 <forkret+0x22>

0000000080001a24 <dump>:
{
    80001a24:	7179                	addi	sp,sp,-48
    80001a26:	f406                	sd	ra,40(sp)
    80001a28:	f022                	sd	s0,32(sp)
    80001a2a:	ec26                	sd	s1,24(sp)
    80001a2c:	e84a                	sd	s2,16(sp)
    80001a2e:	e44e                	sd	s3,8(sp)
    80001a30:	1800                	addi	s0,sp,48
  uint64* dumpFrame = &myproc()->trapframe->s2;
    80001a32:	00000097          	auipc	ra,0x0
    80001a36:	f74080e7          	jalr	-140(ra) # 800019a6 <myproc>
    80001a3a:	05853903          	ld	s2,88(a0)
  for(int i=0; i<10; i++) printf("%d\n", dumpFrame[i]);
    80001a3e:	0b090493          	addi	s1,s2,176
    80001a42:	10090913          	addi	s2,s2,256
    80001a46:	00007997          	auipc	s3,0x7
    80001a4a:	9ea98993          	addi	s3,s3,-1558 # 80008430 <states.0+0x168>
    80001a4e:	608c                	ld	a1,0(s1)
    80001a50:	854e                	mv	a0,s3
    80001a52:	fffff097          	auipc	ra,0xfffff
    80001a56:	b34080e7          	jalr	-1228(ra) # 80000586 <printf>
    80001a5a:	04a1                	addi	s1,s1,8
    80001a5c:	ff2499e3          	bne	s1,s2,80001a4e <dump+0x2a>
}
    80001a60:	4501                	li	a0,0
    80001a62:	70a2                	ld	ra,40(sp)
    80001a64:	7402                	ld	s0,32(sp)
    80001a66:	64e2                	ld	s1,24(sp)
    80001a68:	6942                	ld	s2,16(sp)
    80001a6a:	69a2                	ld	s3,8(sp)
    80001a6c:	6145                	addi	sp,sp,48
    80001a6e:	8082                	ret

0000000080001a70 <allocpid>:
{
    80001a70:	1101                	addi	sp,sp,-32
    80001a72:	ec06                	sd	ra,24(sp)
    80001a74:	e822                	sd	s0,16(sp)
    80001a76:	e426                	sd	s1,8(sp)
    80001a78:	e04a                	sd	s2,0(sp)
    80001a7a:	1000                	addi	s0,sp,32
  acquire(&pid_lock);
    80001a7c:	0000f917          	auipc	s2,0xf
    80001a80:	0c490913          	addi	s2,s2,196 # 80010b40 <pid_lock>
    80001a84:	854a                	mv	a0,s2
    80001a86:	fffff097          	auipc	ra,0xfffff
    80001a8a:	14c080e7          	jalr	332(ra) # 80000bd2 <acquire>
  pid = nextpid;
    80001a8e:	00007797          	auipc	a5,0x7
    80001a92:	dc678793          	addi	a5,a5,-570 # 80008854 <nextpid>
    80001a96:	4384                	lw	s1,0(a5)
  nextpid = nextpid + 1;
    80001a98:	0014871b          	addiw	a4,s1,1
    80001a9c:	c398                	sw	a4,0(a5)
  release(&pid_lock);
    80001a9e:	854a                	mv	a0,s2
    80001aa0:	fffff097          	auipc	ra,0xfffff
    80001aa4:	1e6080e7          	jalr	486(ra) # 80000c86 <release>
}
    80001aa8:	8526                	mv	a0,s1
    80001aaa:	60e2                	ld	ra,24(sp)
    80001aac:	6442                	ld	s0,16(sp)
    80001aae:	64a2                	ld	s1,8(sp)
    80001ab0:	6902                	ld	s2,0(sp)
    80001ab2:	6105                	addi	sp,sp,32
    80001ab4:	8082                	ret

0000000080001ab6 <proc_pagetable>:
{
    80001ab6:	1101                	addi	sp,sp,-32
    80001ab8:	ec06                	sd	ra,24(sp)
    80001aba:	e822                	sd	s0,16(sp)
    80001abc:	e426                	sd	s1,8(sp)
    80001abe:	e04a                	sd	s2,0(sp)
    80001ac0:	1000                	addi	s0,sp,32
    80001ac2:	892a                	mv	s2,a0
  pagetable = uvmcreate();
    80001ac4:	00000097          	auipc	ra,0x0
    80001ac8:	85e080e7          	jalr	-1954(ra) # 80001322 <uvmcreate>
    80001acc:	84aa                	mv	s1,a0
  if(pagetable == 0)
    80001ace:	c121                	beqz	a0,80001b0e <proc_pagetable+0x58>
  if(mappages(pagetable, TRAMPOLINE, PGSIZE,
    80001ad0:	4729                	li	a4,10
    80001ad2:	00005697          	auipc	a3,0x5
    80001ad6:	52e68693          	addi	a3,a3,1326 # 80007000 <_trampoline>
    80001ada:	6605                	lui	a2,0x1
    80001adc:	040005b7          	lui	a1,0x4000
    80001ae0:	15fd                	addi	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    80001ae2:	05b2                	slli	a1,a1,0xc
    80001ae4:	fffff097          	auipc	ra,0xfffff
    80001ae8:	5b4080e7          	jalr	1460(ra) # 80001098 <mappages>
    80001aec:	02054863          	bltz	a0,80001b1c <proc_pagetable+0x66>
  if(mappages(pagetable, TRAPFRAME, PGSIZE,
    80001af0:	4719                	li	a4,6
    80001af2:	05893683          	ld	a3,88(s2)
    80001af6:	6605                	lui	a2,0x1
    80001af8:	020005b7          	lui	a1,0x2000
    80001afc:	15fd                	addi	a1,a1,-1 # 1ffffff <_entry-0x7e000001>
    80001afe:	05b6                	slli	a1,a1,0xd
    80001b00:	8526                	mv	a0,s1
    80001b02:	fffff097          	auipc	ra,0xfffff
    80001b06:	596080e7          	jalr	1430(ra) # 80001098 <mappages>
    80001b0a:	02054163          	bltz	a0,80001b2c <proc_pagetable+0x76>
}
    80001b0e:	8526                	mv	a0,s1
    80001b10:	60e2                	ld	ra,24(sp)
    80001b12:	6442                	ld	s0,16(sp)
    80001b14:	64a2                	ld	s1,8(sp)
    80001b16:	6902                	ld	s2,0(sp)
    80001b18:	6105                	addi	sp,sp,32
    80001b1a:	8082                	ret
    uvmfree(pagetable, 0);
    80001b1c:	4581                	li	a1,0
    80001b1e:	8526                	mv	a0,s1
    80001b20:	00000097          	auipc	ra,0x0
    80001b24:	a08080e7          	jalr	-1528(ra) # 80001528 <uvmfree>
    return 0;
    80001b28:	4481                	li	s1,0
    80001b2a:	b7d5                	j	80001b0e <proc_pagetable+0x58>
    uvmunmap(pagetable, TRAMPOLINE, 1, 0);
    80001b2c:	4681                	li	a3,0
    80001b2e:	4605                	li	a2,1
    80001b30:	040005b7          	lui	a1,0x4000
    80001b34:	15fd                	addi	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    80001b36:	05b2                	slli	a1,a1,0xc
    80001b38:	8526                	mv	a0,s1
    80001b3a:	fffff097          	auipc	ra,0xfffff
    80001b3e:	724080e7          	jalr	1828(ra) # 8000125e <uvmunmap>
    uvmfree(pagetable, 0);
    80001b42:	4581                	li	a1,0
    80001b44:	8526                	mv	a0,s1
    80001b46:	00000097          	auipc	ra,0x0
    80001b4a:	9e2080e7          	jalr	-1566(ra) # 80001528 <uvmfree>
    return 0;
    80001b4e:	4481                	li	s1,0
    80001b50:	bf7d                	j	80001b0e <proc_pagetable+0x58>

0000000080001b52 <proc_freepagetable>:
{
    80001b52:	1101                	addi	sp,sp,-32
    80001b54:	ec06                	sd	ra,24(sp)
    80001b56:	e822                	sd	s0,16(sp)
    80001b58:	e426                	sd	s1,8(sp)
    80001b5a:	e04a                	sd	s2,0(sp)
    80001b5c:	1000                	addi	s0,sp,32
    80001b5e:	84aa                	mv	s1,a0
    80001b60:	892e                	mv	s2,a1
  uvmunmap(pagetable, TRAMPOLINE, 1, 0);
    80001b62:	4681                	li	a3,0
    80001b64:	4605                	li	a2,1
    80001b66:	040005b7          	lui	a1,0x4000
    80001b6a:	15fd                	addi	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    80001b6c:	05b2                	slli	a1,a1,0xc
    80001b6e:	fffff097          	auipc	ra,0xfffff
    80001b72:	6f0080e7          	jalr	1776(ra) # 8000125e <uvmunmap>
  uvmunmap(pagetable, TRAPFRAME, 1, 0);
    80001b76:	4681                	li	a3,0
    80001b78:	4605                	li	a2,1
    80001b7a:	020005b7          	lui	a1,0x2000
    80001b7e:	15fd                	addi	a1,a1,-1 # 1ffffff <_entry-0x7e000001>
    80001b80:	05b6                	slli	a1,a1,0xd
    80001b82:	8526                	mv	a0,s1
    80001b84:	fffff097          	auipc	ra,0xfffff
    80001b88:	6da080e7          	jalr	1754(ra) # 8000125e <uvmunmap>
  uvmfree(pagetable, sz);
    80001b8c:	85ca                	mv	a1,s2
    80001b8e:	8526                	mv	a0,s1
    80001b90:	00000097          	auipc	ra,0x0
    80001b94:	998080e7          	jalr	-1640(ra) # 80001528 <uvmfree>
}
    80001b98:	60e2                	ld	ra,24(sp)
    80001b9a:	6442                	ld	s0,16(sp)
    80001b9c:	64a2                	ld	s1,8(sp)
    80001b9e:	6902                	ld	s2,0(sp)
    80001ba0:	6105                	addi	sp,sp,32
    80001ba2:	8082                	ret

0000000080001ba4 <freeproc>:
{
    80001ba4:	1101                	addi	sp,sp,-32
    80001ba6:	ec06                	sd	ra,24(sp)
    80001ba8:	e822                	sd	s0,16(sp)
    80001baa:	e426                	sd	s1,8(sp)
    80001bac:	1000                	addi	s0,sp,32
    80001bae:	84aa                	mv	s1,a0
  if(p->trapframe)
    80001bb0:	6d28                	ld	a0,88(a0)
    80001bb2:	c509                	beqz	a0,80001bbc <freeproc+0x18>
    kfree((void*)p->trapframe);
    80001bb4:	fffff097          	auipc	ra,0xfffff
    80001bb8:	e30080e7          	jalr	-464(ra) # 800009e4 <kfree>
  p->trapframe = 0;
    80001bbc:	0404bc23          	sd	zero,88(s1)
  if(p->pagetable)
    80001bc0:	68a8                	ld	a0,80(s1)
    80001bc2:	c511                	beqz	a0,80001bce <freeproc+0x2a>
    proc_freepagetable(p->pagetable, p->sz);
    80001bc4:	64ac                	ld	a1,72(s1)
    80001bc6:	00000097          	auipc	ra,0x0
    80001bca:	f8c080e7          	jalr	-116(ra) # 80001b52 <proc_freepagetable>
  p->pagetable = 0;
    80001bce:	0404b823          	sd	zero,80(s1)
  p->sz = 0;
    80001bd2:	0404b423          	sd	zero,72(s1)
  p->pid = 0;
    80001bd6:	0204a823          	sw	zero,48(s1)
  p->parent = 0;
    80001bda:	0204bc23          	sd	zero,56(s1)
  p->name[0] = 0;
    80001bde:	14048c23          	sb	zero,344(s1)
  p->chan = 0;
    80001be2:	0204b023          	sd	zero,32(s1)
  p->killed = 0;
    80001be6:	0204a423          	sw	zero,40(s1)
  p->xstate = 0;
    80001bea:	0204a623          	sw	zero,44(s1)
  p->state = UNUSED;
    80001bee:	0004ac23          	sw	zero,24(s1)
}
    80001bf2:	60e2                	ld	ra,24(sp)
    80001bf4:	6442                	ld	s0,16(sp)
    80001bf6:	64a2                	ld	s1,8(sp)
    80001bf8:	6105                	addi	sp,sp,32
    80001bfa:	8082                	ret

0000000080001bfc <allocproc>:
{
    80001bfc:	1101                	addi	sp,sp,-32
    80001bfe:	ec06                	sd	ra,24(sp)
    80001c00:	e822                	sd	s0,16(sp)
    80001c02:	e426                	sd	s1,8(sp)
    80001c04:	e04a                	sd	s2,0(sp)
    80001c06:	1000                	addi	s0,sp,32
  for(p = proc; p < &proc[NPROC]; p++) {
    80001c08:	0000f497          	auipc	s1,0xf
    80001c0c:	36848493          	addi	s1,s1,872 # 80010f70 <proc>
    80001c10:	00015917          	auipc	s2,0x15
    80001c14:	d6090913          	addi	s2,s2,-672 # 80016970 <tickslock>
    acquire(&p->lock);
    80001c18:	8526                	mv	a0,s1
    80001c1a:	fffff097          	auipc	ra,0xfffff
    80001c1e:	fb8080e7          	jalr	-72(ra) # 80000bd2 <acquire>
    if(p->state == UNUSED) {
    80001c22:	4c9c                	lw	a5,24(s1)
    80001c24:	cf81                	beqz	a5,80001c3c <allocproc+0x40>
      release(&p->lock);
    80001c26:	8526                	mv	a0,s1
    80001c28:	fffff097          	auipc	ra,0xfffff
    80001c2c:	05e080e7          	jalr	94(ra) # 80000c86 <release>
  for(p = proc; p < &proc[NPROC]; p++) {
    80001c30:	16848493          	addi	s1,s1,360
    80001c34:	ff2492e3          	bne	s1,s2,80001c18 <allocproc+0x1c>
  return 0;
    80001c38:	4481                	li	s1,0
    80001c3a:	a889                	j	80001c8c <allocproc+0x90>
  p->pid = allocpid();
    80001c3c:	00000097          	auipc	ra,0x0
    80001c40:	e34080e7          	jalr	-460(ra) # 80001a70 <allocpid>
    80001c44:	d888                	sw	a0,48(s1)
  p->state = USED;
    80001c46:	4785                	li	a5,1
    80001c48:	cc9c                	sw	a5,24(s1)
  if((p->trapframe = (struct trapframe *)kalloc()) == 0){
    80001c4a:	fffff097          	auipc	ra,0xfffff
    80001c4e:	e98080e7          	jalr	-360(ra) # 80000ae2 <kalloc>
    80001c52:	892a                	mv	s2,a0
    80001c54:	eca8                	sd	a0,88(s1)
    80001c56:	c131                	beqz	a0,80001c9a <allocproc+0x9e>
  p->pagetable = proc_pagetable(p);
    80001c58:	8526                	mv	a0,s1
    80001c5a:	00000097          	auipc	ra,0x0
    80001c5e:	e5c080e7          	jalr	-420(ra) # 80001ab6 <proc_pagetable>
    80001c62:	892a                	mv	s2,a0
    80001c64:	e8a8                	sd	a0,80(s1)
  if(p->pagetable == 0){
    80001c66:	c531                	beqz	a0,80001cb2 <allocproc+0xb6>
  memset(&p->context, 0, sizeof(p->context));
    80001c68:	07000613          	li	a2,112
    80001c6c:	4581                	li	a1,0
    80001c6e:	06048513          	addi	a0,s1,96
    80001c72:	fffff097          	auipc	ra,0xfffff
    80001c76:	05c080e7          	jalr	92(ra) # 80000cce <memset>
  p->context.ra = (uint64)forkret;
    80001c7a:	00000797          	auipc	a5,0x0
    80001c7e:	d6478793          	addi	a5,a5,-668 # 800019de <forkret>
    80001c82:	f0bc                	sd	a5,96(s1)
  p->context.sp = p->kstack + PGSIZE;
    80001c84:	60bc                	ld	a5,64(s1)
    80001c86:	6705                	lui	a4,0x1
    80001c88:	97ba                	add	a5,a5,a4
    80001c8a:	f4bc                	sd	a5,104(s1)
}
    80001c8c:	8526                	mv	a0,s1
    80001c8e:	60e2                	ld	ra,24(sp)
    80001c90:	6442                	ld	s0,16(sp)
    80001c92:	64a2                	ld	s1,8(sp)
    80001c94:	6902                	ld	s2,0(sp)
    80001c96:	6105                	addi	sp,sp,32
    80001c98:	8082                	ret
    freeproc(p);
    80001c9a:	8526                	mv	a0,s1
    80001c9c:	00000097          	auipc	ra,0x0
    80001ca0:	f08080e7          	jalr	-248(ra) # 80001ba4 <freeproc>
    release(&p->lock);
    80001ca4:	8526                	mv	a0,s1
    80001ca6:	fffff097          	auipc	ra,0xfffff
    80001caa:	fe0080e7          	jalr	-32(ra) # 80000c86 <release>
    return 0;
    80001cae:	84ca                	mv	s1,s2
    80001cb0:	bff1                	j	80001c8c <allocproc+0x90>
    freeproc(p);
    80001cb2:	8526                	mv	a0,s1
    80001cb4:	00000097          	auipc	ra,0x0
    80001cb8:	ef0080e7          	jalr	-272(ra) # 80001ba4 <freeproc>
    release(&p->lock);
    80001cbc:	8526                	mv	a0,s1
    80001cbe:	fffff097          	auipc	ra,0xfffff
    80001cc2:	fc8080e7          	jalr	-56(ra) # 80000c86 <release>
    return 0;
    80001cc6:	84ca                	mv	s1,s2
    80001cc8:	b7d1                	j	80001c8c <allocproc+0x90>

0000000080001cca <userinit>:
{
    80001cca:	1101                	addi	sp,sp,-32
    80001ccc:	ec06                	sd	ra,24(sp)
    80001cce:	e822                	sd	s0,16(sp)
    80001cd0:	e426                	sd	s1,8(sp)
    80001cd2:	1000                	addi	s0,sp,32
  p = allocproc();
    80001cd4:	00000097          	auipc	ra,0x0
    80001cd8:	f28080e7          	jalr	-216(ra) # 80001bfc <allocproc>
    80001cdc:	84aa                	mv	s1,a0
  initproc = p;
    80001cde:	00007797          	auipc	a5,0x7
    80001ce2:	bea7b523          	sd	a0,-1046(a5) # 800088c8 <initproc>
  uvmfirst(p->pagetable, initcode, sizeof(initcode));
    80001ce6:	03400613          	li	a2,52
    80001cea:	00007597          	auipc	a1,0x7
    80001cee:	b7658593          	addi	a1,a1,-1162 # 80008860 <initcode>
    80001cf2:	6928                	ld	a0,80(a0)
    80001cf4:	fffff097          	auipc	ra,0xfffff
    80001cf8:	65c080e7          	jalr	1628(ra) # 80001350 <uvmfirst>
  p->sz = PGSIZE;
    80001cfc:	6785                	lui	a5,0x1
    80001cfe:	e4bc                	sd	a5,72(s1)
  p->trapframe->epc = 0;      // user program counter
    80001d00:	6cb8                	ld	a4,88(s1)
    80001d02:	00073c23          	sd	zero,24(a4) # 1018 <_entry-0x7fffefe8>
  p->trapframe->sp = PGSIZE;  // user stack pointer
    80001d06:	6cb8                	ld	a4,88(s1)
    80001d08:	fb1c                	sd	a5,48(a4)
  safestrcpy(p->name, "initcode", sizeof(p->name));
    80001d0a:	4641                	li	a2,16
    80001d0c:	00006597          	auipc	a1,0x6
    80001d10:	4f458593          	addi	a1,a1,1268 # 80008200 <digits+0x1c0>
    80001d14:	15848513          	addi	a0,s1,344
    80001d18:	fffff097          	auipc	ra,0xfffff
    80001d1c:	0fe080e7          	jalr	254(ra) # 80000e16 <safestrcpy>
  p->cwd = namei("/");
    80001d20:	00006517          	auipc	a0,0x6
    80001d24:	4f050513          	addi	a0,a0,1264 # 80008210 <digits+0x1d0>
    80001d28:	00002097          	auipc	ra,0x2
    80001d2c:	104080e7          	jalr	260(ra) # 80003e2c <namei>
    80001d30:	14a4b823          	sd	a0,336(s1)
  p->state = RUNNABLE;
    80001d34:	478d                	li	a5,3
    80001d36:	cc9c                	sw	a5,24(s1)
  release(&p->lock);
    80001d38:	8526                	mv	a0,s1
    80001d3a:	fffff097          	auipc	ra,0xfffff
    80001d3e:	f4c080e7          	jalr	-180(ra) # 80000c86 <release>
}
    80001d42:	60e2                	ld	ra,24(sp)
    80001d44:	6442                	ld	s0,16(sp)
    80001d46:	64a2                	ld	s1,8(sp)
    80001d48:	6105                	addi	sp,sp,32
    80001d4a:	8082                	ret

0000000080001d4c <growproc>:
{
    80001d4c:	1101                	addi	sp,sp,-32
    80001d4e:	ec06                	sd	ra,24(sp)
    80001d50:	e822                	sd	s0,16(sp)
    80001d52:	e426                	sd	s1,8(sp)
    80001d54:	e04a                	sd	s2,0(sp)
    80001d56:	1000                	addi	s0,sp,32
    80001d58:	892a                	mv	s2,a0
  struct proc *p = myproc();
    80001d5a:	00000097          	auipc	ra,0x0
    80001d5e:	c4c080e7          	jalr	-948(ra) # 800019a6 <myproc>
    80001d62:	84aa                	mv	s1,a0
  sz = p->sz;
    80001d64:	652c                	ld	a1,72(a0)
  if(n > 0){
    80001d66:	01204c63          	bgtz	s2,80001d7e <growproc+0x32>
  } else if(n < 0){
    80001d6a:	02094663          	bltz	s2,80001d96 <growproc+0x4a>
  p->sz = sz;
    80001d6e:	e4ac                	sd	a1,72(s1)
  return 0;
    80001d70:	4501                	li	a0,0
}
    80001d72:	60e2                	ld	ra,24(sp)
    80001d74:	6442                	ld	s0,16(sp)
    80001d76:	64a2                	ld	s1,8(sp)
    80001d78:	6902                	ld	s2,0(sp)
    80001d7a:	6105                	addi	sp,sp,32
    80001d7c:	8082                	ret
    if((sz = uvmalloc(p->pagetable, sz, sz + n, PTE_W)) == 0) {
    80001d7e:	4691                	li	a3,4
    80001d80:	00b90633          	add	a2,s2,a1
    80001d84:	6928                	ld	a0,80(a0)
    80001d86:	fffff097          	auipc	ra,0xfffff
    80001d8a:	684080e7          	jalr	1668(ra) # 8000140a <uvmalloc>
    80001d8e:	85aa                	mv	a1,a0
    80001d90:	fd79                	bnez	a0,80001d6e <growproc+0x22>
      return -1;
    80001d92:	557d                	li	a0,-1
    80001d94:	bff9                	j	80001d72 <growproc+0x26>
    sz = uvmdealloc(p->pagetable, sz, sz + n);
    80001d96:	00b90633          	add	a2,s2,a1
    80001d9a:	6928                	ld	a0,80(a0)
    80001d9c:	fffff097          	auipc	ra,0xfffff
    80001da0:	626080e7          	jalr	1574(ra) # 800013c2 <uvmdealloc>
    80001da4:	85aa                	mv	a1,a0
    80001da6:	b7e1                	j	80001d6e <growproc+0x22>

0000000080001da8 <fork>:
{
    80001da8:	7139                	addi	sp,sp,-64
    80001daa:	fc06                	sd	ra,56(sp)
    80001dac:	f822                	sd	s0,48(sp)
    80001dae:	f426                	sd	s1,40(sp)
    80001db0:	f04a                	sd	s2,32(sp)
    80001db2:	ec4e                	sd	s3,24(sp)
    80001db4:	e852                	sd	s4,16(sp)
    80001db6:	e456                	sd	s5,8(sp)
    80001db8:	0080                	addi	s0,sp,64
  struct proc *p = myproc();
    80001dba:	00000097          	auipc	ra,0x0
    80001dbe:	bec080e7          	jalr	-1044(ra) # 800019a6 <myproc>
    80001dc2:	8aaa                	mv	s5,a0
  if((np = allocproc()) == 0){
    80001dc4:	00000097          	auipc	ra,0x0
    80001dc8:	e38080e7          	jalr	-456(ra) # 80001bfc <allocproc>
    80001dcc:	10050c63          	beqz	a0,80001ee4 <fork+0x13c>
    80001dd0:	8a2a                	mv	s4,a0
  if(uvmcopy(p->pagetable, np->pagetable, p->sz) < 0){
    80001dd2:	048ab603          	ld	a2,72(s5)
    80001dd6:	692c                	ld	a1,80(a0)
    80001dd8:	050ab503          	ld	a0,80(s5)
    80001ddc:	fffff097          	auipc	ra,0xfffff
    80001de0:	786080e7          	jalr	1926(ra) # 80001562 <uvmcopy>
    80001de4:	04054863          	bltz	a0,80001e34 <fork+0x8c>
  np->sz = p->sz;
    80001de8:	048ab783          	ld	a5,72(s5)
    80001dec:	04fa3423          	sd	a5,72(s4)
  *(np->trapframe) = *(p->trapframe);
    80001df0:	058ab683          	ld	a3,88(s5)
    80001df4:	87b6                	mv	a5,a3
    80001df6:	058a3703          	ld	a4,88(s4)
    80001dfa:	12068693          	addi	a3,a3,288
    80001dfe:	0007b803          	ld	a6,0(a5) # 1000 <_entry-0x7ffff000>
    80001e02:	6788                	ld	a0,8(a5)
    80001e04:	6b8c                	ld	a1,16(a5)
    80001e06:	6f90                	ld	a2,24(a5)
    80001e08:	01073023          	sd	a6,0(a4)
    80001e0c:	e708                	sd	a0,8(a4)
    80001e0e:	eb0c                	sd	a1,16(a4)
    80001e10:	ef10                	sd	a2,24(a4)
    80001e12:	02078793          	addi	a5,a5,32
    80001e16:	02070713          	addi	a4,a4,32
    80001e1a:	fed792e3          	bne	a5,a3,80001dfe <fork+0x56>
  np->trapframe->a0 = 0;
    80001e1e:	058a3783          	ld	a5,88(s4)
    80001e22:	0607b823          	sd	zero,112(a5)
  for(i = 0; i < NOFILE; i++)
    80001e26:	0d0a8493          	addi	s1,s5,208
    80001e2a:	0d0a0913          	addi	s2,s4,208
    80001e2e:	150a8993          	addi	s3,s5,336
    80001e32:	a00d                	j	80001e54 <fork+0xac>
    freeproc(np);
    80001e34:	8552                	mv	a0,s4
    80001e36:	00000097          	auipc	ra,0x0
    80001e3a:	d6e080e7          	jalr	-658(ra) # 80001ba4 <freeproc>
    release(&np->lock);
    80001e3e:	8552                	mv	a0,s4
    80001e40:	fffff097          	auipc	ra,0xfffff
    80001e44:	e46080e7          	jalr	-442(ra) # 80000c86 <release>
    return -1;
    80001e48:	597d                	li	s2,-1
    80001e4a:	a059                	j	80001ed0 <fork+0x128>
  for(i = 0; i < NOFILE; i++)
    80001e4c:	04a1                	addi	s1,s1,8
    80001e4e:	0921                	addi	s2,s2,8
    80001e50:	01348b63          	beq	s1,s3,80001e66 <fork+0xbe>
    if(p->ofile[i])
    80001e54:	6088                	ld	a0,0(s1)
    80001e56:	d97d                	beqz	a0,80001e4c <fork+0xa4>
      np->ofile[i] = filedup(p->ofile[i]);
    80001e58:	00002097          	auipc	ra,0x2
    80001e5c:	646080e7          	jalr	1606(ra) # 8000449e <filedup>
    80001e60:	00a93023          	sd	a0,0(s2)
    80001e64:	b7e5                	j	80001e4c <fork+0xa4>
  np->cwd = idup(p->cwd);
    80001e66:	150ab503          	ld	a0,336(s5)
    80001e6a:	00001097          	auipc	ra,0x1
    80001e6e:	7de080e7          	jalr	2014(ra) # 80003648 <idup>
    80001e72:	14aa3823          	sd	a0,336(s4)
  safestrcpy(np->name, p->name, sizeof(p->name));
    80001e76:	4641                	li	a2,16
    80001e78:	158a8593          	addi	a1,s5,344
    80001e7c:	158a0513          	addi	a0,s4,344
    80001e80:	fffff097          	auipc	ra,0xfffff
    80001e84:	f96080e7          	jalr	-106(ra) # 80000e16 <safestrcpy>
  pid = np->pid;
    80001e88:	030a2903          	lw	s2,48(s4)
  release(&np->lock);
    80001e8c:	8552                	mv	a0,s4
    80001e8e:	fffff097          	auipc	ra,0xfffff
    80001e92:	df8080e7          	jalr	-520(ra) # 80000c86 <release>
  acquire(&wait_lock);
    80001e96:	0000f497          	auipc	s1,0xf
    80001e9a:	cc248493          	addi	s1,s1,-830 # 80010b58 <wait_lock>
    80001e9e:	8526                	mv	a0,s1
    80001ea0:	fffff097          	auipc	ra,0xfffff
    80001ea4:	d32080e7          	jalr	-718(ra) # 80000bd2 <acquire>
  np->parent = p;
    80001ea8:	035a3c23          	sd	s5,56(s4)
  release(&wait_lock);
    80001eac:	8526                	mv	a0,s1
    80001eae:	fffff097          	auipc	ra,0xfffff
    80001eb2:	dd8080e7          	jalr	-552(ra) # 80000c86 <release>
  acquire(&np->lock);
    80001eb6:	8552                	mv	a0,s4
    80001eb8:	fffff097          	auipc	ra,0xfffff
    80001ebc:	d1a080e7          	jalr	-742(ra) # 80000bd2 <acquire>
  np->state = RUNNABLE;
    80001ec0:	478d                	li	a5,3
    80001ec2:	00fa2c23          	sw	a5,24(s4)
  release(&np->lock);
    80001ec6:	8552                	mv	a0,s4
    80001ec8:	fffff097          	auipc	ra,0xfffff
    80001ecc:	dbe080e7          	jalr	-578(ra) # 80000c86 <release>
}
    80001ed0:	854a                	mv	a0,s2
    80001ed2:	70e2                	ld	ra,56(sp)
    80001ed4:	7442                	ld	s0,48(sp)
    80001ed6:	74a2                	ld	s1,40(sp)
    80001ed8:	7902                	ld	s2,32(sp)
    80001eda:	69e2                	ld	s3,24(sp)
    80001edc:	6a42                	ld	s4,16(sp)
    80001ede:	6aa2                	ld	s5,8(sp)
    80001ee0:	6121                	addi	sp,sp,64
    80001ee2:	8082                	ret
    return -1;
    80001ee4:	597d                	li	s2,-1
    80001ee6:	b7ed                	j	80001ed0 <fork+0x128>

0000000080001ee8 <scheduler>:
{
    80001ee8:	7139                	addi	sp,sp,-64
    80001eea:	fc06                	sd	ra,56(sp)
    80001eec:	f822                	sd	s0,48(sp)
    80001eee:	f426                	sd	s1,40(sp)
    80001ef0:	f04a                	sd	s2,32(sp)
    80001ef2:	ec4e                	sd	s3,24(sp)
    80001ef4:	e852                	sd	s4,16(sp)
    80001ef6:	e456                	sd	s5,8(sp)
    80001ef8:	e05a                	sd	s6,0(sp)
    80001efa:	0080                	addi	s0,sp,64
    80001efc:	8792                	mv	a5,tp
  int id = r_tp();
    80001efe:	2781                	sext.w	a5,a5
  c->proc = 0;
    80001f00:	00779a93          	slli	s5,a5,0x7
    80001f04:	0000f717          	auipc	a4,0xf
    80001f08:	c3c70713          	addi	a4,a4,-964 # 80010b40 <pid_lock>
    80001f0c:	9756                	add	a4,a4,s5
    80001f0e:	02073823          	sd	zero,48(a4)
        swtch(&c->context, &p->context);
    80001f12:	0000f717          	auipc	a4,0xf
    80001f16:	c6670713          	addi	a4,a4,-922 # 80010b78 <cpus+0x8>
    80001f1a:	9aba                	add	s5,s5,a4
      if(p->state == RUNNABLE) {
    80001f1c:	498d                	li	s3,3
        p->state = RUNNING;
    80001f1e:	4b11                	li	s6,4
        c->proc = p;
    80001f20:	079e                	slli	a5,a5,0x7
    80001f22:	0000fa17          	auipc	s4,0xf
    80001f26:	c1ea0a13          	addi	s4,s4,-994 # 80010b40 <pid_lock>
    80001f2a:	9a3e                	add	s4,s4,a5
    for(p = proc; p < &proc[NPROC]; p++) {
    80001f2c:	00015917          	auipc	s2,0x15
    80001f30:	a4490913          	addi	s2,s2,-1468 # 80016970 <tickslock>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80001f34:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80001f38:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80001f3c:	10079073          	csrw	sstatus,a5
    80001f40:	0000f497          	auipc	s1,0xf
    80001f44:	03048493          	addi	s1,s1,48 # 80010f70 <proc>
    80001f48:	a811                	j	80001f5c <scheduler+0x74>
      release(&p->lock);
    80001f4a:	8526                	mv	a0,s1
    80001f4c:	fffff097          	auipc	ra,0xfffff
    80001f50:	d3a080e7          	jalr	-710(ra) # 80000c86 <release>
    for(p = proc; p < &proc[NPROC]; p++) {
    80001f54:	16848493          	addi	s1,s1,360
    80001f58:	fd248ee3          	beq	s1,s2,80001f34 <scheduler+0x4c>
      acquire(&p->lock);
    80001f5c:	8526                	mv	a0,s1
    80001f5e:	fffff097          	auipc	ra,0xfffff
    80001f62:	c74080e7          	jalr	-908(ra) # 80000bd2 <acquire>
      if(p->state == RUNNABLE) {
    80001f66:	4c9c                	lw	a5,24(s1)
    80001f68:	ff3791e3          	bne	a5,s3,80001f4a <scheduler+0x62>
        p->state = RUNNING;
    80001f6c:	0164ac23          	sw	s6,24(s1)
        c->proc = p;
    80001f70:	029a3823          	sd	s1,48(s4)
        swtch(&c->context, &p->context);
    80001f74:	06048593          	addi	a1,s1,96
    80001f78:	8556                	mv	a0,s5
    80001f7a:	00000097          	auipc	ra,0x0
    80001f7e:	684080e7          	jalr	1668(ra) # 800025fe <swtch>
        c->proc = 0;
    80001f82:	020a3823          	sd	zero,48(s4)
    80001f86:	b7d1                	j	80001f4a <scheduler+0x62>

0000000080001f88 <sched>:
{
    80001f88:	7179                	addi	sp,sp,-48
    80001f8a:	f406                	sd	ra,40(sp)
    80001f8c:	f022                	sd	s0,32(sp)
    80001f8e:	ec26                	sd	s1,24(sp)
    80001f90:	e84a                	sd	s2,16(sp)
    80001f92:	e44e                	sd	s3,8(sp)
    80001f94:	1800                	addi	s0,sp,48
  struct proc *p = myproc();
    80001f96:	00000097          	auipc	ra,0x0
    80001f9a:	a10080e7          	jalr	-1520(ra) # 800019a6 <myproc>
    80001f9e:	84aa                	mv	s1,a0
  if(!holding(&p->lock))
    80001fa0:	fffff097          	auipc	ra,0xfffff
    80001fa4:	bb8080e7          	jalr	-1096(ra) # 80000b58 <holding>
    80001fa8:	c93d                	beqz	a0,8000201e <sched+0x96>
  asm volatile("mv %0, tp" : "=r" (x) );
    80001faa:	8792                	mv	a5,tp
  if(mycpu()->noff != 1)
    80001fac:	2781                	sext.w	a5,a5
    80001fae:	079e                	slli	a5,a5,0x7
    80001fb0:	0000f717          	auipc	a4,0xf
    80001fb4:	b9070713          	addi	a4,a4,-1136 # 80010b40 <pid_lock>
    80001fb8:	97ba                	add	a5,a5,a4
    80001fba:	0a87a703          	lw	a4,168(a5)
    80001fbe:	4785                	li	a5,1
    80001fc0:	06f71763          	bne	a4,a5,8000202e <sched+0xa6>
  if(p->state == RUNNING)
    80001fc4:	4c98                	lw	a4,24(s1)
    80001fc6:	4791                	li	a5,4
    80001fc8:	06f70b63          	beq	a4,a5,8000203e <sched+0xb6>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80001fcc:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80001fd0:	8b89                	andi	a5,a5,2
  if(intr_get())
    80001fd2:	efb5                	bnez	a5,8000204e <sched+0xc6>
  asm volatile("mv %0, tp" : "=r" (x) );
    80001fd4:	8792                	mv	a5,tp
  intena = mycpu()->intena;
    80001fd6:	0000f917          	auipc	s2,0xf
    80001fda:	b6a90913          	addi	s2,s2,-1174 # 80010b40 <pid_lock>
    80001fde:	2781                	sext.w	a5,a5
    80001fe0:	079e                	slli	a5,a5,0x7
    80001fe2:	97ca                	add	a5,a5,s2
    80001fe4:	0ac7a983          	lw	s3,172(a5)
    80001fe8:	8792                	mv	a5,tp
  swtch(&p->context, &mycpu()->context);
    80001fea:	2781                	sext.w	a5,a5
    80001fec:	079e                	slli	a5,a5,0x7
    80001fee:	0000f597          	auipc	a1,0xf
    80001ff2:	b8a58593          	addi	a1,a1,-1142 # 80010b78 <cpus+0x8>
    80001ff6:	95be                	add	a1,a1,a5
    80001ff8:	06048513          	addi	a0,s1,96
    80001ffc:	00000097          	auipc	ra,0x0
    80002000:	602080e7          	jalr	1538(ra) # 800025fe <swtch>
    80002004:	8792                	mv	a5,tp
  mycpu()->intena = intena;
    80002006:	2781                	sext.w	a5,a5
    80002008:	079e                	slli	a5,a5,0x7
    8000200a:	993e                	add	s2,s2,a5
    8000200c:	0b392623          	sw	s3,172(s2)
}
    80002010:	70a2                	ld	ra,40(sp)
    80002012:	7402                	ld	s0,32(sp)
    80002014:	64e2                	ld	s1,24(sp)
    80002016:	6942                	ld	s2,16(sp)
    80002018:	69a2                	ld	s3,8(sp)
    8000201a:	6145                	addi	sp,sp,48
    8000201c:	8082                	ret
    panic("sched p->lock");
    8000201e:	00006517          	auipc	a0,0x6
    80002022:	1fa50513          	addi	a0,a0,506 # 80008218 <digits+0x1d8>
    80002026:	ffffe097          	auipc	ra,0xffffe
    8000202a:	516080e7          	jalr	1302(ra) # 8000053c <panic>
    panic("sched locks");
    8000202e:	00006517          	auipc	a0,0x6
    80002032:	1fa50513          	addi	a0,a0,506 # 80008228 <digits+0x1e8>
    80002036:	ffffe097          	auipc	ra,0xffffe
    8000203a:	506080e7          	jalr	1286(ra) # 8000053c <panic>
    panic("sched running");
    8000203e:	00006517          	auipc	a0,0x6
    80002042:	1fa50513          	addi	a0,a0,506 # 80008238 <digits+0x1f8>
    80002046:	ffffe097          	auipc	ra,0xffffe
    8000204a:	4f6080e7          	jalr	1270(ra) # 8000053c <panic>
    panic("sched interruptible");
    8000204e:	00006517          	auipc	a0,0x6
    80002052:	1fa50513          	addi	a0,a0,506 # 80008248 <digits+0x208>
    80002056:	ffffe097          	auipc	ra,0xffffe
    8000205a:	4e6080e7          	jalr	1254(ra) # 8000053c <panic>

000000008000205e <yield>:
{
    8000205e:	1101                	addi	sp,sp,-32
    80002060:	ec06                	sd	ra,24(sp)
    80002062:	e822                	sd	s0,16(sp)
    80002064:	e426                	sd	s1,8(sp)
    80002066:	1000                	addi	s0,sp,32
  struct proc *p = myproc();
    80002068:	00000097          	auipc	ra,0x0
    8000206c:	93e080e7          	jalr	-1730(ra) # 800019a6 <myproc>
    80002070:	84aa                	mv	s1,a0
  acquire(&p->lock);
    80002072:	fffff097          	auipc	ra,0xfffff
    80002076:	b60080e7          	jalr	-1184(ra) # 80000bd2 <acquire>
  p->state = RUNNABLE;
    8000207a:	478d                	li	a5,3
    8000207c:	cc9c                	sw	a5,24(s1)
  sched();
    8000207e:	00000097          	auipc	ra,0x0
    80002082:	f0a080e7          	jalr	-246(ra) # 80001f88 <sched>
  release(&p->lock);
    80002086:	8526                	mv	a0,s1
    80002088:	fffff097          	auipc	ra,0xfffff
    8000208c:	bfe080e7          	jalr	-1026(ra) # 80000c86 <release>
}
    80002090:	60e2                	ld	ra,24(sp)
    80002092:	6442                	ld	s0,16(sp)
    80002094:	64a2                	ld	s1,8(sp)
    80002096:	6105                	addi	sp,sp,32
    80002098:	8082                	ret

000000008000209a <sleep>:

// Atomically release lock and sleep on chan.
// Reacquires lock when awakened.
void
sleep(void *chan, struct spinlock *lk)
{
    8000209a:	7179                	addi	sp,sp,-48
    8000209c:	f406                	sd	ra,40(sp)
    8000209e:	f022                	sd	s0,32(sp)
    800020a0:	ec26                	sd	s1,24(sp)
    800020a2:	e84a                	sd	s2,16(sp)
    800020a4:	e44e                	sd	s3,8(sp)
    800020a6:	1800                	addi	s0,sp,48
    800020a8:	89aa                	mv	s3,a0
    800020aa:	892e                	mv	s2,a1
  struct proc *p = myproc();
    800020ac:	00000097          	auipc	ra,0x0
    800020b0:	8fa080e7          	jalr	-1798(ra) # 800019a6 <myproc>
    800020b4:	84aa                	mv	s1,a0
  // Once we hold p->lock, we can be
  // guaranteed that we won't miss any wakeup
  // (wakeup locks p->lock),
  // so it's okay to release lk.

  acquire(&p->lock);  //DOC: sleeplock1
    800020b6:	fffff097          	auipc	ra,0xfffff
    800020ba:	b1c080e7          	jalr	-1252(ra) # 80000bd2 <acquire>
  release(lk);
    800020be:	854a                	mv	a0,s2
    800020c0:	fffff097          	auipc	ra,0xfffff
    800020c4:	bc6080e7          	jalr	-1082(ra) # 80000c86 <release>

  // Go to sleep.
  p->chan = chan;
    800020c8:	0334b023          	sd	s3,32(s1)
  p->state = SLEEPING;
    800020cc:	4789                	li	a5,2
    800020ce:	cc9c                	sw	a5,24(s1)

  sched();
    800020d0:	00000097          	auipc	ra,0x0
    800020d4:	eb8080e7          	jalr	-328(ra) # 80001f88 <sched>

  // Tidy up.
  p->chan = 0;
    800020d8:	0204b023          	sd	zero,32(s1)

  // Reacquire original lock.
  release(&p->lock);
    800020dc:	8526                	mv	a0,s1
    800020de:	fffff097          	auipc	ra,0xfffff
    800020e2:	ba8080e7          	jalr	-1112(ra) # 80000c86 <release>
  acquire(lk);
    800020e6:	854a                	mv	a0,s2
    800020e8:	fffff097          	auipc	ra,0xfffff
    800020ec:	aea080e7          	jalr	-1302(ra) # 80000bd2 <acquire>
}
    800020f0:	70a2                	ld	ra,40(sp)
    800020f2:	7402                	ld	s0,32(sp)
    800020f4:	64e2                	ld	s1,24(sp)
    800020f6:	6942                	ld	s2,16(sp)
    800020f8:	69a2                	ld	s3,8(sp)
    800020fa:	6145                	addi	sp,sp,48
    800020fc:	8082                	ret

00000000800020fe <wakeup>:

// Wake up all processes sleeping on chan.
// Must be called without any p->lock.
void
wakeup(void *chan)
{
    800020fe:	7139                	addi	sp,sp,-64
    80002100:	fc06                	sd	ra,56(sp)
    80002102:	f822                	sd	s0,48(sp)
    80002104:	f426                	sd	s1,40(sp)
    80002106:	f04a                	sd	s2,32(sp)
    80002108:	ec4e                	sd	s3,24(sp)
    8000210a:	e852                	sd	s4,16(sp)
    8000210c:	e456                	sd	s5,8(sp)
    8000210e:	0080                	addi	s0,sp,64
    80002110:	8a2a                	mv	s4,a0
  struct proc *p;

  for(p = proc; p < &proc[NPROC]; p++) {
    80002112:	0000f497          	auipc	s1,0xf
    80002116:	e5e48493          	addi	s1,s1,-418 # 80010f70 <proc>
    if(p != myproc()){
      acquire(&p->lock);
      if(p->state == SLEEPING && p->chan == chan) {
    8000211a:	4989                	li	s3,2
        p->state = RUNNABLE;
    8000211c:	4a8d                	li	s5,3
  for(p = proc; p < &proc[NPROC]; p++) {
    8000211e:	00015917          	auipc	s2,0x15
    80002122:	85290913          	addi	s2,s2,-1966 # 80016970 <tickslock>
    80002126:	a811                	j	8000213a <wakeup+0x3c>
      }
      release(&p->lock);
    80002128:	8526                	mv	a0,s1
    8000212a:	fffff097          	auipc	ra,0xfffff
    8000212e:	b5c080e7          	jalr	-1188(ra) # 80000c86 <release>
  for(p = proc; p < &proc[NPROC]; p++) {
    80002132:	16848493          	addi	s1,s1,360
    80002136:	03248663          	beq	s1,s2,80002162 <wakeup+0x64>
    if(p != myproc()){
    8000213a:	00000097          	auipc	ra,0x0
    8000213e:	86c080e7          	jalr	-1940(ra) # 800019a6 <myproc>
    80002142:	fea488e3          	beq	s1,a0,80002132 <wakeup+0x34>
      acquire(&p->lock);
    80002146:	8526                	mv	a0,s1
    80002148:	fffff097          	auipc	ra,0xfffff
    8000214c:	a8a080e7          	jalr	-1398(ra) # 80000bd2 <acquire>
      if(p->state == SLEEPING && p->chan == chan) {
    80002150:	4c9c                	lw	a5,24(s1)
    80002152:	fd379be3          	bne	a5,s3,80002128 <wakeup+0x2a>
    80002156:	709c                	ld	a5,32(s1)
    80002158:	fd4798e3          	bne	a5,s4,80002128 <wakeup+0x2a>
        p->state = RUNNABLE;
    8000215c:	0154ac23          	sw	s5,24(s1)
    80002160:	b7e1                	j	80002128 <wakeup+0x2a>
    }
  }
}
    80002162:	70e2                	ld	ra,56(sp)
    80002164:	7442                	ld	s0,48(sp)
    80002166:	74a2                	ld	s1,40(sp)
    80002168:	7902                	ld	s2,32(sp)
    8000216a:	69e2                	ld	s3,24(sp)
    8000216c:	6a42                	ld	s4,16(sp)
    8000216e:	6aa2                	ld	s5,8(sp)
    80002170:	6121                	addi	sp,sp,64
    80002172:	8082                	ret

0000000080002174 <reparent>:
{
    80002174:	7179                	addi	sp,sp,-48
    80002176:	f406                	sd	ra,40(sp)
    80002178:	f022                	sd	s0,32(sp)
    8000217a:	ec26                	sd	s1,24(sp)
    8000217c:	e84a                	sd	s2,16(sp)
    8000217e:	e44e                	sd	s3,8(sp)
    80002180:	e052                	sd	s4,0(sp)
    80002182:	1800                	addi	s0,sp,48
    80002184:	892a                	mv	s2,a0
  for(pp = proc; pp < &proc[NPROC]; pp++){
    80002186:	0000f497          	auipc	s1,0xf
    8000218a:	dea48493          	addi	s1,s1,-534 # 80010f70 <proc>
      pp->parent = initproc;
    8000218e:	00006a17          	auipc	s4,0x6
    80002192:	73aa0a13          	addi	s4,s4,1850 # 800088c8 <initproc>
  for(pp = proc; pp < &proc[NPROC]; pp++){
    80002196:	00014997          	auipc	s3,0x14
    8000219a:	7da98993          	addi	s3,s3,2010 # 80016970 <tickslock>
    8000219e:	a029                	j	800021a8 <reparent+0x34>
    800021a0:	16848493          	addi	s1,s1,360
    800021a4:	01348d63          	beq	s1,s3,800021be <reparent+0x4a>
    if(pp->parent == p){
    800021a8:	7c9c                	ld	a5,56(s1)
    800021aa:	ff279be3          	bne	a5,s2,800021a0 <reparent+0x2c>
      pp->parent = initproc;
    800021ae:	000a3503          	ld	a0,0(s4)
    800021b2:	fc88                	sd	a0,56(s1)
      wakeup(initproc);
    800021b4:	00000097          	auipc	ra,0x0
    800021b8:	f4a080e7          	jalr	-182(ra) # 800020fe <wakeup>
    800021bc:	b7d5                	j	800021a0 <reparent+0x2c>
}
    800021be:	70a2                	ld	ra,40(sp)
    800021c0:	7402                	ld	s0,32(sp)
    800021c2:	64e2                	ld	s1,24(sp)
    800021c4:	6942                	ld	s2,16(sp)
    800021c6:	69a2                	ld	s3,8(sp)
    800021c8:	6a02                	ld	s4,0(sp)
    800021ca:	6145                	addi	sp,sp,48
    800021cc:	8082                	ret

00000000800021ce <exit>:
{
    800021ce:	7179                	addi	sp,sp,-48
    800021d0:	f406                	sd	ra,40(sp)
    800021d2:	f022                	sd	s0,32(sp)
    800021d4:	ec26                	sd	s1,24(sp)
    800021d6:	e84a                	sd	s2,16(sp)
    800021d8:	e44e                	sd	s3,8(sp)
    800021da:	e052                	sd	s4,0(sp)
    800021dc:	1800                	addi	s0,sp,48
    800021de:	8a2a                	mv	s4,a0
  struct proc *p = myproc();
    800021e0:	fffff097          	auipc	ra,0xfffff
    800021e4:	7c6080e7          	jalr	1990(ra) # 800019a6 <myproc>
    800021e8:	89aa                	mv	s3,a0
  if(p == initproc)
    800021ea:	00006797          	auipc	a5,0x6
    800021ee:	6de7b783          	ld	a5,1758(a5) # 800088c8 <initproc>
    800021f2:	0d050493          	addi	s1,a0,208
    800021f6:	15050913          	addi	s2,a0,336
    800021fa:	02a79363          	bne	a5,a0,80002220 <exit+0x52>
    panic("init exiting");
    800021fe:	00006517          	auipc	a0,0x6
    80002202:	06250513          	addi	a0,a0,98 # 80008260 <digits+0x220>
    80002206:	ffffe097          	auipc	ra,0xffffe
    8000220a:	336080e7          	jalr	822(ra) # 8000053c <panic>
      fileclose(f);
    8000220e:	00002097          	auipc	ra,0x2
    80002212:	2e2080e7          	jalr	738(ra) # 800044f0 <fileclose>
      p->ofile[fd] = 0;
    80002216:	0004b023          	sd	zero,0(s1)
  for(int fd = 0; fd < NOFILE; fd++){
    8000221a:	04a1                	addi	s1,s1,8
    8000221c:	01248563          	beq	s1,s2,80002226 <exit+0x58>
    if(p->ofile[fd]){
    80002220:	6088                	ld	a0,0(s1)
    80002222:	f575                	bnez	a0,8000220e <exit+0x40>
    80002224:	bfdd                	j	8000221a <exit+0x4c>
  begin_op();
    80002226:	00002097          	auipc	ra,0x2
    8000222a:	e06080e7          	jalr	-506(ra) # 8000402c <begin_op>
  iput(p->cwd);
    8000222e:	1509b503          	ld	a0,336(s3)
    80002232:	00001097          	auipc	ra,0x1
    80002236:	60e080e7          	jalr	1550(ra) # 80003840 <iput>
  end_op();
    8000223a:	00002097          	auipc	ra,0x2
    8000223e:	e6c080e7          	jalr	-404(ra) # 800040a6 <end_op>
  p->cwd = 0;
    80002242:	1409b823          	sd	zero,336(s3)
  acquire(&wait_lock);
    80002246:	0000f497          	auipc	s1,0xf
    8000224a:	91248493          	addi	s1,s1,-1774 # 80010b58 <wait_lock>
    8000224e:	8526                	mv	a0,s1
    80002250:	fffff097          	auipc	ra,0xfffff
    80002254:	982080e7          	jalr	-1662(ra) # 80000bd2 <acquire>
  reparent(p);
    80002258:	854e                	mv	a0,s3
    8000225a:	00000097          	auipc	ra,0x0
    8000225e:	f1a080e7          	jalr	-230(ra) # 80002174 <reparent>
  wakeup(p->parent);
    80002262:	0389b503          	ld	a0,56(s3)
    80002266:	00000097          	auipc	ra,0x0
    8000226a:	e98080e7          	jalr	-360(ra) # 800020fe <wakeup>
  acquire(&p->lock);
    8000226e:	854e                	mv	a0,s3
    80002270:	fffff097          	auipc	ra,0xfffff
    80002274:	962080e7          	jalr	-1694(ra) # 80000bd2 <acquire>
  p->xstate = status;
    80002278:	0349a623          	sw	s4,44(s3)
  p->state = ZOMBIE;
    8000227c:	4795                	li	a5,5
    8000227e:	00f9ac23          	sw	a5,24(s3)
  release(&wait_lock);
    80002282:	8526                	mv	a0,s1
    80002284:	fffff097          	auipc	ra,0xfffff
    80002288:	a02080e7          	jalr	-1534(ra) # 80000c86 <release>
  sched();
    8000228c:	00000097          	auipc	ra,0x0
    80002290:	cfc080e7          	jalr	-772(ra) # 80001f88 <sched>
  panic("zombie exit");
    80002294:	00006517          	auipc	a0,0x6
    80002298:	fdc50513          	addi	a0,a0,-36 # 80008270 <digits+0x230>
    8000229c:	ffffe097          	auipc	ra,0xffffe
    800022a0:	2a0080e7          	jalr	672(ra) # 8000053c <panic>

00000000800022a4 <kill>:
// Kill the process with the given pid.
// The victim won't exit until it tries to return
// to user space (see usertrap() in trap.c).
int
kill(int pid)
{
    800022a4:	7179                	addi	sp,sp,-48
    800022a6:	f406                	sd	ra,40(sp)
    800022a8:	f022                	sd	s0,32(sp)
    800022aa:	ec26                	sd	s1,24(sp)
    800022ac:	e84a                	sd	s2,16(sp)
    800022ae:	e44e                	sd	s3,8(sp)
    800022b0:	1800                	addi	s0,sp,48
    800022b2:	892a                	mv	s2,a0
  struct proc *p;

  for(p = proc; p < &proc[NPROC]; p++){
    800022b4:	0000f497          	auipc	s1,0xf
    800022b8:	cbc48493          	addi	s1,s1,-836 # 80010f70 <proc>
    800022bc:	00014997          	auipc	s3,0x14
    800022c0:	6b498993          	addi	s3,s3,1716 # 80016970 <tickslock>
    acquire(&p->lock);
    800022c4:	8526                	mv	a0,s1
    800022c6:	fffff097          	auipc	ra,0xfffff
    800022ca:	90c080e7          	jalr	-1780(ra) # 80000bd2 <acquire>
    if(p->pid == pid){
    800022ce:	589c                	lw	a5,48(s1)
    800022d0:	01278d63          	beq	a5,s2,800022ea <kill+0x46>
        p->state = RUNNABLE;
      }
      release(&p->lock);
      return 0;
    }
    release(&p->lock);
    800022d4:	8526                	mv	a0,s1
    800022d6:	fffff097          	auipc	ra,0xfffff
    800022da:	9b0080e7          	jalr	-1616(ra) # 80000c86 <release>
  for(p = proc; p < &proc[NPROC]; p++){
    800022de:	16848493          	addi	s1,s1,360
    800022e2:	ff3491e3          	bne	s1,s3,800022c4 <kill+0x20>
  }
  return -1;
    800022e6:	557d                	li	a0,-1
    800022e8:	a829                	j	80002302 <kill+0x5e>
      p->killed = 1;
    800022ea:	4785                	li	a5,1
    800022ec:	d49c                	sw	a5,40(s1)
      if(p->state == SLEEPING){
    800022ee:	4c98                	lw	a4,24(s1)
    800022f0:	4789                	li	a5,2
    800022f2:	00f70f63          	beq	a4,a5,80002310 <kill+0x6c>
      release(&p->lock);
    800022f6:	8526                	mv	a0,s1
    800022f8:	fffff097          	auipc	ra,0xfffff
    800022fc:	98e080e7          	jalr	-1650(ra) # 80000c86 <release>
      return 0;
    80002300:	4501                	li	a0,0
}
    80002302:	70a2                	ld	ra,40(sp)
    80002304:	7402                	ld	s0,32(sp)
    80002306:	64e2                	ld	s1,24(sp)
    80002308:	6942                	ld	s2,16(sp)
    8000230a:	69a2                	ld	s3,8(sp)
    8000230c:	6145                	addi	sp,sp,48
    8000230e:	8082                	ret
        p->state = RUNNABLE;
    80002310:	478d                	li	a5,3
    80002312:	cc9c                	sw	a5,24(s1)
    80002314:	b7cd                	j	800022f6 <kill+0x52>

0000000080002316 <setkilled>:

void
setkilled(struct proc *p)
{
    80002316:	1101                	addi	sp,sp,-32
    80002318:	ec06                	sd	ra,24(sp)
    8000231a:	e822                	sd	s0,16(sp)
    8000231c:	e426                	sd	s1,8(sp)
    8000231e:	1000                	addi	s0,sp,32
    80002320:	84aa                	mv	s1,a0
  acquire(&p->lock);
    80002322:	fffff097          	auipc	ra,0xfffff
    80002326:	8b0080e7          	jalr	-1872(ra) # 80000bd2 <acquire>
  p->killed = 1;
    8000232a:	4785                	li	a5,1
    8000232c:	d49c                	sw	a5,40(s1)
  release(&p->lock);
    8000232e:	8526                	mv	a0,s1
    80002330:	fffff097          	auipc	ra,0xfffff
    80002334:	956080e7          	jalr	-1706(ra) # 80000c86 <release>
}
    80002338:	60e2                	ld	ra,24(sp)
    8000233a:	6442                	ld	s0,16(sp)
    8000233c:	64a2                	ld	s1,8(sp)
    8000233e:	6105                	addi	sp,sp,32
    80002340:	8082                	ret

0000000080002342 <killed>:

int
killed(struct proc *p)
{
    80002342:	1101                	addi	sp,sp,-32
    80002344:	ec06                	sd	ra,24(sp)
    80002346:	e822                	sd	s0,16(sp)
    80002348:	e426                	sd	s1,8(sp)
    8000234a:	e04a                	sd	s2,0(sp)
    8000234c:	1000                	addi	s0,sp,32
    8000234e:	84aa                	mv	s1,a0
  int k;
  
  acquire(&p->lock);
    80002350:	fffff097          	auipc	ra,0xfffff
    80002354:	882080e7          	jalr	-1918(ra) # 80000bd2 <acquire>
  k = p->killed;
    80002358:	0284a903          	lw	s2,40(s1)
  release(&p->lock);
    8000235c:	8526                	mv	a0,s1
    8000235e:	fffff097          	auipc	ra,0xfffff
    80002362:	928080e7          	jalr	-1752(ra) # 80000c86 <release>
  return k;
}
    80002366:	854a                	mv	a0,s2
    80002368:	60e2                	ld	ra,24(sp)
    8000236a:	6442                	ld	s0,16(sp)
    8000236c:	64a2                	ld	s1,8(sp)
    8000236e:	6902                	ld	s2,0(sp)
    80002370:	6105                	addi	sp,sp,32
    80002372:	8082                	ret

0000000080002374 <wait>:
{
    80002374:	715d                	addi	sp,sp,-80
    80002376:	e486                	sd	ra,72(sp)
    80002378:	e0a2                	sd	s0,64(sp)
    8000237a:	fc26                	sd	s1,56(sp)
    8000237c:	f84a                	sd	s2,48(sp)
    8000237e:	f44e                	sd	s3,40(sp)
    80002380:	f052                	sd	s4,32(sp)
    80002382:	ec56                	sd	s5,24(sp)
    80002384:	e85a                	sd	s6,16(sp)
    80002386:	e45e                	sd	s7,8(sp)
    80002388:	e062                	sd	s8,0(sp)
    8000238a:	0880                	addi	s0,sp,80
    8000238c:	8b2a                	mv	s6,a0
  struct proc *p = myproc();
    8000238e:	fffff097          	auipc	ra,0xfffff
    80002392:	618080e7          	jalr	1560(ra) # 800019a6 <myproc>
    80002396:	892a                	mv	s2,a0
  acquire(&wait_lock);
    80002398:	0000e517          	auipc	a0,0xe
    8000239c:	7c050513          	addi	a0,a0,1984 # 80010b58 <wait_lock>
    800023a0:	fffff097          	auipc	ra,0xfffff
    800023a4:	832080e7          	jalr	-1998(ra) # 80000bd2 <acquire>
    havekids = 0;
    800023a8:	4b81                	li	s7,0
        if(pp->state == ZOMBIE){
    800023aa:	4a15                	li	s4,5
        havekids = 1;
    800023ac:	4a85                	li	s5,1
    for(pp = proc; pp < &proc[NPROC]; pp++){
    800023ae:	00014997          	auipc	s3,0x14
    800023b2:	5c298993          	addi	s3,s3,1474 # 80016970 <tickslock>
    sleep(p, &wait_lock);  //DOC: wait-sleep
    800023b6:	0000ec17          	auipc	s8,0xe
    800023ba:	7a2c0c13          	addi	s8,s8,1954 # 80010b58 <wait_lock>
    800023be:	a0d1                	j	80002482 <wait+0x10e>
          pid = pp->pid;
    800023c0:	0304a983          	lw	s3,48(s1)
          if(addr != 0 && copyout(p->pagetable, addr, (char *)&pp->xstate,
    800023c4:	000b0e63          	beqz	s6,800023e0 <wait+0x6c>
    800023c8:	4691                	li	a3,4
    800023ca:	02c48613          	addi	a2,s1,44
    800023ce:	85da                	mv	a1,s6
    800023d0:	05093503          	ld	a0,80(s2)
    800023d4:	fffff097          	auipc	ra,0xfffff
    800023d8:	292080e7          	jalr	658(ra) # 80001666 <copyout>
    800023dc:	04054163          	bltz	a0,8000241e <wait+0xaa>
          freeproc(pp);
    800023e0:	8526                	mv	a0,s1
    800023e2:	fffff097          	auipc	ra,0xfffff
    800023e6:	7c2080e7          	jalr	1986(ra) # 80001ba4 <freeproc>
          release(&pp->lock);
    800023ea:	8526                	mv	a0,s1
    800023ec:	fffff097          	auipc	ra,0xfffff
    800023f0:	89a080e7          	jalr	-1894(ra) # 80000c86 <release>
          release(&wait_lock);
    800023f4:	0000e517          	auipc	a0,0xe
    800023f8:	76450513          	addi	a0,a0,1892 # 80010b58 <wait_lock>
    800023fc:	fffff097          	auipc	ra,0xfffff
    80002400:	88a080e7          	jalr	-1910(ra) # 80000c86 <release>
}
    80002404:	854e                	mv	a0,s3
    80002406:	60a6                	ld	ra,72(sp)
    80002408:	6406                	ld	s0,64(sp)
    8000240a:	74e2                	ld	s1,56(sp)
    8000240c:	7942                	ld	s2,48(sp)
    8000240e:	79a2                	ld	s3,40(sp)
    80002410:	7a02                	ld	s4,32(sp)
    80002412:	6ae2                	ld	s5,24(sp)
    80002414:	6b42                	ld	s6,16(sp)
    80002416:	6ba2                	ld	s7,8(sp)
    80002418:	6c02                	ld	s8,0(sp)
    8000241a:	6161                	addi	sp,sp,80
    8000241c:	8082                	ret
            release(&pp->lock);
    8000241e:	8526                	mv	a0,s1
    80002420:	fffff097          	auipc	ra,0xfffff
    80002424:	866080e7          	jalr	-1946(ra) # 80000c86 <release>
            release(&wait_lock);
    80002428:	0000e517          	auipc	a0,0xe
    8000242c:	73050513          	addi	a0,a0,1840 # 80010b58 <wait_lock>
    80002430:	fffff097          	auipc	ra,0xfffff
    80002434:	856080e7          	jalr	-1962(ra) # 80000c86 <release>
            return -1;
    80002438:	59fd                	li	s3,-1
    8000243a:	b7e9                	j	80002404 <wait+0x90>
    for(pp = proc; pp < &proc[NPROC]; pp++){
    8000243c:	16848493          	addi	s1,s1,360
    80002440:	03348463          	beq	s1,s3,80002468 <wait+0xf4>
      if(pp->parent == p){
    80002444:	7c9c                	ld	a5,56(s1)
    80002446:	ff279be3          	bne	a5,s2,8000243c <wait+0xc8>
        acquire(&pp->lock);
    8000244a:	8526                	mv	a0,s1
    8000244c:	ffffe097          	auipc	ra,0xffffe
    80002450:	786080e7          	jalr	1926(ra) # 80000bd2 <acquire>
        if(pp->state == ZOMBIE){
    80002454:	4c9c                	lw	a5,24(s1)
    80002456:	f74785e3          	beq	a5,s4,800023c0 <wait+0x4c>
        release(&pp->lock);
    8000245a:	8526                	mv	a0,s1
    8000245c:	fffff097          	auipc	ra,0xfffff
    80002460:	82a080e7          	jalr	-2006(ra) # 80000c86 <release>
        havekids = 1;
    80002464:	8756                	mv	a4,s5
    80002466:	bfd9                	j	8000243c <wait+0xc8>
    if(!havekids || killed(p)){
    80002468:	c31d                	beqz	a4,8000248e <wait+0x11a>
    8000246a:	854a                	mv	a0,s2
    8000246c:	00000097          	auipc	ra,0x0
    80002470:	ed6080e7          	jalr	-298(ra) # 80002342 <killed>
    80002474:	ed09                	bnez	a0,8000248e <wait+0x11a>
    sleep(p, &wait_lock);  //DOC: wait-sleep
    80002476:	85e2                	mv	a1,s8
    80002478:	854a                	mv	a0,s2
    8000247a:	00000097          	auipc	ra,0x0
    8000247e:	c20080e7          	jalr	-992(ra) # 8000209a <sleep>
    havekids = 0;
    80002482:	875e                	mv	a4,s7
    for(pp = proc; pp < &proc[NPROC]; pp++){
    80002484:	0000f497          	auipc	s1,0xf
    80002488:	aec48493          	addi	s1,s1,-1300 # 80010f70 <proc>
    8000248c:	bf65                	j	80002444 <wait+0xd0>
      release(&wait_lock);
    8000248e:	0000e517          	auipc	a0,0xe
    80002492:	6ca50513          	addi	a0,a0,1738 # 80010b58 <wait_lock>
    80002496:	ffffe097          	auipc	ra,0xffffe
    8000249a:	7f0080e7          	jalr	2032(ra) # 80000c86 <release>
      return -1;
    8000249e:	59fd                	li	s3,-1
    800024a0:	b795                	j	80002404 <wait+0x90>

00000000800024a2 <either_copyout>:
// Copy to either a user address, or kernel address,
// depending on usr_dst.
// Returns 0 on success, -1 on error.
int
either_copyout(int user_dst, uint64 dst, void *src, uint64 len)
{
    800024a2:	7179                	addi	sp,sp,-48
    800024a4:	f406                	sd	ra,40(sp)
    800024a6:	f022                	sd	s0,32(sp)
    800024a8:	ec26                	sd	s1,24(sp)
    800024aa:	e84a                	sd	s2,16(sp)
    800024ac:	e44e                	sd	s3,8(sp)
    800024ae:	e052                	sd	s4,0(sp)
    800024b0:	1800                	addi	s0,sp,48
    800024b2:	84aa                	mv	s1,a0
    800024b4:	892e                	mv	s2,a1
    800024b6:	89b2                	mv	s3,a2
    800024b8:	8a36                	mv	s4,a3
  struct proc *p = myproc();
    800024ba:	fffff097          	auipc	ra,0xfffff
    800024be:	4ec080e7          	jalr	1260(ra) # 800019a6 <myproc>
  if(user_dst){
    800024c2:	c08d                	beqz	s1,800024e4 <either_copyout+0x42>
    return copyout(p->pagetable, dst, src, len);
    800024c4:	86d2                	mv	a3,s4
    800024c6:	864e                	mv	a2,s3
    800024c8:	85ca                	mv	a1,s2
    800024ca:	6928                	ld	a0,80(a0)
    800024cc:	fffff097          	auipc	ra,0xfffff
    800024d0:	19a080e7          	jalr	410(ra) # 80001666 <copyout>
  } else {
    memmove((char *)dst, src, len);
    return 0;
  }
}
    800024d4:	70a2                	ld	ra,40(sp)
    800024d6:	7402                	ld	s0,32(sp)
    800024d8:	64e2                	ld	s1,24(sp)
    800024da:	6942                	ld	s2,16(sp)
    800024dc:	69a2                	ld	s3,8(sp)
    800024de:	6a02                	ld	s4,0(sp)
    800024e0:	6145                	addi	sp,sp,48
    800024e2:	8082                	ret
    memmove((char *)dst, src, len);
    800024e4:	000a061b          	sext.w	a2,s4
    800024e8:	85ce                	mv	a1,s3
    800024ea:	854a                	mv	a0,s2
    800024ec:	fffff097          	auipc	ra,0xfffff
    800024f0:	83e080e7          	jalr	-1986(ra) # 80000d2a <memmove>
    return 0;
    800024f4:	8526                	mv	a0,s1
    800024f6:	bff9                	j	800024d4 <either_copyout+0x32>

00000000800024f8 <either_copyin>:
// Copy from either a user address, or kernel address,
// depending on usr_src.
// Returns 0 on success, -1 on error.
int
either_copyin(void *dst, int user_src, uint64 src, uint64 len)
{
    800024f8:	7179                	addi	sp,sp,-48
    800024fa:	f406                	sd	ra,40(sp)
    800024fc:	f022                	sd	s0,32(sp)
    800024fe:	ec26                	sd	s1,24(sp)
    80002500:	e84a                	sd	s2,16(sp)
    80002502:	e44e                	sd	s3,8(sp)
    80002504:	e052                	sd	s4,0(sp)
    80002506:	1800                	addi	s0,sp,48
    80002508:	892a                	mv	s2,a0
    8000250a:	84ae                	mv	s1,a1
    8000250c:	89b2                	mv	s3,a2
    8000250e:	8a36                	mv	s4,a3
  struct proc *p = myproc();
    80002510:	fffff097          	auipc	ra,0xfffff
    80002514:	496080e7          	jalr	1174(ra) # 800019a6 <myproc>
  if(user_src){
    80002518:	c08d                	beqz	s1,8000253a <either_copyin+0x42>
    return copyin(p->pagetable, dst, src, len);
    8000251a:	86d2                	mv	a3,s4
    8000251c:	864e                	mv	a2,s3
    8000251e:	85ca                	mv	a1,s2
    80002520:	6928                	ld	a0,80(a0)
    80002522:	fffff097          	auipc	ra,0xfffff
    80002526:	1d0080e7          	jalr	464(ra) # 800016f2 <copyin>
  } else {
    memmove(dst, (char*)src, len);
    return 0;
  }
}
    8000252a:	70a2                	ld	ra,40(sp)
    8000252c:	7402                	ld	s0,32(sp)
    8000252e:	64e2                	ld	s1,24(sp)
    80002530:	6942                	ld	s2,16(sp)
    80002532:	69a2                	ld	s3,8(sp)
    80002534:	6a02                	ld	s4,0(sp)
    80002536:	6145                	addi	sp,sp,48
    80002538:	8082                	ret
    memmove(dst, (char*)src, len);
    8000253a:	000a061b          	sext.w	a2,s4
    8000253e:	85ce                	mv	a1,s3
    80002540:	854a                	mv	a0,s2
    80002542:	ffffe097          	auipc	ra,0xffffe
    80002546:	7e8080e7          	jalr	2024(ra) # 80000d2a <memmove>
    return 0;
    8000254a:	8526                	mv	a0,s1
    8000254c:	bff9                	j	8000252a <either_copyin+0x32>

000000008000254e <procdump>:
// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void
procdump(void)
{
    8000254e:	715d                	addi	sp,sp,-80
    80002550:	e486                	sd	ra,72(sp)
    80002552:	e0a2                	sd	s0,64(sp)
    80002554:	fc26                	sd	s1,56(sp)
    80002556:	f84a                	sd	s2,48(sp)
    80002558:	f44e                	sd	s3,40(sp)
    8000255a:	f052                	sd	s4,32(sp)
    8000255c:	ec56                	sd	s5,24(sp)
    8000255e:	e85a                	sd	s6,16(sp)
    80002560:	e45e                	sd	s7,8(sp)
    80002562:	0880                	addi	s0,sp,80
  [ZOMBIE]    "zombie"
  };
  struct proc *p;
  char *state;

  printf("\n");
    80002564:	00006517          	auipc	a0,0x6
    80002568:	b6450513          	addi	a0,a0,-1180 # 800080c8 <digits+0x88>
    8000256c:	ffffe097          	auipc	ra,0xffffe
    80002570:	01a080e7          	jalr	26(ra) # 80000586 <printf>
  for(p = proc; p < &proc[NPROC]; p++){
    80002574:	0000f497          	auipc	s1,0xf
    80002578:	b5448493          	addi	s1,s1,-1196 # 800110c8 <proc+0x158>
    8000257c:	00014917          	auipc	s2,0x14
    80002580:	54c90913          	addi	s2,s2,1356 # 80016ac8 <bcache+0x140>
    if(p->state == UNUSED)
      continue;
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    80002584:	4b15                	li	s6,5
      state = states[p->state];
    else
      state = "???";
    80002586:	00006997          	auipc	s3,0x6
    8000258a:	cfa98993          	addi	s3,s3,-774 # 80008280 <digits+0x240>
    printf("%d %s %s", p->pid, state, p->name);
    8000258e:	00006a97          	auipc	s5,0x6
    80002592:	cfaa8a93          	addi	s5,s5,-774 # 80008288 <digits+0x248>
    printf("\n");
    80002596:	00006a17          	auipc	s4,0x6
    8000259a:	b32a0a13          	addi	s4,s4,-1230 # 800080c8 <digits+0x88>
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    8000259e:	00006b97          	auipc	s7,0x6
    800025a2:	d2ab8b93          	addi	s7,s7,-726 # 800082c8 <states.0>
    800025a6:	a00d                	j	800025c8 <procdump+0x7a>
    printf("%d %s %s", p->pid, state, p->name);
    800025a8:	ed86a583          	lw	a1,-296(a3)
    800025ac:	8556                	mv	a0,s5
    800025ae:	ffffe097          	auipc	ra,0xffffe
    800025b2:	fd8080e7          	jalr	-40(ra) # 80000586 <printf>
    printf("\n");
    800025b6:	8552                	mv	a0,s4
    800025b8:	ffffe097          	auipc	ra,0xffffe
    800025bc:	fce080e7          	jalr	-50(ra) # 80000586 <printf>
  for(p = proc; p < &proc[NPROC]; p++){
    800025c0:	16848493          	addi	s1,s1,360
    800025c4:	03248263          	beq	s1,s2,800025e8 <procdump+0x9a>
    if(p->state == UNUSED)
    800025c8:	86a6                	mv	a3,s1
    800025ca:	ec04a783          	lw	a5,-320(s1)
    800025ce:	dbed                	beqz	a5,800025c0 <procdump+0x72>
      state = "???";
    800025d0:	864e                	mv	a2,s3
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    800025d2:	fcfb6be3          	bltu	s6,a5,800025a8 <procdump+0x5a>
    800025d6:	02079713          	slli	a4,a5,0x20
    800025da:	01d75793          	srli	a5,a4,0x1d
    800025de:	97de                	add	a5,a5,s7
    800025e0:	6390                	ld	a2,0(a5)
    800025e2:	f279                	bnez	a2,800025a8 <procdump+0x5a>
      state = "???";
    800025e4:	864e                	mv	a2,s3
    800025e6:	b7c9                	j	800025a8 <procdump+0x5a>
  }
}
    800025e8:	60a6                	ld	ra,72(sp)
    800025ea:	6406                	ld	s0,64(sp)
    800025ec:	74e2                	ld	s1,56(sp)
    800025ee:	7942                	ld	s2,48(sp)
    800025f0:	79a2                	ld	s3,40(sp)
    800025f2:	7a02                	ld	s4,32(sp)
    800025f4:	6ae2                	ld	s5,24(sp)
    800025f6:	6b42                	ld	s6,16(sp)
    800025f8:	6ba2                	ld	s7,8(sp)
    800025fa:	6161                	addi	sp,sp,80
    800025fc:	8082                	ret

00000000800025fe <swtch>:
    800025fe:	00153023          	sd	ra,0(a0)
    80002602:	00253423          	sd	sp,8(a0)
    80002606:	e900                	sd	s0,16(a0)
    80002608:	ed04                	sd	s1,24(a0)
    8000260a:	03253023          	sd	s2,32(a0)
    8000260e:	03353423          	sd	s3,40(a0)
    80002612:	03453823          	sd	s4,48(a0)
    80002616:	03553c23          	sd	s5,56(a0)
    8000261a:	05653023          	sd	s6,64(a0)
    8000261e:	05753423          	sd	s7,72(a0)
    80002622:	05853823          	sd	s8,80(a0)
    80002626:	05953c23          	sd	s9,88(a0)
    8000262a:	07a53023          	sd	s10,96(a0)
    8000262e:	07b53423          	sd	s11,104(a0)
    80002632:	0005b083          	ld	ra,0(a1)
    80002636:	0085b103          	ld	sp,8(a1)
    8000263a:	6980                	ld	s0,16(a1)
    8000263c:	6d84                	ld	s1,24(a1)
    8000263e:	0205b903          	ld	s2,32(a1)
    80002642:	0285b983          	ld	s3,40(a1)
    80002646:	0305ba03          	ld	s4,48(a1)
    8000264a:	0385ba83          	ld	s5,56(a1)
    8000264e:	0405bb03          	ld	s6,64(a1)
    80002652:	0485bb83          	ld	s7,72(a1)
    80002656:	0505bc03          	ld	s8,80(a1)
    8000265a:	0585bc83          	ld	s9,88(a1)
    8000265e:	0605bd03          	ld	s10,96(a1)
    80002662:	0685bd83          	ld	s11,104(a1)
    80002666:	8082                	ret

0000000080002668 <trapinit>:

extern int devintr();

void
trapinit(void)
{
    80002668:	1141                	addi	sp,sp,-16
    8000266a:	e406                	sd	ra,8(sp)
    8000266c:	e022                	sd	s0,0(sp)
    8000266e:	0800                	addi	s0,sp,16
  initlock(&tickslock, "time");
    80002670:	00006597          	auipc	a1,0x6
    80002674:	c8858593          	addi	a1,a1,-888 # 800082f8 <states.0+0x30>
    80002678:	00014517          	auipc	a0,0x14
    8000267c:	2f850513          	addi	a0,a0,760 # 80016970 <tickslock>
    80002680:	ffffe097          	auipc	ra,0xffffe
    80002684:	4c2080e7          	jalr	1218(ra) # 80000b42 <initlock>
}
    80002688:	60a2                	ld	ra,8(sp)
    8000268a:	6402                	ld	s0,0(sp)
    8000268c:	0141                	addi	sp,sp,16
    8000268e:	8082                	ret

0000000080002690 <trapinithart>:

// set up to take exceptions and traps while in the kernel.
void
trapinithart(void)
{
    80002690:	1141                	addi	sp,sp,-16
    80002692:	e422                	sd	s0,8(sp)
    80002694:	0800                	addi	s0,sp,16
  asm volatile("csrw stvec, %0" : : "r" (x));
    80002696:	00003797          	auipc	a5,0x3
    8000269a:	47a78793          	addi	a5,a5,1146 # 80005b10 <kernelvec>
    8000269e:	10579073          	csrw	stvec,a5
  w_stvec((uint64)kernelvec);
}
    800026a2:	6422                	ld	s0,8(sp)
    800026a4:	0141                	addi	sp,sp,16
    800026a6:	8082                	ret

00000000800026a8 <usertrapret>:
//
// return to user space
//
void
usertrapret(void)
{
    800026a8:	1141                	addi	sp,sp,-16
    800026aa:	e406                	sd	ra,8(sp)
    800026ac:	e022                	sd	s0,0(sp)
    800026ae:	0800                	addi	s0,sp,16
  struct proc *p = myproc();
    800026b0:	fffff097          	auipc	ra,0xfffff
    800026b4:	2f6080e7          	jalr	758(ra) # 800019a6 <myproc>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800026b8:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    800026bc:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    800026be:	10079073          	csrw	sstatus,a5
  // kerneltrap() to usertrap(), so turn off interrupts until
  // we're back in user space, where usertrap() is correct.
  intr_off();

  // send syscalls, interrupts, and exceptions to uservec in trampoline.S
  uint64 trampoline_uservec = TRAMPOLINE + (uservec - trampoline);
    800026c2:	00005697          	auipc	a3,0x5
    800026c6:	93e68693          	addi	a3,a3,-1730 # 80007000 <_trampoline>
    800026ca:	00005717          	auipc	a4,0x5
    800026ce:	93670713          	addi	a4,a4,-1738 # 80007000 <_trampoline>
    800026d2:	8f15                	sub	a4,a4,a3
    800026d4:	040007b7          	lui	a5,0x4000
    800026d8:	17fd                	addi	a5,a5,-1 # 3ffffff <_entry-0x7c000001>
    800026da:	07b2                	slli	a5,a5,0xc
    800026dc:	973e                	add	a4,a4,a5
  asm volatile("csrw stvec, %0" : : "r" (x));
    800026de:	10571073          	csrw	stvec,a4
  w_stvec(trampoline_uservec);

  // set up trapframe values that uservec will need when
  // the process next traps into the kernel.
  p->trapframe->kernel_satp = r_satp();         // kernel page table
    800026e2:	6d38                	ld	a4,88(a0)
  asm volatile("csrr %0, satp" : "=r" (x) );
    800026e4:	18002673          	csrr	a2,satp
    800026e8:	e310                	sd	a2,0(a4)
  p->trapframe->kernel_sp = p->kstack + PGSIZE; // process's kernel stack
    800026ea:	6d30                	ld	a2,88(a0)
    800026ec:	6138                	ld	a4,64(a0)
    800026ee:	6585                	lui	a1,0x1
    800026f0:	972e                	add	a4,a4,a1
    800026f2:	e618                	sd	a4,8(a2)
  p->trapframe->kernel_trap = (uint64)usertrap;
    800026f4:	6d38                	ld	a4,88(a0)
    800026f6:	00000617          	auipc	a2,0x0
    800026fa:	13460613          	addi	a2,a2,308 # 8000282a <usertrap>
    800026fe:	eb10                	sd	a2,16(a4)
  p->trapframe->kernel_hartid = r_tp();         // hartid for cpuid()
    80002700:	6d38                	ld	a4,88(a0)
  asm volatile("mv %0, tp" : "=r" (x) );
    80002702:	8612                	mv	a2,tp
    80002704:	f310                	sd	a2,32(a4)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002706:	10002773          	csrr	a4,sstatus
  // set up the registers that trampoline.S's sret will use
  // to get to user space.
  
  // set S Previous Privilege mode to User.
  unsigned long x = r_sstatus();
  x &= ~SSTATUS_SPP; // clear SPP to 0 for user mode
    8000270a:	eff77713          	andi	a4,a4,-257
  x |= SSTATUS_SPIE; // enable interrupts in user mode
    8000270e:	02076713          	ori	a4,a4,32
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002712:	10071073          	csrw	sstatus,a4
  w_sstatus(x);

  // set S Exception Program Counter to the saved user pc.
  w_sepc(p->trapframe->epc);
    80002716:	6d38                	ld	a4,88(a0)
  asm volatile("csrw sepc, %0" : : "r" (x));
    80002718:	6f18                	ld	a4,24(a4)
    8000271a:	14171073          	csrw	sepc,a4

  // tell trampoline.S the user page table to switch to.
  uint64 satp = MAKE_SATP(p->pagetable);
    8000271e:	6928                	ld	a0,80(a0)
    80002720:	8131                	srli	a0,a0,0xc

  // jump to userret in trampoline.S at the top of memory, which 
  // switches to the user page table, restores user registers,
  // and switches to user mode with sret.
  uint64 trampoline_userret = TRAMPOLINE + (userret - trampoline);
    80002722:	00005717          	auipc	a4,0x5
    80002726:	97a70713          	addi	a4,a4,-1670 # 8000709c <userret>
    8000272a:	8f15                	sub	a4,a4,a3
    8000272c:	97ba                	add	a5,a5,a4
  ((void (*)(uint64))trampoline_userret)(satp);
    8000272e:	577d                	li	a4,-1
    80002730:	177e                	slli	a4,a4,0x3f
    80002732:	8d59                	or	a0,a0,a4
    80002734:	9782                	jalr	a5
}
    80002736:	60a2                	ld	ra,8(sp)
    80002738:	6402                	ld	s0,0(sp)
    8000273a:	0141                	addi	sp,sp,16
    8000273c:	8082                	ret

000000008000273e <clockintr>:
  w_sstatus(sstatus);
}

void
clockintr()
{
    8000273e:	1101                	addi	sp,sp,-32
    80002740:	ec06                	sd	ra,24(sp)
    80002742:	e822                	sd	s0,16(sp)
    80002744:	e426                	sd	s1,8(sp)
    80002746:	1000                	addi	s0,sp,32
  acquire(&tickslock);
    80002748:	00014497          	auipc	s1,0x14
    8000274c:	22848493          	addi	s1,s1,552 # 80016970 <tickslock>
    80002750:	8526                	mv	a0,s1
    80002752:	ffffe097          	auipc	ra,0xffffe
    80002756:	480080e7          	jalr	1152(ra) # 80000bd2 <acquire>
  ticks++;
    8000275a:	00006517          	auipc	a0,0x6
    8000275e:	17650513          	addi	a0,a0,374 # 800088d0 <ticks>
    80002762:	411c                	lw	a5,0(a0)
    80002764:	2785                	addiw	a5,a5,1
    80002766:	c11c                	sw	a5,0(a0)
  wakeup(&ticks);
    80002768:	00000097          	auipc	ra,0x0
    8000276c:	996080e7          	jalr	-1642(ra) # 800020fe <wakeup>
  release(&tickslock);
    80002770:	8526                	mv	a0,s1
    80002772:	ffffe097          	auipc	ra,0xffffe
    80002776:	514080e7          	jalr	1300(ra) # 80000c86 <release>
}
    8000277a:	60e2                	ld	ra,24(sp)
    8000277c:	6442                	ld	s0,16(sp)
    8000277e:	64a2                	ld	s1,8(sp)
    80002780:	6105                	addi	sp,sp,32
    80002782:	8082                	ret

0000000080002784 <devintr>:
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002784:	142027f3          	csrr	a5,scause
    // the SSIP bit in sip.
    w_sip(r_sip() & ~2);

    return 2;
  } else {
    return 0;
    80002788:	4501                	li	a0,0
  if((scause & 0x8000000000000000L) &&
    8000278a:	0807df63          	bgez	a5,80002828 <devintr+0xa4>
{
    8000278e:	1101                	addi	sp,sp,-32
    80002790:	ec06                	sd	ra,24(sp)
    80002792:	e822                	sd	s0,16(sp)
    80002794:	e426                	sd	s1,8(sp)
    80002796:	1000                	addi	s0,sp,32
     (scause & 0xff) == 9){
    80002798:	0ff7f713          	zext.b	a4,a5
  if((scause & 0x8000000000000000L) &&
    8000279c:	46a5                	li	a3,9
    8000279e:	00d70d63          	beq	a4,a3,800027b8 <devintr+0x34>
  } else if(scause == 0x8000000000000001L){
    800027a2:	577d                	li	a4,-1
    800027a4:	177e                	slli	a4,a4,0x3f
    800027a6:	0705                	addi	a4,a4,1
    return 0;
    800027a8:	4501                	li	a0,0
  } else if(scause == 0x8000000000000001L){
    800027aa:	04e78e63          	beq	a5,a4,80002806 <devintr+0x82>
  }
}
    800027ae:	60e2                	ld	ra,24(sp)
    800027b0:	6442                	ld	s0,16(sp)
    800027b2:	64a2                	ld	s1,8(sp)
    800027b4:	6105                	addi	sp,sp,32
    800027b6:	8082                	ret
    int irq = plic_claim();
    800027b8:	00003097          	auipc	ra,0x3
    800027bc:	460080e7          	jalr	1120(ra) # 80005c18 <plic_claim>
    800027c0:	84aa                	mv	s1,a0
    if(irq == UART0_IRQ){
    800027c2:	47a9                	li	a5,10
    800027c4:	02f50763          	beq	a0,a5,800027f2 <devintr+0x6e>
    } else if(irq == VIRTIO0_IRQ){
    800027c8:	4785                	li	a5,1
    800027ca:	02f50963          	beq	a0,a5,800027fc <devintr+0x78>
    return 1;
    800027ce:	4505                	li	a0,1
    } else if(irq){
    800027d0:	dcf9                	beqz	s1,800027ae <devintr+0x2a>
      printf("unexpected interrupt irq=%d\n", irq);
    800027d2:	85a6                	mv	a1,s1
    800027d4:	00006517          	auipc	a0,0x6
    800027d8:	b2c50513          	addi	a0,a0,-1236 # 80008300 <states.0+0x38>
    800027dc:	ffffe097          	auipc	ra,0xffffe
    800027e0:	daa080e7          	jalr	-598(ra) # 80000586 <printf>
      plic_complete(irq);
    800027e4:	8526                	mv	a0,s1
    800027e6:	00003097          	auipc	ra,0x3
    800027ea:	456080e7          	jalr	1110(ra) # 80005c3c <plic_complete>
    return 1;
    800027ee:	4505                	li	a0,1
    800027f0:	bf7d                	j	800027ae <devintr+0x2a>
      uartintr();
    800027f2:	ffffe097          	auipc	ra,0xffffe
    800027f6:	1a2080e7          	jalr	418(ra) # 80000994 <uartintr>
    if(irq)
    800027fa:	b7ed                	j	800027e4 <devintr+0x60>
      virtio_disk_intr();
    800027fc:	00004097          	auipc	ra,0x4
    80002800:	906080e7          	jalr	-1786(ra) # 80006102 <virtio_disk_intr>
    if(irq)
    80002804:	b7c5                	j	800027e4 <devintr+0x60>
    if(cpuid() == 0){
    80002806:	fffff097          	auipc	ra,0xfffff
    8000280a:	174080e7          	jalr	372(ra) # 8000197a <cpuid>
    8000280e:	c901                	beqz	a0,8000281e <devintr+0x9a>
  asm volatile("csrr %0, sip" : "=r" (x) );
    80002810:	144027f3          	csrr	a5,sip
    w_sip(r_sip() & ~2);
    80002814:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sip, %0" : : "r" (x));
    80002816:	14479073          	csrw	sip,a5
    return 2;
    8000281a:	4509                	li	a0,2
    8000281c:	bf49                	j	800027ae <devintr+0x2a>
      clockintr();
    8000281e:	00000097          	auipc	ra,0x0
    80002822:	f20080e7          	jalr	-224(ra) # 8000273e <clockintr>
    80002826:	b7ed                	j	80002810 <devintr+0x8c>
}
    80002828:	8082                	ret

000000008000282a <usertrap>:
{
    8000282a:	1101                	addi	sp,sp,-32
    8000282c:	ec06                	sd	ra,24(sp)
    8000282e:	e822                	sd	s0,16(sp)
    80002830:	e426                	sd	s1,8(sp)
    80002832:	e04a                	sd	s2,0(sp)
    80002834:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002836:	100027f3          	csrr	a5,sstatus
  if((r_sstatus() & SSTATUS_SPP) != 0)
    8000283a:	1007f793          	andi	a5,a5,256
    8000283e:	e3b1                	bnez	a5,80002882 <usertrap+0x58>
  asm volatile("csrw stvec, %0" : : "r" (x));
    80002840:	00003797          	auipc	a5,0x3
    80002844:	2d078793          	addi	a5,a5,720 # 80005b10 <kernelvec>
    80002848:	10579073          	csrw	stvec,a5
  struct proc *p = myproc();
    8000284c:	fffff097          	auipc	ra,0xfffff
    80002850:	15a080e7          	jalr	346(ra) # 800019a6 <myproc>
    80002854:	84aa                	mv	s1,a0
  p->trapframe->epc = r_sepc();
    80002856:	6d3c                	ld	a5,88(a0)
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002858:	14102773          	csrr	a4,sepc
    8000285c:	ef98                	sd	a4,24(a5)
  asm volatile("csrr %0, scause" : "=r" (x) );
    8000285e:	14202773          	csrr	a4,scause
  if(r_scause() == 8){
    80002862:	47a1                	li	a5,8
    80002864:	02f70763          	beq	a4,a5,80002892 <usertrap+0x68>
  } else if((which_dev = devintr()) != 0){
    80002868:	00000097          	auipc	ra,0x0
    8000286c:	f1c080e7          	jalr	-228(ra) # 80002784 <devintr>
    80002870:	892a                	mv	s2,a0
    80002872:	c151                	beqz	a0,800028f6 <usertrap+0xcc>
  if(killed(p))
    80002874:	8526                	mv	a0,s1
    80002876:	00000097          	auipc	ra,0x0
    8000287a:	acc080e7          	jalr	-1332(ra) # 80002342 <killed>
    8000287e:	c929                	beqz	a0,800028d0 <usertrap+0xa6>
    80002880:	a099                	j	800028c6 <usertrap+0x9c>
    panic("usertrap: not from user mode");
    80002882:	00006517          	auipc	a0,0x6
    80002886:	a9e50513          	addi	a0,a0,-1378 # 80008320 <states.0+0x58>
    8000288a:	ffffe097          	auipc	ra,0xffffe
    8000288e:	cb2080e7          	jalr	-846(ra) # 8000053c <panic>
    if(killed(p))
    80002892:	00000097          	auipc	ra,0x0
    80002896:	ab0080e7          	jalr	-1360(ra) # 80002342 <killed>
    8000289a:	e921                	bnez	a0,800028ea <usertrap+0xc0>
    p->trapframe->epc += 4;
    8000289c:	6cb8                	ld	a4,88(s1)
    8000289e:	6f1c                	ld	a5,24(a4)
    800028a0:	0791                	addi	a5,a5,4
    800028a2:	ef1c                	sd	a5,24(a4)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800028a4:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    800028a8:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    800028ac:	10079073          	csrw	sstatus,a5
    syscall();
    800028b0:	00000097          	auipc	ra,0x0
    800028b4:	2d4080e7          	jalr	724(ra) # 80002b84 <syscall>
  if(killed(p))
    800028b8:	8526                	mv	a0,s1
    800028ba:	00000097          	auipc	ra,0x0
    800028be:	a88080e7          	jalr	-1400(ra) # 80002342 <killed>
    800028c2:	c911                	beqz	a0,800028d6 <usertrap+0xac>
    800028c4:	4901                	li	s2,0
    exit(-1);
    800028c6:	557d                	li	a0,-1
    800028c8:	00000097          	auipc	ra,0x0
    800028cc:	906080e7          	jalr	-1786(ra) # 800021ce <exit>
  if(which_dev == 2)
    800028d0:	4789                	li	a5,2
    800028d2:	04f90f63          	beq	s2,a5,80002930 <usertrap+0x106>
  usertrapret();
    800028d6:	00000097          	auipc	ra,0x0
    800028da:	dd2080e7          	jalr	-558(ra) # 800026a8 <usertrapret>
}
    800028de:	60e2                	ld	ra,24(sp)
    800028e0:	6442                	ld	s0,16(sp)
    800028e2:	64a2                	ld	s1,8(sp)
    800028e4:	6902                	ld	s2,0(sp)
    800028e6:	6105                	addi	sp,sp,32
    800028e8:	8082                	ret
      exit(-1);
    800028ea:	557d                	li	a0,-1
    800028ec:	00000097          	auipc	ra,0x0
    800028f0:	8e2080e7          	jalr	-1822(ra) # 800021ce <exit>
    800028f4:	b765                	j	8000289c <usertrap+0x72>
  asm volatile("csrr %0, scause" : "=r" (x) );
    800028f6:	142025f3          	csrr	a1,scause
    printf("usertrap(): unexpected scause %p pid=%d\n", r_scause(), p->pid);
    800028fa:	5890                	lw	a2,48(s1)
    800028fc:	00006517          	auipc	a0,0x6
    80002900:	a4450513          	addi	a0,a0,-1468 # 80008340 <states.0+0x78>
    80002904:	ffffe097          	auipc	ra,0xffffe
    80002908:	c82080e7          	jalr	-894(ra) # 80000586 <printf>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    8000290c:	141025f3          	csrr	a1,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    80002910:	14302673          	csrr	a2,stval
    printf("            sepc=%p stval=%p\n", r_sepc(), r_stval());
    80002914:	00006517          	auipc	a0,0x6
    80002918:	a5c50513          	addi	a0,a0,-1444 # 80008370 <states.0+0xa8>
    8000291c:	ffffe097          	auipc	ra,0xffffe
    80002920:	c6a080e7          	jalr	-918(ra) # 80000586 <printf>
    setkilled(p);
    80002924:	8526                	mv	a0,s1
    80002926:	00000097          	auipc	ra,0x0
    8000292a:	9f0080e7          	jalr	-1552(ra) # 80002316 <setkilled>
    8000292e:	b769                	j	800028b8 <usertrap+0x8e>
    yield();
    80002930:	fffff097          	auipc	ra,0xfffff
    80002934:	72e080e7          	jalr	1838(ra) # 8000205e <yield>
    80002938:	bf79                	j	800028d6 <usertrap+0xac>

000000008000293a <kerneltrap>:
{
    8000293a:	7179                	addi	sp,sp,-48
    8000293c:	f406                	sd	ra,40(sp)
    8000293e:	f022                	sd	s0,32(sp)
    80002940:	ec26                	sd	s1,24(sp)
    80002942:	e84a                	sd	s2,16(sp)
    80002944:	e44e                	sd	s3,8(sp)
    80002946:	1800                	addi	s0,sp,48
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002948:	14102973          	csrr	s2,sepc
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    8000294c:	100024f3          	csrr	s1,sstatus
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002950:	142029f3          	csrr	s3,scause
  if((sstatus & SSTATUS_SPP) == 0)
    80002954:	1004f793          	andi	a5,s1,256
    80002958:	cb85                	beqz	a5,80002988 <kerneltrap+0x4e>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    8000295a:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    8000295e:	8b89                	andi	a5,a5,2
  if(intr_get() != 0)
    80002960:	ef85                	bnez	a5,80002998 <kerneltrap+0x5e>
  if((which_dev = devintr()) == 0){
    80002962:	00000097          	auipc	ra,0x0
    80002966:	e22080e7          	jalr	-478(ra) # 80002784 <devintr>
    8000296a:	cd1d                	beqz	a0,800029a8 <kerneltrap+0x6e>
  if(which_dev == 2 && myproc() != 0 && myproc()->state == RUNNING)
    8000296c:	4789                	li	a5,2
    8000296e:	06f50a63          	beq	a0,a5,800029e2 <kerneltrap+0xa8>
  asm volatile("csrw sepc, %0" : : "r" (x));
    80002972:	14191073          	csrw	sepc,s2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002976:	10049073          	csrw	sstatus,s1
}
    8000297a:	70a2                	ld	ra,40(sp)
    8000297c:	7402                	ld	s0,32(sp)
    8000297e:	64e2                	ld	s1,24(sp)
    80002980:	6942                	ld	s2,16(sp)
    80002982:	69a2                	ld	s3,8(sp)
    80002984:	6145                	addi	sp,sp,48
    80002986:	8082                	ret
    panic("kerneltrap: not from supervisor mode");
    80002988:	00006517          	auipc	a0,0x6
    8000298c:	a0850513          	addi	a0,a0,-1528 # 80008390 <states.0+0xc8>
    80002990:	ffffe097          	auipc	ra,0xffffe
    80002994:	bac080e7          	jalr	-1108(ra) # 8000053c <panic>
    panic("kerneltrap: interrupts enabled");
    80002998:	00006517          	auipc	a0,0x6
    8000299c:	a2050513          	addi	a0,a0,-1504 # 800083b8 <states.0+0xf0>
    800029a0:	ffffe097          	auipc	ra,0xffffe
    800029a4:	b9c080e7          	jalr	-1124(ra) # 8000053c <panic>
    printf("scause %p\n", scause);
    800029a8:	85ce                	mv	a1,s3
    800029aa:	00006517          	auipc	a0,0x6
    800029ae:	a2e50513          	addi	a0,a0,-1490 # 800083d8 <states.0+0x110>
    800029b2:	ffffe097          	auipc	ra,0xffffe
    800029b6:	bd4080e7          	jalr	-1068(ra) # 80000586 <printf>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    800029ba:	141025f3          	csrr	a1,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    800029be:	14302673          	csrr	a2,stval
    printf("sepc=%p stval=%p\n", r_sepc(), r_stval());
    800029c2:	00006517          	auipc	a0,0x6
    800029c6:	a2650513          	addi	a0,a0,-1498 # 800083e8 <states.0+0x120>
    800029ca:	ffffe097          	auipc	ra,0xffffe
    800029ce:	bbc080e7          	jalr	-1092(ra) # 80000586 <printf>
    panic("kerneltrap");
    800029d2:	00006517          	auipc	a0,0x6
    800029d6:	a2e50513          	addi	a0,a0,-1490 # 80008400 <states.0+0x138>
    800029da:	ffffe097          	auipc	ra,0xffffe
    800029de:	b62080e7          	jalr	-1182(ra) # 8000053c <panic>
  if(which_dev == 2 && myproc() != 0 && myproc()->state == RUNNING)
    800029e2:	fffff097          	auipc	ra,0xfffff
    800029e6:	fc4080e7          	jalr	-60(ra) # 800019a6 <myproc>
    800029ea:	d541                	beqz	a0,80002972 <kerneltrap+0x38>
    800029ec:	fffff097          	auipc	ra,0xfffff
    800029f0:	fba080e7          	jalr	-70(ra) # 800019a6 <myproc>
    800029f4:	4d18                	lw	a4,24(a0)
    800029f6:	4791                	li	a5,4
    800029f8:	f6f71de3          	bne	a4,a5,80002972 <kerneltrap+0x38>
    yield();
    800029fc:	fffff097          	auipc	ra,0xfffff
    80002a00:	662080e7          	jalr	1634(ra) # 8000205e <yield>
    80002a04:	b7bd                	j	80002972 <kerneltrap+0x38>

0000000080002a06 <argraw>:
  return strlen(buf);
}

static uint64
argraw(int n)
{
    80002a06:	1101                	addi	sp,sp,-32
    80002a08:	ec06                	sd	ra,24(sp)
    80002a0a:	e822                	sd	s0,16(sp)
    80002a0c:	e426                	sd	s1,8(sp)
    80002a0e:	1000                	addi	s0,sp,32
    80002a10:	84aa                	mv	s1,a0
  struct proc *p = myproc();
    80002a12:	fffff097          	auipc	ra,0xfffff
    80002a16:	f94080e7          	jalr	-108(ra) # 800019a6 <myproc>
  switch (n) {
    80002a1a:	4795                	li	a5,5
    80002a1c:	0497e163          	bltu	a5,s1,80002a5e <argraw+0x58>
    80002a20:	048a                	slli	s1,s1,0x2
    80002a22:	00006717          	auipc	a4,0x6
    80002a26:	a1670713          	addi	a4,a4,-1514 # 80008438 <states.0+0x170>
    80002a2a:	94ba                	add	s1,s1,a4
    80002a2c:	409c                	lw	a5,0(s1)
    80002a2e:	97ba                	add	a5,a5,a4
    80002a30:	8782                	jr	a5
  case 0:
    return p->trapframe->a0;
    80002a32:	6d3c                	ld	a5,88(a0)
    80002a34:	7ba8                	ld	a0,112(a5)
  case 5:
    return p->trapframe->a5;
  }
  panic("argraw");
  return -1;
}
    80002a36:	60e2                	ld	ra,24(sp)
    80002a38:	6442                	ld	s0,16(sp)
    80002a3a:	64a2                	ld	s1,8(sp)
    80002a3c:	6105                	addi	sp,sp,32
    80002a3e:	8082                	ret
    return p->trapframe->a1;
    80002a40:	6d3c                	ld	a5,88(a0)
    80002a42:	7fa8                	ld	a0,120(a5)
    80002a44:	bfcd                	j	80002a36 <argraw+0x30>
    return p->trapframe->a2;
    80002a46:	6d3c                	ld	a5,88(a0)
    80002a48:	63c8                	ld	a0,128(a5)
    80002a4a:	b7f5                	j	80002a36 <argraw+0x30>
    return p->trapframe->a3;
    80002a4c:	6d3c                	ld	a5,88(a0)
    80002a4e:	67c8                	ld	a0,136(a5)
    80002a50:	b7dd                	j	80002a36 <argraw+0x30>
    return p->trapframe->a4;
    80002a52:	6d3c                	ld	a5,88(a0)
    80002a54:	6bc8                	ld	a0,144(a5)
    80002a56:	b7c5                	j	80002a36 <argraw+0x30>
    return p->trapframe->a5;
    80002a58:	6d3c                	ld	a5,88(a0)
    80002a5a:	6fc8                	ld	a0,152(a5)
    80002a5c:	bfe9                	j	80002a36 <argraw+0x30>
  panic("argraw");
    80002a5e:	00006517          	auipc	a0,0x6
    80002a62:	9b250513          	addi	a0,a0,-1614 # 80008410 <states.0+0x148>
    80002a66:	ffffe097          	auipc	ra,0xffffe
    80002a6a:	ad6080e7          	jalr	-1322(ra) # 8000053c <panic>

0000000080002a6e <fetchaddr>:
{
    80002a6e:	1101                	addi	sp,sp,-32
    80002a70:	ec06                	sd	ra,24(sp)
    80002a72:	e822                	sd	s0,16(sp)
    80002a74:	e426                	sd	s1,8(sp)
    80002a76:	e04a                	sd	s2,0(sp)
    80002a78:	1000                	addi	s0,sp,32
    80002a7a:	84aa                	mv	s1,a0
    80002a7c:	892e                	mv	s2,a1
  struct proc *p = myproc();
    80002a7e:	fffff097          	auipc	ra,0xfffff
    80002a82:	f28080e7          	jalr	-216(ra) # 800019a6 <myproc>
  if(addr >= p->sz || addr+sizeof(uint64) > p->sz) // both tests needed, in case of overflow
    80002a86:	653c                	ld	a5,72(a0)
    80002a88:	02f4f863          	bgeu	s1,a5,80002ab8 <fetchaddr+0x4a>
    80002a8c:	00848713          	addi	a4,s1,8
    80002a90:	02e7e663          	bltu	a5,a4,80002abc <fetchaddr+0x4e>
  if(copyin(p->pagetable, (char *)ip, addr, sizeof(*ip)) != 0)
    80002a94:	46a1                	li	a3,8
    80002a96:	8626                	mv	a2,s1
    80002a98:	85ca                	mv	a1,s2
    80002a9a:	6928                	ld	a0,80(a0)
    80002a9c:	fffff097          	auipc	ra,0xfffff
    80002aa0:	c56080e7          	jalr	-938(ra) # 800016f2 <copyin>
    80002aa4:	00a03533          	snez	a0,a0
    80002aa8:	40a00533          	neg	a0,a0
}
    80002aac:	60e2                	ld	ra,24(sp)
    80002aae:	6442                	ld	s0,16(sp)
    80002ab0:	64a2                	ld	s1,8(sp)
    80002ab2:	6902                	ld	s2,0(sp)
    80002ab4:	6105                	addi	sp,sp,32
    80002ab6:	8082                	ret
    return -1;
    80002ab8:	557d                	li	a0,-1
    80002aba:	bfcd                	j	80002aac <fetchaddr+0x3e>
    80002abc:	557d                	li	a0,-1
    80002abe:	b7fd                	j	80002aac <fetchaddr+0x3e>

0000000080002ac0 <fetchstr>:
{
    80002ac0:	7179                	addi	sp,sp,-48
    80002ac2:	f406                	sd	ra,40(sp)
    80002ac4:	f022                	sd	s0,32(sp)
    80002ac6:	ec26                	sd	s1,24(sp)
    80002ac8:	e84a                	sd	s2,16(sp)
    80002aca:	e44e                	sd	s3,8(sp)
    80002acc:	1800                	addi	s0,sp,48
    80002ace:	892a                	mv	s2,a0
    80002ad0:	84ae                	mv	s1,a1
    80002ad2:	89b2                	mv	s3,a2
  struct proc *p = myproc();
    80002ad4:	fffff097          	auipc	ra,0xfffff
    80002ad8:	ed2080e7          	jalr	-302(ra) # 800019a6 <myproc>
  if(copyinstr(p->pagetable, buf, addr, max) < 0)
    80002adc:	86ce                	mv	a3,s3
    80002ade:	864a                	mv	a2,s2
    80002ae0:	85a6                	mv	a1,s1
    80002ae2:	6928                	ld	a0,80(a0)
    80002ae4:	fffff097          	auipc	ra,0xfffff
    80002ae8:	c9c080e7          	jalr	-868(ra) # 80001780 <copyinstr>
    80002aec:	00054e63          	bltz	a0,80002b08 <fetchstr+0x48>
  return strlen(buf);
    80002af0:	8526                	mv	a0,s1
    80002af2:	ffffe097          	auipc	ra,0xffffe
    80002af6:	356080e7          	jalr	854(ra) # 80000e48 <strlen>
}
    80002afa:	70a2                	ld	ra,40(sp)
    80002afc:	7402                	ld	s0,32(sp)
    80002afe:	64e2                	ld	s1,24(sp)
    80002b00:	6942                	ld	s2,16(sp)
    80002b02:	69a2                	ld	s3,8(sp)
    80002b04:	6145                	addi	sp,sp,48
    80002b06:	8082                	ret
    return -1;
    80002b08:	557d                	li	a0,-1
    80002b0a:	bfc5                	j	80002afa <fetchstr+0x3a>

0000000080002b0c <argint>:

// Fetch the nth 32-bit system call argument.
void
argint(int n, int *ip)
{
    80002b0c:	1101                	addi	sp,sp,-32
    80002b0e:	ec06                	sd	ra,24(sp)
    80002b10:	e822                	sd	s0,16(sp)
    80002b12:	e426                	sd	s1,8(sp)
    80002b14:	1000                	addi	s0,sp,32
    80002b16:	84ae                	mv	s1,a1
  *ip = argraw(n);
    80002b18:	00000097          	auipc	ra,0x0
    80002b1c:	eee080e7          	jalr	-274(ra) # 80002a06 <argraw>
    80002b20:	c088                	sw	a0,0(s1)
}
    80002b22:	60e2                	ld	ra,24(sp)
    80002b24:	6442                	ld	s0,16(sp)
    80002b26:	64a2                	ld	s1,8(sp)
    80002b28:	6105                	addi	sp,sp,32
    80002b2a:	8082                	ret

0000000080002b2c <argaddr>:
// Retrieve an argument as a pointer.
// Doesn't check for legality, since
// copyin/copyout will do that.
void
argaddr(int n, uint64 *ip)
{
    80002b2c:	1101                	addi	sp,sp,-32
    80002b2e:	ec06                	sd	ra,24(sp)
    80002b30:	e822                	sd	s0,16(sp)
    80002b32:	e426                	sd	s1,8(sp)
    80002b34:	1000                	addi	s0,sp,32
    80002b36:	84ae                	mv	s1,a1
  *ip = argraw(n);
    80002b38:	00000097          	auipc	ra,0x0
    80002b3c:	ece080e7          	jalr	-306(ra) # 80002a06 <argraw>
    80002b40:	e088                	sd	a0,0(s1)
}
    80002b42:	60e2                	ld	ra,24(sp)
    80002b44:	6442                	ld	s0,16(sp)
    80002b46:	64a2                	ld	s1,8(sp)
    80002b48:	6105                	addi	sp,sp,32
    80002b4a:	8082                	ret

0000000080002b4c <argstr>:
// Fetch the nth word-sized system call argument as a null-terminated string.
// Copies into buf, at most max.
// Returns string length if OK (including nul), -1 if error.
int
argstr(int n, char *buf, int max)
{
    80002b4c:	7179                	addi	sp,sp,-48
    80002b4e:	f406                	sd	ra,40(sp)
    80002b50:	f022                	sd	s0,32(sp)
    80002b52:	ec26                	sd	s1,24(sp)
    80002b54:	e84a                	sd	s2,16(sp)
    80002b56:	1800                	addi	s0,sp,48
    80002b58:	84ae                	mv	s1,a1
    80002b5a:	8932                	mv	s2,a2
  uint64 addr;
  argaddr(n, &addr);
    80002b5c:	fd840593          	addi	a1,s0,-40
    80002b60:	00000097          	auipc	ra,0x0
    80002b64:	fcc080e7          	jalr	-52(ra) # 80002b2c <argaddr>
  return fetchstr(addr, buf, max);
    80002b68:	864a                	mv	a2,s2
    80002b6a:	85a6                	mv	a1,s1
    80002b6c:	fd843503          	ld	a0,-40(s0)
    80002b70:	00000097          	auipc	ra,0x0
    80002b74:	f50080e7          	jalr	-176(ra) # 80002ac0 <fetchstr>
}
    80002b78:	70a2                	ld	ra,40(sp)
    80002b7a:	7402                	ld	s0,32(sp)
    80002b7c:	64e2                	ld	s1,24(sp)
    80002b7e:	6942                	ld	s2,16(sp)
    80002b80:	6145                	addi	sp,sp,48
    80002b82:	8082                	ret

0000000080002b84 <syscall>:
[SYS_dump]    sys_dump,
};

void
syscall(void)
{
    80002b84:	1101                	addi	sp,sp,-32
    80002b86:	ec06                	sd	ra,24(sp)
    80002b88:	e822                	sd	s0,16(sp)
    80002b8a:	e426                	sd	s1,8(sp)
    80002b8c:	e04a                	sd	s2,0(sp)
    80002b8e:	1000                	addi	s0,sp,32
  int num;
  struct proc *p = myproc();
    80002b90:	fffff097          	auipc	ra,0xfffff
    80002b94:	e16080e7          	jalr	-490(ra) # 800019a6 <myproc>
    80002b98:	84aa                	mv	s1,a0

  num = p->trapframe->a7;
    80002b9a:	05853903          	ld	s2,88(a0)
    80002b9e:	0a893783          	ld	a5,168(s2)
    80002ba2:	0007869b          	sext.w	a3,a5
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
    80002ba6:	37fd                	addiw	a5,a5,-1
    80002ba8:	4755                	li	a4,21
    80002baa:	00f76f63          	bltu	a4,a5,80002bc8 <syscall+0x44>
    80002bae:	00369713          	slli	a4,a3,0x3
    80002bb2:	00006797          	auipc	a5,0x6
    80002bb6:	89e78793          	addi	a5,a5,-1890 # 80008450 <syscalls>
    80002bba:	97ba                	add	a5,a5,a4
    80002bbc:	639c                	ld	a5,0(a5)
    80002bbe:	c789                	beqz	a5,80002bc8 <syscall+0x44>
    // Use num to lookup the system call function for num, call it,
    // and store its return value in p->trapframe->a0
    p->trapframe->a0 = syscalls[num]();
    80002bc0:	9782                	jalr	a5
    80002bc2:	06a93823          	sd	a0,112(s2)
    80002bc6:	a839                	j	80002be4 <syscall+0x60>
  } else {
    printf("%d %s: unknown sys call %d\n",
    80002bc8:	15848613          	addi	a2,s1,344
    80002bcc:	588c                	lw	a1,48(s1)
    80002bce:	00006517          	auipc	a0,0x6
    80002bd2:	84a50513          	addi	a0,a0,-1974 # 80008418 <states.0+0x150>
    80002bd6:	ffffe097          	auipc	ra,0xffffe
    80002bda:	9b0080e7          	jalr	-1616(ra) # 80000586 <printf>
            p->pid, p->name, num);
    p->trapframe->a0 = -1;
    80002bde:	6cbc                	ld	a5,88(s1)
    80002be0:	577d                	li	a4,-1
    80002be2:	fbb8                	sd	a4,112(a5)
  }
}
    80002be4:	60e2                	ld	ra,24(sp)
    80002be6:	6442                	ld	s0,16(sp)
    80002be8:	64a2                	ld	s1,8(sp)
    80002bea:	6902                	ld	s2,0(sp)
    80002bec:	6105                	addi	sp,sp,32
    80002bee:	8082                	ret

0000000080002bf0 <sys_exit>:
#include "spinlock.h"
#include "proc.h"

uint64
sys_exit(void)
{
    80002bf0:	1101                	addi	sp,sp,-32
    80002bf2:	ec06                	sd	ra,24(sp)
    80002bf4:	e822                	sd	s0,16(sp)
    80002bf6:	1000                	addi	s0,sp,32
  int n;
  argint(0, &n);
    80002bf8:	fec40593          	addi	a1,s0,-20
    80002bfc:	4501                	li	a0,0
    80002bfe:	00000097          	auipc	ra,0x0
    80002c02:	f0e080e7          	jalr	-242(ra) # 80002b0c <argint>
  exit(n);
    80002c06:	fec42503          	lw	a0,-20(s0)
    80002c0a:	fffff097          	auipc	ra,0xfffff
    80002c0e:	5c4080e7          	jalr	1476(ra) # 800021ce <exit>
  return 0;  // not reached
}
    80002c12:	4501                	li	a0,0
    80002c14:	60e2                	ld	ra,24(sp)
    80002c16:	6442                	ld	s0,16(sp)
    80002c18:	6105                	addi	sp,sp,32
    80002c1a:	8082                	ret

0000000080002c1c <sys_getpid>:

uint64
sys_getpid(void)
{
    80002c1c:	1141                	addi	sp,sp,-16
    80002c1e:	e406                	sd	ra,8(sp)
    80002c20:	e022                	sd	s0,0(sp)
    80002c22:	0800                	addi	s0,sp,16
  return myproc()->pid;
    80002c24:	fffff097          	auipc	ra,0xfffff
    80002c28:	d82080e7          	jalr	-638(ra) # 800019a6 <myproc>
}
    80002c2c:	5908                	lw	a0,48(a0)
    80002c2e:	60a2                	ld	ra,8(sp)
    80002c30:	6402                	ld	s0,0(sp)
    80002c32:	0141                	addi	sp,sp,16
    80002c34:	8082                	ret

0000000080002c36 <sys_fork>:

uint64
sys_fork(void)
{
    80002c36:	1141                	addi	sp,sp,-16
    80002c38:	e406                	sd	ra,8(sp)
    80002c3a:	e022                	sd	s0,0(sp)
    80002c3c:	0800                	addi	s0,sp,16
  return fork();
    80002c3e:	fffff097          	auipc	ra,0xfffff
    80002c42:	16a080e7          	jalr	362(ra) # 80001da8 <fork>
}
    80002c46:	60a2                	ld	ra,8(sp)
    80002c48:	6402                	ld	s0,0(sp)
    80002c4a:	0141                	addi	sp,sp,16
    80002c4c:	8082                	ret

0000000080002c4e <sys_wait>:

uint64
sys_wait(void)
{
    80002c4e:	1101                	addi	sp,sp,-32
    80002c50:	ec06                	sd	ra,24(sp)
    80002c52:	e822                	sd	s0,16(sp)
    80002c54:	1000                	addi	s0,sp,32
  uint64 p;
  argaddr(0, &p);
    80002c56:	fe840593          	addi	a1,s0,-24
    80002c5a:	4501                	li	a0,0
    80002c5c:	00000097          	auipc	ra,0x0
    80002c60:	ed0080e7          	jalr	-304(ra) # 80002b2c <argaddr>
  return wait(p);
    80002c64:	fe843503          	ld	a0,-24(s0)
    80002c68:	fffff097          	auipc	ra,0xfffff
    80002c6c:	70c080e7          	jalr	1804(ra) # 80002374 <wait>
}
    80002c70:	60e2                	ld	ra,24(sp)
    80002c72:	6442                	ld	s0,16(sp)
    80002c74:	6105                	addi	sp,sp,32
    80002c76:	8082                	ret

0000000080002c78 <sys_sbrk>:

uint64
sys_sbrk(void)
{
    80002c78:	7179                	addi	sp,sp,-48
    80002c7a:	f406                	sd	ra,40(sp)
    80002c7c:	f022                	sd	s0,32(sp)
    80002c7e:	ec26                	sd	s1,24(sp)
    80002c80:	1800                	addi	s0,sp,48
  uint64 addr;
  int n;

  argint(0, &n);
    80002c82:	fdc40593          	addi	a1,s0,-36
    80002c86:	4501                	li	a0,0
    80002c88:	00000097          	auipc	ra,0x0
    80002c8c:	e84080e7          	jalr	-380(ra) # 80002b0c <argint>
  addr = myproc()->sz;
    80002c90:	fffff097          	auipc	ra,0xfffff
    80002c94:	d16080e7          	jalr	-746(ra) # 800019a6 <myproc>
    80002c98:	6524                	ld	s1,72(a0)
  if(growproc(n) < 0)
    80002c9a:	fdc42503          	lw	a0,-36(s0)
    80002c9e:	fffff097          	auipc	ra,0xfffff
    80002ca2:	0ae080e7          	jalr	174(ra) # 80001d4c <growproc>
    80002ca6:	00054863          	bltz	a0,80002cb6 <sys_sbrk+0x3e>
    return -1;
  return addr;
}
    80002caa:	8526                	mv	a0,s1
    80002cac:	70a2                	ld	ra,40(sp)
    80002cae:	7402                	ld	s0,32(sp)
    80002cb0:	64e2                	ld	s1,24(sp)
    80002cb2:	6145                	addi	sp,sp,48
    80002cb4:	8082                	ret
    return -1;
    80002cb6:	54fd                	li	s1,-1
    80002cb8:	bfcd                	j	80002caa <sys_sbrk+0x32>

0000000080002cba <sys_sleep>:

uint64
sys_sleep(void)
{
    80002cba:	7139                	addi	sp,sp,-64
    80002cbc:	fc06                	sd	ra,56(sp)
    80002cbe:	f822                	sd	s0,48(sp)
    80002cc0:	f426                	sd	s1,40(sp)
    80002cc2:	f04a                	sd	s2,32(sp)
    80002cc4:	ec4e                	sd	s3,24(sp)
    80002cc6:	0080                	addi	s0,sp,64
  int n;
  uint ticks0;

  argint(0, &n);
    80002cc8:	fcc40593          	addi	a1,s0,-52
    80002ccc:	4501                	li	a0,0
    80002cce:	00000097          	auipc	ra,0x0
    80002cd2:	e3e080e7          	jalr	-450(ra) # 80002b0c <argint>
  acquire(&tickslock);
    80002cd6:	00014517          	auipc	a0,0x14
    80002cda:	c9a50513          	addi	a0,a0,-870 # 80016970 <tickslock>
    80002cde:	ffffe097          	auipc	ra,0xffffe
    80002ce2:	ef4080e7          	jalr	-268(ra) # 80000bd2 <acquire>
  ticks0 = ticks;
    80002ce6:	00006917          	auipc	s2,0x6
    80002cea:	bea92903          	lw	s2,-1046(s2) # 800088d0 <ticks>
  while(ticks - ticks0 < n){
    80002cee:	fcc42783          	lw	a5,-52(s0)
    80002cf2:	cf9d                	beqz	a5,80002d30 <sys_sleep+0x76>
    if(killed(myproc())){
      release(&tickslock);
      return -1;
    }
    sleep(&ticks, &tickslock);
    80002cf4:	00014997          	auipc	s3,0x14
    80002cf8:	c7c98993          	addi	s3,s3,-900 # 80016970 <tickslock>
    80002cfc:	00006497          	auipc	s1,0x6
    80002d00:	bd448493          	addi	s1,s1,-1068 # 800088d0 <ticks>
    if(killed(myproc())){
    80002d04:	fffff097          	auipc	ra,0xfffff
    80002d08:	ca2080e7          	jalr	-862(ra) # 800019a6 <myproc>
    80002d0c:	fffff097          	auipc	ra,0xfffff
    80002d10:	636080e7          	jalr	1590(ra) # 80002342 <killed>
    80002d14:	ed15                	bnez	a0,80002d50 <sys_sleep+0x96>
    sleep(&ticks, &tickslock);
    80002d16:	85ce                	mv	a1,s3
    80002d18:	8526                	mv	a0,s1
    80002d1a:	fffff097          	auipc	ra,0xfffff
    80002d1e:	380080e7          	jalr	896(ra) # 8000209a <sleep>
  while(ticks - ticks0 < n){
    80002d22:	409c                	lw	a5,0(s1)
    80002d24:	412787bb          	subw	a5,a5,s2
    80002d28:	fcc42703          	lw	a4,-52(s0)
    80002d2c:	fce7ece3          	bltu	a5,a4,80002d04 <sys_sleep+0x4a>
  }
  release(&tickslock);
    80002d30:	00014517          	auipc	a0,0x14
    80002d34:	c4050513          	addi	a0,a0,-960 # 80016970 <tickslock>
    80002d38:	ffffe097          	auipc	ra,0xffffe
    80002d3c:	f4e080e7          	jalr	-178(ra) # 80000c86 <release>
  return 0;
    80002d40:	4501                	li	a0,0
}
    80002d42:	70e2                	ld	ra,56(sp)
    80002d44:	7442                	ld	s0,48(sp)
    80002d46:	74a2                	ld	s1,40(sp)
    80002d48:	7902                	ld	s2,32(sp)
    80002d4a:	69e2                	ld	s3,24(sp)
    80002d4c:	6121                	addi	sp,sp,64
    80002d4e:	8082                	ret
      release(&tickslock);
    80002d50:	00014517          	auipc	a0,0x14
    80002d54:	c2050513          	addi	a0,a0,-992 # 80016970 <tickslock>
    80002d58:	ffffe097          	auipc	ra,0xffffe
    80002d5c:	f2e080e7          	jalr	-210(ra) # 80000c86 <release>
      return -1;
    80002d60:	557d                	li	a0,-1
    80002d62:	b7c5                	j	80002d42 <sys_sleep+0x88>

0000000080002d64 <sys_kill>:

uint64
sys_kill(void)
{
    80002d64:	1101                	addi	sp,sp,-32
    80002d66:	ec06                	sd	ra,24(sp)
    80002d68:	e822                	sd	s0,16(sp)
    80002d6a:	1000                	addi	s0,sp,32
  int pid;

  argint(0, &pid);
    80002d6c:	fec40593          	addi	a1,s0,-20
    80002d70:	4501                	li	a0,0
    80002d72:	00000097          	auipc	ra,0x0
    80002d76:	d9a080e7          	jalr	-614(ra) # 80002b0c <argint>
  return kill(pid);
    80002d7a:	fec42503          	lw	a0,-20(s0)
    80002d7e:	fffff097          	auipc	ra,0xfffff
    80002d82:	526080e7          	jalr	1318(ra) # 800022a4 <kill>
}
    80002d86:	60e2                	ld	ra,24(sp)
    80002d88:	6442                	ld	s0,16(sp)
    80002d8a:	6105                	addi	sp,sp,32
    80002d8c:	8082                	ret

0000000080002d8e <sys_uptime>:

// return how many clock tick interrupts have occurred
// since start.
uint64
sys_uptime(void)
{
    80002d8e:	1101                	addi	sp,sp,-32
    80002d90:	ec06                	sd	ra,24(sp)
    80002d92:	e822                	sd	s0,16(sp)
    80002d94:	e426                	sd	s1,8(sp)
    80002d96:	1000                	addi	s0,sp,32
  uint xticks;

  acquire(&tickslock);
    80002d98:	00014517          	auipc	a0,0x14
    80002d9c:	bd850513          	addi	a0,a0,-1064 # 80016970 <tickslock>
    80002da0:	ffffe097          	auipc	ra,0xffffe
    80002da4:	e32080e7          	jalr	-462(ra) # 80000bd2 <acquire>
  xticks = ticks;
    80002da8:	00006497          	auipc	s1,0x6
    80002dac:	b284a483          	lw	s1,-1240(s1) # 800088d0 <ticks>
  release(&tickslock);
    80002db0:	00014517          	auipc	a0,0x14
    80002db4:	bc050513          	addi	a0,a0,-1088 # 80016970 <tickslock>
    80002db8:	ffffe097          	auipc	ra,0xffffe
    80002dbc:	ece080e7          	jalr	-306(ra) # 80000c86 <release>
  return xticks;
}
    80002dc0:	02049513          	slli	a0,s1,0x20
    80002dc4:	9101                	srli	a0,a0,0x20
    80002dc6:	60e2                	ld	ra,24(sp)
    80002dc8:	6442                	ld	s0,16(sp)
    80002dca:	64a2                	ld	s1,8(sp)
    80002dcc:	6105                	addi	sp,sp,32
    80002dce:	8082                	ret

0000000080002dd0 <sys_dump>:

uint64
sys_dump(void)
{
    80002dd0:	1141                	addi	sp,sp,-16
    80002dd2:	e406                	sd	ra,8(sp)
    80002dd4:	e022                	sd	s0,0(sp)
    80002dd6:	0800                	addi	s0,sp,16
	return dump();
    80002dd8:	fffff097          	auipc	ra,0xfffff
    80002ddc:	c4c080e7          	jalr	-948(ra) # 80001a24 <dump>
}
    80002de0:	60a2                	ld	ra,8(sp)
    80002de2:	6402                	ld	s0,0(sp)
    80002de4:	0141                	addi	sp,sp,16
    80002de6:	8082                	ret

0000000080002de8 <binit>:
  struct buf head;
} bcache;

void
binit(void)
{
    80002de8:	7179                	addi	sp,sp,-48
    80002dea:	f406                	sd	ra,40(sp)
    80002dec:	f022                	sd	s0,32(sp)
    80002dee:	ec26                	sd	s1,24(sp)
    80002df0:	e84a                	sd	s2,16(sp)
    80002df2:	e44e                	sd	s3,8(sp)
    80002df4:	e052                	sd	s4,0(sp)
    80002df6:	1800                	addi	s0,sp,48
  struct buf *b;

  initlock(&bcache.lock, "bcache");
    80002df8:	00005597          	auipc	a1,0x5
    80002dfc:	71058593          	addi	a1,a1,1808 # 80008508 <syscalls+0xb8>
    80002e00:	00014517          	auipc	a0,0x14
    80002e04:	b8850513          	addi	a0,a0,-1144 # 80016988 <bcache>
    80002e08:	ffffe097          	auipc	ra,0xffffe
    80002e0c:	d3a080e7          	jalr	-710(ra) # 80000b42 <initlock>

  // Create linked list of buffers
  bcache.head.prev = &bcache.head;
    80002e10:	0001c797          	auipc	a5,0x1c
    80002e14:	b7878793          	addi	a5,a5,-1160 # 8001e988 <bcache+0x8000>
    80002e18:	0001c717          	auipc	a4,0x1c
    80002e1c:	dd870713          	addi	a4,a4,-552 # 8001ebf0 <bcache+0x8268>
    80002e20:	2ae7b823          	sd	a4,688(a5)
  bcache.head.next = &bcache.head;
    80002e24:	2ae7bc23          	sd	a4,696(a5)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    80002e28:	00014497          	auipc	s1,0x14
    80002e2c:	b7848493          	addi	s1,s1,-1160 # 800169a0 <bcache+0x18>
    b->next = bcache.head.next;
    80002e30:	893e                	mv	s2,a5
    b->prev = &bcache.head;
    80002e32:	89ba                	mv	s3,a4
    initsleeplock(&b->lock, "buffer");
    80002e34:	00005a17          	auipc	s4,0x5
    80002e38:	6dca0a13          	addi	s4,s4,1756 # 80008510 <syscalls+0xc0>
    b->next = bcache.head.next;
    80002e3c:	2b893783          	ld	a5,696(s2)
    80002e40:	e8bc                	sd	a5,80(s1)
    b->prev = &bcache.head;
    80002e42:	0534b423          	sd	s3,72(s1)
    initsleeplock(&b->lock, "buffer");
    80002e46:	85d2                	mv	a1,s4
    80002e48:	01048513          	addi	a0,s1,16
    80002e4c:	00001097          	auipc	ra,0x1
    80002e50:	496080e7          	jalr	1174(ra) # 800042e2 <initsleeplock>
    bcache.head.next->prev = b;
    80002e54:	2b893783          	ld	a5,696(s2)
    80002e58:	e7a4                	sd	s1,72(a5)
    bcache.head.next = b;
    80002e5a:	2a993c23          	sd	s1,696(s2)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    80002e5e:	45848493          	addi	s1,s1,1112
    80002e62:	fd349de3          	bne	s1,s3,80002e3c <binit+0x54>
  }
}
    80002e66:	70a2                	ld	ra,40(sp)
    80002e68:	7402                	ld	s0,32(sp)
    80002e6a:	64e2                	ld	s1,24(sp)
    80002e6c:	6942                	ld	s2,16(sp)
    80002e6e:	69a2                	ld	s3,8(sp)
    80002e70:	6a02                	ld	s4,0(sp)
    80002e72:	6145                	addi	sp,sp,48
    80002e74:	8082                	ret

0000000080002e76 <bread>:
}

// Return a locked buf with the contents of the indicated block.
struct buf*
bread(uint dev, uint blockno)
{
    80002e76:	7179                	addi	sp,sp,-48
    80002e78:	f406                	sd	ra,40(sp)
    80002e7a:	f022                	sd	s0,32(sp)
    80002e7c:	ec26                	sd	s1,24(sp)
    80002e7e:	e84a                	sd	s2,16(sp)
    80002e80:	e44e                	sd	s3,8(sp)
    80002e82:	1800                	addi	s0,sp,48
    80002e84:	892a                	mv	s2,a0
    80002e86:	89ae                	mv	s3,a1
  acquire(&bcache.lock);
    80002e88:	00014517          	auipc	a0,0x14
    80002e8c:	b0050513          	addi	a0,a0,-1280 # 80016988 <bcache>
    80002e90:	ffffe097          	auipc	ra,0xffffe
    80002e94:	d42080e7          	jalr	-702(ra) # 80000bd2 <acquire>
  for(b = bcache.head.next; b != &bcache.head; b = b->next){
    80002e98:	0001c497          	auipc	s1,0x1c
    80002e9c:	da84b483          	ld	s1,-600(s1) # 8001ec40 <bcache+0x82b8>
    80002ea0:	0001c797          	auipc	a5,0x1c
    80002ea4:	d5078793          	addi	a5,a5,-688 # 8001ebf0 <bcache+0x8268>
    80002ea8:	02f48f63          	beq	s1,a5,80002ee6 <bread+0x70>
    80002eac:	873e                	mv	a4,a5
    80002eae:	a021                	j	80002eb6 <bread+0x40>
    80002eb0:	68a4                	ld	s1,80(s1)
    80002eb2:	02e48a63          	beq	s1,a4,80002ee6 <bread+0x70>
    if(b->dev == dev && b->blockno == blockno){
    80002eb6:	449c                	lw	a5,8(s1)
    80002eb8:	ff279ce3          	bne	a5,s2,80002eb0 <bread+0x3a>
    80002ebc:	44dc                	lw	a5,12(s1)
    80002ebe:	ff3799e3          	bne	a5,s3,80002eb0 <bread+0x3a>
      b->refcnt++;
    80002ec2:	40bc                	lw	a5,64(s1)
    80002ec4:	2785                	addiw	a5,a5,1
    80002ec6:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    80002ec8:	00014517          	auipc	a0,0x14
    80002ecc:	ac050513          	addi	a0,a0,-1344 # 80016988 <bcache>
    80002ed0:	ffffe097          	auipc	ra,0xffffe
    80002ed4:	db6080e7          	jalr	-586(ra) # 80000c86 <release>
      acquiresleep(&b->lock);
    80002ed8:	01048513          	addi	a0,s1,16
    80002edc:	00001097          	auipc	ra,0x1
    80002ee0:	440080e7          	jalr	1088(ra) # 8000431c <acquiresleep>
      return b;
    80002ee4:	a8b9                	j	80002f42 <bread+0xcc>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    80002ee6:	0001c497          	auipc	s1,0x1c
    80002eea:	d524b483          	ld	s1,-686(s1) # 8001ec38 <bcache+0x82b0>
    80002eee:	0001c797          	auipc	a5,0x1c
    80002ef2:	d0278793          	addi	a5,a5,-766 # 8001ebf0 <bcache+0x8268>
    80002ef6:	00f48863          	beq	s1,a5,80002f06 <bread+0x90>
    80002efa:	873e                	mv	a4,a5
    if(b->refcnt == 0) {
    80002efc:	40bc                	lw	a5,64(s1)
    80002efe:	cf81                	beqz	a5,80002f16 <bread+0xa0>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    80002f00:	64a4                	ld	s1,72(s1)
    80002f02:	fee49de3          	bne	s1,a4,80002efc <bread+0x86>
  panic("bget: no buffers");
    80002f06:	00005517          	auipc	a0,0x5
    80002f0a:	61250513          	addi	a0,a0,1554 # 80008518 <syscalls+0xc8>
    80002f0e:	ffffd097          	auipc	ra,0xffffd
    80002f12:	62e080e7          	jalr	1582(ra) # 8000053c <panic>
      b->dev = dev;
    80002f16:	0124a423          	sw	s2,8(s1)
      b->blockno = blockno;
    80002f1a:	0134a623          	sw	s3,12(s1)
      b->valid = 0;
    80002f1e:	0004a023          	sw	zero,0(s1)
      b->refcnt = 1;
    80002f22:	4785                	li	a5,1
    80002f24:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    80002f26:	00014517          	auipc	a0,0x14
    80002f2a:	a6250513          	addi	a0,a0,-1438 # 80016988 <bcache>
    80002f2e:	ffffe097          	auipc	ra,0xffffe
    80002f32:	d58080e7          	jalr	-680(ra) # 80000c86 <release>
      acquiresleep(&b->lock);
    80002f36:	01048513          	addi	a0,s1,16
    80002f3a:	00001097          	auipc	ra,0x1
    80002f3e:	3e2080e7          	jalr	994(ra) # 8000431c <acquiresleep>
  struct buf *b;

  b = bget(dev, blockno);
  if(!b->valid) {
    80002f42:	409c                	lw	a5,0(s1)
    80002f44:	cb89                	beqz	a5,80002f56 <bread+0xe0>
    virtio_disk_rw(b, 0);
    b->valid = 1;
  }
  return b;
}
    80002f46:	8526                	mv	a0,s1
    80002f48:	70a2                	ld	ra,40(sp)
    80002f4a:	7402                	ld	s0,32(sp)
    80002f4c:	64e2                	ld	s1,24(sp)
    80002f4e:	6942                	ld	s2,16(sp)
    80002f50:	69a2                	ld	s3,8(sp)
    80002f52:	6145                	addi	sp,sp,48
    80002f54:	8082                	ret
    virtio_disk_rw(b, 0);
    80002f56:	4581                	li	a1,0
    80002f58:	8526                	mv	a0,s1
    80002f5a:	00003097          	auipc	ra,0x3
    80002f5e:	f78080e7          	jalr	-136(ra) # 80005ed2 <virtio_disk_rw>
    b->valid = 1;
    80002f62:	4785                	li	a5,1
    80002f64:	c09c                	sw	a5,0(s1)
  return b;
    80002f66:	b7c5                	j	80002f46 <bread+0xd0>

0000000080002f68 <bwrite>:

// Write b's contents to disk.  Must be locked.
void
bwrite(struct buf *b)
{
    80002f68:	1101                	addi	sp,sp,-32
    80002f6a:	ec06                	sd	ra,24(sp)
    80002f6c:	e822                	sd	s0,16(sp)
    80002f6e:	e426                	sd	s1,8(sp)
    80002f70:	1000                	addi	s0,sp,32
    80002f72:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    80002f74:	0541                	addi	a0,a0,16
    80002f76:	00001097          	auipc	ra,0x1
    80002f7a:	440080e7          	jalr	1088(ra) # 800043b6 <holdingsleep>
    80002f7e:	cd01                	beqz	a0,80002f96 <bwrite+0x2e>
    panic("bwrite");
  virtio_disk_rw(b, 1);
    80002f80:	4585                	li	a1,1
    80002f82:	8526                	mv	a0,s1
    80002f84:	00003097          	auipc	ra,0x3
    80002f88:	f4e080e7          	jalr	-178(ra) # 80005ed2 <virtio_disk_rw>
}
    80002f8c:	60e2                	ld	ra,24(sp)
    80002f8e:	6442                	ld	s0,16(sp)
    80002f90:	64a2                	ld	s1,8(sp)
    80002f92:	6105                	addi	sp,sp,32
    80002f94:	8082                	ret
    panic("bwrite");
    80002f96:	00005517          	auipc	a0,0x5
    80002f9a:	59a50513          	addi	a0,a0,1434 # 80008530 <syscalls+0xe0>
    80002f9e:	ffffd097          	auipc	ra,0xffffd
    80002fa2:	59e080e7          	jalr	1438(ra) # 8000053c <panic>

0000000080002fa6 <brelse>:

// Release a locked buffer.
// Move to the head of the most-recently-used list.
void
brelse(struct buf *b)
{
    80002fa6:	1101                	addi	sp,sp,-32
    80002fa8:	ec06                	sd	ra,24(sp)
    80002faa:	e822                	sd	s0,16(sp)
    80002fac:	e426                	sd	s1,8(sp)
    80002fae:	e04a                	sd	s2,0(sp)
    80002fb0:	1000                	addi	s0,sp,32
    80002fb2:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    80002fb4:	01050913          	addi	s2,a0,16
    80002fb8:	854a                	mv	a0,s2
    80002fba:	00001097          	auipc	ra,0x1
    80002fbe:	3fc080e7          	jalr	1020(ra) # 800043b6 <holdingsleep>
    80002fc2:	c925                	beqz	a0,80003032 <brelse+0x8c>
    panic("brelse");

  releasesleep(&b->lock);
    80002fc4:	854a                	mv	a0,s2
    80002fc6:	00001097          	auipc	ra,0x1
    80002fca:	3ac080e7          	jalr	940(ra) # 80004372 <releasesleep>

  acquire(&bcache.lock);
    80002fce:	00014517          	auipc	a0,0x14
    80002fd2:	9ba50513          	addi	a0,a0,-1606 # 80016988 <bcache>
    80002fd6:	ffffe097          	auipc	ra,0xffffe
    80002fda:	bfc080e7          	jalr	-1028(ra) # 80000bd2 <acquire>
  b->refcnt--;
    80002fde:	40bc                	lw	a5,64(s1)
    80002fe0:	37fd                	addiw	a5,a5,-1
    80002fe2:	0007871b          	sext.w	a4,a5
    80002fe6:	c0bc                	sw	a5,64(s1)
  if (b->refcnt == 0) {
    80002fe8:	e71d                	bnez	a4,80003016 <brelse+0x70>
    // no one is waiting for it.
    b->next->prev = b->prev;
    80002fea:	68b8                	ld	a4,80(s1)
    80002fec:	64bc                	ld	a5,72(s1)
    80002fee:	e73c                	sd	a5,72(a4)
    b->prev->next = b->next;
    80002ff0:	68b8                	ld	a4,80(s1)
    80002ff2:	ebb8                	sd	a4,80(a5)
    b->next = bcache.head.next;
    80002ff4:	0001c797          	auipc	a5,0x1c
    80002ff8:	99478793          	addi	a5,a5,-1644 # 8001e988 <bcache+0x8000>
    80002ffc:	2b87b703          	ld	a4,696(a5)
    80003000:	e8b8                	sd	a4,80(s1)
    b->prev = &bcache.head;
    80003002:	0001c717          	auipc	a4,0x1c
    80003006:	bee70713          	addi	a4,a4,-1042 # 8001ebf0 <bcache+0x8268>
    8000300a:	e4b8                	sd	a4,72(s1)
    bcache.head.next->prev = b;
    8000300c:	2b87b703          	ld	a4,696(a5)
    80003010:	e724                	sd	s1,72(a4)
    bcache.head.next = b;
    80003012:	2a97bc23          	sd	s1,696(a5)
  }
  
  release(&bcache.lock);
    80003016:	00014517          	auipc	a0,0x14
    8000301a:	97250513          	addi	a0,a0,-1678 # 80016988 <bcache>
    8000301e:	ffffe097          	auipc	ra,0xffffe
    80003022:	c68080e7          	jalr	-920(ra) # 80000c86 <release>
}
    80003026:	60e2                	ld	ra,24(sp)
    80003028:	6442                	ld	s0,16(sp)
    8000302a:	64a2                	ld	s1,8(sp)
    8000302c:	6902                	ld	s2,0(sp)
    8000302e:	6105                	addi	sp,sp,32
    80003030:	8082                	ret
    panic("brelse");
    80003032:	00005517          	auipc	a0,0x5
    80003036:	50650513          	addi	a0,a0,1286 # 80008538 <syscalls+0xe8>
    8000303a:	ffffd097          	auipc	ra,0xffffd
    8000303e:	502080e7          	jalr	1282(ra) # 8000053c <panic>

0000000080003042 <bpin>:

void
bpin(struct buf *b) {
    80003042:	1101                	addi	sp,sp,-32
    80003044:	ec06                	sd	ra,24(sp)
    80003046:	e822                	sd	s0,16(sp)
    80003048:	e426                	sd	s1,8(sp)
    8000304a:	1000                	addi	s0,sp,32
    8000304c:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    8000304e:	00014517          	auipc	a0,0x14
    80003052:	93a50513          	addi	a0,a0,-1734 # 80016988 <bcache>
    80003056:	ffffe097          	auipc	ra,0xffffe
    8000305a:	b7c080e7          	jalr	-1156(ra) # 80000bd2 <acquire>
  b->refcnt++;
    8000305e:	40bc                	lw	a5,64(s1)
    80003060:	2785                	addiw	a5,a5,1
    80003062:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    80003064:	00014517          	auipc	a0,0x14
    80003068:	92450513          	addi	a0,a0,-1756 # 80016988 <bcache>
    8000306c:	ffffe097          	auipc	ra,0xffffe
    80003070:	c1a080e7          	jalr	-998(ra) # 80000c86 <release>
}
    80003074:	60e2                	ld	ra,24(sp)
    80003076:	6442                	ld	s0,16(sp)
    80003078:	64a2                	ld	s1,8(sp)
    8000307a:	6105                	addi	sp,sp,32
    8000307c:	8082                	ret

000000008000307e <bunpin>:

void
bunpin(struct buf *b) {
    8000307e:	1101                	addi	sp,sp,-32
    80003080:	ec06                	sd	ra,24(sp)
    80003082:	e822                	sd	s0,16(sp)
    80003084:	e426                	sd	s1,8(sp)
    80003086:	1000                	addi	s0,sp,32
    80003088:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    8000308a:	00014517          	auipc	a0,0x14
    8000308e:	8fe50513          	addi	a0,a0,-1794 # 80016988 <bcache>
    80003092:	ffffe097          	auipc	ra,0xffffe
    80003096:	b40080e7          	jalr	-1216(ra) # 80000bd2 <acquire>
  b->refcnt--;
    8000309a:	40bc                	lw	a5,64(s1)
    8000309c:	37fd                	addiw	a5,a5,-1
    8000309e:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    800030a0:	00014517          	auipc	a0,0x14
    800030a4:	8e850513          	addi	a0,a0,-1816 # 80016988 <bcache>
    800030a8:	ffffe097          	auipc	ra,0xffffe
    800030ac:	bde080e7          	jalr	-1058(ra) # 80000c86 <release>
}
    800030b0:	60e2                	ld	ra,24(sp)
    800030b2:	6442                	ld	s0,16(sp)
    800030b4:	64a2                	ld	s1,8(sp)
    800030b6:	6105                	addi	sp,sp,32
    800030b8:	8082                	ret

00000000800030ba <bfree>:
}

// Free a disk block.
static void
bfree(int dev, uint b)
{
    800030ba:	1101                	addi	sp,sp,-32
    800030bc:	ec06                	sd	ra,24(sp)
    800030be:	e822                	sd	s0,16(sp)
    800030c0:	e426                	sd	s1,8(sp)
    800030c2:	e04a                	sd	s2,0(sp)
    800030c4:	1000                	addi	s0,sp,32
    800030c6:	84ae                	mv	s1,a1
  struct buf *bp;
  int bi, m;

  bp = bread(dev, BBLOCK(b, sb));
    800030c8:	00d5d59b          	srliw	a1,a1,0xd
    800030cc:	0001c797          	auipc	a5,0x1c
    800030d0:	f987a783          	lw	a5,-104(a5) # 8001f064 <sb+0x1c>
    800030d4:	9dbd                	addw	a1,a1,a5
    800030d6:	00000097          	auipc	ra,0x0
    800030da:	da0080e7          	jalr	-608(ra) # 80002e76 <bread>
  bi = b % BPB;
  m = 1 << (bi % 8);
    800030de:	0074f713          	andi	a4,s1,7
    800030e2:	4785                	li	a5,1
    800030e4:	00e797bb          	sllw	a5,a5,a4
  if((bp->data[bi/8] & m) == 0)
    800030e8:	14ce                	slli	s1,s1,0x33
    800030ea:	90d9                	srli	s1,s1,0x36
    800030ec:	00950733          	add	a4,a0,s1
    800030f0:	05874703          	lbu	a4,88(a4)
    800030f4:	00e7f6b3          	and	a3,a5,a4
    800030f8:	c69d                	beqz	a3,80003126 <bfree+0x6c>
    800030fa:	892a                	mv	s2,a0
    panic("freeing free block");
  bp->data[bi/8] &= ~m;
    800030fc:	94aa                	add	s1,s1,a0
    800030fe:	fff7c793          	not	a5,a5
    80003102:	8f7d                	and	a4,a4,a5
    80003104:	04e48c23          	sb	a4,88(s1)
  log_write(bp);
    80003108:	00001097          	auipc	ra,0x1
    8000310c:	0f6080e7          	jalr	246(ra) # 800041fe <log_write>
  brelse(bp);
    80003110:	854a                	mv	a0,s2
    80003112:	00000097          	auipc	ra,0x0
    80003116:	e94080e7          	jalr	-364(ra) # 80002fa6 <brelse>
}
    8000311a:	60e2                	ld	ra,24(sp)
    8000311c:	6442                	ld	s0,16(sp)
    8000311e:	64a2                	ld	s1,8(sp)
    80003120:	6902                	ld	s2,0(sp)
    80003122:	6105                	addi	sp,sp,32
    80003124:	8082                	ret
    panic("freeing free block");
    80003126:	00005517          	auipc	a0,0x5
    8000312a:	41a50513          	addi	a0,a0,1050 # 80008540 <syscalls+0xf0>
    8000312e:	ffffd097          	auipc	ra,0xffffd
    80003132:	40e080e7          	jalr	1038(ra) # 8000053c <panic>

0000000080003136 <balloc>:
{
    80003136:	711d                	addi	sp,sp,-96
    80003138:	ec86                	sd	ra,88(sp)
    8000313a:	e8a2                	sd	s0,80(sp)
    8000313c:	e4a6                	sd	s1,72(sp)
    8000313e:	e0ca                	sd	s2,64(sp)
    80003140:	fc4e                	sd	s3,56(sp)
    80003142:	f852                	sd	s4,48(sp)
    80003144:	f456                	sd	s5,40(sp)
    80003146:	f05a                	sd	s6,32(sp)
    80003148:	ec5e                	sd	s7,24(sp)
    8000314a:	e862                	sd	s8,16(sp)
    8000314c:	e466                	sd	s9,8(sp)
    8000314e:	1080                	addi	s0,sp,96
  for(b = 0; b < sb.size; b += BPB){
    80003150:	0001c797          	auipc	a5,0x1c
    80003154:	efc7a783          	lw	a5,-260(a5) # 8001f04c <sb+0x4>
    80003158:	cff5                	beqz	a5,80003254 <balloc+0x11e>
    8000315a:	8baa                	mv	s7,a0
    8000315c:	4a81                	li	s5,0
    bp = bread(dev, BBLOCK(b, sb));
    8000315e:	0001cb17          	auipc	s6,0x1c
    80003162:	eeab0b13          	addi	s6,s6,-278 # 8001f048 <sb>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80003166:	4c01                	li	s8,0
      m = 1 << (bi % 8);
    80003168:	4985                	li	s3,1
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    8000316a:	6a09                	lui	s4,0x2
  for(b = 0; b < sb.size; b += BPB){
    8000316c:	6c89                	lui	s9,0x2
    8000316e:	a061                	j	800031f6 <balloc+0xc0>
        bp->data[bi/8] |= m;  // Mark block in use.
    80003170:	97ca                	add	a5,a5,s2
    80003172:	8e55                	or	a2,a2,a3
    80003174:	04c78c23          	sb	a2,88(a5)
        log_write(bp);
    80003178:	854a                	mv	a0,s2
    8000317a:	00001097          	auipc	ra,0x1
    8000317e:	084080e7          	jalr	132(ra) # 800041fe <log_write>
        brelse(bp);
    80003182:	854a                	mv	a0,s2
    80003184:	00000097          	auipc	ra,0x0
    80003188:	e22080e7          	jalr	-478(ra) # 80002fa6 <brelse>
  bp = bread(dev, bno);
    8000318c:	85a6                	mv	a1,s1
    8000318e:	855e                	mv	a0,s7
    80003190:	00000097          	auipc	ra,0x0
    80003194:	ce6080e7          	jalr	-794(ra) # 80002e76 <bread>
    80003198:	892a                	mv	s2,a0
  memset(bp->data, 0, BSIZE);
    8000319a:	40000613          	li	a2,1024
    8000319e:	4581                	li	a1,0
    800031a0:	05850513          	addi	a0,a0,88
    800031a4:	ffffe097          	auipc	ra,0xffffe
    800031a8:	b2a080e7          	jalr	-1238(ra) # 80000cce <memset>
  log_write(bp);
    800031ac:	854a                	mv	a0,s2
    800031ae:	00001097          	auipc	ra,0x1
    800031b2:	050080e7          	jalr	80(ra) # 800041fe <log_write>
  brelse(bp);
    800031b6:	854a                	mv	a0,s2
    800031b8:	00000097          	auipc	ra,0x0
    800031bc:	dee080e7          	jalr	-530(ra) # 80002fa6 <brelse>
}
    800031c0:	8526                	mv	a0,s1
    800031c2:	60e6                	ld	ra,88(sp)
    800031c4:	6446                	ld	s0,80(sp)
    800031c6:	64a6                	ld	s1,72(sp)
    800031c8:	6906                	ld	s2,64(sp)
    800031ca:	79e2                	ld	s3,56(sp)
    800031cc:	7a42                	ld	s4,48(sp)
    800031ce:	7aa2                	ld	s5,40(sp)
    800031d0:	7b02                	ld	s6,32(sp)
    800031d2:	6be2                	ld	s7,24(sp)
    800031d4:	6c42                	ld	s8,16(sp)
    800031d6:	6ca2                	ld	s9,8(sp)
    800031d8:	6125                	addi	sp,sp,96
    800031da:	8082                	ret
    brelse(bp);
    800031dc:	854a                	mv	a0,s2
    800031de:	00000097          	auipc	ra,0x0
    800031e2:	dc8080e7          	jalr	-568(ra) # 80002fa6 <brelse>
  for(b = 0; b < sb.size; b += BPB){
    800031e6:	015c87bb          	addw	a5,s9,s5
    800031ea:	00078a9b          	sext.w	s5,a5
    800031ee:	004b2703          	lw	a4,4(s6)
    800031f2:	06eaf163          	bgeu	s5,a4,80003254 <balloc+0x11e>
    bp = bread(dev, BBLOCK(b, sb));
    800031f6:	41fad79b          	sraiw	a5,s5,0x1f
    800031fa:	0137d79b          	srliw	a5,a5,0x13
    800031fe:	015787bb          	addw	a5,a5,s5
    80003202:	40d7d79b          	sraiw	a5,a5,0xd
    80003206:	01cb2583          	lw	a1,28(s6)
    8000320a:	9dbd                	addw	a1,a1,a5
    8000320c:	855e                	mv	a0,s7
    8000320e:	00000097          	auipc	ra,0x0
    80003212:	c68080e7          	jalr	-920(ra) # 80002e76 <bread>
    80003216:	892a                	mv	s2,a0
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80003218:	004b2503          	lw	a0,4(s6)
    8000321c:	000a849b          	sext.w	s1,s5
    80003220:	8762                	mv	a4,s8
    80003222:	faa4fde3          	bgeu	s1,a0,800031dc <balloc+0xa6>
      m = 1 << (bi % 8);
    80003226:	00777693          	andi	a3,a4,7
    8000322a:	00d996bb          	sllw	a3,s3,a3
      if((bp->data[bi/8] & m) == 0){  // Is block free?
    8000322e:	41f7579b          	sraiw	a5,a4,0x1f
    80003232:	01d7d79b          	srliw	a5,a5,0x1d
    80003236:	9fb9                	addw	a5,a5,a4
    80003238:	4037d79b          	sraiw	a5,a5,0x3
    8000323c:	00f90633          	add	a2,s2,a5
    80003240:	05864603          	lbu	a2,88(a2)
    80003244:	00c6f5b3          	and	a1,a3,a2
    80003248:	d585                	beqz	a1,80003170 <balloc+0x3a>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    8000324a:	2705                	addiw	a4,a4,1
    8000324c:	2485                	addiw	s1,s1,1
    8000324e:	fd471ae3          	bne	a4,s4,80003222 <balloc+0xec>
    80003252:	b769                	j	800031dc <balloc+0xa6>
  printf("balloc: out of blocks\n");
    80003254:	00005517          	auipc	a0,0x5
    80003258:	30450513          	addi	a0,a0,772 # 80008558 <syscalls+0x108>
    8000325c:	ffffd097          	auipc	ra,0xffffd
    80003260:	32a080e7          	jalr	810(ra) # 80000586 <printf>
  return 0;
    80003264:	4481                	li	s1,0
    80003266:	bfa9                	j	800031c0 <balloc+0x8a>

0000000080003268 <bmap>:
// Return the disk block address of the nth block in inode ip.
// If there is no such block, bmap allocates one.
// returns 0 if out of disk space.
static uint
bmap(struct inode *ip, uint bn)
{
    80003268:	7179                	addi	sp,sp,-48
    8000326a:	f406                	sd	ra,40(sp)
    8000326c:	f022                	sd	s0,32(sp)
    8000326e:	ec26                	sd	s1,24(sp)
    80003270:	e84a                	sd	s2,16(sp)
    80003272:	e44e                	sd	s3,8(sp)
    80003274:	e052                	sd	s4,0(sp)
    80003276:	1800                	addi	s0,sp,48
    80003278:	89aa                	mv	s3,a0
  uint addr, *a;
  struct buf *bp;

  if(bn < NDIRECT){
    8000327a:	47ad                	li	a5,11
    8000327c:	02b7e863          	bltu	a5,a1,800032ac <bmap+0x44>
    if((addr = ip->addrs[bn]) == 0){
    80003280:	02059793          	slli	a5,a1,0x20
    80003284:	01e7d593          	srli	a1,a5,0x1e
    80003288:	00b504b3          	add	s1,a0,a1
    8000328c:	0504a903          	lw	s2,80(s1)
    80003290:	06091e63          	bnez	s2,8000330c <bmap+0xa4>
      addr = balloc(ip->dev);
    80003294:	4108                	lw	a0,0(a0)
    80003296:	00000097          	auipc	ra,0x0
    8000329a:	ea0080e7          	jalr	-352(ra) # 80003136 <balloc>
    8000329e:	0005091b          	sext.w	s2,a0
      if(addr == 0)
    800032a2:	06090563          	beqz	s2,8000330c <bmap+0xa4>
        return 0;
      ip->addrs[bn] = addr;
    800032a6:	0524a823          	sw	s2,80(s1)
    800032aa:	a08d                	j	8000330c <bmap+0xa4>
    }
    return addr;
  }
  bn -= NDIRECT;
    800032ac:	ff45849b          	addiw	s1,a1,-12
    800032b0:	0004871b          	sext.w	a4,s1

  if(bn < NINDIRECT){
    800032b4:	0ff00793          	li	a5,255
    800032b8:	08e7e563          	bltu	a5,a4,80003342 <bmap+0xda>
    // Load indirect block, allocating if necessary.
    if((addr = ip->addrs[NDIRECT]) == 0){
    800032bc:	08052903          	lw	s2,128(a0)
    800032c0:	00091d63          	bnez	s2,800032da <bmap+0x72>
      addr = balloc(ip->dev);
    800032c4:	4108                	lw	a0,0(a0)
    800032c6:	00000097          	auipc	ra,0x0
    800032ca:	e70080e7          	jalr	-400(ra) # 80003136 <balloc>
    800032ce:	0005091b          	sext.w	s2,a0
      if(addr == 0)
    800032d2:	02090d63          	beqz	s2,8000330c <bmap+0xa4>
        return 0;
      ip->addrs[NDIRECT] = addr;
    800032d6:	0929a023          	sw	s2,128(s3)
    }
    bp = bread(ip->dev, addr);
    800032da:	85ca                	mv	a1,s2
    800032dc:	0009a503          	lw	a0,0(s3)
    800032e0:	00000097          	auipc	ra,0x0
    800032e4:	b96080e7          	jalr	-1130(ra) # 80002e76 <bread>
    800032e8:	8a2a                	mv	s4,a0
    a = (uint*)bp->data;
    800032ea:	05850793          	addi	a5,a0,88
    if((addr = a[bn]) == 0){
    800032ee:	02049713          	slli	a4,s1,0x20
    800032f2:	01e75593          	srli	a1,a4,0x1e
    800032f6:	00b784b3          	add	s1,a5,a1
    800032fa:	0004a903          	lw	s2,0(s1)
    800032fe:	02090063          	beqz	s2,8000331e <bmap+0xb6>
      if(addr){
        a[bn] = addr;
        log_write(bp);
      }
    }
    brelse(bp);
    80003302:	8552                	mv	a0,s4
    80003304:	00000097          	auipc	ra,0x0
    80003308:	ca2080e7          	jalr	-862(ra) # 80002fa6 <brelse>
    return addr;
  }

  panic("bmap: out of range");
}
    8000330c:	854a                	mv	a0,s2
    8000330e:	70a2                	ld	ra,40(sp)
    80003310:	7402                	ld	s0,32(sp)
    80003312:	64e2                	ld	s1,24(sp)
    80003314:	6942                	ld	s2,16(sp)
    80003316:	69a2                	ld	s3,8(sp)
    80003318:	6a02                	ld	s4,0(sp)
    8000331a:	6145                	addi	sp,sp,48
    8000331c:	8082                	ret
      addr = balloc(ip->dev);
    8000331e:	0009a503          	lw	a0,0(s3)
    80003322:	00000097          	auipc	ra,0x0
    80003326:	e14080e7          	jalr	-492(ra) # 80003136 <balloc>
    8000332a:	0005091b          	sext.w	s2,a0
      if(addr){
    8000332e:	fc090ae3          	beqz	s2,80003302 <bmap+0x9a>
        a[bn] = addr;
    80003332:	0124a023          	sw	s2,0(s1)
        log_write(bp);
    80003336:	8552                	mv	a0,s4
    80003338:	00001097          	auipc	ra,0x1
    8000333c:	ec6080e7          	jalr	-314(ra) # 800041fe <log_write>
    80003340:	b7c9                	j	80003302 <bmap+0x9a>
  panic("bmap: out of range");
    80003342:	00005517          	auipc	a0,0x5
    80003346:	22e50513          	addi	a0,a0,558 # 80008570 <syscalls+0x120>
    8000334a:	ffffd097          	auipc	ra,0xffffd
    8000334e:	1f2080e7          	jalr	498(ra) # 8000053c <panic>

0000000080003352 <iget>:
{
    80003352:	7179                	addi	sp,sp,-48
    80003354:	f406                	sd	ra,40(sp)
    80003356:	f022                	sd	s0,32(sp)
    80003358:	ec26                	sd	s1,24(sp)
    8000335a:	e84a                	sd	s2,16(sp)
    8000335c:	e44e                	sd	s3,8(sp)
    8000335e:	e052                	sd	s4,0(sp)
    80003360:	1800                	addi	s0,sp,48
    80003362:	89aa                	mv	s3,a0
    80003364:	8a2e                	mv	s4,a1
  acquire(&itable.lock);
    80003366:	0001c517          	auipc	a0,0x1c
    8000336a:	d0250513          	addi	a0,a0,-766 # 8001f068 <itable>
    8000336e:	ffffe097          	auipc	ra,0xffffe
    80003372:	864080e7          	jalr	-1948(ra) # 80000bd2 <acquire>
  empty = 0;
    80003376:	4901                	li	s2,0
  for(ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++){
    80003378:	0001c497          	auipc	s1,0x1c
    8000337c:	d0848493          	addi	s1,s1,-760 # 8001f080 <itable+0x18>
    80003380:	0001d697          	auipc	a3,0x1d
    80003384:	79068693          	addi	a3,a3,1936 # 80020b10 <log>
    80003388:	a039                	j	80003396 <iget+0x44>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    8000338a:	02090b63          	beqz	s2,800033c0 <iget+0x6e>
  for(ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++){
    8000338e:	08848493          	addi	s1,s1,136
    80003392:	02d48a63          	beq	s1,a3,800033c6 <iget+0x74>
    if(ip->ref > 0 && ip->dev == dev && ip->inum == inum){
    80003396:	449c                	lw	a5,8(s1)
    80003398:	fef059e3          	blez	a5,8000338a <iget+0x38>
    8000339c:	4098                	lw	a4,0(s1)
    8000339e:	ff3716e3          	bne	a4,s3,8000338a <iget+0x38>
    800033a2:	40d8                	lw	a4,4(s1)
    800033a4:	ff4713e3          	bne	a4,s4,8000338a <iget+0x38>
      ip->ref++;
    800033a8:	2785                	addiw	a5,a5,1
    800033aa:	c49c                	sw	a5,8(s1)
      release(&itable.lock);
    800033ac:	0001c517          	auipc	a0,0x1c
    800033b0:	cbc50513          	addi	a0,a0,-836 # 8001f068 <itable>
    800033b4:	ffffe097          	auipc	ra,0xffffe
    800033b8:	8d2080e7          	jalr	-1838(ra) # 80000c86 <release>
      return ip;
    800033bc:	8926                	mv	s2,s1
    800033be:	a03d                	j	800033ec <iget+0x9a>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    800033c0:	f7f9                	bnez	a5,8000338e <iget+0x3c>
    800033c2:	8926                	mv	s2,s1
    800033c4:	b7e9                	j	8000338e <iget+0x3c>
  if(empty == 0)
    800033c6:	02090c63          	beqz	s2,800033fe <iget+0xac>
  ip->dev = dev;
    800033ca:	01392023          	sw	s3,0(s2)
  ip->inum = inum;
    800033ce:	01492223          	sw	s4,4(s2)
  ip->ref = 1;
    800033d2:	4785                	li	a5,1
    800033d4:	00f92423          	sw	a5,8(s2)
  ip->valid = 0;
    800033d8:	04092023          	sw	zero,64(s2)
  release(&itable.lock);
    800033dc:	0001c517          	auipc	a0,0x1c
    800033e0:	c8c50513          	addi	a0,a0,-884 # 8001f068 <itable>
    800033e4:	ffffe097          	auipc	ra,0xffffe
    800033e8:	8a2080e7          	jalr	-1886(ra) # 80000c86 <release>
}
    800033ec:	854a                	mv	a0,s2
    800033ee:	70a2                	ld	ra,40(sp)
    800033f0:	7402                	ld	s0,32(sp)
    800033f2:	64e2                	ld	s1,24(sp)
    800033f4:	6942                	ld	s2,16(sp)
    800033f6:	69a2                	ld	s3,8(sp)
    800033f8:	6a02                	ld	s4,0(sp)
    800033fa:	6145                	addi	sp,sp,48
    800033fc:	8082                	ret
    panic("iget: no inodes");
    800033fe:	00005517          	auipc	a0,0x5
    80003402:	18a50513          	addi	a0,a0,394 # 80008588 <syscalls+0x138>
    80003406:	ffffd097          	auipc	ra,0xffffd
    8000340a:	136080e7          	jalr	310(ra) # 8000053c <panic>

000000008000340e <fsinit>:
fsinit(int dev) {
    8000340e:	7179                	addi	sp,sp,-48
    80003410:	f406                	sd	ra,40(sp)
    80003412:	f022                	sd	s0,32(sp)
    80003414:	ec26                	sd	s1,24(sp)
    80003416:	e84a                	sd	s2,16(sp)
    80003418:	e44e                	sd	s3,8(sp)
    8000341a:	1800                	addi	s0,sp,48
    8000341c:	892a                	mv	s2,a0
  bp = bread(dev, 1);
    8000341e:	4585                	li	a1,1
    80003420:	00000097          	auipc	ra,0x0
    80003424:	a56080e7          	jalr	-1450(ra) # 80002e76 <bread>
    80003428:	84aa                	mv	s1,a0
  memmove(sb, bp->data, sizeof(*sb));
    8000342a:	0001c997          	auipc	s3,0x1c
    8000342e:	c1e98993          	addi	s3,s3,-994 # 8001f048 <sb>
    80003432:	02000613          	li	a2,32
    80003436:	05850593          	addi	a1,a0,88
    8000343a:	854e                	mv	a0,s3
    8000343c:	ffffe097          	auipc	ra,0xffffe
    80003440:	8ee080e7          	jalr	-1810(ra) # 80000d2a <memmove>
  brelse(bp);
    80003444:	8526                	mv	a0,s1
    80003446:	00000097          	auipc	ra,0x0
    8000344a:	b60080e7          	jalr	-1184(ra) # 80002fa6 <brelse>
  if(sb.magic != FSMAGIC)
    8000344e:	0009a703          	lw	a4,0(s3)
    80003452:	102037b7          	lui	a5,0x10203
    80003456:	04078793          	addi	a5,a5,64 # 10203040 <_entry-0x6fdfcfc0>
    8000345a:	02f71263          	bne	a4,a5,8000347e <fsinit+0x70>
  initlog(dev, &sb);
    8000345e:	0001c597          	auipc	a1,0x1c
    80003462:	bea58593          	addi	a1,a1,-1046 # 8001f048 <sb>
    80003466:	854a                	mv	a0,s2
    80003468:	00001097          	auipc	ra,0x1
    8000346c:	b2c080e7          	jalr	-1236(ra) # 80003f94 <initlog>
}
    80003470:	70a2                	ld	ra,40(sp)
    80003472:	7402                	ld	s0,32(sp)
    80003474:	64e2                	ld	s1,24(sp)
    80003476:	6942                	ld	s2,16(sp)
    80003478:	69a2                	ld	s3,8(sp)
    8000347a:	6145                	addi	sp,sp,48
    8000347c:	8082                	ret
    panic("invalid file system");
    8000347e:	00005517          	auipc	a0,0x5
    80003482:	11a50513          	addi	a0,a0,282 # 80008598 <syscalls+0x148>
    80003486:	ffffd097          	auipc	ra,0xffffd
    8000348a:	0b6080e7          	jalr	182(ra) # 8000053c <panic>

000000008000348e <iinit>:
{
    8000348e:	7179                	addi	sp,sp,-48
    80003490:	f406                	sd	ra,40(sp)
    80003492:	f022                	sd	s0,32(sp)
    80003494:	ec26                	sd	s1,24(sp)
    80003496:	e84a                	sd	s2,16(sp)
    80003498:	e44e                	sd	s3,8(sp)
    8000349a:	1800                	addi	s0,sp,48
  initlock(&itable.lock, "itable");
    8000349c:	00005597          	auipc	a1,0x5
    800034a0:	11458593          	addi	a1,a1,276 # 800085b0 <syscalls+0x160>
    800034a4:	0001c517          	auipc	a0,0x1c
    800034a8:	bc450513          	addi	a0,a0,-1084 # 8001f068 <itable>
    800034ac:	ffffd097          	auipc	ra,0xffffd
    800034b0:	696080e7          	jalr	1686(ra) # 80000b42 <initlock>
  for(i = 0; i < NINODE; i++) {
    800034b4:	0001c497          	auipc	s1,0x1c
    800034b8:	bdc48493          	addi	s1,s1,-1060 # 8001f090 <itable+0x28>
    800034bc:	0001d997          	auipc	s3,0x1d
    800034c0:	66498993          	addi	s3,s3,1636 # 80020b20 <log+0x10>
    initsleeplock(&itable.inode[i].lock, "inode");
    800034c4:	00005917          	auipc	s2,0x5
    800034c8:	0f490913          	addi	s2,s2,244 # 800085b8 <syscalls+0x168>
    800034cc:	85ca                	mv	a1,s2
    800034ce:	8526                	mv	a0,s1
    800034d0:	00001097          	auipc	ra,0x1
    800034d4:	e12080e7          	jalr	-494(ra) # 800042e2 <initsleeplock>
  for(i = 0; i < NINODE; i++) {
    800034d8:	08848493          	addi	s1,s1,136
    800034dc:	ff3498e3          	bne	s1,s3,800034cc <iinit+0x3e>
}
    800034e0:	70a2                	ld	ra,40(sp)
    800034e2:	7402                	ld	s0,32(sp)
    800034e4:	64e2                	ld	s1,24(sp)
    800034e6:	6942                	ld	s2,16(sp)
    800034e8:	69a2                	ld	s3,8(sp)
    800034ea:	6145                	addi	sp,sp,48
    800034ec:	8082                	ret

00000000800034ee <ialloc>:
{
    800034ee:	7139                	addi	sp,sp,-64
    800034f0:	fc06                	sd	ra,56(sp)
    800034f2:	f822                	sd	s0,48(sp)
    800034f4:	f426                	sd	s1,40(sp)
    800034f6:	f04a                	sd	s2,32(sp)
    800034f8:	ec4e                	sd	s3,24(sp)
    800034fa:	e852                	sd	s4,16(sp)
    800034fc:	e456                	sd	s5,8(sp)
    800034fe:	e05a                	sd	s6,0(sp)
    80003500:	0080                	addi	s0,sp,64
  for(inum = 1; inum < sb.ninodes; inum++){
    80003502:	0001c717          	auipc	a4,0x1c
    80003506:	b5272703          	lw	a4,-1198(a4) # 8001f054 <sb+0xc>
    8000350a:	4785                	li	a5,1
    8000350c:	04e7f863          	bgeu	a5,a4,8000355c <ialloc+0x6e>
    80003510:	8aaa                	mv	s5,a0
    80003512:	8b2e                	mv	s6,a1
    80003514:	4905                	li	s2,1
    bp = bread(dev, IBLOCK(inum, sb));
    80003516:	0001ca17          	auipc	s4,0x1c
    8000351a:	b32a0a13          	addi	s4,s4,-1230 # 8001f048 <sb>
    8000351e:	00495593          	srli	a1,s2,0x4
    80003522:	018a2783          	lw	a5,24(s4)
    80003526:	9dbd                	addw	a1,a1,a5
    80003528:	8556                	mv	a0,s5
    8000352a:	00000097          	auipc	ra,0x0
    8000352e:	94c080e7          	jalr	-1716(ra) # 80002e76 <bread>
    80003532:	84aa                	mv	s1,a0
    dip = (struct dinode*)bp->data + inum%IPB;
    80003534:	05850993          	addi	s3,a0,88
    80003538:	00f97793          	andi	a5,s2,15
    8000353c:	079a                	slli	a5,a5,0x6
    8000353e:	99be                	add	s3,s3,a5
    if(dip->type == 0){  // a free inode
    80003540:	00099783          	lh	a5,0(s3)
    80003544:	cf9d                	beqz	a5,80003582 <ialloc+0x94>
    brelse(bp);
    80003546:	00000097          	auipc	ra,0x0
    8000354a:	a60080e7          	jalr	-1440(ra) # 80002fa6 <brelse>
  for(inum = 1; inum < sb.ninodes; inum++){
    8000354e:	0905                	addi	s2,s2,1
    80003550:	00ca2703          	lw	a4,12(s4)
    80003554:	0009079b          	sext.w	a5,s2
    80003558:	fce7e3e3          	bltu	a5,a4,8000351e <ialloc+0x30>
  printf("ialloc: no inodes\n");
    8000355c:	00005517          	auipc	a0,0x5
    80003560:	06450513          	addi	a0,a0,100 # 800085c0 <syscalls+0x170>
    80003564:	ffffd097          	auipc	ra,0xffffd
    80003568:	022080e7          	jalr	34(ra) # 80000586 <printf>
  return 0;
    8000356c:	4501                	li	a0,0
}
    8000356e:	70e2                	ld	ra,56(sp)
    80003570:	7442                	ld	s0,48(sp)
    80003572:	74a2                	ld	s1,40(sp)
    80003574:	7902                	ld	s2,32(sp)
    80003576:	69e2                	ld	s3,24(sp)
    80003578:	6a42                	ld	s4,16(sp)
    8000357a:	6aa2                	ld	s5,8(sp)
    8000357c:	6b02                	ld	s6,0(sp)
    8000357e:	6121                	addi	sp,sp,64
    80003580:	8082                	ret
      memset(dip, 0, sizeof(*dip));
    80003582:	04000613          	li	a2,64
    80003586:	4581                	li	a1,0
    80003588:	854e                	mv	a0,s3
    8000358a:	ffffd097          	auipc	ra,0xffffd
    8000358e:	744080e7          	jalr	1860(ra) # 80000cce <memset>
      dip->type = type;
    80003592:	01699023          	sh	s6,0(s3)
      log_write(bp);   // mark it allocated on the disk
    80003596:	8526                	mv	a0,s1
    80003598:	00001097          	auipc	ra,0x1
    8000359c:	c66080e7          	jalr	-922(ra) # 800041fe <log_write>
      brelse(bp);
    800035a0:	8526                	mv	a0,s1
    800035a2:	00000097          	auipc	ra,0x0
    800035a6:	a04080e7          	jalr	-1532(ra) # 80002fa6 <brelse>
      return iget(dev, inum);
    800035aa:	0009059b          	sext.w	a1,s2
    800035ae:	8556                	mv	a0,s5
    800035b0:	00000097          	auipc	ra,0x0
    800035b4:	da2080e7          	jalr	-606(ra) # 80003352 <iget>
    800035b8:	bf5d                	j	8000356e <ialloc+0x80>

00000000800035ba <iupdate>:
{
    800035ba:	1101                	addi	sp,sp,-32
    800035bc:	ec06                	sd	ra,24(sp)
    800035be:	e822                	sd	s0,16(sp)
    800035c0:	e426                	sd	s1,8(sp)
    800035c2:	e04a                	sd	s2,0(sp)
    800035c4:	1000                	addi	s0,sp,32
    800035c6:	84aa                	mv	s1,a0
  bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    800035c8:	415c                	lw	a5,4(a0)
    800035ca:	0047d79b          	srliw	a5,a5,0x4
    800035ce:	0001c597          	auipc	a1,0x1c
    800035d2:	a925a583          	lw	a1,-1390(a1) # 8001f060 <sb+0x18>
    800035d6:	9dbd                	addw	a1,a1,a5
    800035d8:	4108                	lw	a0,0(a0)
    800035da:	00000097          	auipc	ra,0x0
    800035de:	89c080e7          	jalr	-1892(ra) # 80002e76 <bread>
    800035e2:	892a                	mv	s2,a0
  dip = (struct dinode*)bp->data + ip->inum%IPB;
    800035e4:	05850793          	addi	a5,a0,88
    800035e8:	40d8                	lw	a4,4(s1)
    800035ea:	8b3d                	andi	a4,a4,15
    800035ec:	071a                	slli	a4,a4,0x6
    800035ee:	97ba                	add	a5,a5,a4
  dip->type = ip->type;
    800035f0:	04449703          	lh	a4,68(s1)
    800035f4:	00e79023          	sh	a4,0(a5)
  dip->major = ip->major;
    800035f8:	04649703          	lh	a4,70(s1)
    800035fc:	00e79123          	sh	a4,2(a5)
  dip->minor = ip->minor;
    80003600:	04849703          	lh	a4,72(s1)
    80003604:	00e79223          	sh	a4,4(a5)
  dip->nlink = ip->nlink;
    80003608:	04a49703          	lh	a4,74(s1)
    8000360c:	00e79323          	sh	a4,6(a5)
  dip->size = ip->size;
    80003610:	44f8                	lw	a4,76(s1)
    80003612:	c798                	sw	a4,8(a5)
  memmove(dip->addrs, ip->addrs, sizeof(ip->addrs));
    80003614:	03400613          	li	a2,52
    80003618:	05048593          	addi	a1,s1,80
    8000361c:	00c78513          	addi	a0,a5,12
    80003620:	ffffd097          	auipc	ra,0xffffd
    80003624:	70a080e7          	jalr	1802(ra) # 80000d2a <memmove>
  log_write(bp);
    80003628:	854a                	mv	a0,s2
    8000362a:	00001097          	auipc	ra,0x1
    8000362e:	bd4080e7          	jalr	-1068(ra) # 800041fe <log_write>
  brelse(bp);
    80003632:	854a                	mv	a0,s2
    80003634:	00000097          	auipc	ra,0x0
    80003638:	972080e7          	jalr	-1678(ra) # 80002fa6 <brelse>
}
    8000363c:	60e2                	ld	ra,24(sp)
    8000363e:	6442                	ld	s0,16(sp)
    80003640:	64a2                	ld	s1,8(sp)
    80003642:	6902                	ld	s2,0(sp)
    80003644:	6105                	addi	sp,sp,32
    80003646:	8082                	ret

0000000080003648 <idup>:
{
    80003648:	1101                	addi	sp,sp,-32
    8000364a:	ec06                	sd	ra,24(sp)
    8000364c:	e822                	sd	s0,16(sp)
    8000364e:	e426                	sd	s1,8(sp)
    80003650:	1000                	addi	s0,sp,32
    80003652:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    80003654:	0001c517          	auipc	a0,0x1c
    80003658:	a1450513          	addi	a0,a0,-1516 # 8001f068 <itable>
    8000365c:	ffffd097          	auipc	ra,0xffffd
    80003660:	576080e7          	jalr	1398(ra) # 80000bd2 <acquire>
  ip->ref++;
    80003664:	449c                	lw	a5,8(s1)
    80003666:	2785                	addiw	a5,a5,1
    80003668:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    8000366a:	0001c517          	auipc	a0,0x1c
    8000366e:	9fe50513          	addi	a0,a0,-1538 # 8001f068 <itable>
    80003672:	ffffd097          	auipc	ra,0xffffd
    80003676:	614080e7          	jalr	1556(ra) # 80000c86 <release>
}
    8000367a:	8526                	mv	a0,s1
    8000367c:	60e2                	ld	ra,24(sp)
    8000367e:	6442                	ld	s0,16(sp)
    80003680:	64a2                	ld	s1,8(sp)
    80003682:	6105                	addi	sp,sp,32
    80003684:	8082                	ret

0000000080003686 <ilock>:
{
    80003686:	1101                	addi	sp,sp,-32
    80003688:	ec06                	sd	ra,24(sp)
    8000368a:	e822                	sd	s0,16(sp)
    8000368c:	e426                	sd	s1,8(sp)
    8000368e:	e04a                	sd	s2,0(sp)
    80003690:	1000                	addi	s0,sp,32
  if(ip == 0 || ip->ref < 1)
    80003692:	c115                	beqz	a0,800036b6 <ilock+0x30>
    80003694:	84aa                	mv	s1,a0
    80003696:	451c                	lw	a5,8(a0)
    80003698:	00f05f63          	blez	a5,800036b6 <ilock+0x30>
  acquiresleep(&ip->lock);
    8000369c:	0541                	addi	a0,a0,16
    8000369e:	00001097          	auipc	ra,0x1
    800036a2:	c7e080e7          	jalr	-898(ra) # 8000431c <acquiresleep>
  if(ip->valid == 0){
    800036a6:	40bc                	lw	a5,64(s1)
    800036a8:	cf99                	beqz	a5,800036c6 <ilock+0x40>
}
    800036aa:	60e2                	ld	ra,24(sp)
    800036ac:	6442                	ld	s0,16(sp)
    800036ae:	64a2                	ld	s1,8(sp)
    800036b0:	6902                	ld	s2,0(sp)
    800036b2:	6105                	addi	sp,sp,32
    800036b4:	8082                	ret
    panic("ilock");
    800036b6:	00005517          	auipc	a0,0x5
    800036ba:	f2250513          	addi	a0,a0,-222 # 800085d8 <syscalls+0x188>
    800036be:	ffffd097          	auipc	ra,0xffffd
    800036c2:	e7e080e7          	jalr	-386(ra) # 8000053c <panic>
    bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    800036c6:	40dc                	lw	a5,4(s1)
    800036c8:	0047d79b          	srliw	a5,a5,0x4
    800036cc:	0001c597          	auipc	a1,0x1c
    800036d0:	9945a583          	lw	a1,-1644(a1) # 8001f060 <sb+0x18>
    800036d4:	9dbd                	addw	a1,a1,a5
    800036d6:	4088                	lw	a0,0(s1)
    800036d8:	fffff097          	auipc	ra,0xfffff
    800036dc:	79e080e7          	jalr	1950(ra) # 80002e76 <bread>
    800036e0:	892a                	mv	s2,a0
    dip = (struct dinode*)bp->data + ip->inum%IPB;
    800036e2:	05850593          	addi	a1,a0,88
    800036e6:	40dc                	lw	a5,4(s1)
    800036e8:	8bbd                	andi	a5,a5,15
    800036ea:	079a                	slli	a5,a5,0x6
    800036ec:	95be                	add	a1,a1,a5
    ip->type = dip->type;
    800036ee:	00059783          	lh	a5,0(a1)
    800036f2:	04f49223          	sh	a5,68(s1)
    ip->major = dip->major;
    800036f6:	00259783          	lh	a5,2(a1)
    800036fa:	04f49323          	sh	a5,70(s1)
    ip->minor = dip->minor;
    800036fe:	00459783          	lh	a5,4(a1)
    80003702:	04f49423          	sh	a5,72(s1)
    ip->nlink = dip->nlink;
    80003706:	00659783          	lh	a5,6(a1)
    8000370a:	04f49523          	sh	a5,74(s1)
    ip->size = dip->size;
    8000370e:	459c                	lw	a5,8(a1)
    80003710:	c4fc                	sw	a5,76(s1)
    memmove(ip->addrs, dip->addrs, sizeof(ip->addrs));
    80003712:	03400613          	li	a2,52
    80003716:	05b1                	addi	a1,a1,12
    80003718:	05048513          	addi	a0,s1,80
    8000371c:	ffffd097          	auipc	ra,0xffffd
    80003720:	60e080e7          	jalr	1550(ra) # 80000d2a <memmove>
    brelse(bp);
    80003724:	854a                	mv	a0,s2
    80003726:	00000097          	auipc	ra,0x0
    8000372a:	880080e7          	jalr	-1920(ra) # 80002fa6 <brelse>
    ip->valid = 1;
    8000372e:	4785                	li	a5,1
    80003730:	c0bc                	sw	a5,64(s1)
    if(ip->type == 0)
    80003732:	04449783          	lh	a5,68(s1)
    80003736:	fbb5                	bnez	a5,800036aa <ilock+0x24>
      panic("ilock: no type");
    80003738:	00005517          	auipc	a0,0x5
    8000373c:	ea850513          	addi	a0,a0,-344 # 800085e0 <syscalls+0x190>
    80003740:	ffffd097          	auipc	ra,0xffffd
    80003744:	dfc080e7          	jalr	-516(ra) # 8000053c <panic>

0000000080003748 <iunlock>:
{
    80003748:	1101                	addi	sp,sp,-32
    8000374a:	ec06                	sd	ra,24(sp)
    8000374c:	e822                	sd	s0,16(sp)
    8000374e:	e426                	sd	s1,8(sp)
    80003750:	e04a                	sd	s2,0(sp)
    80003752:	1000                	addi	s0,sp,32
  if(ip == 0 || !holdingsleep(&ip->lock) || ip->ref < 1)
    80003754:	c905                	beqz	a0,80003784 <iunlock+0x3c>
    80003756:	84aa                	mv	s1,a0
    80003758:	01050913          	addi	s2,a0,16
    8000375c:	854a                	mv	a0,s2
    8000375e:	00001097          	auipc	ra,0x1
    80003762:	c58080e7          	jalr	-936(ra) # 800043b6 <holdingsleep>
    80003766:	cd19                	beqz	a0,80003784 <iunlock+0x3c>
    80003768:	449c                	lw	a5,8(s1)
    8000376a:	00f05d63          	blez	a5,80003784 <iunlock+0x3c>
  releasesleep(&ip->lock);
    8000376e:	854a                	mv	a0,s2
    80003770:	00001097          	auipc	ra,0x1
    80003774:	c02080e7          	jalr	-1022(ra) # 80004372 <releasesleep>
}
    80003778:	60e2                	ld	ra,24(sp)
    8000377a:	6442                	ld	s0,16(sp)
    8000377c:	64a2                	ld	s1,8(sp)
    8000377e:	6902                	ld	s2,0(sp)
    80003780:	6105                	addi	sp,sp,32
    80003782:	8082                	ret
    panic("iunlock");
    80003784:	00005517          	auipc	a0,0x5
    80003788:	e6c50513          	addi	a0,a0,-404 # 800085f0 <syscalls+0x1a0>
    8000378c:	ffffd097          	auipc	ra,0xffffd
    80003790:	db0080e7          	jalr	-592(ra) # 8000053c <panic>

0000000080003794 <itrunc>:

// Truncate inode (discard contents).
// Caller must hold ip->lock.
void
itrunc(struct inode *ip)
{
    80003794:	7179                	addi	sp,sp,-48
    80003796:	f406                	sd	ra,40(sp)
    80003798:	f022                	sd	s0,32(sp)
    8000379a:	ec26                	sd	s1,24(sp)
    8000379c:	e84a                	sd	s2,16(sp)
    8000379e:	e44e                	sd	s3,8(sp)
    800037a0:	e052                	sd	s4,0(sp)
    800037a2:	1800                	addi	s0,sp,48
    800037a4:	89aa                	mv	s3,a0
  int i, j;
  struct buf *bp;
  uint *a;

  for(i = 0; i < NDIRECT; i++){
    800037a6:	05050493          	addi	s1,a0,80
    800037aa:	08050913          	addi	s2,a0,128
    800037ae:	a021                	j	800037b6 <itrunc+0x22>
    800037b0:	0491                	addi	s1,s1,4
    800037b2:	01248d63          	beq	s1,s2,800037cc <itrunc+0x38>
    if(ip->addrs[i]){
    800037b6:	408c                	lw	a1,0(s1)
    800037b8:	dde5                	beqz	a1,800037b0 <itrunc+0x1c>
      bfree(ip->dev, ip->addrs[i]);
    800037ba:	0009a503          	lw	a0,0(s3)
    800037be:	00000097          	auipc	ra,0x0
    800037c2:	8fc080e7          	jalr	-1796(ra) # 800030ba <bfree>
      ip->addrs[i] = 0;
    800037c6:	0004a023          	sw	zero,0(s1)
    800037ca:	b7dd                	j	800037b0 <itrunc+0x1c>
    }
  }

  if(ip->addrs[NDIRECT]){
    800037cc:	0809a583          	lw	a1,128(s3)
    800037d0:	e185                	bnez	a1,800037f0 <itrunc+0x5c>
    brelse(bp);
    bfree(ip->dev, ip->addrs[NDIRECT]);
    ip->addrs[NDIRECT] = 0;
  }

  ip->size = 0;
    800037d2:	0409a623          	sw	zero,76(s3)
  iupdate(ip);
    800037d6:	854e                	mv	a0,s3
    800037d8:	00000097          	auipc	ra,0x0
    800037dc:	de2080e7          	jalr	-542(ra) # 800035ba <iupdate>
}
    800037e0:	70a2                	ld	ra,40(sp)
    800037e2:	7402                	ld	s0,32(sp)
    800037e4:	64e2                	ld	s1,24(sp)
    800037e6:	6942                	ld	s2,16(sp)
    800037e8:	69a2                	ld	s3,8(sp)
    800037ea:	6a02                	ld	s4,0(sp)
    800037ec:	6145                	addi	sp,sp,48
    800037ee:	8082                	ret
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
    800037f0:	0009a503          	lw	a0,0(s3)
    800037f4:	fffff097          	auipc	ra,0xfffff
    800037f8:	682080e7          	jalr	1666(ra) # 80002e76 <bread>
    800037fc:	8a2a                	mv	s4,a0
    for(j = 0; j < NINDIRECT; j++){
    800037fe:	05850493          	addi	s1,a0,88
    80003802:	45850913          	addi	s2,a0,1112
    80003806:	a021                	j	8000380e <itrunc+0x7a>
    80003808:	0491                	addi	s1,s1,4
    8000380a:	01248b63          	beq	s1,s2,80003820 <itrunc+0x8c>
      if(a[j])
    8000380e:	408c                	lw	a1,0(s1)
    80003810:	dde5                	beqz	a1,80003808 <itrunc+0x74>
        bfree(ip->dev, a[j]);
    80003812:	0009a503          	lw	a0,0(s3)
    80003816:	00000097          	auipc	ra,0x0
    8000381a:	8a4080e7          	jalr	-1884(ra) # 800030ba <bfree>
    8000381e:	b7ed                	j	80003808 <itrunc+0x74>
    brelse(bp);
    80003820:	8552                	mv	a0,s4
    80003822:	fffff097          	auipc	ra,0xfffff
    80003826:	784080e7          	jalr	1924(ra) # 80002fa6 <brelse>
    bfree(ip->dev, ip->addrs[NDIRECT]);
    8000382a:	0809a583          	lw	a1,128(s3)
    8000382e:	0009a503          	lw	a0,0(s3)
    80003832:	00000097          	auipc	ra,0x0
    80003836:	888080e7          	jalr	-1912(ra) # 800030ba <bfree>
    ip->addrs[NDIRECT] = 0;
    8000383a:	0809a023          	sw	zero,128(s3)
    8000383e:	bf51                	j	800037d2 <itrunc+0x3e>

0000000080003840 <iput>:
{
    80003840:	1101                	addi	sp,sp,-32
    80003842:	ec06                	sd	ra,24(sp)
    80003844:	e822                	sd	s0,16(sp)
    80003846:	e426                	sd	s1,8(sp)
    80003848:	e04a                	sd	s2,0(sp)
    8000384a:	1000                	addi	s0,sp,32
    8000384c:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    8000384e:	0001c517          	auipc	a0,0x1c
    80003852:	81a50513          	addi	a0,a0,-2022 # 8001f068 <itable>
    80003856:	ffffd097          	auipc	ra,0xffffd
    8000385a:	37c080e7          	jalr	892(ra) # 80000bd2 <acquire>
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    8000385e:	4498                	lw	a4,8(s1)
    80003860:	4785                	li	a5,1
    80003862:	02f70363          	beq	a4,a5,80003888 <iput+0x48>
  ip->ref--;
    80003866:	449c                	lw	a5,8(s1)
    80003868:	37fd                	addiw	a5,a5,-1
    8000386a:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    8000386c:	0001b517          	auipc	a0,0x1b
    80003870:	7fc50513          	addi	a0,a0,2044 # 8001f068 <itable>
    80003874:	ffffd097          	auipc	ra,0xffffd
    80003878:	412080e7          	jalr	1042(ra) # 80000c86 <release>
}
    8000387c:	60e2                	ld	ra,24(sp)
    8000387e:	6442                	ld	s0,16(sp)
    80003880:	64a2                	ld	s1,8(sp)
    80003882:	6902                	ld	s2,0(sp)
    80003884:	6105                	addi	sp,sp,32
    80003886:	8082                	ret
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    80003888:	40bc                	lw	a5,64(s1)
    8000388a:	dff1                	beqz	a5,80003866 <iput+0x26>
    8000388c:	04a49783          	lh	a5,74(s1)
    80003890:	fbf9                	bnez	a5,80003866 <iput+0x26>
    acquiresleep(&ip->lock);
    80003892:	01048913          	addi	s2,s1,16
    80003896:	854a                	mv	a0,s2
    80003898:	00001097          	auipc	ra,0x1
    8000389c:	a84080e7          	jalr	-1404(ra) # 8000431c <acquiresleep>
    release(&itable.lock);
    800038a0:	0001b517          	auipc	a0,0x1b
    800038a4:	7c850513          	addi	a0,a0,1992 # 8001f068 <itable>
    800038a8:	ffffd097          	auipc	ra,0xffffd
    800038ac:	3de080e7          	jalr	990(ra) # 80000c86 <release>
    itrunc(ip);
    800038b0:	8526                	mv	a0,s1
    800038b2:	00000097          	auipc	ra,0x0
    800038b6:	ee2080e7          	jalr	-286(ra) # 80003794 <itrunc>
    ip->type = 0;
    800038ba:	04049223          	sh	zero,68(s1)
    iupdate(ip);
    800038be:	8526                	mv	a0,s1
    800038c0:	00000097          	auipc	ra,0x0
    800038c4:	cfa080e7          	jalr	-774(ra) # 800035ba <iupdate>
    ip->valid = 0;
    800038c8:	0404a023          	sw	zero,64(s1)
    releasesleep(&ip->lock);
    800038cc:	854a                	mv	a0,s2
    800038ce:	00001097          	auipc	ra,0x1
    800038d2:	aa4080e7          	jalr	-1372(ra) # 80004372 <releasesleep>
    acquire(&itable.lock);
    800038d6:	0001b517          	auipc	a0,0x1b
    800038da:	79250513          	addi	a0,a0,1938 # 8001f068 <itable>
    800038de:	ffffd097          	auipc	ra,0xffffd
    800038e2:	2f4080e7          	jalr	756(ra) # 80000bd2 <acquire>
    800038e6:	b741                	j	80003866 <iput+0x26>

00000000800038e8 <iunlockput>:
{
    800038e8:	1101                	addi	sp,sp,-32
    800038ea:	ec06                	sd	ra,24(sp)
    800038ec:	e822                	sd	s0,16(sp)
    800038ee:	e426                	sd	s1,8(sp)
    800038f0:	1000                	addi	s0,sp,32
    800038f2:	84aa                	mv	s1,a0
  iunlock(ip);
    800038f4:	00000097          	auipc	ra,0x0
    800038f8:	e54080e7          	jalr	-428(ra) # 80003748 <iunlock>
  iput(ip);
    800038fc:	8526                	mv	a0,s1
    800038fe:	00000097          	auipc	ra,0x0
    80003902:	f42080e7          	jalr	-190(ra) # 80003840 <iput>
}
    80003906:	60e2                	ld	ra,24(sp)
    80003908:	6442                	ld	s0,16(sp)
    8000390a:	64a2                	ld	s1,8(sp)
    8000390c:	6105                	addi	sp,sp,32
    8000390e:	8082                	ret

0000000080003910 <stati>:

// Copy stat information from inode.
// Caller must hold ip->lock.
void
stati(struct inode *ip, struct stat *st)
{
    80003910:	1141                	addi	sp,sp,-16
    80003912:	e422                	sd	s0,8(sp)
    80003914:	0800                	addi	s0,sp,16
  st->dev = ip->dev;
    80003916:	411c                	lw	a5,0(a0)
    80003918:	c19c                	sw	a5,0(a1)
  st->ino = ip->inum;
    8000391a:	415c                	lw	a5,4(a0)
    8000391c:	c1dc                	sw	a5,4(a1)
  st->type = ip->type;
    8000391e:	04451783          	lh	a5,68(a0)
    80003922:	00f59423          	sh	a5,8(a1)
  st->nlink = ip->nlink;
    80003926:	04a51783          	lh	a5,74(a0)
    8000392a:	00f59523          	sh	a5,10(a1)
  st->size = ip->size;
    8000392e:	04c56783          	lwu	a5,76(a0)
    80003932:	e99c                	sd	a5,16(a1)
}
    80003934:	6422                	ld	s0,8(sp)
    80003936:	0141                	addi	sp,sp,16
    80003938:	8082                	ret

000000008000393a <readi>:
readi(struct inode *ip, int user_dst, uint64 dst, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    8000393a:	457c                	lw	a5,76(a0)
    8000393c:	0ed7e963          	bltu	a5,a3,80003a2e <readi+0xf4>
{
    80003940:	7159                	addi	sp,sp,-112
    80003942:	f486                	sd	ra,104(sp)
    80003944:	f0a2                	sd	s0,96(sp)
    80003946:	eca6                	sd	s1,88(sp)
    80003948:	e8ca                	sd	s2,80(sp)
    8000394a:	e4ce                	sd	s3,72(sp)
    8000394c:	e0d2                	sd	s4,64(sp)
    8000394e:	fc56                	sd	s5,56(sp)
    80003950:	f85a                	sd	s6,48(sp)
    80003952:	f45e                	sd	s7,40(sp)
    80003954:	f062                	sd	s8,32(sp)
    80003956:	ec66                	sd	s9,24(sp)
    80003958:	e86a                	sd	s10,16(sp)
    8000395a:	e46e                	sd	s11,8(sp)
    8000395c:	1880                	addi	s0,sp,112
    8000395e:	8b2a                	mv	s6,a0
    80003960:	8bae                	mv	s7,a1
    80003962:	8a32                	mv	s4,a2
    80003964:	84b6                	mv	s1,a3
    80003966:	8aba                	mv	s5,a4
  if(off > ip->size || off + n < off)
    80003968:	9f35                	addw	a4,a4,a3
    return 0;
    8000396a:	4501                	li	a0,0
  if(off > ip->size || off + n < off)
    8000396c:	0ad76063          	bltu	a4,a3,80003a0c <readi+0xd2>
  if(off + n > ip->size)
    80003970:	00e7f463          	bgeu	a5,a4,80003978 <readi+0x3e>
    n = ip->size - off;
    80003974:	40d78abb          	subw	s5,a5,a3

  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80003978:	0a0a8963          	beqz	s5,80003a2a <readi+0xf0>
    8000397c:	4981                	li	s3,0
    uint addr = bmap(ip, off/BSIZE);
    if(addr == 0)
      break;
    bp = bread(ip->dev, addr);
    m = min(n - tot, BSIZE - off%BSIZE);
    8000397e:	40000c93          	li	s9,1024
    if(either_copyout(user_dst, dst, bp->data + (off % BSIZE), m) == -1) {
    80003982:	5c7d                	li	s8,-1
    80003984:	a82d                	j	800039be <readi+0x84>
    80003986:	020d1d93          	slli	s11,s10,0x20
    8000398a:	020ddd93          	srli	s11,s11,0x20
    8000398e:	05890613          	addi	a2,s2,88
    80003992:	86ee                	mv	a3,s11
    80003994:	963a                	add	a2,a2,a4
    80003996:	85d2                	mv	a1,s4
    80003998:	855e                	mv	a0,s7
    8000399a:	fffff097          	auipc	ra,0xfffff
    8000399e:	b08080e7          	jalr	-1272(ra) # 800024a2 <either_copyout>
    800039a2:	05850d63          	beq	a0,s8,800039fc <readi+0xc2>
      brelse(bp);
      tot = -1;
      break;
    }
    brelse(bp);
    800039a6:	854a                	mv	a0,s2
    800039a8:	fffff097          	auipc	ra,0xfffff
    800039ac:	5fe080e7          	jalr	1534(ra) # 80002fa6 <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    800039b0:	013d09bb          	addw	s3,s10,s3
    800039b4:	009d04bb          	addw	s1,s10,s1
    800039b8:	9a6e                	add	s4,s4,s11
    800039ba:	0559f763          	bgeu	s3,s5,80003a08 <readi+0xce>
    uint addr = bmap(ip, off/BSIZE);
    800039be:	00a4d59b          	srliw	a1,s1,0xa
    800039c2:	855a                	mv	a0,s6
    800039c4:	00000097          	auipc	ra,0x0
    800039c8:	8a4080e7          	jalr	-1884(ra) # 80003268 <bmap>
    800039cc:	0005059b          	sext.w	a1,a0
    if(addr == 0)
    800039d0:	cd85                	beqz	a1,80003a08 <readi+0xce>
    bp = bread(ip->dev, addr);
    800039d2:	000b2503          	lw	a0,0(s6)
    800039d6:	fffff097          	auipc	ra,0xfffff
    800039da:	4a0080e7          	jalr	1184(ra) # 80002e76 <bread>
    800039de:	892a                	mv	s2,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    800039e0:	3ff4f713          	andi	a4,s1,1023
    800039e4:	40ec87bb          	subw	a5,s9,a4
    800039e8:	413a86bb          	subw	a3,s5,s3
    800039ec:	8d3e                	mv	s10,a5
    800039ee:	2781                	sext.w	a5,a5
    800039f0:	0006861b          	sext.w	a2,a3
    800039f4:	f8f679e3          	bgeu	a2,a5,80003986 <readi+0x4c>
    800039f8:	8d36                	mv	s10,a3
    800039fa:	b771                	j	80003986 <readi+0x4c>
      brelse(bp);
    800039fc:	854a                	mv	a0,s2
    800039fe:	fffff097          	auipc	ra,0xfffff
    80003a02:	5a8080e7          	jalr	1448(ra) # 80002fa6 <brelse>
      tot = -1;
    80003a06:	59fd                	li	s3,-1
  }
  return tot;
    80003a08:	0009851b          	sext.w	a0,s3
}
    80003a0c:	70a6                	ld	ra,104(sp)
    80003a0e:	7406                	ld	s0,96(sp)
    80003a10:	64e6                	ld	s1,88(sp)
    80003a12:	6946                	ld	s2,80(sp)
    80003a14:	69a6                	ld	s3,72(sp)
    80003a16:	6a06                	ld	s4,64(sp)
    80003a18:	7ae2                	ld	s5,56(sp)
    80003a1a:	7b42                	ld	s6,48(sp)
    80003a1c:	7ba2                	ld	s7,40(sp)
    80003a1e:	7c02                	ld	s8,32(sp)
    80003a20:	6ce2                	ld	s9,24(sp)
    80003a22:	6d42                	ld	s10,16(sp)
    80003a24:	6da2                	ld	s11,8(sp)
    80003a26:	6165                	addi	sp,sp,112
    80003a28:	8082                	ret
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80003a2a:	89d6                	mv	s3,s5
    80003a2c:	bff1                	j	80003a08 <readi+0xce>
    return 0;
    80003a2e:	4501                	li	a0,0
}
    80003a30:	8082                	ret

0000000080003a32 <writei>:
writei(struct inode *ip, int user_src, uint64 src, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    80003a32:	457c                	lw	a5,76(a0)
    80003a34:	10d7e863          	bltu	a5,a3,80003b44 <writei+0x112>
{
    80003a38:	7159                	addi	sp,sp,-112
    80003a3a:	f486                	sd	ra,104(sp)
    80003a3c:	f0a2                	sd	s0,96(sp)
    80003a3e:	eca6                	sd	s1,88(sp)
    80003a40:	e8ca                	sd	s2,80(sp)
    80003a42:	e4ce                	sd	s3,72(sp)
    80003a44:	e0d2                	sd	s4,64(sp)
    80003a46:	fc56                	sd	s5,56(sp)
    80003a48:	f85a                	sd	s6,48(sp)
    80003a4a:	f45e                	sd	s7,40(sp)
    80003a4c:	f062                	sd	s8,32(sp)
    80003a4e:	ec66                	sd	s9,24(sp)
    80003a50:	e86a                	sd	s10,16(sp)
    80003a52:	e46e                	sd	s11,8(sp)
    80003a54:	1880                	addi	s0,sp,112
    80003a56:	8aaa                	mv	s5,a0
    80003a58:	8bae                	mv	s7,a1
    80003a5a:	8a32                	mv	s4,a2
    80003a5c:	8936                	mv	s2,a3
    80003a5e:	8b3a                	mv	s6,a4
  if(off > ip->size || off + n < off)
    80003a60:	00e687bb          	addw	a5,a3,a4
    80003a64:	0ed7e263          	bltu	a5,a3,80003b48 <writei+0x116>
    return -1;
  if(off + n > MAXFILE*BSIZE)
    80003a68:	00043737          	lui	a4,0x43
    80003a6c:	0ef76063          	bltu	a4,a5,80003b4c <writei+0x11a>
    return -1;

  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80003a70:	0c0b0863          	beqz	s6,80003b40 <writei+0x10e>
    80003a74:	4981                	li	s3,0
    uint addr = bmap(ip, off/BSIZE);
    if(addr == 0)
      break;
    bp = bread(ip->dev, addr);
    m = min(n - tot, BSIZE - off%BSIZE);
    80003a76:	40000c93          	li	s9,1024
    if(either_copyin(bp->data + (off % BSIZE), user_src, src, m) == -1) {
    80003a7a:	5c7d                	li	s8,-1
    80003a7c:	a091                	j	80003ac0 <writei+0x8e>
    80003a7e:	020d1d93          	slli	s11,s10,0x20
    80003a82:	020ddd93          	srli	s11,s11,0x20
    80003a86:	05848513          	addi	a0,s1,88
    80003a8a:	86ee                	mv	a3,s11
    80003a8c:	8652                	mv	a2,s4
    80003a8e:	85de                	mv	a1,s7
    80003a90:	953a                	add	a0,a0,a4
    80003a92:	fffff097          	auipc	ra,0xfffff
    80003a96:	a66080e7          	jalr	-1434(ra) # 800024f8 <either_copyin>
    80003a9a:	07850263          	beq	a0,s8,80003afe <writei+0xcc>
      brelse(bp);
      break;
    }
    log_write(bp);
    80003a9e:	8526                	mv	a0,s1
    80003aa0:	00000097          	auipc	ra,0x0
    80003aa4:	75e080e7          	jalr	1886(ra) # 800041fe <log_write>
    brelse(bp);
    80003aa8:	8526                	mv	a0,s1
    80003aaa:	fffff097          	auipc	ra,0xfffff
    80003aae:	4fc080e7          	jalr	1276(ra) # 80002fa6 <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80003ab2:	013d09bb          	addw	s3,s10,s3
    80003ab6:	012d093b          	addw	s2,s10,s2
    80003aba:	9a6e                	add	s4,s4,s11
    80003abc:	0569f663          	bgeu	s3,s6,80003b08 <writei+0xd6>
    uint addr = bmap(ip, off/BSIZE);
    80003ac0:	00a9559b          	srliw	a1,s2,0xa
    80003ac4:	8556                	mv	a0,s5
    80003ac6:	fffff097          	auipc	ra,0xfffff
    80003aca:	7a2080e7          	jalr	1954(ra) # 80003268 <bmap>
    80003ace:	0005059b          	sext.w	a1,a0
    if(addr == 0)
    80003ad2:	c99d                	beqz	a1,80003b08 <writei+0xd6>
    bp = bread(ip->dev, addr);
    80003ad4:	000aa503          	lw	a0,0(s5)
    80003ad8:	fffff097          	auipc	ra,0xfffff
    80003adc:	39e080e7          	jalr	926(ra) # 80002e76 <bread>
    80003ae0:	84aa                	mv	s1,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    80003ae2:	3ff97713          	andi	a4,s2,1023
    80003ae6:	40ec87bb          	subw	a5,s9,a4
    80003aea:	413b06bb          	subw	a3,s6,s3
    80003aee:	8d3e                	mv	s10,a5
    80003af0:	2781                	sext.w	a5,a5
    80003af2:	0006861b          	sext.w	a2,a3
    80003af6:	f8f674e3          	bgeu	a2,a5,80003a7e <writei+0x4c>
    80003afa:	8d36                	mv	s10,a3
    80003afc:	b749                	j	80003a7e <writei+0x4c>
      brelse(bp);
    80003afe:	8526                	mv	a0,s1
    80003b00:	fffff097          	auipc	ra,0xfffff
    80003b04:	4a6080e7          	jalr	1190(ra) # 80002fa6 <brelse>
  }

  if(off > ip->size)
    80003b08:	04caa783          	lw	a5,76(s5)
    80003b0c:	0127f463          	bgeu	a5,s2,80003b14 <writei+0xe2>
    ip->size = off;
    80003b10:	052aa623          	sw	s2,76(s5)

  // write the i-node back to disk even if the size didn't change
  // because the loop above might have called bmap() and added a new
  // block to ip->addrs[].
  iupdate(ip);
    80003b14:	8556                	mv	a0,s5
    80003b16:	00000097          	auipc	ra,0x0
    80003b1a:	aa4080e7          	jalr	-1372(ra) # 800035ba <iupdate>

  return tot;
    80003b1e:	0009851b          	sext.w	a0,s3
}
    80003b22:	70a6                	ld	ra,104(sp)
    80003b24:	7406                	ld	s0,96(sp)
    80003b26:	64e6                	ld	s1,88(sp)
    80003b28:	6946                	ld	s2,80(sp)
    80003b2a:	69a6                	ld	s3,72(sp)
    80003b2c:	6a06                	ld	s4,64(sp)
    80003b2e:	7ae2                	ld	s5,56(sp)
    80003b30:	7b42                	ld	s6,48(sp)
    80003b32:	7ba2                	ld	s7,40(sp)
    80003b34:	7c02                	ld	s8,32(sp)
    80003b36:	6ce2                	ld	s9,24(sp)
    80003b38:	6d42                	ld	s10,16(sp)
    80003b3a:	6da2                	ld	s11,8(sp)
    80003b3c:	6165                	addi	sp,sp,112
    80003b3e:	8082                	ret
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80003b40:	89da                	mv	s3,s6
    80003b42:	bfc9                	j	80003b14 <writei+0xe2>
    return -1;
    80003b44:	557d                	li	a0,-1
}
    80003b46:	8082                	ret
    return -1;
    80003b48:	557d                	li	a0,-1
    80003b4a:	bfe1                	j	80003b22 <writei+0xf0>
    return -1;
    80003b4c:	557d                	li	a0,-1
    80003b4e:	bfd1                	j	80003b22 <writei+0xf0>

0000000080003b50 <namecmp>:

// Directories

int
namecmp(const char *s, const char *t)
{
    80003b50:	1141                	addi	sp,sp,-16
    80003b52:	e406                	sd	ra,8(sp)
    80003b54:	e022                	sd	s0,0(sp)
    80003b56:	0800                	addi	s0,sp,16
  return strncmp(s, t, DIRSIZ);
    80003b58:	4639                	li	a2,14
    80003b5a:	ffffd097          	auipc	ra,0xffffd
    80003b5e:	244080e7          	jalr	580(ra) # 80000d9e <strncmp>
}
    80003b62:	60a2                	ld	ra,8(sp)
    80003b64:	6402                	ld	s0,0(sp)
    80003b66:	0141                	addi	sp,sp,16
    80003b68:	8082                	ret

0000000080003b6a <dirlookup>:

// Look for a directory entry in a directory.
// If found, set *poff to byte offset of entry.
struct inode*
dirlookup(struct inode *dp, char *name, uint *poff)
{
    80003b6a:	7139                	addi	sp,sp,-64
    80003b6c:	fc06                	sd	ra,56(sp)
    80003b6e:	f822                	sd	s0,48(sp)
    80003b70:	f426                	sd	s1,40(sp)
    80003b72:	f04a                	sd	s2,32(sp)
    80003b74:	ec4e                	sd	s3,24(sp)
    80003b76:	e852                	sd	s4,16(sp)
    80003b78:	0080                	addi	s0,sp,64
  uint off, inum;
  struct dirent de;

  if(dp->type != T_DIR)
    80003b7a:	04451703          	lh	a4,68(a0)
    80003b7e:	4785                	li	a5,1
    80003b80:	00f71a63          	bne	a4,a5,80003b94 <dirlookup+0x2a>
    80003b84:	892a                	mv	s2,a0
    80003b86:	89ae                	mv	s3,a1
    80003b88:	8a32                	mv	s4,a2
    panic("dirlookup not DIR");

  for(off = 0; off < dp->size; off += sizeof(de)){
    80003b8a:	457c                	lw	a5,76(a0)
    80003b8c:	4481                	li	s1,0
      inum = de.inum;
      return iget(dp->dev, inum);
    }
  }

  return 0;
    80003b8e:	4501                	li	a0,0
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003b90:	e79d                	bnez	a5,80003bbe <dirlookup+0x54>
    80003b92:	a8a5                	j	80003c0a <dirlookup+0xa0>
    panic("dirlookup not DIR");
    80003b94:	00005517          	auipc	a0,0x5
    80003b98:	a6450513          	addi	a0,a0,-1436 # 800085f8 <syscalls+0x1a8>
    80003b9c:	ffffd097          	auipc	ra,0xffffd
    80003ba0:	9a0080e7          	jalr	-1632(ra) # 8000053c <panic>
      panic("dirlookup read");
    80003ba4:	00005517          	auipc	a0,0x5
    80003ba8:	a6c50513          	addi	a0,a0,-1428 # 80008610 <syscalls+0x1c0>
    80003bac:	ffffd097          	auipc	ra,0xffffd
    80003bb0:	990080e7          	jalr	-1648(ra) # 8000053c <panic>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003bb4:	24c1                	addiw	s1,s1,16
    80003bb6:	04c92783          	lw	a5,76(s2)
    80003bba:	04f4f763          	bgeu	s1,a5,80003c08 <dirlookup+0x9e>
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80003bbe:	4741                	li	a4,16
    80003bc0:	86a6                	mv	a3,s1
    80003bc2:	fc040613          	addi	a2,s0,-64
    80003bc6:	4581                	li	a1,0
    80003bc8:	854a                	mv	a0,s2
    80003bca:	00000097          	auipc	ra,0x0
    80003bce:	d70080e7          	jalr	-656(ra) # 8000393a <readi>
    80003bd2:	47c1                	li	a5,16
    80003bd4:	fcf518e3          	bne	a0,a5,80003ba4 <dirlookup+0x3a>
    if(de.inum == 0)
    80003bd8:	fc045783          	lhu	a5,-64(s0)
    80003bdc:	dfe1                	beqz	a5,80003bb4 <dirlookup+0x4a>
    if(namecmp(name, de.name) == 0){
    80003bde:	fc240593          	addi	a1,s0,-62
    80003be2:	854e                	mv	a0,s3
    80003be4:	00000097          	auipc	ra,0x0
    80003be8:	f6c080e7          	jalr	-148(ra) # 80003b50 <namecmp>
    80003bec:	f561                	bnez	a0,80003bb4 <dirlookup+0x4a>
      if(poff)
    80003bee:	000a0463          	beqz	s4,80003bf6 <dirlookup+0x8c>
        *poff = off;
    80003bf2:	009a2023          	sw	s1,0(s4)
      return iget(dp->dev, inum);
    80003bf6:	fc045583          	lhu	a1,-64(s0)
    80003bfa:	00092503          	lw	a0,0(s2)
    80003bfe:	fffff097          	auipc	ra,0xfffff
    80003c02:	754080e7          	jalr	1876(ra) # 80003352 <iget>
    80003c06:	a011                	j	80003c0a <dirlookup+0xa0>
  return 0;
    80003c08:	4501                	li	a0,0
}
    80003c0a:	70e2                	ld	ra,56(sp)
    80003c0c:	7442                	ld	s0,48(sp)
    80003c0e:	74a2                	ld	s1,40(sp)
    80003c10:	7902                	ld	s2,32(sp)
    80003c12:	69e2                	ld	s3,24(sp)
    80003c14:	6a42                	ld	s4,16(sp)
    80003c16:	6121                	addi	sp,sp,64
    80003c18:	8082                	ret

0000000080003c1a <namex>:
// If parent != 0, return the inode for the parent and copy the final
// path element into name, which must have room for DIRSIZ bytes.
// Must be called inside a transaction since it calls iput().
static struct inode*
namex(char *path, int nameiparent, char *name)
{
    80003c1a:	711d                	addi	sp,sp,-96
    80003c1c:	ec86                	sd	ra,88(sp)
    80003c1e:	e8a2                	sd	s0,80(sp)
    80003c20:	e4a6                	sd	s1,72(sp)
    80003c22:	e0ca                	sd	s2,64(sp)
    80003c24:	fc4e                	sd	s3,56(sp)
    80003c26:	f852                	sd	s4,48(sp)
    80003c28:	f456                	sd	s5,40(sp)
    80003c2a:	f05a                	sd	s6,32(sp)
    80003c2c:	ec5e                	sd	s7,24(sp)
    80003c2e:	e862                	sd	s8,16(sp)
    80003c30:	e466                	sd	s9,8(sp)
    80003c32:	1080                	addi	s0,sp,96
    80003c34:	84aa                	mv	s1,a0
    80003c36:	8b2e                	mv	s6,a1
    80003c38:	8ab2                	mv	s5,a2
  struct inode *ip, *next;

  if(*path == '/')
    80003c3a:	00054703          	lbu	a4,0(a0)
    80003c3e:	02f00793          	li	a5,47
    80003c42:	02f70263          	beq	a4,a5,80003c66 <namex+0x4c>
    ip = iget(ROOTDEV, ROOTINO);
  else
    ip = idup(myproc()->cwd);
    80003c46:	ffffe097          	auipc	ra,0xffffe
    80003c4a:	d60080e7          	jalr	-672(ra) # 800019a6 <myproc>
    80003c4e:	15053503          	ld	a0,336(a0)
    80003c52:	00000097          	auipc	ra,0x0
    80003c56:	9f6080e7          	jalr	-1546(ra) # 80003648 <idup>
    80003c5a:	8a2a                	mv	s4,a0
  while(*path == '/')
    80003c5c:	02f00913          	li	s2,47
  if(len >= DIRSIZ)
    80003c60:	4c35                	li	s8,13

  while((path = skipelem(path, name)) != 0){
    ilock(ip);
    if(ip->type != T_DIR){
    80003c62:	4b85                	li	s7,1
    80003c64:	a875                	j	80003d20 <namex+0x106>
    ip = iget(ROOTDEV, ROOTINO);
    80003c66:	4585                	li	a1,1
    80003c68:	4505                	li	a0,1
    80003c6a:	fffff097          	auipc	ra,0xfffff
    80003c6e:	6e8080e7          	jalr	1768(ra) # 80003352 <iget>
    80003c72:	8a2a                	mv	s4,a0
    80003c74:	b7e5                	j	80003c5c <namex+0x42>
      iunlockput(ip);
    80003c76:	8552                	mv	a0,s4
    80003c78:	00000097          	auipc	ra,0x0
    80003c7c:	c70080e7          	jalr	-912(ra) # 800038e8 <iunlockput>
      return 0;
    80003c80:	4a01                	li	s4,0
  if(nameiparent){
    iput(ip);
    return 0;
  }
  return ip;
}
    80003c82:	8552                	mv	a0,s4
    80003c84:	60e6                	ld	ra,88(sp)
    80003c86:	6446                	ld	s0,80(sp)
    80003c88:	64a6                	ld	s1,72(sp)
    80003c8a:	6906                	ld	s2,64(sp)
    80003c8c:	79e2                	ld	s3,56(sp)
    80003c8e:	7a42                	ld	s4,48(sp)
    80003c90:	7aa2                	ld	s5,40(sp)
    80003c92:	7b02                	ld	s6,32(sp)
    80003c94:	6be2                	ld	s7,24(sp)
    80003c96:	6c42                	ld	s8,16(sp)
    80003c98:	6ca2                	ld	s9,8(sp)
    80003c9a:	6125                	addi	sp,sp,96
    80003c9c:	8082                	ret
      iunlock(ip);
    80003c9e:	8552                	mv	a0,s4
    80003ca0:	00000097          	auipc	ra,0x0
    80003ca4:	aa8080e7          	jalr	-1368(ra) # 80003748 <iunlock>
      return ip;
    80003ca8:	bfe9                	j	80003c82 <namex+0x68>
      iunlockput(ip);
    80003caa:	8552                	mv	a0,s4
    80003cac:	00000097          	auipc	ra,0x0
    80003cb0:	c3c080e7          	jalr	-964(ra) # 800038e8 <iunlockput>
      return 0;
    80003cb4:	8a4e                	mv	s4,s3
    80003cb6:	b7f1                	j	80003c82 <namex+0x68>
  len = path - s;
    80003cb8:	40998633          	sub	a2,s3,s1
    80003cbc:	00060c9b          	sext.w	s9,a2
  if(len >= DIRSIZ)
    80003cc0:	099c5863          	bge	s8,s9,80003d50 <namex+0x136>
    memmove(name, s, DIRSIZ);
    80003cc4:	4639                	li	a2,14
    80003cc6:	85a6                	mv	a1,s1
    80003cc8:	8556                	mv	a0,s5
    80003cca:	ffffd097          	auipc	ra,0xffffd
    80003cce:	060080e7          	jalr	96(ra) # 80000d2a <memmove>
    80003cd2:	84ce                	mv	s1,s3
  while(*path == '/')
    80003cd4:	0004c783          	lbu	a5,0(s1)
    80003cd8:	01279763          	bne	a5,s2,80003ce6 <namex+0xcc>
    path++;
    80003cdc:	0485                	addi	s1,s1,1
  while(*path == '/')
    80003cde:	0004c783          	lbu	a5,0(s1)
    80003ce2:	ff278de3          	beq	a5,s2,80003cdc <namex+0xc2>
    ilock(ip);
    80003ce6:	8552                	mv	a0,s4
    80003ce8:	00000097          	auipc	ra,0x0
    80003cec:	99e080e7          	jalr	-1634(ra) # 80003686 <ilock>
    if(ip->type != T_DIR){
    80003cf0:	044a1783          	lh	a5,68(s4)
    80003cf4:	f97791e3          	bne	a5,s7,80003c76 <namex+0x5c>
    if(nameiparent && *path == '\0'){
    80003cf8:	000b0563          	beqz	s6,80003d02 <namex+0xe8>
    80003cfc:	0004c783          	lbu	a5,0(s1)
    80003d00:	dfd9                	beqz	a5,80003c9e <namex+0x84>
    if((next = dirlookup(ip, name, 0)) == 0){
    80003d02:	4601                	li	a2,0
    80003d04:	85d6                	mv	a1,s5
    80003d06:	8552                	mv	a0,s4
    80003d08:	00000097          	auipc	ra,0x0
    80003d0c:	e62080e7          	jalr	-414(ra) # 80003b6a <dirlookup>
    80003d10:	89aa                	mv	s3,a0
    80003d12:	dd41                	beqz	a0,80003caa <namex+0x90>
    iunlockput(ip);
    80003d14:	8552                	mv	a0,s4
    80003d16:	00000097          	auipc	ra,0x0
    80003d1a:	bd2080e7          	jalr	-1070(ra) # 800038e8 <iunlockput>
    ip = next;
    80003d1e:	8a4e                	mv	s4,s3
  while(*path == '/')
    80003d20:	0004c783          	lbu	a5,0(s1)
    80003d24:	01279763          	bne	a5,s2,80003d32 <namex+0x118>
    path++;
    80003d28:	0485                	addi	s1,s1,1
  while(*path == '/')
    80003d2a:	0004c783          	lbu	a5,0(s1)
    80003d2e:	ff278de3          	beq	a5,s2,80003d28 <namex+0x10e>
  if(*path == 0)
    80003d32:	cb9d                	beqz	a5,80003d68 <namex+0x14e>
  while(*path != '/' && *path != 0)
    80003d34:	0004c783          	lbu	a5,0(s1)
    80003d38:	89a6                	mv	s3,s1
  len = path - s;
    80003d3a:	4c81                	li	s9,0
    80003d3c:	4601                	li	a2,0
  while(*path != '/' && *path != 0)
    80003d3e:	01278963          	beq	a5,s2,80003d50 <namex+0x136>
    80003d42:	dbbd                	beqz	a5,80003cb8 <namex+0x9e>
    path++;
    80003d44:	0985                	addi	s3,s3,1
  while(*path != '/' && *path != 0)
    80003d46:	0009c783          	lbu	a5,0(s3)
    80003d4a:	ff279ce3          	bne	a5,s2,80003d42 <namex+0x128>
    80003d4e:	b7ad                	j	80003cb8 <namex+0x9e>
    memmove(name, s, len);
    80003d50:	2601                	sext.w	a2,a2
    80003d52:	85a6                	mv	a1,s1
    80003d54:	8556                	mv	a0,s5
    80003d56:	ffffd097          	auipc	ra,0xffffd
    80003d5a:	fd4080e7          	jalr	-44(ra) # 80000d2a <memmove>
    name[len] = 0;
    80003d5e:	9cd6                	add	s9,s9,s5
    80003d60:	000c8023          	sb	zero,0(s9) # 2000 <_entry-0x7fffe000>
    80003d64:	84ce                	mv	s1,s3
    80003d66:	b7bd                	j	80003cd4 <namex+0xba>
  if(nameiparent){
    80003d68:	f00b0de3          	beqz	s6,80003c82 <namex+0x68>
    iput(ip);
    80003d6c:	8552                	mv	a0,s4
    80003d6e:	00000097          	auipc	ra,0x0
    80003d72:	ad2080e7          	jalr	-1326(ra) # 80003840 <iput>
    return 0;
    80003d76:	4a01                	li	s4,0
    80003d78:	b729                	j	80003c82 <namex+0x68>

0000000080003d7a <dirlink>:
{
    80003d7a:	7139                	addi	sp,sp,-64
    80003d7c:	fc06                	sd	ra,56(sp)
    80003d7e:	f822                	sd	s0,48(sp)
    80003d80:	f426                	sd	s1,40(sp)
    80003d82:	f04a                	sd	s2,32(sp)
    80003d84:	ec4e                	sd	s3,24(sp)
    80003d86:	e852                	sd	s4,16(sp)
    80003d88:	0080                	addi	s0,sp,64
    80003d8a:	892a                	mv	s2,a0
    80003d8c:	8a2e                	mv	s4,a1
    80003d8e:	89b2                	mv	s3,a2
  if((ip = dirlookup(dp, name, 0)) != 0){
    80003d90:	4601                	li	a2,0
    80003d92:	00000097          	auipc	ra,0x0
    80003d96:	dd8080e7          	jalr	-552(ra) # 80003b6a <dirlookup>
    80003d9a:	e93d                	bnez	a0,80003e10 <dirlink+0x96>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003d9c:	04c92483          	lw	s1,76(s2)
    80003da0:	c49d                	beqz	s1,80003dce <dirlink+0x54>
    80003da2:	4481                	li	s1,0
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80003da4:	4741                	li	a4,16
    80003da6:	86a6                	mv	a3,s1
    80003da8:	fc040613          	addi	a2,s0,-64
    80003dac:	4581                	li	a1,0
    80003dae:	854a                	mv	a0,s2
    80003db0:	00000097          	auipc	ra,0x0
    80003db4:	b8a080e7          	jalr	-1142(ra) # 8000393a <readi>
    80003db8:	47c1                	li	a5,16
    80003dba:	06f51163          	bne	a0,a5,80003e1c <dirlink+0xa2>
    if(de.inum == 0)
    80003dbe:	fc045783          	lhu	a5,-64(s0)
    80003dc2:	c791                	beqz	a5,80003dce <dirlink+0x54>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003dc4:	24c1                	addiw	s1,s1,16
    80003dc6:	04c92783          	lw	a5,76(s2)
    80003dca:	fcf4ede3          	bltu	s1,a5,80003da4 <dirlink+0x2a>
  strncpy(de.name, name, DIRSIZ);
    80003dce:	4639                	li	a2,14
    80003dd0:	85d2                	mv	a1,s4
    80003dd2:	fc240513          	addi	a0,s0,-62
    80003dd6:	ffffd097          	auipc	ra,0xffffd
    80003dda:	004080e7          	jalr	4(ra) # 80000dda <strncpy>
  de.inum = inum;
    80003dde:	fd341023          	sh	s3,-64(s0)
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80003de2:	4741                	li	a4,16
    80003de4:	86a6                	mv	a3,s1
    80003de6:	fc040613          	addi	a2,s0,-64
    80003dea:	4581                	li	a1,0
    80003dec:	854a                	mv	a0,s2
    80003dee:	00000097          	auipc	ra,0x0
    80003df2:	c44080e7          	jalr	-956(ra) # 80003a32 <writei>
    80003df6:	1541                	addi	a0,a0,-16
    80003df8:	00a03533          	snez	a0,a0
    80003dfc:	40a00533          	neg	a0,a0
}
    80003e00:	70e2                	ld	ra,56(sp)
    80003e02:	7442                	ld	s0,48(sp)
    80003e04:	74a2                	ld	s1,40(sp)
    80003e06:	7902                	ld	s2,32(sp)
    80003e08:	69e2                	ld	s3,24(sp)
    80003e0a:	6a42                	ld	s4,16(sp)
    80003e0c:	6121                	addi	sp,sp,64
    80003e0e:	8082                	ret
    iput(ip);
    80003e10:	00000097          	auipc	ra,0x0
    80003e14:	a30080e7          	jalr	-1488(ra) # 80003840 <iput>
    return -1;
    80003e18:	557d                	li	a0,-1
    80003e1a:	b7dd                	j	80003e00 <dirlink+0x86>
      panic("dirlink read");
    80003e1c:	00005517          	auipc	a0,0x5
    80003e20:	80450513          	addi	a0,a0,-2044 # 80008620 <syscalls+0x1d0>
    80003e24:	ffffc097          	auipc	ra,0xffffc
    80003e28:	718080e7          	jalr	1816(ra) # 8000053c <panic>

0000000080003e2c <namei>:

struct inode*
namei(char *path)
{
    80003e2c:	1101                	addi	sp,sp,-32
    80003e2e:	ec06                	sd	ra,24(sp)
    80003e30:	e822                	sd	s0,16(sp)
    80003e32:	1000                	addi	s0,sp,32
  char name[DIRSIZ];
  return namex(path, 0, name);
    80003e34:	fe040613          	addi	a2,s0,-32
    80003e38:	4581                	li	a1,0
    80003e3a:	00000097          	auipc	ra,0x0
    80003e3e:	de0080e7          	jalr	-544(ra) # 80003c1a <namex>
}
    80003e42:	60e2                	ld	ra,24(sp)
    80003e44:	6442                	ld	s0,16(sp)
    80003e46:	6105                	addi	sp,sp,32
    80003e48:	8082                	ret

0000000080003e4a <nameiparent>:

struct inode*
nameiparent(char *path, char *name)
{
    80003e4a:	1141                	addi	sp,sp,-16
    80003e4c:	e406                	sd	ra,8(sp)
    80003e4e:	e022                	sd	s0,0(sp)
    80003e50:	0800                	addi	s0,sp,16
    80003e52:	862e                	mv	a2,a1
  return namex(path, 1, name);
    80003e54:	4585                	li	a1,1
    80003e56:	00000097          	auipc	ra,0x0
    80003e5a:	dc4080e7          	jalr	-572(ra) # 80003c1a <namex>
}
    80003e5e:	60a2                	ld	ra,8(sp)
    80003e60:	6402                	ld	s0,0(sp)
    80003e62:	0141                	addi	sp,sp,16
    80003e64:	8082                	ret

0000000080003e66 <write_head>:
// Write in-memory log header to disk.
// This is the true point at which the
// current transaction commits.
static void
write_head(void)
{
    80003e66:	1101                	addi	sp,sp,-32
    80003e68:	ec06                	sd	ra,24(sp)
    80003e6a:	e822                	sd	s0,16(sp)
    80003e6c:	e426                	sd	s1,8(sp)
    80003e6e:	e04a                	sd	s2,0(sp)
    80003e70:	1000                	addi	s0,sp,32
  struct buf *buf = bread(log.dev, log.start);
    80003e72:	0001d917          	auipc	s2,0x1d
    80003e76:	c9e90913          	addi	s2,s2,-866 # 80020b10 <log>
    80003e7a:	01892583          	lw	a1,24(s2)
    80003e7e:	02892503          	lw	a0,40(s2)
    80003e82:	fffff097          	auipc	ra,0xfffff
    80003e86:	ff4080e7          	jalr	-12(ra) # 80002e76 <bread>
    80003e8a:	84aa                	mv	s1,a0
  struct logheader *hb = (struct logheader *) (buf->data);
  int i;
  hb->n = log.lh.n;
    80003e8c:	02c92603          	lw	a2,44(s2)
    80003e90:	cd30                	sw	a2,88(a0)
  for (i = 0; i < log.lh.n; i++) {
    80003e92:	00c05f63          	blez	a2,80003eb0 <write_head+0x4a>
    80003e96:	0001d717          	auipc	a4,0x1d
    80003e9a:	caa70713          	addi	a4,a4,-854 # 80020b40 <log+0x30>
    80003e9e:	87aa                	mv	a5,a0
    80003ea0:	060a                	slli	a2,a2,0x2
    80003ea2:	962a                	add	a2,a2,a0
    hb->block[i] = log.lh.block[i];
    80003ea4:	4314                	lw	a3,0(a4)
    80003ea6:	cff4                	sw	a3,92(a5)
  for (i = 0; i < log.lh.n; i++) {
    80003ea8:	0711                	addi	a4,a4,4
    80003eaa:	0791                	addi	a5,a5,4
    80003eac:	fec79ce3          	bne	a5,a2,80003ea4 <write_head+0x3e>
  }
  bwrite(buf);
    80003eb0:	8526                	mv	a0,s1
    80003eb2:	fffff097          	auipc	ra,0xfffff
    80003eb6:	0b6080e7          	jalr	182(ra) # 80002f68 <bwrite>
  brelse(buf);
    80003eba:	8526                	mv	a0,s1
    80003ebc:	fffff097          	auipc	ra,0xfffff
    80003ec0:	0ea080e7          	jalr	234(ra) # 80002fa6 <brelse>
}
    80003ec4:	60e2                	ld	ra,24(sp)
    80003ec6:	6442                	ld	s0,16(sp)
    80003ec8:	64a2                	ld	s1,8(sp)
    80003eca:	6902                	ld	s2,0(sp)
    80003ecc:	6105                	addi	sp,sp,32
    80003ece:	8082                	ret

0000000080003ed0 <install_trans>:
  for (tail = 0; tail < log.lh.n; tail++) {
    80003ed0:	0001d797          	auipc	a5,0x1d
    80003ed4:	c6c7a783          	lw	a5,-916(a5) # 80020b3c <log+0x2c>
    80003ed8:	0af05d63          	blez	a5,80003f92 <install_trans+0xc2>
{
    80003edc:	7139                	addi	sp,sp,-64
    80003ede:	fc06                	sd	ra,56(sp)
    80003ee0:	f822                	sd	s0,48(sp)
    80003ee2:	f426                	sd	s1,40(sp)
    80003ee4:	f04a                	sd	s2,32(sp)
    80003ee6:	ec4e                	sd	s3,24(sp)
    80003ee8:	e852                	sd	s4,16(sp)
    80003eea:	e456                	sd	s5,8(sp)
    80003eec:	e05a                	sd	s6,0(sp)
    80003eee:	0080                	addi	s0,sp,64
    80003ef0:	8b2a                	mv	s6,a0
    80003ef2:	0001da97          	auipc	s5,0x1d
    80003ef6:	c4ea8a93          	addi	s5,s5,-946 # 80020b40 <log+0x30>
  for (tail = 0; tail < log.lh.n; tail++) {
    80003efa:	4a01                	li	s4,0
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    80003efc:	0001d997          	auipc	s3,0x1d
    80003f00:	c1498993          	addi	s3,s3,-1004 # 80020b10 <log>
    80003f04:	a00d                	j	80003f26 <install_trans+0x56>
    brelse(lbuf);
    80003f06:	854a                	mv	a0,s2
    80003f08:	fffff097          	auipc	ra,0xfffff
    80003f0c:	09e080e7          	jalr	158(ra) # 80002fa6 <brelse>
    brelse(dbuf);
    80003f10:	8526                	mv	a0,s1
    80003f12:	fffff097          	auipc	ra,0xfffff
    80003f16:	094080e7          	jalr	148(ra) # 80002fa6 <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    80003f1a:	2a05                	addiw	s4,s4,1
    80003f1c:	0a91                	addi	s5,s5,4
    80003f1e:	02c9a783          	lw	a5,44(s3)
    80003f22:	04fa5e63          	bge	s4,a5,80003f7e <install_trans+0xae>
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    80003f26:	0189a583          	lw	a1,24(s3)
    80003f2a:	014585bb          	addw	a1,a1,s4
    80003f2e:	2585                	addiw	a1,a1,1
    80003f30:	0289a503          	lw	a0,40(s3)
    80003f34:	fffff097          	auipc	ra,0xfffff
    80003f38:	f42080e7          	jalr	-190(ra) # 80002e76 <bread>
    80003f3c:	892a                	mv	s2,a0
    struct buf *dbuf = bread(log.dev, log.lh.block[tail]); // read dst
    80003f3e:	000aa583          	lw	a1,0(s5)
    80003f42:	0289a503          	lw	a0,40(s3)
    80003f46:	fffff097          	auipc	ra,0xfffff
    80003f4a:	f30080e7          	jalr	-208(ra) # 80002e76 <bread>
    80003f4e:	84aa                	mv	s1,a0
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
    80003f50:	40000613          	li	a2,1024
    80003f54:	05890593          	addi	a1,s2,88
    80003f58:	05850513          	addi	a0,a0,88
    80003f5c:	ffffd097          	auipc	ra,0xffffd
    80003f60:	dce080e7          	jalr	-562(ra) # 80000d2a <memmove>
    bwrite(dbuf);  // write dst to disk
    80003f64:	8526                	mv	a0,s1
    80003f66:	fffff097          	auipc	ra,0xfffff
    80003f6a:	002080e7          	jalr	2(ra) # 80002f68 <bwrite>
    if(recovering == 0)
    80003f6e:	f80b1ce3          	bnez	s6,80003f06 <install_trans+0x36>
      bunpin(dbuf);
    80003f72:	8526                	mv	a0,s1
    80003f74:	fffff097          	auipc	ra,0xfffff
    80003f78:	10a080e7          	jalr	266(ra) # 8000307e <bunpin>
    80003f7c:	b769                	j	80003f06 <install_trans+0x36>
}
    80003f7e:	70e2                	ld	ra,56(sp)
    80003f80:	7442                	ld	s0,48(sp)
    80003f82:	74a2                	ld	s1,40(sp)
    80003f84:	7902                	ld	s2,32(sp)
    80003f86:	69e2                	ld	s3,24(sp)
    80003f88:	6a42                	ld	s4,16(sp)
    80003f8a:	6aa2                	ld	s5,8(sp)
    80003f8c:	6b02                	ld	s6,0(sp)
    80003f8e:	6121                	addi	sp,sp,64
    80003f90:	8082                	ret
    80003f92:	8082                	ret

0000000080003f94 <initlog>:
{
    80003f94:	7179                	addi	sp,sp,-48
    80003f96:	f406                	sd	ra,40(sp)
    80003f98:	f022                	sd	s0,32(sp)
    80003f9a:	ec26                	sd	s1,24(sp)
    80003f9c:	e84a                	sd	s2,16(sp)
    80003f9e:	e44e                	sd	s3,8(sp)
    80003fa0:	1800                	addi	s0,sp,48
    80003fa2:	892a                	mv	s2,a0
    80003fa4:	89ae                	mv	s3,a1
  initlock(&log.lock, "log");
    80003fa6:	0001d497          	auipc	s1,0x1d
    80003faa:	b6a48493          	addi	s1,s1,-1174 # 80020b10 <log>
    80003fae:	00004597          	auipc	a1,0x4
    80003fb2:	68258593          	addi	a1,a1,1666 # 80008630 <syscalls+0x1e0>
    80003fb6:	8526                	mv	a0,s1
    80003fb8:	ffffd097          	auipc	ra,0xffffd
    80003fbc:	b8a080e7          	jalr	-1142(ra) # 80000b42 <initlock>
  log.start = sb->logstart;
    80003fc0:	0149a583          	lw	a1,20(s3)
    80003fc4:	cc8c                	sw	a1,24(s1)
  log.size = sb->nlog;
    80003fc6:	0109a783          	lw	a5,16(s3)
    80003fca:	ccdc                	sw	a5,28(s1)
  log.dev = dev;
    80003fcc:	0324a423          	sw	s2,40(s1)
  struct buf *buf = bread(log.dev, log.start);
    80003fd0:	854a                	mv	a0,s2
    80003fd2:	fffff097          	auipc	ra,0xfffff
    80003fd6:	ea4080e7          	jalr	-348(ra) # 80002e76 <bread>
  log.lh.n = lh->n;
    80003fda:	4d30                	lw	a2,88(a0)
    80003fdc:	d4d0                	sw	a2,44(s1)
  for (i = 0; i < log.lh.n; i++) {
    80003fde:	00c05f63          	blez	a2,80003ffc <initlog+0x68>
    80003fe2:	87aa                	mv	a5,a0
    80003fe4:	0001d717          	auipc	a4,0x1d
    80003fe8:	b5c70713          	addi	a4,a4,-1188 # 80020b40 <log+0x30>
    80003fec:	060a                	slli	a2,a2,0x2
    80003fee:	962a                	add	a2,a2,a0
    log.lh.block[i] = lh->block[i];
    80003ff0:	4ff4                	lw	a3,92(a5)
    80003ff2:	c314                	sw	a3,0(a4)
  for (i = 0; i < log.lh.n; i++) {
    80003ff4:	0791                	addi	a5,a5,4
    80003ff6:	0711                	addi	a4,a4,4
    80003ff8:	fec79ce3          	bne	a5,a2,80003ff0 <initlog+0x5c>
  brelse(buf);
    80003ffc:	fffff097          	auipc	ra,0xfffff
    80004000:	faa080e7          	jalr	-86(ra) # 80002fa6 <brelse>

static void
recover_from_log(void)
{
  read_head();
  install_trans(1); // if committed, copy from log to disk
    80004004:	4505                	li	a0,1
    80004006:	00000097          	auipc	ra,0x0
    8000400a:	eca080e7          	jalr	-310(ra) # 80003ed0 <install_trans>
  log.lh.n = 0;
    8000400e:	0001d797          	auipc	a5,0x1d
    80004012:	b207a723          	sw	zero,-1234(a5) # 80020b3c <log+0x2c>
  write_head(); // clear the log
    80004016:	00000097          	auipc	ra,0x0
    8000401a:	e50080e7          	jalr	-432(ra) # 80003e66 <write_head>
}
    8000401e:	70a2                	ld	ra,40(sp)
    80004020:	7402                	ld	s0,32(sp)
    80004022:	64e2                	ld	s1,24(sp)
    80004024:	6942                	ld	s2,16(sp)
    80004026:	69a2                	ld	s3,8(sp)
    80004028:	6145                	addi	sp,sp,48
    8000402a:	8082                	ret

000000008000402c <begin_op>:
}

// called at the start of each FS system call.
void
begin_op(void)
{
    8000402c:	1101                	addi	sp,sp,-32
    8000402e:	ec06                	sd	ra,24(sp)
    80004030:	e822                	sd	s0,16(sp)
    80004032:	e426                	sd	s1,8(sp)
    80004034:	e04a                	sd	s2,0(sp)
    80004036:	1000                	addi	s0,sp,32
  acquire(&log.lock);
    80004038:	0001d517          	auipc	a0,0x1d
    8000403c:	ad850513          	addi	a0,a0,-1320 # 80020b10 <log>
    80004040:	ffffd097          	auipc	ra,0xffffd
    80004044:	b92080e7          	jalr	-1134(ra) # 80000bd2 <acquire>
  while(1){
    if(log.committing){
    80004048:	0001d497          	auipc	s1,0x1d
    8000404c:	ac848493          	addi	s1,s1,-1336 # 80020b10 <log>
      sleep(&log, &log.lock);
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
    80004050:	4979                	li	s2,30
    80004052:	a039                	j	80004060 <begin_op+0x34>
      sleep(&log, &log.lock);
    80004054:	85a6                	mv	a1,s1
    80004056:	8526                	mv	a0,s1
    80004058:	ffffe097          	auipc	ra,0xffffe
    8000405c:	042080e7          	jalr	66(ra) # 8000209a <sleep>
    if(log.committing){
    80004060:	50dc                	lw	a5,36(s1)
    80004062:	fbed                	bnez	a5,80004054 <begin_op+0x28>
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
    80004064:	5098                	lw	a4,32(s1)
    80004066:	2705                	addiw	a4,a4,1
    80004068:	0027179b          	slliw	a5,a4,0x2
    8000406c:	9fb9                	addw	a5,a5,a4
    8000406e:	0017979b          	slliw	a5,a5,0x1
    80004072:	54d4                	lw	a3,44(s1)
    80004074:	9fb5                	addw	a5,a5,a3
    80004076:	00f95963          	bge	s2,a5,80004088 <begin_op+0x5c>
      // this op might exhaust log space; wait for commit.
      sleep(&log, &log.lock);
    8000407a:	85a6                	mv	a1,s1
    8000407c:	8526                	mv	a0,s1
    8000407e:	ffffe097          	auipc	ra,0xffffe
    80004082:	01c080e7          	jalr	28(ra) # 8000209a <sleep>
    80004086:	bfe9                	j	80004060 <begin_op+0x34>
    } else {
      log.outstanding += 1;
    80004088:	0001d517          	auipc	a0,0x1d
    8000408c:	a8850513          	addi	a0,a0,-1400 # 80020b10 <log>
    80004090:	d118                	sw	a4,32(a0)
      release(&log.lock);
    80004092:	ffffd097          	auipc	ra,0xffffd
    80004096:	bf4080e7          	jalr	-1036(ra) # 80000c86 <release>
      break;
    }
  }
}
    8000409a:	60e2                	ld	ra,24(sp)
    8000409c:	6442                	ld	s0,16(sp)
    8000409e:	64a2                	ld	s1,8(sp)
    800040a0:	6902                	ld	s2,0(sp)
    800040a2:	6105                	addi	sp,sp,32
    800040a4:	8082                	ret

00000000800040a6 <end_op>:

// called at the end of each FS system call.
// commits if this was the last outstanding operation.
void
end_op(void)
{
    800040a6:	7139                	addi	sp,sp,-64
    800040a8:	fc06                	sd	ra,56(sp)
    800040aa:	f822                	sd	s0,48(sp)
    800040ac:	f426                	sd	s1,40(sp)
    800040ae:	f04a                	sd	s2,32(sp)
    800040b0:	ec4e                	sd	s3,24(sp)
    800040b2:	e852                	sd	s4,16(sp)
    800040b4:	e456                	sd	s5,8(sp)
    800040b6:	0080                	addi	s0,sp,64
  int do_commit = 0;

  acquire(&log.lock);
    800040b8:	0001d497          	auipc	s1,0x1d
    800040bc:	a5848493          	addi	s1,s1,-1448 # 80020b10 <log>
    800040c0:	8526                	mv	a0,s1
    800040c2:	ffffd097          	auipc	ra,0xffffd
    800040c6:	b10080e7          	jalr	-1264(ra) # 80000bd2 <acquire>
  log.outstanding -= 1;
    800040ca:	509c                	lw	a5,32(s1)
    800040cc:	37fd                	addiw	a5,a5,-1
    800040ce:	0007891b          	sext.w	s2,a5
    800040d2:	d09c                	sw	a5,32(s1)
  if(log.committing)
    800040d4:	50dc                	lw	a5,36(s1)
    800040d6:	e7b9                	bnez	a5,80004124 <end_op+0x7e>
    panic("log.committing");
  if(log.outstanding == 0){
    800040d8:	04091e63          	bnez	s2,80004134 <end_op+0x8e>
    do_commit = 1;
    log.committing = 1;
    800040dc:	0001d497          	auipc	s1,0x1d
    800040e0:	a3448493          	addi	s1,s1,-1484 # 80020b10 <log>
    800040e4:	4785                	li	a5,1
    800040e6:	d0dc                	sw	a5,36(s1)
    // begin_op() may be waiting for log space,
    // and decrementing log.outstanding has decreased
    // the amount of reserved space.
    wakeup(&log);
  }
  release(&log.lock);
    800040e8:	8526                	mv	a0,s1
    800040ea:	ffffd097          	auipc	ra,0xffffd
    800040ee:	b9c080e7          	jalr	-1124(ra) # 80000c86 <release>
}

static void
commit()
{
  if (log.lh.n > 0) {
    800040f2:	54dc                	lw	a5,44(s1)
    800040f4:	06f04763          	bgtz	a5,80004162 <end_op+0xbc>
    acquire(&log.lock);
    800040f8:	0001d497          	auipc	s1,0x1d
    800040fc:	a1848493          	addi	s1,s1,-1512 # 80020b10 <log>
    80004100:	8526                	mv	a0,s1
    80004102:	ffffd097          	auipc	ra,0xffffd
    80004106:	ad0080e7          	jalr	-1328(ra) # 80000bd2 <acquire>
    log.committing = 0;
    8000410a:	0204a223          	sw	zero,36(s1)
    wakeup(&log);
    8000410e:	8526                	mv	a0,s1
    80004110:	ffffe097          	auipc	ra,0xffffe
    80004114:	fee080e7          	jalr	-18(ra) # 800020fe <wakeup>
    release(&log.lock);
    80004118:	8526                	mv	a0,s1
    8000411a:	ffffd097          	auipc	ra,0xffffd
    8000411e:	b6c080e7          	jalr	-1172(ra) # 80000c86 <release>
}
    80004122:	a03d                	j	80004150 <end_op+0xaa>
    panic("log.committing");
    80004124:	00004517          	auipc	a0,0x4
    80004128:	51450513          	addi	a0,a0,1300 # 80008638 <syscalls+0x1e8>
    8000412c:	ffffc097          	auipc	ra,0xffffc
    80004130:	410080e7          	jalr	1040(ra) # 8000053c <panic>
    wakeup(&log);
    80004134:	0001d497          	auipc	s1,0x1d
    80004138:	9dc48493          	addi	s1,s1,-1572 # 80020b10 <log>
    8000413c:	8526                	mv	a0,s1
    8000413e:	ffffe097          	auipc	ra,0xffffe
    80004142:	fc0080e7          	jalr	-64(ra) # 800020fe <wakeup>
  release(&log.lock);
    80004146:	8526                	mv	a0,s1
    80004148:	ffffd097          	auipc	ra,0xffffd
    8000414c:	b3e080e7          	jalr	-1218(ra) # 80000c86 <release>
}
    80004150:	70e2                	ld	ra,56(sp)
    80004152:	7442                	ld	s0,48(sp)
    80004154:	74a2                	ld	s1,40(sp)
    80004156:	7902                	ld	s2,32(sp)
    80004158:	69e2                	ld	s3,24(sp)
    8000415a:	6a42                	ld	s4,16(sp)
    8000415c:	6aa2                	ld	s5,8(sp)
    8000415e:	6121                	addi	sp,sp,64
    80004160:	8082                	ret
  for (tail = 0; tail < log.lh.n; tail++) {
    80004162:	0001da97          	auipc	s5,0x1d
    80004166:	9dea8a93          	addi	s5,s5,-1570 # 80020b40 <log+0x30>
    struct buf *to = bread(log.dev, log.start+tail+1); // log block
    8000416a:	0001da17          	auipc	s4,0x1d
    8000416e:	9a6a0a13          	addi	s4,s4,-1626 # 80020b10 <log>
    80004172:	018a2583          	lw	a1,24(s4)
    80004176:	012585bb          	addw	a1,a1,s2
    8000417a:	2585                	addiw	a1,a1,1
    8000417c:	028a2503          	lw	a0,40(s4)
    80004180:	fffff097          	auipc	ra,0xfffff
    80004184:	cf6080e7          	jalr	-778(ra) # 80002e76 <bread>
    80004188:	84aa                	mv	s1,a0
    struct buf *from = bread(log.dev, log.lh.block[tail]); // cache block
    8000418a:	000aa583          	lw	a1,0(s5)
    8000418e:	028a2503          	lw	a0,40(s4)
    80004192:	fffff097          	auipc	ra,0xfffff
    80004196:	ce4080e7          	jalr	-796(ra) # 80002e76 <bread>
    8000419a:	89aa                	mv	s3,a0
    memmove(to->data, from->data, BSIZE);
    8000419c:	40000613          	li	a2,1024
    800041a0:	05850593          	addi	a1,a0,88
    800041a4:	05848513          	addi	a0,s1,88
    800041a8:	ffffd097          	auipc	ra,0xffffd
    800041ac:	b82080e7          	jalr	-1150(ra) # 80000d2a <memmove>
    bwrite(to);  // write the log
    800041b0:	8526                	mv	a0,s1
    800041b2:	fffff097          	auipc	ra,0xfffff
    800041b6:	db6080e7          	jalr	-586(ra) # 80002f68 <bwrite>
    brelse(from);
    800041ba:	854e                	mv	a0,s3
    800041bc:	fffff097          	auipc	ra,0xfffff
    800041c0:	dea080e7          	jalr	-534(ra) # 80002fa6 <brelse>
    brelse(to);
    800041c4:	8526                	mv	a0,s1
    800041c6:	fffff097          	auipc	ra,0xfffff
    800041ca:	de0080e7          	jalr	-544(ra) # 80002fa6 <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    800041ce:	2905                	addiw	s2,s2,1
    800041d0:	0a91                	addi	s5,s5,4
    800041d2:	02ca2783          	lw	a5,44(s4)
    800041d6:	f8f94ee3          	blt	s2,a5,80004172 <end_op+0xcc>
    write_log();     // Write modified blocks from cache to log
    write_head();    // Write header to disk -- the real commit
    800041da:	00000097          	auipc	ra,0x0
    800041de:	c8c080e7          	jalr	-884(ra) # 80003e66 <write_head>
    install_trans(0); // Now install writes to home locations
    800041e2:	4501                	li	a0,0
    800041e4:	00000097          	auipc	ra,0x0
    800041e8:	cec080e7          	jalr	-788(ra) # 80003ed0 <install_trans>
    log.lh.n = 0;
    800041ec:	0001d797          	auipc	a5,0x1d
    800041f0:	9407a823          	sw	zero,-1712(a5) # 80020b3c <log+0x2c>
    write_head();    // Erase the transaction from the log
    800041f4:	00000097          	auipc	ra,0x0
    800041f8:	c72080e7          	jalr	-910(ra) # 80003e66 <write_head>
    800041fc:	bdf5                	j	800040f8 <end_op+0x52>

00000000800041fe <log_write>:
//   modify bp->data[]
//   log_write(bp)
//   brelse(bp)
void
log_write(struct buf *b)
{
    800041fe:	1101                	addi	sp,sp,-32
    80004200:	ec06                	sd	ra,24(sp)
    80004202:	e822                	sd	s0,16(sp)
    80004204:	e426                	sd	s1,8(sp)
    80004206:	e04a                	sd	s2,0(sp)
    80004208:	1000                	addi	s0,sp,32
    8000420a:	84aa                	mv	s1,a0
  int i;

  acquire(&log.lock);
    8000420c:	0001d917          	auipc	s2,0x1d
    80004210:	90490913          	addi	s2,s2,-1788 # 80020b10 <log>
    80004214:	854a                	mv	a0,s2
    80004216:	ffffd097          	auipc	ra,0xffffd
    8000421a:	9bc080e7          	jalr	-1604(ra) # 80000bd2 <acquire>
  if (log.lh.n >= LOGSIZE || log.lh.n >= log.size - 1)
    8000421e:	02c92603          	lw	a2,44(s2)
    80004222:	47f5                	li	a5,29
    80004224:	06c7c563          	blt	a5,a2,8000428e <log_write+0x90>
    80004228:	0001d797          	auipc	a5,0x1d
    8000422c:	9047a783          	lw	a5,-1788(a5) # 80020b2c <log+0x1c>
    80004230:	37fd                	addiw	a5,a5,-1
    80004232:	04f65e63          	bge	a2,a5,8000428e <log_write+0x90>
    panic("too big a transaction");
  if (log.outstanding < 1)
    80004236:	0001d797          	auipc	a5,0x1d
    8000423a:	8fa7a783          	lw	a5,-1798(a5) # 80020b30 <log+0x20>
    8000423e:	06f05063          	blez	a5,8000429e <log_write+0xa0>
    panic("log_write outside of trans");

  for (i = 0; i < log.lh.n; i++) {
    80004242:	4781                	li	a5,0
    80004244:	06c05563          	blez	a2,800042ae <log_write+0xb0>
    if (log.lh.block[i] == b->blockno)   // log absorption
    80004248:	44cc                	lw	a1,12(s1)
    8000424a:	0001d717          	auipc	a4,0x1d
    8000424e:	8f670713          	addi	a4,a4,-1802 # 80020b40 <log+0x30>
  for (i = 0; i < log.lh.n; i++) {
    80004252:	4781                	li	a5,0
    if (log.lh.block[i] == b->blockno)   // log absorption
    80004254:	4314                	lw	a3,0(a4)
    80004256:	04b68c63          	beq	a3,a1,800042ae <log_write+0xb0>
  for (i = 0; i < log.lh.n; i++) {
    8000425a:	2785                	addiw	a5,a5,1
    8000425c:	0711                	addi	a4,a4,4
    8000425e:	fef61be3          	bne	a2,a5,80004254 <log_write+0x56>
      break;
  }
  log.lh.block[i] = b->blockno;
    80004262:	0621                	addi	a2,a2,8
    80004264:	060a                	slli	a2,a2,0x2
    80004266:	0001d797          	auipc	a5,0x1d
    8000426a:	8aa78793          	addi	a5,a5,-1878 # 80020b10 <log>
    8000426e:	97b2                	add	a5,a5,a2
    80004270:	44d8                	lw	a4,12(s1)
    80004272:	cb98                	sw	a4,16(a5)
  if (i == log.lh.n) {  // Add new block to log?
    bpin(b);
    80004274:	8526                	mv	a0,s1
    80004276:	fffff097          	auipc	ra,0xfffff
    8000427a:	dcc080e7          	jalr	-564(ra) # 80003042 <bpin>
    log.lh.n++;
    8000427e:	0001d717          	auipc	a4,0x1d
    80004282:	89270713          	addi	a4,a4,-1902 # 80020b10 <log>
    80004286:	575c                	lw	a5,44(a4)
    80004288:	2785                	addiw	a5,a5,1
    8000428a:	d75c                	sw	a5,44(a4)
    8000428c:	a82d                	j	800042c6 <log_write+0xc8>
    panic("too big a transaction");
    8000428e:	00004517          	auipc	a0,0x4
    80004292:	3ba50513          	addi	a0,a0,954 # 80008648 <syscalls+0x1f8>
    80004296:	ffffc097          	auipc	ra,0xffffc
    8000429a:	2a6080e7          	jalr	678(ra) # 8000053c <panic>
    panic("log_write outside of trans");
    8000429e:	00004517          	auipc	a0,0x4
    800042a2:	3c250513          	addi	a0,a0,962 # 80008660 <syscalls+0x210>
    800042a6:	ffffc097          	auipc	ra,0xffffc
    800042aa:	296080e7          	jalr	662(ra) # 8000053c <panic>
  log.lh.block[i] = b->blockno;
    800042ae:	00878693          	addi	a3,a5,8
    800042b2:	068a                	slli	a3,a3,0x2
    800042b4:	0001d717          	auipc	a4,0x1d
    800042b8:	85c70713          	addi	a4,a4,-1956 # 80020b10 <log>
    800042bc:	9736                	add	a4,a4,a3
    800042be:	44d4                	lw	a3,12(s1)
    800042c0:	cb14                	sw	a3,16(a4)
  if (i == log.lh.n) {  // Add new block to log?
    800042c2:	faf609e3          	beq	a2,a5,80004274 <log_write+0x76>
  }
  release(&log.lock);
    800042c6:	0001d517          	auipc	a0,0x1d
    800042ca:	84a50513          	addi	a0,a0,-1974 # 80020b10 <log>
    800042ce:	ffffd097          	auipc	ra,0xffffd
    800042d2:	9b8080e7          	jalr	-1608(ra) # 80000c86 <release>
}
    800042d6:	60e2                	ld	ra,24(sp)
    800042d8:	6442                	ld	s0,16(sp)
    800042da:	64a2                	ld	s1,8(sp)
    800042dc:	6902                	ld	s2,0(sp)
    800042de:	6105                	addi	sp,sp,32
    800042e0:	8082                	ret

00000000800042e2 <initsleeplock>:
#include "proc.h"
#include "sleeplock.h"

void
initsleeplock(struct sleeplock *lk, char *name)
{
    800042e2:	1101                	addi	sp,sp,-32
    800042e4:	ec06                	sd	ra,24(sp)
    800042e6:	e822                	sd	s0,16(sp)
    800042e8:	e426                	sd	s1,8(sp)
    800042ea:	e04a                	sd	s2,0(sp)
    800042ec:	1000                	addi	s0,sp,32
    800042ee:	84aa                	mv	s1,a0
    800042f0:	892e                	mv	s2,a1
  initlock(&lk->lk, "sleep lock");
    800042f2:	00004597          	auipc	a1,0x4
    800042f6:	38e58593          	addi	a1,a1,910 # 80008680 <syscalls+0x230>
    800042fa:	0521                	addi	a0,a0,8
    800042fc:	ffffd097          	auipc	ra,0xffffd
    80004300:	846080e7          	jalr	-1978(ra) # 80000b42 <initlock>
  lk->name = name;
    80004304:	0324b023          	sd	s2,32(s1)
  lk->locked = 0;
    80004308:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    8000430c:	0204a423          	sw	zero,40(s1)
}
    80004310:	60e2                	ld	ra,24(sp)
    80004312:	6442                	ld	s0,16(sp)
    80004314:	64a2                	ld	s1,8(sp)
    80004316:	6902                	ld	s2,0(sp)
    80004318:	6105                	addi	sp,sp,32
    8000431a:	8082                	ret

000000008000431c <acquiresleep>:

void
acquiresleep(struct sleeplock *lk)
{
    8000431c:	1101                	addi	sp,sp,-32
    8000431e:	ec06                	sd	ra,24(sp)
    80004320:	e822                	sd	s0,16(sp)
    80004322:	e426                	sd	s1,8(sp)
    80004324:	e04a                	sd	s2,0(sp)
    80004326:	1000                	addi	s0,sp,32
    80004328:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    8000432a:	00850913          	addi	s2,a0,8
    8000432e:	854a                	mv	a0,s2
    80004330:	ffffd097          	auipc	ra,0xffffd
    80004334:	8a2080e7          	jalr	-1886(ra) # 80000bd2 <acquire>
  while (lk->locked) {
    80004338:	409c                	lw	a5,0(s1)
    8000433a:	cb89                	beqz	a5,8000434c <acquiresleep+0x30>
    sleep(lk, &lk->lk);
    8000433c:	85ca                	mv	a1,s2
    8000433e:	8526                	mv	a0,s1
    80004340:	ffffe097          	auipc	ra,0xffffe
    80004344:	d5a080e7          	jalr	-678(ra) # 8000209a <sleep>
  while (lk->locked) {
    80004348:	409c                	lw	a5,0(s1)
    8000434a:	fbed                	bnez	a5,8000433c <acquiresleep+0x20>
  }
  lk->locked = 1;
    8000434c:	4785                	li	a5,1
    8000434e:	c09c                	sw	a5,0(s1)
  lk->pid = myproc()->pid;
    80004350:	ffffd097          	auipc	ra,0xffffd
    80004354:	656080e7          	jalr	1622(ra) # 800019a6 <myproc>
    80004358:	591c                	lw	a5,48(a0)
    8000435a:	d49c                	sw	a5,40(s1)
  release(&lk->lk);
    8000435c:	854a                	mv	a0,s2
    8000435e:	ffffd097          	auipc	ra,0xffffd
    80004362:	928080e7          	jalr	-1752(ra) # 80000c86 <release>
}
    80004366:	60e2                	ld	ra,24(sp)
    80004368:	6442                	ld	s0,16(sp)
    8000436a:	64a2                	ld	s1,8(sp)
    8000436c:	6902                	ld	s2,0(sp)
    8000436e:	6105                	addi	sp,sp,32
    80004370:	8082                	ret

0000000080004372 <releasesleep>:

void
releasesleep(struct sleeplock *lk)
{
    80004372:	1101                	addi	sp,sp,-32
    80004374:	ec06                	sd	ra,24(sp)
    80004376:	e822                	sd	s0,16(sp)
    80004378:	e426                	sd	s1,8(sp)
    8000437a:	e04a                	sd	s2,0(sp)
    8000437c:	1000                	addi	s0,sp,32
    8000437e:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    80004380:	00850913          	addi	s2,a0,8
    80004384:	854a                	mv	a0,s2
    80004386:	ffffd097          	auipc	ra,0xffffd
    8000438a:	84c080e7          	jalr	-1972(ra) # 80000bd2 <acquire>
  lk->locked = 0;
    8000438e:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    80004392:	0204a423          	sw	zero,40(s1)
  wakeup(lk);
    80004396:	8526                	mv	a0,s1
    80004398:	ffffe097          	auipc	ra,0xffffe
    8000439c:	d66080e7          	jalr	-666(ra) # 800020fe <wakeup>
  release(&lk->lk);
    800043a0:	854a                	mv	a0,s2
    800043a2:	ffffd097          	auipc	ra,0xffffd
    800043a6:	8e4080e7          	jalr	-1820(ra) # 80000c86 <release>
}
    800043aa:	60e2                	ld	ra,24(sp)
    800043ac:	6442                	ld	s0,16(sp)
    800043ae:	64a2                	ld	s1,8(sp)
    800043b0:	6902                	ld	s2,0(sp)
    800043b2:	6105                	addi	sp,sp,32
    800043b4:	8082                	ret

00000000800043b6 <holdingsleep>:

int
holdingsleep(struct sleeplock *lk)
{
    800043b6:	7179                	addi	sp,sp,-48
    800043b8:	f406                	sd	ra,40(sp)
    800043ba:	f022                	sd	s0,32(sp)
    800043bc:	ec26                	sd	s1,24(sp)
    800043be:	e84a                	sd	s2,16(sp)
    800043c0:	e44e                	sd	s3,8(sp)
    800043c2:	1800                	addi	s0,sp,48
    800043c4:	84aa                	mv	s1,a0
  int r;
  
  acquire(&lk->lk);
    800043c6:	00850913          	addi	s2,a0,8
    800043ca:	854a                	mv	a0,s2
    800043cc:	ffffd097          	auipc	ra,0xffffd
    800043d0:	806080e7          	jalr	-2042(ra) # 80000bd2 <acquire>
  r = lk->locked && (lk->pid == myproc()->pid);
    800043d4:	409c                	lw	a5,0(s1)
    800043d6:	ef99                	bnez	a5,800043f4 <holdingsleep+0x3e>
    800043d8:	4481                	li	s1,0
  release(&lk->lk);
    800043da:	854a                	mv	a0,s2
    800043dc:	ffffd097          	auipc	ra,0xffffd
    800043e0:	8aa080e7          	jalr	-1878(ra) # 80000c86 <release>
  return r;
}
    800043e4:	8526                	mv	a0,s1
    800043e6:	70a2                	ld	ra,40(sp)
    800043e8:	7402                	ld	s0,32(sp)
    800043ea:	64e2                	ld	s1,24(sp)
    800043ec:	6942                	ld	s2,16(sp)
    800043ee:	69a2                	ld	s3,8(sp)
    800043f0:	6145                	addi	sp,sp,48
    800043f2:	8082                	ret
  r = lk->locked && (lk->pid == myproc()->pid);
    800043f4:	0284a983          	lw	s3,40(s1)
    800043f8:	ffffd097          	auipc	ra,0xffffd
    800043fc:	5ae080e7          	jalr	1454(ra) # 800019a6 <myproc>
    80004400:	5904                	lw	s1,48(a0)
    80004402:	413484b3          	sub	s1,s1,s3
    80004406:	0014b493          	seqz	s1,s1
    8000440a:	bfc1                	j	800043da <holdingsleep+0x24>

000000008000440c <fileinit>:
  struct file file[NFILE];
} ftable;

void
fileinit(void)
{
    8000440c:	1141                	addi	sp,sp,-16
    8000440e:	e406                	sd	ra,8(sp)
    80004410:	e022                	sd	s0,0(sp)
    80004412:	0800                	addi	s0,sp,16
  initlock(&ftable.lock, "ftable");
    80004414:	00004597          	auipc	a1,0x4
    80004418:	27c58593          	addi	a1,a1,636 # 80008690 <syscalls+0x240>
    8000441c:	0001d517          	auipc	a0,0x1d
    80004420:	83c50513          	addi	a0,a0,-1988 # 80020c58 <ftable>
    80004424:	ffffc097          	auipc	ra,0xffffc
    80004428:	71e080e7          	jalr	1822(ra) # 80000b42 <initlock>
}
    8000442c:	60a2                	ld	ra,8(sp)
    8000442e:	6402                	ld	s0,0(sp)
    80004430:	0141                	addi	sp,sp,16
    80004432:	8082                	ret

0000000080004434 <filealloc>:

// Allocate a file structure.
struct file*
filealloc(void)
{
    80004434:	1101                	addi	sp,sp,-32
    80004436:	ec06                	sd	ra,24(sp)
    80004438:	e822                	sd	s0,16(sp)
    8000443a:	e426                	sd	s1,8(sp)
    8000443c:	1000                	addi	s0,sp,32
  struct file *f;

  acquire(&ftable.lock);
    8000443e:	0001d517          	auipc	a0,0x1d
    80004442:	81a50513          	addi	a0,a0,-2022 # 80020c58 <ftable>
    80004446:	ffffc097          	auipc	ra,0xffffc
    8000444a:	78c080e7          	jalr	1932(ra) # 80000bd2 <acquire>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    8000444e:	0001d497          	auipc	s1,0x1d
    80004452:	82248493          	addi	s1,s1,-2014 # 80020c70 <ftable+0x18>
    80004456:	0001d717          	auipc	a4,0x1d
    8000445a:	7ba70713          	addi	a4,a4,1978 # 80021c10 <disk>
    if(f->ref == 0){
    8000445e:	40dc                	lw	a5,4(s1)
    80004460:	cf99                	beqz	a5,8000447e <filealloc+0x4a>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    80004462:	02848493          	addi	s1,s1,40
    80004466:	fee49ce3          	bne	s1,a4,8000445e <filealloc+0x2a>
      f->ref = 1;
      release(&ftable.lock);
      return f;
    }
  }
  release(&ftable.lock);
    8000446a:	0001c517          	auipc	a0,0x1c
    8000446e:	7ee50513          	addi	a0,a0,2030 # 80020c58 <ftable>
    80004472:	ffffd097          	auipc	ra,0xffffd
    80004476:	814080e7          	jalr	-2028(ra) # 80000c86 <release>
  return 0;
    8000447a:	4481                	li	s1,0
    8000447c:	a819                	j	80004492 <filealloc+0x5e>
      f->ref = 1;
    8000447e:	4785                	li	a5,1
    80004480:	c0dc                	sw	a5,4(s1)
      release(&ftable.lock);
    80004482:	0001c517          	auipc	a0,0x1c
    80004486:	7d650513          	addi	a0,a0,2006 # 80020c58 <ftable>
    8000448a:	ffffc097          	auipc	ra,0xffffc
    8000448e:	7fc080e7          	jalr	2044(ra) # 80000c86 <release>
}
    80004492:	8526                	mv	a0,s1
    80004494:	60e2                	ld	ra,24(sp)
    80004496:	6442                	ld	s0,16(sp)
    80004498:	64a2                	ld	s1,8(sp)
    8000449a:	6105                	addi	sp,sp,32
    8000449c:	8082                	ret

000000008000449e <filedup>:

// Increment ref count for file f.
struct file*
filedup(struct file *f)
{
    8000449e:	1101                	addi	sp,sp,-32
    800044a0:	ec06                	sd	ra,24(sp)
    800044a2:	e822                	sd	s0,16(sp)
    800044a4:	e426                	sd	s1,8(sp)
    800044a6:	1000                	addi	s0,sp,32
    800044a8:	84aa                	mv	s1,a0
  acquire(&ftable.lock);
    800044aa:	0001c517          	auipc	a0,0x1c
    800044ae:	7ae50513          	addi	a0,a0,1966 # 80020c58 <ftable>
    800044b2:	ffffc097          	auipc	ra,0xffffc
    800044b6:	720080e7          	jalr	1824(ra) # 80000bd2 <acquire>
  if(f->ref < 1)
    800044ba:	40dc                	lw	a5,4(s1)
    800044bc:	02f05263          	blez	a5,800044e0 <filedup+0x42>
    panic("filedup");
  f->ref++;
    800044c0:	2785                	addiw	a5,a5,1
    800044c2:	c0dc                	sw	a5,4(s1)
  release(&ftable.lock);
    800044c4:	0001c517          	auipc	a0,0x1c
    800044c8:	79450513          	addi	a0,a0,1940 # 80020c58 <ftable>
    800044cc:	ffffc097          	auipc	ra,0xffffc
    800044d0:	7ba080e7          	jalr	1978(ra) # 80000c86 <release>
  return f;
}
    800044d4:	8526                	mv	a0,s1
    800044d6:	60e2                	ld	ra,24(sp)
    800044d8:	6442                	ld	s0,16(sp)
    800044da:	64a2                	ld	s1,8(sp)
    800044dc:	6105                	addi	sp,sp,32
    800044de:	8082                	ret
    panic("filedup");
    800044e0:	00004517          	auipc	a0,0x4
    800044e4:	1b850513          	addi	a0,a0,440 # 80008698 <syscalls+0x248>
    800044e8:	ffffc097          	auipc	ra,0xffffc
    800044ec:	054080e7          	jalr	84(ra) # 8000053c <panic>

00000000800044f0 <fileclose>:

// Close file f.  (Decrement ref count, close when reaches 0.)
void
fileclose(struct file *f)
{
    800044f0:	7139                	addi	sp,sp,-64
    800044f2:	fc06                	sd	ra,56(sp)
    800044f4:	f822                	sd	s0,48(sp)
    800044f6:	f426                	sd	s1,40(sp)
    800044f8:	f04a                	sd	s2,32(sp)
    800044fa:	ec4e                	sd	s3,24(sp)
    800044fc:	e852                	sd	s4,16(sp)
    800044fe:	e456                	sd	s5,8(sp)
    80004500:	0080                	addi	s0,sp,64
    80004502:	84aa                	mv	s1,a0
  struct file ff;

  acquire(&ftable.lock);
    80004504:	0001c517          	auipc	a0,0x1c
    80004508:	75450513          	addi	a0,a0,1876 # 80020c58 <ftable>
    8000450c:	ffffc097          	auipc	ra,0xffffc
    80004510:	6c6080e7          	jalr	1734(ra) # 80000bd2 <acquire>
  if(f->ref < 1)
    80004514:	40dc                	lw	a5,4(s1)
    80004516:	06f05163          	blez	a5,80004578 <fileclose+0x88>
    panic("fileclose");
  if(--f->ref > 0){
    8000451a:	37fd                	addiw	a5,a5,-1
    8000451c:	0007871b          	sext.w	a4,a5
    80004520:	c0dc                	sw	a5,4(s1)
    80004522:	06e04363          	bgtz	a4,80004588 <fileclose+0x98>
    release(&ftable.lock);
    return;
  }
  ff = *f;
    80004526:	0004a903          	lw	s2,0(s1)
    8000452a:	0094ca83          	lbu	s5,9(s1)
    8000452e:	0104ba03          	ld	s4,16(s1)
    80004532:	0184b983          	ld	s3,24(s1)
  f->ref = 0;
    80004536:	0004a223          	sw	zero,4(s1)
  f->type = FD_NONE;
    8000453a:	0004a023          	sw	zero,0(s1)
  release(&ftable.lock);
    8000453e:	0001c517          	auipc	a0,0x1c
    80004542:	71a50513          	addi	a0,a0,1818 # 80020c58 <ftable>
    80004546:	ffffc097          	auipc	ra,0xffffc
    8000454a:	740080e7          	jalr	1856(ra) # 80000c86 <release>

  if(ff.type == FD_PIPE){
    8000454e:	4785                	li	a5,1
    80004550:	04f90d63          	beq	s2,a5,800045aa <fileclose+0xba>
    pipeclose(ff.pipe, ff.writable);
  } else if(ff.type == FD_INODE || ff.type == FD_DEVICE){
    80004554:	3979                	addiw	s2,s2,-2
    80004556:	4785                	li	a5,1
    80004558:	0527e063          	bltu	a5,s2,80004598 <fileclose+0xa8>
    begin_op();
    8000455c:	00000097          	auipc	ra,0x0
    80004560:	ad0080e7          	jalr	-1328(ra) # 8000402c <begin_op>
    iput(ff.ip);
    80004564:	854e                	mv	a0,s3
    80004566:	fffff097          	auipc	ra,0xfffff
    8000456a:	2da080e7          	jalr	730(ra) # 80003840 <iput>
    end_op();
    8000456e:	00000097          	auipc	ra,0x0
    80004572:	b38080e7          	jalr	-1224(ra) # 800040a6 <end_op>
    80004576:	a00d                	j	80004598 <fileclose+0xa8>
    panic("fileclose");
    80004578:	00004517          	auipc	a0,0x4
    8000457c:	12850513          	addi	a0,a0,296 # 800086a0 <syscalls+0x250>
    80004580:	ffffc097          	auipc	ra,0xffffc
    80004584:	fbc080e7          	jalr	-68(ra) # 8000053c <panic>
    release(&ftable.lock);
    80004588:	0001c517          	auipc	a0,0x1c
    8000458c:	6d050513          	addi	a0,a0,1744 # 80020c58 <ftable>
    80004590:	ffffc097          	auipc	ra,0xffffc
    80004594:	6f6080e7          	jalr	1782(ra) # 80000c86 <release>
  }
}
    80004598:	70e2                	ld	ra,56(sp)
    8000459a:	7442                	ld	s0,48(sp)
    8000459c:	74a2                	ld	s1,40(sp)
    8000459e:	7902                	ld	s2,32(sp)
    800045a0:	69e2                	ld	s3,24(sp)
    800045a2:	6a42                	ld	s4,16(sp)
    800045a4:	6aa2                	ld	s5,8(sp)
    800045a6:	6121                	addi	sp,sp,64
    800045a8:	8082                	ret
    pipeclose(ff.pipe, ff.writable);
    800045aa:	85d6                	mv	a1,s5
    800045ac:	8552                	mv	a0,s4
    800045ae:	00000097          	auipc	ra,0x0
    800045b2:	348080e7          	jalr	840(ra) # 800048f6 <pipeclose>
    800045b6:	b7cd                	j	80004598 <fileclose+0xa8>

00000000800045b8 <filestat>:

// Get metadata about file f.
// addr is a user virtual address, pointing to a struct stat.
int
filestat(struct file *f, uint64 addr)
{
    800045b8:	715d                	addi	sp,sp,-80
    800045ba:	e486                	sd	ra,72(sp)
    800045bc:	e0a2                	sd	s0,64(sp)
    800045be:	fc26                	sd	s1,56(sp)
    800045c0:	f84a                	sd	s2,48(sp)
    800045c2:	f44e                	sd	s3,40(sp)
    800045c4:	0880                	addi	s0,sp,80
    800045c6:	84aa                	mv	s1,a0
    800045c8:	89ae                	mv	s3,a1
  struct proc *p = myproc();
    800045ca:	ffffd097          	auipc	ra,0xffffd
    800045ce:	3dc080e7          	jalr	988(ra) # 800019a6 <myproc>
  struct stat st;
  
  if(f->type == FD_INODE || f->type == FD_DEVICE){
    800045d2:	409c                	lw	a5,0(s1)
    800045d4:	37f9                	addiw	a5,a5,-2
    800045d6:	4705                	li	a4,1
    800045d8:	04f76763          	bltu	a4,a5,80004626 <filestat+0x6e>
    800045dc:	892a                	mv	s2,a0
    ilock(f->ip);
    800045de:	6c88                	ld	a0,24(s1)
    800045e0:	fffff097          	auipc	ra,0xfffff
    800045e4:	0a6080e7          	jalr	166(ra) # 80003686 <ilock>
    stati(f->ip, &st);
    800045e8:	fb840593          	addi	a1,s0,-72
    800045ec:	6c88                	ld	a0,24(s1)
    800045ee:	fffff097          	auipc	ra,0xfffff
    800045f2:	322080e7          	jalr	802(ra) # 80003910 <stati>
    iunlock(f->ip);
    800045f6:	6c88                	ld	a0,24(s1)
    800045f8:	fffff097          	auipc	ra,0xfffff
    800045fc:	150080e7          	jalr	336(ra) # 80003748 <iunlock>
    if(copyout(p->pagetable, addr, (char *)&st, sizeof(st)) < 0)
    80004600:	46e1                	li	a3,24
    80004602:	fb840613          	addi	a2,s0,-72
    80004606:	85ce                	mv	a1,s3
    80004608:	05093503          	ld	a0,80(s2)
    8000460c:	ffffd097          	auipc	ra,0xffffd
    80004610:	05a080e7          	jalr	90(ra) # 80001666 <copyout>
    80004614:	41f5551b          	sraiw	a0,a0,0x1f
      return -1;
    return 0;
  }
  return -1;
}
    80004618:	60a6                	ld	ra,72(sp)
    8000461a:	6406                	ld	s0,64(sp)
    8000461c:	74e2                	ld	s1,56(sp)
    8000461e:	7942                	ld	s2,48(sp)
    80004620:	79a2                	ld	s3,40(sp)
    80004622:	6161                	addi	sp,sp,80
    80004624:	8082                	ret
  return -1;
    80004626:	557d                	li	a0,-1
    80004628:	bfc5                	j	80004618 <filestat+0x60>

000000008000462a <fileread>:

// Read from file f.
// addr is a user virtual address.
int
fileread(struct file *f, uint64 addr, int n)
{
    8000462a:	7179                	addi	sp,sp,-48
    8000462c:	f406                	sd	ra,40(sp)
    8000462e:	f022                	sd	s0,32(sp)
    80004630:	ec26                	sd	s1,24(sp)
    80004632:	e84a                	sd	s2,16(sp)
    80004634:	e44e                	sd	s3,8(sp)
    80004636:	1800                	addi	s0,sp,48
  int r = 0;

  if(f->readable == 0)
    80004638:	00854783          	lbu	a5,8(a0)
    8000463c:	c3d5                	beqz	a5,800046e0 <fileread+0xb6>
    8000463e:	84aa                	mv	s1,a0
    80004640:	89ae                	mv	s3,a1
    80004642:	8932                	mv	s2,a2
    return -1;

  if(f->type == FD_PIPE){
    80004644:	411c                	lw	a5,0(a0)
    80004646:	4705                	li	a4,1
    80004648:	04e78963          	beq	a5,a4,8000469a <fileread+0x70>
    r = piperead(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    8000464c:	470d                	li	a4,3
    8000464e:	04e78d63          	beq	a5,a4,800046a8 <fileread+0x7e>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
      return -1;
    r = devsw[f->major].read(1, addr, n);
  } else if(f->type == FD_INODE){
    80004652:	4709                	li	a4,2
    80004654:	06e79e63          	bne	a5,a4,800046d0 <fileread+0xa6>
    ilock(f->ip);
    80004658:	6d08                	ld	a0,24(a0)
    8000465a:	fffff097          	auipc	ra,0xfffff
    8000465e:	02c080e7          	jalr	44(ra) # 80003686 <ilock>
    if((r = readi(f->ip, 1, addr, f->off, n)) > 0)
    80004662:	874a                	mv	a4,s2
    80004664:	5094                	lw	a3,32(s1)
    80004666:	864e                	mv	a2,s3
    80004668:	4585                	li	a1,1
    8000466a:	6c88                	ld	a0,24(s1)
    8000466c:	fffff097          	auipc	ra,0xfffff
    80004670:	2ce080e7          	jalr	718(ra) # 8000393a <readi>
    80004674:	892a                	mv	s2,a0
    80004676:	00a05563          	blez	a0,80004680 <fileread+0x56>
      f->off += r;
    8000467a:	509c                	lw	a5,32(s1)
    8000467c:	9fa9                	addw	a5,a5,a0
    8000467e:	d09c                	sw	a5,32(s1)
    iunlock(f->ip);
    80004680:	6c88                	ld	a0,24(s1)
    80004682:	fffff097          	auipc	ra,0xfffff
    80004686:	0c6080e7          	jalr	198(ra) # 80003748 <iunlock>
  } else {
    panic("fileread");
  }

  return r;
}
    8000468a:	854a                	mv	a0,s2
    8000468c:	70a2                	ld	ra,40(sp)
    8000468e:	7402                	ld	s0,32(sp)
    80004690:	64e2                	ld	s1,24(sp)
    80004692:	6942                	ld	s2,16(sp)
    80004694:	69a2                	ld	s3,8(sp)
    80004696:	6145                	addi	sp,sp,48
    80004698:	8082                	ret
    r = piperead(f->pipe, addr, n);
    8000469a:	6908                	ld	a0,16(a0)
    8000469c:	00000097          	auipc	ra,0x0
    800046a0:	3c2080e7          	jalr	962(ra) # 80004a5e <piperead>
    800046a4:	892a                	mv	s2,a0
    800046a6:	b7d5                	j	8000468a <fileread+0x60>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
    800046a8:	02451783          	lh	a5,36(a0)
    800046ac:	03079693          	slli	a3,a5,0x30
    800046b0:	92c1                	srli	a3,a3,0x30
    800046b2:	4725                	li	a4,9
    800046b4:	02d76863          	bltu	a4,a3,800046e4 <fileread+0xba>
    800046b8:	0792                	slli	a5,a5,0x4
    800046ba:	0001c717          	auipc	a4,0x1c
    800046be:	4fe70713          	addi	a4,a4,1278 # 80020bb8 <devsw>
    800046c2:	97ba                	add	a5,a5,a4
    800046c4:	639c                	ld	a5,0(a5)
    800046c6:	c38d                	beqz	a5,800046e8 <fileread+0xbe>
    r = devsw[f->major].read(1, addr, n);
    800046c8:	4505                	li	a0,1
    800046ca:	9782                	jalr	a5
    800046cc:	892a                	mv	s2,a0
    800046ce:	bf75                	j	8000468a <fileread+0x60>
    panic("fileread");
    800046d0:	00004517          	auipc	a0,0x4
    800046d4:	fe050513          	addi	a0,a0,-32 # 800086b0 <syscalls+0x260>
    800046d8:	ffffc097          	auipc	ra,0xffffc
    800046dc:	e64080e7          	jalr	-412(ra) # 8000053c <panic>
    return -1;
    800046e0:	597d                	li	s2,-1
    800046e2:	b765                	j	8000468a <fileread+0x60>
      return -1;
    800046e4:	597d                	li	s2,-1
    800046e6:	b755                	j	8000468a <fileread+0x60>
    800046e8:	597d                	li	s2,-1
    800046ea:	b745                	j	8000468a <fileread+0x60>

00000000800046ec <filewrite>:
int
filewrite(struct file *f, uint64 addr, int n)
{
  int r, ret = 0;

  if(f->writable == 0)
    800046ec:	00954783          	lbu	a5,9(a0)
    800046f0:	10078e63          	beqz	a5,8000480c <filewrite+0x120>
{
    800046f4:	715d                	addi	sp,sp,-80
    800046f6:	e486                	sd	ra,72(sp)
    800046f8:	e0a2                	sd	s0,64(sp)
    800046fa:	fc26                	sd	s1,56(sp)
    800046fc:	f84a                	sd	s2,48(sp)
    800046fe:	f44e                	sd	s3,40(sp)
    80004700:	f052                	sd	s4,32(sp)
    80004702:	ec56                	sd	s5,24(sp)
    80004704:	e85a                	sd	s6,16(sp)
    80004706:	e45e                	sd	s7,8(sp)
    80004708:	e062                	sd	s8,0(sp)
    8000470a:	0880                	addi	s0,sp,80
    8000470c:	892a                	mv	s2,a0
    8000470e:	8b2e                	mv	s6,a1
    80004710:	8a32                	mv	s4,a2
    return -1;

  if(f->type == FD_PIPE){
    80004712:	411c                	lw	a5,0(a0)
    80004714:	4705                	li	a4,1
    80004716:	02e78263          	beq	a5,a4,8000473a <filewrite+0x4e>
    ret = pipewrite(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    8000471a:	470d                	li	a4,3
    8000471c:	02e78563          	beq	a5,a4,80004746 <filewrite+0x5a>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
      return -1;
    ret = devsw[f->major].write(1, addr, n);
  } else if(f->type == FD_INODE){
    80004720:	4709                	li	a4,2
    80004722:	0ce79d63          	bne	a5,a4,800047fc <filewrite+0x110>
    // and 2 blocks of slop for non-aligned writes.
    // this really belongs lower down, since writei()
    // might be writing a device like the console.
    int max = ((MAXOPBLOCKS-1-1-2) / 2) * BSIZE;
    int i = 0;
    while(i < n){
    80004726:	0ac05b63          	blez	a2,800047dc <filewrite+0xf0>
    int i = 0;
    8000472a:	4981                	li	s3,0
      int n1 = n - i;
      if(n1 > max)
    8000472c:	6b85                	lui	s7,0x1
    8000472e:	c00b8b93          	addi	s7,s7,-1024 # c00 <_entry-0x7ffff400>
    80004732:	6c05                	lui	s8,0x1
    80004734:	c00c0c1b          	addiw	s8,s8,-1024 # c00 <_entry-0x7ffff400>
    80004738:	a851                	j	800047cc <filewrite+0xe0>
    ret = pipewrite(f->pipe, addr, n);
    8000473a:	6908                	ld	a0,16(a0)
    8000473c:	00000097          	auipc	ra,0x0
    80004740:	22a080e7          	jalr	554(ra) # 80004966 <pipewrite>
    80004744:	a045                	j	800047e4 <filewrite+0xf8>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
    80004746:	02451783          	lh	a5,36(a0)
    8000474a:	03079693          	slli	a3,a5,0x30
    8000474e:	92c1                	srli	a3,a3,0x30
    80004750:	4725                	li	a4,9
    80004752:	0ad76f63          	bltu	a4,a3,80004810 <filewrite+0x124>
    80004756:	0792                	slli	a5,a5,0x4
    80004758:	0001c717          	auipc	a4,0x1c
    8000475c:	46070713          	addi	a4,a4,1120 # 80020bb8 <devsw>
    80004760:	97ba                	add	a5,a5,a4
    80004762:	679c                	ld	a5,8(a5)
    80004764:	cbc5                	beqz	a5,80004814 <filewrite+0x128>
    ret = devsw[f->major].write(1, addr, n);
    80004766:	4505                	li	a0,1
    80004768:	9782                	jalr	a5
    8000476a:	a8ad                	j	800047e4 <filewrite+0xf8>
      if(n1 > max)
    8000476c:	00048a9b          	sext.w	s5,s1
        n1 = max;

      begin_op();
    80004770:	00000097          	auipc	ra,0x0
    80004774:	8bc080e7          	jalr	-1860(ra) # 8000402c <begin_op>
      ilock(f->ip);
    80004778:	01893503          	ld	a0,24(s2)
    8000477c:	fffff097          	auipc	ra,0xfffff
    80004780:	f0a080e7          	jalr	-246(ra) # 80003686 <ilock>
      if ((r = writei(f->ip, 1, addr + i, f->off, n1)) > 0)
    80004784:	8756                	mv	a4,s5
    80004786:	02092683          	lw	a3,32(s2)
    8000478a:	01698633          	add	a2,s3,s6
    8000478e:	4585                	li	a1,1
    80004790:	01893503          	ld	a0,24(s2)
    80004794:	fffff097          	auipc	ra,0xfffff
    80004798:	29e080e7          	jalr	670(ra) # 80003a32 <writei>
    8000479c:	84aa                	mv	s1,a0
    8000479e:	00a05763          	blez	a0,800047ac <filewrite+0xc0>
        f->off += r;
    800047a2:	02092783          	lw	a5,32(s2)
    800047a6:	9fa9                	addw	a5,a5,a0
    800047a8:	02f92023          	sw	a5,32(s2)
      iunlock(f->ip);
    800047ac:	01893503          	ld	a0,24(s2)
    800047b0:	fffff097          	auipc	ra,0xfffff
    800047b4:	f98080e7          	jalr	-104(ra) # 80003748 <iunlock>
      end_op();
    800047b8:	00000097          	auipc	ra,0x0
    800047bc:	8ee080e7          	jalr	-1810(ra) # 800040a6 <end_op>

      if(r != n1){
    800047c0:	009a9f63          	bne	s5,s1,800047de <filewrite+0xf2>
        // error from writei
        break;
      }
      i += r;
    800047c4:	013489bb          	addw	s3,s1,s3
    while(i < n){
    800047c8:	0149db63          	bge	s3,s4,800047de <filewrite+0xf2>
      int n1 = n - i;
    800047cc:	413a04bb          	subw	s1,s4,s3
      if(n1 > max)
    800047d0:	0004879b          	sext.w	a5,s1
    800047d4:	f8fbdce3          	bge	s7,a5,8000476c <filewrite+0x80>
    800047d8:	84e2                	mv	s1,s8
    800047da:	bf49                	j	8000476c <filewrite+0x80>
    int i = 0;
    800047dc:	4981                	li	s3,0
    }
    ret = (i == n ? n : -1);
    800047de:	033a1d63          	bne	s4,s3,80004818 <filewrite+0x12c>
    800047e2:	8552                	mv	a0,s4
  } else {
    panic("filewrite");
  }

  return ret;
}
    800047e4:	60a6                	ld	ra,72(sp)
    800047e6:	6406                	ld	s0,64(sp)
    800047e8:	74e2                	ld	s1,56(sp)
    800047ea:	7942                	ld	s2,48(sp)
    800047ec:	79a2                	ld	s3,40(sp)
    800047ee:	7a02                	ld	s4,32(sp)
    800047f0:	6ae2                	ld	s5,24(sp)
    800047f2:	6b42                	ld	s6,16(sp)
    800047f4:	6ba2                	ld	s7,8(sp)
    800047f6:	6c02                	ld	s8,0(sp)
    800047f8:	6161                	addi	sp,sp,80
    800047fa:	8082                	ret
    panic("filewrite");
    800047fc:	00004517          	auipc	a0,0x4
    80004800:	ec450513          	addi	a0,a0,-316 # 800086c0 <syscalls+0x270>
    80004804:	ffffc097          	auipc	ra,0xffffc
    80004808:	d38080e7          	jalr	-712(ra) # 8000053c <panic>
    return -1;
    8000480c:	557d                	li	a0,-1
}
    8000480e:	8082                	ret
      return -1;
    80004810:	557d                	li	a0,-1
    80004812:	bfc9                	j	800047e4 <filewrite+0xf8>
    80004814:	557d                	li	a0,-1
    80004816:	b7f9                	j	800047e4 <filewrite+0xf8>
    ret = (i == n ? n : -1);
    80004818:	557d                	li	a0,-1
    8000481a:	b7e9                	j	800047e4 <filewrite+0xf8>

000000008000481c <pipealloc>:
  int writeopen;  // write fd is still open
};

int
pipealloc(struct file **f0, struct file **f1)
{
    8000481c:	7179                	addi	sp,sp,-48
    8000481e:	f406                	sd	ra,40(sp)
    80004820:	f022                	sd	s0,32(sp)
    80004822:	ec26                	sd	s1,24(sp)
    80004824:	e84a                	sd	s2,16(sp)
    80004826:	e44e                	sd	s3,8(sp)
    80004828:	e052                	sd	s4,0(sp)
    8000482a:	1800                	addi	s0,sp,48
    8000482c:	84aa                	mv	s1,a0
    8000482e:	8a2e                	mv	s4,a1
  struct pipe *pi;

  pi = 0;
  *f0 = *f1 = 0;
    80004830:	0005b023          	sd	zero,0(a1)
    80004834:	00053023          	sd	zero,0(a0)
  if((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
    80004838:	00000097          	auipc	ra,0x0
    8000483c:	bfc080e7          	jalr	-1028(ra) # 80004434 <filealloc>
    80004840:	e088                	sd	a0,0(s1)
    80004842:	c551                	beqz	a0,800048ce <pipealloc+0xb2>
    80004844:	00000097          	auipc	ra,0x0
    80004848:	bf0080e7          	jalr	-1040(ra) # 80004434 <filealloc>
    8000484c:	00aa3023          	sd	a0,0(s4)
    80004850:	c92d                	beqz	a0,800048c2 <pipealloc+0xa6>
    goto bad;
  if((pi = (struct pipe*)kalloc()) == 0)
    80004852:	ffffc097          	auipc	ra,0xffffc
    80004856:	290080e7          	jalr	656(ra) # 80000ae2 <kalloc>
    8000485a:	892a                	mv	s2,a0
    8000485c:	c125                	beqz	a0,800048bc <pipealloc+0xa0>
    goto bad;
  pi->readopen = 1;
    8000485e:	4985                	li	s3,1
    80004860:	23352023          	sw	s3,544(a0)
  pi->writeopen = 1;
    80004864:	23352223          	sw	s3,548(a0)
  pi->nwrite = 0;
    80004868:	20052e23          	sw	zero,540(a0)
  pi->nread = 0;
    8000486c:	20052c23          	sw	zero,536(a0)
  initlock(&pi->lock, "pipe");
    80004870:	00004597          	auipc	a1,0x4
    80004874:	e6058593          	addi	a1,a1,-416 # 800086d0 <syscalls+0x280>
    80004878:	ffffc097          	auipc	ra,0xffffc
    8000487c:	2ca080e7          	jalr	714(ra) # 80000b42 <initlock>
  (*f0)->type = FD_PIPE;
    80004880:	609c                	ld	a5,0(s1)
    80004882:	0137a023          	sw	s3,0(a5)
  (*f0)->readable = 1;
    80004886:	609c                	ld	a5,0(s1)
    80004888:	01378423          	sb	s3,8(a5)
  (*f0)->writable = 0;
    8000488c:	609c                	ld	a5,0(s1)
    8000488e:	000784a3          	sb	zero,9(a5)
  (*f0)->pipe = pi;
    80004892:	609c                	ld	a5,0(s1)
    80004894:	0127b823          	sd	s2,16(a5)
  (*f1)->type = FD_PIPE;
    80004898:	000a3783          	ld	a5,0(s4)
    8000489c:	0137a023          	sw	s3,0(a5)
  (*f1)->readable = 0;
    800048a0:	000a3783          	ld	a5,0(s4)
    800048a4:	00078423          	sb	zero,8(a5)
  (*f1)->writable = 1;
    800048a8:	000a3783          	ld	a5,0(s4)
    800048ac:	013784a3          	sb	s3,9(a5)
  (*f1)->pipe = pi;
    800048b0:	000a3783          	ld	a5,0(s4)
    800048b4:	0127b823          	sd	s2,16(a5)
  return 0;
    800048b8:	4501                	li	a0,0
    800048ba:	a025                	j	800048e2 <pipealloc+0xc6>

 bad:
  if(pi)
    kfree((char*)pi);
  if(*f0)
    800048bc:	6088                	ld	a0,0(s1)
    800048be:	e501                	bnez	a0,800048c6 <pipealloc+0xaa>
    800048c0:	a039                	j	800048ce <pipealloc+0xb2>
    800048c2:	6088                	ld	a0,0(s1)
    800048c4:	c51d                	beqz	a0,800048f2 <pipealloc+0xd6>
    fileclose(*f0);
    800048c6:	00000097          	auipc	ra,0x0
    800048ca:	c2a080e7          	jalr	-982(ra) # 800044f0 <fileclose>
  if(*f1)
    800048ce:	000a3783          	ld	a5,0(s4)
    fileclose(*f1);
  return -1;
    800048d2:	557d                	li	a0,-1
  if(*f1)
    800048d4:	c799                	beqz	a5,800048e2 <pipealloc+0xc6>
    fileclose(*f1);
    800048d6:	853e                	mv	a0,a5
    800048d8:	00000097          	auipc	ra,0x0
    800048dc:	c18080e7          	jalr	-1000(ra) # 800044f0 <fileclose>
  return -1;
    800048e0:	557d                	li	a0,-1
}
    800048e2:	70a2                	ld	ra,40(sp)
    800048e4:	7402                	ld	s0,32(sp)
    800048e6:	64e2                	ld	s1,24(sp)
    800048e8:	6942                	ld	s2,16(sp)
    800048ea:	69a2                	ld	s3,8(sp)
    800048ec:	6a02                	ld	s4,0(sp)
    800048ee:	6145                	addi	sp,sp,48
    800048f0:	8082                	ret
  return -1;
    800048f2:	557d                	li	a0,-1
    800048f4:	b7fd                	j	800048e2 <pipealloc+0xc6>

00000000800048f6 <pipeclose>:

void
pipeclose(struct pipe *pi, int writable)
{
    800048f6:	1101                	addi	sp,sp,-32
    800048f8:	ec06                	sd	ra,24(sp)
    800048fa:	e822                	sd	s0,16(sp)
    800048fc:	e426                	sd	s1,8(sp)
    800048fe:	e04a                	sd	s2,0(sp)
    80004900:	1000                	addi	s0,sp,32
    80004902:	84aa                	mv	s1,a0
    80004904:	892e                	mv	s2,a1
  acquire(&pi->lock);
    80004906:	ffffc097          	auipc	ra,0xffffc
    8000490a:	2cc080e7          	jalr	716(ra) # 80000bd2 <acquire>
  if(writable){
    8000490e:	02090d63          	beqz	s2,80004948 <pipeclose+0x52>
    pi->writeopen = 0;
    80004912:	2204a223          	sw	zero,548(s1)
    wakeup(&pi->nread);
    80004916:	21848513          	addi	a0,s1,536
    8000491a:	ffffd097          	auipc	ra,0xffffd
    8000491e:	7e4080e7          	jalr	2020(ra) # 800020fe <wakeup>
  } else {
    pi->readopen = 0;
    wakeup(&pi->nwrite);
  }
  if(pi->readopen == 0 && pi->writeopen == 0){
    80004922:	2204b783          	ld	a5,544(s1)
    80004926:	eb95                	bnez	a5,8000495a <pipeclose+0x64>
    release(&pi->lock);
    80004928:	8526                	mv	a0,s1
    8000492a:	ffffc097          	auipc	ra,0xffffc
    8000492e:	35c080e7          	jalr	860(ra) # 80000c86 <release>
    kfree((char*)pi);
    80004932:	8526                	mv	a0,s1
    80004934:	ffffc097          	auipc	ra,0xffffc
    80004938:	0b0080e7          	jalr	176(ra) # 800009e4 <kfree>
  } else
    release(&pi->lock);
}
    8000493c:	60e2                	ld	ra,24(sp)
    8000493e:	6442                	ld	s0,16(sp)
    80004940:	64a2                	ld	s1,8(sp)
    80004942:	6902                	ld	s2,0(sp)
    80004944:	6105                	addi	sp,sp,32
    80004946:	8082                	ret
    pi->readopen = 0;
    80004948:	2204a023          	sw	zero,544(s1)
    wakeup(&pi->nwrite);
    8000494c:	21c48513          	addi	a0,s1,540
    80004950:	ffffd097          	auipc	ra,0xffffd
    80004954:	7ae080e7          	jalr	1966(ra) # 800020fe <wakeup>
    80004958:	b7e9                	j	80004922 <pipeclose+0x2c>
    release(&pi->lock);
    8000495a:	8526                	mv	a0,s1
    8000495c:	ffffc097          	auipc	ra,0xffffc
    80004960:	32a080e7          	jalr	810(ra) # 80000c86 <release>
}
    80004964:	bfe1                	j	8000493c <pipeclose+0x46>

0000000080004966 <pipewrite>:

int
pipewrite(struct pipe *pi, uint64 addr, int n)
{
    80004966:	711d                	addi	sp,sp,-96
    80004968:	ec86                	sd	ra,88(sp)
    8000496a:	e8a2                	sd	s0,80(sp)
    8000496c:	e4a6                	sd	s1,72(sp)
    8000496e:	e0ca                	sd	s2,64(sp)
    80004970:	fc4e                	sd	s3,56(sp)
    80004972:	f852                	sd	s4,48(sp)
    80004974:	f456                	sd	s5,40(sp)
    80004976:	f05a                	sd	s6,32(sp)
    80004978:	ec5e                	sd	s7,24(sp)
    8000497a:	e862                	sd	s8,16(sp)
    8000497c:	1080                	addi	s0,sp,96
    8000497e:	84aa                	mv	s1,a0
    80004980:	8aae                	mv	s5,a1
    80004982:	8a32                	mv	s4,a2
  int i = 0;
  struct proc *pr = myproc();
    80004984:	ffffd097          	auipc	ra,0xffffd
    80004988:	022080e7          	jalr	34(ra) # 800019a6 <myproc>
    8000498c:	89aa                	mv	s3,a0

  acquire(&pi->lock);
    8000498e:	8526                	mv	a0,s1
    80004990:	ffffc097          	auipc	ra,0xffffc
    80004994:	242080e7          	jalr	578(ra) # 80000bd2 <acquire>
  while(i < n){
    80004998:	0b405663          	blez	s4,80004a44 <pipewrite+0xde>
  int i = 0;
    8000499c:	4901                	li	s2,0
    if(pi->nwrite == pi->nread + PIPESIZE){ //DOC: pipewrite-full
      wakeup(&pi->nread);
      sleep(&pi->nwrite, &pi->lock);
    } else {
      char ch;
      if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    8000499e:	5b7d                	li	s6,-1
      wakeup(&pi->nread);
    800049a0:	21848c13          	addi	s8,s1,536
      sleep(&pi->nwrite, &pi->lock);
    800049a4:	21c48b93          	addi	s7,s1,540
    800049a8:	a089                	j	800049ea <pipewrite+0x84>
      release(&pi->lock);
    800049aa:	8526                	mv	a0,s1
    800049ac:	ffffc097          	auipc	ra,0xffffc
    800049b0:	2da080e7          	jalr	730(ra) # 80000c86 <release>
      return -1;
    800049b4:	597d                	li	s2,-1
  }
  wakeup(&pi->nread);
  release(&pi->lock);

  return i;
}
    800049b6:	854a                	mv	a0,s2
    800049b8:	60e6                	ld	ra,88(sp)
    800049ba:	6446                	ld	s0,80(sp)
    800049bc:	64a6                	ld	s1,72(sp)
    800049be:	6906                	ld	s2,64(sp)
    800049c0:	79e2                	ld	s3,56(sp)
    800049c2:	7a42                	ld	s4,48(sp)
    800049c4:	7aa2                	ld	s5,40(sp)
    800049c6:	7b02                	ld	s6,32(sp)
    800049c8:	6be2                	ld	s7,24(sp)
    800049ca:	6c42                	ld	s8,16(sp)
    800049cc:	6125                	addi	sp,sp,96
    800049ce:	8082                	ret
      wakeup(&pi->nread);
    800049d0:	8562                	mv	a0,s8
    800049d2:	ffffd097          	auipc	ra,0xffffd
    800049d6:	72c080e7          	jalr	1836(ra) # 800020fe <wakeup>
      sleep(&pi->nwrite, &pi->lock);
    800049da:	85a6                	mv	a1,s1
    800049dc:	855e                	mv	a0,s7
    800049de:	ffffd097          	auipc	ra,0xffffd
    800049e2:	6bc080e7          	jalr	1724(ra) # 8000209a <sleep>
  while(i < n){
    800049e6:	07495063          	bge	s2,s4,80004a46 <pipewrite+0xe0>
    if(pi->readopen == 0 || killed(pr)){
    800049ea:	2204a783          	lw	a5,544(s1)
    800049ee:	dfd5                	beqz	a5,800049aa <pipewrite+0x44>
    800049f0:	854e                	mv	a0,s3
    800049f2:	ffffe097          	auipc	ra,0xffffe
    800049f6:	950080e7          	jalr	-1712(ra) # 80002342 <killed>
    800049fa:	f945                	bnez	a0,800049aa <pipewrite+0x44>
    if(pi->nwrite == pi->nread + PIPESIZE){ //DOC: pipewrite-full
    800049fc:	2184a783          	lw	a5,536(s1)
    80004a00:	21c4a703          	lw	a4,540(s1)
    80004a04:	2007879b          	addiw	a5,a5,512
    80004a08:	fcf704e3          	beq	a4,a5,800049d0 <pipewrite+0x6a>
      if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    80004a0c:	4685                	li	a3,1
    80004a0e:	01590633          	add	a2,s2,s5
    80004a12:	faf40593          	addi	a1,s0,-81
    80004a16:	0509b503          	ld	a0,80(s3)
    80004a1a:	ffffd097          	auipc	ra,0xffffd
    80004a1e:	cd8080e7          	jalr	-808(ra) # 800016f2 <copyin>
    80004a22:	03650263          	beq	a0,s6,80004a46 <pipewrite+0xe0>
      pi->data[pi->nwrite++ % PIPESIZE] = ch;
    80004a26:	21c4a783          	lw	a5,540(s1)
    80004a2a:	0017871b          	addiw	a4,a5,1
    80004a2e:	20e4ae23          	sw	a4,540(s1)
    80004a32:	1ff7f793          	andi	a5,a5,511
    80004a36:	97a6                	add	a5,a5,s1
    80004a38:	faf44703          	lbu	a4,-81(s0)
    80004a3c:	00e78c23          	sb	a4,24(a5)
      i++;
    80004a40:	2905                	addiw	s2,s2,1
    80004a42:	b755                	j	800049e6 <pipewrite+0x80>
  int i = 0;
    80004a44:	4901                	li	s2,0
  wakeup(&pi->nread);
    80004a46:	21848513          	addi	a0,s1,536
    80004a4a:	ffffd097          	auipc	ra,0xffffd
    80004a4e:	6b4080e7          	jalr	1716(ra) # 800020fe <wakeup>
  release(&pi->lock);
    80004a52:	8526                	mv	a0,s1
    80004a54:	ffffc097          	auipc	ra,0xffffc
    80004a58:	232080e7          	jalr	562(ra) # 80000c86 <release>
  return i;
    80004a5c:	bfa9                	j	800049b6 <pipewrite+0x50>

0000000080004a5e <piperead>:

int
piperead(struct pipe *pi, uint64 addr, int n)
{
    80004a5e:	715d                	addi	sp,sp,-80
    80004a60:	e486                	sd	ra,72(sp)
    80004a62:	e0a2                	sd	s0,64(sp)
    80004a64:	fc26                	sd	s1,56(sp)
    80004a66:	f84a                	sd	s2,48(sp)
    80004a68:	f44e                	sd	s3,40(sp)
    80004a6a:	f052                	sd	s4,32(sp)
    80004a6c:	ec56                	sd	s5,24(sp)
    80004a6e:	e85a                	sd	s6,16(sp)
    80004a70:	0880                	addi	s0,sp,80
    80004a72:	84aa                	mv	s1,a0
    80004a74:	892e                	mv	s2,a1
    80004a76:	8ab2                	mv	s5,a2
  int i;
  struct proc *pr = myproc();
    80004a78:	ffffd097          	auipc	ra,0xffffd
    80004a7c:	f2e080e7          	jalr	-210(ra) # 800019a6 <myproc>
    80004a80:	8a2a                	mv	s4,a0
  char ch;

  acquire(&pi->lock);
    80004a82:	8526                	mv	a0,s1
    80004a84:	ffffc097          	auipc	ra,0xffffc
    80004a88:	14e080e7          	jalr	334(ra) # 80000bd2 <acquire>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80004a8c:	2184a703          	lw	a4,536(s1)
    80004a90:	21c4a783          	lw	a5,540(s1)
    if(killed(pr)){
      release(&pi->lock);
      return -1;
    }
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    80004a94:	21848993          	addi	s3,s1,536
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80004a98:	02f71763          	bne	a4,a5,80004ac6 <piperead+0x68>
    80004a9c:	2244a783          	lw	a5,548(s1)
    80004aa0:	c39d                	beqz	a5,80004ac6 <piperead+0x68>
    if(killed(pr)){
    80004aa2:	8552                	mv	a0,s4
    80004aa4:	ffffe097          	auipc	ra,0xffffe
    80004aa8:	89e080e7          	jalr	-1890(ra) # 80002342 <killed>
    80004aac:	e949                	bnez	a0,80004b3e <piperead+0xe0>
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    80004aae:	85a6                	mv	a1,s1
    80004ab0:	854e                	mv	a0,s3
    80004ab2:	ffffd097          	auipc	ra,0xffffd
    80004ab6:	5e8080e7          	jalr	1512(ra) # 8000209a <sleep>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80004aba:	2184a703          	lw	a4,536(s1)
    80004abe:	21c4a783          	lw	a5,540(s1)
    80004ac2:	fcf70de3          	beq	a4,a5,80004a9c <piperead+0x3e>
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80004ac6:	4981                	li	s3,0
    if(pi->nread == pi->nwrite)
      break;
    ch = pi->data[pi->nread++ % PIPESIZE];
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1)
    80004ac8:	5b7d                	li	s6,-1
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80004aca:	05505463          	blez	s5,80004b12 <piperead+0xb4>
    if(pi->nread == pi->nwrite)
    80004ace:	2184a783          	lw	a5,536(s1)
    80004ad2:	21c4a703          	lw	a4,540(s1)
    80004ad6:	02f70e63          	beq	a4,a5,80004b12 <piperead+0xb4>
    ch = pi->data[pi->nread++ % PIPESIZE];
    80004ada:	0017871b          	addiw	a4,a5,1
    80004ade:	20e4ac23          	sw	a4,536(s1)
    80004ae2:	1ff7f793          	andi	a5,a5,511
    80004ae6:	97a6                	add	a5,a5,s1
    80004ae8:	0187c783          	lbu	a5,24(a5)
    80004aec:	faf40fa3          	sb	a5,-65(s0)
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1)
    80004af0:	4685                	li	a3,1
    80004af2:	fbf40613          	addi	a2,s0,-65
    80004af6:	85ca                	mv	a1,s2
    80004af8:	050a3503          	ld	a0,80(s4)
    80004afc:	ffffd097          	auipc	ra,0xffffd
    80004b00:	b6a080e7          	jalr	-1174(ra) # 80001666 <copyout>
    80004b04:	01650763          	beq	a0,s6,80004b12 <piperead+0xb4>
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80004b08:	2985                	addiw	s3,s3,1
    80004b0a:	0905                	addi	s2,s2,1
    80004b0c:	fd3a91e3          	bne	s5,s3,80004ace <piperead+0x70>
    80004b10:	89d6                	mv	s3,s5
      break;
  }
  wakeup(&pi->nwrite);  //DOC: piperead-wakeup
    80004b12:	21c48513          	addi	a0,s1,540
    80004b16:	ffffd097          	auipc	ra,0xffffd
    80004b1a:	5e8080e7          	jalr	1512(ra) # 800020fe <wakeup>
  release(&pi->lock);
    80004b1e:	8526                	mv	a0,s1
    80004b20:	ffffc097          	auipc	ra,0xffffc
    80004b24:	166080e7          	jalr	358(ra) # 80000c86 <release>
  return i;
}
    80004b28:	854e                	mv	a0,s3
    80004b2a:	60a6                	ld	ra,72(sp)
    80004b2c:	6406                	ld	s0,64(sp)
    80004b2e:	74e2                	ld	s1,56(sp)
    80004b30:	7942                	ld	s2,48(sp)
    80004b32:	79a2                	ld	s3,40(sp)
    80004b34:	7a02                	ld	s4,32(sp)
    80004b36:	6ae2                	ld	s5,24(sp)
    80004b38:	6b42                	ld	s6,16(sp)
    80004b3a:	6161                	addi	sp,sp,80
    80004b3c:	8082                	ret
      release(&pi->lock);
    80004b3e:	8526                	mv	a0,s1
    80004b40:	ffffc097          	auipc	ra,0xffffc
    80004b44:	146080e7          	jalr	326(ra) # 80000c86 <release>
      return -1;
    80004b48:	59fd                	li	s3,-1
    80004b4a:	bff9                	j	80004b28 <piperead+0xca>

0000000080004b4c <flags2perm>:
#include "elf.h"

static int loadseg(pde_t *, uint64, struct inode *, uint, uint);

int flags2perm(int flags)
{
    80004b4c:	1141                	addi	sp,sp,-16
    80004b4e:	e422                	sd	s0,8(sp)
    80004b50:	0800                	addi	s0,sp,16
    80004b52:	87aa                	mv	a5,a0
    int perm = 0;
    if(flags & 0x1)
    80004b54:	8905                	andi	a0,a0,1
    80004b56:	050e                	slli	a0,a0,0x3
      perm = PTE_X;
    if(flags & 0x2)
    80004b58:	8b89                	andi	a5,a5,2
    80004b5a:	c399                	beqz	a5,80004b60 <flags2perm+0x14>
      perm |= PTE_W;
    80004b5c:	00456513          	ori	a0,a0,4
    return perm;
}
    80004b60:	6422                	ld	s0,8(sp)
    80004b62:	0141                	addi	sp,sp,16
    80004b64:	8082                	ret

0000000080004b66 <exec>:

int
exec(char *path, char **argv)
{
    80004b66:	df010113          	addi	sp,sp,-528
    80004b6a:	20113423          	sd	ra,520(sp)
    80004b6e:	20813023          	sd	s0,512(sp)
    80004b72:	ffa6                	sd	s1,504(sp)
    80004b74:	fbca                	sd	s2,496(sp)
    80004b76:	f7ce                	sd	s3,488(sp)
    80004b78:	f3d2                	sd	s4,480(sp)
    80004b7a:	efd6                	sd	s5,472(sp)
    80004b7c:	ebda                	sd	s6,464(sp)
    80004b7e:	e7de                	sd	s7,456(sp)
    80004b80:	e3e2                	sd	s8,448(sp)
    80004b82:	ff66                	sd	s9,440(sp)
    80004b84:	fb6a                	sd	s10,432(sp)
    80004b86:	f76e                	sd	s11,424(sp)
    80004b88:	0c00                	addi	s0,sp,528
    80004b8a:	892a                	mv	s2,a0
    80004b8c:	dea43c23          	sd	a0,-520(s0)
    80004b90:	e0b43023          	sd	a1,-512(s0)
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
  struct elfhdr elf;
  struct inode *ip;
  struct proghdr ph;
  pagetable_t pagetable = 0, oldpagetable;
  struct proc *p = myproc();
    80004b94:	ffffd097          	auipc	ra,0xffffd
    80004b98:	e12080e7          	jalr	-494(ra) # 800019a6 <myproc>
    80004b9c:	84aa                	mv	s1,a0

  begin_op();
    80004b9e:	fffff097          	auipc	ra,0xfffff
    80004ba2:	48e080e7          	jalr	1166(ra) # 8000402c <begin_op>

  if((ip = namei(path)) == 0){
    80004ba6:	854a                	mv	a0,s2
    80004ba8:	fffff097          	auipc	ra,0xfffff
    80004bac:	284080e7          	jalr	644(ra) # 80003e2c <namei>
    80004bb0:	c92d                	beqz	a0,80004c22 <exec+0xbc>
    80004bb2:	8a2a                	mv	s4,a0
    end_op();
    return -1;
  }
  ilock(ip);
    80004bb4:	fffff097          	auipc	ra,0xfffff
    80004bb8:	ad2080e7          	jalr	-1326(ra) # 80003686 <ilock>

  // Check ELF header
  if(readi(ip, 0, (uint64)&elf, 0, sizeof(elf)) != sizeof(elf))
    80004bbc:	04000713          	li	a4,64
    80004bc0:	4681                	li	a3,0
    80004bc2:	e5040613          	addi	a2,s0,-432
    80004bc6:	4581                	li	a1,0
    80004bc8:	8552                	mv	a0,s4
    80004bca:	fffff097          	auipc	ra,0xfffff
    80004bce:	d70080e7          	jalr	-656(ra) # 8000393a <readi>
    80004bd2:	04000793          	li	a5,64
    80004bd6:	00f51a63          	bne	a0,a5,80004bea <exec+0x84>
    goto bad;

  if(elf.magic != ELF_MAGIC)
    80004bda:	e5042703          	lw	a4,-432(s0)
    80004bde:	464c47b7          	lui	a5,0x464c4
    80004be2:	57f78793          	addi	a5,a5,1407 # 464c457f <_entry-0x39b3ba81>
    80004be6:	04f70463          	beq	a4,a5,80004c2e <exec+0xc8>

 bad:
  if(pagetable)
    proc_freepagetable(pagetable, sz);
  if(ip){
    iunlockput(ip);
    80004bea:	8552                	mv	a0,s4
    80004bec:	fffff097          	auipc	ra,0xfffff
    80004bf0:	cfc080e7          	jalr	-772(ra) # 800038e8 <iunlockput>
    end_op();
    80004bf4:	fffff097          	auipc	ra,0xfffff
    80004bf8:	4b2080e7          	jalr	1202(ra) # 800040a6 <end_op>
  }
  return -1;
    80004bfc:	557d                	li	a0,-1
}
    80004bfe:	20813083          	ld	ra,520(sp)
    80004c02:	20013403          	ld	s0,512(sp)
    80004c06:	74fe                	ld	s1,504(sp)
    80004c08:	795e                	ld	s2,496(sp)
    80004c0a:	79be                	ld	s3,488(sp)
    80004c0c:	7a1e                	ld	s4,480(sp)
    80004c0e:	6afe                	ld	s5,472(sp)
    80004c10:	6b5e                	ld	s6,464(sp)
    80004c12:	6bbe                	ld	s7,456(sp)
    80004c14:	6c1e                	ld	s8,448(sp)
    80004c16:	7cfa                	ld	s9,440(sp)
    80004c18:	7d5a                	ld	s10,432(sp)
    80004c1a:	7dba                	ld	s11,424(sp)
    80004c1c:	21010113          	addi	sp,sp,528
    80004c20:	8082                	ret
    end_op();
    80004c22:	fffff097          	auipc	ra,0xfffff
    80004c26:	484080e7          	jalr	1156(ra) # 800040a6 <end_op>
    return -1;
    80004c2a:	557d                	li	a0,-1
    80004c2c:	bfc9                	j	80004bfe <exec+0x98>
  if((pagetable = proc_pagetable(p)) == 0)
    80004c2e:	8526                	mv	a0,s1
    80004c30:	ffffd097          	auipc	ra,0xffffd
    80004c34:	e86080e7          	jalr	-378(ra) # 80001ab6 <proc_pagetable>
    80004c38:	8b2a                	mv	s6,a0
    80004c3a:	d945                	beqz	a0,80004bea <exec+0x84>
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80004c3c:	e7042d03          	lw	s10,-400(s0)
    80004c40:	e8845783          	lhu	a5,-376(s0)
    80004c44:	10078463          	beqz	a5,80004d4c <exec+0x1e6>
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
    80004c48:	4901                	li	s2,0
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80004c4a:	4d81                	li	s11,0
    if(ph.vaddr % PGSIZE != 0)
    80004c4c:	6c85                	lui	s9,0x1
    80004c4e:	fffc8793          	addi	a5,s9,-1 # fff <_entry-0x7ffff001>
    80004c52:	def43823          	sd	a5,-528(s0)

  for(i = 0; i < sz; i += PGSIZE){
    pa = walkaddr(pagetable, va + i);
    if(pa == 0)
      panic("loadseg: address should exist");
    if(sz - i < PGSIZE)
    80004c56:	6a85                	lui	s5,0x1
    80004c58:	a0b5                	j	80004cc4 <exec+0x15e>
      panic("loadseg: address should exist");
    80004c5a:	00004517          	auipc	a0,0x4
    80004c5e:	a7e50513          	addi	a0,a0,-1410 # 800086d8 <syscalls+0x288>
    80004c62:	ffffc097          	auipc	ra,0xffffc
    80004c66:	8da080e7          	jalr	-1830(ra) # 8000053c <panic>
    if(sz - i < PGSIZE)
    80004c6a:	2481                	sext.w	s1,s1
      n = sz - i;
    else
      n = PGSIZE;
    if(readi(ip, 0, (uint64)pa, offset+i, n) != n)
    80004c6c:	8726                	mv	a4,s1
    80004c6e:	012c06bb          	addw	a3,s8,s2
    80004c72:	4581                	li	a1,0
    80004c74:	8552                	mv	a0,s4
    80004c76:	fffff097          	auipc	ra,0xfffff
    80004c7a:	cc4080e7          	jalr	-828(ra) # 8000393a <readi>
    80004c7e:	2501                	sext.w	a0,a0
    80004c80:	24a49863          	bne	s1,a0,80004ed0 <exec+0x36a>
  for(i = 0; i < sz; i += PGSIZE){
    80004c84:	012a893b          	addw	s2,s5,s2
    80004c88:	03397563          	bgeu	s2,s3,80004cb2 <exec+0x14c>
    pa = walkaddr(pagetable, va + i);
    80004c8c:	02091593          	slli	a1,s2,0x20
    80004c90:	9181                	srli	a1,a1,0x20
    80004c92:	95de                	add	a1,a1,s7
    80004c94:	855a                	mv	a0,s6
    80004c96:	ffffc097          	auipc	ra,0xffffc
    80004c9a:	3c0080e7          	jalr	960(ra) # 80001056 <walkaddr>
    80004c9e:	862a                	mv	a2,a0
    if(pa == 0)
    80004ca0:	dd4d                	beqz	a0,80004c5a <exec+0xf4>
    if(sz - i < PGSIZE)
    80004ca2:	412984bb          	subw	s1,s3,s2
    80004ca6:	0004879b          	sext.w	a5,s1
    80004caa:	fcfcf0e3          	bgeu	s9,a5,80004c6a <exec+0x104>
    80004cae:	84d6                	mv	s1,s5
    80004cb0:	bf6d                	j	80004c6a <exec+0x104>
    if((sz1 = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz, flags2perm(ph.flags))) == 0)
    80004cb2:	e0843903          	ld	s2,-504(s0)
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80004cb6:	2d85                	addiw	s11,s11,1
    80004cb8:	038d0d1b          	addiw	s10,s10,56
    80004cbc:	e8845783          	lhu	a5,-376(s0)
    80004cc0:	08fdd763          	bge	s11,a5,80004d4e <exec+0x1e8>
    if(readi(ip, 0, (uint64)&ph, off, sizeof(ph)) != sizeof(ph))
    80004cc4:	2d01                	sext.w	s10,s10
    80004cc6:	03800713          	li	a4,56
    80004cca:	86ea                	mv	a3,s10
    80004ccc:	e1840613          	addi	a2,s0,-488
    80004cd0:	4581                	li	a1,0
    80004cd2:	8552                	mv	a0,s4
    80004cd4:	fffff097          	auipc	ra,0xfffff
    80004cd8:	c66080e7          	jalr	-922(ra) # 8000393a <readi>
    80004cdc:	03800793          	li	a5,56
    80004ce0:	1ef51663          	bne	a0,a5,80004ecc <exec+0x366>
    if(ph.type != ELF_PROG_LOAD)
    80004ce4:	e1842783          	lw	a5,-488(s0)
    80004ce8:	4705                	li	a4,1
    80004cea:	fce796e3          	bne	a5,a4,80004cb6 <exec+0x150>
    if(ph.memsz < ph.filesz)
    80004cee:	e4043483          	ld	s1,-448(s0)
    80004cf2:	e3843783          	ld	a5,-456(s0)
    80004cf6:	1ef4e863          	bltu	s1,a5,80004ee6 <exec+0x380>
    if(ph.vaddr + ph.memsz < ph.vaddr)
    80004cfa:	e2843783          	ld	a5,-472(s0)
    80004cfe:	94be                	add	s1,s1,a5
    80004d00:	1ef4e663          	bltu	s1,a5,80004eec <exec+0x386>
    if(ph.vaddr % PGSIZE != 0)
    80004d04:	df043703          	ld	a4,-528(s0)
    80004d08:	8ff9                	and	a5,a5,a4
    80004d0a:	1e079463          	bnez	a5,80004ef2 <exec+0x38c>
    if((sz1 = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz, flags2perm(ph.flags))) == 0)
    80004d0e:	e1c42503          	lw	a0,-484(s0)
    80004d12:	00000097          	auipc	ra,0x0
    80004d16:	e3a080e7          	jalr	-454(ra) # 80004b4c <flags2perm>
    80004d1a:	86aa                	mv	a3,a0
    80004d1c:	8626                	mv	a2,s1
    80004d1e:	85ca                	mv	a1,s2
    80004d20:	855a                	mv	a0,s6
    80004d22:	ffffc097          	auipc	ra,0xffffc
    80004d26:	6e8080e7          	jalr	1768(ra) # 8000140a <uvmalloc>
    80004d2a:	e0a43423          	sd	a0,-504(s0)
    80004d2e:	1c050563          	beqz	a0,80004ef8 <exec+0x392>
    if(loadseg(pagetable, ph.vaddr, ip, ph.off, ph.filesz) < 0)
    80004d32:	e2843b83          	ld	s7,-472(s0)
    80004d36:	e2042c03          	lw	s8,-480(s0)
    80004d3a:	e3842983          	lw	s3,-456(s0)
  for(i = 0; i < sz; i += PGSIZE){
    80004d3e:	00098463          	beqz	s3,80004d46 <exec+0x1e0>
    80004d42:	4901                	li	s2,0
    80004d44:	b7a1                	j	80004c8c <exec+0x126>
    if((sz1 = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz, flags2perm(ph.flags))) == 0)
    80004d46:	e0843903          	ld	s2,-504(s0)
    80004d4a:	b7b5                	j	80004cb6 <exec+0x150>
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
    80004d4c:	4901                	li	s2,0
  iunlockput(ip);
    80004d4e:	8552                	mv	a0,s4
    80004d50:	fffff097          	auipc	ra,0xfffff
    80004d54:	b98080e7          	jalr	-1128(ra) # 800038e8 <iunlockput>
  end_op();
    80004d58:	fffff097          	auipc	ra,0xfffff
    80004d5c:	34e080e7          	jalr	846(ra) # 800040a6 <end_op>
  p = myproc();
    80004d60:	ffffd097          	auipc	ra,0xffffd
    80004d64:	c46080e7          	jalr	-954(ra) # 800019a6 <myproc>
    80004d68:	8aaa                	mv	s5,a0
  uint64 oldsz = p->sz;
    80004d6a:	04853c83          	ld	s9,72(a0)
  sz = PGROUNDUP(sz);
    80004d6e:	6985                	lui	s3,0x1
    80004d70:	19fd                	addi	s3,s3,-1 # fff <_entry-0x7ffff001>
    80004d72:	99ca                	add	s3,s3,s2
    80004d74:	77fd                	lui	a5,0xfffff
    80004d76:	00f9f9b3          	and	s3,s3,a5
  if((sz1 = uvmalloc(pagetable, sz, sz + 2*PGSIZE, PTE_W)) == 0)
    80004d7a:	4691                	li	a3,4
    80004d7c:	6609                	lui	a2,0x2
    80004d7e:	964e                	add	a2,a2,s3
    80004d80:	85ce                	mv	a1,s3
    80004d82:	855a                	mv	a0,s6
    80004d84:	ffffc097          	auipc	ra,0xffffc
    80004d88:	686080e7          	jalr	1670(ra) # 8000140a <uvmalloc>
    80004d8c:	892a                	mv	s2,a0
    80004d8e:	e0a43423          	sd	a0,-504(s0)
    80004d92:	e509                	bnez	a0,80004d9c <exec+0x236>
  if(pagetable)
    80004d94:	e1343423          	sd	s3,-504(s0)
    80004d98:	4a01                	li	s4,0
    80004d9a:	aa1d                	j	80004ed0 <exec+0x36a>
  uvmclear(pagetable, sz-2*PGSIZE);
    80004d9c:	75f9                	lui	a1,0xffffe
    80004d9e:	95aa                	add	a1,a1,a0
    80004da0:	855a                	mv	a0,s6
    80004da2:	ffffd097          	auipc	ra,0xffffd
    80004da6:	892080e7          	jalr	-1902(ra) # 80001634 <uvmclear>
  stackbase = sp - PGSIZE;
    80004daa:	7bfd                	lui	s7,0xfffff
    80004dac:	9bca                	add	s7,s7,s2
  for(argc = 0; argv[argc]; argc++) {
    80004dae:	e0043783          	ld	a5,-512(s0)
    80004db2:	6388                	ld	a0,0(a5)
    80004db4:	c52d                	beqz	a0,80004e1e <exec+0x2b8>
    80004db6:	e9040993          	addi	s3,s0,-368
    80004dba:	f9040c13          	addi	s8,s0,-112
    80004dbe:	4481                	li	s1,0
    sp -= strlen(argv[argc]) + 1;
    80004dc0:	ffffc097          	auipc	ra,0xffffc
    80004dc4:	088080e7          	jalr	136(ra) # 80000e48 <strlen>
    80004dc8:	0015079b          	addiw	a5,a0,1
    80004dcc:	40f907b3          	sub	a5,s2,a5
    sp -= sp % 16; // riscv sp must be 16-byte aligned
    80004dd0:	ff07f913          	andi	s2,a5,-16
    if(sp < stackbase)
    80004dd4:	13796563          	bltu	s2,s7,80004efe <exec+0x398>
    if(copyout(pagetable, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
    80004dd8:	e0043d03          	ld	s10,-512(s0)
    80004ddc:	000d3a03          	ld	s4,0(s10)
    80004de0:	8552                	mv	a0,s4
    80004de2:	ffffc097          	auipc	ra,0xffffc
    80004de6:	066080e7          	jalr	102(ra) # 80000e48 <strlen>
    80004dea:	0015069b          	addiw	a3,a0,1
    80004dee:	8652                	mv	a2,s4
    80004df0:	85ca                	mv	a1,s2
    80004df2:	855a                	mv	a0,s6
    80004df4:	ffffd097          	auipc	ra,0xffffd
    80004df8:	872080e7          	jalr	-1934(ra) # 80001666 <copyout>
    80004dfc:	10054363          	bltz	a0,80004f02 <exec+0x39c>
    ustack[argc] = sp;
    80004e00:	0129b023          	sd	s2,0(s3)
  for(argc = 0; argv[argc]; argc++) {
    80004e04:	0485                	addi	s1,s1,1
    80004e06:	008d0793          	addi	a5,s10,8
    80004e0a:	e0f43023          	sd	a5,-512(s0)
    80004e0e:	008d3503          	ld	a0,8(s10)
    80004e12:	c909                	beqz	a0,80004e24 <exec+0x2be>
    if(argc >= MAXARG)
    80004e14:	09a1                	addi	s3,s3,8
    80004e16:	fb8995e3          	bne	s3,s8,80004dc0 <exec+0x25a>
  ip = 0;
    80004e1a:	4a01                	li	s4,0
    80004e1c:	a855                	j	80004ed0 <exec+0x36a>
  sp = sz;
    80004e1e:	e0843903          	ld	s2,-504(s0)
  for(argc = 0; argv[argc]; argc++) {
    80004e22:	4481                	li	s1,0
  ustack[argc] = 0;
    80004e24:	00349793          	slli	a5,s1,0x3
    80004e28:	f9078793          	addi	a5,a5,-112 # ffffffffffffef90 <end+0xffffffff7ffdd240>
    80004e2c:	97a2                	add	a5,a5,s0
    80004e2e:	f007b023          	sd	zero,-256(a5)
  sp -= (argc+1) * sizeof(uint64);
    80004e32:	00148693          	addi	a3,s1,1
    80004e36:	068e                	slli	a3,a3,0x3
    80004e38:	40d90933          	sub	s2,s2,a3
  sp -= sp % 16;
    80004e3c:	ff097913          	andi	s2,s2,-16
  sz = sz1;
    80004e40:	e0843983          	ld	s3,-504(s0)
  if(sp < stackbase)
    80004e44:	f57968e3          	bltu	s2,s7,80004d94 <exec+0x22e>
  if(copyout(pagetable, sp, (char *)ustack, (argc+1)*sizeof(uint64)) < 0)
    80004e48:	e9040613          	addi	a2,s0,-368
    80004e4c:	85ca                	mv	a1,s2
    80004e4e:	855a                	mv	a0,s6
    80004e50:	ffffd097          	auipc	ra,0xffffd
    80004e54:	816080e7          	jalr	-2026(ra) # 80001666 <copyout>
    80004e58:	0a054763          	bltz	a0,80004f06 <exec+0x3a0>
  p->trapframe->a1 = sp;
    80004e5c:	058ab783          	ld	a5,88(s5) # 1058 <_entry-0x7fffefa8>
    80004e60:	0727bc23          	sd	s2,120(a5)
  for(last=s=path; *s; s++)
    80004e64:	df843783          	ld	a5,-520(s0)
    80004e68:	0007c703          	lbu	a4,0(a5)
    80004e6c:	cf11                	beqz	a4,80004e88 <exec+0x322>
    80004e6e:	0785                	addi	a5,a5,1
    if(*s == '/')
    80004e70:	02f00693          	li	a3,47
    80004e74:	a039                	j	80004e82 <exec+0x31c>
      last = s+1;
    80004e76:	def43c23          	sd	a5,-520(s0)
  for(last=s=path; *s; s++)
    80004e7a:	0785                	addi	a5,a5,1
    80004e7c:	fff7c703          	lbu	a4,-1(a5)
    80004e80:	c701                	beqz	a4,80004e88 <exec+0x322>
    if(*s == '/')
    80004e82:	fed71ce3          	bne	a4,a3,80004e7a <exec+0x314>
    80004e86:	bfc5                	j	80004e76 <exec+0x310>
  safestrcpy(p->name, last, sizeof(p->name));
    80004e88:	4641                	li	a2,16
    80004e8a:	df843583          	ld	a1,-520(s0)
    80004e8e:	158a8513          	addi	a0,s5,344
    80004e92:	ffffc097          	auipc	ra,0xffffc
    80004e96:	f84080e7          	jalr	-124(ra) # 80000e16 <safestrcpy>
  oldpagetable = p->pagetable;
    80004e9a:	050ab503          	ld	a0,80(s5)
  p->pagetable = pagetable;
    80004e9e:	056ab823          	sd	s6,80(s5)
  p->sz = sz;
    80004ea2:	e0843783          	ld	a5,-504(s0)
    80004ea6:	04fab423          	sd	a5,72(s5)
  p->trapframe->epc = elf.entry;  // initial program counter = main
    80004eaa:	058ab783          	ld	a5,88(s5)
    80004eae:	e6843703          	ld	a4,-408(s0)
    80004eb2:	ef98                	sd	a4,24(a5)
  p->trapframe->sp = sp; // initial stack pointer
    80004eb4:	058ab783          	ld	a5,88(s5)
    80004eb8:	0327b823          	sd	s2,48(a5)
  proc_freepagetable(oldpagetable, oldsz);
    80004ebc:	85e6                	mv	a1,s9
    80004ebe:	ffffd097          	auipc	ra,0xffffd
    80004ec2:	c94080e7          	jalr	-876(ra) # 80001b52 <proc_freepagetable>
  return argc; // this ends up in a0, the first argument to main(argc, argv)
    80004ec6:	0004851b          	sext.w	a0,s1
    80004eca:	bb15                	j	80004bfe <exec+0x98>
    80004ecc:	e1243423          	sd	s2,-504(s0)
    proc_freepagetable(pagetable, sz);
    80004ed0:	e0843583          	ld	a1,-504(s0)
    80004ed4:	855a                	mv	a0,s6
    80004ed6:	ffffd097          	auipc	ra,0xffffd
    80004eda:	c7c080e7          	jalr	-900(ra) # 80001b52 <proc_freepagetable>
  return -1;
    80004ede:	557d                	li	a0,-1
  if(ip){
    80004ee0:	d00a0fe3          	beqz	s4,80004bfe <exec+0x98>
    80004ee4:	b319                	j	80004bea <exec+0x84>
    80004ee6:	e1243423          	sd	s2,-504(s0)
    80004eea:	b7dd                	j	80004ed0 <exec+0x36a>
    80004eec:	e1243423          	sd	s2,-504(s0)
    80004ef0:	b7c5                	j	80004ed0 <exec+0x36a>
    80004ef2:	e1243423          	sd	s2,-504(s0)
    80004ef6:	bfe9                	j	80004ed0 <exec+0x36a>
    80004ef8:	e1243423          	sd	s2,-504(s0)
    80004efc:	bfd1                	j	80004ed0 <exec+0x36a>
  ip = 0;
    80004efe:	4a01                	li	s4,0
    80004f00:	bfc1                	j	80004ed0 <exec+0x36a>
    80004f02:	4a01                	li	s4,0
  if(pagetable)
    80004f04:	b7f1                	j	80004ed0 <exec+0x36a>
  sz = sz1;
    80004f06:	e0843983          	ld	s3,-504(s0)
    80004f0a:	b569                	j	80004d94 <exec+0x22e>

0000000080004f0c <argfd>:

// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.
static int
argfd(int n, int *pfd, struct file **pf)
{
    80004f0c:	7179                	addi	sp,sp,-48
    80004f0e:	f406                	sd	ra,40(sp)
    80004f10:	f022                	sd	s0,32(sp)
    80004f12:	ec26                	sd	s1,24(sp)
    80004f14:	e84a                	sd	s2,16(sp)
    80004f16:	1800                	addi	s0,sp,48
    80004f18:	892e                	mv	s2,a1
    80004f1a:	84b2                	mv	s1,a2
  int fd;
  struct file *f;

  argint(n, &fd);
    80004f1c:	fdc40593          	addi	a1,s0,-36
    80004f20:	ffffe097          	auipc	ra,0xffffe
    80004f24:	bec080e7          	jalr	-1044(ra) # 80002b0c <argint>
  if(fd < 0 || fd >= NOFILE || (f=myproc()->ofile[fd]) == 0)
    80004f28:	fdc42703          	lw	a4,-36(s0)
    80004f2c:	47bd                	li	a5,15
    80004f2e:	02e7eb63          	bltu	a5,a4,80004f64 <argfd+0x58>
    80004f32:	ffffd097          	auipc	ra,0xffffd
    80004f36:	a74080e7          	jalr	-1420(ra) # 800019a6 <myproc>
    80004f3a:	fdc42703          	lw	a4,-36(s0)
    80004f3e:	01a70793          	addi	a5,a4,26
    80004f42:	078e                	slli	a5,a5,0x3
    80004f44:	953e                	add	a0,a0,a5
    80004f46:	611c                	ld	a5,0(a0)
    80004f48:	c385                	beqz	a5,80004f68 <argfd+0x5c>
    return -1;
  if(pfd)
    80004f4a:	00090463          	beqz	s2,80004f52 <argfd+0x46>
    *pfd = fd;
    80004f4e:	00e92023          	sw	a4,0(s2)
  if(pf)
    *pf = f;
  return 0;
    80004f52:	4501                	li	a0,0
  if(pf)
    80004f54:	c091                	beqz	s1,80004f58 <argfd+0x4c>
    *pf = f;
    80004f56:	e09c                	sd	a5,0(s1)
}
    80004f58:	70a2                	ld	ra,40(sp)
    80004f5a:	7402                	ld	s0,32(sp)
    80004f5c:	64e2                	ld	s1,24(sp)
    80004f5e:	6942                	ld	s2,16(sp)
    80004f60:	6145                	addi	sp,sp,48
    80004f62:	8082                	ret
    return -1;
    80004f64:	557d                	li	a0,-1
    80004f66:	bfcd                	j	80004f58 <argfd+0x4c>
    80004f68:	557d                	li	a0,-1
    80004f6a:	b7fd                	j	80004f58 <argfd+0x4c>

0000000080004f6c <fdalloc>:

// Allocate a file descriptor for the given file.
// Takes over file reference from caller on success.
static int
fdalloc(struct file *f)
{
    80004f6c:	1101                	addi	sp,sp,-32
    80004f6e:	ec06                	sd	ra,24(sp)
    80004f70:	e822                	sd	s0,16(sp)
    80004f72:	e426                	sd	s1,8(sp)
    80004f74:	1000                	addi	s0,sp,32
    80004f76:	84aa                	mv	s1,a0
  int fd;
  struct proc *p = myproc();
    80004f78:	ffffd097          	auipc	ra,0xffffd
    80004f7c:	a2e080e7          	jalr	-1490(ra) # 800019a6 <myproc>
    80004f80:	862a                	mv	a2,a0

  for(fd = 0; fd < NOFILE; fd++){
    80004f82:	0d050793          	addi	a5,a0,208
    80004f86:	4501                	li	a0,0
    80004f88:	46c1                	li	a3,16
    if(p->ofile[fd] == 0){
    80004f8a:	6398                	ld	a4,0(a5)
    80004f8c:	cb19                	beqz	a4,80004fa2 <fdalloc+0x36>
  for(fd = 0; fd < NOFILE; fd++){
    80004f8e:	2505                	addiw	a0,a0,1
    80004f90:	07a1                	addi	a5,a5,8
    80004f92:	fed51ce3          	bne	a0,a3,80004f8a <fdalloc+0x1e>
      p->ofile[fd] = f;
      return fd;
    }
  }
  return -1;
    80004f96:	557d                	li	a0,-1
}
    80004f98:	60e2                	ld	ra,24(sp)
    80004f9a:	6442                	ld	s0,16(sp)
    80004f9c:	64a2                	ld	s1,8(sp)
    80004f9e:	6105                	addi	sp,sp,32
    80004fa0:	8082                	ret
      p->ofile[fd] = f;
    80004fa2:	01a50793          	addi	a5,a0,26
    80004fa6:	078e                	slli	a5,a5,0x3
    80004fa8:	963e                	add	a2,a2,a5
    80004faa:	e204                	sd	s1,0(a2)
      return fd;
    80004fac:	b7f5                	j	80004f98 <fdalloc+0x2c>

0000000080004fae <create>:
  return -1;
}

static struct inode*
create(char *path, short type, short major, short minor)
{
    80004fae:	715d                	addi	sp,sp,-80
    80004fb0:	e486                	sd	ra,72(sp)
    80004fb2:	e0a2                	sd	s0,64(sp)
    80004fb4:	fc26                	sd	s1,56(sp)
    80004fb6:	f84a                	sd	s2,48(sp)
    80004fb8:	f44e                	sd	s3,40(sp)
    80004fba:	f052                	sd	s4,32(sp)
    80004fbc:	ec56                	sd	s5,24(sp)
    80004fbe:	e85a                	sd	s6,16(sp)
    80004fc0:	0880                	addi	s0,sp,80
    80004fc2:	8b2e                	mv	s6,a1
    80004fc4:	89b2                	mv	s3,a2
    80004fc6:	8936                	mv	s2,a3
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if((dp = nameiparent(path, name)) == 0)
    80004fc8:	fb040593          	addi	a1,s0,-80
    80004fcc:	fffff097          	auipc	ra,0xfffff
    80004fd0:	e7e080e7          	jalr	-386(ra) # 80003e4a <nameiparent>
    80004fd4:	84aa                	mv	s1,a0
    80004fd6:	14050b63          	beqz	a0,8000512c <create+0x17e>
    return 0;

  ilock(dp);
    80004fda:	ffffe097          	auipc	ra,0xffffe
    80004fde:	6ac080e7          	jalr	1708(ra) # 80003686 <ilock>

  if((ip = dirlookup(dp, name, 0)) != 0){
    80004fe2:	4601                	li	a2,0
    80004fe4:	fb040593          	addi	a1,s0,-80
    80004fe8:	8526                	mv	a0,s1
    80004fea:	fffff097          	auipc	ra,0xfffff
    80004fee:	b80080e7          	jalr	-1152(ra) # 80003b6a <dirlookup>
    80004ff2:	8aaa                	mv	s5,a0
    80004ff4:	c921                	beqz	a0,80005044 <create+0x96>
    iunlockput(dp);
    80004ff6:	8526                	mv	a0,s1
    80004ff8:	fffff097          	auipc	ra,0xfffff
    80004ffc:	8f0080e7          	jalr	-1808(ra) # 800038e8 <iunlockput>
    ilock(ip);
    80005000:	8556                	mv	a0,s5
    80005002:	ffffe097          	auipc	ra,0xffffe
    80005006:	684080e7          	jalr	1668(ra) # 80003686 <ilock>
    if(type == T_FILE && (ip->type == T_FILE || ip->type == T_DEVICE))
    8000500a:	4789                	li	a5,2
    8000500c:	02fb1563          	bne	s6,a5,80005036 <create+0x88>
    80005010:	044ad783          	lhu	a5,68(s5)
    80005014:	37f9                	addiw	a5,a5,-2
    80005016:	17c2                	slli	a5,a5,0x30
    80005018:	93c1                	srli	a5,a5,0x30
    8000501a:	4705                	li	a4,1
    8000501c:	00f76d63          	bltu	a4,a5,80005036 <create+0x88>
  ip->nlink = 0;
  iupdate(ip);
  iunlockput(ip);
  iunlockput(dp);
  return 0;
}
    80005020:	8556                	mv	a0,s5
    80005022:	60a6                	ld	ra,72(sp)
    80005024:	6406                	ld	s0,64(sp)
    80005026:	74e2                	ld	s1,56(sp)
    80005028:	7942                	ld	s2,48(sp)
    8000502a:	79a2                	ld	s3,40(sp)
    8000502c:	7a02                	ld	s4,32(sp)
    8000502e:	6ae2                	ld	s5,24(sp)
    80005030:	6b42                	ld	s6,16(sp)
    80005032:	6161                	addi	sp,sp,80
    80005034:	8082                	ret
    iunlockput(ip);
    80005036:	8556                	mv	a0,s5
    80005038:	fffff097          	auipc	ra,0xfffff
    8000503c:	8b0080e7          	jalr	-1872(ra) # 800038e8 <iunlockput>
    return 0;
    80005040:	4a81                	li	s5,0
    80005042:	bff9                	j	80005020 <create+0x72>
  if((ip = ialloc(dp->dev, type)) == 0){
    80005044:	85da                	mv	a1,s6
    80005046:	4088                	lw	a0,0(s1)
    80005048:	ffffe097          	auipc	ra,0xffffe
    8000504c:	4a6080e7          	jalr	1190(ra) # 800034ee <ialloc>
    80005050:	8a2a                	mv	s4,a0
    80005052:	c529                	beqz	a0,8000509c <create+0xee>
  ilock(ip);
    80005054:	ffffe097          	auipc	ra,0xffffe
    80005058:	632080e7          	jalr	1586(ra) # 80003686 <ilock>
  ip->major = major;
    8000505c:	053a1323          	sh	s3,70(s4)
  ip->minor = minor;
    80005060:	052a1423          	sh	s2,72(s4)
  ip->nlink = 1;
    80005064:	4905                	li	s2,1
    80005066:	052a1523          	sh	s2,74(s4)
  iupdate(ip);
    8000506a:	8552                	mv	a0,s4
    8000506c:	ffffe097          	auipc	ra,0xffffe
    80005070:	54e080e7          	jalr	1358(ra) # 800035ba <iupdate>
  if(type == T_DIR){  // Create . and .. entries.
    80005074:	032b0b63          	beq	s6,s2,800050aa <create+0xfc>
  if(dirlink(dp, name, ip->inum) < 0)
    80005078:	004a2603          	lw	a2,4(s4)
    8000507c:	fb040593          	addi	a1,s0,-80
    80005080:	8526                	mv	a0,s1
    80005082:	fffff097          	auipc	ra,0xfffff
    80005086:	cf8080e7          	jalr	-776(ra) # 80003d7a <dirlink>
    8000508a:	06054f63          	bltz	a0,80005108 <create+0x15a>
  iunlockput(dp);
    8000508e:	8526                	mv	a0,s1
    80005090:	fffff097          	auipc	ra,0xfffff
    80005094:	858080e7          	jalr	-1960(ra) # 800038e8 <iunlockput>
  return ip;
    80005098:	8ad2                	mv	s5,s4
    8000509a:	b759                	j	80005020 <create+0x72>
    iunlockput(dp);
    8000509c:	8526                	mv	a0,s1
    8000509e:	fffff097          	auipc	ra,0xfffff
    800050a2:	84a080e7          	jalr	-1974(ra) # 800038e8 <iunlockput>
    return 0;
    800050a6:	8ad2                	mv	s5,s4
    800050a8:	bfa5                	j	80005020 <create+0x72>
    if(dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
    800050aa:	004a2603          	lw	a2,4(s4)
    800050ae:	00003597          	auipc	a1,0x3
    800050b2:	64a58593          	addi	a1,a1,1610 # 800086f8 <syscalls+0x2a8>
    800050b6:	8552                	mv	a0,s4
    800050b8:	fffff097          	auipc	ra,0xfffff
    800050bc:	cc2080e7          	jalr	-830(ra) # 80003d7a <dirlink>
    800050c0:	04054463          	bltz	a0,80005108 <create+0x15a>
    800050c4:	40d0                	lw	a2,4(s1)
    800050c6:	00003597          	auipc	a1,0x3
    800050ca:	63a58593          	addi	a1,a1,1594 # 80008700 <syscalls+0x2b0>
    800050ce:	8552                	mv	a0,s4
    800050d0:	fffff097          	auipc	ra,0xfffff
    800050d4:	caa080e7          	jalr	-854(ra) # 80003d7a <dirlink>
    800050d8:	02054863          	bltz	a0,80005108 <create+0x15a>
  if(dirlink(dp, name, ip->inum) < 0)
    800050dc:	004a2603          	lw	a2,4(s4)
    800050e0:	fb040593          	addi	a1,s0,-80
    800050e4:	8526                	mv	a0,s1
    800050e6:	fffff097          	auipc	ra,0xfffff
    800050ea:	c94080e7          	jalr	-876(ra) # 80003d7a <dirlink>
    800050ee:	00054d63          	bltz	a0,80005108 <create+0x15a>
    dp->nlink++;  // for ".."
    800050f2:	04a4d783          	lhu	a5,74(s1)
    800050f6:	2785                	addiw	a5,a5,1
    800050f8:	04f49523          	sh	a5,74(s1)
    iupdate(dp);
    800050fc:	8526                	mv	a0,s1
    800050fe:	ffffe097          	auipc	ra,0xffffe
    80005102:	4bc080e7          	jalr	1212(ra) # 800035ba <iupdate>
    80005106:	b761                	j	8000508e <create+0xe0>
  ip->nlink = 0;
    80005108:	040a1523          	sh	zero,74(s4)
  iupdate(ip);
    8000510c:	8552                	mv	a0,s4
    8000510e:	ffffe097          	auipc	ra,0xffffe
    80005112:	4ac080e7          	jalr	1196(ra) # 800035ba <iupdate>
  iunlockput(ip);
    80005116:	8552                	mv	a0,s4
    80005118:	ffffe097          	auipc	ra,0xffffe
    8000511c:	7d0080e7          	jalr	2000(ra) # 800038e8 <iunlockput>
  iunlockput(dp);
    80005120:	8526                	mv	a0,s1
    80005122:	ffffe097          	auipc	ra,0xffffe
    80005126:	7c6080e7          	jalr	1990(ra) # 800038e8 <iunlockput>
  return 0;
    8000512a:	bddd                	j	80005020 <create+0x72>
    return 0;
    8000512c:	8aaa                	mv	s5,a0
    8000512e:	bdcd                	j	80005020 <create+0x72>

0000000080005130 <sys_dup>:
{
    80005130:	7179                	addi	sp,sp,-48
    80005132:	f406                	sd	ra,40(sp)
    80005134:	f022                	sd	s0,32(sp)
    80005136:	ec26                	sd	s1,24(sp)
    80005138:	e84a                	sd	s2,16(sp)
    8000513a:	1800                	addi	s0,sp,48
  if(argfd(0, 0, &f) < 0)
    8000513c:	fd840613          	addi	a2,s0,-40
    80005140:	4581                	li	a1,0
    80005142:	4501                	li	a0,0
    80005144:	00000097          	auipc	ra,0x0
    80005148:	dc8080e7          	jalr	-568(ra) # 80004f0c <argfd>
    return -1;
    8000514c:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0)
    8000514e:	02054363          	bltz	a0,80005174 <sys_dup+0x44>
  if((fd=fdalloc(f)) < 0)
    80005152:	fd843903          	ld	s2,-40(s0)
    80005156:	854a                	mv	a0,s2
    80005158:	00000097          	auipc	ra,0x0
    8000515c:	e14080e7          	jalr	-492(ra) # 80004f6c <fdalloc>
    80005160:	84aa                	mv	s1,a0
    return -1;
    80005162:	57fd                	li	a5,-1
  if((fd=fdalloc(f)) < 0)
    80005164:	00054863          	bltz	a0,80005174 <sys_dup+0x44>
  filedup(f);
    80005168:	854a                	mv	a0,s2
    8000516a:	fffff097          	auipc	ra,0xfffff
    8000516e:	334080e7          	jalr	820(ra) # 8000449e <filedup>
  return fd;
    80005172:	87a6                	mv	a5,s1
}
    80005174:	853e                	mv	a0,a5
    80005176:	70a2                	ld	ra,40(sp)
    80005178:	7402                	ld	s0,32(sp)
    8000517a:	64e2                	ld	s1,24(sp)
    8000517c:	6942                	ld	s2,16(sp)
    8000517e:	6145                	addi	sp,sp,48
    80005180:	8082                	ret

0000000080005182 <sys_read>:
{
    80005182:	7179                	addi	sp,sp,-48
    80005184:	f406                	sd	ra,40(sp)
    80005186:	f022                	sd	s0,32(sp)
    80005188:	1800                	addi	s0,sp,48
  argaddr(1, &p);
    8000518a:	fd840593          	addi	a1,s0,-40
    8000518e:	4505                	li	a0,1
    80005190:	ffffe097          	auipc	ra,0xffffe
    80005194:	99c080e7          	jalr	-1636(ra) # 80002b2c <argaddr>
  argint(2, &n);
    80005198:	fe440593          	addi	a1,s0,-28
    8000519c:	4509                	li	a0,2
    8000519e:	ffffe097          	auipc	ra,0xffffe
    800051a2:	96e080e7          	jalr	-1682(ra) # 80002b0c <argint>
  if(argfd(0, 0, &f) < 0)
    800051a6:	fe840613          	addi	a2,s0,-24
    800051aa:	4581                	li	a1,0
    800051ac:	4501                	li	a0,0
    800051ae:	00000097          	auipc	ra,0x0
    800051b2:	d5e080e7          	jalr	-674(ra) # 80004f0c <argfd>
    800051b6:	87aa                	mv	a5,a0
    return -1;
    800051b8:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    800051ba:	0007cc63          	bltz	a5,800051d2 <sys_read+0x50>
  return fileread(f, p, n);
    800051be:	fe442603          	lw	a2,-28(s0)
    800051c2:	fd843583          	ld	a1,-40(s0)
    800051c6:	fe843503          	ld	a0,-24(s0)
    800051ca:	fffff097          	auipc	ra,0xfffff
    800051ce:	460080e7          	jalr	1120(ra) # 8000462a <fileread>
}
    800051d2:	70a2                	ld	ra,40(sp)
    800051d4:	7402                	ld	s0,32(sp)
    800051d6:	6145                	addi	sp,sp,48
    800051d8:	8082                	ret

00000000800051da <sys_write>:
{
    800051da:	7179                	addi	sp,sp,-48
    800051dc:	f406                	sd	ra,40(sp)
    800051de:	f022                	sd	s0,32(sp)
    800051e0:	1800                	addi	s0,sp,48
  argaddr(1, &p);
    800051e2:	fd840593          	addi	a1,s0,-40
    800051e6:	4505                	li	a0,1
    800051e8:	ffffe097          	auipc	ra,0xffffe
    800051ec:	944080e7          	jalr	-1724(ra) # 80002b2c <argaddr>
  argint(2, &n);
    800051f0:	fe440593          	addi	a1,s0,-28
    800051f4:	4509                	li	a0,2
    800051f6:	ffffe097          	auipc	ra,0xffffe
    800051fa:	916080e7          	jalr	-1770(ra) # 80002b0c <argint>
  if(argfd(0, 0, &f) < 0)
    800051fe:	fe840613          	addi	a2,s0,-24
    80005202:	4581                	li	a1,0
    80005204:	4501                	li	a0,0
    80005206:	00000097          	auipc	ra,0x0
    8000520a:	d06080e7          	jalr	-762(ra) # 80004f0c <argfd>
    8000520e:	87aa                	mv	a5,a0
    return -1;
    80005210:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    80005212:	0007cc63          	bltz	a5,8000522a <sys_write+0x50>
  return filewrite(f, p, n);
    80005216:	fe442603          	lw	a2,-28(s0)
    8000521a:	fd843583          	ld	a1,-40(s0)
    8000521e:	fe843503          	ld	a0,-24(s0)
    80005222:	fffff097          	auipc	ra,0xfffff
    80005226:	4ca080e7          	jalr	1226(ra) # 800046ec <filewrite>
}
    8000522a:	70a2                	ld	ra,40(sp)
    8000522c:	7402                	ld	s0,32(sp)
    8000522e:	6145                	addi	sp,sp,48
    80005230:	8082                	ret

0000000080005232 <sys_close>:
{
    80005232:	1101                	addi	sp,sp,-32
    80005234:	ec06                	sd	ra,24(sp)
    80005236:	e822                	sd	s0,16(sp)
    80005238:	1000                	addi	s0,sp,32
  if(argfd(0, &fd, &f) < 0)
    8000523a:	fe040613          	addi	a2,s0,-32
    8000523e:	fec40593          	addi	a1,s0,-20
    80005242:	4501                	li	a0,0
    80005244:	00000097          	auipc	ra,0x0
    80005248:	cc8080e7          	jalr	-824(ra) # 80004f0c <argfd>
    return -1;
    8000524c:	57fd                	li	a5,-1
  if(argfd(0, &fd, &f) < 0)
    8000524e:	02054463          	bltz	a0,80005276 <sys_close+0x44>
  myproc()->ofile[fd] = 0;
    80005252:	ffffc097          	auipc	ra,0xffffc
    80005256:	754080e7          	jalr	1876(ra) # 800019a6 <myproc>
    8000525a:	fec42783          	lw	a5,-20(s0)
    8000525e:	07e9                	addi	a5,a5,26
    80005260:	078e                	slli	a5,a5,0x3
    80005262:	953e                	add	a0,a0,a5
    80005264:	00053023          	sd	zero,0(a0)
  fileclose(f);
    80005268:	fe043503          	ld	a0,-32(s0)
    8000526c:	fffff097          	auipc	ra,0xfffff
    80005270:	284080e7          	jalr	644(ra) # 800044f0 <fileclose>
  return 0;
    80005274:	4781                	li	a5,0
}
    80005276:	853e                	mv	a0,a5
    80005278:	60e2                	ld	ra,24(sp)
    8000527a:	6442                	ld	s0,16(sp)
    8000527c:	6105                	addi	sp,sp,32
    8000527e:	8082                	ret

0000000080005280 <sys_fstat>:
{
    80005280:	1101                	addi	sp,sp,-32
    80005282:	ec06                	sd	ra,24(sp)
    80005284:	e822                	sd	s0,16(sp)
    80005286:	1000                	addi	s0,sp,32
  argaddr(1, &st);
    80005288:	fe040593          	addi	a1,s0,-32
    8000528c:	4505                	li	a0,1
    8000528e:	ffffe097          	auipc	ra,0xffffe
    80005292:	89e080e7          	jalr	-1890(ra) # 80002b2c <argaddr>
  if(argfd(0, 0, &f) < 0)
    80005296:	fe840613          	addi	a2,s0,-24
    8000529a:	4581                	li	a1,0
    8000529c:	4501                	li	a0,0
    8000529e:	00000097          	auipc	ra,0x0
    800052a2:	c6e080e7          	jalr	-914(ra) # 80004f0c <argfd>
    800052a6:	87aa                	mv	a5,a0
    return -1;
    800052a8:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    800052aa:	0007ca63          	bltz	a5,800052be <sys_fstat+0x3e>
  return filestat(f, st);
    800052ae:	fe043583          	ld	a1,-32(s0)
    800052b2:	fe843503          	ld	a0,-24(s0)
    800052b6:	fffff097          	auipc	ra,0xfffff
    800052ba:	302080e7          	jalr	770(ra) # 800045b8 <filestat>
}
    800052be:	60e2                	ld	ra,24(sp)
    800052c0:	6442                	ld	s0,16(sp)
    800052c2:	6105                	addi	sp,sp,32
    800052c4:	8082                	ret

00000000800052c6 <sys_link>:
{
    800052c6:	7169                	addi	sp,sp,-304
    800052c8:	f606                	sd	ra,296(sp)
    800052ca:	f222                	sd	s0,288(sp)
    800052cc:	ee26                	sd	s1,280(sp)
    800052ce:	ea4a                	sd	s2,272(sp)
    800052d0:	1a00                	addi	s0,sp,304
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    800052d2:	08000613          	li	a2,128
    800052d6:	ed040593          	addi	a1,s0,-304
    800052da:	4501                	li	a0,0
    800052dc:	ffffe097          	auipc	ra,0xffffe
    800052e0:	870080e7          	jalr	-1936(ra) # 80002b4c <argstr>
    return -1;
    800052e4:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    800052e6:	10054e63          	bltz	a0,80005402 <sys_link+0x13c>
    800052ea:	08000613          	li	a2,128
    800052ee:	f5040593          	addi	a1,s0,-176
    800052f2:	4505                	li	a0,1
    800052f4:	ffffe097          	auipc	ra,0xffffe
    800052f8:	858080e7          	jalr	-1960(ra) # 80002b4c <argstr>
    return -1;
    800052fc:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    800052fe:	10054263          	bltz	a0,80005402 <sys_link+0x13c>
  begin_op();
    80005302:	fffff097          	auipc	ra,0xfffff
    80005306:	d2a080e7          	jalr	-726(ra) # 8000402c <begin_op>
  if((ip = namei(old)) == 0){
    8000530a:	ed040513          	addi	a0,s0,-304
    8000530e:	fffff097          	auipc	ra,0xfffff
    80005312:	b1e080e7          	jalr	-1250(ra) # 80003e2c <namei>
    80005316:	84aa                	mv	s1,a0
    80005318:	c551                	beqz	a0,800053a4 <sys_link+0xde>
  ilock(ip);
    8000531a:	ffffe097          	auipc	ra,0xffffe
    8000531e:	36c080e7          	jalr	876(ra) # 80003686 <ilock>
  if(ip->type == T_DIR){
    80005322:	04449703          	lh	a4,68(s1)
    80005326:	4785                	li	a5,1
    80005328:	08f70463          	beq	a4,a5,800053b0 <sys_link+0xea>
  ip->nlink++;
    8000532c:	04a4d783          	lhu	a5,74(s1)
    80005330:	2785                	addiw	a5,a5,1
    80005332:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    80005336:	8526                	mv	a0,s1
    80005338:	ffffe097          	auipc	ra,0xffffe
    8000533c:	282080e7          	jalr	642(ra) # 800035ba <iupdate>
  iunlock(ip);
    80005340:	8526                	mv	a0,s1
    80005342:	ffffe097          	auipc	ra,0xffffe
    80005346:	406080e7          	jalr	1030(ra) # 80003748 <iunlock>
  if((dp = nameiparent(new, name)) == 0)
    8000534a:	fd040593          	addi	a1,s0,-48
    8000534e:	f5040513          	addi	a0,s0,-176
    80005352:	fffff097          	auipc	ra,0xfffff
    80005356:	af8080e7          	jalr	-1288(ra) # 80003e4a <nameiparent>
    8000535a:	892a                	mv	s2,a0
    8000535c:	c935                	beqz	a0,800053d0 <sys_link+0x10a>
  ilock(dp);
    8000535e:	ffffe097          	auipc	ra,0xffffe
    80005362:	328080e7          	jalr	808(ra) # 80003686 <ilock>
  if(dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0){
    80005366:	00092703          	lw	a4,0(s2)
    8000536a:	409c                	lw	a5,0(s1)
    8000536c:	04f71d63          	bne	a4,a5,800053c6 <sys_link+0x100>
    80005370:	40d0                	lw	a2,4(s1)
    80005372:	fd040593          	addi	a1,s0,-48
    80005376:	854a                	mv	a0,s2
    80005378:	fffff097          	auipc	ra,0xfffff
    8000537c:	a02080e7          	jalr	-1534(ra) # 80003d7a <dirlink>
    80005380:	04054363          	bltz	a0,800053c6 <sys_link+0x100>
  iunlockput(dp);
    80005384:	854a                	mv	a0,s2
    80005386:	ffffe097          	auipc	ra,0xffffe
    8000538a:	562080e7          	jalr	1378(ra) # 800038e8 <iunlockput>
  iput(ip);
    8000538e:	8526                	mv	a0,s1
    80005390:	ffffe097          	auipc	ra,0xffffe
    80005394:	4b0080e7          	jalr	1200(ra) # 80003840 <iput>
  end_op();
    80005398:	fffff097          	auipc	ra,0xfffff
    8000539c:	d0e080e7          	jalr	-754(ra) # 800040a6 <end_op>
  return 0;
    800053a0:	4781                	li	a5,0
    800053a2:	a085                	j	80005402 <sys_link+0x13c>
    end_op();
    800053a4:	fffff097          	auipc	ra,0xfffff
    800053a8:	d02080e7          	jalr	-766(ra) # 800040a6 <end_op>
    return -1;
    800053ac:	57fd                	li	a5,-1
    800053ae:	a891                	j	80005402 <sys_link+0x13c>
    iunlockput(ip);
    800053b0:	8526                	mv	a0,s1
    800053b2:	ffffe097          	auipc	ra,0xffffe
    800053b6:	536080e7          	jalr	1334(ra) # 800038e8 <iunlockput>
    end_op();
    800053ba:	fffff097          	auipc	ra,0xfffff
    800053be:	cec080e7          	jalr	-788(ra) # 800040a6 <end_op>
    return -1;
    800053c2:	57fd                	li	a5,-1
    800053c4:	a83d                	j	80005402 <sys_link+0x13c>
    iunlockput(dp);
    800053c6:	854a                	mv	a0,s2
    800053c8:	ffffe097          	auipc	ra,0xffffe
    800053cc:	520080e7          	jalr	1312(ra) # 800038e8 <iunlockput>
  ilock(ip);
    800053d0:	8526                	mv	a0,s1
    800053d2:	ffffe097          	auipc	ra,0xffffe
    800053d6:	2b4080e7          	jalr	692(ra) # 80003686 <ilock>
  ip->nlink--;
    800053da:	04a4d783          	lhu	a5,74(s1)
    800053de:	37fd                	addiw	a5,a5,-1
    800053e0:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    800053e4:	8526                	mv	a0,s1
    800053e6:	ffffe097          	auipc	ra,0xffffe
    800053ea:	1d4080e7          	jalr	468(ra) # 800035ba <iupdate>
  iunlockput(ip);
    800053ee:	8526                	mv	a0,s1
    800053f0:	ffffe097          	auipc	ra,0xffffe
    800053f4:	4f8080e7          	jalr	1272(ra) # 800038e8 <iunlockput>
  end_op();
    800053f8:	fffff097          	auipc	ra,0xfffff
    800053fc:	cae080e7          	jalr	-850(ra) # 800040a6 <end_op>
  return -1;
    80005400:	57fd                	li	a5,-1
}
    80005402:	853e                	mv	a0,a5
    80005404:	70b2                	ld	ra,296(sp)
    80005406:	7412                	ld	s0,288(sp)
    80005408:	64f2                	ld	s1,280(sp)
    8000540a:	6952                	ld	s2,272(sp)
    8000540c:	6155                	addi	sp,sp,304
    8000540e:	8082                	ret

0000000080005410 <sys_unlink>:
{
    80005410:	7151                	addi	sp,sp,-240
    80005412:	f586                	sd	ra,232(sp)
    80005414:	f1a2                	sd	s0,224(sp)
    80005416:	eda6                	sd	s1,216(sp)
    80005418:	e9ca                	sd	s2,208(sp)
    8000541a:	e5ce                	sd	s3,200(sp)
    8000541c:	1980                	addi	s0,sp,240
  if(argstr(0, path, MAXPATH) < 0)
    8000541e:	08000613          	li	a2,128
    80005422:	f3040593          	addi	a1,s0,-208
    80005426:	4501                	li	a0,0
    80005428:	ffffd097          	auipc	ra,0xffffd
    8000542c:	724080e7          	jalr	1828(ra) # 80002b4c <argstr>
    80005430:	18054163          	bltz	a0,800055b2 <sys_unlink+0x1a2>
  begin_op();
    80005434:	fffff097          	auipc	ra,0xfffff
    80005438:	bf8080e7          	jalr	-1032(ra) # 8000402c <begin_op>
  if((dp = nameiparent(path, name)) == 0){
    8000543c:	fb040593          	addi	a1,s0,-80
    80005440:	f3040513          	addi	a0,s0,-208
    80005444:	fffff097          	auipc	ra,0xfffff
    80005448:	a06080e7          	jalr	-1530(ra) # 80003e4a <nameiparent>
    8000544c:	84aa                	mv	s1,a0
    8000544e:	c979                	beqz	a0,80005524 <sys_unlink+0x114>
  ilock(dp);
    80005450:	ffffe097          	auipc	ra,0xffffe
    80005454:	236080e7          	jalr	566(ra) # 80003686 <ilock>
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
    80005458:	00003597          	auipc	a1,0x3
    8000545c:	2a058593          	addi	a1,a1,672 # 800086f8 <syscalls+0x2a8>
    80005460:	fb040513          	addi	a0,s0,-80
    80005464:	ffffe097          	auipc	ra,0xffffe
    80005468:	6ec080e7          	jalr	1772(ra) # 80003b50 <namecmp>
    8000546c:	14050a63          	beqz	a0,800055c0 <sys_unlink+0x1b0>
    80005470:	00003597          	auipc	a1,0x3
    80005474:	29058593          	addi	a1,a1,656 # 80008700 <syscalls+0x2b0>
    80005478:	fb040513          	addi	a0,s0,-80
    8000547c:	ffffe097          	auipc	ra,0xffffe
    80005480:	6d4080e7          	jalr	1748(ra) # 80003b50 <namecmp>
    80005484:	12050e63          	beqz	a0,800055c0 <sys_unlink+0x1b0>
  if((ip = dirlookup(dp, name, &off)) == 0)
    80005488:	f2c40613          	addi	a2,s0,-212
    8000548c:	fb040593          	addi	a1,s0,-80
    80005490:	8526                	mv	a0,s1
    80005492:	ffffe097          	auipc	ra,0xffffe
    80005496:	6d8080e7          	jalr	1752(ra) # 80003b6a <dirlookup>
    8000549a:	892a                	mv	s2,a0
    8000549c:	12050263          	beqz	a0,800055c0 <sys_unlink+0x1b0>
  ilock(ip);
    800054a0:	ffffe097          	auipc	ra,0xffffe
    800054a4:	1e6080e7          	jalr	486(ra) # 80003686 <ilock>
  if(ip->nlink < 1)
    800054a8:	04a91783          	lh	a5,74(s2)
    800054ac:	08f05263          	blez	a5,80005530 <sys_unlink+0x120>
  if(ip->type == T_DIR && !isdirempty(ip)){
    800054b0:	04491703          	lh	a4,68(s2)
    800054b4:	4785                	li	a5,1
    800054b6:	08f70563          	beq	a4,a5,80005540 <sys_unlink+0x130>
  memset(&de, 0, sizeof(de));
    800054ba:	4641                	li	a2,16
    800054bc:	4581                	li	a1,0
    800054be:	fc040513          	addi	a0,s0,-64
    800054c2:	ffffc097          	auipc	ra,0xffffc
    800054c6:	80c080e7          	jalr	-2036(ra) # 80000cce <memset>
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    800054ca:	4741                	li	a4,16
    800054cc:	f2c42683          	lw	a3,-212(s0)
    800054d0:	fc040613          	addi	a2,s0,-64
    800054d4:	4581                	li	a1,0
    800054d6:	8526                	mv	a0,s1
    800054d8:	ffffe097          	auipc	ra,0xffffe
    800054dc:	55a080e7          	jalr	1370(ra) # 80003a32 <writei>
    800054e0:	47c1                	li	a5,16
    800054e2:	0af51563          	bne	a0,a5,8000558c <sys_unlink+0x17c>
  if(ip->type == T_DIR){
    800054e6:	04491703          	lh	a4,68(s2)
    800054ea:	4785                	li	a5,1
    800054ec:	0af70863          	beq	a4,a5,8000559c <sys_unlink+0x18c>
  iunlockput(dp);
    800054f0:	8526                	mv	a0,s1
    800054f2:	ffffe097          	auipc	ra,0xffffe
    800054f6:	3f6080e7          	jalr	1014(ra) # 800038e8 <iunlockput>
  ip->nlink--;
    800054fa:	04a95783          	lhu	a5,74(s2)
    800054fe:	37fd                	addiw	a5,a5,-1
    80005500:	04f91523          	sh	a5,74(s2)
  iupdate(ip);
    80005504:	854a                	mv	a0,s2
    80005506:	ffffe097          	auipc	ra,0xffffe
    8000550a:	0b4080e7          	jalr	180(ra) # 800035ba <iupdate>
  iunlockput(ip);
    8000550e:	854a                	mv	a0,s2
    80005510:	ffffe097          	auipc	ra,0xffffe
    80005514:	3d8080e7          	jalr	984(ra) # 800038e8 <iunlockput>
  end_op();
    80005518:	fffff097          	auipc	ra,0xfffff
    8000551c:	b8e080e7          	jalr	-1138(ra) # 800040a6 <end_op>
  return 0;
    80005520:	4501                	li	a0,0
    80005522:	a84d                	j	800055d4 <sys_unlink+0x1c4>
    end_op();
    80005524:	fffff097          	auipc	ra,0xfffff
    80005528:	b82080e7          	jalr	-1150(ra) # 800040a6 <end_op>
    return -1;
    8000552c:	557d                	li	a0,-1
    8000552e:	a05d                	j	800055d4 <sys_unlink+0x1c4>
    panic("unlink: nlink < 1");
    80005530:	00003517          	auipc	a0,0x3
    80005534:	1d850513          	addi	a0,a0,472 # 80008708 <syscalls+0x2b8>
    80005538:	ffffb097          	auipc	ra,0xffffb
    8000553c:	004080e7          	jalr	4(ra) # 8000053c <panic>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    80005540:	04c92703          	lw	a4,76(s2)
    80005544:	02000793          	li	a5,32
    80005548:	f6e7f9e3          	bgeu	a5,a4,800054ba <sys_unlink+0xaa>
    8000554c:	02000993          	li	s3,32
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80005550:	4741                	li	a4,16
    80005552:	86ce                	mv	a3,s3
    80005554:	f1840613          	addi	a2,s0,-232
    80005558:	4581                	li	a1,0
    8000555a:	854a                	mv	a0,s2
    8000555c:	ffffe097          	auipc	ra,0xffffe
    80005560:	3de080e7          	jalr	990(ra) # 8000393a <readi>
    80005564:	47c1                	li	a5,16
    80005566:	00f51b63          	bne	a0,a5,8000557c <sys_unlink+0x16c>
    if(de.inum != 0)
    8000556a:	f1845783          	lhu	a5,-232(s0)
    8000556e:	e7a1                	bnez	a5,800055b6 <sys_unlink+0x1a6>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    80005570:	29c1                	addiw	s3,s3,16
    80005572:	04c92783          	lw	a5,76(s2)
    80005576:	fcf9ede3          	bltu	s3,a5,80005550 <sys_unlink+0x140>
    8000557a:	b781                	j	800054ba <sys_unlink+0xaa>
      panic("isdirempty: readi");
    8000557c:	00003517          	auipc	a0,0x3
    80005580:	1a450513          	addi	a0,a0,420 # 80008720 <syscalls+0x2d0>
    80005584:	ffffb097          	auipc	ra,0xffffb
    80005588:	fb8080e7          	jalr	-72(ra) # 8000053c <panic>
    panic("unlink: writei");
    8000558c:	00003517          	auipc	a0,0x3
    80005590:	1ac50513          	addi	a0,a0,428 # 80008738 <syscalls+0x2e8>
    80005594:	ffffb097          	auipc	ra,0xffffb
    80005598:	fa8080e7          	jalr	-88(ra) # 8000053c <panic>
    dp->nlink--;
    8000559c:	04a4d783          	lhu	a5,74(s1)
    800055a0:	37fd                	addiw	a5,a5,-1
    800055a2:	04f49523          	sh	a5,74(s1)
    iupdate(dp);
    800055a6:	8526                	mv	a0,s1
    800055a8:	ffffe097          	auipc	ra,0xffffe
    800055ac:	012080e7          	jalr	18(ra) # 800035ba <iupdate>
    800055b0:	b781                	j	800054f0 <sys_unlink+0xe0>
    return -1;
    800055b2:	557d                	li	a0,-1
    800055b4:	a005                	j	800055d4 <sys_unlink+0x1c4>
    iunlockput(ip);
    800055b6:	854a                	mv	a0,s2
    800055b8:	ffffe097          	auipc	ra,0xffffe
    800055bc:	330080e7          	jalr	816(ra) # 800038e8 <iunlockput>
  iunlockput(dp);
    800055c0:	8526                	mv	a0,s1
    800055c2:	ffffe097          	auipc	ra,0xffffe
    800055c6:	326080e7          	jalr	806(ra) # 800038e8 <iunlockput>
  end_op();
    800055ca:	fffff097          	auipc	ra,0xfffff
    800055ce:	adc080e7          	jalr	-1316(ra) # 800040a6 <end_op>
  return -1;
    800055d2:	557d                	li	a0,-1
}
    800055d4:	70ae                	ld	ra,232(sp)
    800055d6:	740e                	ld	s0,224(sp)
    800055d8:	64ee                	ld	s1,216(sp)
    800055da:	694e                	ld	s2,208(sp)
    800055dc:	69ae                	ld	s3,200(sp)
    800055de:	616d                	addi	sp,sp,240
    800055e0:	8082                	ret

00000000800055e2 <sys_open>:

uint64
sys_open(void)
{
    800055e2:	7131                	addi	sp,sp,-192
    800055e4:	fd06                	sd	ra,184(sp)
    800055e6:	f922                	sd	s0,176(sp)
    800055e8:	f526                	sd	s1,168(sp)
    800055ea:	f14a                	sd	s2,160(sp)
    800055ec:	ed4e                	sd	s3,152(sp)
    800055ee:	0180                	addi	s0,sp,192
  int fd, omode;
  struct file *f;
  struct inode *ip;
  int n;

  argint(1, &omode);
    800055f0:	f4c40593          	addi	a1,s0,-180
    800055f4:	4505                	li	a0,1
    800055f6:	ffffd097          	auipc	ra,0xffffd
    800055fa:	516080e7          	jalr	1302(ra) # 80002b0c <argint>
  if((n = argstr(0, path, MAXPATH)) < 0)
    800055fe:	08000613          	li	a2,128
    80005602:	f5040593          	addi	a1,s0,-176
    80005606:	4501                	li	a0,0
    80005608:	ffffd097          	auipc	ra,0xffffd
    8000560c:	544080e7          	jalr	1348(ra) # 80002b4c <argstr>
    80005610:	87aa                	mv	a5,a0
    return -1;
    80005612:	557d                	li	a0,-1
  if((n = argstr(0, path, MAXPATH)) < 0)
    80005614:	0a07c863          	bltz	a5,800056c4 <sys_open+0xe2>

  begin_op();
    80005618:	fffff097          	auipc	ra,0xfffff
    8000561c:	a14080e7          	jalr	-1516(ra) # 8000402c <begin_op>

  if(omode & O_CREATE){
    80005620:	f4c42783          	lw	a5,-180(s0)
    80005624:	2007f793          	andi	a5,a5,512
    80005628:	cbdd                	beqz	a5,800056de <sys_open+0xfc>
    ip = create(path, T_FILE, 0, 0);
    8000562a:	4681                	li	a3,0
    8000562c:	4601                	li	a2,0
    8000562e:	4589                	li	a1,2
    80005630:	f5040513          	addi	a0,s0,-176
    80005634:	00000097          	auipc	ra,0x0
    80005638:	97a080e7          	jalr	-1670(ra) # 80004fae <create>
    8000563c:	84aa                	mv	s1,a0
    if(ip == 0){
    8000563e:	c951                	beqz	a0,800056d2 <sys_open+0xf0>
      end_op();
      return -1;
    }
  }

  if(ip->type == T_DEVICE && (ip->major < 0 || ip->major >= NDEV)){
    80005640:	04449703          	lh	a4,68(s1)
    80005644:	478d                	li	a5,3
    80005646:	00f71763          	bne	a4,a5,80005654 <sys_open+0x72>
    8000564a:	0464d703          	lhu	a4,70(s1)
    8000564e:	47a5                	li	a5,9
    80005650:	0ce7ec63          	bltu	a5,a4,80005728 <sys_open+0x146>
    iunlockput(ip);
    end_op();
    return -1;
  }

  if((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0){
    80005654:	fffff097          	auipc	ra,0xfffff
    80005658:	de0080e7          	jalr	-544(ra) # 80004434 <filealloc>
    8000565c:	892a                	mv	s2,a0
    8000565e:	c56d                	beqz	a0,80005748 <sys_open+0x166>
    80005660:	00000097          	auipc	ra,0x0
    80005664:	90c080e7          	jalr	-1780(ra) # 80004f6c <fdalloc>
    80005668:	89aa                	mv	s3,a0
    8000566a:	0c054a63          	bltz	a0,8000573e <sys_open+0x15c>
    iunlockput(ip);
    end_op();
    return -1;
  }

  if(ip->type == T_DEVICE){
    8000566e:	04449703          	lh	a4,68(s1)
    80005672:	478d                	li	a5,3
    80005674:	0ef70563          	beq	a4,a5,8000575e <sys_open+0x17c>
    f->type = FD_DEVICE;
    f->major = ip->major;
  } else {
    f->type = FD_INODE;
    80005678:	4789                	li	a5,2
    8000567a:	00f92023          	sw	a5,0(s2)
    f->off = 0;
    8000567e:	02092023          	sw	zero,32(s2)
  }
  f->ip = ip;
    80005682:	00993c23          	sd	s1,24(s2)
  f->readable = !(omode & O_WRONLY);
    80005686:	f4c42783          	lw	a5,-180(s0)
    8000568a:	0017c713          	xori	a4,a5,1
    8000568e:	8b05                	andi	a4,a4,1
    80005690:	00e90423          	sb	a4,8(s2)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
    80005694:	0037f713          	andi	a4,a5,3
    80005698:	00e03733          	snez	a4,a4
    8000569c:	00e904a3          	sb	a4,9(s2)

  if((omode & O_TRUNC) && ip->type == T_FILE){
    800056a0:	4007f793          	andi	a5,a5,1024
    800056a4:	c791                	beqz	a5,800056b0 <sys_open+0xce>
    800056a6:	04449703          	lh	a4,68(s1)
    800056aa:	4789                	li	a5,2
    800056ac:	0cf70063          	beq	a4,a5,8000576c <sys_open+0x18a>
    itrunc(ip);
  }

  iunlock(ip);
    800056b0:	8526                	mv	a0,s1
    800056b2:	ffffe097          	auipc	ra,0xffffe
    800056b6:	096080e7          	jalr	150(ra) # 80003748 <iunlock>
  end_op();
    800056ba:	fffff097          	auipc	ra,0xfffff
    800056be:	9ec080e7          	jalr	-1556(ra) # 800040a6 <end_op>

  return fd;
    800056c2:	854e                	mv	a0,s3
}
    800056c4:	70ea                	ld	ra,184(sp)
    800056c6:	744a                	ld	s0,176(sp)
    800056c8:	74aa                	ld	s1,168(sp)
    800056ca:	790a                	ld	s2,160(sp)
    800056cc:	69ea                	ld	s3,152(sp)
    800056ce:	6129                	addi	sp,sp,192
    800056d0:	8082                	ret
      end_op();
    800056d2:	fffff097          	auipc	ra,0xfffff
    800056d6:	9d4080e7          	jalr	-1580(ra) # 800040a6 <end_op>
      return -1;
    800056da:	557d                	li	a0,-1
    800056dc:	b7e5                	j	800056c4 <sys_open+0xe2>
    if((ip = namei(path)) == 0){
    800056de:	f5040513          	addi	a0,s0,-176
    800056e2:	ffffe097          	auipc	ra,0xffffe
    800056e6:	74a080e7          	jalr	1866(ra) # 80003e2c <namei>
    800056ea:	84aa                	mv	s1,a0
    800056ec:	c905                	beqz	a0,8000571c <sys_open+0x13a>
    ilock(ip);
    800056ee:	ffffe097          	auipc	ra,0xffffe
    800056f2:	f98080e7          	jalr	-104(ra) # 80003686 <ilock>
    if(ip->type == T_DIR && omode != O_RDONLY){
    800056f6:	04449703          	lh	a4,68(s1)
    800056fa:	4785                	li	a5,1
    800056fc:	f4f712e3          	bne	a4,a5,80005640 <sys_open+0x5e>
    80005700:	f4c42783          	lw	a5,-180(s0)
    80005704:	dba1                	beqz	a5,80005654 <sys_open+0x72>
      iunlockput(ip);
    80005706:	8526                	mv	a0,s1
    80005708:	ffffe097          	auipc	ra,0xffffe
    8000570c:	1e0080e7          	jalr	480(ra) # 800038e8 <iunlockput>
      end_op();
    80005710:	fffff097          	auipc	ra,0xfffff
    80005714:	996080e7          	jalr	-1642(ra) # 800040a6 <end_op>
      return -1;
    80005718:	557d                	li	a0,-1
    8000571a:	b76d                	j	800056c4 <sys_open+0xe2>
      end_op();
    8000571c:	fffff097          	auipc	ra,0xfffff
    80005720:	98a080e7          	jalr	-1654(ra) # 800040a6 <end_op>
      return -1;
    80005724:	557d                	li	a0,-1
    80005726:	bf79                	j	800056c4 <sys_open+0xe2>
    iunlockput(ip);
    80005728:	8526                	mv	a0,s1
    8000572a:	ffffe097          	auipc	ra,0xffffe
    8000572e:	1be080e7          	jalr	446(ra) # 800038e8 <iunlockput>
    end_op();
    80005732:	fffff097          	auipc	ra,0xfffff
    80005736:	974080e7          	jalr	-1676(ra) # 800040a6 <end_op>
    return -1;
    8000573a:	557d                	li	a0,-1
    8000573c:	b761                	j	800056c4 <sys_open+0xe2>
      fileclose(f);
    8000573e:	854a                	mv	a0,s2
    80005740:	fffff097          	auipc	ra,0xfffff
    80005744:	db0080e7          	jalr	-592(ra) # 800044f0 <fileclose>
    iunlockput(ip);
    80005748:	8526                	mv	a0,s1
    8000574a:	ffffe097          	auipc	ra,0xffffe
    8000574e:	19e080e7          	jalr	414(ra) # 800038e8 <iunlockput>
    end_op();
    80005752:	fffff097          	auipc	ra,0xfffff
    80005756:	954080e7          	jalr	-1708(ra) # 800040a6 <end_op>
    return -1;
    8000575a:	557d                	li	a0,-1
    8000575c:	b7a5                	j	800056c4 <sys_open+0xe2>
    f->type = FD_DEVICE;
    8000575e:	00f92023          	sw	a5,0(s2)
    f->major = ip->major;
    80005762:	04649783          	lh	a5,70(s1)
    80005766:	02f91223          	sh	a5,36(s2)
    8000576a:	bf21                	j	80005682 <sys_open+0xa0>
    itrunc(ip);
    8000576c:	8526                	mv	a0,s1
    8000576e:	ffffe097          	auipc	ra,0xffffe
    80005772:	026080e7          	jalr	38(ra) # 80003794 <itrunc>
    80005776:	bf2d                	j	800056b0 <sys_open+0xce>

0000000080005778 <sys_mkdir>:

uint64
sys_mkdir(void)
{
    80005778:	7175                	addi	sp,sp,-144
    8000577a:	e506                	sd	ra,136(sp)
    8000577c:	e122                	sd	s0,128(sp)
    8000577e:	0900                	addi	s0,sp,144
  char path[MAXPATH];
  struct inode *ip;

  begin_op();
    80005780:	fffff097          	auipc	ra,0xfffff
    80005784:	8ac080e7          	jalr	-1876(ra) # 8000402c <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0){
    80005788:	08000613          	li	a2,128
    8000578c:	f7040593          	addi	a1,s0,-144
    80005790:	4501                	li	a0,0
    80005792:	ffffd097          	auipc	ra,0xffffd
    80005796:	3ba080e7          	jalr	954(ra) # 80002b4c <argstr>
    8000579a:	02054963          	bltz	a0,800057cc <sys_mkdir+0x54>
    8000579e:	4681                	li	a3,0
    800057a0:	4601                	li	a2,0
    800057a2:	4585                	li	a1,1
    800057a4:	f7040513          	addi	a0,s0,-144
    800057a8:	00000097          	auipc	ra,0x0
    800057ac:	806080e7          	jalr	-2042(ra) # 80004fae <create>
    800057b0:	cd11                	beqz	a0,800057cc <sys_mkdir+0x54>
    end_op();
    return -1;
  }
  iunlockput(ip);
    800057b2:	ffffe097          	auipc	ra,0xffffe
    800057b6:	136080e7          	jalr	310(ra) # 800038e8 <iunlockput>
  end_op();
    800057ba:	fffff097          	auipc	ra,0xfffff
    800057be:	8ec080e7          	jalr	-1812(ra) # 800040a6 <end_op>
  return 0;
    800057c2:	4501                	li	a0,0
}
    800057c4:	60aa                	ld	ra,136(sp)
    800057c6:	640a                	ld	s0,128(sp)
    800057c8:	6149                	addi	sp,sp,144
    800057ca:	8082                	ret
    end_op();
    800057cc:	fffff097          	auipc	ra,0xfffff
    800057d0:	8da080e7          	jalr	-1830(ra) # 800040a6 <end_op>
    return -1;
    800057d4:	557d                	li	a0,-1
    800057d6:	b7fd                	j	800057c4 <sys_mkdir+0x4c>

00000000800057d8 <sys_mknod>:

uint64
sys_mknod(void)
{
    800057d8:	7135                	addi	sp,sp,-160
    800057da:	ed06                	sd	ra,152(sp)
    800057dc:	e922                	sd	s0,144(sp)
    800057de:	1100                	addi	s0,sp,160
  struct inode *ip;
  char path[MAXPATH];
  int major, minor;

  begin_op();
    800057e0:	fffff097          	auipc	ra,0xfffff
    800057e4:	84c080e7          	jalr	-1972(ra) # 8000402c <begin_op>
  argint(1, &major);
    800057e8:	f6c40593          	addi	a1,s0,-148
    800057ec:	4505                	li	a0,1
    800057ee:	ffffd097          	auipc	ra,0xffffd
    800057f2:	31e080e7          	jalr	798(ra) # 80002b0c <argint>
  argint(2, &minor);
    800057f6:	f6840593          	addi	a1,s0,-152
    800057fa:	4509                	li	a0,2
    800057fc:	ffffd097          	auipc	ra,0xffffd
    80005800:	310080e7          	jalr	784(ra) # 80002b0c <argint>
  if((argstr(0, path, MAXPATH)) < 0 ||
    80005804:	08000613          	li	a2,128
    80005808:	f7040593          	addi	a1,s0,-144
    8000580c:	4501                	li	a0,0
    8000580e:	ffffd097          	auipc	ra,0xffffd
    80005812:	33e080e7          	jalr	830(ra) # 80002b4c <argstr>
    80005816:	02054b63          	bltz	a0,8000584c <sys_mknod+0x74>
     (ip = create(path, T_DEVICE, major, minor)) == 0){
    8000581a:	f6841683          	lh	a3,-152(s0)
    8000581e:	f6c41603          	lh	a2,-148(s0)
    80005822:	458d                	li	a1,3
    80005824:	f7040513          	addi	a0,s0,-144
    80005828:	fffff097          	auipc	ra,0xfffff
    8000582c:	786080e7          	jalr	1926(ra) # 80004fae <create>
  if((argstr(0, path, MAXPATH)) < 0 ||
    80005830:	cd11                	beqz	a0,8000584c <sys_mknod+0x74>
    end_op();
    return -1;
  }
  iunlockput(ip);
    80005832:	ffffe097          	auipc	ra,0xffffe
    80005836:	0b6080e7          	jalr	182(ra) # 800038e8 <iunlockput>
  end_op();
    8000583a:	fffff097          	auipc	ra,0xfffff
    8000583e:	86c080e7          	jalr	-1940(ra) # 800040a6 <end_op>
  return 0;
    80005842:	4501                	li	a0,0
}
    80005844:	60ea                	ld	ra,152(sp)
    80005846:	644a                	ld	s0,144(sp)
    80005848:	610d                	addi	sp,sp,160
    8000584a:	8082                	ret
    end_op();
    8000584c:	fffff097          	auipc	ra,0xfffff
    80005850:	85a080e7          	jalr	-1958(ra) # 800040a6 <end_op>
    return -1;
    80005854:	557d                	li	a0,-1
    80005856:	b7fd                	j	80005844 <sys_mknod+0x6c>

0000000080005858 <sys_chdir>:

uint64
sys_chdir(void)
{
    80005858:	7135                	addi	sp,sp,-160
    8000585a:	ed06                	sd	ra,152(sp)
    8000585c:	e922                	sd	s0,144(sp)
    8000585e:	e526                	sd	s1,136(sp)
    80005860:	e14a                	sd	s2,128(sp)
    80005862:	1100                	addi	s0,sp,160
  char path[MAXPATH];
  struct inode *ip;
  struct proc *p = myproc();
    80005864:	ffffc097          	auipc	ra,0xffffc
    80005868:	142080e7          	jalr	322(ra) # 800019a6 <myproc>
    8000586c:	892a                	mv	s2,a0
  
  begin_op();
    8000586e:	ffffe097          	auipc	ra,0xffffe
    80005872:	7be080e7          	jalr	1982(ra) # 8000402c <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = namei(path)) == 0){
    80005876:	08000613          	li	a2,128
    8000587a:	f6040593          	addi	a1,s0,-160
    8000587e:	4501                	li	a0,0
    80005880:	ffffd097          	auipc	ra,0xffffd
    80005884:	2cc080e7          	jalr	716(ra) # 80002b4c <argstr>
    80005888:	04054b63          	bltz	a0,800058de <sys_chdir+0x86>
    8000588c:	f6040513          	addi	a0,s0,-160
    80005890:	ffffe097          	auipc	ra,0xffffe
    80005894:	59c080e7          	jalr	1436(ra) # 80003e2c <namei>
    80005898:	84aa                	mv	s1,a0
    8000589a:	c131                	beqz	a0,800058de <sys_chdir+0x86>
    end_op();
    return -1;
  }
  ilock(ip);
    8000589c:	ffffe097          	auipc	ra,0xffffe
    800058a0:	dea080e7          	jalr	-534(ra) # 80003686 <ilock>
  if(ip->type != T_DIR){
    800058a4:	04449703          	lh	a4,68(s1)
    800058a8:	4785                	li	a5,1
    800058aa:	04f71063          	bne	a4,a5,800058ea <sys_chdir+0x92>
    iunlockput(ip);
    end_op();
    return -1;
  }
  iunlock(ip);
    800058ae:	8526                	mv	a0,s1
    800058b0:	ffffe097          	auipc	ra,0xffffe
    800058b4:	e98080e7          	jalr	-360(ra) # 80003748 <iunlock>
  iput(p->cwd);
    800058b8:	15093503          	ld	a0,336(s2)
    800058bc:	ffffe097          	auipc	ra,0xffffe
    800058c0:	f84080e7          	jalr	-124(ra) # 80003840 <iput>
  end_op();
    800058c4:	ffffe097          	auipc	ra,0xffffe
    800058c8:	7e2080e7          	jalr	2018(ra) # 800040a6 <end_op>
  p->cwd = ip;
    800058cc:	14993823          	sd	s1,336(s2)
  return 0;
    800058d0:	4501                	li	a0,0
}
    800058d2:	60ea                	ld	ra,152(sp)
    800058d4:	644a                	ld	s0,144(sp)
    800058d6:	64aa                	ld	s1,136(sp)
    800058d8:	690a                	ld	s2,128(sp)
    800058da:	610d                	addi	sp,sp,160
    800058dc:	8082                	ret
    end_op();
    800058de:	ffffe097          	auipc	ra,0xffffe
    800058e2:	7c8080e7          	jalr	1992(ra) # 800040a6 <end_op>
    return -1;
    800058e6:	557d                	li	a0,-1
    800058e8:	b7ed                	j	800058d2 <sys_chdir+0x7a>
    iunlockput(ip);
    800058ea:	8526                	mv	a0,s1
    800058ec:	ffffe097          	auipc	ra,0xffffe
    800058f0:	ffc080e7          	jalr	-4(ra) # 800038e8 <iunlockput>
    end_op();
    800058f4:	ffffe097          	auipc	ra,0xffffe
    800058f8:	7b2080e7          	jalr	1970(ra) # 800040a6 <end_op>
    return -1;
    800058fc:	557d                	li	a0,-1
    800058fe:	bfd1                	j	800058d2 <sys_chdir+0x7a>

0000000080005900 <sys_exec>:

uint64
sys_exec(void)
{
    80005900:	7121                	addi	sp,sp,-448
    80005902:	ff06                	sd	ra,440(sp)
    80005904:	fb22                	sd	s0,432(sp)
    80005906:	f726                	sd	s1,424(sp)
    80005908:	f34a                	sd	s2,416(sp)
    8000590a:	ef4e                	sd	s3,408(sp)
    8000590c:	eb52                	sd	s4,400(sp)
    8000590e:	0380                	addi	s0,sp,448
  char path[MAXPATH], *argv[MAXARG];
  int i;
  uint64 uargv, uarg;

  argaddr(1, &uargv);
    80005910:	e4840593          	addi	a1,s0,-440
    80005914:	4505                	li	a0,1
    80005916:	ffffd097          	auipc	ra,0xffffd
    8000591a:	216080e7          	jalr	534(ra) # 80002b2c <argaddr>
  if(argstr(0, path, MAXPATH) < 0) {
    8000591e:	08000613          	li	a2,128
    80005922:	f5040593          	addi	a1,s0,-176
    80005926:	4501                	li	a0,0
    80005928:	ffffd097          	auipc	ra,0xffffd
    8000592c:	224080e7          	jalr	548(ra) # 80002b4c <argstr>
    80005930:	87aa                	mv	a5,a0
    return -1;
    80005932:	557d                	li	a0,-1
  if(argstr(0, path, MAXPATH) < 0) {
    80005934:	0c07c263          	bltz	a5,800059f8 <sys_exec+0xf8>
  }
  memset(argv, 0, sizeof(argv));
    80005938:	10000613          	li	a2,256
    8000593c:	4581                	li	a1,0
    8000593e:	e5040513          	addi	a0,s0,-432
    80005942:	ffffb097          	auipc	ra,0xffffb
    80005946:	38c080e7          	jalr	908(ra) # 80000cce <memset>
  for(i=0;; i++){
    if(i >= NELEM(argv)){
    8000594a:	e5040493          	addi	s1,s0,-432
  memset(argv, 0, sizeof(argv));
    8000594e:	89a6                	mv	s3,s1
    80005950:	4901                	li	s2,0
    if(i >= NELEM(argv)){
    80005952:	02000a13          	li	s4,32
      goto bad;
    }
    if(fetchaddr(uargv+sizeof(uint64)*i, (uint64*)&uarg) < 0){
    80005956:	00391513          	slli	a0,s2,0x3
    8000595a:	e4040593          	addi	a1,s0,-448
    8000595e:	e4843783          	ld	a5,-440(s0)
    80005962:	953e                	add	a0,a0,a5
    80005964:	ffffd097          	auipc	ra,0xffffd
    80005968:	10a080e7          	jalr	266(ra) # 80002a6e <fetchaddr>
    8000596c:	02054a63          	bltz	a0,800059a0 <sys_exec+0xa0>
      goto bad;
    }
    if(uarg == 0){
    80005970:	e4043783          	ld	a5,-448(s0)
    80005974:	c3b9                	beqz	a5,800059ba <sys_exec+0xba>
      argv[i] = 0;
      break;
    }
    argv[i] = kalloc();
    80005976:	ffffb097          	auipc	ra,0xffffb
    8000597a:	16c080e7          	jalr	364(ra) # 80000ae2 <kalloc>
    8000597e:	85aa                	mv	a1,a0
    80005980:	00a9b023          	sd	a0,0(s3)
    if(argv[i] == 0)
    80005984:	cd11                	beqz	a0,800059a0 <sys_exec+0xa0>
      goto bad;
    if(fetchstr(uarg, argv[i], PGSIZE) < 0)
    80005986:	6605                	lui	a2,0x1
    80005988:	e4043503          	ld	a0,-448(s0)
    8000598c:	ffffd097          	auipc	ra,0xffffd
    80005990:	134080e7          	jalr	308(ra) # 80002ac0 <fetchstr>
    80005994:	00054663          	bltz	a0,800059a0 <sys_exec+0xa0>
    if(i >= NELEM(argv)){
    80005998:	0905                	addi	s2,s2,1
    8000599a:	09a1                	addi	s3,s3,8
    8000599c:	fb491de3          	bne	s2,s4,80005956 <sys_exec+0x56>
    kfree(argv[i]);

  return ret;

 bad:
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    800059a0:	f5040913          	addi	s2,s0,-176
    800059a4:	6088                	ld	a0,0(s1)
    800059a6:	c921                	beqz	a0,800059f6 <sys_exec+0xf6>
    kfree(argv[i]);
    800059a8:	ffffb097          	auipc	ra,0xffffb
    800059ac:	03c080e7          	jalr	60(ra) # 800009e4 <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    800059b0:	04a1                	addi	s1,s1,8
    800059b2:	ff2499e3          	bne	s1,s2,800059a4 <sys_exec+0xa4>
  return -1;
    800059b6:	557d                	li	a0,-1
    800059b8:	a081                	j	800059f8 <sys_exec+0xf8>
      argv[i] = 0;
    800059ba:	0009079b          	sext.w	a5,s2
    800059be:	078e                	slli	a5,a5,0x3
    800059c0:	fd078793          	addi	a5,a5,-48
    800059c4:	97a2                	add	a5,a5,s0
    800059c6:	e807b023          	sd	zero,-384(a5)
  int ret = exec(path, argv);
    800059ca:	e5040593          	addi	a1,s0,-432
    800059ce:	f5040513          	addi	a0,s0,-176
    800059d2:	fffff097          	auipc	ra,0xfffff
    800059d6:	194080e7          	jalr	404(ra) # 80004b66 <exec>
    800059da:	892a                	mv	s2,a0
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    800059dc:	f5040993          	addi	s3,s0,-176
    800059e0:	6088                	ld	a0,0(s1)
    800059e2:	c901                	beqz	a0,800059f2 <sys_exec+0xf2>
    kfree(argv[i]);
    800059e4:	ffffb097          	auipc	ra,0xffffb
    800059e8:	000080e7          	jalr	ra # 800009e4 <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    800059ec:	04a1                	addi	s1,s1,8
    800059ee:	ff3499e3          	bne	s1,s3,800059e0 <sys_exec+0xe0>
  return ret;
    800059f2:	854a                	mv	a0,s2
    800059f4:	a011                	j	800059f8 <sys_exec+0xf8>
  return -1;
    800059f6:	557d                	li	a0,-1
}
    800059f8:	70fa                	ld	ra,440(sp)
    800059fa:	745a                	ld	s0,432(sp)
    800059fc:	74ba                	ld	s1,424(sp)
    800059fe:	791a                	ld	s2,416(sp)
    80005a00:	69fa                	ld	s3,408(sp)
    80005a02:	6a5a                	ld	s4,400(sp)
    80005a04:	6139                	addi	sp,sp,448
    80005a06:	8082                	ret

0000000080005a08 <sys_pipe>:

uint64
sys_pipe(void)
{
    80005a08:	7139                	addi	sp,sp,-64
    80005a0a:	fc06                	sd	ra,56(sp)
    80005a0c:	f822                	sd	s0,48(sp)
    80005a0e:	f426                	sd	s1,40(sp)
    80005a10:	0080                	addi	s0,sp,64
  uint64 fdarray; // user pointer to array of two integers
  struct file *rf, *wf;
  int fd0, fd1;
  struct proc *p = myproc();
    80005a12:	ffffc097          	auipc	ra,0xffffc
    80005a16:	f94080e7          	jalr	-108(ra) # 800019a6 <myproc>
    80005a1a:	84aa                	mv	s1,a0

  argaddr(0, &fdarray);
    80005a1c:	fd840593          	addi	a1,s0,-40
    80005a20:	4501                	li	a0,0
    80005a22:	ffffd097          	auipc	ra,0xffffd
    80005a26:	10a080e7          	jalr	266(ra) # 80002b2c <argaddr>
  if(pipealloc(&rf, &wf) < 0)
    80005a2a:	fc840593          	addi	a1,s0,-56
    80005a2e:	fd040513          	addi	a0,s0,-48
    80005a32:	fffff097          	auipc	ra,0xfffff
    80005a36:	dea080e7          	jalr	-534(ra) # 8000481c <pipealloc>
    return -1;
    80005a3a:	57fd                	li	a5,-1
  if(pipealloc(&rf, &wf) < 0)
    80005a3c:	0c054463          	bltz	a0,80005b04 <sys_pipe+0xfc>
  fd0 = -1;
    80005a40:	fcf42223          	sw	a5,-60(s0)
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
    80005a44:	fd043503          	ld	a0,-48(s0)
    80005a48:	fffff097          	auipc	ra,0xfffff
    80005a4c:	524080e7          	jalr	1316(ra) # 80004f6c <fdalloc>
    80005a50:	fca42223          	sw	a0,-60(s0)
    80005a54:	08054b63          	bltz	a0,80005aea <sys_pipe+0xe2>
    80005a58:	fc843503          	ld	a0,-56(s0)
    80005a5c:	fffff097          	auipc	ra,0xfffff
    80005a60:	510080e7          	jalr	1296(ra) # 80004f6c <fdalloc>
    80005a64:	fca42023          	sw	a0,-64(s0)
    80005a68:	06054863          	bltz	a0,80005ad8 <sys_pipe+0xd0>
      p->ofile[fd0] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    80005a6c:	4691                	li	a3,4
    80005a6e:	fc440613          	addi	a2,s0,-60
    80005a72:	fd843583          	ld	a1,-40(s0)
    80005a76:	68a8                	ld	a0,80(s1)
    80005a78:	ffffc097          	auipc	ra,0xffffc
    80005a7c:	bee080e7          	jalr	-1042(ra) # 80001666 <copyout>
    80005a80:	02054063          	bltz	a0,80005aa0 <sys_pipe+0x98>
     copyout(p->pagetable, fdarray+sizeof(fd0), (char *)&fd1, sizeof(fd1)) < 0){
    80005a84:	4691                	li	a3,4
    80005a86:	fc040613          	addi	a2,s0,-64
    80005a8a:	fd843583          	ld	a1,-40(s0)
    80005a8e:	0591                	addi	a1,a1,4
    80005a90:	68a8                	ld	a0,80(s1)
    80005a92:	ffffc097          	auipc	ra,0xffffc
    80005a96:	bd4080e7          	jalr	-1068(ra) # 80001666 <copyout>
    p->ofile[fd1] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  return 0;
    80005a9a:	4781                	li	a5,0
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    80005a9c:	06055463          	bgez	a0,80005b04 <sys_pipe+0xfc>
    p->ofile[fd0] = 0;
    80005aa0:	fc442783          	lw	a5,-60(s0)
    80005aa4:	07e9                	addi	a5,a5,26
    80005aa6:	078e                	slli	a5,a5,0x3
    80005aa8:	97a6                	add	a5,a5,s1
    80005aaa:	0007b023          	sd	zero,0(a5)
    p->ofile[fd1] = 0;
    80005aae:	fc042783          	lw	a5,-64(s0)
    80005ab2:	07e9                	addi	a5,a5,26
    80005ab4:	078e                	slli	a5,a5,0x3
    80005ab6:	94be                	add	s1,s1,a5
    80005ab8:	0004b023          	sd	zero,0(s1)
    fileclose(rf);
    80005abc:	fd043503          	ld	a0,-48(s0)
    80005ac0:	fffff097          	auipc	ra,0xfffff
    80005ac4:	a30080e7          	jalr	-1488(ra) # 800044f0 <fileclose>
    fileclose(wf);
    80005ac8:	fc843503          	ld	a0,-56(s0)
    80005acc:	fffff097          	auipc	ra,0xfffff
    80005ad0:	a24080e7          	jalr	-1500(ra) # 800044f0 <fileclose>
    return -1;
    80005ad4:	57fd                	li	a5,-1
    80005ad6:	a03d                	j	80005b04 <sys_pipe+0xfc>
    if(fd0 >= 0)
    80005ad8:	fc442783          	lw	a5,-60(s0)
    80005adc:	0007c763          	bltz	a5,80005aea <sys_pipe+0xe2>
      p->ofile[fd0] = 0;
    80005ae0:	07e9                	addi	a5,a5,26
    80005ae2:	078e                	slli	a5,a5,0x3
    80005ae4:	97a6                	add	a5,a5,s1
    80005ae6:	0007b023          	sd	zero,0(a5)
    fileclose(rf);
    80005aea:	fd043503          	ld	a0,-48(s0)
    80005aee:	fffff097          	auipc	ra,0xfffff
    80005af2:	a02080e7          	jalr	-1534(ra) # 800044f0 <fileclose>
    fileclose(wf);
    80005af6:	fc843503          	ld	a0,-56(s0)
    80005afa:	fffff097          	auipc	ra,0xfffff
    80005afe:	9f6080e7          	jalr	-1546(ra) # 800044f0 <fileclose>
    return -1;
    80005b02:	57fd                	li	a5,-1
}
    80005b04:	853e                	mv	a0,a5
    80005b06:	70e2                	ld	ra,56(sp)
    80005b08:	7442                	ld	s0,48(sp)
    80005b0a:	74a2                	ld	s1,40(sp)
    80005b0c:	6121                	addi	sp,sp,64
    80005b0e:	8082                	ret

0000000080005b10 <kernelvec>:
    80005b10:	7111                	addi	sp,sp,-256
    80005b12:	e006                	sd	ra,0(sp)
    80005b14:	e40a                	sd	sp,8(sp)
    80005b16:	e80e                	sd	gp,16(sp)
    80005b18:	ec12                	sd	tp,24(sp)
    80005b1a:	f016                	sd	t0,32(sp)
    80005b1c:	f41a                	sd	t1,40(sp)
    80005b1e:	f81e                	sd	t2,48(sp)
    80005b20:	fc22                	sd	s0,56(sp)
    80005b22:	e0a6                	sd	s1,64(sp)
    80005b24:	e4aa                	sd	a0,72(sp)
    80005b26:	e8ae                	sd	a1,80(sp)
    80005b28:	ecb2                	sd	a2,88(sp)
    80005b2a:	f0b6                	sd	a3,96(sp)
    80005b2c:	f4ba                	sd	a4,104(sp)
    80005b2e:	f8be                	sd	a5,112(sp)
    80005b30:	fcc2                	sd	a6,120(sp)
    80005b32:	e146                	sd	a7,128(sp)
    80005b34:	e54a                	sd	s2,136(sp)
    80005b36:	e94e                	sd	s3,144(sp)
    80005b38:	ed52                	sd	s4,152(sp)
    80005b3a:	f156                	sd	s5,160(sp)
    80005b3c:	f55a                	sd	s6,168(sp)
    80005b3e:	f95e                	sd	s7,176(sp)
    80005b40:	fd62                	sd	s8,184(sp)
    80005b42:	e1e6                	sd	s9,192(sp)
    80005b44:	e5ea                	sd	s10,200(sp)
    80005b46:	e9ee                	sd	s11,208(sp)
    80005b48:	edf2                	sd	t3,216(sp)
    80005b4a:	f1f6                	sd	t4,224(sp)
    80005b4c:	f5fa                	sd	t5,232(sp)
    80005b4e:	f9fe                	sd	t6,240(sp)
    80005b50:	debfc0ef          	jal	ra,8000293a <kerneltrap>
    80005b54:	6082                	ld	ra,0(sp)
    80005b56:	6122                	ld	sp,8(sp)
    80005b58:	61c2                	ld	gp,16(sp)
    80005b5a:	7282                	ld	t0,32(sp)
    80005b5c:	7322                	ld	t1,40(sp)
    80005b5e:	73c2                	ld	t2,48(sp)
    80005b60:	7462                	ld	s0,56(sp)
    80005b62:	6486                	ld	s1,64(sp)
    80005b64:	6526                	ld	a0,72(sp)
    80005b66:	65c6                	ld	a1,80(sp)
    80005b68:	6666                	ld	a2,88(sp)
    80005b6a:	7686                	ld	a3,96(sp)
    80005b6c:	7726                	ld	a4,104(sp)
    80005b6e:	77c6                	ld	a5,112(sp)
    80005b70:	7866                	ld	a6,120(sp)
    80005b72:	688a                	ld	a7,128(sp)
    80005b74:	692a                	ld	s2,136(sp)
    80005b76:	69ca                	ld	s3,144(sp)
    80005b78:	6a6a                	ld	s4,152(sp)
    80005b7a:	7a8a                	ld	s5,160(sp)
    80005b7c:	7b2a                	ld	s6,168(sp)
    80005b7e:	7bca                	ld	s7,176(sp)
    80005b80:	7c6a                	ld	s8,184(sp)
    80005b82:	6c8e                	ld	s9,192(sp)
    80005b84:	6d2e                	ld	s10,200(sp)
    80005b86:	6dce                	ld	s11,208(sp)
    80005b88:	6e6e                	ld	t3,216(sp)
    80005b8a:	7e8e                	ld	t4,224(sp)
    80005b8c:	7f2e                	ld	t5,232(sp)
    80005b8e:	7fce                	ld	t6,240(sp)
    80005b90:	6111                	addi	sp,sp,256
    80005b92:	10200073          	sret
    80005b96:	00000013          	nop
    80005b9a:	00000013          	nop
    80005b9e:	0001                	nop

0000000080005ba0 <timervec>:
    80005ba0:	34051573          	csrrw	a0,mscratch,a0
    80005ba4:	e10c                	sd	a1,0(a0)
    80005ba6:	e510                	sd	a2,8(a0)
    80005ba8:	e914                	sd	a3,16(a0)
    80005baa:	6d0c                	ld	a1,24(a0)
    80005bac:	7110                	ld	a2,32(a0)
    80005bae:	6194                	ld	a3,0(a1)
    80005bb0:	96b2                	add	a3,a3,a2
    80005bb2:	e194                	sd	a3,0(a1)
    80005bb4:	4589                	li	a1,2
    80005bb6:	14459073          	csrw	sip,a1
    80005bba:	6914                	ld	a3,16(a0)
    80005bbc:	6510                	ld	a2,8(a0)
    80005bbe:	610c                	ld	a1,0(a0)
    80005bc0:	34051573          	csrrw	a0,mscratch,a0
    80005bc4:	30200073          	mret
	...

0000000080005bca <plicinit>:
// the riscv Platform Level Interrupt Controller (PLIC).
//

void
plicinit(void)
{
    80005bca:	1141                	addi	sp,sp,-16
    80005bcc:	e422                	sd	s0,8(sp)
    80005bce:	0800                	addi	s0,sp,16
  // set desired IRQ priorities non-zero (otherwise disabled).
  *(uint32*)(PLIC + UART0_IRQ*4) = 1;
    80005bd0:	0c0007b7          	lui	a5,0xc000
    80005bd4:	4705                	li	a4,1
    80005bd6:	d798                	sw	a4,40(a5)
  *(uint32*)(PLIC + VIRTIO0_IRQ*4) = 1;
    80005bd8:	c3d8                	sw	a4,4(a5)
}
    80005bda:	6422                	ld	s0,8(sp)
    80005bdc:	0141                	addi	sp,sp,16
    80005bde:	8082                	ret

0000000080005be0 <plicinithart>:

void
plicinithart(void)
{
    80005be0:	1141                	addi	sp,sp,-16
    80005be2:	e406                	sd	ra,8(sp)
    80005be4:	e022                	sd	s0,0(sp)
    80005be6:	0800                	addi	s0,sp,16
  int hart = cpuid();
    80005be8:	ffffc097          	auipc	ra,0xffffc
    80005bec:	d92080e7          	jalr	-622(ra) # 8000197a <cpuid>
  
  // set enable bits for this hart's S-mode
  // for the uart and virtio disk.
  *(uint32*)PLIC_SENABLE(hart) = (1 << UART0_IRQ) | (1 << VIRTIO0_IRQ);
    80005bf0:	0085171b          	slliw	a4,a0,0x8
    80005bf4:	0c0027b7          	lui	a5,0xc002
    80005bf8:	97ba                	add	a5,a5,a4
    80005bfa:	40200713          	li	a4,1026
    80005bfe:	08e7a023          	sw	a4,128(a5) # c002080 <_entry-0x73ffdf80>

  // set this hart's S-mode priority threshold to 0.
  *(uint32*)PLIC_SPRIORITY(hart) = 0;
    80005c02:	00d5151b          	slliw	a0,a0,0xd
    80005c06:	0c2017b7          	lui	a5,0xc201
    80005c0a:	97aa                	add	a5,a5,a0
    80005c0c:	0007a023          	sw	zero,0(a5) # c201000 <_entry-0x73dff000>
}
    80005c10:	60a2                	ld	ra,8(sp)
    80005c12:	6402                	ld	s0,0(sp)
    80005c14:	0141                	addi	sp,sp,16
    80005c16:	8082                	ret

0000000080005c18 <plic_claim>:

// ask the PLIC what interrupt we should serve.
int
plic_claim(void)
{
    80005c18:	1141                	addi	sp,sp,-16
    80005c1a:	e406                	sd	ra,8(sp)
    80005c1c:	e022                	sd	s0,0(sp)
    80005c1e:	0800                	addi	s0,sp,16
  int hart = cpuid();
    80005c20:	ffffc097          	auipc	ra,0xffffc
    80005c24:	d5a080e7          	jalr	-678(ra) # 8000197a <cpuid>
  int irq = *(uint32*)PLIC_SCLAIM(hart);
    80005c28:	00d5151b          	slliw	a0,a0,0xd
    80005c2c:	0c2017b7          	lui	a5,0xc201
    80005c30:	97aa                	add	a5,a5,a0
  return irq;
}
    80005c32:	43c8                	lw	a0,4(a5)
    80005c34:	60a2                	ld	ra,8(sp)
    80005c36:	6402                	ld	s0,0(sp)
    80005c38:	0141                	addi	sp,sp,16
    80005c3a:	8082                	ret

0000000080005c3c <plic_complete>:

// tell the PLIC we've served this IRQ.
void
plic_complete(int irq)
{
    80005c3c:	1101                	addi	sp,sp,-32
    80005c3e:	ec06                	sd	ra,24(sp)
    80005c40:	e822                	sd	s0,16(sp)
    80005c42:	e426                	sd	s1,8(sp)
    80005c44:	1000                	addi	s0,sp,32
    80005c46:	84aa                	mv	s1,a0
  int hart = cpuid();
    80005c48:	ffffc097          	auipc	ra,0xffffc
    80005c4c:	d32080e7          	jalr	-718(ra) # 8000197a <cpuid>
  *(uint32*)PLIC_SCLAIM(hart) = irq;
    80005c50:	00d5151b          	slliw	a0,a0,0xd
    80005c54:	0c2017b7          	lui	a5,0xc201
    80005c58:	97aa                	add	a5,a5,a0
    80005c5a:	c3c4                	sw	s1,4(a5)
}
    80005c5c:	60e2                	ld	ra,24(sp)
    80005c5e:	6442                	ld	s0,16(sp)
    80005c60:	64a2                	ld	s1,8(sp)
    80005c62:	6105                	addi	sp,sp,32
    80005c64:	8082                	ret

0000000080005c66 <free_desc>:
}

// mark a descriptor as free.
static void
free_desc(int i)
{
    80005c66:	1141                	addi	sp,sp,-16
    80005c68:	e406                	sd	ra,8(sp)
    80005c6a:	e022                	sd	s0,0(sp)
    80005c6c:	0800                	addi	s0,sp,16
  if(i >= NUM)
    80005c6e:	479d                	li	a5,7
    80005c70:	04a7cc63          	blt	a5,a0,80005cc8 <free_desc+0x62>
    panic("free_desc 1");
  if(disk.free[i])
    80005c74:	0001c797          	auipc	a5,0x1c
    80005c78:	f9c78793          	addi	a5,a5,-100 # 80021c10 <disk>
    80005c7c:	97aa                	add	a5,a5,a0
    80005c7e:	0187c783          	lbu	a5,24(a5)
    80005c82:	ebb9                	bnez	a5,80005cd8 <free_desc+0x72>
    panic("free_desc 2");
  disk.desc[i].addr = 0;
    80005c84:	00451693          	slli	a3,a0,0x4
    80005c88:	0001c797          	auipc	a5,0x1c
    80005c8c:	f8878793          	addi	a5,a5,-120 # 80021c10 <disk>
    80005c90:	6398                	ld	a4,0(a5)
    80005c92:	9736                	add	a4,a4,a3
    80005c94:	00073023          	sd	zero,0(a4)
  disk.desc[i].len = 0;
    80005c98:	6398                	ld	a4,0(a5)
    80005c9a:	9736                	add	a4,a4,a3
    80005c9c:	00072423          	sw	zero,8(a4)
  disk.desc[i].flags = 0;
    80005ca0:	00071623          	sh	zero,12(a4)
  disk.desc[i].next = 0;
    80005ca4:	00071723          	sh	zero,14(a4)
  disk.free[i] = 1;
    80005ca8:	97aa                	add	a5,a5,a0
    80005caa:	4705                	li	a4,1
    80005cac:	00e78c23          	sb	a4,24(a5)
  wakeup(&disk.free[0]);
    80005cb0:	0001c517          	auipc	a0,0x1c
    80005cb4:	f7850513          	addi	a0,a0,-136 # 80021c28 <disk+0x18>
    80005cb8:	ffffc097          	auipc	ra,0xffffc
    80005cbc:	446080e7          	jalr	1094(ra) # 800020fe <wakeup>
}
    80005cc0:	60a2                	ld	ra,8(sp)
    80005cc2:	6402                	ld	s0,0(sp)
    80005cc4:	0141                	addi	sp,sp,16
    80005cc6:	8082                	ret
    panic("free_desc 1");
    80005cc8:	00003517          	auipc	a0,0x3
    80005ccc:	a8050513          	addi	a0,a0,-1408 # 80008748 <syscalls+0x2f8>
    80005cd0:	ffffb097          	auipc	ra,0xffffb
    80005cd4:	86c080e7          	jalr	-1940(ra) # 8000053c <panic>
    panic("free_desc 2");
    80005cd8:	00003517          	auipc	a0,0x3
    80005cdc:	a8050513          	addi	a0,a0,-1408 # 80008758 <syscalls+0x308>
    80005ce0:	ffffb097          	auipc	ra,0xffffb
    80005ce4:	85c080e7          	jalr	-1956(ra) # 8000053c <panic>

0000000080005ce8 <virtio_disk_init>:
{
    80005ce8:	1101                	addi	sp,sp,-32
    80005cea:	ec06                	sd	ra,24(sp)
    80005cec:	e822                	sd	s0,16(sp)
    80005cee:	e426                	sd	s1,8(sp)
    80005cf0:	e04a                	sd	s2,0(sp)
    80005cf2:	1000                	addi	s0,sp,32
  initlock(&disk.vdisk_lock, "virtio_disk");
    80005cf4:	00003597          	auipc	a1,0x3
    80005cf8:	a7458593          	addi	a1,a1,-1420 # 80008768 <syscalls+0x318>
    80005cfc:	0001c517          	auipc	a0,0x1c
    80005d00:	03c50513          	addi	a0,a0,60 # 80021d38 <disk+0x128>
    80005d04:	ffffb097          	auipc	ra,0xffffb
    80005d08:	e3e080e7          	jalr	-450(ra) # 80000b42 <initlock>
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    80005d0c:	100017b7          	lui	a5,0x10001
    80005d10:	4398                	lw	a4,0(a5)
    80005d12:	2701                	sext.w	a4,a4
    80005d14:	747277b7          	lui	a5,0x74727
    80005d18:	97678793          	addi	a5,a5,-1674 # 74726976 <_entry-0xb8d968a>
    80005d1c:	14f71b63          	bne	a4,a5,80005e72 <virtio_disk_init+0x18a>
     *R(VIRTIO_MMIO_VERSION) != 2 ||
    80005d20:	100017b7          	lui	a5,0x10001
    80005d24:	43dc                	lw	a5,4(a5)
    80005d26:	2781                	sext.w	a5,a5
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    80005d28:	4709                	li	a4,2
    80005d2a:	14e79463          	bne	a5,a4,80005e72 <virtio_disk_init+0x18a>
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    80005d2e:	100017b7          	lui	a5,0x10001
    80005d32:	479c                	lw	a5,8(a5)
    80005d34:	2781                	sext.w	a5,a5
     *R(VIRTIO_MMIO_VERSION) != 2 ||
    80005d36:	12e79e63          	bne	a5,a4,80005e72 <virtio_disk_init+0x18a>
     *R(VIRTIO_MMIO_VENDOR_ID) != 0x554d4551){
    80005d3a:	100017b7          	lui	a5,0x10001
    80005d3e:	47d8                	lw	a4,12(a5)
    80005d40:	2701                	sext.w	a4,a4
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    80005d42:	554d47b7          	lui	a5,0x554d4
    80005d46:	55178793          	addi	a5,a5,1361 # 554d4551 <_entry-0x2ab2baaf>
    80005d4a:	12f71463          	bne	a4,a5,80005e72 <virtio_disk_init+0x18a>
  *R(VIRTIO_MMIO_STATUS) = status;
    80005d4e:	100017b7          	lui	a5,0x10001
    80005d52:	0607a823          	sw	zero,112(a5) # 10001070 <_entry-0x6fffef90>
  *R(VIRTIO_MMIO_STATUS) = status;
    80005d56:	4705                	li	a4,1
    80005d58:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    80005d5a:	470d                	li	a4,3
    80005d5c:	dbb8                	sw	a4,112(a5)
  uint64 features = *R(VIRTIO_MMIO_DEVICE_FEATURES);
    80005d5e:	4b98                	lw	a4,16(a5)
  *R(VIRTIO_MMIO_DRIVER_FEATURES) = features;
    80005d60:	c7ffe6b7          	lui	a3,0xc7ffe
    80005d64:	75f68693          	addi	a3,a3,1887 # ffffffffc7ffe75f <end+0xffffffff47fdca0f>
    80005d68:	8f75                	and	a4,a4,a3
    80005d6a:	d398                	sw	a4,32(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    80005d6c:	472d                	li	a4,11
    80005d6e:	dbb8                	sw	a4,112(a5)
  status = *R(VIRTIO_MMIO_STATUS);
    80005d70:	5bbc                	lw	a5,112(a5)
    80005d72:	0007891b          	sext.w	s2,a5
  if(!(status & VIRTIO_CONFIG_S_FEATURES_OK))
    80005d76:	8ba1                	andi	a5,a5,8
    80005d78:	10078563          	beqz	a5,80005e82 <virtio_disk_init+0x19a>
  *R(VIRTIO_MMIO_QUEUE_SEL) = 0;
    80005d7c:	100017b7          	lui	a5,0x10001
    80005d80:	0207a823          	sw	zero,48(a5) # 10001030 <_entry-0x6fffefd0>
  if(*R(VIRTIO_MMIO_QUEUE_READY))
    80005d84:	43fc                	lw	a5,68(a5)
    80005d86:	2781                	sext.w	a5,a5
    80005d88:	10079563          	bnez	a5,80005e92 <virtio_disk_init+0x1aa>
  uint32 max = *R(VIRTIO_MMIO_QUEUE_NUM_MAX);
    80005d8c:	100017b7          	lui	a5,0x10001
    80005d90:	5bdc                	lw	a5,52(a5)
    80005d92:	2781                	sext.w	a5,a5
  if(max == 0)
    80005d94:	10078763          	beqz	a5,80005ea2 <virtio_disk_init+0x1ba>
  if(max < NUM)
    80005d98:	471d                	li	a4,7
    80005d9a:	10f77c63          	bgeu	a4,a5,80005eb2 <virtio_disk_init+0x1ca>
  disk.desc = kalloc();
    80005d9e:	ffffb097          	auipc	ra,0xffffb
    80005da2:	d44080e7          	jalr	-700(ra) # 80000ae2 <kalloc>
    80005da6:	0001c497          	auipc	s1,0x1c
    80005daa:	e6a48493          	addi	s1,s1,-406 # 80021c10 <disk>
    80005dae:	e088                	sd	a0,0(s1)
  disk.avail = kalloc();
    80005db0:	ffffb097          	auipc	ra,0xffffb
    80005db4:	d32080e7          	jalr	-718(ra) # 80000ae2 <kalloc>
    80005db8:	e488                	sd	a0,8(s1)
  disk.used = kalloc();
    80005dba:	ffffb097          	auipc	ra,0xffffb
    80005dbe:	d28080e7          	jalr	-728(ra) # 80000ae2 <kalloc>
    80005dc2:	87aa                	mv	a5,a0
    80005dc4:	e888                	sd	a0,16(s1)
  if(!disk.desc || !disk.avail || !disk.used)
    80005dc6:	6088                	ld	a0,0(s1)
    80005dc8:	cd6d                	beqz	a0,80005ec2 <virtio_disk_init+0x1da>
    80005dca:	0001c717          	auipc	a4,0x1c
    80005dce:	e4e73703          	ld	a4,-434(a4) # 80021c18 <disk+0x8>
    80005dd2:	cb65                	beqz	a4,80005ec2 <virtio_disk_init+0x1da>
    80005dd4:	c7fd                	beqz	a5,80005ec2 <virtio_disk_init+0x1da>
  memset(disk.desc, 0, PGSIZE);
    80005dd6:	6605                	lui	a2,0x1
    80005dd8:	4581                	li	a1,0
    80005dda:	ffffb097          	auipc	ra,0xffffb
    80005dde:	ef4080e7          	jalr	-268(ra) # 80000cce <memset>
  memset(disk.avail, 0, PGSIZE);
    80005de2:	0001c497          	auipc	s1,0x1c
    80005de6:	e2e48493          	addi	s1,s1,-466 # 80021c10 <disk>
    80005dea:	6605                	lui	a2,0x1
    80005dec:	4581                	li	a1,0
    80005dee:	6488                	ld	a0,8(s1)
    80005df0:	ffffb097          	auipc	ra,0xffffb
    80005df4:	ede080e7          	jalr	-290(ra) # 80000cce <memset>
  memset(disk.used, 0, PGSIZE);
    80005df8:	6605                	lui	a2,0x1
    80005dfa:	4581                	li	a1,0
    80005dfc:	6888                	ld	a0,16(s1)
    80005dfe:	ffffb097          	auipc	ra,0xffffb
    80005e02:	ed0080e7          	jalr	-304(ra) # 80000cce <memset>
  *R(VIRTIO_MMIO_QUEUE_NUM) = NUM;
    80005e06:	100017b7          	lui	a5,0x10001
    80005e0a:	4721                	li	a4,8
    80005e0c:	df98                	sw	a4,56(a5)
  *R(VIRTIO_MMIO_QUEUE_DESC_LOW) = (uint64)disk.desc;
    80005e0e:	4098                	lw	a4,0(s1)
    80005e10:	08e7a023          	sw	a4,128(a5) # 10001080 <_entry-0x6fffef80>
  *R(VIRTIO_MMIO_QUEUE_DESC_HIGH) = (uint64)disk.desc >> 32;
    80005e14:	40d8                	lw	a4,4(s1)
    80005e16:	08e7a223          	sw	a4,132(a5)
  *R(VIRTIO_MMIO_DRIVER_DESC_LOW) = (uint64)disk.avail;
    80005e1a:	6498                	ld	a4,8(s1)
    80005e1c:	0007069b          	sext.w	a3,a4
    80005e20:	08d7a823          	sw	a3,144(a5)
  *R(VIRTIO_MMIO_DRIVER_DESC_HIGH) = (uint64)disk.avail >> 32;
    80005e24:	9701                	srai	a4,a4,0x20
    80005e26:	08e7aa23          	sw	a4,148(a5)
  *R(VIRTIO_MMIO_DEVICE_DESC_LOW) = (uint64)disk.used;
    80005e2a:	6898                	ld	a4,16(s1)
    80005e2c:	0007069b          	sext.w	a3,a4
    80005e30:	0ad7a023          	sw	a3,160(a5)
  *R(VIRTIO_MMIO_DEVICE_DESC_HIGH) = (uint64)disk.used >> 32;
    80005e34:	9701                	srai	a4,a4,0x20
    80005e36:	0ae7a223          	sw	a4,164(a5)
  *R(VIRTIO_MMIO_QUEUE_READY) = 0x1;
    80005e3a:	4705                	li	a4,1
    80005e3c:	c3f8                	sw	a4,68(a5)
    disk.free[i] = 1;
    80005e3e:	00e48c23          	sb	a4,24(s1)
    80005e42:	00e48ca3          	sb	a4,25(s1)
    80005e46:	00e48d23          	sb	a4,26(s1)
    80005e4a:	00e48da3          	sb	a4,27(s1)
    80005e4e:	00e48e23          	sb	a4,28(s1)
    80005e52:	00e48ea3          	sb	a4,29(s1)
    80005e56:	00e48f23          	sb	a4,30(s1)
    80005e5a:	00e48fa3          	sb	a4,31(s1)
  status |= VIRTIO_CONFIG_S_DRIVER_OK;
    80005e5e:	00496913          	ori	s2,s2,4
  *R(VIRTIO_MMIO_STATUS) = status;
    80005e62:	0727a823          	sw	s2,112(a5)
}
    80005e66:	60e2                	ld	ra,24(sp)
    80005e68:	6442                	ld	s0,16(sp)
    80005e6a:	64a2                	ld	s1,8(sp)
    80005e6c:	6902                	ld	s2,0(sp)
    80005e6e:	6105                	addi	sp,sp,32
    80005e70:	8082                	ret
    panic("could not find virtio disk");
    80005e72:	00003517          	auipc	a0,0x3
    80005e76:	90650513          	addi	a0,a0,-1786 # 80008778 <syscalls+0x328>
    80005e7a:	ffffa097          	auipc	ra,0xffffa
    80005e7e:	6c2080e7          	jalr	1730(ra) # 8000053c <panic>
    panic("virtio disk FEATURES_OK unset");
    80005e82:	00003517          	auipc	a0,0x3
    80005e86:	91650513          	addi	a0,a0,-1770 # 80008798 <syscalls+0x348>
    80005e8a:	ffffa097          	auipc	ra,0xffffa
    80005e8e:	6b2080e7          	jalr	1714(ra) # 8000053c <panic>
    panic("virtio disk should not be ready");
    80005e92:	00003517          	auipc	a0,0x3
    80005e96:	92650513          	addi	a0,a0,-1754 # 800087b8 <syscalls+0x368>
    80005e9a:	ffffa097          	auipc	ra,0xffffa
    80005e9e:	6a2080e7          	jalr	1698(ra) # 8000053c <panic>
    panic("virtio disk has no queue 0");
    80005ea2:	00003517          	auipc	a0,0x3
    80005ea6:	93650513          	addi	a0,a0,-1738 # 800087d8 <syscalls+0x388>
    80005eaa:	ffffa097          	auipc	ra,0xffffa
    80005eae:	692080e7          	jalr	1682(ra) # 8000053c <panic>
    panic("virtio disk max queue too short");
    80005eb2:	00003517          	auipc	a0,0x3
    80005eb6:	94650513          	addi	a0,a0,-1722 # 800087f8 <syscalls+0x3a8>
    80005eba:	ffffa097          	auipc	ra,0xffffa
    80005ebe:	682080e7          	jalr	1666(ra) # 8000053c <panic>
    panic("virtio disk kalloc");
    80005ec2:	00003517          	auipc	a0,0x3
    80005ec6:	95650513          	addi	a0,a0,-1706 # 80008818 <syscalls+0x3c8>
    80005eca:	ffffa097          	auipc	ra,0xffffa
    80005ece:	672080e7          	jalr	1650(ra) # 8000053c <panic>

0000000080005ed2 <virtio_disk_rw>:
  return 0;
}

void
virtio_disk_rw(struct buf *b, int write)
{
    80005ed2:	7159                	addi	sp,sp,-112
    80005ed4:	f486                	sd	ra,104(sp)
    80005ed6:	f0a2                	sd	s0,96(sp)
    80005ed8:	eca6                	sd	s1,88(sp)
    80005eda:	e8ca                	sd	s2,80(sp)
    80005edc:	e4ce                	sd	s3,72(sp)
    80005ede:	e0d2                	sd	s4,64(sp)
    80005ee0:	fc56                	sd	s5,56(sp)
    80005ee2:	f85a                	sd	s6,48(sp)
    80005ee4:	f45e                	sd	s7,40(sp)
    80005ee6:	f062                	sd	s8,32(sp)
    80005ee8:	ec66                	sd	s9,24(sp)
    80005eea:	e86a                	sd	s10,16(sp)
    80005eec:	1880                	addi	s0,sp,112
    80005eee:	8a2a                	mv	s4,a0
    80005ef0:	8bae                	mv	s7,a1
  uint64 sector = b->blockno * (BSIZE / 512);
    80005ef2:	00c52c83          	lw	s9,12(a0)
    80005ef6:	001c9c9b          	slliw	s9,s9,0x1
    80005efa:	1c82                	slli	s9,s9,0x20
    80005efc:	020cdc93          	srli	s9,s9,0x20

  acquire(&disk.vdisk_lock);
    80005f00:	0001c517          	auipc	a0,0x1c
    80005f04:	e3850513          	addi	a0,a0,-456 # 80021d38 <disk+0x128>
    80005f08:	ffffb097          	auipc	ra,0xffffb
    80005f0c:	cca080e7          	jalr	-822(ra) # 80000bd2 <acquire>
  for(int i = 0; i < 3; i++){
    80005f10:	4901                	li	s2,0
  for(int i = 0; i < NUM; i++){
    80005f12:	44a1                	li	s1,8
      disk.free[i] = 0;
    80005f14:	0001cb17          	auipc	s6,0x1c
    80005f18:	cfcb0b13          	addi	s6,s6,-772 # 80021c10 <disk>
  for(int i = 0; i < 3; i++){
    80005f1c:	4a8d                	li	s5,3
  int idx[3];
  while(1){
    if(alloc3_desc(idx) == 0) {
      break;
    }
    sleep(&disk.free[0], &disk.vdisk_lock);
    80005f1e:	0001cc17          	auipc	s8,0x1c
    80005f22:	e1ac0c13          	addi	s8,s8,-486 # 80021d38 <disk+0x128>
    80005f26:	a095                	j	80005f8a <virtio_disk_rw+0xb8>
      disk.free[i] = 0;
    80005f28:	00fb0733          	add	a4,s6,a5
    80005f2c:	00070c23          	sb	zero,24(a4)
    idx[i] = alloc_desc();
    80005f30:	c11c                	sw	a5,0(a0)
    if(idx[i] < 0){
    80005f32:	0207c563          	bltz	a5,80005f5c <virtio_disk_rw+0x8a>
  for(int i = 0; i < 3; i++){
    80005f36:	2605                	addiw	a2,a2,1 # 1001 <_entry-0x7fffefff>
    80005f38:	0591                	addi	a1,a1,4
    80005f3a:	05560d63          	beq	a2,s5,80005f94 <virtio_disk_rw+0xc2>
    idx[i] = alloc_desc();
    80005f3e:	852e                	mv	a0,a1
  for(int i = 0; i < NUM; i++){
    80005f40:	0001c717          	auipc	a4,0x1c
    80005f44:	cd070713          	addi	a4,a4,-816 # 80021c10 <disk>
    80005f48:	87ca                	mv	a5,s2
    if(disk.free[i]){
    80005f4a:	01874683          	lbu	a3,24(a4)
    80005f4e:	fee9                	bnez	a3,80005f28 <virtio_disk_rw+0x56>
  for(int i = 0; i < NUM; i++){
    80005f50:	2785                	addiw	a5,a5,1
    80005f52:	0705                	addi	a4,a4,1
    80005f54:	fe979be3          	bne	a5,s1,80005f4a <virtio_disk_rw+0x78>
    idx[i] = alloc_desc();
    80005f58:	57fd                	li	a5,-1
    80005f5a:	c11c                	sw	a5,0(a0)
      for(int j = 0; j < i; j++)
    80005f5c:	00c05e63          	blez	a2,80005f78 <virtio_disk_rw+0xa6>
    80005f60:	060a                	slli	a2,a2,0x2
    80005f62:	01360d33          	add	s10,a2,s3
        free_desc(idx[j]);
    80005f66:	0009a503          	lw	a0,0(s3)
    80005f6a:	00000097          	auipc	ra,0x0
    80005f6e:	cfc080e7          	jalr	-772(ra) # 80005c66 <free_desc>
      for(int j = 0; j < i; j++)
    80005f72:	0991                	addi	s3,s3,4
    80005f74:	ffa999e3          	bne	s3,s10,80005f66 <virtio_disk_rw+0x94>
    sleep(&disk.free[0], &disk.vdisk_lock);
    80005f78:	85e2                	mv	a1,s8
    80005f7a:	0001c517          	auipc	a0,0x1c
    80005f7e:	cae50513          	addi	a0,a0,-850 # 80021c28 <disk+0x18>
    80005f82:	ffffc097          	auipc	ra,0xffffc
    80005f86:	118080e7          	jalr	280(ra) # 8000209a <sleep>
  for(int i = 0; i < 3; i++){
    80005f8a:	f9040993          	addi	s3,s0,-112
{
    80005f8e:	85ce                	mv	a1,s3
  for(int i = 0; i < 3; i++){
    80005f90:	864a                	mv	a2,s2
    80005f92:	b775                	j	80005f3e <virtio_disk_rw+0x6c>
  }

  // format the three descriptors.
  // qemu's virtio-blk.c reads them.

  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    80005f94:	f9042503          	lw	a0,-112(s0)
    80005f98:	00a50713          	addi	a4,a0,10
    80005f9c:	0712                	slli	a4,a4,0x4

  if(write)
    80005f9e:	0001c797          	auipc	a5,0x1c
    80005fa2:	c7278793          	addi	a5,a5,-910 # 80021c10 <disk>
    80005fa6:	00e786b3          	add	a3,a5,a4
    80005faa:	01703633          	snez	a2,s7
    80005fae:	c690                	sw	a2,8(a3)
    buf0->type = VIRTIO_BLK_T_OUT; // write the disk
  else
    buf0->type = VIRTIO_BLK_T_IN; // read the disk
  buf0->reserved = 0;
    80005fb0:	0006a623          	sw	zero,12(a3)
  buf0->sector = sector;
    80005fb4:	0196b823          	sd	s9,16(a3)

  disk.desc[idx[0]].addr = (uint64) buf0;
    80005fb8:	f6070613          	addi	a2,a4,-160
    80005fbc:	6394                	ld	a3,0(a5)
    80005fbe:	96b2                	add	a3,a3,a2
  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    80005fc0:	00870593          	addi	a1,a4,8
    80005fc4:	95be                	add	a1,a1,a5
  disk.desc[idx[0]].addr = (uint64) buf0;
    80005fc6:	e28c                	sd	a1,0(a3)
  disk.desc[idx[0]].len = sizeof(struct virtio_blk_req);
    80005fc8:	0007b803          	ld	a6,0(a5)
    80005fcc:	9642                	add	a2,a2,a6
    80005fce:	46c1                	li	a3,16
    80005fd0:	c614                	sw	a3,8(a2)
  disk.desc[idx[0]].flags = VRING_DESC_F_NEXT;
    80005fd2:	4585                	li	a1,1
    80005fd4:	00b61623          	sh	a1,12(a2)
  disk.desc[idx[0]].next = idx[1];
    80005fd8:	f9442683          	lw	a3,-108(s0)
    80005fdc:	00d61723          	sh	a3,14(a2)

  disk.desc[idx[1]].addr = (uint64) b->data;
    80005fe0:	0692                	slli	a3,a3,0x4
    80005fe2:	9836                	add	a6,a6,a3
    80005fe4:	058a0613          	addi	a2,s4,88
    80005fe8:	00c83023          	sd	a2,0(a6)
  disk.desc[idx[1]].len = BSIZE;
    80005fec:	0007b803          	ld	a6,0(a5)
    80005ff0:	96c2                	add	a3,a3,a6
    80005ff2:	40000613          	li	a2,1024
    80005ff6:	c690                	sw	a2,8(a3)
  if(write)
    80005ff8:	001bb613          	seqz	a2,s7
    80005ffc:	0016161b          	slliw	a2,a2,0x1
    disk.desc[idx[1]].flags = 0; // device reads b->data
  else
    disk.desc[idx[1]].flags = VRING_DESC_F_WRITE; // device writes b->data
  disk.desc[idx[1]].flags |= VRING_DESC_F_NEXT;
    80006000:	00166613          	ori	a2,a2,1
    80006004:	00c69623          	sh	a2,12(a3)
  disk.desc[idx[1]].next = idx[2];
    80006008:	f9842603          	lw	a2,-104(s0)
    8000600c:	00c69723          	sh	a2,14(a3)

  disk.info[idx[0]].status = 0xff; // device writes 0 on success
    80006010:	00250693          	addi	a3,a0,2
    80006014:	0692                	slli	a3,a3,0x4
    80006016:	96be                	add	a3,a3,a5
    80006018:	58fd                	li	a7,-1
    8000601a:	01168823          	sb	a7,16(a3)
  disk.desc[idx[2]].addr = (uint64) &disk.info[idx[0]].status;
    8000601e:	0612                	slli	a2,a2,0x4
    80006020:	9832                	add	a6,a6,a2
    80006022:	f9070713          	addi	a4,a4,-112
    80006026:	973e                	add	a4,a4,a5
    80006028:	00e83023          	sd	a4,0(a6)
  disk.desc[idx[2]].len = 1;
    8000602c:	6398                	ld	a4,0(a5)
    8000602e:	9732                	add	a4,a4,a2
    80006030:	c70c                	sw	a1,8(a4)
  disk.desc[idx[2]].flags = VRING_DESC_F_WRITE; // device writes the status
    80006032:	4609                	li	a2,2
    80006034:	00c71623          	sh	a2,12(a4)
  disk.desc[idx[2]].next = 0;
    80006038:	00071723          	sh	zero,14(a4)

  // record struct buf for virtio_disk_intr().
  b->disk = 1;
    8000603c:	00ba2223          	sw	a1,4(s4)
  disk.info[idx[0]].b = b;
    80006040:	0146b423          	sd	s4,8(a3)

  // tell the device the first index in our chain of descriptors.
  disk.avail->ring[disk.avail->idx % NUM] = idx[0];
    80006044:	6794                	ld	a3,8(a5)
    80006046:	0026d703          	lhu	a4,2(a3)
    8000604a:	8b1d                	andi	a4,a4,7
    8000604c:	0706                	slli	a4,a4,0x1
    8000604e:	96ba                	add	a3,a3,a4
    80006050:	00a69223          	sh	a0,4(a3)

  __sync_synchronize();
    80006054:	0ff0000f          	fence

  // tell the device another avail ring entry is available.
  disk.avail->idx += 1; // not % NUM ...
    80006058:	6798                	ld	a4,8(a5)
    8000605a:	00275783          	lhu	a5,2(a4)
    8000605e:	2785                	addiw	a5,a5,1
    80006060:	00f71123          	sh	a5,2(a4)

  __sync_synchronize();
    80006064:	0ff0000f          	fence

  *R(VIRTIO_MMIO_QUEUE_NOTIFY) = 0; // value is queue number
    80006068:	100017b7          	lui	a5,0x10001
    8000606c:	0407a823          	sw	zero,80(a5) # 10001050 <_entry-0x6fffefb0>

  // Wait for virtio_disk_intr() to say request has finished.
  while(b->disk == 1) {
    80006070:	004a2783          	lw	a5,4(s4)
    sleep(b, &disk.vdisk_lock);
    80006074:	0001c917          	auipc	s2,0x1c
    80006078:	cc490913          	addi	s2,s2,-828 # 80021d38 <disk+0x128>
  while(b->disk == 1) {
    8000607c:	4485                	li	s1,1
    8000607e:	00b79c63          	bne	a5,a1,80006096 <virtio_disk_rw+0x1c4>
    sleep(b, &disk.vdisk_lock);
    80006082:	85ca                	mv	a1,s2
    80006084:	8552                	mv	a0,s4
    80006086:	ffffc097          	auipc	ra,0xffffc
    8000608a:	014080e7          	jalr	20(ra) # 8000209a <sleep>
  while(b->disk == 1) {
    8000608e:	004a2783          	lw	a5,4(s4)
    80006092:	fe9788e3          	beq	a5,s1,80006082 <virtio_disk_rw+0x1b0>
  }

  disk.info[idx[0]].b = 0;
    80006096:	f9042903          	lw	s2,-112(s0)
    8000609a:	00290713          	addi	a4,s2,2
    8000609e:	0712                	slli	a4,a4,0x4
    800060a0:	0001c797          	auipc	a5,0x1c
    800060a4:	b7078793          	addi	a5,a5,-1168 # 80021c10 <disk>
    800060a8:	97ba                	add	a5,a5,a4
    800060aa:	0007b423          	sd	zero,8(a5)
    int flag = disk.desc[i].flags;
    800060ae:	0001c997          	auipc	s3,0x1c
    800060b2:	b6298993          	addi	s3,s3,-1182 # 80021c10 <disk>
    800060b6:	00491713          	slli	a4,s2,0x4
    800060ba:	0009b783          	ld	a5,0(s3)
    800060be:	97ba                	add	a5,a5,a4
    800060c0:	00c7d483          	lhu	s1,12(a5)
    int nxt = disk.desc[i].next;
    800060c4:	854a                	mv	a0,s2
    800060c6:	00e7d903          	lhu	s2,14(a5)
    free_desc(i);
    800060ca:	00000097          	auipc	ra,0x0
    800060ce:	b9c080e7          	jalr	-1124(ra) # 80005c66 <free_desc>
    if(flag & VRING_DESC_F_NEXT)
    800060d2:	8885                	andi	s1,s1,1
    800060d4:	f0ed                	bnez	s1,800060b6 <virtio_disk_rw+0x1e4>
  free_chain(idx[0]);

  release(&disk.vdisk_lock);
    800060d6:	0001c517          	auipc	a0,0x1c
    800060da:	c6250513          	addi	a0,a0,-926 # 80021d38 <disk+0x128>
    800060de:	ffffb097          	auipc	ra,0xffffb
    800060e2:	ba8080e7          	jalr	-1112(ra) # 80000c86 <release>
}
    800060e6:	70a6                	ld	ra,104(sp)
    800060e8:	7406                	ld	s0,96(sp)
    800060ea:	64e6                	ld	s1,88(sp)
    800060ec:	6946                	ld	s2,80(sp)
    800060ee:	69a6                	ld	s3,72(sp)
    800060f0:	6a06                	ld	s4,64(sp)
    800060f2:	7ae2                	ld	s5,56(sp)
    800060f4:	7b42                	ld	s6,48(sp)
    800060f6:	7ba2                	ld	s7,40(sp)
    800060f8:	7c02                	ld	s8,32(sp)
    800060fa:	6ce2                	ld	s9,24(sp)
    800060fc:	6d42                	ld	s10,16(sp)
    800060fe:	6165                	addi	sp,sp,112
    80006100:	8082                	ret

0000000080006102 <virtio_disk_intr>:

void
virtio_disk_intr()
{
    80006102:	1101                	addi	sp,sp,-32
    80006104:	ec06                	sd	ra,24(sp)
    80006106:	e822                	sd	s0,16(sp)
    80006108:	e426                	sd	s1,8(sp)
    8000610a:	1000                	addi	s0,sp,32
  acquire(&disk.vdisk_lock);
    8000610c:	0001c497          	auipc	s1,0x1c
    80006110:	b0448493          	addi	s1,s1,-1276 # 80021c10 <disk>
    80006114:	0001c517          	auipc	a0,0x1c
    80006118:	c2450513          	addi	a0,a0,-988 # 80021d38 <disk+0x128>
    8000611c:	ffffb097          	auipc	ra,0xffffb
    80006120:	ab6080e7          	jalr	-1354(ra) # 80000bd2 <acquire>
  // we've seen this interrupt, which the following line does.
  // this may race with the device writing new entries to
  // the "used" ring, in which case we may process the new
  // completion entries in this interrupt, and have nothing to do
  // in the next interrupt, which is harmless.
  *R(VIRTIO_MMIO_INTERRUPT_ACK) = *R(VIRTIO_MMIO_INTERRUPT_STATUS) & 0x3;
    80006124:	10001737          	lui	a4,0x10001
    80006128:	533c                	lw	a5,96(a4)
    8000612a:	8b8d                	andi	a5,a5,3
    8000612c:	d37c                	sw	a5,100(a4)

  __sync_synchronize();
    8000612e:	0ff0000f          	fence

  // the device increments disk.used->idx when it
  // adds an entry to the used ring.

  while(disk.used_idx != disk.used->idx){
    80006132:	689c                	ld	a5,16(s1)
    80006134:	0204d703          	lhu	a4,32(s1)
    80006138:	0027d783          	lhu	a5,2(a5)
    8000613c:	04f70863          	beq	a4,a5,8000618c <virtio_disk_intr+0x8a>
    __sync_synchronize();
    80006140:	0ff0000f          	fence
    int id = disk.used->ring[disk.used_idx % NUM].id;
    80006144:	6898                	ld	a4,16(s1)
    80006146:	0204d783          	lhu	a5,32(s1)
    8000614a:	8b9d                	andi	a5,a5,7
    8000614c:	078e                	slli	a5,a5,0x3
    8000614e:	97ba                	add	a5,a5,a4
    80006150:	43dc                	lw	a5,4(a5)

    if(disk.info[id].status != 0)
    80006152:	00278713          	addi	a4,a5,2
    80006156:	0712                	slli	a4,a4,0x4
    80006158:	9726                	add	a4,a4,s1
    8000615a:	01074703          	lbu	a4,16(a4) # 10001010 <_entry-0x6fffeff0>
    8000615e:	e721                	bnez	a4,800061a6 <virtio_disk_intr+0xa4>
      panic("virtio_disk_intr status");

    struct buf *b = disk.info[id].b;
    80006160:	0789                	addi	a5,a5,2
    80006162:	0792                	slli	a5,a5,0x4
    80006164:	97a6                	add	a5,a5,s1
    80006166:	6788                	ld	a0,8(a5)
    b->disk = 0;   // disk is done with buf
    80006168:	00052223          	sw	zero,4(a0)
    wakeup(b);
    8000616c:	ffffc097          	auipc	ra,0xffffc
    80006170:	f92080e7          	jalr	-110(ra) # 800020fe <wakeup>

    disk.used_idx += 1;
    80006174:	0204d783          	lhu	a5,32(s1)
    80006178:	2785                	addiw	a5,a5,1
    8000617a:	17c2                	slli	a5,a5,0x30
    8000617c:	93c1                	srli	a5,a5,0x30
    8000617e:	02f49023          	sh	a5,32(s1)
  while(disk.used_idx != disk.used->idx){
    80006182:	6898                	ld	a4,16(s1)
    80006184:	00275703          	lhu	a4,2(a4)
    80006188:	faf71ce3          	bne	a4,a5,80006140 <virtio_disk_intr+0x3e>
  }

  release(&disk.vdisk_lock);
    8000618c:	0001c517          	auipc	a0,0x1c
    80006190:	bac50513          	addi	a0,a0,-1108 # 80021d38 <disk+0x128>
    80006194:	ffffb097          	auipc	ra,0xffffb
    80006198:	af2080e7          	jalr	-1294(ra) # 80000c86 <release>
}
    8000619c:	60e2                	ld	ra,24(sp)
    8000619e:	6442                	ld	s0,16(sp)
    800061a0:	64a2                	ld	s1,8(sp)
    800061a2:	6105                	addi	sp,sp,32
    800061a4:	8082                	ret
      panic("virtio_disk_intr status");
    800061a6:	00002517          	auipc	a0,0x2
    800061aa:	68a50513          	addi	a0,a0,1674 # 80008830 <syscalls+0x3e0>
    800061ae:	ffffa097          	auipc	ra,0xffffa
    800061b2:	38e080e7          	jalr	910(ra) # 8000053c <panic>
	...

0000000080007000 <_trampoline>:
    80007000:	14051073          	csrw	sscratch,a0
    80007004:	02000537          	lui	a0,0x2000
    80007008:	357d                	addiw	a0,a0,-1 # 1ffffff <_entry-0x7e000001>
    8000700a:	0536                	slli	a0,a0,0xd
    8000700c:	02153423          	sd	ra,40(a0)
    80007010:	02253823          	sd	sp,48(a0)
    80007014:	02353c23          	sd	gp,56(a0)
    80007018:	04453023          	sd	tp,64(a0)
    8000701c:	04553423          	sd	t0,72(a0)
    80007020:	04653823          	sd	t1,80(a0)
    80007024:	04753c23          	sd	t2,88(a0)
    80007028:	f120                	sd	s0,96(a0)
    8000702a:	f524                	sd	s1,104(a0)
    8000702c:	fd2c                	sd	a1,120(a0)
    8000702e:	e150                	sd	a2,128(a0)
    80007030:	e554                	sd	a3,136(a0)
    80007032:	e958                	sd	a4,144(a0)
    80007034:	ed5c                	sd	a5,152(a0)
    80007036:	0b053023          	sd	a6,160(a0)
    8000703a:	0b153423          	sd	a7,168(a0)
    8000703e:	0b253823          	sd	s2,176(a0)
    80007042:	0b353c23          	sd	s3,184(a0)
    80007046:	0d453023          	sd	s4,192(a0)
    8000704a:	0d553423          	sd	s5,200(a0)
    8000704e:	0d653823          	sd	s6,208(a0)
    80007052:	0d753c23          	sd	s7,216(a0)
    80007056:	0f853023          	sd	s8,224(a0)
    8000705a:	0f953423          	sd	s9,232(a0)
    8000705e:	0fa53823          	sd	s10,240(a0)
    80007062:	0fb53c23          	sd	s11,248(a0)
    80007066:	11c53023          	sd	t3,256(a0)
    8000706a:	11d53423          	sd	t4,264(a0)
    8000706e:	11e53823          	sd	t5,272(a0)
    80007072:	11f53c23          	sd	t6,280(a0)
    80007076:	140022f3          	csrr	t0,sscratch
    8000707a:	06553823          	sd	t0,112(a0)
    8000707e:	00853103          	ld	sp,8(a0)
    80007082:	02053203          	ld	tp,32(a0)
    80007086:	01053283          	ld	t0,16(a0)
    8000708a:	00053303          	ld	t1,0(a0)
    8000708e:	12000073          	sfence.vma
    80007092:	18031073          	csrw	satp,t1
    80007096:	12000073          	sfence.vma
    8000709a:	8282                	jr	t0

000000008000709c <userret>:
    8000709c:	12000073          	sfence.vma
    800070a0:	18051073          	csrw	satp,a0
    800070a4:	12000073          	sfence.vma
    800070a8:	02000537          	lui	a0,0x2000
    800070ac:	357d                	addiw	a0,a0,-1 # 1ffffff <_entry-0x7e000001>
    800070ae:	0536                	slli	a0,a0,0xd
    800070b0:	02853083          	ld	ra,40(a0)
    800070b4:	03053103          	ld	sp,48(a0)
    800070b8:	03853183          	ld	gp,56(a0)
    800070bc:	04053203          	ld	tp,64(a0)
    800070c0:	04853283          	ld	t0,72(a0)
    800070c4:	05053303          	ld	t1,80(a0)
    800070c8:	05853383          	ld	t2,88(a0)
    800070cc:	7120                	ld	s0,96(a0)
    800070ce:	7524                	ld	s1,104(a0)
    800070d0:	7d2c                	ld	a1,120(a0)
    800070d2:	6150                	ld	a2,128(a0)
    800070d4:	6554                	ld	a3,136(a0)
    800070d6:	6958                	ld	a4,144(a0)
    800070d8:	6d5c                	ld	a5,152(a0)
    800070da:	0a053803          	ld	a6,160(a0)
    800070de:	0a853883          	ld	a7,168(a0)
    800070e2:	0b053903          	ld	s2,176(a0)
    800070e6:	0b853983          	ld	s3,184(a0)
    800070ea:	0c053a03          	ld	s4,192(a0)
    800070ee:	0c853a83          	ld	s5,200(a0)
    800070f2:	0d053b03          	ld	s6,208(a0)
    800070f6:	0d853b83          	ld	s7,216(a0)
    800070fa:	0e053c03          	ld	s8,224(a0)
    800070fe:	0e853c83          	ld	s9,232(a0)
    80007102:	0f053d03          	ld	s10,240(a0)
    80007106:	0f853d83          	ld	s11,248(a0)
    8000710a:	10053e03          	ld	t3,256(a0)
    8000710e:	10853e83          	ld	t4,264(a0)
    80007112:	11053f03          	ld	t5,272(a0)
    80007116:	11853f83          	ld	t6,280(a0)
    8000711a:	7928                	ld	a0,112(a0)
    8000711c:	10200073          	sret
	...
