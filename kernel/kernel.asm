
kernel/kernel:     file format elf64-littleriscv


Disassembly of section .text:

0000000080000000 <_entry>:
    80000000:	00009117          	auipc	sp,0x9
    80000004:	a1013103          	ld	sp,-1520(sp) # 80008a10 <_GLOBAL_OFFSET_TABLE_+0x8>
    80000008:	6505                	lui	a0,0x1
    8000000a:	f14025f3          	csrr	a1,mhartid
    8000000e:	0585                	addi	a1,a1,1
    80000010:	02b50533          	mul	a0,a0,a1
    80000014:	912a                	add	sp,sp,a0
    80000016:	078000ef          	jal	ra,8000008e <start>

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
    80000026:	0007869b          	sext.w	a3,a5

  // ask the CLINT for a timer interrupt.
  int interval = 1000000; // cycles; about 1/10th second in qemu.
  *(uint64*)CLINT_MTIMECMP(id) = *(uint64*)CLINT_MTIME + interval;
    8000002a:	0037979b          	slliw	a5,a5,0x3
    8000002e:	02004737          	lui	a4,0x2004
    80000032:	97ba                	add	a5,a5,a4
    80000034:	0200c737          	lui	a4,0x200c
    80000038:	ff873583          	ld	a1,-8(a4) # 200bff8 <_entry-0x7dff4008>
    8000003c:	000f4637          	lui	a2,0xf4
    80000040:	24060613          	addi	a2,a2,576 # f4240 <_entry-0x7ff0bdc0>
    80000044:	95b2                	add	a1,a1,a2
    80000046:	e38c                	sd	a1,0(a5)

  // prepare information in scratch[] for timervec.
  // scratch[0..2] : space for timervec to save registers.
  // scratch[3] : address of CLINT MTIMECMP register.
  // scratch[4] : desired interval (in cycles) between timer interrupts.
  uint64 *scratch = &timer_scratch[id][0];
    80000048:	00269713          	slli	a4,a3,0x2
    8000004c:	9736                	add	a4,a4,a3
    8000004e:	00371693          	slli	a3,a4,0x3
    80000052:	00009717          	auipc	a4,0x9
    80000056:	a2e70713          	addi	a4,a4,-1490 # 80008a80 <timer_scratch>
    8000005a:	9736                	add	a4,a4,a3
  scratch[3] = CLINT_MTIMECMP(id);
    8000005c:	ef1c                	sd	a5,24(a4)
  scratch[4] = interval;
    8000005e:	f310                	sd	a2,32(a4)
}

static inline void 
w_mscratch(uint64 x)
{
  asm volatile("csrw mscratch, %0" : : "r" (x));
    80000060:	34071073          	csrw	mscratch,a4
  asm volatile("csrw mtvec, %0" : : "r" (x));
    80000064:	00006797          	auipc	a5,0x6
    80000068:	02c78793          	addi	a5,a5,44 # 80006090 <timervec>
    8000006c:	30579073          	csrw	mtvec,a5
  asm volatile("csrr %0, mstatus" : "=r" (x) );
    80000070:	300027f3          	csrr	a5,mstatus

  // set the machine-mode trap handler.
  w_mtvec((uint64)timervec);

  // enable machine-mode interrupts.
  w_mstatus(r_mstatus() | MSTATUS_MIE);
    80000074:	0087e793          	ori	a5,a5,8
  asm volatile("csrw mstatus, %0" : : "r" (x));
    80000078:	30079073          	csrw	mstatus,a5
  asm volatile("csrr %0, mie" : "=r" (x) );
    8000007c:	304027f3          	csrr	a5,mie

  // enable machine-mode timer interrupts.
  w_mie(r_mie() | MIE_MTIE);
    80000080:	0807e793          	ori	a5,a5,128
  asm volatile("csrw mie, %0" : : "r" (x));
    80000084:	30479073          	csrw	mie,a5
}
    80000088:	6422                	ld	s0,8(sp)
    8000008a:	0141                	addi	sp,sp,16
    8000008c:	8082                	ret

000000008000008e <start>:
{
    8000008e:	1141                	addi	sp,sp,-16
    80000090:	e406                	sd	ra,8(sp)
    80000092:	e022                	sd	s0,0(sp)
    80000094:	0800                	addi	s0,sp,16
  asm volatile("csrr %0, mstatus" : "=r" (x) );
    80000096:	300027f3          	csrr	a5,mstatus
  x &= ~MSTATUS_MPP_MASK;
    8000009a:	7779                	lui	a4,0xffffe
    8000009c:	7ff70713          	addi	a4,a4,2047 # ffffffffffffe7ff <end+0xffffffff7ffdc90f>
    800000a0:	8ff9                	and	a5,a5,a4
  x |= MSTATUS_MPP_S;
    800000a2:	6705                	lui	a4,0x1
    800000a4:	80070713          	addi	a4,a4,-2048 # 800 <_entry-0x7ffff800>
    800000a8:	8fd9                	or	a5,a5,a4
  asm volatile("csrw mstatus, %0" : : "r" (x));
    800000aa:	30079073          	csrw	mstatus,a5
  asm volatile("csrw mepc, %0" : : "r" (x));
    800000ae:	00001797          	auipc	a5,0x1
    800000b2:	e9278793          	addi	a5,a5,-366 # 80000f40 <main>
    800000b6:	34179073          	csrw	mepc,a5
  asm volatile("csrw satp, %0" : : "r" (x));
    800000ba:	4781                	li	a5,0
    800000bc:	18079073          	csrw	satp,a5
  asm volatile("csrw medeleg, %0" : : "r" (x));
    800000c0:	67c1                	lui	a5,0x10
    800000c2:	17fd                	addi	a5,a5,-1
    800000c4:	30279073          	csrw	medeleg,a5
  asm volatile("csrw mideleg, %0" : : "r" (x));
    800000c8:	30379073          	csrw	mideleg,a5
  asm volatile("csrr %0, sie" : "=r" (x) );
    800000cc:	104027f3          	csrr	a5,sie
  w_sie(r_sie() | SIE_SEIE | SIE_STIE | SIE_SSIE);
    800000d0:	2227e793          	ori	a5,a5,546
  asm volatile("csrw sie, %0" : : "r" (x));
    800000d4:	10479073          	csrw	sie,a5
  asm volatile("csrw pmpaddr0, %0" : : "r" (x));
    800000d8:	57fd                	li	a5,-1
    800000da:	83a9                	srli	a5,a5,0xa
    800000dc:	3b079073          	csrw	pmpaddr0,a5
  asm volatile("csrw pmpcfg0, %0" : : "r" (x));
    800000e0:	47bd                	li	a5,15
    800000e2:	3a079073          	csrw	pmpcfg0,a5
  timerinit();
    800000e6:	00000097          	auipc	ra,0x0
    800000ea:	f36080e7          	jalr	-202(ra) # 8000001c <timerinit>
  asm volatile("csrr %0, mhartid" : "=r" (x) );
    800000ee:	f14027f3          	csrr	a5,mhartid
  w_tp(id);
    800000f2:	2781                	sext.w	a5,a5
}

static inline void 
w_tp(uint64 x)
{
  asm volatile("mv tp, %0" : : "r" (x));
    800000f4:	823e                	mv	tp,a5
  asm volatile("mret");
    800000f6:	30200073          	mret
}
    800000fa:	60a2                	ld	ra,8(sp)
    800000fc:	6402                	ld	s0,0(sp)
    800000fe:	0141                	addi	sp,sp,16
    80000100:	8082                	ret

0000000080000102 <consolewrite>:

//
// user write()s to the console go here.
//
int consolewrite(int user_src, uint64 src, int n)
{
    80000102:	715d                	addi	sp,sp,-80
    80000104:	e486                	sd	ra,72(sp)
    80000106:	e0a2                	sd	s0,64(sp)
    80000108:	fc26                	sd	s1,56(sp)
    8000010a:	f84a                	sd	s2,48(sp)
    8000010c:	f44e                	sd	s3,40(sp)
    8000010e:	f052                	sd	s4,32(sp)
    80000110:	ec56                	sd	s5,24(sp)
    80000112:	0880                	addi	s0,sp,80
    int i;

    for (i = 0; i < n; i++)
    80000114:	04c05663          	blez	a2,80000160 <consolewrite+0x5e>
    80000118:	8a2a                	mv	s4,a0
    8000011a:	84ae                	mv	s1,a1
    8000011c:	89b2                	mv	s3,a2
    8000011e:	4901                	li	s2,0
    {
        char c;
        if (either_copyin(&c, user_src, src + i, 1) == -1)
    80000120:	5afd                	li	s5,-1
    80000122:	4685                	li	a3,1
    80000124:	8626                	mv	a2,s1
    80000126:	85d2                	mv	a1,s4
    80000128:	fbf40513          	addi	a0,s0,-65
    8000012c:	00002097          	auipc	ra,0x2
    80000130:	606080e7          	jalr	1542(ra) # 80002732 <either_copyin>
    80000134:	01550c63          	beq	a0,s5,8000014c <consolewrite+0x4a>
            break;
        uartputc(c);
    80000138:	fbf44503          	lbu	a0,-65(s0)
    8000013c:	00000097          	auipc	ra,0x0
    80000140:	78a080e7          	jalr	1930(ra) # 800008c6 <uartputc>
    for (i = 0; i < n; i++)
    80000144:	2905                	addiw	s2,s2,1
    80000146:	0485                	addi	s1,s1,1
    80000148:	fd299de3          	bne	s3,s2,80000122 <consolewrite+0x20>
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
    for (i = 0; i < n; i++)
    80000160:	4901                	li	s2,0
    80000162:	b7ed                	j	8000014c <consolewrite+0x4a>

0000000080000164 <consoleread>:
// copy (up to) a whole input line to dst.
// user_dist indicates whether dst is a user
// or kernel address.
//
int consoleread(int user_dst, uint64 dst, int n)
{
    80000164:	7119                	addi	sp,sp,-128
    80000166:	fc86                	sd	ra,120(sp)
    80000168:	f8a2                	sd	s0,112(sp)
    8000016a:	f4a6                	sd	s1,104(sp)
    8000016c:	f0ca                	sd	s2,96(sp)
    8000016e:	ecce                	sd	s3,88(sp)
    80000170:	e8d2                	sd	s4,80(sp)
    80000172:	e4d6                	sd	s5,72(sp)
    80000174:	e0da                	sd	s6,64(sp)
    80000176:	fc5e                	sd	s7,56(sp)
    80000178:	f862                	sd	s8,48(sp)
    8000017a:	f466                	sd	s9,40(sp)
    8000017c:	f06a                	sd	s10,32(sp)
    8000017e:	ec6e                	sd	s11,24(sp)
    80000180:	0100                	addi	s0,sp,128
    80000182:	8b2a                	mv	s6,a0
    80000184:	8aae                	mv	s5,a1
    80000186:	8a32                	mv	s4,a2
    uint target;
    int c;
    char cbuf;

    target = n;
    80000188:	00060b9b          	sext.w	s7,a2
    acquire(&cons.lock);
    8000018c:	00011517          	auipc	a0,0x11
    80000190:	a3450513          	addi	a0,a0,-1484 # 80010bc0 <cons>
    80000194:	00001097          	auipc	ra,0x1
    80000198:	b02080e7          	jalr	-1278(ra) # 80000c96 <acquire>
    while (n > 0)
    {
        // wait until interrupt handler has put some
        // input into cons.buffer.
        while (cons.r == cons.w)
    8000019c:	00011497          	auipc	s1,0x11
    800001a0:	a2448493          	addi	s1,s1,-1500 # 80010bc0 <cons>
            if (killed(myproc()))
            {
                release(&cons.lock);
                return -1;
            }
            sleep(&cons.r, &cons.lock);
    800001a4:	89a6                	mv	s3,s1
    800001a6:	00011917          	auipc	s2,0x11
    800001aa:	ab290913          	addi	s2,s2,-1358 # 80010c58 <cons+0x98>
        }

        c = cons.buf[cons.r++ % INPUT_BUF_SIZE];

        if (c == C('D'))
    800001ae:	4c91                	li	s9,4
            break;
        }

        // copy the input byte to the user-space buffer.
        cbuf = c;
        if (either_copyout(user_dst, dst, &cbuf, 1) == -1)
    800001b0:	5d7d                	li	s10,-1
            break;

        dst++;
        --n;

        if (c == '\n')
    800001b2:	4da9                	li	s11,10
    while (n > 0)
    800001b4:	07405b63          	blez	s4,8000022a <consoleread+0xc6>
        while (cons.r == cons.w)
    800001b8:	0984a783          	lw	a5,152(s1)
    800001bc:	09c4a703          	lw	a4,156(s1)
    800001c0:	02f71763          	bne	a4,a5,800001ee <consoleread+0x8a>
            if (killed(myproc()))
    800001c4:	00002097          	auipc	ra,0x2
    800001c8:	9ac080e7          	jalr	-1620(ra) # 80001b70 <myproc>
    800001cc:	00002097          	auipc	ra,0x2
    800001d0:	3b0080e7          	jalr	944(ra) # 8000257c <killed>
    800001d4:	e535                	bnez	a0,80000240 <consoleread+0xdc>
            sleep(&cons.r, &cons.lock);
    800001d6:	85ce                	mv	a1,s3
    800001d8:	854a                	mv	a0,s2
    800001da:	00002097          	auipc	ra,0x2
    800001de:	0fa080e7          	jalr	250(ra) # 800022d4 <sleep>
        while (cons.r == cons.w)
    800001e2:	0984a783          	lw	a5,152(s1)
    800001e6:	09c4a703          	lw	a4,156(s1)
    800001ea:	fcf70de3          	beq	a4,a5,800001c4 <consoleread+0x60>
        c = cons.buf[cons.r++ % INPUT_BUF_SIZE];
    800001ee:	0017871b          	addiw	a4,a5,1
    800001f2:	08e4ac23          	sw	a4,152(s1)
    800001f6:	07f7f713          	andi	a4,a5,127
    800001fa:	9726                	add	a4,a4,s1
    800001fc:	01874703          	lbu	a4,24(a4)
    80000200:	00070c1b          	sext.w	s8,a4
        if (c == C('D'))
    80000204:	079c0663          	beq	s8,s9,80000270 <consoleread+0x10c>
        cbuf = c;
    80000208:	f8e407a3          	sb	a4,-113(s0)
        if (either_copyout(user_dst, dst, &cbuf, 1) == -1)
    8000020c:	4685                	li	a3,1
    8000020e:	f8f40613          	addi	a2,s0,-113
    80000212:	85d6                	mv	a1,s5
    80000214:	855a                	mv	a0,s6
    80000216:	00002097          	auipc	ra,0x2
    8000021a:	4c6080e7          	jalr	1222(ra) # 800026dc <either_copyout>
    8000021e:	01a50663          	beq	a0,s10,8000022a <consoleread+0xc6>
        dst++;
    80000222:	0a85                	addi	s5,s5,1
        --n;
    80000224:	3a7d                	addiw	s4,s4,-1
        if (c == '\n')
    80000226:	f9bc17e3          	bne	s8,s11,800001b4 <consoleread+0x50>
            // a whole line has arrived, return to
            // the user-level read().
            break;
        }
    }
    release(&cons.lock);
    8000022a:	00011517          	auipc	a0,0x11
    8000022e:	99650513          	addi	a0,a0,-1642 # 80010bc0 <cons>
    80000232:	00001097          	auipc	ra,0x1
    80000236:	b18080e7          	jalr	-1256(ra) # 80000d4a <release>

    return target - n;
    8000023a:	414b853b          	subw	a0,s7,s4
    8000023e:	a811                	j	80000252 <consoleread+0xee>
                release(&cons.lock);
    80000240:	00011517          	auipc	a0,0x11
    80000244:	98050513          	addi	a0,a0,-1664 # 80010bc0 <cons>
    80000248:	00001097          	auipc	ra,0x1
    8000024c:	b02080e7          	jalr	-1278(ra) # 80000d4a <release>
                return -1;
    80000250:	557d                	li	a0,-1
}
    80000252:	70e6                	ld	ra,120(sp)
    80000254:	7446                	ld	s0,112(sp)
    80000256:	74a6                	ld	s1,104(sp)
    80000258:	7906                	ld	s2,96(sp)
    8000025a:	69e6                	ld	s3,88(sp)
    8000025c:	6a46                	ld	s4,80(sp)
    8000025e:	6aa6                	ld	s5,72(sp)
    80000260:	6b06                	ld	s6,64(sp)
    80000262:	7be2                	ld	s7,56(sp)
    80000264:	7c42                	ld	s8,48(sp)
    80000266:	7ca2                	ld	s9,40(sp)
    80000268:	7d02                	ld	s10,32(sp)
    8000026a:	6de2                	ld	s11,24(sp)
    8000026c:	6109                	addi	sp,sp,128
    8000026e:	8082                	ret
            if (n < target)
    80000270:	000a071b          	sext.w	a4,s4
    80000274:	fb777be3          	bgeu	a4,s7,8000022a <consoleread+0xc6>
                cons.r--;
    80000278:	00011717          	auipc	a4,0x11
    8000027c:	9ef72023          	sw	a5,-1568(a4) # 80010c58 <cons+0x98>
    80000280:	b76d                	j	8000022a <consoleread+0xc6>

0000000080000282 <consputc>:
{
    80000282:	1141                	addi	sp,sp,-16
    80000284:	e406                	sd	ra,8(sp)
    80000286:	e022                	sd	s0,0(sp)
    80000288:	0800                	addi	s0,sp,16
    if (c == BACKSPACE)
    8000028a:	10000793          	li	a5,256
    8000028e:	00f50a63          	beq	a0,a5,800002a2 <consputc+0x20>
        uartputc_sync(c);
    80000292:	00000097          	auipc	ra,0x0
    80000296:	55a080e7          	jalr	1370(ra) # 800007ec <uartputc_sync>
}
    8000029a:	60a2                	ld	ra,8(sp)
    8000029c:	6402                	ld	s0,0(sp)
    8000029e:	0141                	addi	sp,sp,16
    800002a0:	8082                	ret
        uartputc_sync('\b');
    800002a2:	4521                	li	a0,8
    800002a4:	00000097          	auipc	ra,0x0
    800002a8:	548080e7          	jalr	1352(ra) # 800007ec <uartputc_sync>
        uartputc_sync(' ');
    800002ac:	02000513          	li	a0,32
    800002b0:	00000097          	auipc	ra,0x0
    800002b4:	53c080e7          	jalr	1340(ra) # 800007ec <uartputc_sync>
        uartputc_sync('\b');
    800002b8:	4521                	li	a0,8
    800002ba:	00000097          	auipc	ra,0x0
    800002be:	532080e7          	jalr	1330(ra) # 800007ec <uartputc_sync>
    800002c2:	bfe1                	j	8000029a <consputc+0x18>

00000000800002c4 <consoleintr>:
// uartintr() calls this for input character.
// do erase/kill processing, append to cons.buf,
// wake up consoleread() if a whole line has arrived.
//
void consoleintr(int c)
{
    800002c4:	1101                	addi	sp,sp,-32
    800002c6:	ec06                	sd	ra,24(sp)
    800002c8:	e822                	sd	s0,16(sp)
    800002ca:	e426                	sd	s1,8(sp)
    800002cc:	e04a                	sd	s2,0(sp)
    800002ce:	1000                	addi	s0,sp,32
    800002d0:	84aa                	mv	s1,a0
    acquire(&cons.lock);
    800002d2:	00011517          	auipc	a0,0x11
    800002d6:	8ee50513          	addi	a0,a0,-1810 # 80010bc0 <cons>
    800002da:	00001097          	auipc	ra,0x1
    800002de:	9bc080e7          	jalr	-1604(ra) # 80000c96 <acquire>

    switch (c)
    800002e2:	47d5                	li	a5,21
    800002e4:	0af48663          	beq	s1,a5,80000390 <consoleintr+0xcc>
    800002e8:	0297ca63          	blt	a5,s1,8000031c <consoleintr+0x58>
    800002ec:	47a1                	li	a5,8
    800002ee:	0ef48763          	beq	s1,a5,800003dc <consoleintr+0x118>
    800002f2:	47c1                	li	a5,16
    800002f4:	10f49a63          	bne	s1,a5,80000408 <consoleintr+0x144>
    {
    case C('P'): // Print process list.
        procdump();
    800002f8:	00002097          	auipc	ra,0x2
    800002fc:	490080e7          	jalr	1168(ra) # 80002788 <procdump>
            }
        }
        break;
    }

    release(&cons.lock);
    80000300:	00011517          	auipc	a0,0x11
    80000304:	8c050513          	addi	a0,a0,-1856 # 80010bc0 <cons>
    80000308:	00001097          	auipc	ra,0x1
    8000030c:	a42080e7          	jalr	-1470(ra) # 80000d4a <release>
}
    80000310:	60e2                	ld	ra,24(sp)
    80000312:	6442                	ld	s0,16(sp)
    80000314:	64a2                	ld	s1,8(sp)
    80000316:	6902                	ld	s2,0(sp)
    80000318:	6105                	addi	sp,sp,32
    8000031a:	8082                	ret
    switch (c)
    8000031c:	07f00793          	li	a5,127
    80000320:	0af48e63          	beq	s1,a5,800003dc <consoleintr+0x118>
        if (c != 0 && cons.e - cons.r < INPUT_BUF_SIZE)
    80000324:	00011717          	auipc	a4,0x11
    80000328:	89c70713          	addi	a4,a4,-1892 # 80010bc0 <cons>
    8000032c:	0a072783          	lw	a5,160(a4)
    80000330:	09872703          	lw	a4,152(a4)
    80000334:	9f99                	subw	a5,a5,a4
    80000336:	07f00713          	li	a4,127
    8000033a:	fcf763e3          	bltu	a4,a5,80000300 <consoleintr+0x3c>
            c = (c == '\r') ? '\n' : c;
    8000033e:	47b5                	li	a5,13
    80000340:	0cf48763          	beq	s1,a5,8000040e <consoleintr+0x14a>
            consputc(c);
    80000344:	8526                	mv	a0,s1
    80000346:	00000097          	auipc	ra,0x0
    8000034a:	f3c080e7          	jalr	-196(ra) # 80000282 <consputc>
            cons.buf[cons.e++ % INPUT_BUF_SIZE] = c;
    8000034e:	00011797          	auipc	a5,0x11
    80000352:	87278793          	addi	a5,a5,-1934 # 80010bc0 <cons>
    80000356:	0a07a683          	lw	a3,160(a5)
    8000035a:	0016871b          	addiw	a4,a3,1
    8000035e:	0007061b          	sext.w	a2,a4
    80000362:	0ae7a023          	sw	a4,160(a5)
    80000366:	07f6f693          	andi	a3,a3,127
    8000036a:	97b6                	add	a5,a5,a3
    8000036c:	00978c23          	sb	s1,24(a5)
            if (c == '\n' || c == C('D') || cons.e - cons.r == INPUT_BUF_SIZE)
    80000370:	47a9                	li	a5,10
    80000372:	0cf48563          	beq	s1,a5,8000043c <consoleintr+0x178>
    80000376:	4791                	li	a5,4
    80000378:	0cf48263          	beq	s1,a5,8000043c <consoleintr+0x178>
    8000037c:	00011797          	auipc	a5,0x11
    80000380:	8dc7a783          	lw	a5,-1828(a5) # 80010c58 <cons+0x98>
    80000384:	9f1d                	subw	a4,a4,a5
    80000386:	08000793          	li	a5,128
    8000038a:	f6f71be3          	bne	a4,a5,80000300 <consoleintr+0x3c>
    8000038e:	a07d                	j	8000043c <consoleintr+0x178>
        while (cons.e != cons.w &&
    80000390:	00011717          	auipc	a4,0x11
    80000394:	83070713          	addi	a4,a4,-2000 # 80010bc0 <cons>
    80000398:	0a072783          	lw	a5,160(a4)
    8000039c:	09c72703          	lw	a4,156(a4)
               cons.buf[(cons.e - 1) % INPUT_BUF_SIZE] != '\n')
    800003a0:	00011497          	auipc	s1,0x11
    800003a4:	82048493          	addi	s1,s1,-2016 # 80010bc0 <cons>
        while (cons.e != cons.w &&
    800003a8:	4929                	li	s2,10
    800003aa:	f4f70be3          	beq	a4,a5,80000300 <consoleintr+0x3c>
               cons.buf[(cons.e - 1) % INPUT_BUF_SIZE] != '\n')
    800003ae:	37fd                	addiw	a5,a5,-1
    800003b0:	07f7f713          	andi	a4,a5,127
    800003b4:	9726                	add	a4,a4,s1
        while (cons.e != cons.w &&
    800003b6:	01874703          	lbu	a4,24(a4)
    800003ba:	f52703e3          	beq	a4,s2,80000300 <consoleintr+0x3c>
            cons.e--;
    800003be:	0af4a023          	sw	a5,160(s1)
            consputc(BACKSPACE);
    800003c2:	10000513          	li	a0,256
    800003c6:	00000097          	auipc	ra,0x0
    800003ca:	ebc080e7          	jalr	-324(ra) # 80000282 <consputc>
        while (cons.e != cons.w &&
    800003ce:	0a04a783          	lw	a5,160(s1)
    800003d2:	09c4a703          	lw	a4,156(s1)
    800003d6:	fcf71ce3          	bne	a4,a5,800003ae <consoleintr+0xea>
    800003da:	b71d                	j	80000300 <consoleintr+0x3c>
        if (cons.e != cons.w)
    800003dc:	00010717          	auipc	a4,0x10
    800003e0:	7e470713          	addi	a4,a4,2020 # 80010bc0 <cons>
    800003e4:	0a072783          	lw	a5,160(a4)
    800003e8:	09c72703          	lw	a4,156(a4)
    800003ec:	f0f70ae3          	beq	a4,a5,80000300 <consoleintr+0x3c>
            cons.e--;
    800003f0:	37fd                	addiw	a5,a5,-1
    800003f2:	00011717          	auipc	a4,0x11
    800003f6:	86f72723          	sw	a5,-1938(a4) # 80010c60 <cons+0xa0>
            consputc(BACKSPACE);
    800003fa:	10000513          	li	a0,256
    800003fe:	00000097          	auipc	ra,0x0
    80000402:	e84080e7          	jalr	-380(ra) # 80000282 <consputc>
    80000406:	bded                	j	80000300 <consoleintr+0x3c>
        if (c != 0 && cons.e - cons.r < INPUT_BUF_SIZE)
    80000408:	ee048ce3          	beqz	s1,80000300 <consoleintr+0x3c>
    8000040c:	bf21                	j	80000324 <consoleintr+0x60>
            consputc(c);
    8000040e:	4529                	li	a0,10
    80000410:	00000097          	auipc	ra,0x0
    80000414:	e72080e7          	jalr	-398(ra) # 80000282 <consputc>
            cons.buf[cons.e++ % INPUT_BUF_SIZE] = c;
    80000418:	00010797          	auipc	a5,0x10
    8000041c:	7a878793          	addi	a5,a5,1960 # 80010bc0 <cons>
    80000420:	0a07a703          	lw	a4,160(a5)
    80000424:	0017069b          	addiw	a3,a4,1
    80000428:	0006861b          	sext.w	a2,a3
    8000042c:	0ad7a023          	sw	a3,160(a5)
    80000430:	07f77713          	andi	a4,a4,127
    80000434:	97ba                	add	a5,a5,a4
    80000436:	4729                	li	a4,10
    80000438:	00e78c23          	sb	a4,24(a5)
                cons.w = cons.e;
    8000043c:	00011797          	auipc	a5,0x11
    80000440:	82c7a023          	sw	a2,-2016(a5) # 80010c5c <cons+0x9c>
                wakeup(&cons.r);
    80000444:	00011517          	auipc	a0,0x11
    80000448:	81450513          	addi	a0,a0,-2028 # 80010c58 <cons+0x98>
    8000044c:	00002097          	auipc	ra,0x2
    80000450:	eec080e7          	jalr	-276(ra) # 80002338 <wakeup>
    80000454:	b575                	j	80000300 <consoleintr+0x3c>

0000000080000456 <consoleinit>:

void consoleinit(void)
{
    80000456:	1141                	addi	sp,sp,-16
    80000458:	e406                	sd	ra,8(sp)
    8000045a:	e022                	sd	s0,0(sp)
    8000045c:	0800                	addi	s0,sp,16
    initlock(&cons.lock, "cons");
    8000045e:	00008597          	auipc	a1,0x8
    80000462:	bc258593          	addi	a1,a1,-1086 # 80008020 <__func__.1508+0x18>
    80000466:	00010517          	auipc	a0,0x10
    8000046a:	75a50513          	addi	a0,a0,1882 # 80010bc0 <cons>
    8000046e:	00000097          	auipc	ra,0x0
    80000472:	798080e7          	jalr	1944(ra) # 80000c06 <initlock>

    uartinit();
    80000476:	00000097          	auipc	ra,0x0
    8000047a:	326080e7          	jalr	806(ra) # 8000079c <uartinit>

    // connect read and write system calls
    // to consoleread and consolewrite.
    devsw[CONSOLE].read = consoleread;
    8000047e:	00021797          	auipc	a5,0x21
    80000482:	8da78793          	addi	a5,a5,-1830 # 80020d58 <devsw>
    80000486:	00000717          	auipc	a4,0x0
    8000048a:	cde70713          	addi	a4,a4,-802 # 80000164 <consoleread>
    8000048e:	eb98                	sd	a4,16(a5)
    devsw[CONSOLE].write = consolewrite;
    80000490:	00000717          	auipc	a4,0x0
    80000494:	c7270713          	addi	a4,a4,-910 # 80000102 <consolewrite>
    80000498:	ef98                	sd	a4,24(a5)
}
    8000049a:	60a2                	ld	ra,8(sp)
    8000049c:	6402                	ld	s0,0(sp)
    8000049e:	0141                	addi	sp,sp,16
    800004a0:	8082                	ret

00000000800004a2 <printint>:

static char digits[] = "0123456789abcdef";

static void
printint(int xx, int base, int sign)
{
    800004a2:	7179                	addi	sp,sp,-48
    800004a4:	f406                	sd	ra,40(sp)
    800004a6:	f022                	sd	s0,32(sp)
    800004a8:	ec26                	sd	s1,24(sp)
    800004aa:	e84a                	sd	s2,16(sp)
    800004ac:	1800                	addi	s0,sp,48
    char buf[16];
    int i;
    uint x;

    if (sign && (sign = xx < 0))
    800004ae:	c219                	beqz	a2,800004b4 <printint+0x12>
    800004b0:	06054963          	bltz	a0,80000522 <printint+0x80>
        x = -xx;
    else
        x = xx;
    800004b4:	2501                	sext.w	a0,a0
{
    800004b6:	fd040693          	addi	a3,s0,-48
    800004ba:	4701                	li	a4,0

    i = 0;
    do
    {
        buf[i++] = digits[x % base];
    800004bc:	2581                	sext.w	a1,a1
    800004be:	00008817          	auipc	a6,0x8
    800004c2:	b9280813          	addi	a6,a6,-1134 # 80008050 <digits>
    800004c6:	863a                	mv	a2,a4
    800004c8:	2705                	addiw	a4,a4,1
    800004ca:	02b577bb          	remuw	a5,a0,a1
    800004ce:	1782                	slli	a5,a5,0x20
    800004d0:	9381                	srli	a5,a5,0x20
    800004d2:	97c2                	add	a5,a5,a6
    800004d4:	0007c783          	lbu	a5,0(a5)
    800004d8:	00f68023          	sb	a5,0(a3)
    } while ((x /= base) != 0);
    800004dc:	0005079b          	sext.w	a5,a0
    800004e0:	02b5553b          	divuw	a0,a0,a1
    800004e4:	0685                	addi	a3,a3,1
    800004e6:	feb7f0e3          	bgeu	a5,a1,800004c6 <printint+0x24>

    /*
    if (sign)
        buf[i++] = '-'; */

    while (--i >= 0)
    800004ea:	02064663          	bltz	a2,80000516 <printint+0x74>
    800004ee:	fd040793          	addi	a5,s0,-48
    800004f2:	00c784b3          	add	s1,a5,a2
    800004f6:	fff78913          	addi	s2,a5,-1
    800004fa:	9932                	add	s2,s2,a2
    800004fc:	1602                	slli	a2,a2,0x20
    800004fe:	9201                	srli	a2,a2,0x20
    80000500:	40c90933          	sub	s2,s2,a2
        consputc(buf[i]);
    80000504:	0004c503          	lbu	a0,0(s1)
    80000508:	00000097          	auipc	ra,0x0
    8000050c:	d7a080e7          	jalr	-646(ra) # 80000282 <consputc>
    while (--i >= 0)
    80000510:	14fd                	addi	s1,s1,-1
    80000512:	ff2499e3          	bne	s1,s2,80000504 <printint+0x62>
}
    80000516:	70a2                	ld	ra,40(sp)
    80000518:	7402                	ld	s0,32(sp)
    8000051a:	64e2                	ld	s1,24(sp)
    8000051c:	6942                	ld	s2,16(sp)
    8000051e:	6145                	addi	sp,sp,48
    80000520:	8082                	ret
        x = -xx;
    80000522:	40a0053b          	negw	a0,a0
    80000526:	bf41                	j	800004b6 <printint+0x14>

0000000080000528 <panic>:
    if (locking)
        release(&pr.lock);
}

void panic(char *s, ...)
{
    80000528:	711d                	addi	sp,sp,-96
    8000052a:	ec06                	sd	ra,24(sp)
    8000052c:	e822                	sd	s0,16(sp)
    8000052e:	e426                	sd	s1,8(sp)
    80000530:	1000                	addi	s0,sp,32
    80000532:	84aa                	mv	s1,a0
    80000534:	e40c                	sd	a1,8(s0)
    80000536:	e810                	sd	a2,16(s0)
    80000538:	ec14                	sd	a3,24(s0)
    8000053a:	f018                	sd	a4,32(s0)
    8000053c:	f41c                	sd	a5,40(s0)
    8000053e:	03043823          	sd	a6,48(s0)
    80000542:	03143c23          	sd	a7,56(s0)
    pr.locking = 0;
    80000546:	00010797          	auipc	a5,0x10
    8000054a:	7207ad23          	sw	zero,1850(a5) # 80010c80 <pr+0x18>
    printf("panic: ");
    8000054e:	00008517          	auipc	a0,0x8
    80000552:	ada50513          	addi	a0,a0,-1318 # 80008028 <__func__.1508+0x20>
    80000556:	00000097          	auipc	ra,0x0
    8000055a:	02e080e7          	jalr	46(ra) # 80000584 <printf>
    printf(s);
    8000055e:	8526                	mv	a0,s1
    80000560:	00000097          	auipc	ra,0x0
    80000564:	024080e7          	jalr	36(ra) # 80000584 <printf>
    printf("\n");
    80000568:	00008517          	auipc	a0,0x8
    8000056c:	b2050513          	addi	a0,a0,-1248 # 80008088 <digits+0x38>
    80000570:	00000097          	auipc	ra,0x0
    80000574:	014080e7          	jalr	20(ra) # 80000584 <printf>
    panicked = 1; // freeze uart output from other CPUs
    80000578:	4785                	li	a5,1
    8000057a:	00008717          	auipc	a4,0x8
    8000057e:	4af72b23          	sw	a5,1206(a4) # 80008a30 <panicked>
    for (;;)
    80000582:	a001                	j	80000582 <panic+0x5a>

0000000080000584 <printf>:
{
    80000584:	7131                	addi	sp,sp,-192
    80000586:	fc86                	sd	ra,120(sp)
    80000588:	f8a2                	sd	s0,112(sp)
    8000058a:	f4a6                	sd	s1,104(sp)
    8000058c:	f0ca                	sd	s2,96(sp)
    8000058e:	ecce                	sd	s3,88(sp)
    80000590:	e8d2                	sd	s4,80(sp)
    80000592:	e4d6                	sd	s5,72(sp)
    80000594:	e0da                	sd	s6,64(sp)
    80000596:	fc5e                	sd	s7,56(sp)
    80000598:	f862                	sd	s8,48(sp)
    8000059a:	f466                	sd	s9,40(sp)
    8000059c:	f06a                	sd	s10,32(sp)
    8000059e:	ec6e                	sd	s11,24(sp)
    800005a0:	0100                	addi	s0,sp,128
    800005a2:	8a2a                	mv	s4,a0
    800005a4:	e40c                	sd	a1,8(s0)
    800005a6:	e810                	sd	a2,16(s0)
    800005a8:	ec14                	sd	a3,24(s0)
    800005aa:	f018                	sd	a4,32(s0)
    800005ac:	f41c                	sd	a5,40(s0)
    800005ae:	03043823          	sd	a6,48(s0)
    800005b2:	03143c23          	sd	a7,56(s0)
    locking = pr.locking;
    800005b6:	00010d97          	auipc	s11,0x10
    800005ba:	6cadad83          	lw	s11,1738(s11) # 80010c80 <pr+0x18>
    if (locking)
    800005be:	020d9b63          	bnez	s11,800005f4 <printf+0x70>
    if (fmt == 0)
    800005c2:	040a0263          	beqz	s4,80000606 <printf+0x82>
    va_start(ap, fmt);
    800005c6:	00840793          	addi	a5,s0,8
    800005ca:	f8f43423          	sd	a5,-120(s0)
    for (i = 0; (c = fmt[i] & 0xff) != 0; i++)
    800005ce:	000a4503          	lbu	a0,0(s4)
    800005d2:	16050263          	beqz	a0,80000736 <printf+0x1b2>
    800005d6:	4481                	li	s1,0
        if (c != '%')
    800005d8:	02500a93          	li	s5,37
        switch (c)
    800005dc:	07000b13          	li	s6,112
    consputc('x');
    800005e0:	4d41                	li	s10,16
        consputc(digits[x >> (sizeof(uint64) * 8 - 4)]);
    800005e2:	00008b97          	auipc	s7,0x8
    800005e6:	a6eb8b93          	addi	s7,s7,-1426 # 80008050 <digits>
        switch (c)
    800005ea:	07300c93          	li	s9,115
    800005ee:	06400c13          	li	s8,100
    800005f2:	a82d                	j	8000062c <printf+0xa8>
        acquire(&pr.lock);
    800005f4:	00010517          	auipc	a0,0x10
    800005f8:	67450513          	addi	a0,a0,1652 # 80010c68 <pr>
    800005fc:	00000097          	auipc	ra,0x0
    80000600:	69a080e7          	jalr	1690(ra) # 80000c96 <acquire>
    80000604:	bf7d                	j	800005c2 <printf+0x3e>
        panic("null fmt");
    80000606:	00008517          	auipc	a0,0x8
    8000060a:	a3250513          	addi	a0,a0,-1486 # 80008038 <__func__.1508+0x30>
    8000060e:	00000097          	auipc	ra,0x0
    80000612:	f1a080e7          	jalr	-230(ra) # 80000528 <panic>
            consputc(c);
    80000616:	00000097          	auipc	ra,0x0
    8000061a:	c6c080e7          	jalr	-916(ra) # 80000282 <consputc>
    for (i = 0; (c = fmt[i] & 0xff) != 0; i++)
    8000061e:	2485                	addiw	s1,s1,1
    80000620:	009a07b3          	add	a5,s4,s1
    80000624:	0007c503          	lbu	a0,0(a5)
    80000628:	10050763          	beqz	a0,80000736 <printf+0x1b2>
        if (c != '%')
    8000062c:	ff5515e3          	bne	a0,s5,80000616 <printf+0x92>
        c = fmt[++i] & 0xff;
    80000630:	2485                	addiw	s1,s1,1
    80000632:	009a07b3          	add	a5,s4,s1
    80000636:	0007c783          	lbu	a5,0(a5)
    8000063a:	0007891b          	sext.w	s2,a5
        if (c == 0)
    8000063e:	cfe5                	beqz	a5,80000736 <printf+0x1b2>
        switch (c)
    80000640:	05678a63          	beq	a5,s6,80000694 <printf+0x110>
    80000644:	02fb7663          	bgeu	s6,a5,80000670 <printf+0xec>
    80000648:	09978963          	beq	a5,s9,800006da <printf+0x156>
    8000064c:	07800713          	li	a4,120
    80000650:	0ce79863          	bne	a5,a4,80000720 <printf+0x19c>
            printint(va_arg(ap, int), 16, 1);
    80000654:	f8843783          	ld	a5,-120(s0)
    80000658:	00878713          	addi	a4,a5,8
    8000065c:	f8e43423          	sd	a4,-120(s0)
    80000660:	4605                	li	a2,1
    80000662:	85ea                	mv	a1,s10
    80000664:	4388                	lw	a0,0(a5)
    80000666:	00000097          	auipc	ra,0x0
    8000066a:	e3c080e7          	jalr	-452(ra) # 800004a2 <printint>
            break;
    8000066e:	bf45                	j	8000061e <printf+0x9a>
        switch (c)
    80000670:	0b578263          	beq	a5,s5,80000714 <printf+0x190>
    80000674:	0b879663          	bne	a5,s8,80000720 <printf+0x19c>
            printint(va_arg(ap, int), 10, 1);
    80000678:	f8843783          	ld	a5,-120(s0)
    8000067c:	00878713          	addi	a4,a5,8
    80000680:	f8e43423          	sd	a4,-120(s0)
    80000684:	4605                	li	a2,1
    80000686:	45a9                	li	a1,10
    80000688:	4388                	lw	a0,0(a5)
    8000068a:	00000097          	auipc	ra,0x0
    8000068e:	e18080e7          	jalr	-488(ra) # 800004a2 <printint>
            break;
    80000692:	b771                	j	8000061e <printf+0x9a>
            printptr(va_arg(ap, uint64));
    80000694:	f8843783          	ld	a5,-120(s0)
    80000698:	00878713          	addi	a4,a5,8
    8000069c:	f8e43423          	sd	a4,-120(s0)
    800006a0:	0007b983          	ld	s3,0(a5)
    consputc('0');
    800006a4:	03000513          	li	a0,48
    800006a8:	00000097          	auipc	ra,0x0
    800006ac:	bda080e7          	jalr	-1062(ra) # 80000282 <consputc>
    consputc('x');
    800006b0:	07800513          	li	a0,120
    800006b4:	00000097          	auipc	ra,0x0
    800006b8:	bce080e7          	jalr	-1074(ra) # 80000282 <consputc>
    800006bc:	896a                	mv	s2,s10
        consputc(digits[x >> (sizeof(uint64) * 8 - 4)]);
    800006be:	03c9d793          	srli	a5,s3,0x3c
    800006c2:	97de                	add	a5,a5,s7
    800006c4:	0007c503          	lbu	a0,0(a5)
    800006c8:	00000097          	auipc	ra,0x0
    800006cc:	bba080e7          	jalr	-1094(ra) # 80000282 <consputc>
    for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
    800006d0:	0992                	slli	s3,s3,0x4
    800006d2:	397d                	addiw	s2,s2,-1
    800006d4:	fe0915e3          	bnez	s2,800006be <printf+0x13a>
    800006d8:	b799                	j	8000061e <printf+0x9a>
            if ((s = va_arg(ap, char *)) == 0)
    800006da:	f8843783          	ld	a5,-120(s0)
    800006de:	00878713          	addi	a4,a5,8
    800006e2:	f8e43423          	sd	a4,-120(s0)
    800006e6:	0007b903          	ld	s2,0(a5)
    800006ea:	00090e63          	beqz	s2,80000706 <printf+0x182>
            for (; *s; s++)
    800006ee:	00094503          	lbu	a0,0(s2)
    800006f2:	d515                	beqz	a0,8000061e <printf+0x9a>
                consputc(*s);
    800006f4:	00000097          	auipc	ra,0x0
    800006f8:	b8e080e7          	jalr	-1138(ra) # 80000282 <consputc>
            for (; *s; s++)
    800006fc:	0905                	addi	s2,s2,1
    800006fe:	00094503          	lbu	a0,0(s2)
    80000702:	f96d                	bnez	a0,800006f4 <printf+0x170>
    80000704:	bf29                	j	8000061e <printf+0x9a>
                s = "(null)";
    80000706:	00008917          	auipc	s2,0x8
    8000070a:	92a90913          	addi	s2,s2,-1750 # 80008030 <__func__.1508+0x28>
            for (; *s; s++)
    8000070e:	02800513          	li	a0,40
    80000712:	b7cd                	j	800006f4 <printf+0x170>
            consputc('%');
    80000714:	8556                	mv	a0,s5
    80000716:	00000097          	auipc	ra,0x0
    8000071a:	b6c080e7          	jalr	-1172(ra) # 80000282 <consputc>
            break;
    8000071e:	b701                	j	8000061e <printf+0x9a>
            consputc('%');
    80000720:	8556                	mv	a0,s5
    80000722:	00000097          	auipc	ra,0x0
    80000726:	b60080e7          	jalr	-1184(ra) # 80000282 <consputc>
            consputc(c);
    8000072a:	854a                	mv	a0,s2
    8000072c:	00000097          	auipc	ra,0x0
    80000730:	b56080e7          	jalr	-1194(ra) # 80000282 <consputc>
            break;
    80000734:	b5ed                	j	8000061e <printf+0x9a>
    if (locking)
    80000736:	020d9163          	bnez	s11,80000758 <printf+0x1d4>
}
    8000073a:	70e6                	ld	ra,120(sp)
    8000073c:	7446                	ld	s0,112(sp)
    8000073e:	74a6                	ld	s1,104(sp)
    80000740:	7906                	ld	s2,96(sp)
    80000742:	69e6                	ld	s3,88(sp)
    80000744:	6a46                	ld	s4,80(sp)
    80000746:	6aa6                	ld	s5,72(sp)
    80000748:	6b06                	ld	s6,64(sp)
    8000074a:	7be2                	ld	s7,56(sp)
    8000074c:	7c42                	ld	s8,48(sp)
    8000074e:	7ca2                	ld	s9,40(sp)
    80000750:	7d02                	ld	s10,32(sp)
    80000752:	6de2                	ld	s11,24(sp)
    80000754:	6129                	addi	sp,sp,192
    80000756:	8082                	ret
        release(&pr.lock);
    80000758:	00010517          	auipc	a0,0x10
    8000075c:	51050513          	addi	a0,a0,1296 # 80010c68 <pr>
    80000760:	00000097          	auipc	ra,0x0
    80000764:	5ea080e7          	jalr	1514(ra) # 80000d4a <release>
}
    80000768:	bfc9                	j	8000073a <printf+0x1b6>

000000008000076a <printfinit>:
        ;
}

void printfinit(void)
{
    8000076a:	1101                	addi	sp,sp,-32
    8000076c:	ec06                	sd	ra,24(sp)
    8000076e:	e822                	sd	s0,16(sp)
    80000770:	e426                	sd	s1,8(sp)
    80000772:	1000                	addi	s0,sp,32
    initlock(&pr.lock, "pr");
    80000774:	00010497          	auipc	s1,0x10
    80000778:	4f448493          	addi	s1,s1,1268 # 80010c68 <pr>
    8000077c:	00008597          	auipc	a1,0x8
    80000780:	8cc58593          	addi	a1,a1,-1844 # 80008048 <__func__.1508+0x40>
    80000784:	8526                	mv	a0,s1
    80000786:	00000097          	auipc	ra,0x0
    8000078a:	480080e7          	jalr	1152(ra) # 80000c06 <initlock>
    pr.locking = 1;
    8000078e:	4785                	li	a5,1
    80000790:	cc9c                	sw	a5,24(s1)
}
    80000792:	60e2                	ld	ra,24(sp)
    80000794:	6442                	ld	s0,16(sp)
    80000796:	64a2                	ld	s1,8(sp)
    80000798:	6105                	addi	sp,sp,32
    8000079a:	8082                	ret

000000008000079c <uartinit>:

void uartstart();

void
uartinit(void)
{
    8000079c:	1141                	addi	sp,sp,-16
    8000079e:	e406                	sd	ra,8(sp)
    800007a0:	e022                	sd	s0,0(sp)
    800007a2:	0800                	addi	s0,sp,16
  // disable interrupts.
  WriteReg(IER, 0x00);
    800007a4:	100007b7          	lui	a5,0x10000
    800007a8:	000780a3          	sb	zero,1(a5) # 10000001 <_entry-0x6fffffff>

  // special mode to set baud rate.
  WriteReg(LCR, LCR_BAUD_LATCH);
    800007ac:	f8000713          	li	a4,-128
    800007b0:	00e781a3          	sb	a4,3(a5)

  // LSB for baud rate of 38.4K.
  WriteReg(0, 0x03);
    800007b4:	470d                	li	a4,3
    800007b6:	00e78023          	sb	a4,0(a5)

  // MSB for baud rate of 38.4K.
  WriteReg(1, 0x00);
    800007ba:	000780a3          	sb	zero,1(a5)

  // leave set-baud mode,
  // and set word length to 8 bits, no parity.
  WriteReg(LCR, LCR_EIGHT_BITS);
    800007be:	00e781a3          	sb	a4,3(a5)

  // reset and enable FIFOs.
  WriteReg(FCR, FCR_FIFO_ENABLE | FCR_FIFO_CLEAR);
    800007c2:	469d                	li	a3,7
    800007c4:	00d78123          	sb	a3,2(a5)

  // enable transmit and receive interrupts.
  WriteReg(IER, IER_TX_ENABLE | IER_RX_ENABLE);
    800007c8:	00e780a3          	sb	a4,1(a5)

  initlock(&uart_tx_lock, "uart");
    800007cc:	00008597          	auipc	a1,0x8
    800007d0:	89c58593          	addi	a1,a1,-1892 # 80008068 <digits+0x18>
    800007d4:	00010517          	auipc	a0,0x10
    800007d8:	4b450513          	addi	a0,a0,1204 # 80010c88 <uart_tx_lock>
    800007dc:	00000097          	auipc	ra,0x0
    800007e0:	42a080e7          	jalr	1066(ra) # 80000c06 <initlock>
}
    800007e4:	60a2                	ld	ra,8(sp)
    800007e6:	6402                	ld	s0,0(sp)
    800007e8:	0141                	addi	sp,sp,16
    800007ea:	8082                	ret

00000000800007ec <uartputc_sync>:
// use interrupts, for use by kernel printf() and
// to echo characters. it spins waiting for the uart's
// output register to be empty.
void
uartputc_sync(int c)
{
    800007ec:	1101                	addi	sp,sp,-32
    800007ee:	ec06                	sd	ra,24(sp)
    800007f0:	e822                	sd	s0,16(sp)
    800007f2:	e426                	sd	s1,8(sp)
    800007f4:	1000                	addi	s0,sp,32
    800007f6:	84aa                	mv	s1,a0
  push_off();
    800007f8:	00000097          	auipc	ra,0x0
    800007fc:	452080e7          	jalr	1106(ra) # 80000c4a <push_off>

  if(panicked){
    80000800:	00008797          	auipc	a5,0x8
    80000804:	2307a783          	lw	a5,560(a5) # 80008a30 <panicked>
    for(;;)
      ;
  }

  // wait for Transmit Holding Empty to be set in LSR.
  while((ReadReg(LSR) & LSR_TX_IDLE) == 0)
    80000808:	10000737          	lui	a4,0x10000
  if(panicked){
    8000080c:	c391                	beqz	a5,80000810 <uartputc_sync+0x24>
    for(;;)
    8000080e:	a001                	j	8000080e <uartputc_sync+0x22>
  while((ReadReg(LSR) & LSR_TX_IDLE) == 0)
    80000810:	00574783          	lbu	a5,5(a4) # 10000005 <_entry-0x6ffffffb>
    80000814:	0ff7f793          	andi	a5,a5,255
    80000818:	0207f793          	andi	a5,a5,32
    8000081c:	dbf5                	beqz	a5,80000810 <uartputc_sync+0x24>
    ;
  WriteReg(THR, c);
    8000081e:	0ff4f793          	andi	a5,s1,255
    80000822:	10000737          	lui	a4,0x10000
    80000826:	00f70023          	sb	a5,0(a4) # 10000000 <_entry-0x70000000>

  pop_off();
    8000082a:	00000097          	auipc	ra,0x0
    8000082e:	4c0080e7          	jalr	1216(ra) # 80000cea <pop_off>
}
    80000832:	60e2                	ld	ra,24(sp)
    80000834:	6442                	ld	s0,16(sp)
    80000836:	64a2                	ld	s1,8(sp)
    80000838:	6105                	addi	sp,sp,32
    8000083a:	8082                	ret

000000008000083c <uartstart>:
// called from both the top- and bottom-half.
void
uartstart()
{
  while(1){
    if(uart_tx_w == uart_tx_r){
    8000083c:	00008717          	auipc	a4,0x8
    80000840:	1fc73703          	ld	a4,508(a4) # 80008a38 <uart_tx_r>
    80000844:	00008797          	auipc	a5,0x8
    80000848:	1fc7b783          	ld	a5,508(a5) # 80008a40 <uart_tx_w>
    8000084c:	06e78c63          	beq	a5,a4,800008c4 <uartstart+0x88>
{
    80000850:	7139                	addi	sp,sp,-64
    80000852:	fc06                	sd	ra,56(sp)
    80000854:	f822                	sd	s0,48(sp)
    80000856:	f426                	sd	s1,40(sp)
    80000858:	f04a                	sd	s2,32(sp)
    8000085a:	ec4e                	sd	s3,24(sp)
    8000085c:	e852                	sd	s4,16(sp)
    8000085e:	e456                	sd	s5,8(sp)
    80000860:	0080                	addi	s0,sp,64
      // transmit buffer is empty.
      return;
    }
    
    if((ReadReg(LSR) & LSR_TX_IDLE) == 0){
    80000862:	10000937          	lui	s2,0x10000
      // so we cannot give it another byte.
      // it will interrupt when it's ready for a new byte.
      return;
    }
    
    int c = uart_tx_buf[uart_tx_r % UART_TX_BUF_SIZE];
    80000866:	00010a17          	auipc	s4,0x10
    8000086a:	422a0a13          	addi	s4,s4,1058 # 80010c88 <uart_tx_lock>
    uart_tx_r += 1;
    8000086e:	00008497          	auipc	s1,0x8
    80000872:	1ca48493          	addi	s1,s1,458 # 80008a38 <uart_tx_r>
    if(uart_tx_w == uart_tx_r){
    80000876:	00008997          	auipc	s3,0x8
    8000087a:	1ca98993          	addi	s3,s3,458 # 80008a40 <uart_tx_w>
    if((ReadReg(LSR) & LSR_TX_IDLE) == 0){
    8000087e:	00594783          	lbu	a5,5(s2) # 10000005 <_entry-0x6ffffffb>
    80000882:	0ff7f793          	andi	a5,a5,255
    80000886:	0207f793          	andi	a5,a5,32
    8000088a:	c785                	beqz	a5,800008b2 <uartstart+0x76>
    int c = uart_tx_buf[uart_tx_r % UART_TX_BUF_SIZE];
    8000088c:	01f77793          	andi	a5,a4,31
    80000890:	97d2                	add	a5,a5,s4
    80000892:	0187ca83          	lbu	s5,24(a5)
    uart_tx_r += 1;
    80000896:	0705                	addi	a4,a4,1
    80000898:	e098                	sd	a4,0(s1)
    
    // maybe uartputc() is waiting for space in the buffer.
    wakeup(&uart_tx_r);
    8000089a:	8526                	mv	a0,s1
    8000089c:	00002097          	auipc	ra,0x2
    800008a0:	a9c080e7          	jalr	-1380(ra) # 80002338 <wakeup>
    
    WriteReg(THR, c);
    800008a4:	01590023          	sb	s5,0(s2)
    if(uart_tx_w == uart_tx_r){
    800008a8:	6098                	ld	a4,0(s1)
    800008aa:	0009b783          	ld	a5,0(s3)
    800008ae:	fce798e3          	bne	a5,a4,8000087e <uartstart+0x42>
  }
}
    800008b2:	70e2                	ld	ra,56(sp)
    800008b4:	7442                	ld	s0,48(sp)
    800008b6:	74a2                	ld	s1,40(sp)
    800008b8:	7902                	ld	s2,32(sp)
    800008ba:	69e2                	ld	s3,24(sp)
    800008bc:	6a42                	ld	s4,16(sp)
    800008be:	6aa2                	ld	s5,8(sp)
    800008c0:	6121                	addi	sp,sp,64
    800008c2:	8082                	ret
    800008c4:	8082                	ret

00000000800008c6 <uartputc>:
{
    800008c6:	7179                	addi	sp,sp,-48
    800008c8:	f406                	sd	ra,40(sp)
    800008ca:	f022                	sd	s0,32(sp)
    800008cc:	ec26                	sd	s1,24(sp)
    800008ce:	e84a                	sd	s2,16(sp)
    800008d0:	e44e                	sd	s3,8(sp)
    800008d2:	e052                	sd	s4,0(sp)
    800008d4:	1800                	addi	s0,sp,48
    800008d6:	89aa                	mv	s3,a0
  acquire(&uart_tx_lock);
    800008d8:	00010517          	auipc	a0,0x10
    800008dc:	3b050513          	addi	a0,a0,944 # 80010c88 <uart_tx_lock>
    800008e0:	00000097          	auipc	ra,0x0
    800008e4:	3b6080e7          	jalr	950(ra) # 80000c96 <acquire>
  if(panicked){
    800008e8:	00008797          	auipc	a5,0x8
    800008ec:	1487a783          	lw	a5,328(a5) # 80008a30 <panicked>
    800008f0:	e7c9                	bnez	a5,8000097a <uartputc+0xb4>
  while(uart_tx_w == uart_tx_r + UART_TX_BUF_SIZE){
    800008f2:	00008797          	auipc	a5,0x8
    800008f6:	14e7b783          	ld	a5,334(a5) # 80008a40 <uart_tx_w>
    800008fa:	00008717          	auipc	a4,0x8
    800008fe:	13e73703          	ld	a4,318(a4) # 80008a38 <uart_tx_r>
    80000902:	02070713          	addi	a4,a4,32
    sleep(&uart_tx_r, &uart_tx_lock);
    80000906:	00010a17          	auipc	s4,0x10
    8000090a:	382a0a13          	addi	s4,s4,898 # 80010c88 <uart_tx_lock>
    8000090e:	00008497          	auipc	s1,0x8
    80000912:	12a48493          	addi	s1,s1,298 # 80008a38 <uart_tx_r>
  while(uart_tx_w == uart_tx_r + UART_TX_BUF_SIZE){
    80000916:	00008917          	auipc	s2,0x8
    8000091a:	12a90913          	addi	s2,s2,298 # 80008a40 <uart_tx_w>
    8000091e:	00f71f63          	bne	a4,a5,8000093c <uartputc+0x76>
    sleep(&uart_tx_r, &uart_tx_lock);
    80000922:	85d2                	mv	a1,s4
    80000924:	8526                	mv	a0,s1
    80000926:	00002097          	auipc	ra,0x2
    8000092a:	9ae080e7          	jalr	-1618(ra) # 800022d4 <sleep>
  while(uart_tx_w == uart_tx_r + UART_TX_BUF_SIZE){
    8000092e:	00093783          	ld	a5,0(s2)
    80000932:	6098                	ld	a4,0(s1)
    80000934:	02070713          	addi	a4,a4,32
    80000938:	fef705e3          	beq	a4,a5,80000922 <uartputc+0x5c>
  uart_tx_buf[uart_tx_w % UART_TX_BUF_SIZE] = c;
    8000093c:	00010497          	auipc	s1,0x10
    80000940:	34c48493          	addi	s1,s1,844 # 80010c88 <uart_tx_lock>
    80000944:	01f7f713          	andi	a4,a5,31
    80000948:	9726                	add	a4,a4,s1
    8000094a:	01370c23          	sb	s3,24(a4)
  uart_tx_w += 1;
    8000094e:	0785                	addi	a5,a5,1
    80000950:	00008717          	auipc	a4,0x8
    80000954:	0ef73823          	sd	a5,240(a4) # 80008a40 <uart_tx_w>
  uartstart();
    80000958:	00000097          	auipc	ra,0x0
    8000095c:	ee4080e7          	jalr	-284(ra) # 8000083c <uartstart>
  release(&uart_tx_lock);
    80000960:	8526                	mv	a0,s1
    80000962:	00000097          	auipc	ra,0x0
    80000966:	3e8080e7          	jalr	1000(ra) # 80000d4a <release>
}
    8000096a:	70a2                	ld	ra,40(sp)
    8000096c:	7402                	ld	s0,32(sp)
    8000096e:	64e2                	ld	s1,24(sp)
    80000970:	6942                	ld	s2,16(sp)
    80000972:	69a2                	ld	s3,8(sp)
    80000974:	6a02                	ld	s4,0(sp)
    80000976:	6145                	addi	sp,sp,48
    80000978:	8082                	ret
    for(;;)
    8000097a:	a001                	j	8000097a <uartputc+0xb4>

000000008000097c <uartgetc>:

// read one input character from the UART.
// return -1 if none is waiting.
int
uartgetc(void)
{
    8000097c:	1141                	addi	sp,sp,-16
    8000097e:	e422                	sd	s0,8(sp)
    80000980:	0800                	addi	s0,sp,16
  if(ReadReg(LSR) & 0x01){
    80000982:	100007b7          	lui	a5,0x10000
    80000986:	0057c783          	lbu	a5,5(a5) # 10000005 <_entry-0x6ffffffb>
    8000098a:	8b85                	andi	a5,a5,1
    8000098c:	cb91                	beqz	a5,800009a0 <uartgetc+0x24>
    // input data is ready.
    return ReadReg(RHR);
    8000098e:	100007b7          	lui	a5,0x10000
    80000992:	0007c503          	lbu	a0,0(a5) # 10000000 <_entry-0x70000000>
    80000996:	0ff57513          	andi	a0,a0,255
  } else {
    return -1;
  }
}
    8000099a:	6422                	ld	s0,8(sp)
    8000099c:	0141                	addi	sp,sp,16
    8000099e:	8082                	ret
    return -1;
    800009a0:	557d                	li	a0,-1
    800009a2:	bfe5                	j	8000099a <uartgetc+0x1e>

00000000800009a4 <uartintr>:
// handle a uart interrupt, raised because input has
// arrived, or the uart is ready for more output, or
// both. called from devintr().
void
uartintr(void)
{
    800009a4:	1101                	addi	sp,sp,-32
    800009a6:	ec06                	sd	ra,24(sp)
    800009a8:	e822                	sd	s0,16(sp)
    800009aa:	e426                	sd	s1,8(sp)
    800009ac:	1000                	addi	s0,sp,32
  // read and process incoming characters.
  while(1){
    int c = uartgetc();
    if(c == -1)
    800009ae:	54fd                	li	s1,-1
    int c = uartgetc();
    800009b0:	00000097          	auipc	ra,0x0
    800009b4:	fcc080e7          	jalr	-52(ra) # 8000097c <uartgetc>
    if(c == -1)
    800009b8:	00950763          	beq	a0,s1,800009c6 <uartintr+0x22>
      break;
    consoleintr(c);
    800009bc:	00000097          	auipc	ra,0x0
    800009c0:	908080e7          	jalr	-1784(ra) # 800002c4 <consoleintr>
  while(1){
    800009c4:	b7f5                	j	800009b0 <uartintr+0xc>
  }

  // send buffered characters.
  acquire(&uart_tx_lock);
    800009c6:	00010497          	auipc	s1,0x10
    800009ca:	2c248493          	addi	s1,s1,706 # 80010c88 <uart_tx_lock>
    800009ce:	8526                	mv	a0,s1
    800009d0:	00000097          	auipc	ra,0x0
    800009d4:	2c6080e7          	jalr	710(ra) # 80000c96 <acquire>
  uartstart();
    800009d8:	00000097          	auipc	ra,0x0
    800009dc:	e64080e7          	jalr	-412(ra) # 8000083c <uartstart>
  release(&uart_tx_lock);
    800009e0:	8526                	mv	a0,s1
    800009e2:	00000097          	auipc	ra,0x0
    800009e6:	368080e7          	jalr	872(ra) # 80000d4a <release>
}
    800009ea:	60e2                	ld	ra,24(sp)
    800009ec:	6442                	ld	s0,16(sp)
    800009ee:	64a2                	ld	s1,8(sp)
    800009f0:	6105                	addi	sp,sp,32
    800009f2:	8082                	ret

00000000800009f4 <kfree>:
// Free the page of physical memory pointed at by pa,
// which normally should have been returned by a
// call to kalloc().  (The exception is when
// initializing the allocator; see kinit above.)
void kfree(void *pa)
{
    800009f4:	1101                	addi	sp,sp,-32
    800009f6:	ec06                	sd	ra,24(sp)
    800009f8:	e822                	sd	s0,16(sp)
    800009fa:	e426                	sd	s1,8(sp)
    800009fc:	e04a                	sd	s2,0(sp)
    800009fe:	1000                	addi	s0,sp,32
    80000a00:	84aa                	mv	s1,a0
    if (MAX_PAGES != 0)
    80000a02:	00008797          	auipc	a5,0x8
    80000a06:	04e7b783          	ld	a5,78(a5) # 80008a50 <MAX_PAGES>
    80000a0a:	c799                	beqz	a5,80000a18 <kfree+0x24>
        assert(FREE_PAGES < MAX_PAGES);
    80000a0c:	00008717          	auipc	a4,0x8
    80000a10:	03c73703          	ld	a4,60(a4) # 80008a48 <FREE_PAGES>
    80000a14:	06f77663          	bgeu	a4,a5,80000a80 <kfree+0x8c>
    struct run *r;

    if (((uint64)pa % PGSIZE) != 0 || (char *)pa < end || (uint64)pa >= PHYSTOP)
    80000a18:	03449793          	slli	a5,s1,0x34
    80000a1c:	efc1                	bnez	a5,80000ab4 <kfree+0xc0>
    80000a1e:	00021797          	auipc	a5,0x21
    80000a22:	4d278793          	addi	a5,a5,1234 # 80021ef0 <end>
    80000a26:	08f4e763          	bltu	s1,a5,80000ab4 <kfree+0xc0>
    80000a2a:	47c5                	li	a5,17
    80000a2c:	07ee                	slli	a5,a5,0x1b
    80000a2e:	08f4f363          	bgeu	s1,a5,80000ab4 <kfree+0xc0>
        panic("kfree");

    // Fill with junk to catch dangling refs.
    memset(pa, 1, PGSIZE);
    80000a32:	6605                	lui	a2,0x1
    80000a34:	4585                	li	a1,1
    80000a36:	8526                	mv	a0,s1
    80000a38:	00000097          	auipc	ra,0x0
    80000a3c:	35a080e7          	jalr	858(ra) # 80000d92 <memset>

    r = (struct run *)pa;

    acquire(&kmem.lock);
    80000a40:	00010917          	auipc	s2,0x10
    80000a44:	28090913          	addi	s2,s2,640 # 80010cc0 <kmem>
    80000a48:	854a                	mv	a0,s2
    80000a4a:	00000097          	auipc	ra,0x0
    80000a4e:	24c080e7          	jalr	588(ra) # 80000c96 <acquire>
    r->next = kmem.freelist;
    80000a52:	01893783          	ld	a5,24(s2)
    80000a56:	e09c                	sd	a5,0(s1)
    kmem.freelist = r;
    80000a58:	00993c23          	sd	s1,24(s2)
    FREE_PAGES++;
    80000a5c:	00008717          	auipc	a4,0x8
    80000a60:	fec70713          	addi	a4,a4,-20 # 80008a48 <FREE_PAGES>
    80000a64:	631c                	ld	a5,0(a4)
    80000a66:	0785                	addi	a5,a5,1
    80000a68:	e31c                	sd	a5,0(a4)
    release(&kmem.lock);
    80000a6a:	854a                	mv	a0,s2
    80000a6c:	00000097          	auipc	ra,0x0
    80000a70:	2de080e7          	jalr	734(ra) # 80000d4a <release>
}
    80000a74:	60e2                	ld	ra,24(sp)
    80000a76:	6442                	ld	s0,16(sp)
    80000a78:	64a2                	ld	s1,8(sp)
    80000a7a:	6902                	ld	s2,0(sp)
    80000a7c:	6105                	addi	sp,sp,32
    80000a7e:	8082                	ret
        assert(FREE_PAGES < MAX_PAGES);
    80000a80:	03700693          	li	a3,55
    80000a84:	00007617          	auipc	a2,0x7
    80000a88:	58460613          	addi	a2,a2,1412 # 80008008 <__func__.1508>
    80000a8c:	00007597          	auipc	a1,0x7
    80000a90:	5e458593          	addi	a1,a1,1508 # 80008070 <digits+0x20>
    80000a94:	00007517          	auipc	a0,0x7
    80000a98:	5ec50513          	addi	a0,a0,1516 # 80008080 <digits+0x30>
    80000a9c:	00000097          	auipc	ra,0x0
    80000aa0:	ae8080e7          	jalr	-1304(ra) # 80000584 <printf>
    80000aa4:	00007517          	auipc	a0,0x7
    80000aa8:	5ec50513          	addi	a0,a0,1516 # 80008090 <digits+0x40>
    80000aac:	00000097          	auipc	ra,0x0
    80000ab0:	a7c080e7          	jalr	-1412(ra) # 80000528 <panic>
        panic("kfree");
    80000ab4:	00007517          	auipc	a0,0x7
    80000ab8:	5ec50513          	addi	a0,a0,1516 # 800080a0 <digits+0x50>
    80000abc:	00000097          	auipc	ra,0x0
    80000ac0:	a6c080e7          	jalr	-1428(ra) # 80000528 <panic>

0000000080000ac4 <freerange>:
{
    80000ac4:	7179                	addi	sp,sp,-48
    80000ac6:	f406                	sd	ra,40(sp)
    80000ac8:	f022                	sd	s0,32(sp)
    80000aca:	ec26                	sd	s1,24(sp)
    80000acc:	e84a                	sd	s2,16(sp)
    80000ace:	e44e                	sd	s3,8(sp)
    80000ad0:	e052                	sd	s4,0(sp)
    80000ad2:	1800                	addi	s0,sp,48
    p = (char *)PGROUNDUP((uint64)pa_start);
    80000ad4:	6785                	lui	a5,0x1
    80000ad6:	fff78493          	addi	s1,a5,-1 # fff <_entry-0x7ffff001>
    80000ada:	94aa                	add	s1,s1,a0
    80000adc:	757d                	lui	a0,0xfffff
    80000ade:	8ce9                	and	s1,s1,a0
    for (; p + PGSIZE <= (char *)pa_end; p += PGSIZE)
    80000ae0:	94be                	add	s1,s1,a5
    80000ae2:	0095ee63          	bltu	a1,s1,80000afe <freerange+0x3a>
    80000ae6:	892e                	mv	s2,a1
        kfree(p);
    80000ae8:	7a7d                	lui	s4,0xfffff
    for (; p + PGSIZE <= (char *)pa_end; p += PGSIZE)
    80000aea:	6985                	lui	s3,0x1
        kfree(p);
    80000aec:	01448533          	add	a0,s1,s4
    80000af0:	00000097          	auipc	ra,0x0
    80000af4:	f04080e7          	jalr	-252(ra) # 800009f4 <kfree>
    for (; p + PGSIZE <= (char *)pa_end; p += PGSIZE)
    80000af8:	94ce                	add	s1,s1,s3
    80000afa:	fe9979e3          	bgeu	s2,s1,80000aec <freerange+0x28>
}
    80000afe:	70a2                	ld	ra,40(sp)
    80000b00:	7402                	ld	s0,32(sp)
    80000b02:	64e2                	ld	s1,24(sp)
    80000b04:	6942                	ld	s2,16(sp)
    80000b06:	69a2                	ld	s3,8(sp)
    80000b08:	6a02                	ld	s4,0(sp)
    80000b0a:	6145                	addi	sp,sp,48
    80000b0c:	8082                	ret

0000000080000b0e <kinit>:
{
    80000b0e:	1141                	addi	sp,sp,-16
    80000b10:	e406                	sd	ra,8(sp)
    80000b12:	e022                	sd	s0,0(sp)
    80000b14:	0800                	addi	s0,sp,16
    initlock(&kmem.lock, "kmem");
    80000b16:	00007597          	auipc	a1,0x7
    80000b1a:	59258593          	addi	a1,a1,1426 # 800080a8 <digits+0x58>
    80000b1e:	00010517          	auipc	a0,0x10
    80000b22:	1a250513          	addi	a0,a0,418 # 80010cc0 <kmem>
    80000b26:	00000097          	auipc	ra,0x0
    80000b2a:	0e0080e7          	jalr	224(ra) # 80000c06 <initlock>
    freerange(end, (void *)PHYSTOP);
    80000b2e:	45c5                	li	a1,17
    80000b30:	05ee                	slli	a1,a1,0x1b
    80000b32:	00021517          	auipc	a0,0x21
    80000b36:	3be50513          	addi	a0,a0,958 # 80021ef0 <end>
    80000b3a:	00000097          	auipc	ra,0x0
    80000b3e:	f8a080e7          	jalr	-118(ra) # 80000ac4 <freerange>
    MAX_PAGES = FREE_PAGES;
    80000b42:	00008797          	auipc	a5,0x8
    80000b46:	f067b783          	ld	a5,-250(a5) # 80008a48 <FREE_PAGES>
    80000b4a:	00008717          	auipc	a4,0x8
    80000b4e:	f0f73323          	sd	a5,-250(a4) # 80008a50 <MAX_PAGES>
}
    80000b52:	60a2                	ld	ra,8(sp)
    80000b54:	6402                	ld	s0,0(sp)
    80000b56:	0141                	addi	sp,sp,16
    80000b58:	8082                	ret

0000000080000b5a <kalloc>:
// Allocate one 4096-byte page of physical memory.
// Returns a pointer that the kernel can use.
// Returns 0 if the memory cannot be allocated.
void *
kalloc(void)
{
    80000b5a:	1101                	addi	sp,sp,-32
    80000b5c:	ec06                	sd	ra,24(sp)
    80000b5e:	e822                	sd	s0,16(sp)
    80000b60:	e426                	sd	s1,8(sp)
    80000b62:	1000                	addi	s0,sp,32
    assert(FREE_PAGES > 0);
    80000b64:	00008797          	auipc	a5,0x8
    80000b68:	ee47b783          	ld	a5,-284(a5) # 80008a48 <FREE_PAGES>
    80000b6c:	cbb1                	beqz	a5,80000bc0 <kalloc+0x66>
    struct run *r;

    acquire(&kmem.lock);
    80000b6e:	00010497          	auipc	s1,0x10
    80000b72:	15248493          	addi	s1,s1,338 # 80010cc0 <kmem>
    80000b76:	8526                	mv	a0,s1
    80000b78:	00000097          	auipc	ra,0x0
    80000b7c:	11e080e7          	jalr	286(ra) # 80000c96 <acquire>
    r = kmem.freelist;
    80000b80:	6c84                	ld	s1,24(s1)
    if (r)
    80000b82:	c8ad                	beqz	s1,80000bf4 <kalloc+0x9a>
        kmem.freelist = r->next;
    80000b84:	609c                	ld	a5,0(s1)
    80000b86:	00010517          	auipc	a0,0x10
    80000b8a:	13a50513          	addi	a0,a0,314 # 80010cc0 <kmem>
    80000b8e:	ed1c                	sd	a5,24(a0)
    release(&kmem.lock);
    80000b90:	00000097          	auipc	ra,0x0
    80000b94:	1ba080e7          	jalr	442(ra) # 80000d4a <release>

    if (r)
        memset((char *)r, 5, PGSIZE); // fill with junk
    80000b98:	6605                	lui	a2,0x1
    80000b9a:	4595                	li	a1,5
    80000b9c:	8526                	mv	a0,s1
    80000b9e:	00000097          	auipc	ra,0x0
    80000ba2:	1f4080e7          	jalr	500(ra) # 80000d92 <memset>
    FREE_PAGES--;
    80000ba6:	00008717          	auipc	a4,0x8
    80000baa:	ea270713          	addi	a4,a4,-350 # 80008a48 <FREE_PAGES>
    80000bae:	631c                	ld	a5,0(a4)
    80000bb0:	17fd                	addi	a5,a5,-1
    80000bb2:	e31c                	sd	a5,0(a4)
    return (void *)r;
}
    80000bb4:	8526                	mv	a0,s1
    80000bb6:	60e2                	ld	ra,24(sp)
    80000bb8:	6442                	ld	s0,16(sp)
    80000bba:	64a2                	ld	s1,8(sp)
    80000bbc:	6105                	addi	sp,sp,32
    80000bbe:	8082                	ret
    assert(FREE_PAGES > 0);
    80000bc0:	04f00693          	li	a3,79
    80000bc4:	00007617          	auipc	a2,0x7
    80000bc8:	43c60613          	addi	a2,a2,1084 # 80008000 <etext>
    80000bcc:	00007597          	auipc	a1,0x7
    80000bd0:	4a458593          	addi	a1,a1,1188 # 80008070 <digits+0x20>
    80000bd4:	00007517          	auipc	a0,0x7
    80000bd8:	4ac50513          	addi	a0,a0,1196 # 80008080 <digits+0x30>
    80000bdc:	00000097          	auipc	ra,0x0
    80000be0:	9a8080e7          	jalr	-1624(ra) # 80000584 <printf>
    80000be4:	00007517          	auipc	a0,0x7
    80000be8:	4ac50513          	addi	a0,a0,1196 # 80008090 <digits+0x40>
    80000bec:	00000097          	auipc	ra,0x0
    80000bf0:	93c080e7          	jalr	-1732(ra) # 80000528 <panic>
    release(&kmem.lock);
    80000bf4:	00010517          	auipc	a0,0x10
    80000bf8:	0cc50513          	addi	a0,a0,204 # 80010cc0 <kmem>
    80000bfc:	00000097          	auipc	ra,0x0
    80000c00:	14e080e7          	jalr	334(ra) # 80000d4a <release>
    if (r)
    80000c04:	b74d                	j	80000ba6 <kalloc+0x4c>

0000000080000c06 <initlock>:
#include "proc.h"
#include "defs.h"

void
initlock(struct spinlock *lk, char *name)
{
    80000c06:	1141                	addi	sp,sp,-16
    80000c08:	e422                	sd	s0,8(sp)
    80000c0a:	0800                	addi	s0,sp,16
  lk->name = name;
    80000c0c:	e50c                	sd	a1,8(a0)
  lk->locked = 0;
    80000c0e:	00052023          	sw	zero,0(a0)
  lk->cpu = 0;
    80000c12:	00053823          	sd	zero,16(a0)
}
    80000c16:	6422                	ld	s0,8(sp)
    80000c18:	0141                	addi	sp,sp,16
    80000c1a:	8082                	ret

0000000080000c1c <holding>:
// Interrupts must be off.
int
holding(struct spinlock *lk)
{
  int r;
  r = (lk->locked && lk->cpu == mycpu());
    80000c1c:	411c                	lw	a5,0(a0)
    80000c1e:	e399                	bnez	a5,80000c24 <holding+0x8>
    80000c20:	4501                	li	a0,0
  return r;
}
    80000c22:	8082                	ret
{
    80000c24:	1101                	addi	sp,sp,-32
    80000c26:	ec06                	sd	ra,24(sp)
    80000c28:	e822                	sd	s0,16(sp)
    80000c2a:	e426                	sd	s1,8(sp)
    80000c2c:	1000                	addi	s0,sp,32
  r = (lk->locked && lk->cpu == mycpu());
    80000c2e:	6904                	ld	s1,16(a0)
    80000c30:	00001097          	auipc	ra,0x1
    80000c34:	f24080e7          	jalr	-220(ra) # 80001b54 <mycpu>
    80000c38:	40a48533          	sub	a0,s1,a0
    80000c3c:	00153513          	seqz	a0,a0
}
    80000c40:	60e2                	ld	ra,24(sp)
    80000c42:	6442                	ld	s0,16(sp)
    80000c44:	64a2                	ld	s1,8(sp)
    80000c46:	6105                	addi	sp,sp,32
    80000c48:	8082                	ret

0000000080000c4a <push_off>:
// it takes two pop_off()s to undo two push_off()s.  Also, if interrupts
// are initially off, then push_off, pop_off leaves them off.

void
push_off(void)
{
    80000c4a:	1101                	addi	sp,sp,-32
    80000c4c:	ec06                	sd	ra,24(sp)
    80000c4e:	e822                	sd	s0,16(sp)
    80000c50:	e426                	sd	s1,8(sp)
    80000c52:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80000c54:	100024f3          	csrr	s1,sstatus
    80000c58:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    80000c5c:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80000c5e:	10079073          	csrw	sstatus,a5
  int old = intr_get();

  intr_off();
  if(mycpu()->noff == 0)
    80000c62:	00001097          	auipc	ra,0x1
    80000c66:	ef2080e7          	jalr	-270(ra) # 80001b54 <mycpu>
    80000c6a:	5d3c                	lw	a5,120(a0)
    80000c6c:	cf89                	beqz	a5,80000c86 <push_off+0x3c>
    mycpu()->intena = old;
  mycpu()->noff += 1;
    80000c6e:	00001097          	auipc	ra,0x1
    80000c72:	ee6080e7          	jalr	-282(ra) # 80001b54 <mycpu>
    80000c76:	5d3c                	lw	a5,120(a0)
    80000c78:	2785                	addiw	a5,a5,1
    80000c7a:	dd3c                	sw	a5,120(a0)
}
    80000c7c:	60e2                	ld	ra,24(sp)
    80000c7e:	6442                	ld	s0,16(sp)
    80000c80:	64a2                	ld	s1,8(sp)
    80000c82:	6105                	addi	sp,sp,32
    80000c84:	8082                	ret
    mycpu()->intena = old;
    80000c86:	00001097          	auipc	ra,0x1
    80000c8a:	ece080e7          	jalr	-306(ra) # 80001b54 <mycpu>
  return (x & SSTATUS_SIE) != 0;
    80000c8e:	8085                	srli	s1,s1,0x1
    80000c90:	8885                	andi	s1,s1,1
    80000c92:	dd64                	sw	s1,124(a0)
    80000c94:	bfe9                	j	80000c6e <push_off+0x24>

0000000080000c96 <acquire>:
{
    80000c96:	1101                	addi	sp,sp,-32
    80000c98:	ec06                	sd	ra,24(sp)
    80000c9a:	e822                	sd	s0,16(sp)
    80000c9c:	e426                	sd	s1,8(sp)
    80000c9e:	1000                	addi	s0,sp,32
    80000ca0:	84aa                	mv	s1,a0
  push_off(); // disable interrupts to avoid deadlock.
    80000ca2:	00000097          	auipc	ra,0x0
    80000ca6:	fa8080e7          	jalr	-88(ra) # 80000c4a <push_off>
  if(holding(lk))
    80000caa:	8526                	mv	a0,s1
    80000cac:	00000097          	auipc	ra,0x0
    80000cb0:	f70080e7          	jalr	-144(ra) # 80000c1c <holding>
  while(__sync_lock_test_and_set(&lk->locked, 1) != 0)
    80000cb4:	4705                	li	a4,1
  if(holding(lk))
    80000cb6:	e115                	bnez	a0,80000cda <acquire+0x44>
  while(__sync_lock_test_and_set(&lk->locked, 1) != 0)
    80000cb8:	87ba                	mv	a5,a4
    80000cba:	0cf4a7af          	amoswap.w.aq	a5,a5,(s1)
    80000cbe:	2781                	sext.w	a5,a5
    80000cc0:	ffe5                	bnez	a5,80000cb8 <acquire+0x22>
  __sync_synchronize();
    80000cc2:	0ff0000f          	fence
  lk->cpu = mycpu();
    80000cc6:	00001097          	auipc	ra,0x1
    80000cca:	e8e080e7          	jalr	-370(ra) # 80001b54 <mycpu>
    80000cce:	e888                	sd	a0,16(s1)
}
    80000cd0:	60e2                	ld	ra,24(sp)
    80000cd2:	6442                	ld	s0,16(sp)
    80000cd4:	64a2                	ld	s1,8(sp)
    80000cd6:	6105                	addi	sp,sp,32
    80000cd8:	8082                	ret
    panic("acquire");
    80000cda:	00007517          	auipc	a0,0x7
    80000cde:	3d650513          	addi	a0,a0,982 # 800080b0 <digits+0x60>
    80000ce2:	00000097          	auipc	ra,0x0
    80000ce6:	846080e7          	jalr	-1978(ra) # 80000528 <panic>

0000000080000cea <pop_off>:

void
pop_off(void)
{
    80000cea:	1141                	addi	sp,sp,-16
    80000cec:	e406                	sd	ra,8(sp)
    80000cee:	e022                	sd	s0,0(sp)
    80000cf0:	0800                	addi	s0,sp,16
  struct cpu *c = mycpu();
    80000cf2:	00001097          	auipc	ra,0x1
    80000cf6:	e62080e7          	jalr	-414(ra) # 80001b54 <mycpu>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80000cfa:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80000cfe:	8b89                	andi	a5,a5,2
  if(intr_get())
    80000d00:	e78d                	bnez	a5,80000d2a <pop_off+0x40>
    panic("pop_off - interruptible");
  if(c->noff < 1)
    80000d02:	5d3c                	lw	a5,120(a0)
    80000d04:	02f05b63          	blez	a5,80000d3a <pop_off+0x50>
    panic("pop_off");
  c->noff -= 1;
    80000d08:	37fd                	addiw	a5,a5,-1
    80000d0a:	0007871b          	sext.w	a4,a5
    80000d0e:	dd3c                	sw	a5,120(a0)
  if(c->noff == 0 && c->intena)
    80000d10:	eb09                	bnez	a4,80000d22 <pop_off+0x38>
    80000d12:	5d7c                	lw	a5,124(a0)
    80000d14:	c799                	beqz	a5,80000d22 <pop_off+0x38>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80000d16:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80000d1a:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80000d1e:	10079073          	csrw	sstatus,a5
    intr_on();
}
    80000d22:	60a2                	ld	ra,8(sp)
    80000d24:	6402                	ld	s0,0(sp)
    80000d26:	0141                	addi	sp,sp,16
    80000d28:	8082                	ret
    panic("pop_off - interruptible");
    80000d2a:	00007517          	auipc	a0,0x7
    80000d2e:	38e50513          	addi	a0,a0,910 # 800080b8 <digits+0x68>
    80000d32:	fffff097          	auipc	ra,0xfffff
    80000d36:	7f6080e7          	jalr	2038(ra) # 80000528 <panic>
    panic("pop_off");
    80000d3a:	00007517          	auipc	a0,0x7
    80000d3e:	39650513          	addi	a0,a0,918 # 800080d0 <digits+0x80>
    80000d42:	fffff097          	auipc	ra,0xfffff
    80000d46:	7e6080e7          	jalr	2022(ra) # 80000528 <panic>

0000000080000d4a <release>:
{
    80000d4a:	1101                	addi	sp,sp,-32
    80000d4c:	ec06                	sd	ra,24(sp)
    80000d4e:	e822                	sd	s0,16(sp)
    80000d50:	e426                	sd	s1,8(sp)
    80000d52:	1000                	addi	s0,sp,32
    80000d54:	84aa                	mv	s1,a0
  if(!holding(lk))
    80000d56:	00000097          	auipc	ra,0x0
    80000d5a:	ec6080e7          	jalr	-314(ra) # 80000c1c <holding>
    80000d5e:	c115                	beqz	a0,80000d82 <release+0x38>
  lk->cpu = 0;
    80000d60:	0004b823          	sd	zero,16(s1)
  __sync_synchronize();
    80000d64:	0ff0000f          	fence
  __sync_lock_release(&lk->locked);
    80000d68:	0f50000f          	fence	iorw,ow
    80000d6c:	0804a02f          	amoswap.w	zero,zero,(s1)
  pop_off();
    80000d70:	00000097          	auipc	ra,0x0
    80000d74:	f7a080e7          	jalr	-134(ra) # 80000cea <pop_off>
}
    80000d78:	60e2                	ld	ra,24(sp)
    80000d7a:	6442                	ld	s0,16(sp)
    80000d7c:	64a2                	ld	s1,8(sp)
    80000d7e:	6105                	addi	sp,sp,32
    80000d80:	8082                	ret
    panic("release");
    80000d82:	00007517          	auipc	a0,0x7
    80000d86:	35650513          	addi	a0,a0,854 # 800080d8 <digits+0x88>
    80000d8a:	fffff097          	auipc	ra,0xfffff
    80000d8e:	79e080e7          	jalr	1950(ra) # 80000528 <panic>

0000000080000d92 <memset>:
#include "types.h"

void*
memset(void *dst, int c, uint n)
{
    80000d92:	1141                	addi	sp,sp,-16
    80000d94:	e422                	sd	s0,8(sp)
    80000d96:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
    80000d98:	ce09                	beqz	a2,80000db2 <memset+0x20>
    80000d9a:	87aa                	mv	a5,a0
    80000d9c:	fff6071b          	addiw	a4,a2,-1
    80000da0:	1702                	slli	a4,a4,0x20
    80000da2:	9301                	srli	a4,a4,0x20
    80000da4:	0705                	addi	a4,a4,1
    80000da6:	972a                	add	a4,a4,a0
    cdst[i] = c;
    80000da8:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
    80000dac:	0785                	addi	a5,a5,1
    80000dae:	fee79de3          	bne	a5,a4,80000da8 <memset+0x16>
  }
  return dst;
}
    80000db2:	6422                	ld	s0,8(sp)
    80000db4:	0141                	addi	sp,sp,16
    80000db6:	8082                	ret

0000000080000db8 <memcmp>:

int
memcmp(const void *v1, const void *v2, uint n)
{
    80000db8:	1141                	addi	sp,sp,-16
    80000dba:	e422                	sd	s0,8(sp)
    80000dbc:	0800                	addi	s0,sp,16
  const uchar *s1, *s2;

  s1 = v1;
  s2 = v2;
  while(n-- > 0){
    80000dbe:	ca05                	beqz	a2,80000dee <memcmp+0x36>
    80000dc0:	fff6069b          	addiw	a3,a2,-1
    80000dc4:	1682                	slli	a3,a3,0x20
    80000dc6:	9281                	srli	a3,a3,0x20
    80000dc8:	0685                	addi	a3,a3,1
    80000dca:	96aa                	add	a3,a3,a0
    if(*s1 != *s2)
    80000dcc:	00054783          	lbu	a5,0(a0)
    80000dd0:	0005c703          	lbu	a4,0(a1)
    80000dd4:	00e79863          	bne	a5,a4,80000de4 <memcmp+0x2c>
      return *s1 - *s2;
    s1++, s2++;
    80000dd8:	0505                	addi	a0,a0,1
    80000dda:	0585                	addi	a1,a1,1
  while(n-- > 0){
    80000ddc:	fed518e3          	bne	a0,a3,80000dcc <memcmp+0x14>
  }

  return 0;
    80000de0:	4501                	li	a0,0
    80000de2:	a019                	j	80000de8 <memcmp+0x30>
      return *s1 - *s2;
    80000de4:	40e7853b          	subw	a0,a5,a4
}
    80000de8:	6422                	ld	s0,8(sp)
    80000dea:	0141                	addi	sp,sp,16
    80000dec:	8082                	ret
  return 0;
    80000dee:	4501                	li	a0,0
    80000df0:	bfe5                	j	80000de8 <memcmp+0x30>

0000000080000df2 <memmove>:

void*
memmove(void *dst, const void *src, uint n)
{
    80000df2:	1141                	addi	sp,sp,-16
    80000df4:	e422                	sd	s0,8(sp)
    80000df6:	0800                	addi	s0,sp,16
  const char *s;
  char *d;

  if(n == 0)
    80000df8:	ca0d                	beqz	a2,80000e2a <memmove+0x38>
    return dst;
  
  s = src;
  d = dst;
  if(s < d && s + n > d){
    80000dfa:	00a5f963          	bgeu	a1,a0,80000e0c <memmove+0x1a>
    80000dfe:	02061693          	slli	a3,a2,0x20
    80000e02:	9281                	srli	a3,a3,0x20
    80000e04:	00d58733          	add	a4,a1,a3
    80000e08:	02e56463          	bltu	a0,a4,80000e30 <memmove+0x3e>
    s += n;
    d += n;
    while(n-- > 0)
      *--d = *--s;
  } else
    while(n-- > 0)
    80000e0c:	fff6079b          	addiw	a5,a2,-1
    80000e10:	1782                	slli	a5,a5,0x20
    80000e12:	9381                	srli	a5,a5,0x20
    80000e14:	0785                	addi	a5,a5,1
    80000e16:	97ae                	add	a5,a5,a1
    80000e18:	872a                	mv	a4,a0
      *d++ = *s++;
    80000e1a:	0585                	addi	a1,a1,1
    80000e1c:	0705                	addi	a4,a4,1
    80000e1e:	fff5c683          	lbu	a3,-1(a1)
    80000e22:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
    80000e26:	fef59ae3          	bne	a1,a5,80000e1a <memmove+0x28>

  return dst;
}
    80000e2a:	6422                	ld	s0,8(sp)
    80000e2c:	0141                	addi	sp,sp,16
    80000e2e:	8082                	ret
    d += n;
    80000e30:	96aa                	add	a3,a3,a0
    while(n-- > 0)
    80000e32:	fff6079b          	addiw	a5,a2,-1
    80000e36:	1782                	slli	a5,a5,0x20
    80000e38:	9381                	srli	a5,a5,0x20
    80000e3a:	fff7c793          	not	a5,a5
    80000e3e:	97ba                	add	a5,a5,a4
      *--d = *--s;
    80000e40:	177d                	addi	a4,a4,-1
    80000e42:	16fd                	addi	a3,a3,-1
    80000e44:	00074603          	lbu	a2,0(a4)
    80000e48:	00c68023          	sb	a2,0(a3)
    while(n-- > 0)
    80000e4c:	fef71ae3          	bne	a4,a5,80000e40 <memmove+0x4e>
    80000e50:	bfe9                	j	80000e2a <memmove+0x38>

0000000080000e52 <memcpy>:

// memcpy exists to placate GCC.  Use memmove.
void*
memcpy(void *dst, const void *src, uint n)
{
    80000e52:	1141                	addi	sp,sp,-16
    80000e54:	e406                	sd	ra,8(sp)
    80000e56:	e022                	sd	s0,0(sp)
    80000e58:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
    80000e5a:	00000097          	auipc	ra,0x0
    80000e5e:	f98080e7          	jalr	-104(ra) # 80000df2 <memmove>
}
    80000e62:	60a2                	ld	ra,8(sp)
    80000e64:	6402                	ld	s0,0(sp)
    80000e66:	0141                	addi	sp,sp,16
    80000e68:	8082                	ret

0000000080000e6a <strncmp>:

int
strncmp(const char *p, const char *q, uint n)
{
    80000e6a:	1141                	addi	sp,sp,-16
    80000e6c:	e422                	sd	s0,8(sp)
    80000e6e:	0800                	addi	s0,sp,16
  while(n > 0 && *p && *p == *q)
    80000e70:	ce11                	beqz	a2,80000e8c <strncmp+0x22>
    80000e72:	00054783          	lbu	a5,0(a0)
    80000e76:	cf89                	beqz	a5,80000e90 <strncmp+0x26>
    80000e78:	0005c703          	lbu	a4,0(a1)
    80000e7c:	00f71a63          	bne	a4,a5,80000e90 <strncmp+0x26>
    n--, p++, q++;
    80000e80:	367d                	addiw	a2,a2,-1
    80000e82:	0505                	addi	a0,a0,1
    80000e84:	0585                	addi	a1,a1,1
  while(n > 0 && *p && *p == *q)
    80000e86:	f675                	bnez	a2,80000e72 <strncmp+0x8>
  if(n == 0)
    return 0;
    80000e88:	4501                	li	a0,0
    80000e8a:	a809                	j	80000e9c <strncmp+0x32>
    80000e8c:	4501                	li	a0,0
    80000e8e:	a039                	j	80000e9c <strncmp+0x32>
  if(n == 0)
    80000e90:	ca09                	beqz	a2,80000ea2 <strncmp+0x38>
  return (uchar)*p - (uchar)*q;
    80000e92:	00054503          	lbu	a0,0(a0)
    80000e96:	0005c783          	lbu	a5,0(a1)
    80000e9a:	9d1d                	subw	a0,a0,a5
}
    80000e9c:	6422                	ld	s0,8(sp)
    80000e9e:	0141                	addi	sp,sp,16
    80000ea0:	8082                	ret
    return 0;
    80000ea2:	4501                	li	a0,0
    80000ea4:	bfe5                	j	80000e9c <strncmp+0x32>

0000000080000ea6 <strncpy>:

char*
strncpy(char *s, const char *t, int n)
{
    80000ea6:	1141                	addi	sp,sp,-16
    80000ea8:	e422                	sd	s0,8(sp)
    80000eaa:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while(n-- > 0 && (*s++ = *t++) != 0)
    80000eac:	872a                	mv	a4,a0
    80000eae:	8832                	mv	a6,a2
    80000eb0:	367d                	addiw	a2,a2,-1
    80000eb2:	01005963          	blez	a6,80000ec4 <strncpy+0x1e>
    80000eb6:	0705                	addi	a4,a4,1
    80000eb8:	0005c783          	lbu	a5,0(a1)
    80000ebc:	fef70fa3          	sb	a5,-1(a4)
    80000ec0:	0585                	addi	a1,a1,1
    80000ec2:	f7f5                	bnez	a5,80000eae <strncpy+0x8>
    ;
  while(n-- > 0)
    80000ec4:	00c05d63          	blez	a2,80000ede <strncpy+0x38>
    80000ec8:	86ba                	mv	a3,a4
    *s++ = 0;
    80000eca:	0685                	addi	a3,a3,1
    80000ecc:	fe068fa3          	sb	zero,-1(a3)
  while(n-- > 0)
    80000ed0:	fff6c793          	not	a5,a3
    80000ed4:	9fb9                	addw	a5,a5,a4
    80000ed6:	010787bb          	addw	a5,a5,a6
    80000eda:	fef048e3          	bgtz	a5,80000eca <strncpy+0x24>
  return os;
}
    80000ede:	6422                	ld	s0,8(sp)
    80000ee0:	0141                	addi	sp,sp,16
    80000ee2:	8082                	ret

0000000080000ee4 <safestrcpy>:

// Like strncpy but guaranteed to NUL-terminate.
char*
safestrcpy(char *s, const char *t, int n)
{
    80000ee4:	1141                	addi	sp,sp,-16
    80000ee6:	e422                	sd	s0,8(sp)
    80000ee8:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  if(n <= 0)
    80000eea:	02c05363          	blez	a2,80000f10 <safestrcpy+0x2c>
    80000eee:	fff6069b          	addiw	a3,a2,-1
    80000ef2:	1682                	slli	a3,a3,0x20
    80000ef4:	9281                	srli	a3,a3,0x20
    80000ef6:	96ae                	add	a3,a3,a1
    80000ef8:	87aa                	mv	a5,a0
    return os;
  while(--n > 0 && (*s++ = *t++) != 0)
    80000efa:	00d58963          	beq	a1,a3,80000f0c <safestrcpy+0x28>
    80000efe:	0585                	addi	a1,a1,1
    80000f00:	0785                	addi	a5,a5,1
    80000f02:	fff5c703          	lbu	a4,-1(a1)
    80000f06:	fee78fa3          	sb	a4,-1(a5)
    80000f0a:	fb65                	bnez	a4,80000efa <safestrcpy+0x16>
    ;
  *s = 0;
    80000f0c:	00078023          	sb	zero,0(a5)
  return os;
}
    80000f10:	6422                	ld	s0,8(sp)
    80000f12:	0141                	addi	sp,sp,16
    80000f14:	8082                	ret

0000000080000f16 <strlen>:

int
strlen(const char *s)
{
    80000f16:	1141                	addi	sp,sp,-16
    80000f18:	e422                	sd	s0,8(sp)
    80000f1a:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
    80000f1c:	00054783          	lbu	a5,0(a0)
    80000f20:	cf91                	beqz	a5,80000f3c <strlen+0x26>
    80000f22:	0505                	addi	a0,a0,1
    80000f24:	87aa                	mv	a5,a0
    80000f26:	4685                	li	a3,1
    80000f28:	9e89                	subw	a3,a3,a0
    80000f2a:	00f6853b          	addw	a0,a3,a5
    80000f2e:	0785                	addi	a5,a5,1
    80000f30:	fff7c703          	lbu	a4,-1(a5)
    80000f34:	fb7d                	bnez	a4,80000f2a <strlen+0x14>
    ;
  return n;
}
    80000f36:	6422                	ld	s0,8(sp)
    80000f38:	0141                	addi	sp,sp,16
    80000f3a:	8082                	ret
  for(n = 0; s[n]; n++)
    80000f3c:	4501                	li	a0,0
    80000f3e:	bfe5                	j	80000f36 <strlen+0x20>

0000000080000f40 <main>:
volatile static int started = 0;

// start() jumps here in supervisor mode on all CPUs.
void
main()
{
    80000f40:	1141                	addi	sp,sp,-16
    80000f42:	e406                	sd	ra,8(sp)
    80000f44:	e022                	sd	s0,0(sp)
    80000f46:	0800                	addi	s0,sp,16
  if(cpuid() == 0){
    80000f48:	00001097          	auipc	ra,0x1
    80000f4c:	bfc080e7          	jalr	-1028(ra) # 80001b44 <cpuid>
    virtio_disk_init(); // emulated hard disk
    userinit();      // first user process
    __sync_synchronize();
    started = 1;
  } else {
    while(started == 0)
    80000f50:	00008717          	auipc	a4,0x8
    80000f54:	b0870713          	addi	a4,a4,-1272 # 80008a58 <started>
  if(cpuid() == 0){
    80000f58:	c139                	beqz	a0,80000f9e <main+0x5e>
    while(started == 0)
    80000f5a:	431c                	lw	a5,0(a4)
    80000f5c:	2781                	sext.w	a5,a5
    80000f5e:	dff5                	beqz	a5,80000f5a <main+0x1a>
      ;
    __sync_synchronize();
    80000f60:	0ff0000f          	fence
    printf("hart %d starting\n", cpuid());
    80000f64:	00001097          	auipc	ra,0x1
    80000f68:	be0080e7          	jalr	-1056(ra) # 80001b44 <cpuid>
    80000f6c:	85aa                	mv	a1,a0
    80000f6e:	00007517          	auipc	a0,0x7
    80000f72:	18a50513          	addi	a0,a0,394 # 800080f8 <digits+0xa8>
    80000f76:	fffff097          	auipc	ra,0xfffff
    80000f7a:	60e080e7          	jalr	1550(ra) # 80000584 <printf>
    kvminithart();    // turn on paging
    80000f7e:	00000097          	auipc	ra,0x0
    80000f82:	0d8080e7          	jalr	216(ra) # 80001056 <kvminithart>
    trapinithart();   // install kernel trap vector
    80000f86:	00002097          	auipc	ra,0x2
    80000f8a:	aee080e7          	jalr	-1298(ra) # 80002a74 <trapinithart>
    plicinithart();   // ask PLIC for device interrupts
    80000f8e:	00005097          	auipc	ra,0x5
    80000f92:	142080e7          	jalr	322(ra) # 800060d0 <plicinithart>
  }

  scheduler();        
    80000f96:	00001097          	auipc	ra,0x1
    80000f9a:	21c080e7          	jalr	540(ra) # 800021b2 <scheduler>
    consoleinit();
    80000f9e:	fffff097          	auipc	ra,0xfffff
    80000fa2:	4b8080e7          	jalr	1208(ra) # 80000456 <consoleinit>
    printfinit();
    80000fa6:	fffff097          	auipc	ra,0xfffff
    80000faa:	7c4080e7          	jalr	1988(ra) # 8000076a <printfinit>
    printf("\n");
    80000fae:	00007517          	auipc	a0,0x7
    80000fb2:	0da50513          	addi	a0,a0,218 # 80008088 <digits+0x38>
    80000fb6:	fffff097          	auipc	ra,0xfffff
    80000fba:	5ce080e7          	jalr	1486(ra) # 80000584 <printf>
    printf("xv6 kernel is booting\n");
    80000fbe:	00007517          	auipc	a0,0x7
    80000fc2:	12250513          	addi	a0,a0,290 # 800080e0 <digits+0x90>
    80000fc6:	fffff097          	auipc	ra,0xfffff
    80000fca:	5be080e7          	jalr	1470(ra) # 80000584 <printf>
    printf("\n");
    80000fce:	00007517          	auipc	a0,0x7
    80000fd2:	0ba50513          	addi	a0,a0,186 # 80008088 <digits+0x38>
    80000fd6:	fffff097          	auipc	ra,0xfffff
    80000fda:	5ae080e7          	jalr	1454(ra) # 80000584 <printf>
    kinit();         // physical page allocator
    80000fde:	00000097          	auipc	ra,0x0
    80000fe2:	b30080e7          	jalr	-1232(ra) # 80000b0e <kinit>
    kvminit();       // create kernel page table
    80000fe6:	00000097          	auipc	ra,0x0
    80000fea:	326080e7          	jalr	806(ra) # 8000130c <kvminit>
    kvminithart();   // turn on paging
    80000fee:	00000097          	auipc	ra,0x0
    80000ff2:	068080e7          	jalr	104(ra) # 80001056 <kvminithart>
    procinit();      // process table
    80000ff6:	00001097          	auipc	ra,0x1
    80000ffa:	a6c080e7          	jalr	-1428(ra) # 80001a62 <procinit>
    trapinit();      // trap vectors
    80000ffe:	00002097          	auipc	ra,0x2
    80001002:	a4e080e7          	jalr	-1458(ra) # 80002a4c <trapinit>
    trapinithart();  // install kernel trap vector
    80001006:	00002097          	auipc	ra,0x2
    8000100a:	a6e080e7          	jalr	-1426(ra) # 80002a74 <trapinithart>
    plicinit();      // set up interrupt controller
    8000100e:	00005097          	auipc	ra,0x5
    80001012:	0ac080e7          	jalr	172(ra) # 800060ba <plicinit>
    plicinithart();  // ask PLIC for device interrupts
    80001016:	00005097          	auipc	ra,0x5
    8000101a:	0ba080e7          	jalr	186(ra) # 800060d0 <plicinithart>
    binit();         // buffer cache
    8000101e:	00002097          	auipc	ra,0x2
    80001022:	266080e7          	jalr	614(ra) # 80003284 <binit>
    iinit();         // inode table
    80001026:	00003097          	auipc	ra,0x3
    8000102a:	90a080e7          	jalr	-1782(ra) # 80003930 <iinit>
    fileinit();      // file table
    8000102e:	00004097          	auipc	ra,0x4
    80001032:	8a8080e7          	jalr	-1880(ra) # 800048d6 <fileinit>
    virtio_disk_init(); // emulated hard disk
    80001036:	00005097          	auipc	ra,0x5
    8000103a:	1a2080e7          	jalr	418(ra) # 800061d8 <virtio_disk_init>
    userinit();      // first user process
    8000103e:	00001097          	auipc	ra,0x1
    80001042:	e0a080e7          	jalr	-502(ra) # 80001e48 <userinit>
    __sync_synchronize();
    80001046:	0ff0000f          	fence
    started = 1;
    8000104a:	4785                	li	a5,1
    8000104c:	00008717          	auipc	a4,0x8
    80001050:	a0f72623          	sw	a5,-1524(a4) # 80008a58 <started>
    80001054:	b789                	j	80000f96 <main+0x56>

0000000080001056 <kvminithart>:

// Switch h/w page table register to the kernel's page table,
// and enable paging.
void
kvminithart()
{
    80001056:	1141                	addi	sp,sp,-16
    80001058:	e422                	sd	s0,8(sp)
    8000105a:	0800                	addi	s0,sp,16
// flush the TLB.
static inline void
sfence_vma()
{
  // the zero, zero means flush all TLB entries.
  asm volatile("sfence.vma zero, zero");
    8000105c:	12000073          	sfence.vma
  // wait for any previous writes to the page table memory to finish.
  sfence_vma();

  w_satp(MAKE_SATP(kernel_pagetable));
    80001060:	00008797          	auipc	a5,0x8
    80001064:	a007b783          	ld	a5,-1536(a5) # 80008a60 <kernel_pagetable>
    80001068:	83b1                	srli	a5,a5,0xc
    8000106a:	577d                	li	a4,-1
    8000106c:	177e                	slli	a4,a4,0x3f
    8000106e:	8fd9                	or	a5,a5,a4
  asm volatile("csrw satp, %0" : : "r" (x));
    80001070:	18079073          	csrw	satp,a5
  asm volatile("sfence.vma zero, zero");
    80001074:	12000073          	sfence.vma

  // flush stale entries from the TLB.
  sfence_vma();
}
    80001078:	6422                	ld	s0,8(sp)
    8000107a:	0141                	addi	sp,sp,16
    8000107c:	8082                	ret

000000008000107e <walk>:
//   21..29 -- 9 bits of level-1 index.
//   12..20 -- 9 bits of level-0 index.
//    0..11 -- 12 bits of byte offset within the page.
pte_t *
walk(pagetable_t pagetable, uint64 va, int alloc)
{
    8000107e:	7139                	addi	sp,sp,-64
    80001080:	fc06                	sd	ra,56(sp)
    80001082:	f822                	sd	s0,48(sp)
    80001084:	f426                	sd	s1,40(sp)
    80001086:	f04a                	sd	s2,32(sp)
    80001088:	ec4e                	sd	s3,24(sp)
    8000108a:	e852                	sd	s4,16(sp)
    8000108c:	e456                	sd	s5,8(sp)
    8000108e:	e05a                	sd	s6,0(sp)
    80001090:	0080                	addi	s0,sp,64
    80001092:	84aa                	mv	s1,a0
    80001094:	89ae                	mv	s3,a1
    80001096:	8ab2                	mv	s5,a2
  if(va >= MAXVA)
    80001098:	57fd                	li	a5,-1
    8000109a:	83e9                	srli	a5,a5,0x1a
    8000109c:	4a79                	li	s4,30
    panic("walk");

  for(int level = 2; level > 0; level--) {
    8000109e:	4b31                	li	s6,12
  if(va >= MAXVA)
    800010a0:	04b7f263          	bgeu	a5,a1,800010e4 <walk+0x66>
    panic("walk");
    800010a4:	00007517          	auipc	a0,0x7
    800010a8:	06c50513          	addi	a0,a0,108 # 80008110 <digits+0xc0>
    800010ac:	fffff097          	auipc	ra,0xfffff
    800010b0:	47c080e7          	jalr	1148(ra) # 80000528 <panic>
    pte_t *pte = &pagetable[PX(level, va)];
    if(*pte & PTE_V) {
      pagetable = (pagetable_t)PTE2PA(*pte);
    } else {
      if(!alloc || (pagetable = (pde_t*)kalloc()) == 0)
    800010b4:	060a8663          	beqz	s5,80001120 <walk+0xa2>
    800010b8:	00000097          	auipc	ra,0x0
    800010bc:	aa2080e7          	jalr	-1374(ra) # 80000b5a <kalloc>
    800010c0:	84aa                	mv	s1,a0
    800010c2:	c529                	beqz	a0,8000110c <walk+0x8e>
        return 0;
      memset(pagetable, 0, PGSIZE);
    800010c4:	6605                	lui	a2,0x1
    800010c6:	4581                	li	a1,0
    800010c8:	00000097          	auipc	ra,0x0
    800010cc:	cca080e7          	jalr	-822(ra) # 80000d92 <memset>
      *pte = PA2PTE(pagetable) | PTE_V;
    800010d0:	00c4d793          	srli	a5,s1,0xc
    800010d4:	07aa                	slli	a5,a5,0xa
    800010d6:	0017e793          	ori	a5,a5,1
    800010da:	00f93023          	sd	a5,0(s2)
  for(int level = 2; level > 0; level--) {
    800010de:	3a5d                	addiw	s4,s4,-9
    800010e0:	036a0063          	beq	s4,s6,80001100 <walk+0x82>
    pte_t *pte = &pagetable[PX(level, va)];
    800010e4:	0149d933          	srl	s2,s3,s4
    800010e8:	1ff97913          	andi	s2,s2,511
    800010ec:	090e                	slli	s2,s2,0x3
    800010ee:	9926                	add	s2,s2,s1
    if(*pte & PTE_V) {
    800010f0:	00093483          	ld	s1,0(s2)
    800010f4:	0014f793          	andi	a5,s1,1
    800010f8:	dfd5                	beqz	a5,800010b4 <walk+0x36>
      pagetable = (pagetable_t)PTE2PA(*pte);
    800010fa:	80a9                	srli	s1,s1,0xa
    800010fc:	04b2                	slli	s1,s1,0xc
    800010fe:	b7c5                	j	800010de <walk+0x60>
    }
  }
  return &pagetable[PX(0, va)];
    80001100:	00c9d513          	srli	a0,s3,0xc
    80001104:	1ff57513          	andi	a0,a0,511
    80001108:	050e                	slli	a0,a0,0x3
    8000110a:	9526                	add	a0,a0,s1
}
    8000110c:	70e2                	ld	ra,56(sp)
    8000110e:	7442                	ld	s0,48(sp)
    80001110:	74a2                	ld	s1,40(sp)
    80001112:	7902                	ld	s2,32(sp)
    80001114:	69e2                	ld	s3,24(sp)
    80001116:	6a42                	ld	s4,16(sp)
    80001118:	6aa2                	ld	s5,8(sp)
    8000111a:	6b02                	ld	s6,0(sp)
    8000111c:	6121                	addi	sp,sp,64
    8000111e:	8082                	ret
        return 0;
    80001120:	4501                	li	a0,0
    80001122:	b7ed                	j	8000110c <walk+0x8e>

0000000080001124 <walkaddr>:
walkaddr(pagetable_t pagetable, uint64 va)
{
  pte_t *pte;
  uint64 pa;

  if(va >= MAXVA)
    80001124:	57fd                	li	a5,-1
    80001126:	83e9                	srli	a5,a5,0x1a
    80001128:	00b7f463          	bgeu	a5,a1,80001130 <walkaddr+0xc>
    return 0;
    8000112c:	4501                	li	a0,0
    return 0;
  if((*pte & PTE_U) == 0)
    return 0;
  pa = PTE2PA(*pte);
  return pa;
}
    8000112e:	8082                	ret
{
    80001130:	1141                	addi	sp,sp,-16
    80001132:	e406                	sd	ra,8(sp)
    80001134:	e022                	sd	s0,0(sp)
    80001136:	0800                	addi	s0,sp,16
  pte = walk(pagetable, va, 0);
    80001138:	4601                	li	a2,0
    8000113a:	00000097          	auipc	ra,0x0
    8000113e:	f44080e7          	jalr	-188(ra) # 8000107e <walk>
  if(pte == 0)
    80001142:	c105                	beqz	a0,80001162 <walkaddr+0x3e>
  if((*pte & PTE_V) == 0)
    80001144:	611c                	ld	a5,0(a0)
  if((*pte & PTE_U) == 0)
    80001146:	0117f693          	andi	a3,a5,17
    8000114a:	4745                	li	a4,17
    return 0;
    8000114c:	4501                	li	a0,0
  if((*pte & PTE_U) == 0)
    8000114e:	00e68663          	beq	a3,a4,8000115a <walkaddr+0x36>
}
    80001152:	60a2                	ld	ra,8(sp)
    80001154:	6402                	ld	s0,0(sp)
    80001156:	0141                	addi	sp,sp,16
    80001158:	8082                	ret
  pa = PTE2PA(*pte);
    8000115a:	00a7d513          	srli	a0,a5,0xa
    8000115e:	0532                	slli	a0,a0,0xc
  return pa;
    80001160:	bfcd                	j	80001152 <walkaddr+0x2e>
    return 0;
    80001162:	4501                	li	a0,0
    80001164:	b7fd                	j	80001152 <walkaddr+0x2e>

0000000080001166 <mappages>:
// physical addresses starting at pa. va and size might not
// be page-aligned. Returns 0 on success, -1 if walk() couldn't
// allocate a needed page-table page.
int
mappages(pagetable_t pagetable, uint64 va, uint64 size, uint64 pa, int perm)
{
    80001166:	715d                	addi	sp,sp,-80
    80001168:	e486                	sd	ra,72(sp)
    8000116a:	e0a2                	sd	s0,64(sp)
    8000116c:	fc26                	sd	s1,56(sp)
    8000116e:	f84a                	sd	s2,48(sp)
    80001170:	f44e                	sd	s3,40(sp)
    80001172:	f052                	sd	s4,32(sp)
    80001174:	ec56                	sd	s5,24(sp)
    80001176:	e85a                	sd	s6,16(sp)
    80001178:	e45e                	sd	s7,8(sp)
    8000117a:	0880                	addi	s0,sp,80
  uint64 a, last;
  pte_t *pte;

  if(size == 0)
    8000117c:	c205                	beqz	a2,8000119c <mappages+0x36>
    8000117e:	8aaa                	mv	s5,a0
    80001180:	8b3a                	mv	s6,a4
    panic("mappages: size");
  
  a = PGROUNDDOWN(va);
    80001182:	77fd                	lui	a5,0xfffff
    80001184:	00f5fa33          	and	s4,a1,a5
  last = PGROUNDDOWN(va + size - 1);
    80001188:	15fd                	addi	a1,a1,-1
    8000118a:	00c589b3          	add	s3,a1,a2
    8000118e:	00f9f9b3          	and	s3,s3,a5
  a = PGROUNDDOWN(va);
    80001192:	8952                	mv	s2,s4
    80001194:	41468a33          	sub	s4,a3,s4
    if(*pte & PTE_V)
      panic("mappages: remap");
    *pte = PA2PTE(pa) | perm | PTE_V;
    if(a == last)
      break;
    a += PGSIZE;
    80001198:	6b85                	lui	s7,0x1
    8000119a:	a015                	j	800011be <mappages+0x58>
    panic("mappages: size");
    8000119c:	00007517          	auipc	a0,0x7
    800011a0:	f7c50513          	addi	a0,a0,-132 # 80008118 <digits+0xc8>
    800011a4:	fffff097          	auipc	ra,0xfffff
    800011a8:	384080e7          	jalr	900(ra) # 80000528 <panic>
      panic("mappages: remap");
    800011ac:	00007517          	auipc	a0,0x7
    800011b0:	f7c50513          	addi	a0,a0,-132 # 80008128 <digits+0xd8>
    800011b4:	fffff097          	auipc	ra,0xfffff
    800011b8:	374080e7          	jalr	884(ra) # 80000528 <panic>
    a += PGSIZE;
    800011bc:	995e                	add	s2,s2,s7
  for(;;){
    800011be:	012a04b3          	add	s1,s4,s2
    if((pte = walk(pagetable, a, 1)) == 0)
    800011c2:	4605                	li	a2,1
    800011c4:	85ca                	mv	a1,s2
    800011c6:	8556                	mv	a0,s5
    800011c8:	00000097          	auipc	ra,0x0
    800011cc:	eb6080e7          	jalr	-330(ra) # 8000107e <walk>
    800011d0:	cd19                	beqz	a0,800011ee <mappages+0x88>
    if(*pte & PTE_V)
    800011d2:	611c                	ld	a5,0(a0)
    800011d4:	8b85                	andi	a5,a5,1
    800011d6:	fbf9                	bnez	a5,800011ac <mappages+0x46>
    *pte = PA2PTE(pa) | perm | PTE_V;
    800011d8:	80b1                	srli	s1,s1,0xc
    800011da:	04aa                	slli	s1,s1,0xa
    800011dc:	0164e4b3          	or	s1,s1,s6
    800011e0:	0014e493          	ori	s1,s1,1
    800011e4:	e104                	sd	s1,0(a0)
    if(a == last)
    800011e6:	fd391be3          	bne	s2,s3,800011bc <mappages+0x56>
    pa += PGSIZE;
  }
  return 0;
    800011ea:	4501                	li	a0,0
    800011ec:	a011                	j	800011f0 <mappages+0x8a>
      return -1;
    800011ee:	557d                	li	a0,-1
}
    800011f0:	60a6                	ld	ra,72(sp)
    800011f2:	6406                	ld	s0,64(sp)
    800011f4:	74e2                	ld	s1,56(sp)
    800011f6:	7942                	ld	s2,48(sp)
    800011f8:	79a2                	ld	s3,40(sp)
    800011fa:	7a02                	ld	s4,32(sp)
    800011fc:	6ae2                	ld	s5,24(sp)
    800011fe:	6b42                	ld	s6,16(sp)
    80001200:	6ba2                	ld	s7,8(sp)
    80001202:	6161                	addi	sp,sp,80
    80001204:	8082                	ret

0000000080001206 <kvmmap>:
{
    80001206:	1141                	addi	sp,sp,-16
    80001208:	e406                	sd	ra,8(sp)
    8000120a:	e022                	sd	s0,0(sp)
    8000120c:	0800                	addi	s0,sp,16
    8000120e:	87b6                	mv	a5,a3
  if(mappages(kpgtbl, va, sz, pa, perm) != 0)
    80001210:	86b2                	mv	a3,a2
    80001212:	863e                	mv	a2,a5
    80001214:	00000097          	auipc	ra,0x0
    80001218:	f52080e7          	jalr	-174(ra) # 80001166 <mappages>
    8000121c:	e509                	bnez	a0,80001226 <kvmmap+0x20>
}
    8000121e:	60a2                	ld	ra,8(sp)
    80001220:	6402                	ld	s0,0(sp)
    80001222:	0141                	addi	sp,sp,16
    80001224:	8082                	ret
    panic("kvmmap");
    80001226:	00007517          	auipc	a0,0x7
    8000122a:	f1250513          	addi	a0,a0,-238 # 80008138 <digits+0xe8>
    8000122e:	fffff097          	auipc	ra,0xfffff
    80001232:	2fa080e7          	jalr	762(ra) # 80000528 <panic>

0000000080001236 <kvmmake>:
{
    80001236:	1101                	addi	sp,sp,-32
    80001238:	ec06                	sd	ra,24(sp)
    8000123a:	e822                	sd	s0,16(sp)
    8000123c:	e426                	sd	s1,8(sp)
    8000123e:	e04a                	sd	s2,0(sp)
    80001240:	1000                	addi	s0,sp,32
  kpgtbl = (pagetable_t) kalloc();
    80001242:	00000097          	auipc	ra,0x0
    80001246:	918080e7          	jalr	-1768(ra) # 80000b5a <kalloc>
    8000124a:	84aa                	mv	s1,a0
  memset(kpgtbl, 0, PGSIZE);
    8000124c:	6605                	lui	a2,0x1
    8000124e:	4581                	li	a1,0
    80001250:	00000097          	auipc	ra,0x0
    80001254:	b42080e7          	jalr	-1214(ra) # 80000d92 <memset>
  kvmmap(kpgtbl, UART0, UART0, PGSIZE, PTE_R | PTE_W);
    80001258:	4719                	li	a4,6
    8000125a:	6685                	lui	a3,0x1
    8000125c:	10000637          	lui	a2,0x10000
    80001260:	100005b7          	lui	a1,0x10000
    80001264:	8526                	mv	a0,s1
    80001266:	00000097          	auipc	ra,0x0
    8000126a:	fa0080e7          	jalr	-96(ra) # 80001206 <kvmmap>
  kvmmap(kpgtbl, VIRTIO0, VIRTIO0, PGSIZE, PTE_R | PTE_W);
    8000126e:	4719                	li	a4,6
    80001270:	6685                	lui	a3,0x1
    80001272:	10001637          	lui	a2,0x10001
    80001276:	100015b7          	lui	a1,0x10001
    8000127a:	8526                	mv	a0,s1
    8000127c:	00000097          	auipc	ra,0x0
    80001280:	f8a080e7          	jalr	-118(ra) # 80001206 <kvmmap>
  kvmmap(kpgtbl, PLIC, PLIC, 0x400000, PTE_R | PTE_W);
    80001284:	4719                	li	a4,6
    80001286:	004006b7          	lui	a3,0x400
    8000128a:	0c000637          	lui	a2,0xc000
    8000128e:	0c0005b7          	lui	a1,0xc000
    80001292:	8526                	mv	a0,s1
    80001294:	00000097          	auipc	ra,0x0
    80001298:	f72080e7          	jalr	-142(ra) # 80001206 <kvmmap>
  kvmmap(kpgtbl, KERNBASE, KERNBASE, (uint64)etext-KERNBASE, PTE_R | PTE_X);
    8000129c:	00007917          	auipc	s2,0x7
    800012a0:	d6490913          	addi	s2,s2,-668 # 80008000 <etext>
    800012a4:	4729                	li	a4,10
    800012a6:	80007697          	auipc	a3,0x80007
    800012aa:	d5a68693          	addi	a3,a3,-678 # 8000 <_entry-0x7fff8000>
    800012ae:	4605                	li	a2,1
    800012b0:	067e                	slli	a2,a2,0x1f
    800012b2:	85b2                	mv	a1,a2
    800012b4:	8526                	mv	a0,s1
    800012b6:	00000097          	auipc	ra,0x0
    800012ba:	f50080e7          	jalr	-176(ra) # 80001206 <kvmmap>
  kvmmap(kpgtbl, (uint64)etext, (uint64)etext, PHYSTOP-(uint64)etext, PTE_R | PTE_W);
    800012be:	4719                	li	a4,6
    800012c0:	46c5                	li	a3,17
    800012c2:	06ee                	slli	a3,a3,0x1b
    800012c4:	412686b3          	sub	a3,a3,s2
    800012c8:	864a                	mv	a2,s2
    800012ca:	85ca                	mv	a1,s2
    800012cc:	8526                	mv	a0,s1
    800012ce:	00000097          	auipc	ra,0x0
    800012d2:	f38080e7          	jalr	-200(ra) # 80001206 <kvmmap>
  kvmmap(kpgtbl, TRAMPOLINE, (uint64)trampoline, PGSIZE, PTE_R | PTE_X);
    800012d6:	4729                	li	a4,10
    800012d8:	6685                	lui	a3,0x1
    800012da:	00006617          	auipc	a2,0x6
    800012de:	d2660613          	addi	a2,a2,-730 # 80007000 <_trampoline>
    800012e2:	040005b7          	lui	a1,0x4000
    800012e6:	15fd                	addi	a1,a1,-1
    800012e8:	05b2                	slli	a1,a1,0xc
    800012ea:	8526                	mv	a0,s1
    800012ec:	00000097          	auipc	ra,0x0
    800012f0:	f1a080e7          	jalr	-230(ra) # 80001206 <kvmmap>
  proc_mapstacks(kpgtbl);
    800012f4:	8526                	mv	a0,s1
    800012f6:	00000097          	auipc	ra,0x0
    800012fa:	6d6080e7          	jalr	1750(ra) # 800019cc <proc_mapstacks>
}
    800012fe:	8526                	mv	a0,s1
    80001300:	60e2                	ld	ra,24(sp)
    80001302:	6442                	ld	s0,16(sp)
    80001304:	64a2                	ld	s1,8(sp)
    80001306:	6902                	ld	s2,0(sp)
    80001308:	6105                	addi	sp,sp,32
    8000130a:	8082                	ret

000000008000130c <kvminit>:
{
    8000130c:	1141                	addi	sp,sp,-16
    8000130e:	e406                	sd	ra,8(sp)
    80001310:	e022                	sd	s0,0(sp)
    80001312:	0800                	addi	s0,sp,16
  kernel_pagetable = kvmmake();
    80001314:	00000097          	auipc	ra,0x0
    80001318:	f22080e7          	jalr	-222(ra) # 80001236 <kvmmake>
    8000131c:	00007797          	auipc	a5,0x7
    80001320:	74a7b223          	sd	a0,1860(a5) # 80008a60 <kernel_pagetable>
}
    80001324:	60a2                	ld	ra,8(sp)
    80001326:	6402                	ld	s0,0(sp)
    80001328:	0141                	addi	sp,sp,16
    8000132a:	8082                	ret

000000008000132c <uvmunmap>:
// Remove npages of mappings starting from va. va must be
// page-aligned. The mappings must exist.
// Optionally free the physical memory.
void
uvmunmap(pagetable_t pagetable, uint64 va, uint64 npages, int do_free)
{
    8000132c:	715d                	addi	sp,sp,-80
    8000132e:	e486                	sd	ra,72(sp)
    80001330:	e0a2                	sd	s0,64(sp)
    80001332:	fc26                	sd	s1,56(sp)
    80001334:	f84a                	sd	s2,48(sp)
    80001336:	f44e                	sd	s3,40(sp)
    80001338:	f052                	sd	s4,32(sp)
    8000133a:	ec56                	sd	s5,24(sp)
    8000133c:	e85a                	sd	s6,16(sp)
    8000133e:	e45e                	sd	s7,8(sp)
    80001340:	0880                	addi	s0,sp,80
  uint64 a;
  pte_t *pte;

  if((va % PGSIZE) != 0)
    80001342:	03459793          	slli	a5,a1,0x34
    80001346:	e795                	bnez	a5,80001372 <uvmunmap+0x46>
    80001348:	8a2a                	mv	s4,a0
    8000134a:	892e                	mv	s2,a1
    8000134c:	8ab6                	mv	s5,a3
    panic("uvmunmap: not aligned");

  for(a = va; a < va + npages*PGSIZE; a += PGSIZE){
    8000134e:	0632                	slli	a2,a2,0xc
    80001350:	00b609b3          	add	s3,a2,a1
    if((pte = walk(pagetable, a, 0)) == 0)
      panic("uvmunmap: walk");
    if((*pte & PTE_V) == 0)
      panic("uvmunmap: not mapped");
    if(PTE_FLAGS(*pte) == PTE_V)
    80001354:	4b85                	li	s7,1
  for(a = va; a < va + npages*PGSIZE; a += PGSIZE){
    80001356:	6b05                	lui	s6,0x1
    80001358:	0735e863          	bltu	a1,s3,800013c8 <uvmunmap+0x9c>
      uint64 pa = PTE2PA(*pte);
      kfree((void*)pa);
    }
    *pte = 0;
  }
}
    8000135c:	60a6                	ld	ra,72(sp)
    8000135e:	6406                	ld	s0,64(sp)
    80001360:	74e2                	ld	s1,56(sp)
    80001362:	7942                	ld	s2,48(sp)
    80001364:	79a2                	ld	s3,40(sp)
    80001366:	7a02                	ld	s4,32(sp)
    80001368:	6ae2                	ld	s5,24(sp)
    8000136a:	6b42                	ld	s6,16(sp)
    8000136c:	6ba2                	ld	s7,8(sp)
    8000136e:	6161                	addi	sp,sp,80
    80001370:	8082                	ret
    panic("uvmunmap: not aligned");
    80001372:	00007517          	auipc	a0,0x7
    80001376:	dce50513          	addi	a0,a0,-562 # 80008140 <digits+0xf0>
    8000137a:	fffff097          	auipc	ra,0xfffff
    8000137e:	1ae080e7          	jalr	430(ra) # 80000528 <panic>
      panic("uvmunmap: walk");
    80001382:	00007517          	auipc	a0,0x7
    80001386:	dd650513          	addi	a0,a0,-554 # 80008158 <digits+0x108>
    8000138a:	fffff097          	auipc	ra,0xfffff
    8000138e:	19e080e7          	jalr	414(ra) # 80000528 <panic>
      panic("uvmunmap: not mapped");
    80001392:	00007517          	auipc	a0,0x7
    80001396:	dd650513          	addi	a0,a0,-554 # 80008168 <digits+0x118>
    8000139a:	fffff097          	auipc	ra,0xfffff
    8000139e:	18e080e7          	jalr	398(ra) # 80000528 <panic>
      panic("uvmunmap: not a leaf");
    800013a2:	00007517          	auipc	a0,0x7
    800013a6:	dde50513          	addi	a0,a0,-546 # 80008180 <digits+0x130>
    800013aa:	fffff097          	auipc	ra,0xfffff
    800013ae:	17e080e7          	jalr	382(ra) # 80000528 <panic>
      uint64 pa = PTE2PA(*pte);
    800013b2:	8129                	srli	a0,a0,0xa
      kfree((void*)pa);
    800013b4:	0532                	slli	a0,a0,0xc
    800013b6:	fffff097          	auipc	ra,0xfffff
    800013ba:	63e080e7          	jalr	1598(ra) # 800009f4 <kfree>
    *pte = 0;
    800013be:	0004b023          	sd	zero,0(s1)
  for(a = va; a < va + npages*PGSIZE; a += PGSIZE){
    800013c2:	995a                	add	s2,s2,s6
    800013c4:	f9397ce3          	bgeu	s2,s3,8000135c <uvmunmap+0x30>
    if((pte = walk(pagetable, a, 0)) == 0)
    800013c8:	4601                	li	a2,0
    800013ca:	85ca                	mv	a1,s2
    800013cc:	8552                	mv	a0,s4
    800013ce:	00000097          	auipc	ra,0x0
    800013d2:	cb0080e7          	jalr	-848(ra) # 8000107e <walk>
    800013d6:	84aa                	mv	s1,a0
    800013d8:	d54d                	beqz	a0,80001382 <uvmunmap+0x56>
    if((*pte & PTE_V) == 0)
    800013da:	6108                	ld	a0,0(a0)
    800013dc:	00157793          	andi	a5,a0,1
    800013e0:	dbcd                	beqz	a5,80001392 <uvmunmap+0x66>
    if(PTE_FLAGS(*pte) == PTE_V)
    800013e2:	3ff57793          	andi	a5,a0,1023
    800013e6:	fb778ee3          	beq	a5,s7,800013a2 <uvmunmap+0x76>
    if(do_free){
    800013ea:	fc0a8ae3          	beqz	s5,800013be <uvmunmap+0x92>
    800013ee:	b7d1                	j	800013b2 <uvmunmap+0x86>

00000000800013f0 <uvmcreate>:

// create an empty user page table.
// returns 0 if out of memory.
pagetable_t
uvmcreate()
{
    800013f0:	1101                	addi	sp,sp,-32
    800013f2:	ec06                	sd	ra,24(sp)
    800013f4:	e822                	sd	s0,16(sp)
    800013f6:	e426                	sd	s1,8(sp)
    800013f8:	1000                	addi	s0,sp,32
  pagetable_t pagetable;
  pagetable = (pagetable_t) kalloc();
    800013fa:	fffff097          	auipc	ra,0xfffff
    800013fe:	760080e7          	jalr	1888(ra) # 80000b5a <kalloc>
    80001402:	84aa                	mv	s1,a0
  if(pagetable == 0)
    80001404:	c519                	beqz	a0,80001412 <uvmcreate+0x22>
    return 0;
  memset(pagetable, 0, PGSIZE);
    80001406:	6605                	lui	a2,0x1
    80001408:	4581                	li	a1,0
    8000140a:	00000097          	auipc	ra,0x0
    8000140e:	988080e7          	jalr	-1656(ra) # 80000d92 <memset>
  return pagetable;
}
    80001412:	8526                	mv	a0,s1
    80001414:	60e2                	ld	ra,24(sp)
    80001416:	6442                	ld	s0,16(sp)
    80001418:	64a2                	ld	s1,8(sp)
    8000141a:	6105                	addi	sp,sp,32
    8000141c:	8082                	ret

000000008000141e <uvmfirst>:
// Load the user initcode into address 0 of pagetable,
// for the very first process.
// sz must be less than a page.
void
uvmfirst(pagetable_t pagetable, uchar *src, uint sz)
{
    8000141e:	7179                	addi	sp,sp,-48
    80001420:	f406                	sd	ra,40(sp)
    80001422:	f022                	sd	s0,32(sp)
    80001424:	ec26                	sd	s1,24(sp)
    80001426:	e84a                	sd	s2,16(sp)
    80001428:	e44e                	sd	s3,8(sp)
    8000142a:	e052                	sd	s4,0(sp)
    8000142c:	1800                	addi	s0,sp,48
  char *mem;

  if(sz >= PGSIZE)
    8000142e:	6785                	lui	a5,0x1
    80001430:	04f67863          	bgeu	a2,a5,80001480 <uvmfirst+0x62>
    80001434:	8a2a                	mv	s4,a0
    80001436:	89ae                	mv	s3,a1
    80001438:	84b2                	mv	s1,a2
    panic("uvmfirst: more than a page");
  mem = kalloc();
    8000143a:	fffff097          	auipc	ra,0xfffff
    8000143e:	720080e7          	jalr	1824(ra) # 80000b5a <kalloc>
    80001442:	892a                	mv	s2,a0
  memset(mem, 0, PGSIZE);
    80001444:	6605                	lui	a2,0x1
    80001446:	4581                	li	a1,0
    80001448:	00000097          	auipc	ra,0x0
    8000144c:	94a080e7          	jalr	-1718(ra) # 80000d92 <memset>
  mappages(pagetable, 0, PGSIZE, (uint64)mem, PTE_W|PTE_R|PTE_X|PTE_U);
    80001450:	4779                	li	a4,30
    80001452:	86ca                	mv	a3,s2
    80001454:	6605                	lui	a2,0x1
    80001456:	4581                	li	a1,0
    80001458:	8552                	mv	a0,s4
    8000145a:	00000097          	auipc	ra,0x0
    8000145e:	d0c080e7          	jalr	-756(ra) # 80001166 <mappages>
  memmove(mem, src, sz);
    80001462:	8626                	mv	a2,s1
    80001464:	85ce                	mv	a1,s3
    80001466:	854a                	mv	a0,s2
    80001468:	00000097          	auipc	ra,0x0
    8000146c:	98a080e7          	jalr	-1654(ra) # 80000df2 <memmove>
}
    80001470:	70a2                	ld	ra,40(sp)
    80001472:	7402                	ld	s0,32(sp)
    80001474:	64e2                	ld	s1,24(sp)
    80001476:	6942                	ld	s2,16(sp)
    80001478:	69a2                	ld	s3,8(sp)
    8000147a:	6a02                	ld	s4,0(sp)
    8000147c:	6145                	addi	sp,sp,48
    8000147e:	8082                	ret
    panic("uvmfirst: more than a page");
    80001480:	00007517          	auipc	a0,0x7
    80001484:	d1850513          	addi	a0,a0,-744 # 80008198 <digits+0x148>
    80001488:	fffff097          	auipc	ra,0xfffff
    8000148c:	0a0080e7          	jalr	160(ra) # 80000528 <panic>

0000000080001490 <uvmdealloc>:
// newsz.  oldsz and newsz need not be page-aligned, nor does newsz
// need to be less than oldsz.  oldsz can be larger than the actual
// process size.  Returns the new process size.
uint64
uvmdealloc(pagetable_t pagetable, uint64 oldsz, uint64 newsz)
{
    80001490:	1101                	addi	sp,sp,-32
    80001492:	ec06                	sd	ra,24(sp)
    80001494:	e822                	sd	s0,16(sp)
    80001496:	e426                	sd	s1,8(sp)
    80001498:	1000                	addi	s0,sp,32
  if(newsz >= oldsz)
    return oldsz;
    8000149a:	84ae                	mv	s1,a1
  if(newsz >= oldsz)
    8000149c:	00b67d63          	bgeu	a2,a1,800014b6 <uvmdealloc+0x26>
    800014a0:	84b2                	mv	s1,a2

  if(PGROUNDUP(newsz) < PGROUNDUP(oldsz)){
    800014a2:	6785                	lui	a5,0x1
    800014a4:	17fd                	addi	a5,a5,-1
    800014a6:	00f60733          	add	a4,a2,a5
    800014aa:	767d                	lui	a2,0xfffff
    800014ac:	8f71                	and	a4,a4,a2
    800014ae:	97ae                	add	a5,a5,a1
    800014b0:	8ff1                	and	a5,a5,a2
    800014b2:	00f76863          	bltu	a4,a5,800014c2 <uvmdealloc+0x32>
    int npages = (PGROUNDUP(oldsz) - PGROUNDUP(newsz)) / PGSIZE;
    uvmunmap(pagetable, PGROUNDUP(newsz), npages, 1);
  }

  return newsz;
}
    800014b6:	8526                	mv	a0,s1
    800014b8:	60e2                	ld	ra,24(sp)
    800014ba:	6442                	ld	s0,16(sp)
    800014bc:	64a2                	ld	s1,8(sp)
    800014be:	6105                	addi	sp,sp,32
    800014c0:	8082                	ret
    int npages = (PGROUNDUP(oldsz) - PGROUNDUP(newsz)) / PGSIZE;
    800014c2:	8f99                	sub	a5,a5,a4
    800014c4:	83b1                	srli	a5,a5,0xc
    uvmunmap(pagetable, PGROUNDUP(newsz), npages, 1);
    800014c6:	4685                	li	a3,1
    800014c8:	0007861b          	sext.w	a2,a5
    800014cc:	85ba                	mv	a1,a4
    800014ce:	00000097          	auipc	ra,0x0
    800014d2:	e5e080e7          	jalr	-418(ra) # 8000132c <uvmunmap>
    800014d6:	b7c5                	j	800014b6 <uvmdealloc+0x26>

00000000800014d8 <uvmalloc>:
  if(newsz < oldsz)
    800014d8:	0ab66563          	bltu	a2,a1,80001582 <uvmalloc+0xaa>
{
    800014dc:	7139                	addi	sp,sp,-64
    800014de:	fc06                	sd	ra,56(sp)
    800014e0:	f822                	sd	s0,48(sp)
    800014e2:	f426                	sd	s1,40(sp)
    800014e4:	f04a                	sd	s2,32(sp)
    800014e6:	ec4e                	sd	s3,24(sp)
    800014e8:	e852                	sd	s4,16(sp)
    800014ea:	e456                	sd	s5,8(sp)
    800014ec:	e05a                	sd	s6,0(sp)
    800014ee:	0080                	addi	s0,sp,64
    800014f0:	8aaa                	mv	s5,a0
    800014f2:	8a32                	mv	s4,a2
  oldsz = PGROUNDUP(oldsz);
    800014f4:	6985                	lui	s3,0x1
    800014f6:	19fd                	addi	s3,s3,-1
    800014f8:	95ce                	add	a1,a1,s3
    800014fa:	79fd                	lui	s3,0xfffff
    800014fc:	0135f9b3          	and	s3,a1,s3
  for(a = oldsz; a < newsz; a += PGSIZE){
    80001500:	08c9f363          	bgeu	s3,a2,80001586 <uvmalloc+0xae>
    80001504:	894e                	mv	s2,s3
    if(mappages(pagetable, a, PGSIZE, (uint64)mem, PTE_R|PTE_U|xperm) != 0){
    80001506:	0126eb13          	ori	s6,a3,18
    mem = kalloc();
    8000150a:	fffff097          	auipc	ra,0xfffff
    8000150e:	650080e7          	jalr	1616(ra) # 80000b5a <kalloc>
    80001512:	84aa                	mv	s1,a0
    if(mem == 0){
    80001514:	c51d                	beqz	a0,80001542 <uvmalloc+0x6a>
    memset(mem, 0, PGSIZE);
    80001516:	6605                	lui	a2,0x1
    80001518:	4581                	li	a1,0
    8000151a:	00000097          	auipc	ra,0x0
    8000151e:	878080e7          	jalr	-1928(ra) # 80000d92 <memset>
    if(mappages(pagetable, a, PGSIZE, (uint64)mem, PTE_R|PTE_U|xperm) != 0){
    80001522:	875a                	mv	a4,s6
    80001524:	86a6                	mv	a3,s1
    80001526:	6605                	lui	a2,0x1
    80001528:	85ca                	mv	a1,s2
    8000152a:	8556                	mv	a0,s5
    8000152c:	00000097          	auipc	ra,0x0
    80001530:	c3a080e7          	jalr	-966(ra) # 80001166 <mappages>
    80001534:	e90d                	bnez	a0,80001566 <uvmalloc+0x8e>
  for(a = oldsz; a < newsz; a += PGSIZE){
    80001536:	6785                	lui	a5,0x1
    80001538:	993e                	add	s2,s2,a5
    8000153a:	fd4968e3          	bltu	s2,s4,8000150a <uvmalloc+0x32>
  return newsz;
    8000153e:	8552                	mv	a0,s4
    80001540:	a809                	j	80001552 <uvmalloc+0x7a>
      uvmdealloc(pagetable, a, oldsz);
    80001542:	864e                	mv	a2,s3
    80001544:	85ca                	mv	a1,s2
    80001546:	8556                	mv	a0,s5
    80001548:	00000097          	auipc	ra,0x0
    8000154c:	f48080e7          	jalr	-184(ra) # 80001490 <uvmdealloc>
      return 0;
    80001550:	4501                	li	a0,0
}
    80001552:	70e2                	ld	ra,56(sp)
    80001554:	7442                	ld	s0,48(sp)
    80001556:	74a2                	ld	s1,40(sp)
    80001558:	7902                	ld	s2,32(sp)
    8000155a:	69e2                	ld	s3,24(sp)
    8000155c:	6a42                	ld	s4,16(sp)
    8000155e:	6aa2                	ld	s5,8(sp)
    80001560:	6b02                	ld	s6,0(sp)
    80001562:	6121                	addi	sp,sp,64
    80001564:	8082                	ret
      kfree(mem);
    80001566:	8526                	mv	a0,s1
    80001568:	fffff097          	auipc	ra,0xfffff
    8000156c:	48c080e7          	jalr	1164(ra) # 800009f4 <kfree>
      uvmdealloc(pagetable, a, oldsz);
    80001570:	864e                	mv	a2,s3
    80001572:	85ca                	mv	a1,s2
    80001574:	8556                	mv	a0,s5
    80001576:	00000097          	auipc	ra,0x0
    8000157a:	f1a080e7          	jalr	-230(ra) # 80001490 <uvmdealloc>
      return 0;
    8000157e:	4501                	li	a0,0
    80001580:	bfc9                	j	80001552 <uvmalloc+0x7a>
    return oldsz;
    80001582:	852e                	mv	a0,a1
}
    80001584:	8082                	ret
  return newsz;
    80001586:	8532                	mv	a0,a2
    80001588:	b7e9                	j	80001552 <uvmalloc+0x7a>

000000008000158a <freewalk>:

// Recursively free page-table pages.
// All leaf mappings must already have been removed.
void
freewalk(pagetable_t pagetable)
{
    8000158a:	7179                	addi	sp,sp,-48
    8000158c:	f406                	sd	ra,40(sp)
    8000158e:	f022                	sd	s0,32(sp)
    80001590:	ec26                	sd	s1,24(sp)
    80001592:	e84a                	sd	s2,16(sp)
    80001594:	e44e                	sd	s3,8(sp)
    80001596:	e052                	sd	s4,0(sp)
    80001598:	1800                	addi	s0,sp,48
    8000159a:	8a2a                	mv	s4,a0
  // there are 2^9 = 512 PTEs in a page table.
  for(int i = 0; i < 512; i++){
    8000159c:	84aa                	mv	s1,a0
    8000159e:	6905                	lui	s2,0x1
    800015a0:	992a                	add	s2,s2,a0
    pte_t pte = pagetable[i];
    if((pte & PTE_V) && (pte & (PTE_R|PTE_W|PTE_X)) == 0){
    800015a2:	4985                	li	s3,1
    800015a4:	a821                	j	800015bc <freewalk+0x32>
      // this PTE points to a lower-level page table.
      uint64 child = PTE2PA(pte);
    800015a6:	8129                	srli	a0,a0,0xa
      freewalk((pagetable_t)child);
    800015a8:	0532                	slli	a0,a0,0xc
    800015aa:	00000097          	auipc	ra,0x0
    800015ae:	fe0080e7          	jalr	-32(ra) # 8000158a <freewalk>
      pagetable[i] = 0;
    800015b2:	0004b023          	sd	zero,0(s1)
  for(int i = 0; i < 512; i++){
    800015b6:	04a1                	addi	s1,s1,8
    800015b8:	03248163          	beq	s1,s2,800015da <freewalk+0x50>
    pte_t pte = pagetable[i];
    800015bc:	6088                	ld	a0,0(s1)
    if((pte & PTE_V) && (pte & (PTE_R|PTE_W|PTE_X)) == 0){
    800015be:	00f57793          	andi	a5,a0,15
    800015c2:	ff3782e3          	beq	a5,s3,800015a6 <freewalk+0x1c>
    } else if(pte & PTE_V){
    800015c6:	8905                	andi	a0,a0,1
    800015c8:	d57d                	beqz	a0,800015b6 <freewalk+0x2c>
      panic("freewalk: leaf");
    800015ca:	00007517          	auipc	a0,0x7
    800015ce:	bee50513          	addi	a0,a0,-1042 # 800081b8 <digits+0x168>
    800015d2:	fffff097          	auipc	ra,0xfffff
    800015d6:	f56080e7          	jalr	-170(ra) # 80000528 <panic>
    }
  }
  kfree((void*)pagetable);
    800015da:	8552                	mv	a0,s4
    800015dc:	fffff097          	auipc	ra,0xfffff
    800015e0:	418080e7          	jalr	1048(ra) # 800009f4 <kfree>
}
    800015e4:	70a2                	ld	ra,40(sp)
    800015e6:	7402                	ld	s0,32(sp)
    800015e8:	64e2                	ld	s1,24(sp)
    800015ea:	6942                	ld	s2,16(sp)
    800015ec:	69a2                	ld	s3,8(sp)
    800015ee:	6a02                	ld	s4,0(sp)
    800015f0:	6145                	addi	sp,sp,48
    800015f2:	8082                	ret

00000000800015f4 <uvmfree>:

// Free user memory pages,
// then free page-table pages.
void
uvmfree(pagetable_t pagetable, uint64 sz)
{
    800015f4:	1101                	addi	sp,sp,-32
    800015f6:	ec06                	sd	ra,24(sp)
    800015f8:	e822                	sd	s0,16(sp)
    800015fa:	e426                	sd	s1,8(sp)
    800015fc:	1000                	addi	s0,sp,32
    800015fe:	84aa                	mv	s1,a0
  if(sz > 0)
    80001600:	e999                	bnez	a1,80001616 <uvmfree+0x22>
    uvmunmap(pagetable, 0, PGROUNDUP(sz)/PGSIZE, 1);
  freewalk(pagetable);
    80001602:	8526                	mv	a0,s1
    80001604:	00000097          	auipc	ra,0x0
    80001608:	f86080e7          	jalr	-122(ra) # 8000158a <freewalk>
}
    8000160c:	60e2                	ld	ra,24(sp)
    8000160e:	6442                	ld	s0,16(sp)
    80001610:	64a2                	ld	s1,8(sp)
    80001612:	6105                	addi	sp,sp,32
    80001614:	8082                	ret
    uvmunmap(pagetable, 0, PGROUNDUP(sz)/PGSIZE, 1);
    80001616:	6605                	lui	a2,0x1
    80001618:	167d                	addi	a2,a2,-1
    8000161a:	962e                	add	a2,a2,a1
    8000161c:	4685                	li	a3,1
    8000161e:	8231                	srli	a2,a2,0xc
    80001620:	4581                	li	a1,0
    80001622:	00000097          	auipc	ra,0x0
    80001626:	d0a080e7          	jalr	-758(ra) # 8000132c <uvmunmap>
    8000162a:	bfe1                	j	80001602 <uvmfree+0xe>

000000008000162c <uvmcopy>:
  pte_t *pte;
  uint64 pa, i;
  uint flags;
  char *mem;

  for(i = 0; i < sz; i += PGSIZE){
    8000162c:	c679                	beqz	a2,800016fa <uvmcopy+0xce>
{
    8000162e:	715d                	addi	sp,sp,-80
    80001630:	e486                	sd	ra,72(sp)
    80001632:	e0a2                	sd	s0,64(sp)
    80001634:	fc26                	sd	s1,56(sp)
    80001636:	f84a                	sd	s2,48(sp)
    80001638:	f44e                	sd	s3,40(sp)
    8000163a:	f052                	sd	s4,32(sp)
    8000163c:	ec56                	sd	s5,24(sp)
    8000163e:	e85a                	sd	s6,16(sp)
    80001640:	e45e                	sd	s7,8(sp)
    80001642:	0880                	addi	s0,sp,80
    80001644:	8b2a                	mv	s6,a0
    80001646:	8aae                	mv	s5,a1
    80001648:	8a32                	mv	s4,a2
  for(i = 0; i < sz; i += PGSIZE){
    8000164a:	4981                	li	s3,0
    if((pte = walk(old, i, 0)) == 0)
    8000164c:	4601                	li	a2,0
    8000164e:	85ce                	mv	a1,s3
    80001650:	855a                	mv	a0,s6
    80001652:	00000097          	auipc	ra,0x0
    80001656:	a2c080e7          	jalr	-1492(ra) # 8000107e <walk>
    8000165a:	c531                	beqz	a0,800016a6 <uvmcopy+0x7a>
      panic("uvmcopy: pte should exist");
    if((*pte & PTE_V) == 0)
    8000165c:	6118                	ld	a4,0(a0)
    8000165e:	00177793          	andi	a5,a4,1
    80001662:	cbb1                	beqz	a5,800016b6 <uvmcopy+0x8a>
      panic("uvmcopy: page not present");
    pa = PTE2PA(*pte);
    80001664:	00a75593          	srli	a1,a4,0xa
    80001668:	00c59b93          	slli	s7,a1,0xc
    flags = PTE_FLAGS(*pte);
    8000166c:	3ff77493          	andi	s1,a4,1023
    if((mem = kalloc()) == 0)
    80001670:	fffff097          	auipc	ra,0xfffff
    80001674:	4ea080e7          	jalr	1258(ra) # 80000b5a <kalloc>
    80001678:	892a                	mv	s2,a0
    8000167a:	c939                	beqz	a0,800016d0 <uvmcopy+0xa4>
      goto err;
    memmove(mem, (char*)pa, PGSIZE);
    8000167c:	6605                	lui	a2,0x1
    8000167e:	85de                	mv	a1,s7
    80001680:	fffff097          	auipc	ra,0xfffff
    80001684:	772080e7          	jalr	1906(ra) # 80000df2 <memmove>
    if(mappages(new, i, PGSIZE, (uint64)mem, flags) != 0){
    80001688:	8726                	mv	a4,s1
    8000168a:	86ca                	mv	a3,s2
    8000168c:	6605                	lui	a2,0x1
    8000168e:	85ce                	mv	a1,s3
    80001690:	8556                	mv	a0,s5
    80001692:	00000097          	auipc	ra,0x0
    80001696:	ad4080e7          	jalr	-1324(ra) # 80001166 <mappages>
    8000169a:	e515                	bnez	a0,800016c6 <uvmcopy+0x9a>
  for(i = 0; i < sz; i += PGSIZE){
    8000169c:	6785                	lui	a5,0x1
    8000169e:	99be                	add	s3,s3,a5
    800016a0:	fb49e6e3          	bltu	s3,s4,8000164c <uvmcopy+0x20>
    800016a4:	a081                	j	800016e4 <uvmcopy+0xb8>
      panic("uvmcopy: pte should exist");
    800016a6:	00007517          	auipc	a0,0x7
    800016aa:	b2250513          	addi	a0,a0,-1246 # 800081c8 <digits+0x178>
    800016ae:	fffff097          	auipc	ra,0xfffff
    800016b2:	e7a080e7          	jalr	-390(ra) # 80000528 <panic>
      panic("uvmcopy: page not present");
    800016b6:	00007517          	auipc	a0,0x7
    800016ba:	b3250513          	addi	a0,a0,-1230 # 800081e8 <digits+0x198>
    800016be:	fffff097          	auipc	ra,0xfffff
    800016c2:	e6a080e7          	jalr	-406(ra) # 80000528 <panic>
      kfree(mem);
    800016c6:	854a                	mv	a0,s2
    800016c8:	fffff097          	auipc	ra,0xfffff
    800016cc:	32c080e7          	jalr	812(ra) # 800009f4 <kfree>
    }
  }
  return 0;

 err:
  uvmunmap(new, 0, i / PGSIZE, 1);
    800016d0:	4685                	li	a3,1
    800016d2:	00c9d613          	srli	a2,s3,0xc
    800016d6:	4581                	li	a1,0
    800016d8:	8556                	mv	a0,s5
    800016da:	00000097          	auipc	ra,0x0
    800016de:	c52080e7          	jalr	-942(ra) # 8000132c <uvmunmap>
  return -1;
    800016e2:	557d                	li	a0,-1
}
    800016e4:	60a6                	ld	ra,72(sp)
    800016e6:	6406                	ld	s0,64(sp)
    800016e8:	74e2                	ld	s1,56(sp)
    800016ea:	7942                	ld	s2,48(sp)
    800016ec:	79a2                	ld	s3,40(sp)
    800016ee:	7a02                	ld	s4,32(sp)
    800016f0:	6ae2                	ld	s5,24(sp)
    800016f2:	6b42                	ld	s6,16(sp)
    800016f4:	6ba2                	ld	s7,8(sp)
    800016f6:	6161                	addi	sp,sp,80
    800016f8:	8082                	ret
  return 0;
    800016fa:	4501                	li	a0,0
}
    800016fc:	8082                	ret

00000000800016fe <uvmclear>:

// mark a PTE invalid for user access.
// used by exec for the user stack guard page.
void
uvmclear(pagetable_t pagetable, uint64 va)
{
    800016fe:	1141                	addi	sp,sp,-16
    80001700:	e406                	sd	ra,8(sp)
    80001702:	e022                	sd	s0,0(sp)
    80001704:	0800                	addi	s0,sp,16
  pte_t *pte;
  
  pte = walk(pagetable, va, 0);
    80001706:	4601                	li	a2,0
    80001708:	00000097          	auipc	ra,0x0
    8000170c:	976080e7          	jalr	-1674(ra) # 8000107e <walk>
  if(pte == 0)
    80001710:	c901                	beqz	a0,80001720 <uvmclear+0x22>
    panic("uvmclear");
  *pte &= ~PTE_U;
    80001712:	611c                	ld	a5,0(a0)
    80001714:	9bbd                	andi	a5,a5,-17
    80001716:	e11c                	sd	a5,0(a0)
}
    80001718:	60a2                	ld	ra,8(sp)
    8000171a:	6402                	ld	s0,0(sp)
    8000171c:	0141                	addi	sp,sp,16
    8000171e:	8082                	ret
    panic("uvmclear");
    80001720:	00007517          	auipc	a0,0x7
    80001724:	ae850513          	addi	a0,a0,-1304 # 80008208 <digits+0x1b8>
    80001728:	fffff097          	auipc	ra,0xfffff
    8000172c:	e00080e7          	jalr	-512(ra) # 80000528 <panic>

0000000080001730 <copyout>:
int
copyout(pagetable_t pagetable, uint64 dstva, char *src, uint64 len)
{
  uint64 n, va0, pa0;

  while(len > 0){
    80001730:	c6bd                	beqz	a3,8000179e <copyout+0x6e>
{
    80001732:	715d                	addi	sp,sp,-80
    80001734:	e486                	sd	ra,72(sp)
    80001736:	e0a2                	sd	s0,64(sp)
    80001738:	fc26                	sd	s1,56(sp)
    8000173a:	f84a                	sd	s2,48(sp)
    8000173c:	f44e                	sd	s3,40(sp)
    8000173e:	f052                	sd	s4,32(sp)
    80001740:	ec56                	sd	s5,24(sp)
    80001742:	e85a                	sd	s6,16(sp)
    80001744:	e45e                	sd	s7,8(sp)
    80001746:	e062                	sd	s8,0(sp)
    80001748:	0880                	addi	s0,sp,80
    8000174a:	8b2a                	mv	s6,a0
    8000174c:	8c2e                	mv	s8,a1
    8000174e:	8a32                	mv	s4,a2
    80001750:	89b6                	mv	s3,a3
    va0 = PGROUNDDOWN(dstva);
    80001752:	7bfd                	lui	s7,0xfffff
    pa0 = walkaddr(pagetable, va0);
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (dstva - va0);
    80001754:	6a85                	lui	s5,0x1
    80001756:	a015                	j	8000177a <copyout+0x4a>
    if(n > len)
      n = len;
    memmove((void *)(pa0 + (dstva - va0)), src, n);
    80001758:	9562                	add	a0,a0,s8
    8000175a:	0004861b          	sext.w	a2,s1
    8000175e:	85d2                	mv	a1,s4
    80001760:	41250533          	sub	a0,a0,s2
    80001764:	fffff097          	auipc	ra,0xfffff
    80001768:	68e080e7          	jalr	1678(ra) # 80000df2 <memmove>

    len -= n;
    8000176c:	409989b3          	sub	s3,s3,s1
    src += n;
    80001770:	9a26                	add	s4,s4,s1
    dstva = va0 + PGSIZE;
    80001772:	01590c33          	add	s8,s2,s5
  while(len > 0){
    80001776:	02098263          	beqz	s3,8000179a <copyout+0x6a>
    va0 = PGROUNDDOWN(dstva);
    8000177a:	017c7933          	and	s2,s8,s7
    pa0 = walkaddr(pagetable, va0);
    8000177e:	85ca                	mv	a1,s2
    80001780:	855a                	mv	a0,s6
    80001782:	00000097          	auipc	ra,0x0
    80001786:	9a2080e7          	jalr	-1630(ra) # 80001124 <walkaddr>
    if(pa0 == 0)
    8000178a:	cd01                	beqz	a0,800017a2 <copyout+0x72>
    n = PGSIZE - (dstva - va0);
    8000178c:	418904b3          	sub	s1,s2,s8
    80001790:	94d6                	add	s1,s1,s5
    if(n > len)
    80001792:	fc99f3e3          	bgeu	s3,s1,80001758 <copyout+0x28>
    80001796:	84ce                	mv	s1,s3
    80001798:	b7c1                	j	80001758 <copyout+0x28>
  }
  return 0;
    8000179a:	4501                	li	a0,0
    8000179c:	a021                	j	800017a4 <copyout+0x74>
    8000179e:	4501                	li	a0,0
}
    800017a0:	8082                	ret
      return -1;
    800017a2:	557d                	li	a0,-1
}
    800017a4:	60a6                	ld	ra,72(sp)
    800017a6:	6406                	ld	s0,64(sp)
    800017a8:	74e2                	ld	s1,56(sp)
    800017aa:	7942                	ld	s2,48(sp)
    800017ac:	79a2                	ld	s3,40(sp)
    800017ae:	7a02                	ld	s4,32(sp)
    800017b0:	6ae2                	ld	s5,24(sp)
    800017b2:	6b42                	ld	s6,16(sp)
    800017b4:	6ba2                	ld	s7,8(sp)
    800017b6:	6c02                	ld	s8,0(sp)
    800017b8:	6161                	addi	sp,sp,80
    800017ba:	8082                	ret

00000000800017bc <copyin>:
int
copyin(pagetable_t pagetable, char *dst, uint64 srcva, uint64 len)
{
  uint64 n, va0, pa0;

  while(len > 0){
    800017bc:	c6bd                	beqz	a3,8000182a <copyin+0x6e>
{
    800017be:	715d                	addi	sp,sp,-80
    800017c0:	e486                	sd	ra,72(sp)
    800017c2:	e0a2                	sd	s0,64(sp)
    800017c4:	fc26                	sd	s1,56(sp)
    800017c6:	f84a                	sd	s2,48(sp)
    800017c8:	f44e                	sd	s3,40(sp)
    800017ca:	f052                	sd	s4,32(sp)
    800017cc:	ec56                	sd	s5,24(sp)
    800017ce:	e85a                	sd	s6,16(sp)
    800017d0:	e45e                	sd	s7,8(sp)
    800017d2:	e062                	sd	s8,0(sp)
    800017d4:	0880                	addi	s0,sp,80
    800017d6:	8b2a                	mv	s6,a0
    800017d8:	8a2e                	mv	s4,a1
    800017da:	8c32                	mv	s8,a2
    800017dc:	89b6                	mv	s3,a3
    va0 = PGROUNDDOWN(srcva);
    800017de:	7bfd                	lui	s7,0xfffff
    pa0 = walkaddr(pagetable, va0);
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (srcva - va0);
    800017e0:	6a85                	lui	s5,0x1
    800017e2:	a015                	j	80001806 <copyin+0x4a>
    if(n > len)
      n = len;
    memmove(dst, (void *)(pa0 + (srcva - va0)), n);
    800017e4:	9562                	add	a0,a0,s8
    800017e6:	0004861b          	sext.w	a2,s1
    800017ea:	412505b3          	sub	a1,a0,s2
    800017ee:	8552                	mv	a0,s4
    800017f0:	fffff097          	auipc	ra,0xfffff
    800017f4:	602080e7          	jalr	1538(ra) # 80000df2 <memmove>

    len -= n;
    800017f8:	409989b3          	sub	s3,s3,s1
    dst += n;
    800017fc:	9a26                	add	s4,s4,s1
    srcva = va0 + PGSIZE;
    800017fe:	01590c33          	add	s8,s2,s5
  while(len > 0){
    80001802:	02098263          	beqz	s3,80001826 <copyin+0x6a>
    va0 = PGROUNDDOWN(srcva);
    80001806:	017c7933          	and	s2,s8,s7
    pa0 = walkaddr(pagetable, va0);
    8000180a:	85ca                	mv	a1,s2
    8000180c:	855a                	mv	a0,s6
    8000180e:	00000097          	auipc	ra,0x0
    80001812:	916080e7          	jalr	-1770(ra) # 80001124 <walkaddr>
    if(pa0 == 0)
    80001816:	cd01                	beqz	a0,8000182e <copyin+0x72>
    n = PGSIZE - (srcva - va0);
    80001818:	418904b3          	sub	s1,s2,s8
    8000181c:	94d6                	add	s1,s1,s5
    if(n > len)
    8000181e:	fc99f3e3          	bgeu	s3,s1,800017e4 <copyin+0x28>
    80001822:	84ce                	mv	s1,s3
    80001824:	b7c1                	j	800017e4 <copyin+0x28>
  }
  return 0;
    80001826:	4501                	li	a0,0
    80001828:	a021                	j	80001830 <copyin+0x74>
    8000182a:	4501                	li	a0,0
}
    8000182c:	8082                	ret
      return -1;
    8000182e:	557d                	li	a0,-1
}
    80001830:	60a6                	ld	ra,72(sp)
    80001832:	6406                	ld	s0,64(sp)
    80001834:	74e2                	ld	s1,56(sp)
    80001836:	7942                	ld	s2,48(sp)
    80001838:	79a2                	ld	s3,40(sp)
    8000183a:	7a02                	ld	s4,32(sp)
    8000183c:	6ae2                	ld	s5,24(sp)
    8000183e:	6b42                	ld	s6,16(sp)
    80001840:	6ba2                	ld	s7,8(sp)
    80001842:	6c02                	ld	s8,0(sp)
    80001844:	6161                	addi	sp,sp,80
    80001846:	8082                	ret

0000000080001848 <copyinstr>:
copyinstr(pagetable_t pagetable, char *dst, uint64 srcva, uint64 max)
{
  uint64 n, va0, pa0;
  int got_null = 0;

  while(got_null == 0 && max > 0){
    80001848:	c6c5                	beqz	a3,800018f0 <copyinstr+0xa8>
{
    8000184a:	715d                	addi	sp,sp,-80
    8000184c:	e486                	sd	ra,72(sp)
    8000184e:	e0a2                	sd	s0,64(sp)
    80001850:	fc26                	sd	s1,56(sp)
    80001852:	f84a                	sd	s2,48(sp)
    80001854:	f44e                	sd	s3,40(sp)
    80001856:	f052                	sd	s4,32(sp)
    80001858:	ec56                	sd	s5,24(sp)
    8000185a:	e85a                	sd	s6,16(sp)
    8000185c:	e45e                	sd	s7,8(sp)
    8000185e:	0880                	addi	s0,sp,80
    80001860:	8a2a                	mv	s4,a0
    80001862:	8b2e                	mv	s6,a1
    80001864:	8bb2                	mv	s7,a2
    80001866:	84b6                	mv	s1,a3
    va0 = PGROUNDDOWN(srcva);
    80001868:	7afd                	lui	s5,0xfffff
    pa0 = walkaddr(pagetable, va0);
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (srcva - va0);
    8000186a:	6985                	lui	s3,0x1
    8000186c:	a035                	j	80001898 <copyinstr+0x50>
      n = max;

    char *p = (char *) (pa0 + (srcva - va0));
    while(n > 0){
      if(*p == '\0'){
        *dst = '\0';
    8000186e:	00078023          	sb	zero,0(a5) # 1000 <_entry-0x7ffff000>
    80001872:	4785                	li	a5,1
      dst++;
    }

    srcva = va0 + PGSIZE;
  }
  if(got_null){
    80001874:	0017b793          	seqz	a5,a5
    80001878:	40f00533          	neg	a0,a5
    return 0;
  } else {
    return -1;
  }
}
    8000187c:	60a6                	ld	ra,72(sp)
    8000187e:	6406                	ld	s0,64(sp)
    80001880:	74e2                	ld	s1,56(sp)
    80001882:	7942                	ld	s2,48(sp)
    80001884:	79a2                	ld	s3,40(sp)
    80001886:	7a02                	ld	s4,32(sp)
    80001888:	6ae2                	ld	s5,24(sp)
    8000188a:	6b42                	ld	s6,16(sp)
    8000188c:	6ba2                	ld	s7,8(sp)
    8000188e:	6161                	addi	sp,sp,80
    80001890:	8082                	ret
    srcva = va0 + PGSIZE;
    80001892:	01390bb3          	add	s7,s2,s3
  while(got_null == 0 && max > 0){
    80001896:	c8a9                	beqz	s1,800018e8 <copyinstr+0xa0>
    va0 = PGROUNDDOWN(srcva);
    80001898:	015bf933          	and	s2,s7,s5
    pa0 = walkaddr(pagetable, va0);
    8000189c:	85ca                	mv	a1,s2
    8000189e:	8552                	mv	a0,s4
    800018a0:	00000097          	auipc	ra,0x0
    800018a4:	884080e7          	jalr	-1916(ra) # 80001124 <walkaddr>
    if(pa0 == 0)
    800018a8:	c131                	beqz	a0,800018ec <copyinstr+0xa4>
    n = PGSIZE - (srcva - va0);
    800018aa:	41790833          	sub	a6,s2,s7
    800018ae:	984e                	add	a6,a6,s3
    if(n > max)
    800018b0:	0104f363          	bgeu	s1,a6,800018b6 <copyinstr+0x6e>
    800018b4:	8826                	mv	a6,s1
    char *p = (char *) (pa0 + (srcva - va0));
    800018b6:	955e                	add	a0,a0,s7
    800018b8:	41250533          	sub	a0,a0,s2
    while(n > 0){
    800018bc:	fc080be3          	beqz	a6,80001892 <copyinstr+0x4a>
    800018c0:	985a                	add	a6,a6,s6
    800018c2:	87da                	mv	a5,s6
      if(*p == '\0'){
    800018c4:	41650633          	sub	a2,a0,s6
    800018c8:	14fd                	addi	s1,s1,-1
    800018ca:	9b26                	add	s6,s6,s1
    800018cc:	00f60733          	add	a4,a2,a5
    800018d0:	00074703          	lbu	a4,0(a4)
    800018d4:	df49                	beqz	a4,8000186e <copyinstr+0x26>
        *dst = *p;
    800018d6:	00e78023          	sb	a4,0(a5)
      --max;
    800018da:	40fb04b3          	sub	s1,s6,a5
      dst++;
    800018de:	0785                	addi	a5,a5,1
    while(n > 0){
    800018e0:	ff0796e3          	bne	a5,a6,800018cc <copyinstr+0x84>
      dst++;
    800018e4:	8b42                	mv	s6,a6
    800018e6:	b775                	j	80001892 <copyinstr+0x4a>
    800018e8:	4781                	li	a5,0
    800018ea:	b769                	j	80001874 <copyinstr+0x2c>
      return -1;
    800018ec:	557d                	li	a0,-1
    800018ee:	b779                	j	8000187c <copyinstr+0x34>
  int got_null = 0;
    800018f0:	4781                	li	a5,0
  if(got_null){
    800018f2:	0017b793          	seqz	a5,a5
    800018f6:	40f00533          	neg	a0,a5
}
    800018fa:	8082                	ret

00000000800018fc <rr_scheduler>:
        (*sched_pointer)();
    }
}

void rr_scheduler(void)
{
    800018fc:	715d                	addi	sp,sp,-80
    800018fe:	e486                	sd	ra,72(sp)
    80001900:	e0a2                	sd	s0,64(sp)
    80001902:	fc26                	sd	s1,56(sp)
    80001904:	f84a                	sd	s2,48(sp)
    80001906:	f44e                	sd	s3,40(sp)
    80001908:	f052                	sd	s4,32(sp)
    8000190a:	ec56                	sd	s5,24(sp)
    8000190c:	e85a                	sd	s6,16(sp)
    8000190e:	e45e                	sd	s7,8(sp)
    80001910:	e062                	sd	s8,0(sp)
    80001912:	0880                	addi	s0,sp,80
  asm volatile("mv %0, tp" : "=r" (x) );
    80001914:	8912                	mv	s2,tp
    int id = r_tp();
    80001916:	2901                	sext.w	s2,s2
    struct proc *p;
    struct cpu *c = mycpu();

    c->proc = 0;
    80001918:	0000fa97          	auipc	s5,0xf
    8000191c:	3c8a8a93          	addi	s5,s5,968 # 80010ce0 <cpus>
    80001920:	00791793          	slli	a5,s2,0x7
    80001924:	00fa8733          	add	a4,s5,a5
    80001928:	00073023          	sd	zero,0(a4)
                // Switch to chosen process.  It is the process's job
                // to release its lock and then reacquire it
                // before jumping back to us.
                p->state = RUNNING;
                c->proc = p;
                swtch(&c->context, &p->context);
    8000192c:	07a1                	addi	a5,a5,8
    8000192e:	9abe                	add	s5,s5,a5
                c->proc = p;
    80001930:	893a                	mv	s2,a4
                // check if we are still the right scheduler (or if schedset changed)
                if (sched_pointer != &rr_scheduler)
    80001932:	00007c17          	auipc	s8,0x7
    80001936:	066c0c13          	addi	s8,s8,102 # 80008998 <sched_pointer>
    8000193a:	00000b97          	auipc	s7,0x0
    8000193e:	fc2b8b93          	addi	s7,s7,-62 # 800018fc <rr_scheduler>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80001942:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80001946:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    8000194a:	10079073          	csrw	sstatus,a5
        for (p = proc; p < &proc[NPROC]; p++)
    8000194e:	0000f497          	auipc	s1,0xf
    80001952:	7c248493          	addi	s1,s1,1986 # 80011110 <proc>
            if (p->state == RUNNABLE)
    80001956:	498d                	li	s3,3
                p->state = RUNNING;
    80001958:	4b11                	li	s6,4
        for (p = proc; p < &proc[NPROC]; p++)
    8000195a:	00015a17          	auipc	s4,0x15
    8000195e:	1b6a0a13          	addi	s4,s4,438 # 80016b10 <tickslock>
    80001962:	a81d                	j	80001998 <rr_scheduler+0x9c>
                {
                    release(&p->lock);
    80001964:	8526                	mv	a0,s1
    80001966:	fffff097          	auipc	ra,0xfffff
    8000196a:	3e4080e7          	jalr	996(ra) # 80000d4a <release>
                c->proc = 0;
            }
            release(&p->lock);
        }
    }
}
    8000196e:	60a6                	ld	ra,72(sp)
    80001970:	6406                	ld	s0,64(sp)
    80001972:	74e2                	ld	s1,56(sp)
    80001974:	7942                	ld	s2,48(sp)
    80001976:	79a2                	ld	s3,40(sp)
    80001978:	7a02                	ld	s4,32(sp)
    8000197a:	6ae2                	ld	s5,24(sp)
    8000197c:	6b42                	ld	s6,16(sp)
    8000197e:	6ba2                	ld	s7,8(sp)
    80001980:	6c02                	ld	s8,0(sp)
    80001982:	6161                	addi	sp,sp,80
    80001984:	8082                	ret
            release(&p->lock);
    80001986:	8526                	mv	a0,s1
    80001988:	fffff097          	auipc	ra,0xfffff
    8000198c:	3c2080e7          	jalr	962(ra) # 80000d4a <release>
        for (p = proc; p < &proc[NPROC]; p++)
    80001990:	16848493          	addi	s1,s1,360
    80001994:	fb4487e3          	beq	s1,s4,80001942 <rr_scheduler+0x46>
            acquire(&p->lock);
    80001998:	8526                	mv	a0,s1
    8000199a:	fffff097          	auipc	ra,0xfffff
    8000199e:	2fc080e7          	jalr	764(ra) # 80000c96 <acquire>
            if (p->state == RUNNABLE)
    800019a2:	4c9c                	lw	a5,24(s1)
    800019a4:	ff3791e3          	bne	a5,s3,80001986 <rr_scheduler+0x8a>
                p->state = RUNNING;
    800019a8:	0164ac23          	sw	s6,24(s1)
                c->proc = p;
    800019ac:	00993023          	sd	s1,0(s2) # 1000 <_entry-0x7ffff000>
                swtch(&c->context, &p->context);
    800019b0:	06048593          	addi	a1,s1,96
    800019b4:	8556                	mv	a0,s5
    800019b6:	00001097          	auipc	ra,0x1
    800019ba:	02c080e7          	jalr	44(ra) # 800029e2 <swtch>
                if (sched_pointer != &rr_scheduler)
    800019be:	000c3783          	ld	a5,0(s8)
    800019c2:	fb7791e3          	bne	a5,s7,80001964 <rr_scheduler+0x68>
                c->proc = 0;
    800019c6:	00093023          	sd	zero,0(s2)
    800019ca:	bf75                	j	80001986 <rr_scheduler+0x8a>

00000000800019cc <proc_mapstacks>:
{
    800019cc:	7139                	addi	sp,sp,-64
    800019ce:	fc06                	sd	ra,56(sp)
    800019d0:	f822                	sd	s0,48(sp)
    800019d2:	f426                	sd	s1,40(sp)
    800019d4:	f04a                	sd	s2,32(sp)
    800019d6:	ec4e                	sd	s3,24(sp)
    800019d8:	e852                	sd	s4,16(sp)
    800019da:	e456                	sd	s5,8(sp)
    800019dc:	e05a                	sd	s6,0(sp)
    800019de:	0080                	addi	s0,sp,64
    800019e0:	89aa                	mv	s3,a0
    for (p = proc; p < &proc[NPROC]; p++)
    800019e2:	0000f497          	auipc	s1,0xf
    800019e6:	72e48493          	addi	s1,s1,1838 # 80011110 <proc>
        uint64 va = KSTACK((int)(p - proc));
    800019ea:	8b26                	mv	s6,s1
    800019ec:	00006a97          	auipc	s5,0x6
    800019f0:	624a8a93          	addi	s5,s5,1572 # 80008010 <__func__.1508+0x8>
    800019f4:	04000937          	lui	s2,0x4000
    800019f8:	197d                	addi	s2,s2,-1
    800019fa:	0932                	slli	s2,s2,0xc
    for (p = proc; p < &proc[NPROC]; p++)
    800019fc:	00015a17          	auipc	s4,0x15
    80001a00:	114a0a13          	addi	s4,s4,276 # 80016b10 <tickslock>
        char *pa = kalloc();
    80001a04:	fffff097          	auipc	ra,0xfffff
    80001a08:	156080e7          	jalr	342(ra) # 80000b5a <kalloc>
    80001a0c:	862a                	mv	a2,a0
        if (pa == 0)
    80001a0e:	c131                	beqz	a0,80001a52 <proc_mapstacks+0x86>
        uint64 va = KSTACK((int)(p - proc));
    80001a10:	416485b3          	sub	a1,s1,s6
    80001a14:	858d                	srai	a1,a1,0x3
    80001a16:	000ab783          	ld	a5,0(s5)
    80001a1a:	02f585b3          	mul	a1,a1,a5
    80001a1e:	2585                	addiw	a1,a1,1
    80001a20:	00d5959b          	slliw	a1,a1,0xd
        kvmmap(kpgtbl, va, (uint64)pa, PGSIZE, PTE_R | PTE_W);
    80001a24:	4719                	li	a4,6
    80001a26:	6685                	lui	a3,0x1
    80001a28:	40b905b3          	sub	a1,s2,a1
    80001a2c:	854e                	mv	a0,s3
    80001a2e:	fffff097          	auipc	ra,0xfffff
    80001a32:	7d8080e7          	jalr	2008(ra) # 80001206 <kvmmap>
    for (p = proc; p < &proc[NPROC]; p++)
    80001a36:	16848493          	addi	s1,s1,360
    80001a3a:	fd4495e3          	bne	s1,s4,80001a04 <proc_mapstacks+0x38>
}
    80001a3e:	70e2                	ld	ra,56(sp)
    80001a40:	7442                	ld	s0,48(sp)
    80001a42:	74a2                	ld	s1,40(sp)
    80001a44:	7902                	ld	s2,32(sp)
    80001a46:	69e2                	ld	s3,24(sp)
    80001a48:	6a42                	ld	s4,16(sp)
    80001a4a:	6aa2                	ld	s5,8(sp)
    80001a4c:	6b02                	ld	s6,0(sp)
    80001a4e:	6121                	addi	sp,sp,64
    80001a50:	8082                	ret
            panic("kalloc");
    80001a52:	00006517          	auipc	a0,0x6
    80001a56:	7c650513          	addi	a0,a0,1990 # 80008218 <digits+0x1c8>
    80001a5a:	fffff097          	auipc	ra,0xfffff
    80001a5e:	ace080e7          	jalr	-1330(ra) # 80000528 <panic>

0000000080001a62 <procinit>:
{
    80001a62:	7139                	addi	sp,sp,-64
    80001a64:	fc06                	sd	ra,56(sp)
    80001a66:	f822                	sd	s0,48(sp)
    80001a68:	f426                	sd	s1,40(sp)
    80001a6a:	f04a                	sd	s2,32(sp)
    80001a6c:	ec4e                	sd	s3,24(sp)
    80001a6e:	e852                	sd	s4,16(sp)
    80001a70:	e456                	sd	s5,8(sp)
    80001a72:	e05a                	sd	s6,0(sp)
    80001a74:	0080                	addi	s0,sp,64
    initlock(&pid_lock, "nextpid");
    80001a76:	00006597          	auipc	a1,0x6
    80001a7a:	7aa58593          	addi	a1,a1,1962 # 80008220 <digits+0x1d0>
    80001a7e:	0000f517          	auipc	a0,0xf
    80001a82:	66250513          	addi	a0,a0,1634 # 800110e0 <pid_lock>
    80001a86:	fffff097          	auipc	ra,0xfffff
    80001a8a:	180080e7          	jalr	384(ra) # 80000c06 <initlock>
    initlock(&wait_lock, "wait_lock");
    80001a8e:	00006597          	auipc	a1,0x6
    80001a92:	79a58593          	addi	a1,a1,1946 # 80008228 <digits+0x1d8>
    80001a96:	0000f517          	auipc	a0,0xf
    80001a9a:	66250513          	addi	a0,a0,1634 # 800110f8 <wait_lock>
    80001a9e:	fffff097          	auipc	ra,0xfffff
    80001aa2:	168080e7          	jalr	360(ra) # 80000c06 <initlock>
    for (p = proc; p < &proc[NPROC]; p++)
    80001aa6:	0000f497          	auipc	s1,0xf
    80001aaa:	66a48493          	addi	s1,s1,1642 # 80011110 <proc>
        initlock(&p->lock, "proc");
    80001aae:	00006b17          	auipc	s6,0x6
    80001ab2:	78ab0b13          	addi	s6,s6,1930 # 80008238 <digits+0x1e8>
        p->kstack = KSTACK((int)(p - proc));
    80001ab6:	8aa6                	mv	s5,s1
    80001ab8:	00006a17          	auipc	s4,0x6
    80001abc:	558a0a13          	addi	s4,s4,1368 # 80008010 <__func__.1508+0x8>
    80001ac0:	04000937          	lui	s2,0x4000
    80001ac4:	197d                	addi	s2,s2,-1
    80001ac6:	0932                	slli	s2,s2,0xc
    for (p = proc; p < &proc[NPROC]; p++)
    80001ac8:	00015997          	auipc	s3,0x15
    80001acc:	04898993          	addi	s3,s3,72 # 80016b10 <tickslock>
        initlock(&p->lock, "proc");
    80001ad0:	85da                	mv	a1,s6
    80001ad2:	8526                	mv	a0,s1
    80001ad4:	fffff097          	auipc	ra,0xfffff
    80001ad8:	132080e7          	jalr	306(ra) # 80000c06 <initlock>
        p->state = UNUSED;
    80001adc:	0004ac23          	sw	zero,24(s1)
        p->kstack = KSTACK((int)(p - proc));
    80001ae0:	415487b3          	sub	a5,s1,s5
    80001ae4:	878d                	srai	a5,a5,0x3
    80001ae6:	000a3703          	ld	a4,0(s4)
    80001aea:	02e787b3          	mul	a5,a5,a4
    80001aee:	2785                	addiw	a5,a5,1
    80001af0:	00d7979b          	slliw	a5,a5,0xd
    80001af4:	40f907b3          	sub	a5,s2,a5
    80001af8:	e0bc                	sd	a5,64(s1)
    for (p = proc; p < &proc[NPROC]; p++)
    80001afa:	16848493          	addi	s1,s1,360
    80001afe:	fd3499e3          	bne	s1,s3,80001ad0 <procinit+0x6e>
}
    80001b02:	70e2                	ld	ra,56(sp)
    80001b04:	7442                	ld	s0,48(sp)
    80001b06:	74a2                	ld	s1,40(sp)
    80001b08:	7902                	ld	s2,32(sp)
    80001b0a:	69e2                	ld	s3,24(sp)
    80001b0c:	6a42                	ld	s4,16(sp)
    80001b0e:	6aa2                	ld	s5,8(sp)
    80001b10:	6b02                	ld	s6,0(sp)
    80001b12:	6121                	addi	sp,sp,64
    80001b14:	8082                	ret

0000000080001b16 <copy_array>:
{
    80001b16:	1141                	addi	sp,sp,-16
    80001b18:	e422                	sd	s0,8(sp)
    80001b1a:	0800                	addi	s0,sp,16
    for (int i = 0; i < len; i++)
    80001b1c:	02c05163          	blez	a2,80001b3e <copy_array+0x28>
    80001b20:	87aa                	mv	a5,a0
    80001b22:	0505                	addi	a0,a0,1
    80001b24:	fff6069b          	addiw	a3,a2,-1
    80001b28:	1682                	slli	a3,a3,0x20
    80001b2a:	9281                	srli	a3,a3,0x20
    80001b2c:	96aa                	add	a3,a3,a0
        dst[i] = src[i];
    80001b2e:	0007c703          	lbu	a4,0(a5)
    80001b32:	00e58023          	sb	a4,0(a1)
    for (int i = 0; i < len; i++)
    80001b36:	0785                	addi	a5,a5,1
    80001b38:	0585                	addi	a1,a1,1
    80001b3a:	fed79ae3          	bne	a5,a3,80001b2e <copy_array+0x18>
}
    80001b3e:	6422                	ld	s0,8(sp)
    80001b40:	0141                	addi	sp,sp,16
    80001b42:	8082                	ret

0000000080001b44 <cpuid>:
{
    80001b44:	1141                	addi	sp,sp,-16
    80001b46:	e422                	sd	s0,8(sp)
    80001b48:	0800                	addi	s0,sp,16
  asm volatile("mv %0, tp" : "=r" (x) );
    80001b4a:	8512                	mv	a0,tp
}
    80001b4c:	2501                	sext.w	a0,a0
    80001b4e:	6422                	ld	s0,8(sp)
    80001b50:	0141                	addi	sp,sp,16
    80001b52:	8082                	ret

0000000080001b54 <mycpu>:
{
    80001b54:	1141                	addi	sp,sp,-16
    80001b56:	e422                	sd	s0,8(sp)
    80001b58:	0800                	addi	s0,sp,16
    80001b5a:	8792                	mv	a5,tp
    struct cpu *c = &cpus[id];
    80001b5c:	2781                	sext.w	a5,a5
    80001b5e:	079e                	slli	a5,a5,0x7
}
    80001b60:	0000f517          	auipc	a0,0xf
    80001b64:	18050513          	addi	a0,a0,384 # 80010ce0 <cpus>
    80001b68:	953e                	add	a0,a0,a5
    80001b6a:	6422                	ld	s0,8(sp)
    80001b6c:	0141                	addi	sp,sp,16
    80001b6e:	8082                	ret

0000000080001b70 <myproc>:
{
    80001b70:	1101                	addi	sp,sp,-32
    80001b72:	ec06                	sd	ra,24(sp)
    80001b74:	e822                	sd	s0,16(sp)
    80001b76:	e426                	sd	s1,8(sp)
    80001b78:	1000                	addi	s0,sp,32
    push_off();
    80001b7a:	fffff097          	auipc	ra,0xfffff
    80001b7e:	0d0080e7          	jalr	208(ra) # 80000c4a <push_off>
    80001b82:	8792                	mv	a5,tp
    struct proc *p = c->proc;
    80001b84:	2781                	sext.w	a5,a5
    80001b86:	079e                	slli	a5,a5,0x7
    80001b88:	0000f717          	auipc	a4,0xf
    80001b8c:	15870713          	addi	a4,a4,344 # 80010ce0 <cpus>
    80001b90:	97ba                	add	a5,a5,a4
    80001b92:	6384                	ld	s1,0(a5)
    pop_off();
    80001b94:	fffff097          	auipc	ra,0xfffff
    80001b98:	156080e7          	jalr	342(ra) # 80000cea <pop_off>
}
    80001b9c:	8526                	mv	a0,s1
    80001b9e:	60e2                	ld	ra,24(sp)
    80001ba0:	6442                	ld	s0,16(sp)
    80001ba2:	64a2                	ld	s1,8(sp)
    80001ba4:	6105                	addi	sp,sp,32
    80001ba6:	8082                	ret

0000000080001ba8 <forkret>:
}

// A fork child's very first scheduling by scheduler()
// will swtch to forkret.
void forkret(void)
{
    80001ba8:	1141                	addi	sp,sp,-16
    80001baa:	e406                	sd	ra,8(sp)
    80001bac:	e022                	sd	s0,0(sp)
    80001bae:	0800                	addi	s0,sp,16
    static int first = 1;

    // Still holding p->lock from scheduler.
    release(&myproc()->lock);
    80001bb0:	00000097          	auipc	ra,0x0
    80001bb4:	fc0080e7          	jalr	-64(ra) # 80001b70 <myproc>
    80001bb8:	fffff097          	auipc	ra,0xfffff
    80001bbc:	192080e7          	jalr	402(ra) # 80000d4a <release>

    if (first)
    80001bc0:	00007797          	auipc	a5,0x7
    80001bc4:	dd07a783          	lw	a5,-560(a5) # 80008990 <first.1730>
    80001bc8:	eb89                	bnez	a5,80001bda <forkret+0x32>
        // be run from main().
        first = 0;
        fsinit(ROOTDEV);
    }

    usertrapret();
    80001bca:	00001097          	auipc	ra,0x1
    80001bce:	ec2080e7          	jalr	-318(ra) # 80002a8c <usertrapret>
}
    80001bd2:	60a2                	ld	ra,8(sp)
    80001bd4:	6402                	ld	s0,0(sp)
    80001bd6:	0141                	addi	sp,sp,16
    80001bd8:	8082                	ret
        first = 0;
    80001bda:	00007797          	auipc	a5,0x7
    80001bde:	da07ab23          	sw	zero,-586(a5) # 80008990 <first.1730>
        fsinit(ROOTDEV);
    80001be2:	4505                	li	a0,1
    80001be4:	00002097          	auipc	ra,0x2
    80001be8:	ccc080e7          	jalr	-820(ra) # 800038b0 <fsinit>
    80001bec:	bff9                	j	80001bca <forkret+0x22>

0000000080001bee <allocpid>:
{
    80001bee:	1101                	addi	sp,sp,-32
    80001bf0:	ec06                	sd	ra,24(sp)
    80001bf2:	e822                	sd	s0,16(sp)
    80001bf4:	e426                	sd	s1,8(sp)
    80001bf6:	e04a                	sd	s2,0(sp)
    80001bf8:	1000                	addi	s0,sp,32
    acquire(&pid_lock);
    80001bfa:	0000f917          	auipc	s2,0xf
    80001bfe:	4e690913          	addi	s2,s2,1254 # 800110e0 <pid_lock>
    80001c02:	854a                	mv	a0,s2
    80001c04:	fffff097          	auipc	ra,0xfffff
    80001c08:	092080e7          	jalr	146(ra) # 80000c96 <acquire>
    pid = nextpid;
    80001c0c:	00007797          	auipc	a5,0x7
    80001c10:	d9478793          	addi	a5,a5,-620 # 800089a0 <nextpid>
    80001c14:	4384                	lw	s1,0(a5)
    nextpid = nextpid + 1;
    80001c16:	0014871b          	addiw	a4,s1,1
    80001c1a:	c398                	sw	a4,0(a5)
    release(&pid_lock);
    80001c1c:	854a                	mv	a0,s2
    80001c1e:	fffff097          	auipc	ra,0xfffff
    80001c22:	12c080e7          	jalr	300(ra) # 80000d4a <release>
}
    80001c26:	8526                	mv	a0,s1
    80001c28:	60e2                	ld	ra,24(sp)
    80001c2a:	6442                	ld	s0,16(sp)
    80001c2c:	64a2                	ld	s1,8(sp)
    80001c2e:	6902                	ld	s2,0(sp)
    80001c30:	6105                	addi	sp,sp,32
    80001c32:	8082                	ret

0000000080001c34 <proc_pagetable>:
{
    80001c34:	1101                	addi	sp,sp,-32
    80001c36:	ec06                	sd	ra,24(sp)
    80001c38:	e822                	sd	s0,16(sp)
    80001c3a:	e426                	sd	s1,8(sp)
    80001c3c:	e04a                	sd	s2,0(sp)
    80001c3e:	1000                	addi	s0,sp,32
    80001c40:	892a                	mv	s2,a0
    pagetable = uvmcreate();
    80001c42:	fffff097          	auipc	ra,0xfffff
    80001c46:	7ae080e7          	jalr	1966(ra) # 800013f0 <uvmcreate>
    80001c4a:	84aa                	mv	s1,a0
    if (pagetable == 0)
    80001c4c:	c121                	beqz	a0,80001c8c <proc_pagetable+0x58>
    if (mappages(pagetable, TRAMPOLINE, PGSIZE,
    80001c4e:	4729                	li	a4,10
    80001c50:	00005697          	auipc	a3,0x5
    80001c54:	3b068693          	addi	a3,a3,944 # 80007000 <_trampoline>
    80001c58:	6605                	lui	a2,0x1
    80001c5a:	040005b7          	lui	a1,0x4000
    80001c5e:	15fd                	addi	a1,a1,-1
    80001c60:	05b2                	slli	a1,a1,0xc
    80001c62:	fffff097          	auipc	ra,0xfffff
    80001c66:	504080e7          	jalr	1284(ra) # 80001166 <mappages>
    80001c6a:	02054863          	bltz	a0,80001c9a <proc_pagetable+0x66>
    if (mappages(pagetable, TRAPFRAME, PGSIZE,
    80001c6e:	4719                	li	a4,6
    80001c70:	05893683          	ld	a3,88(s2)
    80001c74:	6605                	lui	a2,0x1
    80001c76:	020005b7          	lui	a1,0x2000
    80001c7a:	15fd                	addi	a1,a1,-1
    80001c7c:	05b6                	slli	a1,a1,0xd
    80001c7e:	8526                	mv	a0,s1
    80001c80:	fffff097          	auipc	ra,0xfffff
    80001c84:	4e6080e7          	jalr	1254(ra) # 80001166 <mappages>
    80001c88:	02054163          	bltz	a0,80001caa <proc_pagetable+0x76>
}
    80001c8c:	8526                	mv	a0,s1
    80001c8e:	60e2                	ld	ra,24(sp)
    80001c90:	6442                	ld	s0,16(sp)
    80001c92:	64a2                	ld	s1,8(sp)
    80001c94:	6902                	ld	s2,0(sp)
    80001c96:	6105                	addi	sp,sp,32
    80001c98:	8082                	ret
        uvmfree(pagetable, 0);
    80001c9a:	4581                	li	a1,0
    80001c9c:	8526                	mv	a0,s1
    80001c9e:	00000097          	auipc	ra,0x0
    80001ca2:	956080e7          	jalr	-1706(ra) # 800015f4 <uvmfree>
        return 0;
    80001ca6:	4481                	li	s1,0
    80001ca8:	b7d5                	j	80001c8c <proc_pagetable+0x58>
        uvmunmap(pagetable, TRAMPOLINE, 1, 0);
    80001caa:	4681                	li	a3,0
    80001cac:	4605                	li	a2,1
    80001cae:	040005b7          	lui	a1,0x4000
    80001cb2:	15fd                	addi	a1,a1,-1
    80001cb4:	05b2                	slli	a1,a1,0xc
    80001cb6:	8526                	mv	a0,s1
    80001cb8:	fffff097          	auipc	ra,0xfffff
    80001cbc:	674080e7          	jalr	1652(ra) # 8000132c <uvmunmap>
        uvmfree(pagetable, 0);
    80001cc0:	4581                	li	a1,0
    80001cc2:	8526                	mv	a0,s1
    80001cc4:	00000097          	auipc	ra,0x0
    80001cc8:	930080e7          	jalr	-1744(ra) # 800015f4 <uvmfree>
        return 0;
    80001ccc:	4481                	li	s1,0
    80001cce:	bf7d                	j	80001c8c <proc_pagetable+0x58>

0000000080001cd0 <proc_freepagetable>:
{
    80001cd0:	1101                	addi	sp,sp,-32
    80001cd2:	ec06                	sd	ra,24(sp)
    80001cd4:	e822                	sd	s0,16(sp)
    80001cd6:	e426                	sd	s1,8(sp)
    80001cd8:	e04a                	sd	s2,0(sp)
    80001cda:	1000                	addi	s0,sp,32
    80001cdc:	84aa                	mv	s1,a0
    80001cde:	892e                	mv	s2,a1
    uvmunmap(pagetable, TRAMPOLINE, 1, 0);
    80001ce0:	4681                	li	a3,0
    80001ce2:	4605                	li	a2,1
    80001ce4:	040005b7          	lui	a1,0x4000
    80001ce8:	15fd                	addi	a1,a1,-1
    80001cea:	05b2                	slli	a1,a1,0xc
    80001cec:	fffff097          	auipc	ra,0xfffff
    80001cf0:	640080e7          	jalr	1600(ra) # 8000132c <uvmunmap>
    uvmunmap(pagetable, TRAPFRAME, 1, 0);
    80001cf4:	4681                	li	a3,0
    80001cf6:	4605                	li	a2,1
    80001cf8:	020005b7          	lui	a1,0x2000
    80001cfc:	15fd                	addi	a1,a1,-1
    80001cfe:	05b6                	slli	a1,a1,0xd
    80001d00:	8526                	mv	a0,s1
    80001d02:	fffff097          	auipc	ra,0xfffff
    80001d06:	62a080e7          	jalr	1578(ra) # 8000132c <uvmunmap>
    uvmfree(pagetable, sz);
    80001d0a:	85ca                	mv	a1,s2
    80001d0c:	8526                	mv	a0,s1
    80001d0e:	00000097          	auipc	ra,0x0
    80001d12:	8e6080e7          	jalr	-1818(ra) # 800015f4 <uvmfree>
}
    80001d16:	60e2                	ld	ra,24(sp)
    80001d18:	6442                	ld	s0,16(sp)
    80001d1a:	64a2                	ld	s1,8(sp)
    80001d1c:	6902                	ld	s2,0(sp)
    80001d1e:	6105                	addi	sp,sp,32
    80001d20:	8082                	ret

0000000080001d22 <freeproc>:
{
    80001d22:	1101                	addi	sp,sp,-32
    80001d24:	ec06                	sd	ra,24(sp)
    80001d26:	e822                	sd	s0,16(sp)
    80001d28:	e426                	sd	s1,8(sp)
    80001d2a:	1000                	addi	s0,sp,32
    80001d2c:	84aa                	mv	s1,a0
    if (p->trapframe)
    80001d2e:	6d28                	ld	a0,88(a0)
    80001d30:	c509                	beqz	a0,80001d3a <freeproc+0x18>
        kfree((void *)p->trapframe);
    80001d32:	fffff097          	auipc	ra,0xfffff
    80001d36:	cc2080e7          	jalr	-830(ra) # 800009f4 <kfree>
    p->trapframe = 0;
    80001d3a:	0404bc23          	sd	zero,88(s1)
    if (p->pagetable)
    80001d3e:	68a8                	ld	a0,80(s1)
    80001d40:	c511                	beqz	a0,80001d4c <freeproc+0x2a>
        proc_freepagetable(p->pagetable, p->sz);
    80001d42:	64ac                	ld	a1,72(s1)
    80001d44:	00000097          	auipc	ra,0x0
    80001d48:	f8c080e7          	jalr	-116(ra) # 80001cd0 <proc_freepagetable>
    p->pagetable = 0;
    80001d4c:	0404b823          	sd	zero,80(s1)
    p->sz = 0;
    80001d50:	0404b423          	sd	zero,72(s1)
    p->pid = 0;
    80001d54:	0204a823          	sw	zero,48(s1)
    p->parent = 0;
    80001d58:	0204bc23          	sd	zero,56(s1)
    p->name[0] = 0;
    80001d5c:	14048c23          	sb	zero,344(s1)
    p->chan = 0;
    80001d60:	0204b023          	sd	zero,32(s1)
    p->killed = 0;
    80001d64:	0204a423          	sw	zero,40(s1)
    p->xstate = 0;
    80001d68:	0204a623          	sw	zero,44(s1)
    p->state = UNUSED;
    80001d6c:	0004ac23          	sw	zero,24(s1)
}
    80001d70:	60e2                	ld	ra,24(sp)
    80001d72:	6442                	ld	s0,16(sp)
    80001d74:	64a2                	ld	s1,8(sp)
    80001d76:	6105                	addi	sp,sp,32
    80001d78:	8082                	ret

0000000080001d7a <allocproc>:
{
    80001d7a:	1101                	addi	sp,sp,-32
    80001d7c:	ec06                	sd	ra,24(sp)
    80001d7e:	e822                	sd	s0,16(sp)
    80001d80:	e426                	sd	s1,8(sp)
    80001d82:	e04a                	sd	s2,0(sp)
    80001d84:	1000                	addi	s0,sp,32
    for (p = proc; p < &proc[NPROC]; p++)
    80001d86:	0000f497          	auipc	s1,0xf
    80001d8a:	38a48493          	addi	s1,s1,906 # 80011110 <proc>
    80001d8e:	00015917          	auipc	s2,0x15
    80001d92:	d8290913          	addi	s2,s2,-638 # 80016b10 <tickslock>
        acquire(&p->lock);
    80001d96:	8526                	mv	a0,s1
    80001d98:	fffff097          	auipc	ra,0xfffff
    80001d9c:	efe080e7          	jalr	-258(ra) # 80000c96 <acquire>
        if (p->state == UNUSED)
    80001da0:	4c9c                	lw	a5,24(s1)
    80001da2:	cf81                	beqz	a5,80001dba <allocproc+0x40>
            release(&p->lock);
    80001da4:	8526                	mv	a0,s1
    80001da6:	fffff097          	auipc	ra,0xfffff
    80001daa:	fa4080e7          	jalr	-92(ra) # 80000d4a <release>
    for (p = proc; p < &proc[NPROC]; p++)
    80001dae:	16848493          	addi	s1,s1,360
    80001db2:	ff2492e3          	bne	s1,s2,80001d96 <allocproc+0x1c>
    return 0;
    80001db6:	4481                	li	s1,0
    80001db8:	a889                	j	80001e0a <allocproc+0x90>
    p->pid = allocpid();
    80001dba:	00000097          	auipc	ra,0x0
    80001dbe:	e34080e7          	jalr	-460(ra) # 80001bee <allocpid>
    80001dc2:	d888                	sw	a0,48(s1)
    p->state = USED;
    80001dc4:	4785                	li	a5,1
    80001dc6:	cc9c                	sw	a5,24(s1)
    if ((p->trapframe = (struct trapframe *)kalloc()) == 0)
    80001dc8:	fffff097          	auipc	ra,0xfffff
    80001dcc:	d92080e7          	jalr	-622(ra) # 80000b5a <kalloc>
    80001dd0:	892a                	mv	s2,a0
    80001dd2:	eca8                	sd	a0,88(s1)
    80001dd4:	c131                	beqz	a0,80001e18 <allocproc+0x9e>
    p->pagetable = proc_pagetable(p);
    80001dd6:	8526                	mv	a0,s1
    80001dd8:	00000097          	auipc	ra,0x0
    80001ddc:	e5c080e7          	jalr	-420(ra) # 80001c34 <proc_pagetable>
    80001de0:	892a                	mv	s2,a0
    80001de2:	e8a8                	sd	a0,80(s1)
    if (p->pagetable == 0)
    80001de4:	c531                	beqz	a0,80001e30 <allocproc+0xb6>
    memset(&p->context, 0, sizeof(p->context));
    80001de6:	07000613          	li	a2,112
    80001dea:	4581                	li	a1,0
    80001dec:	06048513          	addi	a0,s1,96
    80001df0:	fffff097          	auipc	ra,0xfffff
    80001df4:	fa2080e7          	jalr	-94(ra) # 80000d92 <memset>
    p->context.ra = (uint64)forkret;
    80001df8:	00000797          	auipc	a5,0x0
    80001dfc:	db078793          	addi	a5,a5,-592 # 80001ba8 <forkret>
    80001e00:	f0bc                	sd	a5,96(s1)
    p->context.sp = p->kstack + PGSIZE;
    80001e02:	60bc                	ld	a5,64(s1)
    80001e04:	6705                	lui	a4,0x1
    80001e06:	97ba                	add	a5,a5,a4
    80001e08:	f4bc                	sd	a5,104(s1)
}
    80001e0a:	8526                	mv	a0,s1
    80001e0c:	60e2                	ld	ra,24(sp)
    80001e0e:	6442                	ld	s0,16(sp)
    80001e10:	64a2                	ld	s1,8(sp)
    80001e12:	6902                	ld	s2,0(sp)
    80001e14:	6105                	addi	sp,sp,32
    80001e16:	8082                	ret
        freeproc(p);
    80001e18:	8526                	mv	a0,s1
    80001e1a:	00000097          	auipc	ra,0x0
    80001e1e:	f08080e7          	jalr	-248(ra) # 80001d22 <freeproc>
        release(&p->lock);
    80001e22:	8526                	mv	a0,s1
    80001e24:	fffff097          	auipc	ra,0xfffff
    80001e28:	f26080e7          	jalr	-218(ra) # 80000d4a <release>
        return 0;
    80001e2c:	84ca                	mv	s1,s2
    80001e2e:	bff1                	j	80001e0a <allocproc+0x90>
        freeproc(p);
    80001e30:	8526                	mv	a0,s1
    80001e32:	00000097          	auipc	ra,0x0
    80001e36:	ef0080e7          	jalr	-272(ra) # 80001d22 <freeproc>
        release(&p->lock);
    80001e3a:	8526                	mv	a0,s1
    80001e3c:	fffff097          	auipc	ra,0xfffff
    80001e40:	f0e080e7          	jalr	-242(ra) # 80000d4a <release>
        return 0;
    80001e44:	84ca                	mv	s1,s2
    80001e46:	b7d1                	j	80001e0a <allocproc+0x90>

0000000080001e48 <userinit>:
{
    80001e48:	1101                	addi	sp,sp,-32
    80001e4a:	ec06                	sd	ra,24(sp)
    80001e4c:	e822                	sd	s0,16(sp)
    80001e4e:	e426                	sd	s1,8(sp)
    80001e50:	1000                	addi	s0,sp,32
    p = allocproc();
    80001e52:	00000097          	auipc	ra,0x0
    80001e56:	f28080e7          	jalr	-216(ra) # 80001d7a <allocproc>
    80001e5a:	84aa                	mv	s1,a0
    initproc = p;
    80001e5c:	00007797          	auipc	a5,0x7
    80001e60:	c0a7b623          	sd	a0,-1012(a5) # 80008a68 <initproc>
    uvmfirst(p->pagetable, initcode, sizeof(initcode));
    80001e64:	03400613          	li	a2,52
    80001e68:	00007597          	auipc	a1,0x7
    80001e6c:	b4858593          	addi	a1,a1,-1208 # 800089b0 <initcode>
    80001e70:	6928                	ld	a0,80(a0)
    80001e72:	fffff097          	auipc	ra,0xfffff
    80001e76:	5ac080e7          	jalr	1452(ra) # 8000141e <uvmfirst>
    p->sz = PGSIZE;
    80001e7a:	6785                	lui	a5,0x1
    80001e7c:	e4bc                	sd	a5,72(s1)
    p->trapframe->epc = 0;     // user program counter
    80001e7e:	6cb8                	ld	a4,88(s1)
    80001e80:	00073c23          	sd	zero,24(a4) # 1018 <_entry-0x7fffefe8>
    p->trapframe->sp = PGSIZE; // user stack pointer
    80001e84:	6cb8                	ld	a4,88(s1)
    80001e86:	fb1c                	sd	a5,48(a4)
    safestrcpy(p->name, "initcode", sizeof(p->name));
    80001e88:	4641                	li	a2,16
    80001e8a:	00006597          	auipc	a1,0x6
    80001e8e:	3b658593          	addi	a1,a1,950 # 80008240 <digits+0x1f0>
    80001e92:	15848513          	addi	a0,s1,344
    80001e96:	fffff097          	auipc	ra,0xfffff
    80001e9a:	04e080e7          	jalr	78(ra) # 80000ee4 <safestrcpy>
    p->cwd = namei("/");
    80001e9e:	00006517          	auipc	a0,0x6
    80001ea2:	3b250513          	addi	a0,a0,946 # 80008250 <digits+0x200>
    80001ea6:	00002097          	auipc	ra,0x2
    80001eaa:	42c080e7          	jalr	1068(ra) # 800042d2 <namei>
    80001eae:	14a4b823          	sd	a0,336(s1)
    p->state = RUNNABLE;
    80001eb2:	478d                	li	a5,3
    80001eb4:	cc9c                	sw	a5,24(s1)
    release(&p->lock);
    80001eb6:	8526                	mv	a0,s1
    80001eb8:	fffff097          	auipc	ra,0xfffff
    80001ebc:	e92080e7          	jalr	-366(ra) # 80000d4a <release>
}
    80001ec0:	60e2                	ld	ra,24(sp)
    80001ec2:	6442                	ld	s0,16(sp)
    80001ec4:	64a2                	ld	s1,8(sp)
    80001ec6:	6105                	addi	sp,sp,32
    80001ec8:	8082                	ret

0000000080001eca <growproc>:
{
    80001eca:	1101                	addi	sp,sp,-32
    80001ecc:	ec06                	sd	ra,24(sp)
    80001ece:	e822                	sd	s0,16(sp)
    80001ed0:	e426                	sd	s1,8(sp)
    80001ed2:	e04a                	sd	s2,0(sp)
    80001ed4:	1000                	addi	s0,sp,32
    80001ed6:	892a                	mv	s2,a0
    struct proc *p = myproc();
    80001ed8:	00000097          	auipc	ra,0x0
    80001edc:	c98080e7          	jalr	-872(ra) # 80001b70 <myproc>
    80001ee0:	84aa                	mv	s1,a0
    sz = p->sz;
    80001ee2:	652c                	ld	a1,72(a0)
    if (n > 0)
    80001ee4:	01204c63          	bgtz	s2,80001efc <growproc+0x32>
    else if (n < 0)
    80001ee8:	02094663          	bltz	s2,80001f14 <growproc+0x4a>
    p->sz = sz;
    80001eec:	e4ac                	sd	a1,72(s1)
    return 0;
    80001eee:	4501                	li	a0,0
}
    80001ef0:	60e2                	ld	ra,24(sp)
    80001ef2:	6442                	ld	s0,16(sp)
    80001ef4:	64a2                	ld	s1,8(sp)
    80001ef6:	6902                	ld	s2,0(sp)
    80001ef8:	6105                	addi	sp,sp,32
    80001efa:	8082                	ret
        if ((sz = uvmalloc(p->pagetable, sz, sz + n, PTE_W)) == 0)
    80001efc:	4691                	li	a3,4
    80001efe:	00b90633          	add	a2,s2,a1
    80001f02:	6928                	ld	a0,80(a0)
    80001f04:	fffff097          	auipc	ra,0xfffff
    80001f08:	5d4080e7          	jalr	1492(ra) # 800014d8 <uvmalloc>
    80001f0c:	85aa                	mv	a1,a0
    80001f0e:	fd79                	bnez	a0,80001eec <growproc+0x22>
            return -1;
    80001f10:	557d                	li	a0,-1
    80001f12:	bff9                	j	80001ef0 <growproc+0x26>
        sz = uvmdealloc(p->pagetable, sz, sz + n);
    80001f14:	00b90633          	add	a2,s2,a1
    80001f18:	6928                	ld	a0,80(a0)
    80001f1a:	fffff097          	auipc	ra,0xfffff
    80001f1e:	576080e7          	jalr	1398(ra) # 80001490 <uvmdealloc>
    80001f22:	85aa                	mv	a1,a0
    80001f24:	b7e1                	j	80001eec <growproc+0x22>

0000000080001f26 <ps>:
{
    80001f26:	715d                	addi	sp,sp,-80
    80001f28:	e486                	sd	ra,72(sp)
    80001f2a:	e0a2                	sd	s0,64(sp)
    80001f2c:	fc26                	sd	s1,56(sp)
    80001f2e:	f84a                	sd	s2,48(sp)
    80001f30:	f44e                	sd	s3,40(sp)
    80001f32:	f052                	sd	s4,32(sp)
    80001f34:	ec56                	sd	s5,24(sp)
    80001f36:	e85a                	sd	s6,16(sp)
    80001f38:	e45e                	sd	s7,8(sp)
    80001f3a:	e062                	sd	s8,0(sp)
    80001f3c:	0880                	addi	s0,sp,80
    80001f3e:	84aa                	mv	s1,a0
    80001f40:	8bae                	mv	s7,a1
    void *result = (void *)myproc()->sz;
    80001f42:	00000097          	auipc	ra,0x0
    80001f46:	c2e080e7          	jalr	-978(ra) # 80001b70 <myproc>
    if (count == 0)
    80001f4a:	120b8063          	beqz	s7,8000206a <ps+0x144>
    void *result = (void *)myproc()->sz;
    80001f4e:	04853b03          	ld	s6,72(a0)
    if (growproc(count * sizeof(struct user_proc)) < 0)
    80001f52:	003b951b          	slliw	a0,s7,0x3
    80001f56:	0175053b          	addw	a0,a0,s7
    80001f5a:	0025151b          	slliw	a0,a0,0x2
    80001f5e:	00000097          	auipc	ra,0x0
    80001f62:	f6c080e7          	jalr	-148(ra) # 80001eca <growproc>
    80001f66:	10054463          	bltz	a0,8000206e <ps+0x148>
    struct user_proc loc_result[count];
    80001f6a:	003b9a13          	slli	s4,s7,0x3
    80001f6e:	9a5e                	add	s4,s4,s7
    80001f70:	0a0a                	slli	s4,s4,0x2
    80001f72:	00fa0793          	addi	a5,s4,15
    80001f76:	8391                	srli	a5,a5,0x4
    80001f78:	0792                	slli	a5,a5,0x4
    80001f7a:	40f10133          	sub	sp,sp,a5
    80001f7e:	8a8a                	mv	s5,sp
    struct proc *p = proc + (start * sizeof(proc));
    80001f80:	007e9537          	lui	a0,0x7e9
    80001f84:	02a484b3          	mul	s1,s1,a0
    80001f88:	0000f797          	auipc	a5,0xf
    80001f8c:	18878793          	addi	a5,a5,392 # 80011110 <proc>
    80001f90:	94be                	add	s1,s1,a5
    if (p >= &proc[NPROC])
    80001f92:	00015797          	auipc	a5,0x15
    80001f96:	b7e78793          	addi	a5,a5,-1154 # 80016b10 <tickslock>
    80001f9a:	0cf4fc63          	bgeu	s1,a5,80002072 <ps+0x14c>
    80001f9e:	014a8913          	addi	s2,s5,20
    uint8 localCount = 0;
    80001fa2:	4981                	li	s3,0
    for (; p < &proc[NPROC]; p++)
    80001fa4:	8c3e                	mv	s8,a5
    80001fa6:	a051                	j	8000202a <ps+0x104>
            loc_result[localCount].state = UNUSED;
    80001fa8:	00399793          	slli	a5,s3,0x3
    80001fac:	97ce                	add	a5,a5,s3
    80001fae:	078a                	slli	a5,a5,0x2
    80001fb0:	97d6                	add	a5,a5,s5
    80001fb2:	0007a023          	sw	zero,0(a5)
            release(&p->lock);
    80001fb6:	8526                	mv	a0,s1
    80001fb8:	fffff097          	auipc	ra,0xfffff
    80001fbc:	d92080e7          	jalr	-622(ra) # 80000d4a <release>
    if (localCount < count)
    80001fc0:	0179f963          	bgeu	s3,s7,80001fd2 <ps+0xac>
        loc_result[localCount].state = UNUSED; // if we reach the end of processes
    80001fc4:	00399793          	slli	a5,s3,0x3
    80001fc8:	97ce                	add	a5,a5,s3
    80001fca:	078a                	slli	a5,a5,0x2
    80001fcc:	97d6                	add	a5,a5,s5
    80001fce:	0007a023          	sw	zero,0(a5)
    void *result = (void *)myproc()->sz;
    80001fd2:	84da                	mv	s1,s6
    copyout(myproc()->pagetable, (uint64)result, (void *)loc_result, count * sizeof(struct user_proc));
    80001fd4:	00000097          	auipc	ra,0x0
    80001fd8:	b9c080e7          	jalr	-1124(ra) # 80001b70 <myproc>
    80001fdc:	86d2                	mv	a3,s4
    80001fde:	8656                	mv	a2,s5
    80001fe0:	85da                	mv	a1,s6
    80001fe2:	6928                	ld	a0,80(a0)
    80001fe4:	fffff097          	auipc	ra,0xfffff
    80001fe8:	74c080e7          	jalr	1868(ra) # 80001730 <copyout>
}
    80001fec:	8526                	mv	a0,s1
    80001fee:	fb040113          	addi	sp,s0,-80
    80001ff2:	60a6                	ld	ra,72(sp)
    80001ff4:	6406                	ld	s0,64(sp)
    80001ff6:	74e2                	ld	s1,56(sp)
    80001ff8:	7942                	ld	s2,48(sp)
    80001ffa:	79a2                	ld	s3,40(sp)
    80001ffc:	7a02                	ld	s4,32(sp)
    80001ffe:	6ae2                	ld	s5,24(sp)
    80002000:	6b42                	ld	s6,16(sp)
    80002002:	6ba2                	ld	s7,8(sp)
    80002004:	6c02                	ld	s8,0(sp)
    80002006:	6161                	addi	sp,sp,80
    80002008:	8082                	ret
        release(&p->lock);
    8000200a:	8526                	mv	a0,s1
    8000200c:	fffff097          	auipc	ra,0xfffff
    80002010:	d3e080e7          	jalr	-706(ra) # 80000d4a <release>
        localCount++;
    80002014:	2985                	addiw	s3,s3,1
    80002016:	0ff9f993          	andi	s3,s3,255
    for (; p < &proc[NPROC]; p++)
    8000201a:	16848493          	addi	s1,s1,360
    8000201e:	fb84f1e3          	bgeu	s1,s8,80001fc0 <ps+0x9a>
        if (localCount == count)
    80002022:	02490913          	addi	s2,s2,36
    80002026:	fb3b86e3          	beq	s7,s3,80001fd2 <ps+0xac>
        acquire(&p->lock);
    8000202a:	8526                	mv	a0,s1
    8000202c:	fffff097          	auipc	ra,0xfffff
    80002030:	c6a080e7          	jalr	-918(ra) # 80000c96 <acquire>
        if (p->state == UNUSED)
    80002034:	4c9c                	lw	a5,24(s1)
    80002036:	dbad                	beqz	a5,80001fa8 <ps+0x82>
        loc_result[localCount].state = p->state;
    80002038:	fef92623          	sw	a5,-20(s2)
        loc_result[localCount].killed = p->killed;
    8000203c:	549c                	lw	a5,40(s1)
    8000203e:	fef92823          	sw	a5,-16(s2)
        loc_result[localCount].xstate = p->xstate;
    80002042:	54dc                	lw	a5,44(s1)
    80002044:	fef92a23          	sw	a5,-12(s2)
        loc_result[localCount].pid = p->pid;
    80002048:	589c                	lw	a5,48(s1)
    8000204a:	fef92c23          	sw	a5,-8(s2)
        copy_array(p->name, loc_result[localCount].name, 16);
    8000204e:	4641                	li	a2,16
    80002050:	85ca                	mv	a1,s2
    80002052:	15848513          	addi	a0,s1,344
    80002056:	00000097          	auipc	ra,0x0
    8000205a:	ac0080e7          	jalr	-1344(ra) # 80001b16 <copy_array>
        if (p->parent != 0) // init
    8000205e:	7c9c                	ld	a5,56(s1)
    80002060:	d7cd                	beqz	a5,8000200a <ps+0xe4>
            loc_result[localCount].parent_id = p->parent->pid;
    80002062:	5b9c                	lw	a5,48(a5)
    80002064:	fef92e23          	sw	a5,-4(s2)
    80002068:	b74d                	j	8000200a <ps+0xe4>
        return result;
    8000206a:	4481                	li	s1,0
    8000206c:	b741                	j	80001fec <ps+0xc6>
        return result;
    8000206e:	4481                	li	s1,0
    80002070:	bfb5                	j	80001fec <ps+0xc6>
        return result;
    80002072:	4481                	li	s1,0
    80002074:	bfa5                	j	80001fec <ps+0xc6>

0000000080002076 <fork>:
{
    80002076:	7179                	addi	sp,sp,-48
    80002078:	f406                	sd	ra,40(sp)
    8000207a:	f022                	sd	s0,32(sp)
    8000207c:	ec26                	sd	s1,24(sp)
    8000207e:	e84a                	sd	s2,16(sp)
    80002080:	e44e                	sd	s3,8(sp)
    80002082:	e052                	sd	s4,0(sp)
    80002084:	1800                	addi	s0,sp,48
    struct proc *p = myproc();
    80002086:	00000097          	auipc	ra,0x0
    8000208a:	aea080e7          	jalr	-1302(ra) # 80001b70 <myproc>
    8000208e:	892a                	mv	s2,a0
    if ((np = allocproc()) == 0)
    80002090:	00000097          	auipc	ra,0x0
    80002094:	cea080e7          	jalr	-790(ra) # 80001d7a <allocproc>
    80002098:	10050b63          	beqz	a0,800021ae <fork+0x138>
    8000209c:	89aa                	mv	s3,a0
    if (uvmcopy(p->pagetable, np->pagetable, p->sz) < 0)
    8000209e:	04893603          	ld	a2,72(s2)
    800020a2:	692c                	ld	a1,80(a0)
    800020a4:	05093503          	ld	a0,80(s2)
    800020a8:	fffff097          	auipc	ra,0xfffff
    800020ac:	584080e7          	jalr	1412(ra) # 8000162c <uvmcopy>
    800020b0:	04054663          	bltz	a0,800020fc <fork+0x86>
    np->sz = p->sz;
    800020b4:	04893783          	ld	a5,72(s2)
    800020b8:	04f9b423          	sd	a5,72(s3)
    *(np->trapframe) = *(p->trapframe);
    800020bc:	05893683          	ld	a3,88(s2)
    800020c0:	87b6                	mv	a5,a3
    800020c2:	0589b703          	ld	a4,88(s3)
    800020c6:	12068693          	addi	a3,a3,288
    800020ca:	0007b803          	ld	a6,0(a5)
    800020ce:	6788                	ld	a0,8(a5)
    800020d0:	6b8c                	ld	a1,16(a5)
    800020d2:	6f90                	ld	a2,24(a5)
    800020d4:	01073023          	sd	a6,0(a4)
    800020d8:	e708                	sd	a0,8(a4)
    800020da:	eb0c                	sd	a1,16(a4)
    800020dc:	ef10                	sd	a2,24(a4)
    800020de:	02078793          	addi	a5,a5,32
    800020e2:	02070713          	addi	a4,a4,32
    800020e6:	fed792e3          	bne	a5,a3,800020ca <fork+0x54>
    np->trapframe->a0 = 0;
    800020ea:	0589b783          	ld	a5,88(s3)
    800020ee:	0607b823          	sd	zero,112(a5)
    800020f2:	0d000493          	li	s1,208
    for (i = 0; i < NOFILE; i++)
    800020f6:	15000a13          	li	s4,336
    800020fa:	a03d                	j	80002128 <fork+0xb2>
        freeproc(np);
    800020fc:	854e                	mv	a0,s3
    800020fe:	00000097          	auipc	ra,0x0
    80002102:	c24080e7          	jalr	-988(ra) # 80001d22 <freeproc>
        release(&np->lock);
    80002106:	854e                	mv	a0,s3
    80002108:	fffff097          	auipc	ra,0xfffff
    8000210c:	c42080e7          	jalr	-958(ra) # 80000d4a <release>
        return -1;
    80002110:	5a7d                	li	s4,-1
    80002112:	a069                	j	8000219c <fork+0x126>
            np->ofile[i] = filedup(p->ofile[i]);
    80002114:	00003097          	auipc	ra,0x3
    80002118:	854080e7          	jalr	-1964(ra) # 80004968 <filedup>
    8000211c:	009987b3          	add	a5,s3,s1
    80002120:	e388                	sd	a0,0(a5)
    for (i = 0; i < NOFILE; i++)
    80002122:	04a1                	addi	s1,s1,8
    80002124:	01448763          	beq	s1,s4,80002132 <fork+0xbc>
        if (p->ofile[i])
    80002128:	009907b3          	add	a5,s2,s1
    8000212c:	6388                	ld	a0,0(a5)
    8000212e:	f17d                	bnez	a0,80002114 <fork+0x9e>
    80002130:	bfcd                	j	80002122 <fork+0xac>
    np->cwd = idup(p->cwd);
    80002132:	15093503          	ld	a0,336(s2)
    80002136:	00002097          	auipc	ra,0x2
    8000213a:	9b8080e7          	jalr	-1608(ra) # 80003aee <idup>
    8000213e:	14a9b823          	sd	a0,336(s3)
    safestrcpy(np->name, p->name, sizeof(p->name));
    80002142:	4641                	li	a2,16
    80002144:	15890593          	addi	a1,s2,344
    80002148:	15898513          	addi	a0,s3,344
    8000214c:	fffff097          	auipc	ra,0xfffff
    80002150:	d98080e7          	jalr	-616(ra) # 80000ee4 <safestrcpy>
    pid = np->pid;
    80002154:	0309aa03          	lw	s4,48(s3)
    release(&np->lock);
    80002158:	854e                	mv	a0,s3
    8000215a:	fffff097          	auipc	ra,0xfffff
    8000215e:	bf0080e7          	jalr	-1040(ra) # 80000d4a <release>
    acquire(&wait_lock);
    80002162:	0000f497          	auipc	s1,0xf
    80002166:	f9648493          	addi	s1,s1,-106 # 800110f8 <wait_lock>
    8000216a:	8526                	mv	a0,s1
    8000216c:	fffff097          	auipc	ra,0xfffff
    80002170:	b2a080e7          	jalr	-1238(ra) # 80000c96 <acquire>
    np->parent = p;
    80002174:	0329bc23          	sd	s2,56(s3)
    release(&wait_lock);
    80002178:	8526                	mv	a0,s1
    8000217a:	fffff097          	auipc	ra,0xfffff
    8000217e:	bd0080e7          	jalr	-1072(ra) # 80000d4a <release>
    acquire(&np->lock);
    80002182:	854e                	mv	a0,s3
    80002184:	fffff097          	auipc	ra,0xfffff
    80002188:	b12080e7          	jalr	-1262(ra) # 80000c96 <acquire>
    np->state = RUNNABLE;
    8000218c:	478d                	li	a5,3
    8000218e:	00f9ac23          	sw	a5,24(s3)
    release(&np->lock);
    80002192:	854e                	mv	a0,s3
    80002194:	fffff097          	auipc	ra,0xfffff
    80002198:	bb6080e7          	jalr	-1098(ra) # 80000d4a <release>
}
    8000219c:	8552                	mv	a0,s4
    8000219e:	70a2                	ld	ra,40(sp)
    800021a0:	7402                	ld	s0,32(sp)
    800021a2:	64e2                	ld	s1,24(sp)
    800021a4:	6942                	ld	s2,16(sp)
    800021a6:	69a2                	ld	s3,8(sp)
    800021a8:	6a02                	ld	s4,0(sp)
    800021aa:	6145                	addi	sp,sp,48
    800021ac:	8082                	ret
        return -1;
    800021ae:	5a7d                	li	s4,-1
    800021b0:	b7f5                	j	8000219c <fork+0x126>

00000000800021b2 <scheduler>:
{
    800021b2:	1101                	addi	sp,sp,-32
    800021b4:	ec06                	sd	ra,24(sp)
    800021b6:	e822                	sd	s0,16(sp)
    800021b8:	e426                	sd	s1,8(sp)
    800021ba:	1000                	addi	s0,sp,32
        (*sched_pointer)();
    800021bc:	00006497          	auipc	s1,0x6
    800021c0:	7dc48493          	addi	s1,s1,2012 # 80008998 <sched_pointer>
    800021c4:	609c                	ld	a5,0(s1)
    800021c6:	9782                	jalr	a5
    while (1)
    800021c8:	bff5                	j	800021c4 <scheduler+0x12>

00000000800021ca <sched>:
{
    800021ca:	7179                	addi	sp,sp,-48
    800021cc:	f406                	sd	ra,40(sp)
    800021ce:	f022                	sd	s0,32(sp)
    800021d0:	ec26                	sd	s1,24(sp)
    800021d2:	e84a                	sd	s2,16(sp)
    800021d4:	e44e                	sd	s3,8(sp)
    800021d6:	1800                	addi	s0,sp,48
    struct proc *p = myproc();
    800021d8:	00000097          	auipc	ra,0x0
    800021dc:	998080e7          	jalr	-1640(ra) # 80001b70 <myproc>
    800021e0:	84aa                	mv	s1,a0
    if (!holding(&p->lock))
    800021e2:	fffff097          	auipc	ra,0xfffff
    800021e6:	a3a080e7          	jalr	-1478(ra) # 80000c1c <holding>
    800021ea:	c53d                	beqz	a0,80002258 <sched+0x8e>
    800021ec:	8792                	mv	a5,tp
    if (mycpu()->noff != 1)
    800021ee:	2781                	sext.w	a5,a5
    800021f0:	079e                	slli	a5,a5,0x7
    800021f2:	0000f717          	auipc	a4,0xf
    800021f6:	aee70713          	addi	a4,a4,-1298 # 80010ce0 <cpus>
    800021fa:	97ba                	add	a5,a5,a4
    800021fc:	5fb8                	lw	a4,120(a5)
    800021fe:	4785                	li	a5,1
    80002200:	06f71463          	bne	a4,a5,80002268 <sched+0x9e>
    if (p->state == RUNNING)
    80002204:	4c98                	lw	a4,24(s1)
    80002206:	4791                	li	a5,4
    80002208:	06f70863          	beq	a4,a5,80002278 <sched+0xae>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    8000220c:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80002210:	8b89                	andi	a5,a5,2
    if (intr_get())
    80002212:	ebbd                	bnez	a5,80002288 <sched+0xbe>
  asm volatile("mv %0, tp" : "=r" (x) );
    80002214:	8792                	mv	a5,tp
    intena = mycpu()->intena;
    80002216:	0000f917          	auipc	s2,0xf
    8000221a:	aca90913          	addi	s2,s2,-1334 # 80010ce0 <cpus>
    8000221e:	2781                	sext.w	a5,a5
    80002220:	079e                	slli	a5,a5,0x7
    80002222:	97ca                	add	a5,a5,s2
    80002224:	07c7a983          	lw	s3,124(a5)
    80002228:	8592                	mv	a1,tp
    swtch(&p->context, &mycpu()->context);
    8000222a:	2581                	sext.w	a1,a1
    8000222c:	059e                	slli	a1,a1,0x7
    8000222e:	05a1                	addi	a1,a1,8
    80002230:	95ca                	add	a1,a1,s2
    80002232:	06048513          	addi	a0,s1,96
    80002236:	00000097          	auipc	ra,0x0
    8000223a:	7ac080e7          	jalr	1964(ra) # 800029e2 <swtch>
    8000223e:	8792                	mv	a5,tp
    mycpu()->intena = intena;
    80002240:	2781                	sext.w	a5,a5
    80002242:	079e                	slli	a5,a5,0x7
    80002244:	993e                	add	s2,s2,a5
    80002246:	07392e23          	sw	s3,124(s2)
}
    8000224a:	70a2                	ld	ra,40(sp)
    8000224c:	7402                	ld	s0,32(sp)
    8000224e:	64e2                	ld	s1,24(sp)
    80002250:	6942                	ld	s2,16(sp)
    80002252:	69a2                	ld	s3,8(sp)
    80002254:	6145                	addi	sp,sp,48
    80002256:	8082                	ret
        panic("sched p->lock");
    80002258:	00006517          	auipc	a0,0x6
    8000225c:	00050513          	mv	a0,a0
    80002260:	ffffe097          	auipc	ra,0xffffe
    80002264:	2c8080e7          	jalr	712(ra) # 80000528 <panic>
        panic("sched locks");
    80002268:	00006517          	auipc	a0,0x6
    8000226c:	00050513          	mv	a0,a0
    80002270:	ffffe097          	auipc	ra,0xffffe
    80002274:	2b8080e7          	jalr	696(ra) # 80000528 <panic>
        panic("sched running");
    80002278:	00006517          	auipc	a0,0x6
    8000227c:	00050513          	mv	a0,a0
    80002280:	ffffe097          	auipc	ra,0xffffe
    80002284:	2a8080e7          	jalr	680(ra) # 80000528 <panic>
        panic("sched interruptible");
    80002288:	00006517          	auipc	a0,0x6
    8000228c:	00050513          	mv	a0,a0
    80002290:	ffffe097          	auipc	ra,0xffffe
    80002294:	298080e7          	jalr	664(ra) # 80000528 <panic>

0000000080002298 <yield>:
{
    80002298:	1101                	addi	sp,sp,-32
    8000229a:	ec06                	sd	ra,24(sp)
    8000229c:	e822                	sd	s0,16(sp)
    8000229e:	e426                	sd	s1,8(sp)
    800022a0:	1000                	addi	s0,sp,32
    struct proc *p = myproc();
    800022a2:	00000097          	auipc	ra,0x0
    800022a6:	8ce080e7          	jalr	-1842(ra) # 80001b70 <myproc>
    800022aa:	84aa                	mv	s1,a0
    acquire(&p->lock);
    800022ac:	fffff097          	auipc	ra,0xfffff
    800022b0:	9ea080e7          	jalr	-1558(ra) # 80000c96 <acquire>
    p->state = RUNNABLE;
    800022b4:	478d                	li	a5,3
    800022b6:	cc9c                	sw	a5,24(s1)
    sched();
    800022b8:	00000097          	auipc	ra,0x0
    800022bc:	f12080e7          	jalr	-238(ra) # 800021ca <sched>
    release(&p->lock);
    800022c0:	8526                	mv	a0,s1
    800022c2:	fffff097          	auipc	ra,0xfffff
    800022c6:	a88080e7          	jalr	-1400(ra) # 80000d4a <release>
}
    800022ca:	60e2                	ld	ra,24(sp)
    800022cc:	6442                	ld	s0,16(sp)
    800022ce:	64a2                	ld	s1,8(sp)
    800022d0:	6105                	addi	sp,sp,32
    800022d2:	8082                	ret

00000000800022d4 <sleep>:

// Atomically release lock and sleep on chan.
// Reacquires lock when awakened.
void sleep(void *chan, struct spinlock *lk)
{
    800022d4:	7179                	addi	sp,sp,-48
    800022d6:	f406                	sd	ra,40(sp)
    800022d8:	f022                	sd	s0,32(sp)
    800022da:	ec26                	sd	s1,24(sp)
    800022dc:	e84a                	sd	s2,16(sp)
    800022de:	e44e                	sd	s3,8(sp)
    800022e0:	1800                	addi	s0,sp,48
    800022e2:	89aa                	mv	s3,a0
    800022e4:	892e                	mv	s2,a1
    struct proc *p = myproc();
    800022e6:	00000097          	auipc	ra,0x0
    800022ea:	88a080e7          	jalr	-1910(ra) # 80001b70 <myproc>
    800022ee:	84aa                	mv	s1,a0
    // Once we hold p->lock, we can be
    // guaranteed that we won't miss any wakeup
    // (wakeup locks p->lock),
    // so it's okay to release lk.

    acquire(&p->lock); // DOC: sleeplock1
    800022f0:	fffff097          	auipc	ra,0xfffff
    800022f4:	9a6080e7          	jalr	-1626(ra) # 80000c96 <acquire>
    release(lk);
    800022f8:	854a                	mv	a0,s2
    800022fa:	fffff097          	auipc	ra,0xfffff
    800022fe:	a50080e7          	jalr	-1456(ra) # 80000d4a <release>

    // Go to sleep.
    p->chan = chan;
    80002302:	0334b023          	sd	s3,32(s1)
    p->state = SLEEPING;
    80002306:	4789                	li	a5,2
    80002308:	cc9c                	sw	a5,24(s1)

    sched();
    8000230a:	00000097          	auipc	ra,0x0
    8000230e:	ec0080e7          	jalr	-320(ra) # 800021ca <sched>

    // Tidy up.
    p->chan = 0;
    80002312:	0204b023          	sd	zero,32(s1)

    // Reacquire original lock.
    release(&p->lock);
    80002316:	8526                	mv	a0,s1
    80002318:	fffff097          	auipc	ra,0xfffff
    8000231c:	a32080e7          	jalr	-1486(ra) # 80000d4a <release>
    acquire(lk);
    80002320:	854a                	mv	a0,s2
    80002322:	fffff097          	auipc	ra,0xfffff
    80002326:	974080e7          	jalr	-1676(ra) # 80000c96 <acquire>
}
    8000232a:	70a2                	ld	ra,40(sp)
    8000232c:	7402                	ld	s0,32(sp)
    8000232e:	64e2                	ld	s1,24(sp)
    80002330:	6942                	ld	s2,16(sp)
    80002332:	69a2                	ld	s3,8(sp)
    80002334:	6145                	addi	sp,sp,48
    80002336:	8082                	ret

0000000080002338 <wakeup>:

// Wake up all processes sleeping on chan.
// Must be called without any p->lock.
void wakeup(void *chan)
{
    80002338:	7139                	addi	sp,sp,-64
    8000233a:	fc06                	sd	ra,56(sp)
    8000233c:	f822                	sd	s0,48(sp)
    8000233e:	f426                	sd	s1,40(sp)
    80002340:	f04a                	sd	s2,32(sp)
    80002342:	ec4e                	sd	s3,24(sp)
    80002344:	e852                	sd	s4,16(sp)
    80002346:	e456                	sd	s5,8(sp)
    80002348:	0080                	addi	s0,sp,64
    8000234a:	8a2a                	mv	s4,a0
    struct proc *p;

    for (p = proc; p < &proc[NPROC]; p++)
    8000234c:	0000f497          	auipc	s1,0xf
    80002350:	dc448493          	addi	s1,s1,-572 # 80011110 <proc>
    {
        if (p != myproc())
        {
            acquire(&p->lock);
            if (p->state == SLEEPING && p->chan == chan)
    80002354:	4989                	li	s3,2
            {
                p->state = RUNNABLE;
    80002356:	4a8d                	li	s5,3
    for (p = proc; p < &proc[NPROC]; p++)
    80002358:	00014917          	auipc	s2,0x14
    8000235c:	7b890913          	addi	s2,s2,1976 # 80016b10 <tickslock>
    80002360:	a821                	j	80002378 <wakeup+0x40>
                p->state = RUNNABLE;
    80002362:	0154ac23          	sw	s5,24(s1)
            }
            release(&p->lock);
    80002366:	8526                	mv	a0,s1
    80002368:	fffff097          	auipc	ra,0xfffff
    8000236c:	9e2080e7          	jalr	-1566(ra) # 80000d4a <release>
    for (p = proc; p < &proc[NPROC]; p++)
    80002370:	16848493          	addi	s1,s1,360
    80002374:	03248463          	beq	s1,s2,8000239c <wakeup+0x64>
        if (p != myproc())
    80002378:	fffff097          	auipc	ra,0xfffff
    8000237c:	7f8080e7          	jalr	2040(ra) # 80001b70 <myproc>
    80002380:	fea488e3          	beq	s1,a0,80002370 <wakeup+0x38>
            acquire(&p->lock);
    80002384:	8526                	mv	a0,s1
    80002386:	fffff097          	auipc	ra,0xfffff
    8000238a:	910080e7          	jalr	-1776(ra) # 80000c96 <acquire>
            if (p->state == SLEEPING && p->chan == chan)
    8000238e:	4c9c                	lw	a5,24(s1)
    80002390:	fd379be3          	bne	a5,s3,80002366 <wakeup+0x2e>
    80002394:	709c                	ld	a5,32(s1)
    80002396:	fd4798e3          	bne	a5,s4,80002366 <wakeup+0x2e>
    8000239a:	b7e1                	j	80002362 <wakeup+0x2a>
        }
    }
}
    8000239c:	70e2                	ld	ra,56(sp)
    8000239e:	7442                	ld	s0,48(sp)
    800023a0:	74a2                	ld	s1,40(sp)
    800023a2:	7902                	ld	s2,32(sp)
    800023a4:	69e2                	ld	s3,24(sp)
    800023a6:	6a42                	ld	s4,16(sp)
    800023a8:	6aa2                	ld	s5,8(sp)
    800023aa:	6121                	addi	sp,sp,64
    800023ac:	8082                	ret

00000000800023ae <reparent>:
{
    800023ae:	7179                	addi	sp,sp,-48
    800023b0:	f406                	sd	ra,40(sp)
    800023b2:	f022                	sd	s0,32(sp)
    800023b4:	ec26                	sd	s1,24(sp)
    800023b6:	e84a                	sd	s2,16(sp)
    800023b8:	e44e                	sd	s3,8(sp)
    800023ba:	e052                	sd	s4,0(sp)
    800023bc:	1800                	addi	s0,sp,48
    800023be:	892a                	mv	s2,a0
    for (pp = proc; pp < &proc[NPROC]; pp++)
    800023c0:	0000f497          	auipc	s1,0xf
    800023c4:	d5048493          	addi	s1,s1,-688 # 80011110 <proc>
            pp->parent = initproc;
    800023c8:	00006a17          	auipc	s4,0x6
    800023cc:	6a0a0a13          	addi	s4,s4,1696 # 80008a68 <initproc>
    for (pp = proc; pp < &proc[NPROC]; pp++)
    800023d0:	00014997          	auipc	s3,0x14
    800023d4:	74098993          	addi	s3,s3,1856 # 80016b10 <tickslock>
    800023d8:	a029                	j	800023e2 <reparent+0x34>
    800023da:	16848493          	addi	s1,s1,360
    800023de:	01348d63          	beq	s1,s3,800023f8 <reparent+0x4a>
        if (pp->parent == p)
    800023e2:	7c9c                	ld	a5,56(s1)
    800023e4:	ff279be3          	bne	a5,s2,800023da <reparent+0x2c>
            pp->parent = initproc;
    800023e8:	000a3503          	ld	a0,0(s4)
    800023ec:	fc88                	sd	a0,56(s1)
            wakeup(initproc);
    800023ee:	00000097          	auipc	ra,0x0
    800023f2:	f4a080e7          	jalr	-182(ra) # 80002338 <wakeup>
    800023f6:	b7d5                	j	800023da <reparent+0x2c>
}
    800023f8:	70a2                	ld	ra,40(sp)
    800023fa:	7402                	ld	s0,32(sp)
    800023fc:	64e2                	ld	s1,24(sp)
    800023fe:	6942                	ld	s2,16(sp)
    80002400:	69a2                	ld	s3,8(sp)
    80002402:	6a02                	ld	s4,0(sp)
    80002404:	6145                	addi	sp,sp,48
    80002406:	8082                	ret

0000000080002408 <exit>:
{
    80002408:	7179                	addi	sp,sp,-48
    8000240a:	f406                	sd	ra,40(sp)
    8000240c:	f022                	sd	s0,32(sp)
    8000240e:	ec26                	sd	s1,24(sp)
    80002410:	e84a                	sd	s2,16(sp)
    80002412:	e44e                	sd	s3,8(sp)
    80002414:	e052                	sd	s4,0(sp)
    80002416:	1800                	addi	s0,sp,48
    80002418:	8a2a                	mv	s4,a0
    struct proc *p = myproc();
    8000241a:	fffff097          	auipc	ra,0xfffff
    8000241e:	756080e7          	jalr	1878(ra) # 80001b70 <myproc>
    80002422:	89aa                	mv	s3,a0
    if (p == initproc)
    80002424:	00006797          	auipc	a5,0x6
    80002428:	6447b783          	ld	a5,1604(a5) # 80008a68 <initproc>
    8000242c:	0d050493          	addi	s1,a0,208 # 80008358 <digits+0x308>
    80002430:	15050913          	addi	s2,a0,336
    80002434:	02a79363          	bne	a5,a0,8000245a <exit+0x52>
        panic("init exiting");
    80002438:	00006517          	auipc	a0,0x6
    8000243c:	e6850513          	addi	a0,a0,-408 # 800082a0 <digits+0x250>
    80002440:	ffffe097          	auipc	ra,0xffffe
    80002444:	0e8080e7          	jalr	232(ra) # 80000528 <panic>
            fileclose(f);
    80002448:	00002097          	auipc	ra,0x2
    8000244c:	572080e7          	jalr	1394(ra) # 800049ba <fileclose>
            p->ofile[fd] = 0;
    80002450:	0004b023          	sd	zero,0(s1)
    for (int fd = 0; fd < NOFILE; fd++)
    80002454:	04a1                	addi	s1,s1,8
    80002456:	01248563          	beq	s1,s2,80002460 <exit+0x58>
        if (p->ofile[fd])
    8000245a:	6088                	ld	a0,0(s1)
    8000245c:	f575                	bnez	a0,80002448 <exit+0x40>
    8000245e:	bfdd                	j	80002454 <exit+0x4c>
    begin_op();
    80002460:	00002097          	auipc	ra,0x2
    80002464:	08e080e7          	jalr	142(ra) # 800044ee <begin_op>
    iput(p->cwd);
    80002468:	1509b503          	ld	a0,336(s3)
    8000246c:	00002097          	auipc	ra,0x2
    80002470:	87a080e7          	jalr	-1926(ra) # 80003ce6 <iput>
    end_op();
    80002474:	00002097          	auipc	ra,0x2
    80002478:	0fa080e7          	jalr	250(ra) # 8000456e <end_op>
    p->cwd = 0;
    8000247c:	1409b823          	sd	zero,336(s3)
    acquire(&wait_lock);
    80002480:	0000f497          	auipc	s1,0xf
    80002484:	c7848493          	addi	s1,s1,-904 # 800110f8 <wait_lock>
    80002488:	8526                	mv	a0,s1
    8000248a:	fffff097          	auipc	ra,0xfffff
    8000248e:	80c080e7          	jalr	-2036(ra) # 80000c96 <acquire>
    reparent(p);
    80002492:	854e                	mv	a0,s3
    80002494:	00000097          	auipc	ra,0x0
    80002498:	f1a080e7          	jalr	-230(ra) # 800023ae <reparent>
    wakeup(p->parent);
    8000249c:	0389b503          	ld	a0,56(s3)
    800024a0:	00000097          	auipc	ra,0x0
    800024a4:	e98080e7          	jalr	-360(ra) # 80002338 <wakeup>
    acquire(&p->lock);
    800024a8:	854e                	mv	a0,s3
    800024aa:	ffffe097          	auipc	ra,0xffffe
    800024ae:	7ec080e7          	jalr	2028(ra) # 80000c96 <acquire>
    p->xstate = status;
    800024b2:	0349a623          	sw	s4,44(s3)
    p->state = ZOMBIE;
    800024b6:	4795                	li	a5,5
    800024b8:	00f9ac23          	sw	a5,24(s3)
    release(&wait_lock);
    800024bc:	8526                	mv	a0,s1
    800024be:	fffff097          	auipc	ra,0xfffff
    800024c2:	88c080e7          	jalr	-1908(ra) # 80000d4a <release>
    sched();
    800024c6:	00000097          	auipc	ra,0x0
    800024ca:	d04080e7          	jalr	-764(ra) # 800021ca <sched>
    panic("zombie exit");
    800024ce:	00006517          	auipc	a0,0x6
    800024d2:	de250513          	addi	a0,a0,-542 # 800082b0 <digits+0x260>
    800024d6:	ffffe097          	auipc	ra,0xffffe
    800024da:	052080e7          	jalr	82(ra) # 80000528 <panic>

00000000800024de <kill>:

// Kill the process with the given pid.
// The victim won't exit until it tries to return
// to user space (see usertrap() in trap.c).
int kill(int pid)
{
    800024de:	7179                	addi	sp,sp,-48
    800024e0:	f406                	sd	ra,40(sp)
    800024e2:	f022                	sd	s0,32(sp)
    800024e4:	ec26                	sd	s1,24(sp)
    800024e6:	e84a                	sd	s2,16(sp)
    800024e8:	e44e                	sd	s3,8(sp)
    800024ea:	1800                	addi	s0,sp,48
    800024ec:	892a                	mv	s2,a0
    struct proc *p;

    for (p = proc; p < &proc[NPROC]; p++)
    800024ee:	0000f497          	auipc	s1,0xf
    800024f2:	c2248493          	addi	s1,s1,-990 # 80011110 <proc>
    800024f6:	00014997          	auipc	s3,0x14
    800024fa:	61a98993          	addi	s3,s3,1562 # 80016b10 <tickslock>
    {
        acquire(&p->lock);
    800024fe:	8526                	mv	a0,s1
    80002500:	ffffe097          	auipc	ra,0xffffe
    80002504:	796080e7          	jalr	1942(ra) # 80000c96 <acquire>
        if (p->pid == pid)
    80002508:	589c                	lw	a5,48(s1)
    8000250a:	01278d63          	beq	a5,s2,80002524 <kill+0x46>
                p->state = RUNNABLE;
            }
            release(&p->lock);
            return 0;
        }
        release(&p->lock);
    8000250e:	8526                	mv	a0,s1
    80002510:	fffff097          	auipc	ra,0xfffff
    80002514:	83a080e7          	jalr	-1990(ra) # 80000d4a <release>
    for (p = proc; p < &proc[NPROC]; p++)
    80002518:	16848493          	addi	s1,s1,360
    8000251c:	ff3491e3          	bne	s1,s3,800024fe <kill+0x20>
    }
    return -1;
    80002520:	557d                	li	a0,-1
    80002522:	a829                	j	8000253c <kill+0x5e>
            p->killed = 1;
    80002524:	4785                	li	a5,1
    80002526:	d49c                	sw	a5,40(s1)
            if (p->state == SLEEPING)
    80002528:	4c98                	lw	a4,24(s1)
    8000252a:	4789                	li	a5,2
    8000252c:	00f70f63          	beq	a4,a5,8000254a <kill+0x6c>
            release(&p->lock);
    80002530:	8526                	mv	a0,s1
    80002532:	fffff097          	auipc	ra,0xfffff
    80002536:	818080e7          	jalr	-2024(ra) # 80000d4a <release>
            return 0;
    8000253a:	4501                	li	a0,0
}
    8000253c:	70a2                	ld	ra,40(sp)
    8000253e:	7402                	ld	s0,32(sp)
    80002540:	64e2                	ld	s1,24(sp)
    80002542:	6942                	ld	s2,16(sp)
    80002544:	69a2                	ld	s3,8(sp)
    80002546:	6145                	addi	sp,sp,48
    80002548:	8082                	ret
                p->state = RUNNABLE;
    8000254a:	478d                	li	a5,3
    8000254c:	cc9c                	sw	a5,24(s1)
    8000254e:	b7cd                	j	80002530 <kill+0x52>

0000000080002550 <setkilled>:

void setkilled(struct proc *p)
{
    80002550:	1101                	addi	sp,sp,-32
    80002552:	ec06                	sd	ra,24(sp)
    80002554:	e822                	sd	s0,16(sp)
    80002556:	e426                	sd	s1,8(sp)
    80002558:	1000                	addi	s0,sp,32
    8000255a:	84aa                	mv	s1,a0
    acquire(&p->lock);
    8000255c:	ffffe097          	auipc	ra,0xffffe
    80002560:	73a080e7          	jalr	1850(ra) # 80000c96 <acquire>
    p->killed = 1;
    80002564:	4785                	li	a5,1
    80002566:	d49c                	sw	a5,40(s1)
    release(&p->lock);
    80002568:	8526                	mv	a0,s1
    8000256a:	ffffe097          	auipc	ra,0xffffe
    8000256e:	7e0080e7          	jalr	2016(ra) # 80000d4a <release>
}
    80002572:	60e2                	ld	ra,24(sp)
    80002574:	6442                	ld	s0,16(sp)
    80002576:	64a2                	ld	s1,8(sp)
    80002578:	6105                	addi	sp,sp,32
    8000257a:	8082                	ret

000000008000257c <killed>:

int killed(struct proc *p)
{
    8000257c:	1101                	addi	sp,sp,-32
    8000257e:	ec06                	sd	ra,24(sp)
    80002580:	e822                	sd	s0,16(sp)
    80002582:	e426                	sd	s1,8(sp)
    80002584:	e04a                	sd	s2,0(sp)
    80002586:	1000                	addi	s0,sp,32
    80002588:	84aa                	mv	s1,a0
    int k;

    acquire(&p->lock);
    8000258a:	ffffe097          	auipc	ra,0xffffe
    8000258e:	70c080e7          	jalr	1804(ra) # 80000c96 <acquire>
    k = p->killed;
    80002592:	0284a903          	lw	s2,40(s1)
    release(&p->lock);
    80002596:	8526                	mv	a0,s1
    80002598:	ffffe097          	auipc	ra,0xffffe
    8000259c:	7b2080e7          	jalr	1970(ra) # 80000d4a <release>
    return k;
}
    800025a0:	854a                	mv	a0,s2
    800025a2:	60e2                	ld	ra,24(sp)
    800025a4:	6442                	ld	s0,16(sp)
    800025a6:	64a2                	ld	s1,8(sp)
    800025a8:	6902                	ld	s2,0(sp)
    800025aa:	6105                	addi	sp,sp,32
    800025ac:	8082                	ret

00000000800025ae <wait>:
{
    800025ae:	715d                	addi	sp,sp,-80
    800025b0:	e486                	sd	ra,72(sp)
    800025b2:	e0a2                	sd	s0,64(sp)
    800025b4:	fc26                	sd	s1,56(sp)
    800025b6:	f84a                	sd	s2,48(sp)
    800025b8:	f44e                	sd	s3,40(sp)
    800025ba:	f052                	sd	s4,32(sp)
    800025bc:	ec56                	sd	s5,24(sp)
    800025be:	e85a                	sd	s6,16(sp)
    800025c0:	e45e                	sd	s7,8(sp)
    800025c2:	e062                	sd	s8,0(sp)
    800025c4:	0880                	addi	s0,sp,80
    800025c6:	8b2a                	mv	s6,a0
    struct proc *p = myproc();
    800025c8:	fffff097          	auipc	ra,0xfffff
    800025cc:	5a8080e7          	jalr	1448(ra) # 80001b70 <myproc>
    800025d0:	892a                	mv	s2,a0
    acquire(&wait_lock);
    800025d2:	0000f517          	auipc	a0,0xf
    800025d6:	b2650513          	addi	a0,a0,-1242 # 800110f8 <wait_lock>
    800025da:	ffffe097          	auipc	ra,0xffffe
    800025de:	6bc080e7          	jalr	1724(ra) # 80000c96 <acquire>
        havekids = 0;
    800025e2:	4b81                	li	s7,0
                if (pp->state == ZOMBIE)
    800025e4:	4a15                	li	s4,5
        for (pp = proc; pp < &proc[NPROC]; pp++)
    800025e6:	00014997          	auipc	s3,0x14
    800025ea:	52a98993          	addi	s3,s3,1322 # 80016b10 <tickslock>
                havekids = 1;
    800025ee:	4a85                	li	s5,1
        sleep(p, &wait_lock); // DOC: wait-sleep
    800025f0:	0000fc17          	auipc	s8,0xf
    800025f4:	b08c0c13          	addi	s8,s8,-1272 # 800110f8 <wait_lock>
        havekids = 0;
    800025f8:	875e                	mv	a4,s7
        for (pp = proc; pp < &proc[NPROC]; pp++)
    800025fa:	0000f497          	auipc	s1,0xf
    800025fe:	b1648493          	addi	s1,s1,-1258 # 80011110 <proc>
    80002602:	a0bd                	j	80002670 <wait+0xc2>
                    pid = pp->pid;
    80002604:	0304a983          	lw	s3,48(s1)
                    if (addr != 0 && copyout(p->pagetable, addr, (char *)&pp->xstate,
    80002608:	000b0e63          	beqz	s6,80002624 <wait+0x76>
    8000260c:	4691                	li	a3,4
    8000260e:	02c48613          	addi	a2,s1,44
    80002612:	85da                	mv	a1,s6
    80002614:	05093503          	ld	a0,80(s2)
    80002618:	fffff097          	auipc	ra,0xfffff
    8000261c:	118080e7          	jalr	280(ra) # 80001730 <copyout>
    80002620:	02054563          	bltz	a0,8000264a <wait+0x9c>
                    freeproc(pp);
    80002624:	8526                	mv	a0,s1
    80002626:	fffff097          	auipc	ra,0xfffff
    8000262a:	6fc080e7          	jalr	1788(ra) # 80001d22 <freeproc>
                    release(&pp->lock);
    8000262e:	8526                	mv	a0,s1
    80002630:	ffffe097          	auipc	ra,0xffffe
    80002634:	71a080e7          	jalr	1818(ra) # 80000d4a <release>
                    release(&wait_lock);
    80002638:	0000f517          	auipc	a0,0xf
    8000263c:	ac050513          	addi	a0,a0,-1344 # 800110f8 <wait_lock>
    80002640:	ffffe097          	auipc	ra,0xffffe
    80002644:	70a080e7          	jalr	1802(ra) # 80000d4a <release>
                    return pid;
    80002648:	a0b5                	j	800026b4 <wait+0x106>
                        release(&pp->lock);
    8000264a:	8526                	mv	a0,s1
    8000264c:	ffffe097          	auipc	ra,0xffffe
    80002650:	6fe080e7          	jalr	1790(ra) # 80000d4a <release>
                        release(&wait_lock);
    80002654:	0000f517          	auipc	a0,0xf
    80002658:	aa450513          	addi	a0,a0,-1372 # 800110f8 <wait_lock>
    8000265c:	ffffe097          	auipc	ra,0xffffe
    80002660:	6ee080e7          	jalr	1774(ra) # 80000d4a <release>
                        return -1;
    80002664:	59fd                	li	s3,-1
    80002666:	a0b9                	j	800026b4 <wait+0x106>
        for (pp = proc; pp < &proc[NPROC]; pp++)
    80002668:	16848493          	addi	s1,s1,360
    8000266c:	03348463          	beq	s1,s3,80002694 <wait+0xe6>
            if (pp->parent == p)
    80002670:	7c9c                	ld	a5,56(s1)
    80002672:	ff279be3          	bne	a5,s2,80002668 <wait+0xba>
                acquire(&pp->lock);
    80002676:	8526                	mv	a0,s1
    80002678:	ffffe097          	auipc	ra,0xffffe
    8000267c:	61e080e7          	jalr	1566(ra) # 80000c96 <acquire>
                if (pp->state == ZOMBIE)
    80002680:	4c9c                	lw	a5,24(s1)
    80002682:	f94781e3          	beq	a5,s4,80002604 <wait+0x56>
                release(&pp->lock);
    80002686:	8526                	mv	a0,s1
    80002688:	ffffe097          	auipc	ra,0xffffe
    8000268c:	6c2080e7          	jalr	1730(ra) # 80000d4a <release>
                havekids = 1;
    80002690:	8756                	mv	a4,s5
    80002692:	bfd9                	j	80002668 <wait+0xba>
        if (!havekids || killed(p))
    80002694:	c719                	beqz	a4,800026a2 <wait+0xf4>
    80002696:	854a                	mv	a0,s2
    80002698:	00000097          	auipc	ra,0x0
    8000269c:	ee4080e7          	jalr	-284(ra) # 8000257c <killed>
    800026a0:	c51d                	beqz	a0,800026ce <wait+0x120>
            release(&wait_lock);
    800026a2:	0000f517          	auipc	a0,0xf
    800026a6:	a5650513          	addi	a0,a0,-1450 # 800110f8 <wait_lock>
    800026aa:	ffffe097          	auipc	ra,0xffffe
    800026ae:	6a0080e7          	jalr	1696(ra) # 80000d4a <release>
            return -1;
    800026b2:	59fd                	li	s3,-1
}
    800026b4:	854e                	mv	a0,s3
    800026b6:	60a6                	ld	ra,72(sp)
    800026b8:	6406                	ld	s0,64(sp)
    800026ba:	74e2                	ld	s1,56(sp)
    800026bc:	7942                	ld	s2,48(sp)
    800026be:	79a2                	ld	s3,40(sp)
    800026c0:	7a02                	ld	s4,32(sp)
    800026c2:	6ae2                	ld	s5,24(sp)
    800026c4:	6b42                	ld	s6,16(sp)
    800026c6:	6ba2                	ld	s7,8(sp)
    800026c8:	6c02                	ld	s8,0(sp)
    800026ca:	6161                	addi	sp,sp,80
    800026cc:	8082                	ret
        sleep(p, &wait_lock); // DOC: wait-sleep
    800026ce:	85e2                	mv	a1,s8
    800026d0:	854a                	mv	a0,s2
    800026d2:	00000097          	auipc	ra,0x0
    800026d6:	c02080e7          	jalr	-1022(ra) # 800022d4 <sleep>
        havekids = 0;
    800026da:	bf39                	j	800025f8 <wait+0x4a>

00000000800026dc <either_copyout>:

// Copy to either a user address, or kernel address,
// depending on usr_dst.
// Returns 0 on success, -1 on error.
int either_copyout(int user_dst, uint64 dst, void *src, uint64 len)
{
    800026dc:	7179                	addi	sp,sp,-48
    800026de:	f406                	sd	ra,40(sp)
    800026e0:	f022                	sd	s0,32(sp)
    800026e2:	ec26                	sd	s1,24(sp)
    800026e4:	e84a                	sd	s2,16(sp)
    800026e6:	e44e                	sd	s3,8(sp)
    800026e8:	e052                	sd	s4,0(sp)
    800026ea:	1800                	addi	s0,sp,48
    800026ec:	84aa                	mv	s1,a0
    800026ee:	892e                	mv	s2,a1
    800026f0:	89b2                	mv	s3,a2
    800026f2:	8a36                	mv	s4,a3
    struct proc *p = myproc();
    800026f4:	fffff097          	auipc	ra,0xfffff
    800026f8:	47c080e7          	jalr	1148(ra) # 80001b70 <myproc>
    if (user_dst)
    800026fc:	c08d                	beqz	s1,8000271e <either_copyout+0x42>
    {
        return copyout(p->pagetable, dst, src, len);
    800026fe:	86d2                	mv	a3,s4
    80002700:	864e                	mv	a2,s3
    80002702:	85ca                	mv	a1,s2
    80002704:	6928                	ld	a0,80(a0)
    80002706:	fffff097          	auipc	ra,0xfffff
    8000270a:	02a080e7          	jalr	42(ra) # 80001730 <copyout>
    else
    {
        memmove((char *)dst, src, len);
        return 0;
    }
}
    8000270e:	70a2                	ld	ra,40(sp)
    80002710:	7402                	ld	s0,32(sp)
    80002712:	64e2                	ld	s1,24(sp)
    80002714:	6942                	ld	s2,16(sp)
    80002716:	69a2                	ld	s3,8(sp)
    80002718:	6a02                	ld	s4,0(sp)
    8000271a:	6145                	addi	sp,sp,48
    8000271c:	8082                	ret
        memmove((char *)dst, src, len);
    8000271e:	000a061b          	sext.w	a2,s4
    80002722:	85ce                	mv	a1,s3
    80002724:	854a                	mv	a0,s2
    80002726:	ffffe097          	auipc	ra,0xffffe
    8000272a:	6cc080e7          	jalr	1740(ra) # 80000df2 <memmove>
        return 0;
    8000272e:	8526                	mv	a0,s1
    80002730:	bff9                	j	8000270e <either_copyout+0x32>

0000000080002732 <either_copyin>:

// Copy from either a user address, or kernel address,
// depending on usr_src.
// Returns 0 on success, -1 on error.
int either_copyin(void *dst, int user_src, uint64 src, uint64 len)
{
    80002732:	7179                	addi	sp,sp,-48
    80002734:	f406                	sd	ra,40(sp)
    80002736:	f022                	sd	s0,32(sp)
    80002738:	ec26                	sd	s1,24(sp)
    8000273a:	e84a                	sd	s2,16(sp)
    8000273c:	e44e                	sd	s3,8(sp)
    8000273e:	e052                	sd	s4,0(sp)
    80002740:	1800                	addi	s0,sp,48
    80002742:	892a                	mv	s2,a0
    80002744:	84ae                	mv	s1,a1
    80002746:	89b2                	mv	s3,a2
    80002748:	8a36                	mv	s4,a3
    struct proc *p = myproc();
    8000274a:	fffff097          	auipc	ra,0xfffff
    8000274e:	426080e7          	jalr	1062(ra) # 80001b70 <myproc>
    if (user_src)
    80002752:	c08d                	beqz	s1,80002774 <either_copyin+0x42>
    {
        return copyin(p->pagetable, dst, src, len);
    80002754:	86d2                	mv	a3,s4
    80002756:	864e                	mv	a2,s3
    80002758:	85ca                	mv	a1,s2
    8000275a:	6928                	ld	a0,80(a0)
    8000275c:	fffff097          	auipc	ra,0xfffff
    80002760:	060080e7          	jalr	96(ra) # 800017bc <copyin>
    else
    {
        memmove(dst, (char *)src, len);
        return 0;
    }
}
    80002764:	70a2                	ld	ra,40(sp)
    80002766:	7402                	ld	s0,32(sp)
    80002768:	64e2                	ld	s1,24(sp)
    8000276a:	6942                	ld	s2,16(sp)
    8000276c:	69a2                	ld	s3,8(sp)
    8000276e:	6a02                	ld	s4,0(sp)
    80002770:	6145                	addi	sp,sp,48
    80002772:	8082                	ret
        memmove(dst, (char *)src, len);
    80002774:	000a061b          	sext.w	a2,s4
    80002778:	85ce                	mv	a1,s3
    8000277a:	854a                	mv	a0,s2
    8000277c:	ffffe097          	auipc	ra,0xffffe
    80002780:	676080e7          	jalr	1654(ra) # 80000df2 <memmove>
        return 0;
    80002784:	8526                	mv	a0,s1
    80002786:	bff9                	j	80002764 <either_copyin+0x32>

0000000080002788 <procdump>:

// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void procdump(void)
{
    80002788:	715d                	addi	sp,sp,-80
    8000278a:	e486                	sd	ra,72(sp)
    8000278c:	e0a2                	sd	s0,64(sp)
    8000278e:	fc26                	sd	s1,56(sp)
    80002790:	f84a                	sd	s2,48(sp)
    80002792:	f44e                	sd	s3,40(sp)
    80002794:	f052                	sd	s4,32(sp)
    80002796:	ec56                	sd	s5,24(sp)
    80002798:	e85a                	sd	s6,16(sp)
    8000279a:	e45e                	sd	s7,8(sp)
    8000279c:	0880                	addi	s0,sp,80
        [RUNNING] "run   ",
        [ZOMBIE] "zombie"};
    struct proc *p;
    char *state;

    printf("\n");
    8000279e:	00006517          	auipc	a0,0x6
    800027a2:	8ea50513          	addi	a0,a0,-1814 # 80008088 <digits+0x38>
    800027a6:	ffffe097          	auipc	ra,0xffffe
    800027aa:	dde080e7          	jalr	-546(ra) # 80000584 <printf>
    for (p = proc; p < &proc[NPROC]; p++)
    800027ae:	0000f497          	auipc	s1,0xf
    800027b2:	aba48493          	addi	s1,s1,-1350 # 80011268 <proc+0x158>
    800027b6:	00014917          	auipc	s2,0x14
    800027ba:	4b290913          	addi	s2,s2,1202 # 80016c68 <bcache+0x140>
    {
        if (p->state == UNUSED)
            continue;
        if (p->state >= 0 && p->state < NELEM(states) && states[p->state])
    800027be:	4b15                	li	s6,5
            state = states[p->state];
        else
            state = "???";
    800027c0:	00006997          	auipc	s3,0x6
    800027c4:	b0098993          	addi	s3,s3,-1280 # 800082c0 <digits+0x270>
        printf("%d <%s %s", p->pid, state, p->name);
    800027c8:	00006a97          	auipc	s5,0x6
    800027cc:	b00a8a93          	addi	s5,s5,-1280 # 800082c8 <digits+0x278>
        printf("\n");
    800027d0:	00006a17          	auipc	s4,0x6
    800027d4:	8b8a0a13          	addi	s4,s4,-1864 # 80008088 <digits+0x38>
        if (p->state >= 0 && p->state < NELEM(states) && states[p->state])
    800027d8:	00006b97          	auipc	s7,0x6
    800027dc:	c10b8b93          	addi	s7,s7,-1008 # 800083e8 <states.1774>
    800027e0:	a00d                	j	80002802 <procdump+0x7a>
        printf("%d <%s %s", p->pid, state, p->name);
    800027e2:	ed86a583          	lw	a1,-296(a3)
    800027e6:	8556                	mv	a0,s5
    800027e8:	ffffe097          	auipc	ra,0xffffe
    800027ec:	d9c080e7          	jalr	-612(ra) # 80000584 <printf>
        printf("\n");
    800027f0:	8552                	mv	a0,s4
    800027f2:	ffffe097          	auipc	ra,0xffffe
    800027f6:	d92080e7          	jalr	-622(ra) # 80000584 <printf>
    for (p = proc; p < &proc[NPROC]; p++)
    800027fa:	16848493          	addi	s1,s1,360
    800027fe:	03248163          	beq	s1,s2,80002820 <procdump+0x98>
        if (p->state == UNUSED)
    80002802:	86a6                	mv	a3,s1
    80002804:	ec04a783          	lw	a5,-320(s1)
    80002808:	dbed                	beqz	a5,800027fa <procdump+0x72>
            state = "???";
    8000280a:	864e                	mv	a2,s3
        if (p->state >= 0 && p->state < NELEM(states) && states[p->state])
    8000280c:	fcfb6be3          	bltu	s6,a5,800027e2 <procdump+0x5a>
    80002810:	1782                	slli	a5,a5,0x20
    80002812:	9381                	srli	a5,a5,0x20
    80002814:	078e                	slli	a5,a5,0x3
    80002816:	97de                	add	a5,a5,s7
    80002818:	6390                	ld	a2,0(a5)
    8000281a:	f661                	bnez	a2,800027e2 <procdump+0x5a>
            state = "???";
    8000281c:	864e                	mv	a2,s3
    8000281e:	b7d1                	j	800027e2 <procdump+0x5a>
    }
}
    80002820:	60a6                	ld	ra,72(sp)
    80002822:	6406                	ld	s0,64(sp)
    80002824:	74e2                	ld	s1,56(sp)
    80002826:	7942                	ld	s2,48(sp)
    80002828:	79a2                	ld	s3,40(sp)
    8000282a:	7a02                	ld	s4,32(sp)
    8000282c:	6ae2                	ld	s5,24(sp)
    8000282e:	6b42                	ld	s6,16(sp)
    80002830:	6ba2                	ld	s7,8(sp)
    80002832:	6161                	addi	sp,sp,80
    80002834:	8082                	ret

0000000080002836 <schedls>:

void schedls()
{
    80002836:	1141                	addi	sp,sp,-16
    80002838:	e406                	sd	ra,8(sp)
    8000283a:	e022                	sd	s0,0(sp)
    8000283c:	0800                	addi	s0,sp,16
    printf("[ ]\tScheduler Name\tScheduler ID\n");
    8000283e:	00006517          	auipc	a0,0x6
    80002842:	a9a50513          	addi	a0,a0,-1382 # 800082d8 <digits+0x288>
    80002846:	ffffe097          	auipc	ra,0xffffe
    8000284a:	d3e080e7          	jalr	-706(ra) # 80000584 <printf>
    printf("====================================\n");
    8000284e:	00006517          	auipc	a0,0x6
    80002852:	ab250513          	addi	a0,a0,-1358 # 80008300 <digits+0x2b0>
    80002856:	ffffe097          	auipc	ra,0xffffe
    8000285a:	d2e080e7          	jalr	-722(ra) # 80000584 <printf>
    for (int i = 0; i < SCHEDC; i++)
    {
        if (available_schedulers[i].impl == sched_pointer)
    8000285e:	00006717          	auipc	a4,0x6
    80002862:	19a73703          	ld	a4,410(a4) # 800089f8 <available_schedulers+0x10>
    80002866:	00006797          	auipc	a5,0x6
    8000286a:	1327b783          	ld	a5,306(a5) # 80008998 <sched_pointer>
    8000286e:	04f70663          	beq	a4,a5,800028ba <schedls+0x84>
        {
            printf("[*]\t");
        }
        else
        {
            printf("   \t");
    80002872:	00006517          	auipc	a0,0x6
    80002876:	abe50513          	addi	a0,a0,-1346 # 80008330 <digits+0x2e0>
    8000287a:	ffffe097          	auipc	ra,0xffffe
    8000287e:	d0a080e7          	jalr	-758(ra) # 80000584 <printf>
        }
        printf("%s\t%d\n", available_schedulers[i].name, available_schedulers[i].id);
    80002882:	00006617          	auipc	a2,0x6
    80002886:	17e62603          	lw	a2,382(a2) # 80008a00 <available_schedulers+0x18>
    8000288a:	00006597          	auipc	a1,0x6
    8000288e:	15e58593          	addi	a1,a1,350 # 800089e8 <available_schedulers>
    80002892:	00006517          	auipc	a0,0x6
    80002896:	aa650513          	addi	a0,a0,-1370 # 80008338 <digits+0x2e8>
    8000289a:	ffffe097          	auipc	ra,0xffffe
    8000289e:	cea080e7          	jalr	-790(ra) # 80000584 <printf>
    }
    printf("\n*: current scheduler\n\n");
    800028a2:	00006517          	auipc	a0,0x6
    800028a6:	a9e50513          	addi	a0,a0,-1378 # 80008340 <digits+0x2f0>
    800028aa:	ffffe097          	auipc	ra,0xffffe
    800028ae:	cda080e7          	jalr	-806(ra) # 80000584 <printf>
}
    800028b2:	60a2                	ld	ra,8(sp)
    800028b4:	6402                	ld	s0,0(sp)
    800028b6:	0141                	addi	sp,sp,16
    800028b8:	8082                	ret
            printf("[*]\t");
    800028ba:	00006517          	auipc	a0,0x6
    800028be:	a6e50513          	addi	a0,a0,-1426 # 80008328 <digits+0x2d8>
    800028c2:	ffffe097          	auipc	ra,0xffffe
    800028c6:	cc2080e7          	jalr	-830(ra) # 80000584 <printf>
    800028ca:	bf65                	j	80002882 <schedls+0x4c>

00000000800028cc <schedset>:

void schedset(int id)
{
    800028cc:	1141                	addi	sp,sp,-16
    800028ce:	e406                	sd	ra,8(sp)
    800028d0:	e022                	sd	s0,0(sp)
    800028d2:	0800                	addi	s0,sp,16
    if (id < 0 || SCHEDC <= id)
    800028d4:	e90d                	bnez	a0,80002906 <schedset+0x3a>
    {
        printf("Scheduler unchanged: ID out of range\n");
        return;
    }
    sched_pointer = available_schedulers[id].impl;
    800028d6:	00006797          	auipc	a5,0x6
    800028da:	1227b783          	ld	a5,290(a5) # 800089f8 <available_schedulers+0x10>
    800028de:	00006717          	auipc	a4,0x6
    800028e2:	0af73d23          	sd	a5,186(a4) # 80008998 <sched_pointer>
    printf("Scheduler successfully changed to %s\n", available_schedulers[id].name);
    800028e6:	00006597          	auipc	a1,0x6
    800028ea:	10258593          	addi	a1,a1,258 # 800089e8 <available_schedulers>
    800028ee:	00006517          	auipc	a0,0x6
    800028f2:	a9250513          	addi	a0,a0,-1390 # 80008380 <digits+0x330>
    800028f6:	ffffe097          	auipc	ra,0xffffe
    800028fa:	c8e080e7          	jalr	-882(ra) # 80000584 <printf>
}
    800028fe:	60a2                	ld	ra,8(sp)
    80002900:	6402                	ld	s0,0(sp)
    80002902:	0141                	addi	sp,sp,16
    80002904:	8082                	ret
        printf("Scheduler unchanged: ID out of range\n");
    80002906:	00006517          	auipc	a0,0x6
    8000290a:	a5250513          	addi	a0,a0,-1454 # 80008358 <digits+0x308>
    8000290e:	ffffe097          	auipc	ra,0xffffe
    80002912:	c76080e7          	jalr	-906(ra) # 80000584 <printf>
        return;
    80002916:	b7e5                	j	800028fe <schedset+0x32>

0000000080002918 <va2pa>:


// Made by me

void va2pa(uint64 addr, int pid) 
{
    80002918:	7179                	addi	sp,sp,-48
    8000291a:	f406                	sd	ra,40(sp)
    8000291c:	f022                	sd	s0,32(sp)
    8000291e:	ec26                	sd	s1,24(sp)
    80002920:	e84a                	sd	s2,16(sp)
    80002922:	1800                	addi	s0,sp,48
    uint64 VA = addr;
    80002924:	fca43c23          	sd	a0,-40(s0)
    int PID = pid;
    80002928:	fcb42a23          	sw	a1,-44(s0)
    argaddr(0, &VA);
    8000292c:	fd840593          	addi	a1,s0,-40
    80002930:	4501                	li	a0,0
    80002932:	00000097          	auipc	ra,0x0
    80002936:	5da080e7          	jalr	1498(ra) # 80002f0c <argaddr>
    argint(1, &PID);
    8000293a:	fd440593          	addi	a1,s0,-44
    8000293e:	4505                	li	a0,1
    80002940:	00000097          	auipc	ra,0x0
    80002944:	5ac080e7          	jalr	1452(ra) # 80002eec <argint>

    struct proc *p;
    int validPID = 0;

    if (PID != 0)
    80002948:	fd442783          	lw	a5,-44(s0)
    8000294c:	cf85                	beqz	a5,80002984 <va2pa+0x6c>
    {
        for (p = proc; p < &proc[NPROC]; p++)
    8000294e:	0000e497          	auipc	s1,0xe
    80002952:	7c248493          	addi	s1,s1,1986 # 80011110 <proc>
    80002956:	00014917          	auipc	s2,0x14
    8000295a:	1ba90913          	addi	s2,s2,442 # 80016b10 <tickslock>
        {
            acquire(&p->lock);
    8000295e:	8526                	mv	a0,s1
    80002960:	ffffe097          	auipc	ra,0xffffe
    80002964:	336080e7          	jalr	822(ra) # 80000c96 <acquire>
            if (p->pid == PID)
    80002968:	5898                	lw	a4,48(s1)
    8000296a:	fd442783          	lw	a5,-44(s0)
    8000296e:	02f70163          	beq	a4,a5,80002990 <va2pa+0x78>
            {
                release(&p->lock);
                validPID = 1;
                break;
            }
            release(&p->lock);
    80002972:	8526                	mv	a0,s1
    80002974:	ffffe097          	auipc	ra,0xffffe
    80002978:	3d6080e7          	jalr	982(ra) # 80000d4a <release>
        for (p = proc; p < &proc[NPROC]; p++)
    8000297c:	16848493          	addi	s1,s1,360
    80002980:	fd249fe3          	bne	s1,s2,8000295e <va2pa+0x46>
        }
    }
    if (validPID == 0)
    {
        p = myproc();
    80002984:	fffff097          	auipc	ra,0xfffff
    80002988:	1ec080e7          	jalr	492(ra) # 80001b70 <myproc>
    8000298c:	84aa                	mv	s1,a0
    8000298e:	a031                	j	8000299a <va2pa+0x82>
                release(&p->lock);
    80002990:	8526                	mv	a0,s1
    80002992:	ffffe097          	auipc	ra,0xffffe
    80002996:	3b8080e7          	jalr	952(ra) # 80000d4a <release>
    }

    pagetable_t pagetable = p->pagetable;
    uint64 PA = walkaddr(pagetable, VA);
    8000299a:	fd843583          	ld	a1,-40(s0)
    8000299e:	68a8                	ld	a0,80(s1)
    800029a0:	ffffe097          	auipc	ra,0xffffe
    800029a4:	784080e7          	jalr	1924(ra) # 80001124 <walkaddr>
    PA |= (0xFFF & VA);
    800029a8:	fd843583          	ld	a1,-40(s0)
    800029ac:	15d2                	slli	a1,a1,0x34
    800029ae:	91d1                	srli	a1,a1,0x34
    800029b0:	8dc9                	or	a1,a1,a0

    if (PA == 0)
    800029b2:	ed99                	bnez	a1,800029d0 <va2pa+0xb8>
    {
        printf("0x0");
    800029b4:	00006517          	auipc	a0,0x6
    800029b8:	9f450513          	addi	a0,a0,-1548 # 800083a8 <digits+0x358>
    800029bc:	ffffe097          	auipc	ra,0xffffe
    800029c0:	bc8080e7          	jalr	-1080(ra) # 80000584 <printf>
    {
        printf("0x%x\n", PA);
    }


    800029c4:	70a2                	ld	ra,40(sp)
    800029c6:	7402                	ld	s0,32(sp)
    800029c8:	64e2                	ld	s1,24(sp)
    800029ca:	6942                	ld	s2,16(sp)
    800029cc:	6145                	addi	sp,sp,48
    800029ce:	8082                	ret
        printf("0x%x\n", PA);
    800029d0:	00006517          	auipc	a0,0x6
    800029d4:	9e050513          	addi	a0,a0,-1568 # 800083b0 <digits+0x360>
    800029d8:	ffffe097          	auipc	ra,0xffffe
    800029dc:	bac080e7          	jalr	-1108(ra) # 80000584 <printf>
    800029e0:	b7d5                	j	800029c4 <va2pa+0xac>

00000000800029e2 <swtch>:
    800029e2:	00153023          	sd	ra,0(a0)
    800029e6:	00253423          	sd	sp,8(a0)
    800029ea:	e900                	sd	s0,16(a0)
    800029ec:	ed04                	sd	s1,24(a0)
    800029ee:	03253023          	sd	s2,32(a0)
    800029f2:	03353423          	sd	s3,40(a0)
    800029f6:	03453823          	sd	s4,48(a0)
    800029fa:	03553c23          	sd	s5,56(a0)
    800029fe:	05653023          	sd	s6,64(a0)
    80002a02:	05753423          	sd	s7,72(a0)
    80002a06:	05853823          	sd	s8,80(a0)
    80002a0a:	05953c23          	sd	s9,88(a0)
    80002a0e:	07a53023          	sd	s10,96(a0)
    80002a12:	07b53423          	sd	s11,104(a0)
    80002a16:	0005b083          	ld	ra,0(a1)
    80002a1a:	0085b103          	ld	sp,8(a1)
    80002a1e:	6980                	ld	s0,16(a1)
    80002a20:	6d84                	ld	s1,24(a1)
    80002a22:	0205b903          	ld	s2,32(a1)
    80002a26:	0285b983          	ld	s3,40(a1)
    80002a2a:	0305ba03          	ld	s4,48(a1)
    80002a2e:	0385ba83          	ld	s5,56(a1)
    80002a32:	0405bb03          	ld	s6,64(a1)
    80002a36:	0485bb83          	ld	s7,72(a1)
    80002a3a:	0505bc03          	ld	s8,80(a1)
    80002a3e:	0585bc83          	ld	s9,88(a1)
    80002a42:	0605bd03          	ld	s10,96(a1)
    80002a46:	0685bd83          	ld	s11,104(a1)
    80002a4a:	8082                	ret

0000000080002a4c <trapinit>:

extern int devintr();

void
trapinit(void)
{
    80002a4c:	1141                	addi	sp,sp,-16
    80002a4e:	e406                	sd	ra,8(sp)
    80002a50:	e022                	sd	s0,0(sp)
    80002a52:	0800                	addi	s0,sp,16
  initlock(&tickslock, "time");
    80002a54:	00006597          	auipc	a1,0x6
    80002a58:	9c458593          	addi	a1,a1,-1596 # 80008418 <states.1774+0x30>
    80002a5c:	00014517          	auipc	a0,0x14
    80002a60:	0b450513          	addi	a0,a0,180 # 80016b10 <tickslock>
    80002a64:	ffffe097          	auipc	ra,0xffffe
    80002a68:	1a2080e7          	jalr	418(ra) # 80000c06 <initlock>
}
    80002a6c:	60a2                	ld	ra,8(sp)
    80002a6e:	6402                	ld	s0,0(sp)
    80002a70:	0141                	addi	sp,sp,16
    80002a72:	8082                	ret

0000000080002a74 <trapinithart>:

// set up to take exceptions and traps while in the kernel.
void
trapinithart(void)
{
    80002a74:	1141                	addi	sp,sp,-16
    80002a76:	e422                	sd	s0,8(sp)
    80002a78:	0800                	addi	s0,sp,16
  asm volatile("csrw stvec, %0" : : "r" (x));
    80002a7a:	00003797          	auipc	a5,0x3
    80002a7e:	58678793          	addi	a5,a5,1414 # 80006000 <kernelvec>
    80002a82:	10579073          	csrw	stvec,a5
  w_stvec((uint64)kernelvec);
}
    80002a86:	6422                	ld	s0,8(sp)
    80002a88:	0141                	addi	sp,sp,16
    80002a8a:	8082                	ret

0000000080002a8c <usertrapret>:
//
// return to user space
//
void
usertrapret(void)
{
    80002a8c:	1141                	addi	sp,sp,-16
    80002a8e:	e406                	sd	ra,8(sp)
    80002a90:	e022                	sd	s0,0(sp)
    80002a92:	0800                	addi	s0,sp,16
  struct proc *p = myproc();
    80002a94:	fffff097          	auipc	ra,0xfffff
    80002a98:	0dc080e7          	jalr	220(ra) # 80001b70 <myproc>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002a9c:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    80002aa0:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002aa2:	10079073          	csrw	sstatus,a5
  // kerneltrap() to usertrap(), so turn off interrupts until
  // we're back in user space, where usertrap() is correct.
  intr_off();

  // send syscalls, interrupts, and exceptions to uservec in trampoline.S
  uint64 trampoline_uservec = TRAMPOLINE + (uservec - trampoline);
    80002aa6:	00004617          	auipc	a2,0x4
    80002aaa:	55a60613          	addi	a2,a2,1370 # 80007000 <_trampoline>
    80002aae:	00004697          	auipc	a3,0x4
    80002ab2:	55268693          	addi	a3,a3,1362 # 80007000 <_trampoline>
    80002ab6:	8e91                	sub	a3,a3,a2
    80002ab8:	040007b7          	lui	a5,0x4000
    80002abc:	17fd                	addi	a5,a5,-1
    80002abe:	07b2                	slli	a5,a5,0xc
    80002ac0:	96be                	add	a3,a3,a5
  asm volatile("csrw stvec, %0" : : "r" (x));
    80002ac2:	10569073          	csrw	stvec,a3
  w_stvec(trampoline_uservec);

  // set up trapframe values that uservec will need when
  // the process next traps into the kernel.
  p->trapframe->kernel_satp = r_satp();         // kernel page table
    80002ac6:	6d38                	ld	a4,88(a0)
  asm volatile("csrr %0, satp" : "=r" (x) );
    80002ac8:	180026f3          	csrr	a3,satp
    80002acc:	e314                	sd	a3,0(a4)
  p->trapframe->kernel_sp = p->kstack + PGSIZE; // process's kernel stack
    80002ace:	6d38                	ld	a4,88(a0)
    80002ad0:	6134                	ld	a3,64(a0)
    80002ad2:	6585                	lui	a1,0x1
    80002ad4:	96ae                	add	a3,a3,a1
    80002ad6:	e714                	sd	a3,8(a4)
  p->trapframe->kernel_trap = (uint64)usertrap;
    80002ad8:	6d38                	ld	a4,88(a0)
    80002ada:	00000697          	auipc	a3,0x0
    80002ade:	13068693          	addi	a3,a3,304 # 80002c0a <usertrap>
    80002ae2:	eb14                	sd	a3,16(a4)
  p->trapframe->kernel_hartid = r_tp();         // hartid for cpuid()
    80002ae4:	6d38                	ld	a4,88(a0)
  asm volatile("mv %0, tp" : "=r" (x) );
    80002ae6:	8692                	mv	a3,tp
    80002ae8:	f314                	sd	a3,32(a4)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002aea:	100026f3          	csrr	a3,sstatus
  // set up the registers that trampoline.S's sret will use
  // to get to user space.
  
  // set S Previous Privilege mode to User.
  unsigned long x = r_sstatus();
  x &= ~SSTATUS_SPP; // clear SPP to 0 for user mode
    80002aee:	eff6f693          	andi	a3,a3,-257
  x |= SSTATUS_SPIE; // enable interrupts in user mode
    80002af2:	0206e693          	ori	a3,a3,32
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002af6:	10069073          	csrw	sstatus,a3
  w_sstatus(x);

  // set S Exception Program Counter to the saved user pc.
  w_sepc(p->trapframe->epc);
    80002afa:	6d38                	ld	a4,88(a0)
  asm volatile("csrw sepc, %0" : : "r" (x));
    80002afc:	6f18                	ld	a4,24(a4)
    80002afe:	14171073          	csrw	sepc,a4

  // tell trampoline.S the user page table to switch to.
  uint64 satp = MAKE_SATP(p->pagetable);
    80002b02:	6928                	ld	a0,80(a0)
    80002b04:	8131                	srli	a0,a0,0xc

  // jump to userret in trampoline.S at the top of memory, which 
  // switches to the user page table, restores user registers,
  // and switches to user mode with sret.
  uint64 trampoline_userret = TRAMPOLINE + (userret - trampoline);
    80002b06:	00004717          	auipc	a4,0x4
    80002b0a:	59670713          	addi	a4,a4,1430 # 8000709c <userret>
    80002b0e:	8f11                	sub	a4,a4,a2
    80002b10:	97ba                	add	a5,a5,a4
  ((void (*)(uint64))trampoline_userret)(satp);
    80002b12:	577d                	li	a4,-1
    80002b14:	177e                	slli	a4,a4,0x3f
    80002b16:	8d59                	or	a0,a0,a4
    80002b18:	9782                	jalr	a5
}
    80002b1a:	60a2                	ld	ra,8(sp)
    80002b1c:	6402                	ld	s0,0(sp)
    80002b1e:	0141                	addi	sp,sp,16
    80002b20:	8082                	ret

0000000080002b22 <clockintr>:
  w_sstatus(sstatus);
}

void
clockintr()
{
    80002b22:	1101                	addi	sp,sp,-32
    80002b24:	ec06                	sd	ra,24(sp)
    80002b26:	e822                	sd	s0,16(sp)
    80002b28:	e426                	sd	s1,8(sp)
    80002b2a:	1000                	addi	s0,sp,32
  acquire(&tickslock);
    80002b2c:	00014497          	auipc	s1,0x14
    80002b30:	fe448493          	addi	s1,s1,-28 # 80016b10 <tickslock>
    80002b34:	8526                	mv	a0,s1
    80002b36:	ffffe097          	auipc	ra,0xffffe
    80002b3a:	160080e7          	jalr	352(ra) # 80000c96 <acquire>
  ticks++;
    80002b3e:	00006517          	auipc	a0,0x6
    80002b42:	f3250513          	addi	a0,a0,-206 # 80008a70 <ticks>
    80002b46:	411c                	lw	a5,0(a0)
    80002b48:	2785                	addiw	a5,a5,1
    80002b4a:	c11c                	sw	a5,0(a0)
  wakeup(&ticks);
    80002b4c:	fffff097          	auipc	ra,0xfffff
    80002b50:	7ec080e7          	jalr	2028(ra) # 80002338 <wakeup>
  release(&tickslock);
    80002b54:	8526                	mv	a0,s1
    80002b56:	ffffe097          	auipc	ra,0xffffe
    80002b5a:	1f4080e7          	jalr	500(ra) # 80000d4a <release>
}
    80002b5e:	60e2                	ld	ra,24(sp)
    80002b60:	6442                	ld	s0,16(sp)
    80002b62:	64a2                	ld	s1,8(sp)
    80002b64:	6105                	addi	sp,sp,32
    80002b66:	8082                	ret

0000000080002b68 <devintr>:
// returns 2 if timer interrupt,
// 1 if other device,
// 0 if not recognized.
int
devintr()
{
    80002b68:	1101                	addi	sp,sp,-32
    80002b6a:	ec06                	sd	ra,24(sp)
    80002b6c:	e822                	sd	s0,16(sp)
    80002b6e:	e426                	sd	s1,8(sp)
    80002b70:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002b72:	14202773          	csrr	a4,scause
  uint64 scause = r_scause();

  if((scause & 0x8000000000000000L) &&
    80002b76:	00074d63          	bltz	a4,80002b90 <devintr+0x28>
    // now allowed to interrupt again.
    if(irq)
      plic_complete(irq);

    return 1;
  } else if(scause == 0x8000000000000001L){
    80002b7a:	57fd                	li	a5,-1
    80002b7c:	17fe                	slli	a5,a5,0x3f
    80002b7e:	0785                	addi	a5,a5,1
    // the SSIP bit in sip.
    w_sip(r_sip() & ~2);

    return 2;
  } else {
    return 0;
    80002b80:	4501                	li	a0,0
  } else if(scause == 0x8000000000000001L){
    80002b82:	06f70363          	beq	a4,a5,80002be8 <devintr+0x80>
  }
}
    80002b86:	60e2                	ld	ra,24(sp)
    80002b88:	6442                	ld	s0,16(sp)
    80002b8a:	64a2                	ld	s1,8(sp)
    80002b8c:	6105                	addi	sp,sp,32
    80002b8e:	8082                	ret
     (scause & 0xff) == 9){
    80002b90:	0ff77793          	andi	a5,a4,255
  if((scause & 0x8000000000000000L) &&
    80002b94:	46a5                	li	a3,9
    80002b96:	fed792e3          	bne	a5,a3,80002b7a <devintr+0x12>
    int irq = plic_claim();
    80002b9a:	00003097          	auipc	ra,0x3
    80002b9e:	56e080e7          	jalr	1390(ra) # 80006108 <plic_claim>
    80002ba2:	84aa                	mv	s1,a0
    if(irq == UART0_IRQ){
    80002ba4:	47a9                	li	a5,10
    80002ba6:	02f50763          	beq	a0,a5,80002bd4 <devintr+0x6c>
    } else if(irq == VIRTIO0_IRQ){
    80002baa:	4785                	li	a5,1
    80002bac:	02f50963          	beq	a0,a5,80002bde <devintr+0x76>
    return 1;
    80002bb0:	4505                	li	a0,1
    } else if(irq){
    80002bb2:	d8f1                	beqz	s1,80002b86 <devintr+0x1e>
      printf("unexpected interrupt irq=%d\n", irq);
    80002bb4:	85a6                	mv	a1,s1
    80002bb6:	00006517          	auipc	a0,0x6
    80002bba:	86a50513          	addi	a0,a0,-1942 # 80008420 <states.1774+0x38>
    80002bbe:	ffffe097          	auipc	ra,0xffffe
    80002bc2:	9c6080e7          	jalr	-1594(ra) # 80000584 <printf>
      plic_complete(irq);
    80002bc6:	8526                	mv	a0,s1
    80002bc8:	00003097          	auipc	ra,0x3
    80002bcc:	564080e7          	jalr	1380(ra) # 8000612c <plic_complete>
    return 1;
    80002bd0:	4505                	li	a0,1
    80002bd2:	bf55                	j	80002b86 <devintr+0x1e>
      uartintr();
    80002bd4:	ffffe097          	auipc	ra,0xffffe
    80002bd8:	dd0080e7          	jalr	-560(ra) # 800009a4 <uartintr>
    80002bdc:	b7ed                	j	80002bc6 <devintr+0x5e>
      virtio_disk_intr();
    80002bde:	00004097          	auipc	ra,0x4
    80002be2:	a78080e7          	jalr	-1416(ra) # 80006656 <virtio_disk_intr>
    80002be6:	b7c5                	j	80002bc6 <devintr+0x5e>
    if(cpuid() == 0){
    80002be8:	fffff097          	auipc	ra,0xfffff
    80002bec:	f5c080e7          	jalr	-164(ra) # 80001b44 <cpuid>
    80002bf0:	c901                	beqz	a0,80002c00 <devintr+0x98>
  asm volatile("csrr %0, sip" : "=r" (x) );
    80002bf2:	144027f3          	csrr	a5,sip
    w_sip(r_sip() & ~2);
    80002bf6:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sip, %0" : : "r" (x));
    80002bf8:	14479073          	csrw	sip,a5
    return 2;
    80002bfc:	4509                	li	a0,2
    80002bfe:	b761                	j	80002b86 <devintr+0x1e>
      clockintr();
    80002c00:	00000097          	auipc	ra,0x0
    80002c04:	f22080e7          	jalr	-222(ra) # 80002b22 <clockintr>
    80002c08:	b7ed                	j	80002bf2 <devintr+0x8a>

0000000080002c0a <usertrap>:
{
    80002c0a:	1101                	addi	sp,sp,-32
    80002c0c:	ec06                	sd	ra,24(sp)
    80002c0e:	e822                	sd	s0,16(sp)
    80002c10:	e426                	sd	s1,8(sp)
    80002c12:	e04a                	sd	s2,0(sp)
    80002c14:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002c16:	100027f3          	csrr	a5,sstatus
  if((r_sstatus() & SSTATUS_SPP) != 0)
    80002c1a:	1007f793          	andi	a5,a5,256
    80002c1e:	e3b1                	bnez	a5,80002c62 <usertrap+0x58>
  asm volatile("csrw stvec, %0" : : "r" (x));
    80002c20:	00003797          	auipc	a5,0x3
    80002c24:	3e078793          	addi	a5,a5,992 # 80006000 <kernelvec>
    80002c28:	10579073          	csrw	stvec,a5
  struct proc *p = myproc();
    80002c2c:	fffff097          	auipc	ra,0xfffff
    80002c30:	f44080e7          	jalr	-188(ra) # 80001b70 <myproc>
    80002c34:	84aa                	mv	s1,a0
  p->trapframe->epc = r_sepc();
    80002c36:	6d3c                	ld	a5,88(a0)
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002c38:	14102773          	csrr	a4,sepc
    80002c3c:	ef98                	sd	a4,24(a5)
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002c3e:	14202773          	csrr	a4,scause
  if(r_scause() == 8){
    80002c42:	47a1                	li	a5,8
    80002c44:	02f70763          	beq	a4,a5,80002c72 <usertrap+0x68>
  } else if((which_dev = devintr()) != 0){
    80002c48:	00000097          	auipc	ra,0x0
    80002c4c:	f20080e7          	jalr	-224(ra) # 80002b68 <devintr>
    80002c50:	892a                	mv	s2,a0
    80002c52:	c151                	beqz	a0,80002cd6 <usertrap+0xcc>
  if(killed(p))
    80002c54:	8526                	mv	a0,s1
    80002c56:	00000097          	auipc	ra,0x0
    80002c5a:	926080e7          	jalr	-1754(ra) # 8000257c <killed>
    80002c5e:	c929                	beqz	a0,80002cb0 <usertrap+0xa6>
    80002c60:	a099                	j	80002ca6 <usertrap+0x9c>
    panic("usertrap: not from user mode");
    80002c62:	00005517          	auipc	a0,0x5
    80002c66:	7de50513          	addi	a0,a0,2014 # 80008440 <states.1774+0x58>
    80002c6a:	ffffe097          	auipc	ra,0xffffe
    80002c6e:	8be080e7          	jalr	-1858(ra) # 80000528 <panic>
    if(killed(p))
    80002c72:	00000097          	auipc	ra,0x0
    80002c76:	90a080e7          	jalr	-1782(ra) # 8000257c <killed>
    80002c7a:	e921                	bnez	a0,80002cca <usertrap+0xc0>
    p->trapframe->epc += 4;
    80002c7c:	6cb8                	ld	a4,88(s1)
    80002c7e:	6f1c                	ld	a5,24(a4)
    80002c80:	0791                	addi	a5,a5,4
    80002c82:	ef1c                	sd	a5,24(a4)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002c84:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80002c88:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002c8c:	10079073          	csrw	sstatus,a5
    syscall();
    80002c90:	00000097          	auipc	ra,0x0
    80002c94:	2d4080e7          	jalr	724(ra) # 80002f64 <syscall>
  if(killed(p))
    80002c98:	8526                	mv	a0,s1
    80002c9a:	00000097          	auipc	ra,0x0
    80002c9e:	8e2080e7          	jalr	-1822(ra) # 8000257c <killed>
    80002ca2:	c911                	beqz	a0,80002cb6 <usertrap+0xac>
    80002ca4:	4901                	li	s2,0
    exit(-1);
    80002ca6:	557d                	li	a0,-1
    80002ca8:	fffff097          	auipc	ra,0xfffff
    80002cac:	760080e7          	jalr	1888(ra) # 80002408 <exit>
  if(which_dev == 2)
    80002cb0:	4789                	li	a5,2
    80002cb2:	04f90f63          	beq	s2,a5,80002d10 <usertrap+0x106>
  usertrapret();
    80002cb6:	00000097          	auipc	ra,0x0
    80002cba:	dd6080e7          	jalr	-554(ra) # 80002a8c <usertrapret>
}
    80002cbe:	60e2                	ld	ra,24(sp)
    80002cc0:	6442                	ld	s0,16(sp)
    80002cc2:	64a2                	ld	s1,8(sp)
    80002cc4:	6902                	ld	s2,0(sp)
    80002cc6:	6105                	addi	sp,sp,32
    80002cc8:	8082                	ret
      exit(-1);
    80002cca:	557d                	li	a0,-1
    80002ccc:	fffff097          	auipc	ra,0xfffff
    80002cd0:	73c080e7          	jalr	1852(ra) # 80002408 <exit>
    80002cd4:	b765                	j	80002c7c <usertrap+0x72>
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002cd6:	142025f3          	csrr	a1,scause
    printf("usertrap(): unexpected scause %p pid=%d\n", r_scause(), p->pid);
    80002cda:	5890                	lw	a2,48(s1)
    80002cdc:	00005517          	auipc	a0,0x5
    80002ce0:	78450513          	addi	a0,a0,1924 # 80008460 <states.1774+0x78>
    80002ce4:	ffffe097          	auipc	ra,0xffffe
    80002ce8:	8a0080e7          	jalr	-1888(ra) # 80000584 <printf>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002cec:	141025f3          	csrr	a1,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    80002cf0:	14302673          	csrr	a2,stval
    printf("            sepc=%p stval=%p\n", r_sepc(), r_stval());
    80002cf4:	00005517          	auipc	a0,0x5
    80002cf8:	79c50513          	addi	a0,a0,1948 # 80008490 <states.1774+0xa8>
    80002cfc:	ffffe097          	auipc	ra,0xffffe
    80002d00:	888080e7          	jalr	-1912(ra) # 80000584 <printf>
    setkilled(p);
    80002d04:	8526                	mv	a0,s1
    80002d06:	00000097          	auipc	ra,0x0
    80002d0a:	84a080e7          	jalr	-1974(ra) # 80002550 <setkilled>
    80002d0e:	b769                	j	80002c98 <usertrap+0x8e>
    yield();
    80002d10:	fffff097          	auipc	ra,0xfffff
    80002d14:	588080e7          	jalr	1416(ra) # 80002298 <yield>
    80002d18:	bf79                	j	80002cb6 <usertrap+0xac>

0000000080002d1a <kerneltrap>:
{
    80002d1a:	7179                	addi	sp,sp,-48
    80002d1c:	f406                	sd	ra,40(sp)
    80002d1e:	f022                	sd	s0,32(sp)
    80002d20:	ec26                	sd	s1,24(sp)
    80002d22:	e84a                	sd	s2,16(sp)
    80002d24:	e44e                	sd	s3,8(sp)
    80002d26:	1800                	addi	s0,sp,48
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002d28:	14102973          	csrr	s2,sepc
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002d2c:	100024f3          	csrr	s1,sstatus
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002d30:	142029f3          	csrr	s3,scause
  if((sstatus & SSTATUS_SPP) == 0)
    80002d34:	1004f793          	andi	a5,s1,256
    80002d38:	cb85                	beqz	a5,80002d68 <kerneltrap+0x4e>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002d3a:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80002d3e:	8b89                	andi	a5,a5,2
  if(intr_get() != 0)
    80002d40:	ef85                	bnez	a5,80002d78 <kerneltrap+0x5e>
  if((which_dev = devintr()) == 0){
    80002d42:	00000097          	auipc	ra,0x0
    80002d46:	e26080e7          	jalr	-474(ra) # 80002b68 <devintr>
    80002d4a:	cd1d                	beqz	a0,80002d88 <kerneltrap+0x6e>
  if(which_dev == 2 && myproc() != 0 && myproc()->state == RUNNING)
    80002d4c:	4789                	li	a5,2
    80002d4e:	06f50a63          	beq	a0,a5,80002dc2 <kerneltrap+0xa8>
  asm volatile("csrw sepc, %0" : : "r" (x));
    80002d52:	14191073          	csrw	sepc,s2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002d56:	10049073          	csrw	sstatus,s1
}
    80002d5a:	70a2                	ld	ra,40(sp)
    80002d5c:	7402                	ld	s0,32(sp)
    80002d5e:	64e2                	ld	s1,24(sp)
    80002d60:	6942                	ld	s2,16(sp)
    80002d62:	69a2                	ld	s3,8(sp)
    80002d64:	6145                	addi	sp,sp,48
    80002d66:	8082                	ret
    panic("kerneltrap: not from supervisor mode");
    80002d68:	00005517          	auipc	a0,0x5
    80002d6c:	74850513          	addi	a0,a0,1864 # 800084b0 <states.1774+0xc8>
    80002d70:	ffffd097          	auipc	ra,0xffffd
    80002d74:	7b8080e7          	jalr	1976(ra) # 80000528 <panic>
    panic("kerneltrap: interrupts enabled");
    80002d78:	00005517          	auipc	a0,0x5
    80002d7c:	76050513          	addi	a0,a0,1888 # 800084d8 <states.1774+0xf0>
    80002d80:	ffffd097          	auipc	ra,0xffffd
    80002d84:	7a8080e7          	jalr	1960(ra) # 80000528 <panic>
    printf("scause %p\n", scause);
    80002d88:	85ce                	mv	a1,s3
    80002d8a:	00005517          	auipc	a0,0x5
    80002d8e:	76e50513          	addi	a0,a0,1902 # 800084f8 <states.1774+0x110>
    80002d92:	ffffd097          	auipc	ra,0xffffd
    80002d96:	7f2080e7          	jalr	2034(ra) # 80000584 <printf>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002d9a:	141025f3          	csrr	a1,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    80002d9e:	14302673          	csrr	a2,stval
    printf("sepc=%p stval=%p\n", r_sepc(), r_stval());
    80002da2:	00005517          	auipc	a0,0x5
    80002da6:	76650513          	addi	a0,a0,1894 # 80008508 <states.1774+0x120>
    80002daa:	ffffd097          	auipc	ra,0xffffd
    80002dae:	7da080e7          	jalr	2010(ra) # 80000584 <printf>
    panic("kerneltrap");
    80002db2:	00005517          	auipc	a0,0x5
    80002db6:	76e50513          	addi	a0,a0,1902 # 80008520 <states.1774+0x138>
    80002dba:	ffffd097          	auipc	ra,0xffffd
    80002dbe:	76e080e7          	jalr	1902(ra) # 80000528 <panic>
  if(which_dev == 2 && myproc() != 0 && myproc()->state == RUNNING)
    80002dc2:	fffff097          	auipc	ra,0xfffff
    80002dc6:	dae080e7          	jalr	-594(ra) # 80001b70 <myproc>
    80002dca:	d541                	beqz	a0,80002d52 <kerneltrap+0x38>
    80002dcc:	fffff097          	auipc	ra,0xfffff
    80002dd0:	da4080e7          	jalr	-604(ra) # 80001b70 <myproc>
    80002dd4:	4d18                	lw	a4,24(a0)
    80002dd6:	4791                	li	a5,4
    80002dd8:	f6f71de3          	bne	a4,a5,80002d52 <kerneltrap+0x38>
    yield();
    80002ddc:	fffff097          	auipc	ra,0xfffff
    80002de0:	4bc080e7          	jalr	1212(ra) # 80002298 <yield>
    80002de4:	b7bd                	j	80002d52 <kerneltrap+0x38>

0000000080002de6 <argraw>:
    return strlen(buf);
}

static uint64
argraw(int n)
{
    80002de6:	1101                	addi	sp,sp,-32
    80002de8:	ec06                	sd	ra,24(sp)
    80002dea:	e822                	sd	s0,16(sp)
    80002dec:	e426                	sd	s1,8(sp)
    80002dee:	1000                	addi	s0,sp,32
    80002df0:	84aa                	mv	s1,a0
    struct proc *p = myproc();
    80002df2:	fffff097          	auipc	ra,0xfffff
    80002df6:	d7e080e7          	jalr	-642(ra) # 80001b70 <myproc>
    switch (n)
    80002dfa:	4795                	li	a5,5
    80002dfc:	0497e163          	bltu	a5,s1,80002e3e <argraw+0x58>
    80002e00:	048a                	slli	s1,s1,0x2
    80002e02:	00005717          	auipc	a4,0x5
    80002e06:	75670713          	addi	a4,a4,1878 # 80008558 <states.1774+0x170>
    80002e0a:	94ba                	add	s1,s1,a4
    80002e0c:	409c                	lw	a5,0(s1)
    80002e0e:	97ba                	add	a5,a5,a4
    80002e10:	8782                	jr	a5
    {
    case 0:
        return p->trapframe->a0;
    80002e12:	6d3c                	ld	a5,88(a0)
    80002e14:	7ba8                	ld	a0,112(a5)
    case 5:
        return p->trapframe->a5;
    }
    panic("argraw");
    return -1;
}
    80002e16:	60e2                	ld	ra,24(sp)
    80002e18:	6442                	ld	s0,16(sp)
    80002e1a:	64a2                	ld	s1,8(sp)
    80002e1c:	6105                	addi	sp,sp,32
    80002e1e:	8082                	ret
        return p->trapframe->a1;
    80002e20:	6d3c                	ld	a5,88(a0)
    80002e22:	7fa8                	ld	a0,120(a5)
    80002e24:	bfcd                	j	80002e16 <argraw+0x30>
        return p->trapframe->a2;
    80002e26:	6d3c                	ld	a5,88(a0)
    80002e28:	63c8                	ld	a0,128(a5)
    80002e2a:	b7f5                	j	80002e16 <argraw+0x30>
        return p->trapframe->a3;
    80002e2c:	6d3c                	ld	a5,88(a0)
    80002e2e:	67c8                	ld	a0,136(a5)
    80002e30:	b7dd                	j	80002e16 <argraw+0x30>
        return p->trapframe->a4;
    80002e32:	6d3c                	ld	a5,88(a0)
    80002e34:	6bc8                	ld	a0,144(a5)
    80002e36:	b7c5                	j	80002e16 <argraw+0x30>
        return p->trapframe->a5;
    80002e38:	6d3c                	ld	a5,88(a0)
    80002e3a:	6fc8                	ld	a0,152(a5)
    80002e3c:	bfe9                	j	80002e16 <argraw+0x30>
    panic("argraw");
    80002e3e:	00005517          	auipc	a0,0x5
    80002e42:	6f250513          	addi	a0,a0,1778 # 80008530 <states.1774+0x148>
    80002e46:	ffffd097          	auipc	ra,0xffffd
    80002e4a:	6e2080e7          	jalr	1762(ra) # 80000528 <panic>

0000000080002e4e <fetchaddr>:
{
    80002e4e:	1101                	addi	sp,sp,-32
    80002e50:	ec06                	sd	ra,24(sp)
    80002e52:	e822                	sd	s0,16(sp)
    80002e54:	e426                	sd	s1,8(sp)
    80002e56:	e04a                	sd	s2,0(sp)
    80002e58:	1000                	addi	s0,sp,32
    80002e5a:	84aa                	mv	s1,a0
    80002e5c:	892e                	mv	s2,a1
    struct proc *p = myproc();
    80002e5e:	fffff097          	auipc	ra,0xfffff
    80002e62:	d12080e7          	jalr	-750(ra) # 80001b70 <myproc>
    if (addr >= p->sz || addr + sizeof(uint64) > p->sz) // both tests needed, in case of overflow
    80002e66:	653c                	ld	a5,72(a0)
    80002e68:	02f4f863          	bgeu	s1,a5,80002e98 <fetchaddr+0x4a>
    80002e6c:	00848713          	addi	a4,s1,8
    80002e70:	02e7e663          	bltu	a5,a4,80002e9c <fetchaddr+0x4e>
    if (copyin(p->pagetable, (char *)ip, addr, sizeof(*ip)) != 0)
    80002e74:	46a1                	li	a3,8
    80002e76:	8626                	mv	a2,s1
    80002e78:	85ca                	mv	a1,s2
    80002e7a:	6928                	ld	a0,80(a0)
    80002e7c:	fffff097          	auipc	ra,0xfffff
    80002e80:	940080e7          	jalr	-1728(ra) # 800017bc <copyin>
    80002e84:	00a03533          	snez	a0,a0
    80002e88:	40a00533          	neg	a0,a0
}
    80002e8c:	60e2                	ld	ra,24(sp)
    80002e8e:	6442                	ld	s0,16(sp)
    80002e90:	64a2                	ld	s1,8(sp)
    80002e92:	6902                	ld	s2,0(sp)
    80002e94:	6105                	addi	sp,sp,32
    80002e96:	8082                	ret
        return -1;
    80002e98:	557d                	li	a0,-1
    80002e9a:	bfcd                	j	80002e8c <fetchaddr+0x3e>
    80002e9c:	557d                	li	a0,-1
    80002e9e:	b7fd                	j	80002e8c <fetchaddr+0x3e>

0000000080002ea0 <fetchstr>:
{
    80002ea0:	7179                	addi	sp,sp,-48
    80002ea2:	f406                	sd	ra,40(sp)
    80002ea4:	f022                	sd	s0,32(sp)
    80002ea6:	ec26                	sd	s1,24(sp)
    80002ea8:	e84a                	sd	s2,16(sp)
    80002eaa:	e44e                	sd	s3,8(sp)
    80002eac:	1800                	addi	s0,sp,48
    80002eae:	892a                	mv	s2,a0
    80002eb0:	84ae                	mv	s1,a1
    80002eb2:	89b2                	mv	s3,a2
    struct proc *p = myproc();
    80002eb4:	fffff097          	auipc	ra,0xfffff
    80002eb8:	cbc080e7          	jalr	-836(ra) # 80001b70 <myproc>
    if (copyinstr(p->pagetable, buf, addr, max) < 0)
    80002ebc:	86ce                	mv	a3,s3
    80002ebe:	864a                	mv	a2,s2
    80002ec0:	85a6                	mv	a1,s1
    80002ec2:	6928                	ld	a0,80(a0)
    80002ec4:	fffff097          	auipc	ra,0xfffff
    80002ec8:	984080e7          	jalr	-1660(ra) # 80001848 <copyinstr>
    80002ecc:	00054e63          	bltz	a0,80002ee8 <fetchstr+0x48>
    return strlen(buf);
    80002ed0:	8526                	mv	a0,s1
    80002ed2:	ffffe097          	auipc	ra,0xffffe
    80002ed6:	044080e7          	jalr	68(ra) # 80000f16 <strlen>
}
    80002eda:	70a2                	ld	ra,40(sp)
    80002edc:	7402                	ld	s0,32(sp)
    80002ede:	64e2                	ld	s1,24(sp)
    80002ee0:	6942                	ld	s2,16(sp)
    80002ee2:	69a2                	ld	s3,8(sp)
    80002ee4:	6145                	addi	sp,sp,48
    80002ee6:	8082                	ret
        return -1;
    80002ee8:	557d                	li	a0,-1
    80002eea:	bfc5                	j	80002eda <fetchstr+0x3a>

0000000080002eec <argint>:

// Fetch the nth 32-bit system call argument.
void argint(int n, int *ip)
{
    80002eec:	1101                	addi	sp,sp,-32
    80002eee:	ec06                	sd	ra,24(sp)
    80002ef0:	e822                	sd	s0,16(sp)
    80002ef2:	e426                	sd	s1,8(sp)
    80002ef4:	1000                	addi	s0,sp,32
    80002ef6:	84ae                	mv	s1,a1
    *ip = argraw(n);
    80002ef8:	00000097          	auipc	ra,0x0
    80002efc:	eee080e7          	jalr	-274(ra) # 80002de6 <argraw>
    80002f00:	c088                	sw	a0,0(s1)
}
    80002f02:	60e2                	ld	ra,24(sp)
    80002f04:	6442                	ld	s0,16(sp)
    80002f06:	64a2                	ld	s1,8(sp)
    80002f08:	6105                	addi	sp,sp,32
    80002f0a:	8082                	ret

0000000080002f0c <argaddr>:

// Retrieve an argument as a pointer.
// Doesn't check for legality, since
// copyin/copyout will do that.
void argaddr(int n, uint64 *ip)
{
    80002f0c:	1101                	addi	sp,sp,-32
    80002f0e:	ec06                	sd	ra,24(sp)
    80002f10:	e822                	sd	s0,16(sp)
    80002f12:	e426                	sd	s1,8(sp)
    80002f14:	1000                	addi	s0,sp,32
    80002f16:	84ae                	mv	s1,a1
    *ip = argraw(n);
    80002f18:	00000097          	auipc	ra,0x0
    80002f1c:	ece080e7          	jalr	-306(ra) # 80002de6 <argraw>
    80002f20:	e088                	sd	a0,0(s1)
}
    80002f22:	60e2                	ld	ra,24(sp)
    80002f24:	6442                	ld	s0,16(sp)
    80002f26:	64a2                	ld	s1,8(sp)
    80002f28:	6105                	addi	sp,sp,32
    80002f2a:	8082                	ret

0000000080002f2c <argstr>:

// Fetch the nth word-sized system call argument as a null-terminated string.
// Copies into buf, at most max.
// Returns string length if OK (including nul), -1 if error.
int argstr(int n, char *buf, int max)
{
    80002f2c:	7179                	addi	sp,sp,-48
    80002f2e:	f406                	sd	ra,40(sp)
    80002f30:	f022                	sd	s0,32(sp)
    80002f32:	ec26                	sd	s1,24(sp)
    80002f34:	e84a                	sd	s2,16(sp)
    80002f36:	1800                	addi	s0,sp,48
    80002f38:	84ae                	mv	s1,a1
    80002f3a:	8932                	mv	s2,a2
    uint64 addr;
    argaddr(n, &addr);
    80002f3c:	fd840593          	addi	a1,s0,-40
    80002f40:	00000097          	auipc	ra,0x0
    80002f44:	fcc080e7          	jalr	-52(ra) # 80002f0c <argaddr>
    return fetchstr(addr, buf, max);
    80002f48:	864a                	mv	a2,s2
    80002f4a:	85a6                	mv	a1,s1
    80002f4c:	fd843503          	ld	a0,-40(s0)
    80002f50:	00000097          	auipc	ra,0x0
    80002f54:	f50080e7          	jalr	-176(ra) # 80002ea0 <fetchstr>
}
    80002f58:	70a2                	ld	ra,40(sp)
    80002f5a:	7402                	ld	s0,32(sp)
    80002f5c:	64e2                	ld	s1,24(sp)
    80002f5e:	6942                	ld	s2,16(sp)
    80002f60:	6145                	addi	sp,sp,48
    80002f62:	8082                	ret

0000000080002f64 <syscall>:
    [SYS_pfreepages] sys_pfreepages,
    [SYS_va2pa] sys_va2pa,
};

void syscall(void)
{
    80002f64:	1101                	addi	sp,sp,-32
    80002f66:	ec06                	sd	ra,24(sp)
    80002f68:	e822                	sd	s0,16(sp)
    80002f6a:	e426                	sd	s1,8(sp)
    80002f6c:	e04a                	sd	s2,0(sp)
    80002f6e:	1000                	addi	s0,sp,32
    int num;
    struct proc *p = myproc();
    80002f70:	fffff097          	auipc	ra,0xfffff
    80002f74:	c00080e7          	jalr	-1024(ra) # 80001b70 <myproc>
    80002f78:	84aa                	mv	s1,a0

    num = p->trapframe->a7;
    80002f7a:	05853903          	ld	s2,88(a0)
    80002f7e:	0a893783          	ld	a5,168(s2)
    80002f82:	0007869b          	sext.w	a3,a5
    if (num > 0 && num < NELEM(syscalls) && syscalls[num])
    80002f86:	37fd                	addiw	a5,a5,-1
    80002f88:	4765                	li	a4,25
    80002f8a:	00f76f63          	bltu	a4,a5,80002fa8 <syscall+0x44>
    80002f8e:	00369713          	slli	a4,a3,0x3
    80002f92:	00005797          	auipc	a5,0x5
    80002f96:	5de78793          	addi	a5,a5,1502 # 80008570 <syscalls>
    80002f9a:	97ba                	add	a5,a5,a4
    80002f9c:	639c                	ld	a5,0(a5)
    80002f9e:	c789                	beqz	a5,80002fa8 <syscall+0x44>
    {
        // Use num to lookup the system call function for num, call it,
        // and store its return value in p->trapframe->a0
        p->trapframe->a0 = syscalls[num]();
    80002fa0:	9782                	jalr	a5
    80002fa2:	06a93823          	sd	a0,112(s2)
    80002fa6:	a839                	j	80002fc4 <syscall+0x60>
    }
    else
    {
        printf("%d %s: unknown sys call %d\n",
    80002fa8:	15848613          	addi	a2,s1,344
    80002fac:	588c                	lw	a1,48(s1)
    80002fae:	00005517          	auipc	a0,0x5
    80002fb2:	58a50513          	addi	a0,a0,1418 # 80008538 <states.1774+0x150>
    80002fb6:	ffffd097          	auipc	ra,0xffffd
    80002fba:	5ce080e7          	jalr	1486(ra) # 80000584 <printf>
               p->pid, p->name, num);
        p->trapframe->a0 = -1;
    80002fbe:	6cbc                	ld	a5,88(s1)
    80002fc0:	577d                	li	a4,-1
    80002fc2:	fbb8                	sd	a4,112(a5)
    }
}
    80002fc4:	60e2                	ld	ra,24(sp)
    80002fc6:	6442                	ld	s0,16(sp)
    80002fc8:	64a2                	ld	s1,8(sp)
    80002fca:	6902                	ld	s2,0(sp)
    80002fcc:	6105                	addi	sp,sp,32
    80002fce:	8082                	ret

0000000080002fd0 <sys_exit>:

extern uint64 FREE_PAGES; // kalloc.c keeps track of those

uint64
sys_exit(void)
{
    80002fd0:	1101                	addi	sp,sp,-32
    80002fd2:	ec06                	sd	ra,24(sp)
    80002fd4:	e822                	sd	s0,16(sp)
    80002fd6:	1000                	addi	s0,sp,32
    int n;
    argint(0, &n);
    80002fd8:	fec40593          	addi	a1,s0,-20
    80002fdc:	4501                	li	a0,0
    80002fde:	00000097          	auipc	ra,0x0
    80002fe2:	f0e080e7          	jalr	-242(ra) # 80002eec <argint>
    exit(n);
    80002fe6:	fec42503          	lw	a0,-20(s0)
    80002fea:	fffff097          	auipc	ra,0xfffff
    80002fee:	41e080e7          	jalr	1054(ra) # 80002408 <exit>
    return 0; // not reached
}
    80002ff2:	4501                	li	a0,0
    80002ff4:	60e2                	ld	ra,24(sp)
    80002ff6:	6442                	ld	s0,16(sp)
    80002ff8:	6105                	addi	sp,sp,32
    80002ffa:	8082                	ret

0000000080002ffc <sys_getpid>:

uint64
sys_getpid(void)
{
    80002ffc:	1141                	addi	sp,sp,-16
    80002ffe:	e406                	sd	ra,8(sp)
    80003000:	e022                	sd	s0,0(sp)
    80003002:	0800                	addi	s0,sp,16
    return myproc()->pid;
    80003004:	fffff097          	auipc	ra,0xfffff
    80003008:	b6c080e7          	jalr	-1172(ra) # 80001b70 <myproc>
}
    8000300c:	5908                	lw	a0,48(a0)
    8000300e:	60a2                	ld	ra,8(sp)
    80003010:	6402                	ld	s0,0(sp)
    80003012:	0141                	addi	sp,sp,16
    80003014:	8082                	ret

0000000080003016 <sys_fork>:

uint64
sys_fork(void)
{
    80003016:	1141                	addi	sp,sp,-16
    80003018:	e406                	sd	ra,8(sp)
    8000301a:	e022                	sd	s0,0(sp)
    8000301c:	0800                	addi	s0,sp,16
    return fork();
    8000301e:	fffff097          	auipc	ra,0xfffff
    80003022:	058080e7          	jalr	88(ra) # 80002076 <fork>
}
    80003026:	60a2                	ld	ra,8(sp)
    80003028:	6402                	ld	s0,0(sp)
    8000302a:	0141                	addi	sp,sp,16
    8000302c:	8082                	ret

000000008000302e <sys_wait>:

uint64
sys_wait(void)
{
    8000302e:	1101                	addi	sp,sp,-32
    80003030:	ec06                	sd	ra,24(sp)
    80003032:	e822                	sd	s0,16(sp)
    80003034:	1000                	addi	s0,sp,32
    uint64 p;
    argaddr(0, &p);
    80003036:	fe840593          	addi	a1,s0,-24
    8000303a:	4501                	li	a0,0
    8000303c:	00000097          	auipc	ra,0x0
    80003040:	ed0080e7          	jalr	-304(ra) # 80002f0c <argaddr>
    return wait(p);
    80003044:	fe843503          	ld	a0,-24(s0)
    80003048:	fffff097          	auipc	ra,0xfffff
    8000304c:	566080e7          	jalr	1382(ra) # 800025ae <wait>
}
    80003050:	60e2                	ld	ra,24(sp)
    80003052:	6442                	ld	s0,16(sp)
    80003054:	6105                	addi	sp,sp,32
    80003056:	8082                	ret

0000000080003058 <sys_sbrk>:

uint64
sys_sbrk(void)
{
    80003058:	7179                	addi	sp,sp,-48
    8000305a:	f406                	sd	ra,40(sp)
    8000305c:	f022                	sd	s0,32(sp)
    8000305e:	ec26                	sd	s1,24(sp)
    80003060:	1800                	addi	s0,sp,48
    uint64 addr;
    int n;

    argint(0, &n);
    80003062:	fdc40593          	addi	a1,s0,-36
    80003066:	4501                	li	a0,0
    80003068:	00000097          	auipc	ra,0x0
    8000306c:	e84080e7          	jalr	-380(ra) # 80002eec <argint>
    addr = myproc()->sz;
    80003070:	fffff097          	auipc	ra,0xfffff
    80003074:	b00080e7          	jalr	-1280(ra) # 80001b70 <myproc>
    80003078:	6524                	ld	s1,72(a0)
    if (growproc(n) < 0)
    8000307a:	fdc42503          	lw	a0,-36(s0)
    8000307e:	fffff097          	auipc	ra,0xfffff
    80003082:	e4c080e7          	jalr	-436(ra) # 80001eca <growproc>
    80003086:	00054863          	bltz	a0,80003096 <sys_sbrk+0x3e>
        return -1;
    return addr;
}
    8000308a:	8526                	mv	a0,s1
    8000308c:	70a2                	ld	ra,40(sp)
    8000308e:	7402                	ld	s0,32(sp)
    80003090:	64e2                	ld	s1,24(sp)
    80003092:	6145                	addi	sp,sp,48
    80003094:	8082                	ret
        return -1;
    80003096:	54fd                	li	s1,-1
    80003098:	bfcd                	j	8000308a <sys_sbrk+0x32>

000000008000309a <sys_sleep>:

uint64
sys_sleep(void)
{
    8000309a:	7139                	addi	sp,sp,-64
    8000309c:	fc06                	sd	ra,56(sp)
    8000309e:	f822                	sd	s0,48(sp)
    800030a0:	f426                	sd	s1,40(sp)
    800030a2:	f04a                	sd	s2,32(sp)
    800030a4:	ec4e                	sd	s3,24(sp)
    800030a6:	0080                	addi	s0,sp,64
    int n;
    uint ticks0;

    argint(0, &n);
    800030a8:	fcc40593          	addi	a1,s0,-52
    800030ac:	4501                	li	a0,0
    800030ae:	00000097          	auipc	ra,0x0
    800030b2:	e3e080e7          	jalr	-450(ra) # 80002eec <argint>
    acquire(&tickslock);
    800030b6:	00014517          	auipc	a0,0x14
    800030ba:	a5a50513          	addi	a0,a0,-1446 # 80016b10 <tickslock>
    800030be:	ffffe097          	auipc	ra,0xffffe
    800030c2:	bd8080e7          	jalr	-1064(ra) # 80000c96 <acquire>
    ticks0 = ticks;
    800030c6:	00006917          	auipc	s2,0x6
    800030ca:	9aa92903          	lw	s2,-1622(s2) # 80008a70 <ticks>
    while (ticks - ticks0 < n)
    800030ce:	fcc42783          	lw	a5,-52(s0)
    800030d2:	cf9d                	beqz	a5,80003110 <sys_sleep+0x76>
        if (killed(myproc()))
        {
            release(&tickslock);
            return -1;
        }
        sleep(&ticks, &tickslock);
    800030d4:	00014997          	auipc	s3,0x14
    800030d8:	a3c98993          	addi	s3,s3,-1476 # 80016b10 <tickslock>
    800030dc:	00006497          	auipc	s1,0x6
    800030e0:	99448493          	addi	s1,s1,-1644 # 80008a70 <ticks>
        if (killed(myproc()))
    800030e4:	fffff097          	auipc	ra,0xfffff
    800030e8:	a8c080e7          	jalr	-1396(ra) # 80001b70 <myproc>
    800030ec:	fffff097          	auipc	ra,0xfffff
    800030f0:	490080e7          	jalr	1168(ra) # 8000257c <killed>
    800030f4:	ed15                	bnez	a0,80003130 <sys_sleep+0x96>
        sleep(&ticks, &tickslock);
    800030f6:	85ce                	mv	a1,s3
    800030f8:	8526                	mv	a0,s1
    800030fa:	fffff097          	auipc	ra,0xfffff
    800030fe:	1da080e7          	jalr	474(ra) # 800022d4 <sleep>
    while (ticks - ticks0 < n)
    80003102:	409c                	lw	a5,0(s1)
    80003104:	412787bb          	subw	a5,a5,s2
    80003108:	fcc42703          	lw	a4,-52(s0)
    8000310c:	fce7ece3          	bltu	a5,a4,800030e4 <sys_sleep+0x4a>
    }
    release(&tickslock);
    80003110:	00014517          	auipc	a0,0x14
    80003114:	a0050513          	addi	a0,a0,-1536 # 80016b10 <tickslock>
    80003118:	ffffe097          	auipc	ra,0xffffe
    8000311c:	c32080e7          	jalr	-974(ra) # 80000d4a <release>
    return 0;
    80003120:	4501                	li	a0,0
}
    80003122:	70e2                	ld	ra,56(sp)
    80003124:	7442                	ld	s0,48(sp)
    80003126:	74a2                	ld	s1,40(sp)
    80003128:	7902                	ld	s2,32(sp)
    8000312a:	69e2                	ld	s3,24(sp)
    8000312c:	6121                	addi	sp,sp,64
    8000312e:	8082                	ret
            release(&tickslock);
    80003130:	00014517          	auipc	a0,0x14
    80003134:	9e050513          	addi	a0,a0,-1568 # 80016b10 <tickslock>
    80003138:	ffffe097          	auipc	ra,0xffffe
    8000313c:	c12080e7          	jalr	-1006(ra) # 80000d4a <release>
            return -1;
    80003140:	557d                	li	a0,-1
    80003142:	b7c5                	j	80003122 <sys_sleep+0x88>

0000000080003144 <sys_kill>:

uint64
sys_kill(void)
{
    80003144:	1101                	addi	sp,sp,-32
    80003146:	ec06                	sd	ra,24(sp)
    80003148:	e822                	sd	s0,16(sp)
    8000314a:	1000                	addi	s0,sp,32
    int pid;

    argint(0, &pid);
    8000314c:	fec40593          	addi	a1,s0,-20
    80003150:	4501                	li	a0,0
    80003152:	00000097          	auipc	ra,0x0
    80003156:	d9a080e7          	jalr	-614(ra) # 80002eec <argint>
    return kill(pid);
    8000315a:	fec42503          	lw	a0,-20(s0)
    8000315e:	fffff097          	auipc	ra,0xfffff
    80003162:	380080e7          	jalr	896(ra) # 800024de <kill>
}
    80003166:	60e2                	ld	ra,24(sp)
    80003168:	6442                	ld	s0,16(sp)
    8000316a:	6105                	addi	sp,sp,32
    8000316c:	8082                	ret

000000008000316e <sys_uptime>:

// return how many clock tick interrupts have occurred
// since start.
uint64
sys_uptime(void)
{
    8000316e:	1101                	addi	sp,sp,-32
    80003170:	ec06                	sd	ra,24(sp)
    80003172:	e822                	sd	s0,16(sp)
    80003174:	e426                	sd	s1,8(sp)
    80003176:	1000                	addi	s0,sp,32
    uint xticks;

    acquire(&tickslock);
    80003178:	00014517          	auipc	a0,0x14
    8000317c:	99850513          	addi	a0,a0,-1640 # 80016b10 <tickslock>
    80003180:	ffffe097          	auipc	ra,0xffffe
    80003184:	b16080e7          	jalr	-1258(ra) # 80000c96 <acquire>
    xticks = ticks;
    80003188:	00006497          	auipc	s1,0x6
    8000318c:	8e84a483          	lw	s1,-1816(s1) # 80008a70 <ticks>
    release(&tickslock);
    80003190:	00014517          	auipc	a0,0x14
    80003194:	98050513          	addi	a0,a0,-1664 # 80016b10 <tickslock>
    80003198:	ffffe097          	auipc	ra,0xffffe
    8000319c:	bb2080e7          	jalr	-1102(ra) # 80000d4a <release>
    return xticks;
}
    800031a0:	02049513          	slli	a0,s1,0x20
    800031a4:	9101                	srli	a0,a0,0x20
    800031a6:	60e2                	ld	ra,24(sp)
    800031a8:	6442                	ld	s0,16(sp)
    800031aa:	64a2                	ld	s1,8(sp)
    800031ac:	6105                	addi	sp,sp,32
    800031ae:	8082                	ret

00000000800031b0 <sys_ps>:

void *
sys_ps(void)
{
    800031b0:	1101                	addi	sp,sp,-32
    800031b2:	ec06                	sd	ra,24(sp)
    800031b4:	e822                	sd	s0,16(sp)
    800031b6:	1000                	addi	s0,sp,32
    int start = 0, count = 0;
    800031b8:	fe042623          	sw	zero,-20(s0)
    800031bc:	fe042423          	sw	zero,-24(s0)
    argint(0, &start);
    800031c0:	fec40593          	addi	a1,s0,-20
    800031c4:	4501                	li	a0,0
    800031c6:	00000097          	auipc	ra,0x0
    800031ca:	d26080e7          	jalr	-730(ra) # 80002eec <argint>
    argint(1, &count);
    800031ce:	fe840593          	addi	a1,s0,-24
    800031d2:	4505                	li	a0,1
    800031d4:	00000097          	auipc	ra,0x0
    800031d8:	d18080e7          	jalr	-744(ra) # 80002eec <argint>
    return ps((uint8)start, (uint8)count);
    800031dc:	fe844583          	lbu	a1,-24(s0)
    800031e0:	fec44503          	lbu	a0,-20(s0)
    800031e4:	fffff097          	auipc	ra,0xfffff
    800031e8:	d42080e7          	jalr	-702(ra) # 80001f26 <ps>
}
    800031ec:	60e2                	ld	ra,24(sp)
    800031ee:	6442                	ld	s0,16(sp)
    800031f0:	6105                	addi	sp,sp,32
    800031f2:	8082                	ret

00000000800031f4 <sys_schedls>:

uint64 sys_schedls(void)
{
    800031f4:	1141                	addi	sp,sp,-16
    800031f6:	e406                	sd	ra,8(sp)
    800031f8:	e022                	sd	s0,0(sp)
    800031fa:	0800                	addi	s0,sp,16
    schedls();
    800031fc:	fffff097          	auipc	ra,0xfffff
    80003200:	63a080e7          	jalr	1594(ra) # 80002836 <schedls>
    return 0;
}
    80003204:	4501                	li	a0,0
    80003206:	60a2                	ld	ra,8(sp)
    80003208:	6402                	ld	s0,0(sp)
    8000320a:	0141                	addi	sp,sp,16
    8000320c:	8082                	ret

000000008000320e <sys_schedset>:

uint64 sys_schedset(void)
{
    8000320e:	1101                	addi	sp,sp,-32
    80003210:	ec06                	sd	ra,24(sp)
    80003212:	e822                	sd	s0,16(sp)
    80003214:	1000                	addi	s0,sp,32
    int id = 0;
    80003216:	fe042623          	sw	zero,-20(s0)
    argint(0, &id);
    8000321a:	fec40593          	addi	a1,s0,-20
    8000321e:	4501                	li	a0,0
    80003220:	00000097          	auipc	ra,0x0
    80003224:	ccc080e7          	jalr	-820(ra) # 80002eec <argint>
    schedset(id - 1);
    80003228:	fec42503          	lw	a0,-20(s0)
    8000322c:	357d                	addiw	a0,a0,-1
    8000322e:	fffff097          	auipc	ra,0xfffff
    80003232:	69e080e7          	jalr	1694(ra) # 800028cc <schedset>
    return 0;
}
    80003236:	4501                	li	a0,0
    80003238:	60e2                	ld	ra,24(sp)
    8000323a:	6442                	ld	s0,16(sp)
    8000323c:	6105                	addi	sp,sp,32
    8000323e:	8082                	ret

0000000080003240 <sys_va2pa>:

uint64 sys_va2pa(uint64 addr, int pid)
{
    80003240:	1141                	addi	sp,sp,-16
    80003242:	e406                	sd	ra,8(sp)
    80003244:	e022                	sd	s0,0(sp)
    80003246:	0800                	addi	s0,sp,16
    va2pa(addr, pid);
    80003248:	fffff097          	auipc	ra,0xfffff
    8000324c:	6d0080e7          	jalr	1744(ra) # 80002918 <va2pa>
    return 0;
}
    80003250:	4501                	li	a0,0
    80003252:	60a2                	ld	ra,8(sp)
    80003254:	6402                	ld	s0,0(sp)
    80003256:	0141                	addi	sp,sp,16
    80003258:	8082                	ret

000000008000325a <sys_pfreepages>:

uint64 sys_pfreepages(void)
{
    8000325a:	1141                	addi	sp,sp,-16
    8000325c:	e406                	sd	ra,8(sp)
    8000325e:	e022                	sd	s0,0(sp)
    80003260:	0800                	addi	s0,sp,16
    printf("%d\n", FREE_PAGES);
    80003262:	00005597          	auipc	a1,0x5
    80003266:	7e65b583          	ld	a1,2022(a1) # 80008a48 <FREE_PAGES>
    8000326a:	00005517          	auipc	a0,0x5
    8000326e:	2e650513          	addi	a0,a0,742 # 80008550 <states.1774+0x168>
    80003272:	ffffd097          	auipc	ra,0xffffd
    80003276:	312080e7          	jalr	786(ra) # 80000584 <printf>
    return 0;
    8000327a:	4501                	li	a0,0
    8000327c:	60a2                	ld	ra,8(sp)
    8000327e:	6402                	ld	s0,0(sp)
    80003280:	0141                	addi	sp,sp,16
    80003282:	8082                	ret

0000000080003284 <binit>:
  struct buf head;
} bcache;

void
binit(void)
{
    80003284:	7179                	addi	sp,sp,-48
    80003286:	f406                	sd	ra,40(sp)
    80003288:	f022                	sd	s0,32(sp)
    8000328a:	ec26                	sd	s1,24(sp)
    8000328c:	e84a                	sd	s2,16(sp)
    8000328e:	e44e                	sd	s3,8(sp)
    80003290:	e052                	sd	s4,0(sp)
    80003292:	1800                	addi	s0,sp,48
  struct buf *b;

  initlock(&bcache.lock, "bcache");
    80003294:	00005597          	auipc	a1,0x5
    80003298:	3b458593          	addi	a1,a1,948 # 80008648 <syscalls+0xd8>
    8000329c:	00014517          	auipc	a0,0x14
    800032a0:	88c50513          	addi	a0,a0,-1908 # 80016b28 <bcache>
    800032a4:	ffffe097          	auipc	ra,0xffffe
    800032a8:	962080e7          	jalr	-1694(ra) # 80000c06 <initlock>

  // Create linked list of buffers
  bcache.head.prev = &bcache.head;
    800032ac:	0001c797          	auipc	a5,0x1c
    800032b0:	87c78793          	addi	a5,a5,-1924 # 8001eb28 <bcache+0x8000>
    800032b4:	0001c717          	auipc	a4,0x1c
    800032b8:	adc70713          	addi	a4,a4,-1316 # 8001ed90 <bcache+0x8268>
    800032bc:	2ae7b823          	sd	a4,688(a5)
  bcache.head.next = &bcache.head;
    800032c0:	2ae7bc23          	sd	a4,696(a5)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    800032c4:	00014497          	auipc	s1,0x14
    800032c8:	87c48493          	addi	s1,s1,-1924 # 80016b40 <bcache+0x18>
    b->next = bcache.head.next;
    800032cc:	893e                	mv	s2,a5
    b->prev = &bcache.head;
    800032ce:	89ba                	mv	s3,a4
    initsleeplock(&b->lock, "buffer");
    800032d0:	00005a17          	auipc	s4,0x5
    800032d4:	380a0a13          	addi	s4,s4,896 # 80008650 <syscalls+0xe0>
    b->next = bcache.head.next;
    800032d8:	2b893783          	ld	a5,696(s2)
    800032dc:	e8bc                	sd	a5,80(s1)
    b->prev = &bcache.head;
    800032de:	0534b423          	sd	s3,72(s1)
    initsleeplock(&b->lock, "buffer");
    800032e2:	85d2                	mv	a1,s4
    800032e4:	01048513          	addi	a0,s1,16
    800032e8:	00001097          	auipc	ra,0x1
    800032ec:	4c4080e7          	jalr	1220(ra) # 800047ac <initsleeplock>
    bcache.head.next->prev = b;
    800032f0:	2b893783          	ld	a5,696(s2)
    800032f4:	e7a4                	sd	s1,72(a5)
    bcache.head.next = b;
    800032f6:	2a993c23          	sd	s1,696(s2)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    800032fa:	45848493          	addi	s1,s1,1112
    800032fe:	fd349de3          	bne	s1,s3,800032d8 <binit+0x54>
  }
}
    80003302:	70a2                	ld	ra,40(sp)
    80003304:	7402                	ld	s0,32(sp)
    80003306:	64e2                	ld	s1,24(sp)
    80003308:	6942                	ld	s2,16(sp)
    8000330a:	69a2                	ld	s3,8(sp)
    8000330c:	6a02                	ld	s4,0(sp)
    8000330e:	6145                	addi	sp,sp,48
    80003310:	8082                	ret

0000000080003312 <bread>:
}

// Return a locked buf with the contents of the indicated block.
struct buf*
bread(uint dev, uint blockno)
{
    80003312:	7179                	addi	sp,sp,-48
    80003314:	f406                	sd	ra,40(sp)
    80003316:	f022                	sd	s0,32(sp)
    80003318:	ec26                	sd	s1,24(sp)
    8000331a:	e84a                	sd	s2,16(sp)
    8000331c:	e44e                	sd	s3,8(sp)
    8000331e:	1800                	addi	s0,sp,48
    80003320:	89aa                	mv	s3,a0
    80003322:	892e                	mv	s2,a1
  acquire(&bcache.lock);
    80003324:	00014517          	auipc	a0,0x14
    80003328:	80450513          	addi	a0,a0,-2044 # 80016b28 <bcache>
    8000332c:	ffffe097          	auipc	ra,0xffffe
    80003330:	96a080e7          	jalr	-1686(ra) # 80000c96 <acquire>
  for(b = bcache.head.next; b != &bcache.head; b = b->next){
    80003334:	0001c497          	auipc	s1,0x1c
    80003338:	aac4b483          	ld	s1,-1364(s1) # 8001ede0 <bcache+0x82b8>
    8000333c:	0001c797          	auipc	a5,0x1c
    80003340:	a5478793          	addi	a5,a5,-1452 # 8001ed90 <bcache+0x8268>
    80003344:	02f48f63          	beq	s1,a5,80003382 <bread+0x70>
    80003348:	873e                	mv	a4,a5
    8000334a:	a021                	j	80003352 <bread+0x40>
    8000334c:	68a4                	ld	s1,80(s1)
    8000334e:	02e48a63          	beq	s1,a4,80003382 <bread+0x70>
    if(b->dev == dev && b->blockno == blockno){
    80003352:	449c                	lw	a5,8(s1)
    80003354:	ff379ce3          	bne	a5,s3,8000334c <bread+0x3a>
    80003358:	44dc                	lw	a5,12(s1)
    8000335a:	ff2799e3          	bne	a5,s2,8000334c <bread+0x3a>
      b->refcnt++;
    8000335e:	40bc                	lw	a5,64(s1)
    80003360:	2785                	addiw	a5,a5,1
    80003362:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    80003364:	00013517          	auipc	a0,0x13
    80003368:	7c450513          	addi	a0,a0,1988 # 80016b28 <bcache>
    8000336c:	ffffe097          	auipc	ra,0xffffe
    80003370:	9de080e7          	jalr	-1570(ra) # 80000d4a <release>
      acquiresleep(&b->lock);
    80003374:	01048513          	addi	a0,s1,16
    80003378:	00001097          	auipc	ra,0x1
    8000337c:	46e080e7          	jalr	1134(ra) # 800047e6 <acquiresleep>
      return b;
    80003380:	a8b9                	j	800033de <bread+0xcc>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    80003382:	0001c497          	auipc	s1,0x1c
    80003386:	a564b483          	ld	s1,-1450(s1) # 8001edd8 <bcache+0x82b0>
    8000338a:	0001c797          	auipc	a5,0x1c
    8000338e:	a0678793          	addi	a5,a5,-1530 # 8001ed90 <bcache+0x8268>
    80003392:	00f48863          	beq	s1,a5,800033a2 <bread+0x90>
    80003396:	873e                	mv	a4,a5
    if(b->refcnt == 0) {
    80003398:	40bc                	lw	a5,64(s1)
    8000339a:	cf81                	beqz	a5,800033b2 <bread+0xa0>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    8000339c:	64a4                	ld	s1,72(s1)
    8000339e:	fee49de3          	bne	s1,a4,80003398 <bread+0x86>
  panic("bget: no buffers");
    800033a2:	00005517          	auipc	a0,0x5
    800033a6:	2b650513          	addi	a0,a0,694 # 80008658 <syscalls+0xe8>
    800033aa:	ffffd097          	auipc	ra,0xffffd
    800033ae:	17e080e7          	jalr	382(ra) # 80000528 <panic>
      b->dev = dev;
    800033b2:	0134a423          	sw	s3,8(s1)
      b->blockno = blockno;
    800033b6:	0124a623          	sw	s2,12(s1)
      b->valid = 0;
    800033ba:	0004a023          	sw	zero,0(s1)
      b->refcnt = 1;
    800033be:	4785                	li	a5,1
    800033c0:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    800033c2:	00013517          	auipc	a0,0x13
    800033c6:	76650513          	addi	a0,a0,1894 # 80016b28 <bcache>
    800033ca:	ffffe097          	auipc	ra,0xffffe
    800033ce:	980080e7          	jalr	-1664(ra) # 80000d4a <release>
      acquiresleep(&b->lock);
    800033d2:	01048513          	addi	a0,s1,16
    800033d6:	00001097          	auipc	ra,0x1
    800033da:	410080e7          	jalr	1040(ra) # 800047e6 <acquiresleep>
  struct buf *b;

  b = bget(dev, blockno);
  if(!b->valid) {
    800033de:	409c                	lw	a5,0(s1)
    800033e0:	cb89                	beqz	a5,800033f2 <bread+0xe0>
    virtio_disk_rw(b, 0);
    b->valid = 1;
  }
  return b;
}
    800033e2:	8526                	mv	a0,s1
    800033e4:	70a2                	ld	ra,40(sp)
    800033e6:	7402                	ld	s0,32(sp)
    800033e8:	64e2                	ld	s1,24(sp)
    800033ea:	6942                	ld	s2,16(sp)
    800033ec:	69a2                	ld	s3,8(sp)
    800033ee:	6145                	addi	sp,sp,48
    800033f0:	8082                	ret
    virtio_disk_rw(b, 0);
    800033f2:	4581                	li	a1,0
    800033f4:	8526                	mv	a0,s1
    800033f6:	00003097          	auipc	ra,0x3
    800033fa:	fd2080e7          	jalr	-46(ra) # 800063c8 <virtio_disk_rw>
    b->valid = 1;
    800033fe:	4785                	li	a5,1
    80003400:	c09c                	sw	a5,0(s1)
  return b;
    80003402:	b7c5                	j	800033e2 <bread+0xd0>

0000000080003404 <bwrite>:

// Write b's contents to disk.  Must be locked.
void
bwrite(struct buf *b)
{
    80003404:	1101                	addi	sp,sp,-32
    80003406:	ec06                	sd	ra,24(sp)
    80003408:	e822                	sd	s0,16(sp)
    8000340a:	e426                	sd	s1,8(sp)
    8000340c:	1000                	addi	s0,sp,32
    8000340e:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    80003410:	0541                	addi	a0,a0,16
    80003412:	00001097          	auipc	ra,0x1
    80003416:	46e080e7          	jalr	1134(ra) # 80004880 <holdingsleep>
    8000341a:	cd01                	beqz	a0,80003432 <bwrite+0x2e>
    panic("bwrite");
  virtio_disk_rw(b, 1);
    8000341c:	4585                	li	a1,1
    8000341e:	8526                	mv	a0,s1
    80003420:	00003097          	auipc	ra,0x3
    80003424:	fa8080e7          	jalr	-88(ra) # 800063c8 <virtio_disk_rw>
}
    80003428:	60e2                	ld	ra,24(sp)
    8000342a:	6442                	ld	s0,16(sp)
    8000342c:	64a2                	ld	s1,8(sp)
    8000342e:	6105                	addi	sp,sp,32
    80003430:	8082                	ret
    panic("bwrite");
    80003432:	00005517          	auipc	a0,0x5
    80003436:	23e50513          	addi	a0,a0,574 # 80008670 <syscalls+0x100>
    8000343a:	ffffd097          	auipc	ra,0xffffd
    8000343e:	0ee080e7          	jalr	238(ra) # 80000528 <panic>

0000000080003442 <brelse>:

// Release a locked buffer.
// Move to the head of the most-recently-used list.
void
brelse(struct buf *b)
{
    80003442:	1101                	addi	sp,sp,-32
    80003444:	ec06                	sd	ra,24(sp)
    80003446:	e822                	sd	s0,16(sp)
    80003448:	e426                	sd	s1,8(sp)
    8000344a:	e04a                	sd	s2,0(sp)
    8000344c:	1000                	addi	s0,sp,32
    8000344e:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    80003450:	01050913          	addi	s2,a0,16
    80003454:	854a                	mv	a0,s2
    80003456:	00001097          	auipc	ra,0x1
    8000345a:	42a080e7          	jalr	1066(ra) # 80004880 <holdingsleep>
    8000345e:	c92d                	beqz	a0,800034d0 <brelse+0x8e>
    panic("brelse");

  releasesleep(&b->lock);
    80003460:	854a                	mv	a0,s2
    80003462:	00001097          	auipc	ra,0x1
    80003466:	3da080e7          	jalr	986(ra) # 8000483c <releasesleep>

  acquire(&bcache.lock);
    8000346a:	00013517          	auipc	a0,0x13
    8000346e:	6be50513          	addi	a0,a0,1726 # 80016b28 <bcache>
    80003472:	ffffe097          	auipc	ra,0xffffe
    80003476:	824080e7          	jalr	-2012(ra) # 80000c96 <acquire>
  b->refcnt--;
    8000347a:	40bc                	lw	a5,64(s1)
    8000347c:	37fd                	addiw	a5,a5,-1
    8000347e:	0007871b          	sext.w	a4,a5
    80003482:	c0bc                	sw	a5,64(s1)
  if (b->refcnt == 0) {
    80003484:	eb05                	bnez	a4,800034b4 <brelse+0x72>
    // no one is waiting for it.
    b->next->prev = b->prev;
    80003486:	68bc                	ld	a5,80(s1)
    80003488:	64b8                	ld	a4,72(s1)
    8000348a:	e7b8                	sd	a4,72(a5)
    b->prev->next = b->next;
    8000348c:	64bc                	ld	a5,72(s1)
    8000348e:	68b8                	ld	a4,80(s1)
    80003490:	ebb8                	sd	a4,80(a5)
    b->next = bcache.head.next;
    80003492:	0001b797          	auipc	a5,0x1b
    80003496:	69678793          	addi	a5,a5,1686 # 8001eb28 <bcache+0x8000>
    8000349a:	2b87b703          	ld	a4,696(a5)
    8000349e:	e8b8                	sd	a4,80(s1)
    b->prev = &bcache.head;
    800034a0:	0001c717          	auipc	a4,0x1c
    800034a4:	8f070713          	addi	a4,a4,-1808 # 8001ed90 <bcache+0x8268>
    800034a8:	e4b8                	sd	a4,72(s1)
    bcache.head.next->prev = b;
    800034aa:	2b87b703          	ld	a4,696(a5)
    800034ae:	e724                	sd	s1,72(a4)
    bcache.head.next = b;
    800034b0:	2a97bc23          	sd	s1,696(a5)
  }
  
  release(&bcache.lock);
    800034b4:	00013517          	auipc	a0,0x13
    800034b8:	67450513          	addi	a0,a0,1652 # 80016b28 <bcache>
    800034bc:	ffffe097          	auipc	ra,0xffffe
    800034c0:	88e080e7          	jalr	-1906(ra) # 80000d4a <release>
}
    800034c4:	60e2                	ld	ra,24(sp)
    800034c6:	6442                	ld	s0,16(sp)
    800034c8:	64a2                	ld	s1,8(sp)
    800034ca:	6902                	ld	s2,0(sp)
    800034cc:	6105                	addi	sp,sp,32
    800034ce:	8082                	ret
    panic("brelse");
    800034d0:	00005517          	auipc	a0,0x5
    800034d4:	1a850513          	addi	a0,a0,424 # 80008678 <syscalls+0x108>
    800034d8:	ffffd097          	auipc	ra,0xffffd
    800034dc:	050080e7          	jalr	80(ra) # 80000528 <panic>

00000000800034e0 <bpin>:

void
bpin(struct buf *b) {
    800034e0:	1101                	addi	sp,sp,-32
    800034e2:	ec06                	sd	ra,24(sp)
    800034e4:	e822                	sd	s0,16(sp)
    800034e6:	e426                	sd	s1,8(sp)
    800034e8:	1000                	addi	s0,sp,32
    800034ea:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    800034ec:	00013517          	auipc	a0,0x13
    800034f0:	63c50513          	addi	a0,a0,1596 # 80016b28 <bcache>
    800034f4:	ffffd097          	auipc	ra,0xffffd
    800034f8:	7a2080e7          	jalr	1954(ra) # 80000c96 <acquire>
  b->refcnt++;
    800034fc:	40bc                	lw	a5,64(s1)
    800034fe:	2785                	addiw	a5,a5,1
    80003500:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    80003502:	00013517          	auipc	a0,0x13
    80003506:	62650513          	addi	a0,a0,1574 # 80016b28 <bcache>
    8000350a:	ffffe097          	auipc	ra,0xffffe
    8000350e:	840080e7          	jalr	-1984(ra) # 80000d4a <release>
}
    80003512:	60e2                	ld	ra,24(sp)
    80003514:	6442                	ld	s0,16(sp)
    80003516:	64a2                	ld	s1,8(sp)
    80003518:	6105                	addi	sp,sp,32
    8000351a:	8082                	ret

000000008000351c <bunpin>:

void
bunpin(struct buf *b) {
    8000351c:	1101                	addi	sp,sp,-32
    8000351e:	ec06                	sd	ra,24(sp)
    80003520:	e822                	sd	s0,16(sp)
    80003522:	e426                	sd	s1,8(sp)
    80003524:	1000                	addi	s0,sp,32
    80003526:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    80003528:	00013517          	auipc	a0,0x13
    8000352c:	60050513          	addi	a0,a0,1536 # 80016b28 <bcache>
    80003530:	ffffd097          	auipc	ra,0xffffd
    80003534:	766080e7          	jalr	1894(ra) # 80000c96 <acquire>
  b->refcnt--;
    80003538:	40bc                	lw	a5,64(s1)
    8000353a:	37fd                	addiw	a5,a5,-1
    8000353c:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    8000353e:	00013517          	auipc	a0,0x13
    80003542:	5ea50513          	addi	a0,a0,1514 # 80016b28 <bcache>
    80003546:	ffffe097          	auipc	ra,0xffffe
    8000354a:	804080e7          	jalr	-2044(ra) # 80000d4a <release>
}
    8000354e:	60e2                	ld	ra,24(sp)
    80003550:	6442                	ld	s0,16(sp)
    80003552:	64a2                	ld	s1,8(sp)
    80003554:	6105                	addi	sp,sp,32
    80003556:	8082                	ret

0000000080003558 <bfree>:
}

// Free a disk block.
static void
bfree(int dev, uint b)
{
    80003558:	1101                	addi	sp,sp,-32
    8000355a:	ec06                	sd	ra,24(sp)
    8000355c:	e822                	sd	s0,16(sp)
    8000355e:	e426                	sd	s1,8(sp)
    80003560:	e04a                	sd	s2,0(sp)
    80003562:	1000                	addi	s0,sp,32
    80003564:	84ae                	mv	s1,a1
  struct buf *bp;
  int bi, m;

  bp = bread(dev, BBLOCK(b, sb));
    80003566:	00d5d59b          	srliw	a1,a1,0xd
    8000356a:	0001c797          	auipc	a5,0x1c
    8000356e:	c9a7a783          	lw	a5,-870(a5) # 8001f204 <sb+0x1c>
    80003572:	9dbd                	addw	a1,a1,a5
    80003574:	00000097          	auipc	ra,0x0
    80003578:	d9e080e7          	jalr	-610(ra) # 80003312 <bread>
  bi = b % BPB;
  m = 1 << (bi % 8);
    8000357c:	0074f713          	andi	a4,s1,7
    80003580:	4785                	li	a5,1
    80003582:	00e797bb          	sllw	a5,a5,a4
  if((bp->data[bi/8] & m) == 0)
    80003586:	14ce                	slli	s1,s1,0x33
    80003588:	90d9                	srli	s1,s1,0x36
    8000358a:	00950733          	add	a4,a0,s1
    8000358e:	05874703          	lbu	a4,88(a4)
    80003592:	00e7f6b3          	and	a3,a5,a4
    80003596:	c69d                	beqz	a3,800035c4 <bfree+0x6c>
    80003598:	892a                	mv	s2,a0
    panic("freeing free block");
  bp->data[bi/8] &= ~m;
    8000359a:	94aa                	add	s1,s1,a0
    8000359c:	fff7c793          	not	a5,a5
    800035a0:	8ff9                	and	a5,a5,a4
    800035a2:	04f48c23          	sb	a5,88(s1)
  log_write(bp);
    800035a6:	00001097          	auipc	ra,0x1
    800035aa:	120080e7          	jalr	288(ra) # 800046c6 <log_write>
  brelse(bp);
    800035ae:	854a                	mv	a0,s2
    800035b0:	00000097          	auipc	ra,0x0
    800035b4:	e92080e7          	jalr	-366(ra) # 80003442 <brelse>
}
    800035b8:	60e2                	ld	ra,24(sp)
    800035ba:	6442                	ld	s0,16(sp)
    800035bc:	64a2                	ld	s1,8(sp)
    800035be:	6902                	ld	s2,0(sp)
    800035c0:	6105                	addi	sp,sp,32
    800035c2:	8082                	ret
    panic("freeing free block");
    800035c4:	00005517          	auipc	a0,0x5
    800035c8:	0bc50513          	addi	a0,a0,188 # 80008680 <syscalls+0x110>
    800035cc:	ffffd097          	auipc	ra,0xffffd
    800035d0:	f5c080e7          	jalr	-164(ra) # 80000528 <panic>

00000000800035d4 <balloc>:
{
    800035d4:	711d                	addi	sp,sp,-96
    800035d6:	ec86                	sd	ra,88(sp)
    800035d8:	e8a2                	sd	s0,80(sp)
    800035da:	e4a6                	sd	s1,72(sp)
    800035dc:	e0ca                	sd	s2,64(sp)
    800035de:	fc4e                	sd	s3,56(sp)
    800035e0:	f852                	sd	s4,48(sp)
    800035e2:	f456                	sd	s5,40(sp)
    800035e4:	f05a                	sd	s6,32(sp)
    800035e6:	ec5e                	sd	s7,24(sp)
    800035e8:	e862                	sd	s8,16(sp)
    800035ea:	e466                	sd	s9,8(sp)
    800035ec:	1080                	addi	s0,sp,96
  for(b = 0; b < sb.size; b += BPB){
    800035ee:	0001c797          	auipc	a5,0x1c
    800035f2:	bfe7a783          	lw	a5,-1026(a5) # 8001f1ec <sb+0x4>
    800035f6:	10078163          	beqz	a5,800036f8 <balloc+0x124>
    800035fa:	8baa                	mv	s7,a0
    800035fc:	4a81                	li	s5,0
    bp = bread(dev, BBLOCK(b, sb));
    800035fe:	0001cb17          	auipc	s6,0x1c
    80003602:	beab0b13          	addi	s6,s6,-1046 # 8001f1e8 <sb>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80003606:	4c01                	li	s8,0
      m = 1 << (bi % 8);
    80003608:	4985                	li	s3,1
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    8000360a:	6a09                	lui	s4,0x2
  for(b = 0; b < sb.size; b += BPB){
    8000360c:	6c89                	lui	s9,0x2
    8000360e:	a061                	j	80003696 <balloc+0xc2>
        bp->data[bi/8] |= m;  // Mark block in use.
    80003610:	974a                	add	a4,a4,s2
    80003612:	8fd5                	or	a5,a5,a3
    80003614:	04f70c23          	sb	a5,88(a4)
        log_write(bp);
    80003618:	854a                	mv	a0,s2
    8000361a:	00001097          	auipc	ra,0x1
    8000361e:	0ac080e7          	jalr	172(ra) # 800046c6 <log_write>
        brelse(bp);
    80003622:	854a                	mv	a0,s2
    80003624:	00000097          	auipc	ra,0x0
    80003628:	e1e080e7          	jalr	-482(ra) # 80003442 <brelse>
  bp = bread(dev, bno);
    8000362c:	85a6                	mv	a1,s1
    8000362e:	855e                	mv	a0,s7
    80003630:	00000097          	auipc	ra,0x0
    80003634:	ce2080e7          	jalr	-798(ra) # 80003312 <bread>
    80003638:	892a                	mv	s2,a0
  memset(bp->data, 0, BSIZE);
    8000363a:	40000613          	li	a2,1024
    8000363e:	4581                	li	a1,0
    80003640:	05850513          	addi	a0,a0,88
    80003644:	ffffd097          	auipc	ra,0xffffd
    80003648:	74e080e7          	jalr	1870(ra) # 80000d92 <memset>
  log_write(bp);
    8000364c:	854a                	mv	a0,s2
    8000364e:	00001097          	auipc	ra,0x1
    80003652:	078080e7          	jalr	120(ra) # 800046c6 <log_write>
  brelse(bp);
    80003656:	854a                	mv	a0,s2
    80003658:	00000097          	auipc	ra,0x0
    8000365c:	dea080e7          	jalr	-534(ra) # 80003442 <brelse>
}
    80003660:	8526                	mv	a0,s1
    80003662:	60e6                	ld	ra,88(sp)
    80003664:	6446                	ld	s0,80(sp)
    80003666:	64a6                	ld	s1,72(sp)
    80003668:	6906                	ld	s2,64(sp)
    8000366a:	79e2                	ld	s3,56(sp)
    8000366c:	7a42                	ld	s4,48(sp)
    8000366e:	7aa2                	ld	s5,40(sp)
    80003670:	7b02                	ld	s6,32(sp)
    80003672:	6be2                	ld	s7,24(sp)
    80003674:	6c42                	ld	s8,16(sp)
    80003676:	6ca2                	ld	s9,8(sp)
    80003678:	6125                	addi	sp,sp,96
    8000367a:	8082                	ret
    brelse(bp);
    8000367c:	854a                	mv	a0,s2
    8000367e:	00000097          	auipc	ra,0x0
    80003682:	dc4080e7          	jalr	-572(ra) # 80003442 <brelse>
  for(b = 0; b < sb.size; b += BPB){
    80003686:	015c87bb          	addw	a5,s9,s5
    8000368a:	00078a9b          	sext.w	s5,a5
    8000368e:	004b2703          	lw	a4,4(s6)
    80003692:	06eaf363          	bgeu	s5,a4,800036f8 <balloc+0x124>
    bp = bread(dev, BBLOCK(b, sb));
    80003696:	41fad79b          	sraiw	a5,s5,0x1f
    8000369a:	0137d79b          	srliw	a5,a5,0x13
    8000369e:	015787bb          	addw	a5,a5,s5
    800036a2:	40d7d79b          	sraiw	a5,a5,0xd
    800036a6:	01cb2583          	lw	a1,28(s6)
    800036aa:	9dbd                	addw	a1,a1,a5
    800036ac:	855e                	mv	a0,s7
    800036ae:	00000097          	auipc	ra,0x0
    800036b2:	c64080e7          	jalr	-924(ra) # 80003312 <bread>
    800036b6:	892a                	mv	s2,a0
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    800036b8:	004b2503          	lw	a0,4(s6)
    800036bc:	000a849b          	sext.w	s1,s5
    800036c0:	8662                	mv	a2,s8
    800036c2:	faa4fde3          	bgeu	s1,a0,8000367c <balloc+0xa8>
      m = 1 << (bi % 8);
    800036c6:	41f6579b          	sraiw	a5,a2,0x1f
    800036ca:	01d7d69b          	srliw	a3,a5,0x1d
    800036ce:	00c6873b          	addw	a4,a3,a2
    800036d2:	00777793          	andi	a5,a4,7
    800036d6:	9f95                	subw	a5,a5,a3
    800036d8:	00f997bb          	sllw	a5,s3,a5
      if((bp->data[bi/8] & m) == 0){  // Is block free?
    800036dc:	4037571b          	sraiw	a4,a4,0x3
    800036e0:	00e906b3          	add	a3,s2,a4
    800036e4:	0586c683          	lbu	a3,88(a3)
    800036e8:	00d7f5b3          	and	a1,a5,a3
    800036ec:	d195                	beqz	a1,80003610 <balloc+0x3c>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    800036ee:	2605                	addiw	a2,a2,1
    800036f0:	2485                	addiw	s1,s1,1
    800036f2:	fd4618e3          	bne	a2,s4,800036c2 <balloc+0xee>
    800036f6:	b759                	j	8000367c <balloc+0xa8>
  printf("balloc: out of blocks\n");
    800036f8:	00005517          	auipc	a0,0x5
    800036fc:	fa050513          	addi	a0,a0,-96 # 80008698 <syscalls+0x128>
    80003700:	ffffd097          	auipc	ra,0xffffd
    80003704:	e84080e7          	jalr	-380(ra) # 80000584 <printf>
  return 0;
    80003708:	4481                	li	s1,0
    8000370a:	bf99                	j	80003660 <balloc+0x8c>

000000008000370c <bmap>:
// Return the disk block address of the nth block in inode ip.
// If there is no such block, bmap allocates one.
// returns 0 if out of disk space.
static uint
bmap(struct inode *ip, uint bn)
{
    8000370c:	7179                	addi	sp,sp,-48
    8000370e:	f406                	sd	ra,40(sp)
    80003710:	f022                	sd	s0,32(sp)
    80003712:	ec26                	sd	s1,24(sp)
    80003714:	e84a                	sd	s2,16(sp)
    80003716:	e44e                	sd	s3,8(sp)
    80003718:	e052                	sd	s4,0(sp)
    8000371a:	1800                	addi	s0,sp,48
    8000371c:	89aa                	mv	s3,a0
  uint addr, *a;
  struct buf *bp;

  if(bn < NDIRECT){
    8000371e:	47ad                	li	a5,11
    80003720:	02b7e763          	bltu	a5,a1,8000374e <bmap+0x42>
    if((addr = ip->addrs[bn]) == 0){
    80003724:	02059493          	slli	s1,a1,0x20
    80003728:	9081                	srli	s1,s1,0x20
    8000372a:	048a                	slli	s1,s1,0x2
    8000372c:	94aa                	add	s1,s1,a0
    8000372e:	0504a903          	lw	s2,80(s1)
    80003732:	06091e63          	bnez	s2,800037ae <bmap+0xa2>
      addr = balloc(ip->dev);
    80003736:	4108                	lw	a0,0(a0)
    80003738:	00000097          	auipc	ra,0x0
    8000373c:	e9c080e7          	jalr	-356(ra) # 800035d4 <balloc>
    80003740:	0005091b          	sext.w	s2,a0
      if(addr == 0)
    80003744:	06090563          	beqz	s2,800037ae <bmap+0xa2>
        return 0;
      ip->addrs[bn] = addr;
    80003748:	0524a823          	sw	s2,80(s1)
    8000374c:	a08d                	j	800037ae <bmap+0xa2>
    }
    return addr;
  }
  bn -= NDIRECT;
    8000374e:	ff45849b          	addiw	s1,a1,-12
    80003752:	0004871b          	sext.w	a4,s1

  if(bn < NINDIRECT){
    80003756:	0ff00793          	li	a5,255
    8000375a:	08e7e563          	bltu	a5,a4,800037e4 <bmap+0xd8>
    // Load indirect block, allocating if necessary.
    if((addr = ip->addrs[NDIRECT]) == 0){
    8000375e:	08052903          	lw	s2,128(a0)
    80003762:	00091d63          	bnez	s2,8000377c <bmap+0x70>
      addr = balloc(ip->dev);
    80003766:	4108                	lw	a0,0(a0)
    80003768:	00000097          	auipc	ra,0x0
    8000376c:	e6c080e7          	jalr	-404(ra) # 800035d4 <balloc>
    80003770:	0005091b          	sext.w	s2,a0
      if(addr == 0)
    80003774:	02090d63          	beqz	s2,800037ae <bmap+0xa2>
        return 0;
      ip->addrs[NDIRECT] = addr;
    80003778:	0929a023          	sw	s2,128(s3)
    }
    bp = bread(ip->dev, addr);
    8000377c:	85ca                	mv	a1,s2
    8000377e:	0009a503          	lw	a0,0(s3)
    80003782:	00000097          	auipc	ra,0x0
    80003786:	b90080e7          	jalr	-1136(ra) # 80003312 <bread>
    8000378a:	8a2a                	mv	s4,a0
    a = (uint*)bp->data;
    8000378c:	05850793          	addi	a5,a0,88
    if((addr = a[bn]) == 0){
    80003790:	02049593          	slli	a1,s1,0x20
    80003794:	9181                	srli	a1,a1,0x20
    80003796:	058a                	slli	a1,a1,0x2
    80003798:	00b784b3          	add	s1,a5,a1
    8000379c:	0004a903          	lw	s2,0(s1)
    800037a0:	02090063          	beqz	s2,800037c0 <bmap+0xb4>
      if(addr){
        a[bn] = addr;
        log_write(bp);
      }
    }
    brelse(bp);
    800037a4:	8552                	mv	a0,s4
    800037a6:	00000097          	auipc	ra,0x0
    800037aa:	c9c080e7          	jalr	-868(ra) # 80003442 <brelse>
    return addr;
  }

  panic("bmap: out of range");
}
    800037ae:	854a                	mv	a0,s2
    800037b0:	70a2                	ld	ra,40(sp)
    800037b2:	7402                	ld	s0,32(sp)
    800037b4:	64e2                	ld	s1,24(sp)
    800037b6:	6942                	ld	s2,16(sp)
    800037b8:	69a2                	ld	s3,8(sp)
    800037ba:	6a02                	ld	s4,0(sp)
    800037bc:	6145                	addi	sp,sp,48
    800037be:	8082                	ret
      addr = balloc(ip->dev);
    800037c0:	0009a503          	lw	a0,0(s3)
    800037c4:	00000097          	auipc	ra,0x0
    800037c8:	e10080e7          	jalr	-496(ra) # 800035d4 <balloc>
    800037cc:	0005091b          	sext.w	s2,a0
      if(addr){
    800037d0:	fc090ae3          	beqz	s2,800037a4 <bmap+0x98>
        a[bn] = addr;
    800037d4:	0124a023          	sw	s2,0(s1)
        log_write(bp);
    800037d8:	8552                	mv	a0,s4
    800037da:	00001097          	auipc	ra,0x1
    800037de:	eec080e7          	jalr	-276(ra) # 800046c6 <log_write>
    800037e2:	b7c9                	j	800037a4 <bmap+0x98>
  panic("bmap: out of range");
    800037e4:	00005517          	auipc	a0,0x5
    800037e8:	ecc50513          	addi	a0,a0,-308 # 800086b0 <syscalls+0x140>
    800037ec:	ffffd097          	auipc	ra,0xffffd
    800037f0:	d3c080e7          	jalr	-708(ra) # 80000528 <panic>

00000000800037f4 <iget>:
{
    800037f4:	7179                	addi	sp,sp,-48
    800037f6:	f406                	sd	ra,40(sp)
    800037f8:	f022                	sd	s0,32(sp)
    800037fa:	ec26                	sd	s1,24(sp)
    800037fc:	e84a                	sd	s2,16(sp)
    800037fe:	e44e                	sd	s3,8(sp)
    80003800:	e052                	sd	s4,0(sp)
    80003802:	1800                	addi	s0,sp,48
    80003804:	89aa                	mv	s3,a0
    80003806:	8a2e                	mv	s4,a1
  acquire(&itable.lock);
    80003808:	0001c517          	auipc	a0,0x1c
    8000380c:	a0050513          	addi	a0,a0,-1536 # 8001f208 <itable>
    80003810:	ffffd097          	auipc	ra,0xffffd
    80003814:	486080e7          	jalr	1158(ra) # 80000c96 <acquire>
  empty = 0;
    80003818:	4901                	li	s2,0
  for(ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++){
    8000381a:	0001c497          	auipc	s1,0x1c
    8000381e:	a0648493          	addi	s1,s1,-1530 # 8001f220 <itable+0x18>
    80003822:	0001d697          	auipc	a3,0x1d
    80003826:	48e68693          	addi	a3,a3,1166 # 80020cb0 <log>
    8000382a:	a039                	j	80003838 <iget+0x44>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    8000382c:	02090b63          	beqz	s2,80003862 <iget+0x6e>
  for(ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++){
    80003830:	08848493          	addi	s1,s1,136
    80003834:	02d48a63          	beq	s1,a3,80003868 <iget+0x74>
    if(ip->ref > 0 && ip->dev == dev && ip->inum == inum){
    80003838:	449c                	lw	a5,8(s1)
    8000383a:	fef059e3          	blez	a5,8000382c <iget+0x38>
    8000383e:	4098                	lw	a4,0(s1)
    80003840:	ff3716e3          	bne	a4,s3,8000382c <iget+0x38>
    80003844:	40d8                	lw	a4,4(s1)
    80003846:	ff4713e3          	bne	a4,s4,8000382c <iget+0x38>
      ip->ref++;
    8000384a:	2785                	addiw	a5,a5,1
    8000384c:	c49c                	sw	a5,8(s1)
      release(&itable.lock);
    8000384e:	0001c517          	auipc	a0,0x1c
    80003852:	9ba50513          	addi	a0,a0,-1606 # 8001f208 <itable>
    80003856:	ffffd097          	auipc	ra,0xffffd
    8000385a:	4f4080e7          	jalr	1268(ra) # 80000d4a <release>
      return ip;
    8000385e:	8926                	mv	s2,s1
    80003860:	a03d                	j	8000388e <iget+0x9a>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    80003862:	f7f9                	bnez	a5,80003830 <iget+0x3c>
    80003864:	8926                	mv	s2,s1
    80003866:	b7e9                	j	80003830 <iget+0x3c>
  if(empty == 0)
    80003868:	02090c63          	beqz	s2,800038a0 <iget+0xac>
  ip->dev = dev;
    8000386c:	01392023          	sw	s3,0(s2)
  ip->inum = inum;
    80003870:	01492223          	sw	s4,4(s2)
  ip->ref = 1;
    80003874:	4785                	li	a5,1
    80003876:	00f92423          	sw	a5,8(s2)
  ip->valid = 0;
    8000387a:	04092023          	sw	zero,64(s2)
  release(&itable.lock);
    8000387e:	0001c517          	auipc	a0,0x1c
    80003882:	98a50513          	addi	a0,a0,-1654 # 8001f208 <itable>
    80003886:	ffffd097          	auipc	ra,0xffffd
    8000388a:	4c4080e7          	jalr	1220(ra) # 80000d4a <release>
}
    8000388e:	854a                	mv	a0,s2
    80003890:	70a2                	ld	ra,40(sp)
    80003892:	7402                	ld	s0,32(sp)
    80003894:	64e2                	ld	s1,24(sp)
    80003896:	6942                	ld	s2,16(sp)
    80003898:	69a2                	ld	s3,8(sp)
    8000389a:	6a02                	ld	s4,0(sp)
    8000389c:	6145                	addi	sp,sp,48
    8000389e:	8082                	ret
    panic("iget: no inodes");
    800038a0:	00005517          	auipc	a0,0x5
    800038a4:	e2850513          	addi	a0,a0,-472 # 800086c8 <syscalls+0x158>
    800038a8:	ffffd097          	auipc	ra,0xffffd
    800038ac:	c80080e7          	jalr	-896(ra) # 80000528 <panic>

00000000800038b0 <fsinit>:
fsinit(int dev) {
    800038b0:	7179                	addi	sp,sp,-48
    800038b2:	f406                	sd	ra,40(sp)
    800038b4:	f022                	sd	s0,32(sp)
    800038b6:	ec26                	sd	s1,24(sp)
    800038b8:	e84a                	sd	s2,16(sp)
    800038ba:	e44e                	sd	s3,8(sp)
    800038bc:	1800                	addi	s0,sp,48
    800038be:	892a                	mv	s2,a0
  bp = bread(dev, 1);
    800038c0:	4585                	li	a1,1
    800038c2:	00000097          	auipc	ra,0x0
    800038c6:	a50080e7          	jalr	-1456(ra) # 80003312 <bread>
    800038ca:	84aa                	mv	s1,a0
  memmove(sb, bp->data, sizeof(*sb));
    800038cc:	0001c997          	auipc	s3,0x1c
    800038d0:	91c98993          	addi	s3,s3,-1764 # 8001f1e8 <sb>
    800038d4:	02000613          	li	a2,32
    800038d8:	05850593          	addi	a1,a0,88
    800038dc:	854e                	mv	a0,s3
    800038de:	ffffd097          	auipc	ra,0xffffd
    800038e2:	514080e7          	jalr	1300(ra) # 80000df2 <memmove>
  brelse(bp);
    800038e6:	8526                	mv	a0,s1
    800038e8:	00000097          	auipc	ra,0x0
    800038ec:	b5a080e7          	jalr	-1190(ra) # 80003442 <brelse>
  if(sb.magic != FSMAGIC)
    800038f0:	0009a703          	lw	a4,0(s3)
    800038f4:	102037b7          	lui	a5,0x10203
    800038f8:	04078793          	addi	a5,a5,64 # 10203040 <_entry-0x6fdfcfc0>
    800038fc:	02f71263          	bne	a4,a5,80003920 <fsinit+0x70>
  initlog(dev, &sb);
    80003900:	0001c597          	auipc	a1,0x1c
    80003904:	8e858593          	addi	a1,a1,-1816 # 8001f1e8 <sb>
    80003908:	854a                	mv	a0,s2
    8000390a:	00001097          	auipc	ra,0x1
    8000390e:	b40080e7          	jalr	-1216(ra) # 8000444a <initlog>
}
    80003912:	70a2                	ld	ra,40(sp)
    80003914:	7402                	ld	s0,32(sp)
    80003916:	64e2                	ld	s1,24(sp)
    80003918:	6942                	ld	s2,16(sp)
    8000391a:	69a2                	ld	s3,8(sp)
    8000391c:	6145                	addi	sp,sp,48
    8000391e:	8082                	ret
    panic("invalid file system");
    80003920:	00005517          	auipc	a0,0x5
    80003924:	db850513          	addi	a0,a0,-584 # 800086d8 <syscalls+0x168>
    80003928:	ffffd097          	auipc	ra,0xffffd
    8000392c:	c00080e7          	jalr	-1024(ra) # 80000528 <panic>

0000000080003930 <iinit>:
{
    80003930:	7179                	addi	sp,sp,-48
    80003932:	f406                	sd	ra,40(sp)
    80003934:	f022                	sd	s0,32(sp)
    80003936:	ec26                	sd	s1,24(sp)
    80003938:	e84a                	sd	s2,16(sp)
    8000393a:	e44e                	sd	s3,8(sp)
    8000393c:	1800                	addi	s0,sp,48
  initlock(&itable.lock, "itable");
    8000393e:	00005597          	auipc	a1,0x5
    80003942:	db258593          	addi	a1,a1,-590 # 800086f0 <syscalls+0x180>
    80003946:	0001c517          	auipc	a0,0x1c
    8000394a:	8c250513          	addi	a0,a0,-1854 # 8001f208 <itable>
    8000394e:	ffffd097          	auipc	ra,0xffffd
    80003952:	2b8080e7          	jalr	696(ra) # 80000c06 <initlock>
  for(i = 0; i < NINODE; i++) {
    80003956:	0001c497          	auipc	s1,0x1c
    8000395a:	8da48493          	addi	s1,s1,-1830 # 8001f230 <itable+0x28>
    8000395e:	0001d997          	auipc	s3,0x1d
    80003962:	36298993          	addi	s3,s3,866 # 80020cc0 <log+0x10>
    initsleeplock(&itable.inode[i].lock, "inode");
    80003966:	00005917          	auipc	s2,0x5
    8000396a:	d9290913          	addi	s2,s2,-622 # 800086f8 <syscalls+0x188>
    8000396e:	85ca                	mv	a1,s2
    80003970:	8526                	mv	a0,s1
    80003972:	00001097          	auipc	ra,0x1
    80003976:	e3a080e7          	jalr	-454(ra) # 800047ac <initsleeplock>
  for(i = 0; i < NINODE; i++) {
    8000397a:	08848493          	addi	s1,s1,136
    8000397e:	ff3498e3          	bne	s1,s3,8000396e <iinit+0x3e>
}
    80003982:	70a2                	ld	ra,40(sp)
    80003984:	7402                	ld	s0,32(sp)
    80003986:	64e2                	ld	s1,24(sp)
    80003988:	6942                	ld	s2,16(sp)
    8000398a:	69a2                	ld	s3,8(sp)
    8000398c:	6145                	addi	sp,sp,48
    8000398e:	8082                	ret

0000000080003990 <ialloc>:
{
    80003990:	715d                	addi	sp,sp,-80
    80003992:	e486                	sd	ra,72(sp)
    80003994:	e0a2                	sd	s0,64(sp)
    80003996:	fc26                	sd	s1,56(sp)
    80003998:	f84a                	sd	s2,48(sp)
    8000399a:	f44e                	sd	s3,40(sp)
    8000399c:	f052                	sd	s4,32(sp)
    8000399e:	ec56                	sd	s5,24(sp)
    800039a0:	e85a                	sd	s6,16(sp)
    800039a2:	e45e                	sd	s7,8(sp)
    800039a4:	0880                	addi	s0,sp,80
  for(inum = 1; inum < sb.ninodes; inum++){
    800039a6:	0001c717          	auipc	a4,0x1c
    800039aa:	84e72703          	lw	a4,-1970(a4) # 8001f1f4 <sb+0xc>
    800039ae:	4785                	li	a5,1
    800039b0:	04e7fa63          	bgeu	a5,a4,80003a04 <ialloc+0x74>
    800039b4:	8aaa                	mv	s5,a0
    800039b6:	8bae                	mv	s7,a1
    800039b8:	4485                	li	s1,1
    bp = bread(dev, IBLOCK(inum, sb));
    800039ba:	0001ca17          	auipc	s4,0x1c
    800039be:	82ea0a13          	addi	s4,s4,-2002 # 8001f1e8 <sb>
    800039c2:	00048b1b          	sext.w	s6,s1
    800039c6:	0044d593          	srli	a1,s1,0x4
    800039ca:	018a2783          	lw	a5,24(s4)
    800039ce:	9dbd                	addw	a1,a1,a5
    800039d0:	8556                	mv	a0,s5
    800039d2:	00000097          	auipc	ra,0x0
    800039d6:	940080e7          	jalr	-1728(ra) # 80003312 <bread>
    800039da:	892a                	mv	s2,a0
    dip = (struct dinode*)bp->data + inum%IPB;
    800039dc:	05850993          	addi	s3,a0,88
    800039e0:	00f4f793          	andi	a5,s1,15
    800039e4:	079a                	slli	a5,a5,0x6
    800039e6:	99be                	add	s3,s3,a5
    if(dip->type == 0){  // a free inode
    800039e8:	00099783          	lh	a5,0(s3)
    800039ec:	c3a1                	beqz	a5,80003a2c <ialloc+0x9c>
    brelse(bp);
    800039ee:	00000097          	auipc	ra,0x0
    800039f2:	a54080e7          	jalr	-1452(ra) # 80003442 <brelse>
  for(inum = 1; inum < sb.ninodes; inum++){
    800039f6:	0485                	addi	s1,s1,1
    800039f8:	00ca2703          	lw	a4,12(s4)
    800039fc:	0004879b          	sext.w	a5,s1
    80003a00:	fce7e1e3          	bltu	a5,a4,800039c2 <ialloc+0x32>
  printf("ialloc: no inodes\n");
    80003a04:	00005517          	auipc	a0,0x5
    80003a08:	cfc50513          	addi	a0,a0,-772 # 80008700 <syscalls+0x190>
    80003a0c:	ffffd097          	auipc	ra,0xffffd
    80003a10:	b78080e7          	jalr	-1160(ra) # 80000584 <printf>
  return 0;
    80003a14:	4501                	li	a0,0
}
    80003a16:	60a6                	ld	ra,72(sp)
    80003a18:	6406                	ld	s0,64(sp)
    80003a1a:	74e2                	ld	s1,56(sp)
    80003a1c:	7942                	ld	s2,48(sp)
    80003a1e:	79a2                	ld	s3,40(sp)
    80003a20:	7a02                	ld	s4,32(sp)
    80003a22:	6ae2                	ld	s5,24(sp)
    80003a24:	6b42                	ld	s6,16(sp)
    80003a26:	6ba2                	ld	s7,8(sp)
    80003a28:	6161                	addi	sp,sp,80
    80003a2a:	8082                	ret
      memset(dip, 0, sizeof(*dip));
    80003a2c:	04000613          	li	a2,64
    80003a30:	4581                	li	a1,0
    80003a32:	854e                	mv	a0,s3
    80003a34:	ffffd097          	auipc	ra,0xffffd
    80003a38:	35e080e7          	jalr	862(ra) # 80000d92 <memset>
      dip->type = type;
    80003a3c:	01799023          	sh	s7,0(s3)
      log_write(bp);   // mark it allocated on the disk
    80003a40:	854a                	mv	a0,s2
    80003a42:	00001097          	auipc	ra,0x1
    80003a46:	c84080e7          	jalr	-892(ra) # 800046c6 <log_write>
      brelse(bp);
    80003a4a:	854a                	mv	a0,s2
    80003a4c:	00000097          	auipc	ra,0x0
    80003a50:	9f6080e7          	jalr	-1546(ra) # 80003442 <brelse>
      return iget(dev, inum);
    80003a54:	85da                	mv	a1,s6
    80003a56:	8556                	mv	a0,s5
    80003a58:	00000097          	auipc	ra,0x0
    80003a5c:	d9c080e7          	jalr	-612(ra) # 800037f4 <iget>
    80003a60:	bf5d                	j	80003a16 <ialloc+0x86>

0000000080003a62 <iupdate>:
{
    80003a62:	1101                	addi	sp,sp,-32
    80003a64:	ec06                	sd	ra,24(sp)
    80003a66:	e822                	sd	s0,16(sp)
    80003a68:	e426                	sd	s1,8(sp)
    80003a6a:	e04a                	sd	s2,0(sp)
    80003a6c:	1000                	addi	s0,sp,32
    80003a6e:	84aa                	mv	s1,a0
  bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    80003a70:	415c                	lw	a5,4(a0)
    80003a72:	0047d79b          	srliw	a5,a5,0x4
    80003a76:	0001b597          	auipc	a1,0x1b
    80003a7a:	78a5a583          	lw	a1,1930(a1) # 8001f200 <sb+0x18>
    80003a7e:	9dbd                	addw	a1,a1,a5
    80003a80:	4108                	lw	a0,0(a0)
    80003a82:	00000097          	auipc	ra,0x0
    80003a86:	890080e7          	jalr	-1904(ra) # 80003312 <bread>
    80003a8a:	892a                	mv	s2,a0
  dip = (struct dinode*)bp->data + ip->inum%IPB;
    80003a8c:	05850793          	addi	a5,a0,88
    80003a90:	40c8                	lw	a0,4(s1)
    80003a92:	893d                	andi	a0,a0,15
    80003a94:	051a                	slli	a0,a0,0x6
    80003a96:	953e                	add	a0,a0,a5
  dip->type = ip->type;
    80003a98:	04449703          	lh	a4,68(s1)
    80003a9c:	00e51023          	sh	a4,0(a0)
  dip->major = ip->major;
    80003aa0:	04649703          	lh	a4,70(s1)
    80003aa4:	00e51123          	sh	a4,2(a0)
  dip->minor = ip->minor;
    80003aa8:	04849703          	lh	a4,72(s1)
    80003aac:	00e51223          	sh	a4,4(a0)
  dip->nlink = ip->nlink;
    80003ab0:	04a49703          	lh	a4,74(s1)
    80003ab4:	00e51323          	sh	a4,6(a0)
  dip->size = ip->size;
    80003ab8:	44f8                	lw	a4,76(s1)
    80003aba:	c518                	sw	a4,8(a0)
  memmove(dip->addrs, ip->addrs, sizeof(ip->addrs));
    80003abc:	03400613          	li	a2,52
    80003ac0:	05048593          	addi	a1,s1,80
    80003ac4:	0531                	addi	a0,a0,12
    80003ac6:	ffffd097          	auipc	ra,0xffffd
    80003aca:	32c080e7          	jalr	812(ra) # 80000df2 <memmove>
  log_write(bp);
    80003ace:	854a                	mv	a0,s2
    80003ad0:	00001097          	auipc	ra,0x1
    80003ad4:	bf6080e7          	jalr	-1034(ra) # 800046c6 <log_write>
  brelse(bp);
    80003ad8:	854a                	mv	a0,s2
    80003ada:	00000097          	auipc	ra,0x0
    80003ade:	968080e7          	jalr	-1688(ra) # 80003442 <brelse>
}
    80003ae2:	60e2                	ld	ra,24(sp)
    80003ae4:	6442                	ld	s0,16(sp)
    80003ae6:	64a2                	ld	s1,8(sp)
    80003ae8:	6902                	ld	s2,0(sp)
    80003aea:	6105                	addi	sp,sp,32
    80003aec:	8082                	ret

0000000080003aee <idup>:
{
    80003aee:	1101                	addi	sp,sp,-32
    80003af0:	ec06                	sd	ra,24(sp)
    80003af2:	e822                	sd	s0,16(sp)
    80003af4:	e426                	sd	s1,8(sp)
    80003af6:	1000                	addi	s0,sp,32
    80003af8:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    80003afa:	0001b517          	auipc	a0,0x1b
    80003afe:	70e50513          	addi	a0,a0,1806 # 8001f208 <itable>
    80003b02:	ffffd097          	auipc	ra,0xffffd
    80003b06:	194080e7          	jalr	404(ra) # 80000c96 <acquire>
  ip->ref++;
    80003b0a:	449c                	lw	a5,8(s1)
    80003b0c:	2785                	addiw	a5,a5,1
    80003b0e:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    80003b10:	0001b517          	auipc	a0,0x1b
    80003b14:	6f850513          	addi	a0,a0,1784 # 8001f208 <itable>
    80003b18:	ffffd097          	auipc	ra,0xffffd
    80003b1c:	232080e7          	jalr	562(ra) # 80000d4a <release>
}
    80003b20:	8526                	mv	a0,s1
    80003b22:	60e2                	ld	ra,24(sp)
    80003b24:	6442                	ld	s0,16(sp)
    80003b26:	64a2                	ld	s1,8(sp)
    80003b28:	6105                	addi	sp,sp,32
    80003b2a:	8082                	ret

0000000080003b2c <ilock>:
{
    80003b2c:	1101                	addi	sp,sp,-32
    80003b2e:	ec06                	sd	ra,24(sp)
    80003b30:	e822                	sd	s0,16(sp)
    80003b32:	e426                	sd	s1,8(sp)
    80003b34:	e04a                	sd	s2,0(sp)
    80003b36:	1000                	addi	s0,sp,32
  if(ip == 0 || ip->ref < 1)
    80003b38:	c115                	beqz	a0,80003b5c <ilock+0x30>
    80003b3a:	84aa                	mv	s1,a0
    80003b3c:	451c                	lw	a5,8(a0)
    80003b3e:	00f05f63          	blez	a5,80003b5c <ilock+0x30>
  acquiresleep(&ip->lock);
    80003b42:	0541                	addi	a0,a0,16
    80003b44:	00001097          	auipc	ra,0x1
    80003b48:	ca2080e7          	jalr	-862(ra) # 800047e6 <acquiresleep>
  if(ip->valid == 0){
    80003b4c:	40bc                	lw	a5,64(s1)
    80003b4e:	cf99                	beqz	a5,80003b6c <ilock+0x40>
}
    80003b50:	60e2                	ld	ra,24(sp)
    80003b52:	6442                	ld	s0,16(sp)
    80003b54:	64a2                	ld	s1,8(sp)
    80003b56:	6902                	ld	s2,0(sp)
    80003b58:	6105                	addi	sp,sp,32
    80003b5a:	8082                	ret
    panic("ilock");
    80003b5c:	00005517          	auipc	a0,0x5
    80003b60:	bbc50513          	addi	a0,a0,-1092 # 80008718 <syscalls+0x1a8>
    80003b64:	ffffd097          	auipc	ra,0xffffd
    80003b68:	9c4080e7          	jalr	-1596(ra) # 80000528 <panic>
    bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    80003b6c:	40dc                	lw	a5,4(s1)
    80003b6e:	0047d79b          	srliw	a5,a5,0x4
    80003b72:	0001b597          	auipc	a1,0x1b
    80003b76:	68e5a583          	lw	a1,1678(a1) # 8001f200 <sb+0x18>
    80003b7a:	9dbd                	addw	a1,a1,a5
    80003b7c:	4088                	lw	a0,0(s1)
    80003b7e:	fffff097          	auipc	ra,0xfffff
    80003b82:	794080e7          	jalr	1940(ra) # 80003312 <bread>
    80003b86:	892a                	mv	s2,a0
    dip = (struct dinode*)bp->data + ip->inum%IPB;
    80003b88:	05850593          	addi	a1,a0,88
    80003b8c:	40dc                	lw	a5,4(s1)
    80003b8e:	8bbd                	andi	a5,a5,15
    80003b90:	079a                	slli	a5,a5,0x6
    80003b92:	95be                	add	a1,a1,a5
    ip->type = dip->type;
    80003b94:	00059783          	lh	a5,0(a1)
    80003b98:	04f49223          	sh	a5,68(s1)
    ip->major = dip->major;
    80003b9c:	00259783          	lh	a5,2(a1)
    80003ba0:	04f49323          	sh	a5,70(s1)
    ip->minor = dip->minor;
    80003ba4:	00459783          	lh	a5,4(a1)
    80003ba8:	04f49423          	sh	a5,72(s1)
    ip->nlink = dip->nlink;
    80003bac:	00659783          	lh	a5,6(a1)
    80003bb0:	04f49523          	sh	a5,74(s1)
    ip->size = dip->size;
    80003bb4:	459c                	lw	a5,8(a1)
    80003bb6:	c4fc                	sw	a5,76(s1)
    memmove(ip->addrs, dip->addrs, sizeof(ip->addrs));
    80003bb8:	03400613          	li	a2,52
    80003bbc:	05b1                	addi	a1,a1,12
    80003bbe:	05048513          	addi	a0,s1,80
    80003bc2:	ffffd097          	auipc	ra,0xffffd
    80003bc6:	230080e7          	jalr	560(ra) # 80000df2 <memmove>
    brelse(bp);
    80003bca:	854a                	mv	a0,s2
    80003bcc:	00000097          	auipc	ra,0x0
    80003bd0:	876080e7          	jalr	-1930(ra) # 80003442 <brelse>
    ip->valid = 1;
    80003bd4:	4785                	li	a5,1
    80003bd6:	c0bc                	sw	a5,64(s1)
    if(ip->type == 0)
    80003bd8:	04449783          	lh	a5,68(s1)
    80003bdc:	fbb5                	bnez	a5,80003b50 <ilock+0x24>
      panic("ilock: no type");
    80003bde:	00005517          	auipc	a0,0x5
    80003be2:	b4250513          	addi	a0,a0,-1214 # 80008720 <syscalls+0x1b0>
    80003be6:	ffffd097          	auipc	ra,0xffffd
    80003bea:	942080e7          	jalr	-1726(ra) # 80000528 <panic>

0000000080003bee <iunlock>:
{
    80003bee:	1101                	addi	sp,sp,-32
    80003bf0:	ec06                	sd	ra,24(sp)
    80003bf2:	e822                	sd	s0,16(sp)
    80003bf4:	e426                	sd	s1,8(sp)
    80003bf6:	e04a                	sd	s2,0(sp)
    80003bf8:	1000                	addi	s0,sp,32
  if(ip == 0 || !holdingsleep(&ip->lock) || ip->ref < 1)
    80003bfa:	c905                	beqz	a0,80003c2a <iunlock+0x3c>
    80003bfc:	84aa                	mv	s1,a0
    80003bfe:	01050913          	addi	s2,a0,16
    80003c02:	854a                	mv	a0,s2
    80003c04:	00001097          	auipc	ra,0x1
    80003c08:	c7c080e7          	jalr	-900(ra) # 80004880 <holdingsleep>
    80003c0c:	cd19                	beqz	a0,80003c2a <iunlock+0x3c>
    80003c0e:	449c                	lw	a5,8(s1)
    80003c10:	00f05d63          	blez	a5,80003c2a <iunlock+0x3c>
  releasesleep(&ip->lock);
    80003c14:	854a                	mv	a0,s2
    80003c16:	00001097          	auipc	ra,0x1
    80003c1a:	c26080e7          	jalr	-986(ra) # 8000483c <releasesleep>
}
    80003c1e:	60e2                	ld	ra,24(sp)
    80003c20:	6442                	ld	s0,16(sp)
    80003c22:	64a2                	ld	s1,8(sp)
    80003c24:	6902                	ld	s2,0(sp)
    80003c26:	6105                	addi	sp,sp,32
    80003c28:	8082                	ret
    panic("iunlock");
    80003c2a:	00005517          	auipc	a0,0x5
    80003c2e:	b0650513          	addi	a0,a0,-1274 # 80008730 <syscalls+0x1c0>
    80003c32:	ffffd097          	auipc	ra,0xffffd
    80003c36:	8f6080e7          	jalr	-1802(ra) # 80000528 <panic>

0000000080003c3a <itrunc>:

// Truncate inode (discard contents).
// Caller must hold ip->lock.
void
itrunc(struct inode *ip)
{
    80003c3a:	7179                	addi	sp,sp,-48
    80003c3c:	f406                	sd	ra,40(sp)
    80003c3e:	f022                	sd	s0,32(sp)
    80003c40:	ec26                	sd	s1,24(sp)
    80003c42:	e84a                	sd	s2,16(sp)
    80003c44:	e44e                	sd	s3,8(sp)
    80003c46:	e052                	sd	s4,0(sp)
    80003c48:	1800                	addi	s0,sp,48
    80003c4a:	89aa                	mv	s3,a0
  int i, j;
  struct buf *bp;
  uint *a;

  for(i = 0; i < NDIRECT; i++){
    80003c4c:	05050493          	addi	s1,a0,80
    80003c50:	08050913          	addi	s2,a0,128
    80003c54:	a021                	j	80003c5c <itrunc+0x22>
    80003c56:	0491                	addi	s1,s1,4
    80003c58:	01248d63          	beq	s1,s2,80003c72 <itrunc+0x38>
    if(ip->addrs[i]){
    80003c5c:	408c                	lw	a1,0(s1)
    80003c5e:	dde5                	beqz	a1,80003c56 <itrunc+0x1c>
      bfree(ip->dev, ip->addrs[i]);
    80003c60:	0009a503          	lw	a0,0(s3)
    80003c64:	00000097          	auipc	ra,0x0
    80003c68:	8f4080e7          	jalr	-1804(ra) # 80003558 <bfree>
      ip->addrs[i] = 0;
    80003c6c:	0004a023          	sw	zero,0(s1)
    80003c70:	b7dd                	j	80003c56 <itrunc+0x1c>
    }
  }

  if(ip->addrs[NDIRECT]){
    80003c72:	0809a583          	lw	a1,128(s3)
    80003c76:	e185                	bnez	a1,80003c96 <itrunc+0x5c>
    brelse(bp);
    bfree(ip->dev, ip->addrs[NDIRECT]);
    ip->addrs[NDIRECT] = 0;
  }

  ip->size = 0;
    80003c78:	0409a623          	sw	zero,76(s3)
  iupdate(ip);
    80003c7c:	854e                	mv	a0,s3
    80003c7e:	00000097          	auipc	ra,0x0
    80003c82:	de4080e7          	jalr	-540(ra) # 80003a62 <iupdate>
}
    80003c86:	70a2                	ld	ra,40(sp)
    80003c88:	7402                	ld	s0,32(sp)
    80003c8a:	64e2                	ld	s1,24(sp)
    80003c8c:	6942                	ld	s2,16(sp)
    80003c8e:	69a2                	ld	s3,8(sp)
    80003c90:	6a02                	ld	s4,0(sp)
    80003c92:	6145                	addi	sp,sp,48
    80003c94:	8082                	ret
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
    80003c96:	0009a503          	lw	a0,0(s3)
    80003c9a:	fffff097          	auipc	ra,0xfffff
    80003c9e:	678080e7          	jalr	1656(ra) # 80003312 <bread>
    80003ca2:	8a2a                	mv	s4,a0
    for(j = 0; j < NINDIRECT; j++){
    80003ca4:	05850493          	addi	s1,a0,88
    80003ca8:	45850913          	addi	s2,a0,1112
    80003cac:	a811                	j	80003cc0 <itrunc+0x86>
        bfree(ip->dev, a[j]);
    80003cae:	0009a503          	lw	a0,0(s3)
    80003cb2:	00000097          	auipc	ra,0x0
    80003cb6:	8a6080e7          	jalr	-1882(ra) # 80003558 <bfree>
    for(j = 0; j < NINDIRECT; j++){
    80003cba:	0491                	addi	s1,s1,4
    80003cbc:	01248563          	beq	s1,s2,80003cc6 <itrunc+0x8c>
      if(a[j])
    80003cc0:	408c                	lw	a1,0(s1)
    80003cc2:	dde5                	beqz	a1,80003cba <itrunc+0x80>
    80003cc4:	b7ed                	j	80003cae <itrunc+0x74>
    brelse(bp);
    80003cc6:	8552                	mv	a0,s4
    80003cc8:	fffff097          	auipc	ra,0xfffff
    80003ccc:	77a080e7          	jalr	1914(ra) # 80003442 <brelse>
    bfree(ip->dev, ip->addrs[NDIRECT]);
    80003cd0:	0809a583          	lw	a1,128(s3)
    80003cd4:	0009a503          	lw	a0,0(s3)
    80003cd8:	00000097          	auipc	ra,0x0
    80003cdc:	880080e7          	jalr	-1920(ra) # 80003558 <bfree>
    ip->addrs[NDIRECT] = 0;
    80003ce0:	0809a023          	sw	zero,128(s3)
    80003ce4:	bf51                	j	80003c78 <itrunc+0x3e>

0000000080003ce6 <iput>:
{
    80003ce6:	1101                	addi	sp,sp,-32
    80003ce8:	ec06                	sd	ra,24(sp)
    80003cea:	e822                	sd	s0,16(sp)
    80003cec:	e426                	sd	s1,8(sp)
    80003cee:	e04a                	sd	s2,0(sp)
    80003cf0:	1000                	addi	s0,sp,32
    80003cf2:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    80003cf4:	0001b517          	auipc	a0,0x1b
    80003cf8:	51450513          	addi	a0,a0,1300 # 8001f208 <itable>
    80003cfc:	ffffd097          	auipc	ra,0xffffd
    80003d00:	f9a080e7          	jalr	-102(ra) # 80000c96 <acquire>
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    80003d04:	4498                	lw	a4,8(s1)
    80003d06:	4785                	li	a5,1
    80003d08:	02f70363          	beq	a4,a5,80003d2e <iput+0x48>
  ip->ref--;
    80003d0c:	449c                	lw	a5,8(s1)
    80003d0e:	37fd                	addiw	a5,a5,-1
    80003d10:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    80003d12:	0001b517          	auipc	a0,0x1b
    80003d16:	4f650513          	addi	a0,a0,1270 # 8001f208 <itable>
    80003d1a:	ffffd097          	auipc	ra,0xffffd
    80003d1e:	030080e7          	jalr	48(ra) # 80000d4a <release>
}
    80003d22:	60e2                	ld	ra,24(sp)
    80003d24:	6442                	ld	s0,16(sp)
    80003d26:	64a2                	ld	s1,8(sp)
    80003d28:	6902                	ld	s2,0(sp)
    80003d2a:	6105                	addi	sp,sp,32
    80003d2c:	8082                	ret
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    80003d2e:	40bc                	lw	a5,64(s1)
    80003d30:	dff1                	beqz	a5,80003d0c <iput+0x26>
    80003d32:	04a49783          	lh	a5,74(s1)
    80003d36:	fbf9                	bnez	a5,80003d0c <iput+0x26>
    acquiresleep(&ip->lock);
    80003d38:	01048913          	addi	s2,s1,16
    80003d3c:	854a                	mv	a0,s2
    80003d3e:	00001097          	auipc	ra,0x1
    80003d42:	aa8080e7          	jalr	-1368(ra) # 800047e6 <acquiresleep>
    release(&itable.lock);
    80003d46:	0001b517          	auipc	a0,0x1b
    80003d4a:	4c250513          	addi	a0,a0,1218 # 8001f208 <itable>
    80003d4e:	ffffd097          	auipc	ra,0xffffd
    80003d52:	ffc080e7          	jalr	-4(ra) # 80000d4a <release>
    itrunc(ip);
    80003d56:	8526                	mv	a0,s1
    80003d58:	00000097          	auipc	ra,0x0
    80003d5c:	ee2080e7          	jalr	-286(ra) # 80003c3a <itrunc>
    ip->type = 0;
    80003d60:	04049223          	sh	zero,68(s1)
    iupdate(ip);
    80003d64:	8526                	mv	a0,s1
    80003d66:	00000097          	auipc	ra,0x0
    80003d6a:	cfc080e7          	jalr	-772(ra) # 80003a62 <iupdate>
    ip->valid = 0;
    80003d6e:	0404a023          	sw	zero,64(s1)
    releasesleep(&ip->lock);
    80003d72:	854a                	mv	a0,s2
    80003d74:	00001097          	auipc	ra,0x1
    80003d78:	ac8080e7          	jalr	-1336(ra) # 8000483c <releasesleep>
    acquire(&itable.lock);
    80003d7c:	0001b517          	auipc	a0,0x1b
    80003d80:	48c50513          	addi	a0,a0,1164 # 8001f208 <itable>
    80003d84:	ffffd097          	auipc	ra,0xffffd
    80003d88:	f12080e7          	jalr	-238(ra) # 80000c96 <acquire>
    80003d8c:	b741                	j	80003d0c <iput+0x26>

0000000080003d8e <iunlockput>:
{
    80003d8e:	1101                	addi	sp,sp,-32
    80003d90:	ec06                	sd	ra,24(sp)
    80003d92:	e822                	sd	s0,16(sp)
    80003d94:	e426                	sd	s1,8(sp)
    80003d96:	1000                	addi	s0,sp,32
    80003d98:	84aa                	mv	s1,a0
  iunlock(ip);
    80003d9a:	00000097          	auipc	ra,0x0
    80003d9e:	e54080e7          	jalr	-428(ra) # 80003bee <iunlock>
  iput(ip);
    80003da2:	8526                	mv	a0,s1
    80003da4:	00000097          	auipc	ra,0x0
    80003da8:	f42080e7          	jalr	-190(ra) # 80003ce6 <iput>
}
    80003dac:	60e2                	ld	ra,24(sp)
    80003dae:	6442                	ld	s0,16(sp)
    80003db0:	64a2                	ld	s1,8(sp)
    80003db2:	6105                	addi	sp,sp,32
    80003db4:	8082                	ret

0000000080003db6 <stati>:

// Copy stat information from inode.
// Caller must hold ip->lock.
void
stati(struct inode *ip, struct stat *st)
{
    80003db6:	1141                	addi	sp,sp,-16
    80003db8:	e422                	sd	s0,8(sp)
    80003dba:	0800                	addi	s0,sp,16
  st->dev = ip->dev;
    80003dbc:	411c                	lw	a5,0(a0)
    80003dbe:	c19c                	sw	a5,0(a1)
  st->ino = ip->inum;
    80003dc0:	415c                	lw	a5,4(a0)
    80003dc2:	c1dc                	sw	a5,4(a1)
  st->type = ip->type;
    80003dc4:	04451783          	lh	a5,68(a0)
    80003dc8:	00f59423          	sh	a5,8(a1)
  st->nlink = ip->nlink;
    80003dcc:	04a51783          	lh	a5,74(a0)
    80003dd0:	00f59523          	sh	a5,10(a1)
  st->size = ip->size;
    80003dd4:	04c56783          	lwu	a5,76(a0)
    80003dd8:	e99c                	sd	a5,16(a1)
}
    80003dda:	6422                	ld	s0,8(sp)
    80003ddc:	0141                	addi	sp,sp,16
    80003dde:	8082                	ret

0000000080003de0 <readi>:
readi(struct inode *ip, int user_dst, uint64 dst, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    80003de0:	457c                	lw	a5,76(a0)
    80003de2:	0ed7e963          	bltu	a5,a3,80003ed4 <readi+0xf4>
{
    80003de6:	7159                	addi	sp,sp,-112
    80003de8:	f486                	sd	ra,104(sp)
    80003dea:	f0a2                	sd	s0,96(sp)
    80003dec:	eca6                	sd	s1,88(sp)
    80003dee:	e8ca                	sd	s2,80(sp)
    80003df0:	e4ce                	sd	s3,72(sp)
    80003df2:	e0d2                	sd	s4,64(sp)
    80003df4:	fc56                	sd	s5,56(sp)
    80003df6:	f85a                	sd	s6,48(sp)
    80003df8:	f45e                	sd	s7,40(sp)
    80003dfa:	f062                	sd	s8,32(sp)
    80003dfc:	ec66                	sd	s9,24(sp)
    80003dfe:	e86a                	sd	s10,16(sp)
    80003e00:	e46e                	sd	s11,8(sp)
    80003e02:	1880                	addi	s0,sp,112
    80003e04:	8b2a                	mv	s6,a0
    80003e06:	8bae                	mv	s7,a1
    80003e08:	8a32                	mv	s4,a2
    80003e0a:	84b6                	mv	s1,a3
    80003e0c:	8aba                	mv	s5,a4
  if(off > ip->size || off + n < off)
    80003e0e:	9f35                	addw	a4,a4,a3
    return 0;
    80003e10:	4501                	li	a0,0
  if(off > ip->size || off + n < off)
    80003e12:	0ad76063          	bltu	a4,a3,80003eb2 <readi+0xd2>
  if(off + n > ip->size)
    80003e16:	00e7f463          	bgeu	a5,a4,80003e1e <readi+0x3e>
    n = ip->size - off;
    80003e1a:	40d78abb          	subw	s5,a5,a3

  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80003e1e:	0a0a8963          	beqz	s5,80003ed0 <readi+0xf0>
    80003e22:	4981                	li	s3,0
    uint addr = bmap(ip, off/BSIZE);
    if(addr == 0)
      break;
    bp = bread(ip->dev, addr);
    m = min(n - tot, BSIZE - off%BSIZE);
    80003e24:	40000c93          	li	s9,1024
    if(either_copyout(user_dst, dst, bp->data + (off % BSIZE), m) == -1) {
    80003e28:	5c7d                	li	s8,-1
    80003e2a:	a82d                	j	80003e64 <readi+0x84>
    80003e2c:	020d1d93          	slli	s11,s10,0x20
    80003e30:	020ddd93          	srli	s11,s11,0x20
    80003e34:	05890613          	addi	a2,s2,88
    80003e38:	86ee                	mv	a3,s11
    80003e3a:	963a                	add	a2,a2,a4
    80003e3c:	85d2                	mv	a1,s4
    80003e3e:	855e                	mv	a0,s7
    80003e40:	fffff097          	auipc	ra,0xfffff
    80003e44:	89c080e7          	jalr	-1892(ra) # 800026dc <either_copyout>
    80003e48:	05850d63          	beq	a0,s8,80003ea2 <readi+0xc2>
      brelse(bp);
      tot = -1;
      break;
    }
    brelse(bp);
    80003e4c:	854a                	mv	a0,s2
    80003e4e:	fffff097          	auipc	ra,0xfffff
    80003e52:	5f4080e7          	jalr	1524(ra) # 80003442 <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80003e56:	013d09bb          	addw	s3,s10,s3
    80003e5a:	009d04bb          	addw	s1,s10,s1
    80003e5e:	9a6e                	add	s4,s4,s11
    80003e60:	0559f763          	bgeu	s3,s5,80003eae <readi+0xce>
    uint addr = bmap(ip, off/BSIZE);
    80003e64:	00a4d59b          	srliw	a1,s1,0xa
    80003e68:	855a                	mv	a0,s6
    80003e6a:	00000097          	auipc	ra,0x0
    80003e6e:	8a2080e7          	jalr	-1886(ra) # 8000370c <bmap>
    80003e72:	0005059b          	sext.w	a1,a0
    if(addr == 0)
    80003e76:	cd85                	beqz	a1,80003eae <readi+0xce>
    bp = bread(ip->dev, addr);
    80003e78:	000b2503          	lw	a0,0(s6)
    80003e7c:	fffff097          	auipc	ra,0xfffff
    80003e80:	496080e7          	jalr	1174(ra) # 80003312 <bread>
    80003e84:	892a                	mv	s2,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    80003e86:	3ff4f713          	andi	a4,s1,1023
    80003e8a:	40ec87bb          	subw	a5,s9,a4
    80003e8e:	413a86bb          	subw	a3,s5,s3
    80003e92:	8d3e                	mv	s10,a5
    80003e94:	2781                	sext.w	a5,a5
    80003e96:	0006861b          	sext.w	a2,a3
    80003e9a:	f8f679e3          	bgeu	a2,a5,80003e2c <readi+0x4c>
    80003e9e:	8d36                	mv	s10,a3
    80003ea0:	b771                	j	80003e2c <readi+0x4c>
      brelse(bp);
    80003ea2:	854a                	mv	a0,s2
    80003ea4:	fffff097          	auipc	ra,0xfffff
    80003ea8:	59e080e7          	jalr	1438(ra) # 80003442 <brelse>
      tot = -1;
    80003eac:	59fd                	li	s3,-1
  }
  return tot;
    80003eae:	0009851b          	sext.w	a0,s3
}
    80003eb2:	70a6                	ld	ra,104(sp)
    80003eb4:	7406                	ld	s0,96(sp)
    80003eb6:	64e6                	ld	s1,88(sp)
    80003eb8:	6946                	ld	s2,80(sp)
    80003eba:	69a6                	ld	s3,72(sp)
    80003ebc:	6a06                	ld	s4,64(sp)
    80003ebe:	7ae2                	ld	s5,56(sp)
    80003ec0:	7b42                	ld	s6,48(sp)
    80003ec2:	7ba2                	ld	s7,40(sp)
    80003ec4:	7c02                	ld	s8,32(sp)
    80003ec6:	6ce2                	ld	s9,24(sp)
    80003ec8:	6d42                	ld	s10,16(sp)
    80003eca:	6da2                	ld	s11,8(sp)
    80003ecc:	6165                	addi	sp,sp,112
    80003ece:	8082                	ret
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80003ed0:	89d6                	mv	s3,s5
    80003ed2:	bff1                	j	80003eae <readi+0xce>
    return 0;
    80003ed4:	4501                	li	a0,0
}
    80003ed6:	8082                	ret

0000000080003ed8 <writei>:
writei(struct inode *ip, int user_src, uint64 src, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    80003ed8:	457c                	lw	a5,76(a0)
    80003eda:	10d7e863          	bltu	a5,a3,80003fea <writei+0x112>
{
    80003ede:	7159                	addi	sp,sp,-112
    80003ee0:	f486                	sd	ra,104(sp)
    80003ee2:	f0a2                	sd	s0,96(sp)
    80003ee4:	eca6                	sd	s1,88(sp)
    80003ee6:	e8ca                	sd	s2,80(sp)
    80003ee8:	e4ce                	sd	s3,72(sp)
    80003eea:	e0d2                	sd	s4,64(sp)
    80003eec:	fc56                	sd	s5,56(sp)
    80003eee:	f85a                	sd	s6,48(sp)
    80003ef0:	f45e                	sd	s7,40(sp)
    80003ef2:	f062                	sd	s8,32(sp)
    80003ef4:	ec66                	sd	s9,24(sp)
    80003ef6:	e86a                	sd	s10,16(sp)
    80003ef8:	e46e                	sd	s11,8(sp)
    80003efa:	1880                	addi	s0,sp,112
    80003efc:	8aaa                	mv	s5,a0
    80003efe:	8bae                	mv	s7,a1
    80003f00:	8a32                	mv	s4,a2
    80003f02:	8936                	mv	s2,a3
    80003f04:	8b3a                	mv	s6,a4
  if(off > ip->size || off + n < off)
    80003f06:	00e687bb          	addw	a5,a3,a4
    80003f0a:	0ed7e263          	bltu	a5,a3,80003fee <writei+0x116>
    return -1;
  if(off + n > MAXFILE*BSIZE)
    80003f0e:	00043737          	lui	a4,0x43
    80003f12:	0ef76063          	bltu	a4,a5,80003ff2 <writei+0x11a>
    return -1;

  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80003f16:	0c0b0863          	beqz	s6,80003fe6 <writei+0x10e>
    80003f1a:	4981                	li	s3,0
    uint addr = bmap(ip, off/BSIZE);
    if(addr == 0)
      break;
    bp = bread(ip->dev, addr);
    m = min(n - tot, BSIZE - off%BSIZE);
    80003f1c:	40000c93          	li	s9,1024
    if(either_copyin(bp->data + (off % BSIZE), user_src, src, m) == -1) {
    80003f20:	5c7d                	li	s8,-1
    80003f22:	a091                	j	80003f66 <writei+0x8e>
    80003f24:	020d1d93          	slli	s11,s10,0x20
    80003f28:	020ddd93          	srli	s11,s11,0x20
    80003f2c:	05848513          	addi	a0,s1,88
    80003f30:	86ee                	mv	a3,s11
    80003f32:	8652                	mv	a2,s4
    80003f34:	85de                	mv	a1,s7
    80003f36:	953a                	add	a0,a0,a4
    80003f38:	ffffe097          	auipc	ra,0xffffe
    80003f3c:	7fa080e7          	jalr	2042(ra) # 80002732 <either_copyin>
    80003f40:	07850263          	beq	a0,s8,80003fa4 <writei+0xcc>
      brelse(bp);
      break;
    }
    log_write(bp);
    80003f44:	8526                	mv	a0,s1
    80003f46:	00000097          	auipc	ra,0x0
    80003f4a:	780080e7          	jalr	1920(ra) # 800046c6 <log_write>
    brelse(bp);
    80003f4e:	8526                	mv	a0,s1
    80003f50:	fffff097          	auipc	ra,0xfffff
    80003f54:	4f2080e7          	jalr	1266(ra) # 80003442 <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80003f58:	013d09bb          	addw	s3,s10,s3
    80003f5c:	012d093b          	addw	s2,s10,s2
    80003f60:	9a6e                	add	s4,s4,s11
    80003f62:	0569f663          	bgeu	s3,s6,80003fae <writei+0xd6>
    uint addr = bmap(ip, off/BSIZE);
    80003f66:	00a9559b          	srliw	a1,s2,0xa
    80003f6a:	8556                	mv	a0,s5
    80003f6c:	fffff097          	auipc	ra,0xfffff
    80003f70:	7a0080e7          	jalr	1952(ra) # 8000370c <bmap>
    80003f74:	0005059b          	sext.w	a1,a0
    if(addr == 0)
    80003f78:	c99d                	beqz	a1,80003fae <writei+0xd6>
    bp = bread(ip->dev, addr);
    80003f7a:	000aa503          	lw	a0,0(s5)
    80003f7e:	fffff097          	auipc	ra,0xfffff
    80003f82:	394080e7          	jalr	916(ra) # 80003312 <bread>
    80003f86:	84aa                	mv	s1,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    80003f88:	3ff97713          	andi	a4,s2,1023
    80003f8c:	40ec87bb          	subw	a5,s9,a4
    80003f90:	413b06bb          	subw	a3,s6,s3
    80003f94:	8d3e                	mv	s10,a5
    80003f96:	2781                	sext.w	a5,a5
    80003f98:	0006861b          	sext.w	a2,a3
    80003f9c:	f8f674e3          	bgeu	a2,a5,80003f24 <writei+0x4c>
    80003fa0:	8d36                	mv	s10,a3
    80003fa2:	b749                	j	80003f24 <writei+0x4c>
      brelse(bp);
    80003fa4:	8526                	mv	a0,s1
    80003fa6:	fffff097          	auipc	ra,0xfffff
    80003faa:	49c080e7          	jalr	1180(ra) # 80003442 <brelse>
  }

  if(off > ip->size)
    80003fae:	04caa783          	lw	a5,76(s5)
    80003fb2:	0127f463          	bgeu	a5,s2,80003fba <writei+0xe2>
    ip->size = off;
    80003fb6:	052aa623          	sw	s2,76(s5)

  // write the i-node back to disk even if the size didn't change
  // because the loop above might have called bmap() and added a new
  // block to ip->addrs[].
  iupdate(ip);
    80003fba:	8556                	mv	a0,s5
    80003fbc:	00000097          	auipc	ra,0x0
    80003fc0:	aa6080e7          	jalr	-1370(ra) # 80003a62 <iupdate>

  return tot;
    80003fc4:	0009851b          	sext.w	a0,s3
}
    80003fc8:	70a6                	ld	ra,104(sp)
    80003fca:	7406                	ld	s0,96(sp)
    80003fcc:	64e6                	ld	s1,88(sp)
    80003fce:	6946                	ld	s2,80(sp)
    80003fd0:	69a6                	ld	s3,72(sp)
    80003fd2:	6a06                	ld	s4,64(sp)
    80003fd4:	7ae2                	ld	s5,56(sp)
    80003fd6:	7b42                	ld	s6,48(sp)
    80003fd8:	7ba2                	ld	s7,40(sp)
    80003fda:	7c02                	ld	s8,32(sp)
    80003fdc:	6ce2                	ld	s9,24(sp)
    80003fde:	6d42                	ld	s10,16(sp)
    80003fe0:	6da2                	ld	s11,8(sp)
    80003fe2:	6165                	addi	sp,sp,112
    80003fe4:	8082                	ret
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80003fe6:	89da                	mv	s3,s6
    80003fe8:	bfc9                	j	80003fba <writei+0xe2>
    return -1;
    80003fea:	557d                	li	a0,-1
}
    80003fec:	8082                	ret
    return -1;
    80003fee:	557d                	li	a0,-1
    80003ff0:	bfe1                	j	80003fc8 <writei+0xf0>
    return -1;
    80003ff2:	557d                	li	a0,-1
    80003ff4:	bfd1                	j	80003fc8 <writei+0xf0>

0000000080003ff6 <namecmp>:

// Directories

int
namecmp(const char *s, const char *t)
{
    80003ff6:	1141                	addi	sp,sp,-16
    80003ff8:	e406                	sd	ra,8(sp)
    80003ffa:	e022                	sd	s0,0(sp)
    80003ffc:	0800                	addi	s0,sp,16
  return strncmp(s, t, DIRSIZ);
    80003ffe:	4639                	li	a2,14
    80004000:	ffffd097          	auipc	ra,0xffffd
    80004004:	e6a080e7          	jalr	-406(ra) # 80000e6a <strncmp>
}
    80004008:	60a2                	ld	ra,8(sp)
    8000400a:	6402                	ld	s0,0(sp)
    8000400c:	0141                	addi	sp,sp,16
    8000400e:	8082                	ret

0000000080004010 <dirlookup>:

// Look for a directory entry in a directory.
// If found, set *poff to byte offset of entry.
struct inode*
dirlookup(struct inode *dp, char *name, uint *poff)
{
    80004010:	7139                	addi	sp,sp,-64
    80004012:	fc06                	sd	ra,56(sp)
    80004014:	f822                	sd	s0,48(sp)
    80004016:	f426                	sd	s1,40(sp)
    80004018:	f04a                	sd	s2,32(sp)
    8000401a:	ec4e                	sd	s3,24(sp)
    8000401c:	e852                	sd	s4,16(sp)
    8000401e:	0080                	addi	s0,sp,64
  uint off, inum;
  struct dirent de;

  if(dp->type != T_DIR)
    80004020:	04451703          	lh	a4,68(a0)
    80004024:	4785                	li	a5,1
    80004026:	00f71a63          	bne	a4,a5,8000403a <dirlookup+0x2a>
    8000402a:	892a                	mv	s2,a0
    8000402c:	89ae                	mv	s3,a1
    8000402e:	8a32                	mv	s4,a2
    panic("dirlookup not DIR");

  for(off = 0; off < dp->size; off += sizeof(de)){
    80004030:	457c                	lw	a5,76(a0)
    80004032:	4481                	li	s1,0
      inum = de.inum;
      return iget(dp->dev, inum);
    }
  }

  return 0;
    80004034:	4501                	li	a0,0
  for(off = 0; off < dp->size; off += sizeof(de)){
    80004036:	e79d                	bnez	a5,80004064 <dirlookup+0x54>
    80004038:	a8a5                	j	800040b0 <dirlookup+0xa0>
    panic("dirlookup not DIR");
    8000403a:	00004517          	auipc	a0,0x4
    8000403e:	6fe50513          	addi	a0,a0,1790 # 80008738 <syscalls+0x1c8>
    80004042:	ffffc097          	auipc	ra,0xffffc
    80004046:	4e6080e7          	jalr	1254(ra) # 80000528 <panic>
      panic("dirlookup read");
    8000404a:	00004517          	auipc	a0,0x4
    8000404e:	70650513          	addi	a0,a0,1798 # 80008750 <syscalls+0x1e0>
    80004052:	ffffc097          	auipc	ra,0xffffc
    80004056:	4d6080e7          	jalr	1238(ra) # 80000528 <panic>
  for(off = 0; off < dp->size; off += sizeof(de)){
    8000405a:	24c1                	addiw	s1,s1,16
    8000405c:	04c92783          	lw	a5,76(s2)
    80004060:	04f4f763          	bgeu	s1,a5,800040ae <dirlookup+0x9e>
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80004064:	4741                	li	a4,16
    80004066:	86a6                	mv	a3,s1
    80004068:	fc040613          	addi	a2,s0,-64
    8000406c:	4581                	li	a1,0
    8000406e:	854a                	mv	a0,s2
    80004070:	00000097          	auipc	ra,0x0
    80004074:	d70080e7          	jalr	-656(ra) # 80003de0 <readi>
    80004078:	47c1                	li	a5,16
    8000407a:	fcf518e3          	bne	a0,a5,8000404a <dirlookup+0x3a>
    if(de.inum == 0)
    8000407e:	fc045783          	lhu	a5,-64(s0)
    80004082:	dfe1                	beqz	a5,8000405a <dirlookup+0x4a>
    if(namecmp(name, de.name) == 0){
    80004084:	fc240593          	addi	a1,s0,-62
    80004088:	854e                	mv	a0,s3
    8000408a:	00000097          	auipc	ra,0x0
    8000408e:	f6c080e7          	jalr	-148(ra) # 80003ff6 <namecmp>
    80004092:	f561                	bnez	a0,8000405a <dirlookup+0x4a>
      if(poff)
    80004094:	000a0463          	beqz	s4,8000409c <dirlookup+0x8c>
        *poff = off;
    80004098:	009a2023          	sw	s1,0(s4)
      return iget(dp->dev, inum);
    8000409c:	fc045583          	lhu	a1,-64(s0)
    800040a0:	00092503          	lw	a0,0(s2)
    800040a4:	fffff097          	auipc	ra,0xfffff
    800040a8:	750080e7          	jalr	1872(ra) # 800037f4 <iget>
    800040ac:	a011                	j	800040b0 <dirlookup+0xa0>
  return 0;
    800040ae:	4501                	li	a0,0
}
    800040b0:	70e2                	ld	ra,56(sp)
    800040b2:	7442                	ld	s0,48(sp)
    800040b4:	74a2                	ld	s1,40(sp)
    800040b6:	7902                	ld	s2,32(sp)
    800040b8:	69e2                	ld	s3,24(sp)
    800040ba:	6a42                	ld	s4,16(sp)
    800040bc:	6121                	addi	sp,sp,64
    800040be:	8082                	ret

00000000800040c0 <namex>:
// If parent != 0, return the inode for the parent and copy the final
// path element into name, which must have room for DIRSIZ bytes.
// Must be called inside a transaction since it calls iput().
static struct inode*
namex(char *path, int nameiparent, char *name)
{
    800040c0:	711d                	addi	sp,sp,-96
    800040c2:	ec86                	sd	ra,88(sp)
    800040c4:	e8a2                	sd	s0,80(sp)
    800040c6:	e4a6                	sd	s1,72(sp)
    800040c8:	e0ca                	sd	s2,64(sp)
    800040ca:	fc4e                	sd	s3,56(sp)
    800040cc:	f852                	sd	s4,48(sp)
    800040ce:	f456                	sd	s5,40(sp)
    800040d0:	f05a                	sd	s6,32(sp)
    800040d2:	ec5e                	sd	s7,24(sp)
    800040d4:	e862                	sd	s8,16(sp)
    800040d6:	e466                	sd	s9,8(sp)
    800040d8:	1080                	addi	s0,sp,96
    800040da:	84aa                	mv	s1,a0
    800040dc:	8b2e                	mv	s6,a1
    800040de:	8ab2                	mv	s5,a2
  struct inode *ip, *next;

  if(*path == '/')
    800040e0:	00054703          	lbu	a4,0(a0)
    800040e4:	02f00793          	li	a5,47
    800040e8:	02f70363          	beq	a4,a5,8000410e <namex+0x4e>
    ip = iget(ROOTDEV, ROOTINO);
  else
    ip = idup(myproc()->cwd);
    800040ec:	ffffe097          	auipc	ra,0xffffe
    800040f0:	a84080e7          	jalr	-1404(ra) # 80001b70 <myproc>
    800040f4:	15053503          	ld	a0,336(a0)
    800040f8:	00000097          	auipc	ra,0x0
    800040fc:	9f6080e7          	jalr	-1546(ra) # 80003aee <idup>
    80004100:	89aa                	mv	s3,a0
  while(*path == '/')
    80004102:	02f00913          	li	s2,47
  len = path - s;
    80004106:	4b81                	li	s7,0
  if(len >= DIRSIZ)
    80004108:	4cb5                	li	s9,13

  while((path = skipelem(path, name)) != 0){
    ilock(ip);
    if(ip->type != T_DIR){
    8000410a:	4c05                	li	s8,1
    8000410c:	a865                	j	800041c4 <namex+0x104>
    ip = iget(ROOTDEV, ROOTINO);
    8000410e:	4585                	li	a1,1
    80004110:	4505                	li	a0,1
    80004112:	fffff097          	auipc	ra,0xfffff
    80004116:	6e2080e7          	jalr	1762(ra) # 800037f4 <iget>
    8000411a:	89aa                	mv	s3,a0
    8000411c:	b7dd                	j	80004102 <namex+0x42>
      iunlockput(ip);
    8000411e:	854e                	mv	a0,s3
    80004120:	00000097          	auipc	ra,0x0
    80004124:	c6e080e7          	jalr	-914(ra) # 80003d8e <iunlockput>
      return 0;
    80004128:	4981                	li	s3,0
  if(nameiparent){
    iput(ip);
    return 0;
  }
  return ip;
}
    8000412a:	854e                	mv	a0,s3
    8000412c:	60e6                	ld	ra,88(sp)
    8000412e:	6446                	ld	s0,80(sp)
    80004130:	64a6                	ld	s1,72(sp)
    80004132:	6906                	ld	s2,64(sp)
    80004134:	79e2                	ld	s3,56(sp)
    80004136:	7a42                	ld	s4,48(sp)
    80004138:	7aa2                	ld	s5,40(sp)
    8000413a:	7b02                	ld	s6,32(sp)
    8000413c:	6be2                	ld	s7,24(sp)
    8000413e:	6c42                	ld	s8,16(sp)
    80004140:	6ca2                	ld	s9,8(sp)
    80004142:	6125                	addi	sp,sp,96
    80004144:	8082                	ret
      iunlock(ip);
    80004146:	854e                	mv	a0,s3
    80004148:	00000097          	auipc	ra,0x0
    8000414c:	aa6080e7          	jalr	-1370(ra) # 80003bee <iunlock>
      return ip;
    80004150:	bfe9                	j	8000412a <namex+0x6a>
      iunlockput(ip);
    80004152:	854e                	mv	a0,s3
    80004154:	00000097          	auipc	ra,0x0
    80004158:	c3a080e7          	jalr	-966(ra) # 80003d8e <iunlockput>
      return 0;
    8000415c:	89d2                	mv	s3,s4
    8000415e:	b7f1                	j	8000412a <namex+0x6a>
  len = path - s;
    80004160:	40b48633          	sub	a2,s1,a1
    80004164:	00060a1b          	sext.w	s4,a2
  if(len >= DIRSIZ)
    80004168:	094cd463          	bge	s9,s4,800041f0 <namex+0x130>
    memmove(name, s, DIRSIZ);
    8000416c:	4639                	li	a2,14
    8000416e:	8556                	mv	a0,s5
    80004170:	ffffd097          	auipc	ra,0xffffd
    80004174:	c82080e7          	jalr	-894(ra) # 80000df2 <memmove>
  while(*path == '/')
    80004178:	0004c783          	lbu	a5,0(s1)
    8000417c:	01279763          	bne	a5,s2,8000418a <namex+0xca>
    path++;
    80004180:	0485                	addi	s1,s1,1
  while(*path == '/')
    80004182:	0004c783          	lbu	a5,0(s1)
    80004186:	ff278de3          	beq	a5,s2,80004180 <namex+0xc0>
    ilock(ip);
    8000418a:	854e                	mv	a0,s3
    8000418c:	00000097          	auipc	ra,0x0
    80004190:	9a0080e7          	jalr	-1632(ra) # 80003b2c <ilock>
    if(ip->type != T_DIR){
    80004194:	04499783          	lh	a5,68(s3)
    80004198:	f98793e3          	bne	a5,s8,8000411e <namex+0x5e>
    if(nameiparent && *path == '\0'){
    8000419c:	000b0563          	beqz	s6,800041a6 <namex+0xe6>
    800041a0:	0004c783          	lbu	a5,0(s1)
    800041a4:	d3cd                	beqz	a5,80004146 <namex+0x86>
    if((next = dirlookup(ip, name, 0)) == 0){
    800041a6:	865e                	mv	a2,s7
    800041a8:	85d6                	mv	a1,s5
    800041aa:	854e                	mv	a0,s3
    800041ac:	00000097          	auipc	ra,0x0
    800041b0:	e64080e7          	jalr	-412(ra) # 80004010 <dirlookup>
    800041b4:	8a2a                	mv	s4,a0
    800041b6:	dd51                	beqz	a0,80004152 <namex+0x92>
    iunlockput(ip);
    800041b8:	854e                	mv	a0,s3
    800041ba:	00000097          	auipc	ra,0x0
    800041be:	bd4080e7          	jalr	-1068(ra) # 80003d8e <iunlockput>
    ip = next;
    800041c2:	89d2                	mv	s3,s4
  while(*path == '/')
    800041c4:	0004c783          	lbu	a5,0(s1)
    800041c8:	05279763          	bne	a5,s2,80004216 <namex+0x156>
    path++;
    800041cc:	0485                	addi	s1,s1,1
  while(*path == '/')
    800041ce:	0004c783          	lbu	a5,0(s1)
    800041d2:	ff278de3          	beq	a5,s2,800041cc <namex+0x10c>
  if(*path == 0)
    800041d6:	c79d                	beqz	a5,80004204 <namex+0x144>
    path++;
    800041d8:	85a6                	mv	a1,s1
  len = path - s;
    800041da:	8a5e                	mv	s4,s7
    800041dc:	865e                	mv	a2,s7
  while(*path != '/' && *path != 0)
    800041de:	01278963          	beq	a5,s2,800041f0 <namex+0x130>
    800041e2:	dfbd                	beqz	a5,80004160 <namex+0xa0>
    path++;
    800041e4:	0485                	addi	s1,s1,1
  while(*path != '/' && *path != 0)
    800041e6:	0004c783          	lbu	a5,0(s1)
    800041ea:	ff279ce3          	bne	a5,s2,800041e2 <namex+0x122>
    800041ee:	bf8d                	j	80004160 <namex+0xa0>
    memmove(name, s, len);
    800041f0:	2601                	sext.w	a2,a2
    800041f2:	8556                	mv	a0,s5
    800041f4:	ffffd097          	auipc	ra,0xffffd
    800041f8:	bfe080e7          	jalr	-1026(ra) # 80000df2 <memmove>
    name[len] = 0;
    800041fc:	9a56                	add	s4,s4,s5
    800041fe:	000a0023          	sb	zero,0(s4)
    80004202:	bf9d                	j	80004178 <namex+0xb8>
  if(nameiparent){
    80004204:	f20b03e3          	beqz	s6,8000412a <namex+0x6a>
    iput(ip);
    80004208:	854e                	mv	a0,s3
    8000420a:	00000097          	auipc	ra,0x0
    8000420e:	adc080e7          	jalr	-1316(ra) # 80003ce6 <iput>
    return 0;
    80004212:	4981                	li	s3,0
    80004214:	bf19                	j	8000412a <namex+0x6a>
  if(*path == 0)
    80004216:	d7fd                	beqz	a5,80004204 <namex+0x144>
  while(*path != '/' && *path != 0)
    80004218:	0004c783          	lbu	a5,0(s1)
    8000421c:	85a6                	mv	a1,s1
    8000421e:	b7d1                	j	800041e2 <namex+0x122>

0000000080004220 <dirlink>:
{
    80004220:	7139                	addi	sp,sp,-64
    80004222:	fc06                	sd	ra,56(sp)
    80004224:	f822                	sd	s0,48(sp)
    80004226:	f426                	sd	s1,40(sp)
    80004228:	f04a                	sd	s2,32(sp)
    8000422a:	ec4e                	sd	s3,24(sp)
    8000422c:	e852                	sd	s4,16(sp)
    8000422e:	0080                	addi	s0,sp,64
    80004230:	892a                	mv	s2,a0
    80004232:	8a2e                	mv	s4,a1
    80004234:	89b2                	mv	s3,a2
  if((ip = dirlookup(dp, name, 0)) != 0){
    80004236:	4601                	li	a2,0
    80004238:	00000097          	auipc	ra,0x0
    8000423c:	dd8080e7          	jalr	-552(ra) # 80004010 <dirlookup>
    80004240:	e93d                	bnez	a0,800042b6 <dirlink+0x96>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80004242:	04c92483          	lw	s1,76(s2)
    80004246:	c49d                	beqz	s1,80004274 <dirlink+0x54>
    80004248:	4481                	li	s1,0
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    8000424a:	4741                	li	a4,16
    8000424c:	86a6                	mv	a3,s1
    8000424e:	fc040613          	addi	a2,s0,-64
    80004252:	4581                	li	a1,0
    80004254:	854a                	mv	a0,s2
    80004256:	00000097          	auipc	ra,0x0
    8000425a:	b8a080e7          	jalr	-1142(ra) # 80003de0 <readi>
    8000425e:	47c1                	li	a5,16
    80004260:	06f51163          	bne	a0,a5,800042c2 <dirlink+0xa2>
    if(de.inum == 0)
    80004264:	fc045783          	lhu	a5,-64(s0)
    80004268:	c791                	beqz	a5,80004274 <dirlink+0x54>
  for(off = 0; off < dp->size; off += sizeof(de)){
    8000426a:	24c1                	addiw	s1,s1,16
    8000426c:	04c92783          	lw	a5,76(s2)
    80004270:	fcf4ede3          	bltu	s1,a5,8000424a <dirlink+0x2a>
  strncpy(de.name, name, DIRSIZ);
    80004274:	4639                	li	a2,14
    80004276:	85d2                	mv	a1,s4
    80004278:	fc240513          	addi	a0,s0,-62
    8000427c:	ffffd097          	auipc	ra,0xffffd
    80004280:	c2a080e7          	jalr	-982(ra) # 80000ea6 <strncpy>
  de.inum = inum;
    80004284:	fd341023          	sh	s3,-64(s0)
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80004288:	4741                	li	a4,16
    8000428a:	86a6                	mv	a3,s1
    8000428c:	fc040613          	addi	a2,s0,-64
    80004290:	4581                	li	a1,0
    80004292:	854a                	mv	a0,s2
    80004294:	00000097          	auipc	ra,0x0
    80004298:	c44080e7          	jalr	-956(ra) # 80003ed8 <writei>
    8000429c:	1541                	addi	a0,a0,-16
    8000429e:	00a03533          	snez	a0,a0
    800042a2:	40a00533          	neg	a0,a0
}
    800042a6:	70e2                	ld	ra,56(sp)
    800042a8:	7442                	ld	s0,48(sp)
    800042aa:	74a2                	ld	s1,40(sp)
    800042ac:	7902                	ld	s2,32(sp)
    800042ae:	69e2                	ld	s3,24(sp)
    800042b0:	6a42                	ld	s4,16(sp)
    800042b2:	6121                	addi	sp,sp,64
    800042b4:	8082                	ret
    iput(ip);
    800042b6:	00000097          	auipc	ra,0x0
    800042ba:	a30080e7          	jalr	-1488(ra) # 80003ce6 <iput>
    return -1;
    800042be:	557d                	li	a0,-1
    800042c0:	b7dd                	j	800042a6 <dirlink+0x86>
      panic("dirlink read");
    800042c2:	00004517          	auipc	a0,0x4
    800042c6:	49e50513          	addi	a0,a0,1182 # 80008760 <syscalls+0x1f0>
    800042ca:	ffffc097          	auipc	ra,0xffffc
    800042ce:	25e080e7          	jalr	606(ra) # 80000528 <panic>

00000000800042d2 <namei>:

struct inode*
namei(char *path)
{
    800042d2:	1101                	addi	sp,sp,-32
    800042d4:	ec06                	sd	ra,24(sp)
    800042d6:	e822                	sd	s0,16(sp)
    800042d8:	1000                	addi	s0,sp,32
  char name[DIRSIZ];
  return namex(path, 0, name);
    800042da:	fe040613          	addi	a2,s0,-32
    800042de:	4581                	li	a1,0
    800042e0:	00000097          	auipc	ra,0x0
    800042e4:	de0080e7          	jalr	-544(ra) # 800040c0 <namex>
}
    800042e8:	60e2                	ld	ra,24(sp)
    800042ea:	6442                	ld	s0,16(sp)
    800042ec:	6105                	addi	sp,sp,32
    800042ee:	8082                	ret

00000000800042f0 <nameiparent>:

struct inode*
nameiparent(char *path, char *name)
{
    800042f0:	1141                	addi	sp,sp,-16
    800042f2:	e406                	sd	ra,8(sp)
    800042f4:	e022                	sd	s0,0(sp)
    800042f6:	0800                	addi	s0,sp,16
    800042f8:	862e                	mv	a2,a1
  return namex(path, 1, name);
    800042fa:	4585                	li	a1,1
    800042fc:	00000097          	auipc	ra,0x0
    80004300:	dc4080e7          	jalr	-572(ra) # 800040c0 <namex>
}
    80004304:	60a2                	ld	ra,8(sp)
    80004306:	6402                	ld	s0,0(sp)
    80004308:	0141                	addi	sp,sp,16
    8000430a:	8082                	ret

000000008000430c <write_head>:
// Write in-memory log header to disk.
// This is the true point at which the
// current transaction commits.
static void
write_head(void)
{
    8000430c:	1101                	addi	sp,sp,-32
    8000430e:	ec06                	sd	ra,24(sp)
    80004310:	e822                	sd	s0,16(sp)
    80004312:	e426                	sd	s1,8(sp)
    80004314:	e04a                	sd	s2,0(sp)
    80004316:	1000                	addi	s0,sp,32
  struct buf *buf = bread(log.dev, log.start);
    80004318:	0001d917          	auipc	s2,0x1d
    8000431c:	99890913          	addi	s2,s2,-1640 # 80020cb0 <log>
    80004320:	01892583          	lw	a1,24(s2)
    80004324:	02892503          	lw	a0,40(s2)
    80004328:	fffff097          	auipc	ra,0xfffff
    8000432c:	fea080e7          	jalr	-22(ra) # 80003312 <bread>
    80004330:	84aa                	mv	s1,a0
  struct logheader *hb = (struct logheader *) (buf->data);
  int i;
  hb->n = log.lh.n;
    80004332:	02c92683          	lw	a3,44(s2)
    80004336:	cd34                	sw	a3,88(a0)
  for (i = 0; i < log.lh.n; i++) {
    80004338:	02d05763          	blez	a3,80004366 <write_head+0x5a>
    8000433c:	0001d797          	auipc	a5,0x1d
    80004340:	9a478793          	addi	a5,a5,-1628 # 80020ce0 <log+0x30>
    80004344:	05c50713          	addi	a4,a0,92
    80004348:	36fd                	addiw	a3,a3,-1
    8000434a:	1682                	slli	a3,a3,0x20
    8000434c:	9281                	srli	a3,a3,0x20
    8000434e:	068a                	slli	a3,a3,0x2
    80004350:	0001d617          	auipc	a2,0x1d
    80004354:	99460613          	addi	a2,a2,-1644 # 80020ce4 <log+0x34>
    80004358:	96b2                	add	a3,a3,a2
    hb->block[i] = log.lh.block[i];
    8000435a:	4390                	lw	a2,0(a5)
    8000435c:	c310                	sw	a2,0(a4)
  for (i = 0; i < log.lh.n; i++) {
    8000435e:	0791                	addi	a5,a5,4
    80004360:	0711                	addi	a4,a4,4
    80004362:	fed79ce3          	bne	a5,a3,8000435a <write_head+0x4e>
  }
  bwrite(buf);
    80004366:	8526                	mv	a0,s1
    80004368:	fffff097          	auipc	ra,0xfffff
    8000436c:	09c080e7          	jalr	156(ra) # 80003404 <bwrite>
  brelse(buf);
    80004370:	8526                	mv	a0,s1
    80004372:	fffff097          	auipc	ra,0xfffff
    80004376:	0d0080e7          	jalr	208(ra) # 80003442 <brelse>
}
    8000437a:	60e2                	ld	ra,24(sp)
    8000437c:	6442                	ld	s0,16(sp)
    8000437e:	64a2                	ld	s1,8(sp)
    80004380:	6902                	ld	s2,0(sp)
    80004382:	6105                	addi	sp,sp,32
    80004384:	8082                	ret

0000000080004386 <install_trans>:
  for (tail = 0; tail < log.lh.n; tail++) {
    80004386:	0001d797          	auipc	a5,0x1d
    8000438a:	9567a783          	lw	a5,-1706(a5) # 80020cdc <log+0x2c>
    8000438e:	0af05d63          	blez	a5,80004448 <install_trans+0xc2>
{
    80004392:	7139                	addi	sp,sp,-64
    80004394:	fc06                	sd	ra,56(sp)
    80004396:	f822                	sd	s0,48(sp)
    80004398:	f426                	sd	s1,40(sp)
    8000439a:	f04a                	sd	s2,32(sp)
    8000439c:	ec4e                	sd	s3,24(sp)
    8000439e:	e852                	sd	s4,16(sp)
    800043a0:	e456                	sd	s5,8(sp)
    800043a2:	e05a                	sd	s6,0(sp)
    800043a4:	0080                	addi	s0,sp,64
    800043a6:	8b2a                	mv	s6,a0
    800043a8:	0001da97          	auipc	s5,0x1d
    800043ac:	938a8a93          	addi	s5,s5,-1736 # 80020ce0 <log+0x30>
  for (tail = 0; tail < log.lh.n; tail++) {
    800043b0:	4a01                	li	s4,0
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    800043b2:	0001d997          	auipc	s3,0x1d
    800043b6:	8fe98993          	addi	s3,s3,-1794 # 80020cb0 <log>
    800043ba:	a035                	j	800043e6 <install_trans+0x60>
      bunpin(dbuf);
    800043bc:	8526                	mv	a0,s1
    800043be:	fffff097          	auipc	ra,0xfffff
    800043c2:	15e080e7          	jalr	350(ra) # 8000351c <bunpin>
    brelse(lbuf);
    800043c6:	854a                	mv	a0,s2
    800043c8:	fffff097          	auipc	ra,0xfffff
    800043cc:	07a080e7          	jalr	122(ra) # 80003442 <brelse>
    brelse(dbuf);
    800043d0:	8526                	mv	a0,s1
    800043d2:	fffff097          	auipc	ra,0xfffff
    800043d6:	070080e7          	jalr	112(ra) # 80003442 <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    800043da:	2a05                	addiw	s4,s4,1
    800043dc:	0a91                	addi	s5,s5,4
    800043de:	02c9a783          	lw	a5,44(s3)
    800043e2:	04fa5963          	bge	s4,a5,80004434 <install_trans+0xae>
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    800043e6:	0189a583          	lw	a1,24(s3)
    800043ea:	014585bb          	addw	a1,a1,s4
    800043ee:	2585                	addiw	a1,a1,1
    800043f0:	0289a503          	lw	a0,40(s3)
    800043f4:	fffff097          	auipc	ra,0xfffff
    800043f8:	f1e080e7          	jalr	-226(ra) # 80003312 <bread>
    800043fc:	892a                	mv	s2,a0
    struct buf *dbuf = bread(log.dev, log.lh.block[tail]); // read dst
    800043fe:	000aa583          	lw	a1,0(s5)
    80004402:	0289a503          	lw	a0,40(s3)
    80004406:	fffff097          	auipc	ra,0xfffff
    8000440a:	f0c080e7          	jalr	-244(ra) # 80003312 <bread>
    8000440e:	84aa                	mv	s1,a0
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
    80004410:	40000613          	li	a2,1024
    80004414:	05890593          	addi	a1,s2,88
    80004418:	05850513          	addi	a0,a0,88
    8000441c:	ffffd097          	auipc	ra,0xffffd
    80004420:	9d6080e7          	jalr	-1578(ra) # 80000df2 <memmove>
    bwrite(dbuf);  // write dst to disk
    80004424:	8526                	mv	a0,s1
    80004426:	fffff097          	auipc	ra,0xfffff
    8000442a:	fde080e7          	jalr	-34(ra) # 80003404 <bwrite>
    if(recovering == 0)
    8000442e:	f80b1ce3          	bnez	s6,800043c6 <install_trans+0x40>
    80004432:	b769                	j	800043bc <install_trans+0x36>
}
    80004434:	70e2                	ld	ra,56(sp)
    80004436:	7442                	ld	s0,48(sp)
    80004438:	74a2                	ld	s1,40(sp)
    8000443a:	7902                	ld	s2,32(sp)
    8000443c:	69e2                	ld	s3,24(sp)
    8000443e:	6a42                	ld	s4,16(sp)
    80004440:	6aa2                	ld	s5,8(sp)
    80004442:	6b02                	ld	s6,0(sp)
    80004444:	6121                	addi	sp,sp,64
    80004446:	8082                	ret
    80004448:	8082                	ret

000000008000444a <initlog>:
{
    8000444a:	7179                	addi	sp,sp,-48
    8000444c:	f406                	sd	ra,40(sp)
    8000444e:	f022                	sd	s0,32(sp)
    80004450:	ec26                	sd	s1,24(sp)
    80004452:	e84a                	sd	s2,16(sp)
    80004454:	e44e                	sd	s3,8(sp)
    80004456:	1800                	addi	s0,sp,48
    80004458:	892a                	mv	s2,a0
    8000445a:	89ae                	mv	s3,a1
  initlock(&log.lock, "log");
    8000445c:	0001d497          	auipc	s1,0x1d
    80004460:	85448493          	addi	s1,s1,-1964 # 80020cb0 <log>
    80004464:	00004597          	auipc	a1,0x4
    80004468:	30c58593          	addi	a1,a1,780 # 80008770 <syscalls+0x200>
    8000446c:	8526                	mv	a0,s1
    8000446e:	ffffc097          	auipc	ra,0xffffc
    80004472:	798080e7          	jalr	1944(ra) # 80000c06 <initlock>
  log.start = sb->logstart;
    80004476:	0149a583          	lw	a1,20(s3)
    8000447a:	cc8c                	sw	a1,24(s1)
  log.size = sb->nlog;
    8000447c:	0109a783          	lw	a5,16(s3)
    80004480:	ccdc                	sw	a5,28(s1)
  log.dev = dev;
    80004482:	0324a423          	sw	s2,40(s1)
  struct buf *buf = bread(log.dev, log.start);
    80004486:	854a                	mv	a0,s2
    80004488:	fffff097          	auipc	ra,0xfffff
    8000448c:	e8a080e7          	jalr	-374(ra) # 80003312 <bread>
  log.lh.n = lh->n;
    80004490:	4d3c                	lw	a5,88(a0)
    80004492:	d4dc                	sw	a5,44(s1)
  for (i = 0; i < log.lh.n; i++) {
    80004494:	02f05563          	blez	a5,800044be <initlog+0x74>
    80004498:	05c50713          	addi	a4,a0,92
    8000449c:	0001d697          	auipc	a3,0x1d
    800044a0:	84468693          	addi	a3,a3,-1980 # 80020ce0 <log+0x30>
    800044a4:	37fd                	addiw	a5,a5,-1
    800044a6:	1782                	slli	a5,a5,0x20
    800044a8:	9381                	srli	a5,a5,0x20
    800044aa:	078a                	slli	a5,a5,0x2
    800044ac:	06050613          	addi	a2,a0,96
    800044b0:	97b2                	add	a5,a5,a2
    log.lh.block[i] = lh->block[i];
    800044b2:	4310                	lw	a2,0(a4)
    800044b4:	c290                	sw	a2,0(a3)
  for (i = 0; i < log.lh.n; i++) {
    800044b6:	0711                	addi	a4,a4,4
    800044b8:	0691                	addi	a3,a3,4
    800044ba:	fef71ce3          	bne	a4,a5,800044b2 <initlog+0x68>
  brelse(buf);
    800044be:	fffff097          	auipc	ra,0xfffff
    800044c2:	f84080e7          	jalr	-124(ra) # 80003442 <brelse>

static void
recover_from_log(void)
{
  read_head();
  install_trans(1); // if committed, copy from log to disk
    800044c6:	4505                	li	a0,1
    800044c8:	00000097          	auipc	ra,0x0
    800044cc:	ebe080e7          	jalr	-322(ra) # 80004386 <install_trans>
  log.lh.n = 0;
    800044d0:	0001d797          	auipc	a5,0x1d
    800044d4:	8007a623          	sw	zero,-2036(a5) # 80020cdc <log+0x2c>
  write_head(); // clear the log
    800044d8:	00000097          	auipc	ra,0x0
    800044dc:	e34080e7          	jalr	-460(ra) # 8000430c <write_head>
}
    800044e0:	70a2                	ld	ra,40(sp)
    800044e2:	7402                	ld	s0,32(sp)
    800044e4:	64e2                	ld	s1,24(sp)
    800044e6:	6942                	ld	s2,16(sp)
    800044e8:	69a2                	ld	s3,8(sp)
    800044ea:	6145                	addi	sp,sp,48
    800044ec:	8082                	ret

00000000800044ee <begin_op>:
}

// called at the start of each FS system call.
void
begin_op(void)
{
    800044ee:	1101                	addi	sp,sp,-32
    800044f0:	ec06                	sd	ra,24(sp)
    800044f2:	e822                	sd	s0,16(sp)
    800044f4:	e426                	sd	s1,8(sp)
    800044f6:	e04a                	sd	s2,0(sp)
    800044f8:	1000                	addi	s0,sp,32
  acquire(&log.lock);
    800044fa:	0001c517          	auipc	a0,0x1c
    800044fe:	7b650513          	addi	a0,a0,1974 # 80020cb0 <log>
    80004502:	ffffc097          	auipc	ra,0xffffc
    80004506:	794080e7          	jalr	1940(ra) # 80000c96 <acquire>
  while(1){
    if(log.committing){
    8000450a:	0001c497          	auipc	s1,0x1c
    8000450e:	7a648493          	addi	s1,s1,1958 # 80020cb0 <log>
      sleep(&log, &log.lock);
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
    80004512:	4979                	li	s2,30
    80004514:	a039                	j	80004522 <begin_op+0x34>
      sleep(&log, &log.lock);
    80004516:	85a6                	mv	a1,s1
    80004518:	8526                	mv	a0,s1
    8000451a:	ffffe097          	auipc	ra,0xffffe
    8000451e:	dba080e7          	jalr	-582(ra) # 800022d4 <sleep>
    if(log.committing){
    80004522:	50dc                	lw	a5,36(s1)
    80004524:	fbed                	bnez	a5,80004516 <begin_op+0x28>
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
    80004526:	509c                	lw	a5,32(s1)
    80004528:	0017871b          	addiw	a4,a5,1
    8000452c:	0007069b          	sext.w	a3,a4
    80004530:	0027179b          	slliw	a5,a4,0x2
    80004534:	9fb9                	addw	a5,a5,a4
    80004536:	0017979b          	slliw	a5,a5,0x1
    8000453a:	54d8                	lw	a4,44(s1)
    8000453c:	9fb9                	addw	a5,a5,a4
    8000453e:	00f95963          	bge	s2,a5,80004550 <begin_op+0x62>
      // this op might exhaust log space; wait for commit.
      sleep(&log, &log.lock);
    80004542:	85a6                	mv	a1,s1
    80004544:	8526                	mv	a0,s1
    80004546:	ffffe097          	auipc	ra,0xffffe
    8000454a:	d8e080e7          	jalr	-626(ra) # 800022d4 <sleep>
    8000454e:	bfd1                	j	80004522 <begin_op+0x34>
    } else {
      log.outstanding += 1;
    80004550:	0001c517          	auipc	a0,0x1c
    80004554:	76050513          	addi	a0,a0,1888 # 80020cb0 <log>
    80004558:	d114                	sw	a3,32(a0)
      release(&log.lock);
    8000455a:	ffffc097          	auipc	ra,0xffffc
    8000455e:	7f0080e7          	jalr	2032(ra) # 80000d4a <release>
      break;
    }
  }
}
    80004562:	60e2                	ld	ra,24(sp)
    80004564:	6442                	ld	s0,16(sp)
    80004566:	64a2                	ld	s1,8(sp)
    80004568:	6902                	ld	s2,0(sp)
    8000456a:	6105                	addi	sp,sp,32
    8000456c:	8082                	ret

000000008000456e <end_op>:

// called at the end of each FS system call.
// commits if this was the last outstanding operation.
void
end_op(void)
{
    8000456e:	7139                	addi	sp,sp,-64
    80004570:	fc06                	sd	ra,56(sp)
    80004572:	f822                	sd	s0,48(sp)
    80004574:	f426                	sd	s1,40(sp)
    80004576:	f04a                	sd	s2,32(sp)
    80004578:	ec4e                	sd	s3,24(sp)
    8000457a:	e852                	sd	s4,16(sp)
    8000457c:	e456                	sd	s5,8(sp)
    8000457e:	0080                	addi	s0,sp,64
  int do_commit = 0;

  acquire(&log.lock);
    80004580:	0001c497          	auipc	s1,0x1c
    80004584:	73048493          	addi	s1,s1,1840 # 80020cb0 <log>
    80004588:	8526                	mv	a0,s1
    8000458a:	ffffc097          	auipc	ra,0xffffc
    8000458e:	70c080e7          	jalr	1804(ra) # 80000c96 <acquire>
  log.outstanding -= 1;
    80004592:	509c                	lw	a5,32(s1)
    80004594:	37fd                	addiw	a5,a5,-1
    80004596:	0007891b          	sext.w	s2,a5
    8000459a:	d09c                	sw	a5,32(s1)
  if(log.committing)
    8000459c:	50dc                	lw	a5,36(s1)
    8000459e:	efb9                	bnez	a5,800045fc <end_op+0x8e>
    panic("log.committing");
  if(log.outstanding == 0){
    800045a0:	06091663          	bnez	s2,8000460c <end_op+0x9e>
    do_commit = 1;
    log.committing = 1;
    800045a4:	0001c497          	auipc	s1,0x1c
    800045a8:	70c48493          	addi	s1,s1,1804 # 80020cb0 <log>
    800045ac:	4785                	li	a5,1
    800045ae:	d0dc                	sw	a5,36(s1)
    // begin_op() may be waiting for log space,
    // and decrementing log.outstanding has decreased
    // the amount of reserved space.
    wakeup(&log);
  }
  release(&log.lock);
    800045b0:	8526                	mv	a0,s1
    800045b2:	ffffc097          	auipc	ra,0xffffc
    800045b6:	798080e7          	jalr	1944(ra) # 80000d4a <release>
}

static void
commit()
{
  if (log.lh.n > 0) {
    800045ba:	54dc                	lw	a5,44(s1)
    800045bc:	06f04763          	bgtz	a5,8000462a <end_op+0xbc>
    acquire(&log.lock);
    800045c0:	0001c497          	auipc	s1,0x1c
    800045c4:	6f048493          	addi	s1,s1,1776 # 80020cb0 <log>
    800045c8:	8526                	mv	a0,s1
    800045ca:	ffffc097          	auipc	ra,0xffffc
    800045ce:	6cc080e7          	jalr	1740(ra) # 80000c96 <acquire>
    log.committing = 0;
    800045d2:	0204a223          	sw	zero,36(s1)
    wakeup(&log);
    800045d6:	8526                	mv	a0,s1
    800045d8:	ffffe097          	auipc	ra,0xffffe
    800045dc:	d60080e7          	jalr	-672(ra) # 80002338 <wakeup>
    release(&log.lock);
    800045e0:	8526                	mv	a0,s1
    800045e2:	ffffc097          	auipc	ra,0xffffc
    800045e6:	768080e7          	jalr	1896(ra) # 80000d4a <release>
}
    800045ea:	70e2                	ld	ra,56(sp)
    800045ec:	7442                	ld	s0,48(sp)
    800045ee:	74a2                	ld	s1,40(sp)
    800045f0:	7902                	ld	s2,32(sp)
    800045f2:	69e2                	ld	s3,24(sp)
    800045f4:	6a42                	ld	s4,16(sp)
    800045f6:	6aa2                	ld	s5,8(sp)
    800045f8:	6121                	addi	sp,sp,64
    800045fa:	8082                	ret
    panic("log.committing");
    800045fc:	00004517          	auipc	a0,0x4
    80004600:	17c50513          	addi	a0,a0,380 # 80008778 <syscalls+0x208>
    80004604:	ffffc097          	auipc	ra,0xffffc
    80004608:	f24080e7          	jalr	-220(ra) # 80000528 <panic>
    wakeup(&log);
    8000460c:	0001c497          	auipc	s1,0x1c
    80004610:	6a448493          	addi	s1,s1,1700 # 80020cb0 <log>
    80004614:	8526                	mv	a0,s1
    80004616:	ffffe097          	auipc	ra,0xffffe
    8000461a:	d22080e7          	jalr	-734(ra) # 80002338 <wakeup>
  release(&log.lock);
    8000461e:	8526                	mv	a0,s1
    80004620:	ffffc097          	auipc	ra,0xffffc
    80004624:	72a080e7          	jalr	1834(ra) # 80000d4a <release>
  if(do_commit){
    80004628:	b7c9                	j	800045ea <end_op+0x7c>
  for (tail = 0; tail < log.lh.n; tail++) {
    8000462a:	0001ca97          	auipc	s5,0x1c
    8000462e:	6b6a8a93          	addi	s5,s5,1718 # 80020ce0 <log+0x30>
    struct buf *to = bread(log.dev, log.start+tail+1); // log block
    80004632:	0001ca17          	auipc	s4,0x1c
    80004636:	67ea0a13          	addi	s4,s4,1662 # 80020cb0 <log>
    8000463a:	018a2583          	lw	a1,24(s4)
    8000463e:	012585bb          	addw	a1,a1,s2
    80004642:	2585                	addiw	a1,a1,1
    80004644:	028a2503          	lw	a0,40(s4)
    80004648:	fffff097          	auipc	ra,0xfffff
    8000464c:	cca080e7          	jalr	-822(ra) # 80003312 <bread>
    80004650:	84aa                	mv	s1,a0
    struct buf *from = bread(log.dev, log.lh.block[tail]); // cache block
    80004652:	000aa583          	lw	a1,0(s5)
    80004656:	028a2503          	lw	a0,40(s4)
    8000465a:	fffff097          	auipc	ra,0xfffff
    8000465e:	cb8080e7          	jalr	-840(ra) # 80003312 <bread>
    80004662:	89aa                	mv	s3,a0
    memmove(to->data, from->data, BSIZE);
    80004664:	40000613          	li	a2,1024
    80004668:	05850593          	addi	a1,a0,88
    8000466c:	05848513          	addi	a0,s1,88
    80004670:	ffffc097          	auipc	ra,0xffffc
    80004674:	782080e7          	jalr	1922(ra) # 80000df2 <memmove>
    bwrite(to);  // write the log
    80004678:	8526                	mv	a0,s1
    8000467a:	fffff097          	auipc	ra,0xfffff
    8000467e:	d8a080e7          	jalr	-630(ra) # 80003404 <bwrite>
    brelse(from);
    80004682:	854e                	mv	a0,s3
    80004684:	fffff097          	auipc	ra,0xfffff
    80004688:	dbe080e7          	jalr	-578(ra) # 80003442 <brelse>
    brelse(to);
    8000468c:	8526                	mv	a0,s1
    8000468e:	fffff097          	auipc	ra,0xfffff
    80004692:	db4080e7          	jalr	-588(ra) # 80003442 <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    80004696:	2905                	addiw	s2,s2,1
    80004698:	0a91                	addi	s5,s5,4
    8000469a:	02ca2783          	lw	a5,44(s4)
    8000469e:	f8f94ee3          	blt	s2,a5,8000463a <end_op+0xcc>
    write_log();     // Write modified blocks from cache to log
    write_head();    // Write header to disk -- the real commit
    800046a2:	00000097          	auipc	ra,0x0
    800046a6:	c6a080e7          	jalr	-918(ra) # 8000430c <write_head>
    install_trans(0); // Now install writes to home locations
    800046aa:	4501                	li	a0,0
    800046ac:	00000097          	auipc	ra,0x0
    800046b0:	cda080e7          	jalr	-806(ra) # 80004386 <install_trans>
    log.lh.n = 0;
    800046b4:	0001c797          	auipc	a5,0x1c
    800046b8:	6207a423          	sw	zero,1576(a5) # 80020cdc <log+0x2c>
    write_head();    // Erase the transaction from the log
    800046bc:	00000097          	auipc	ra,0x0
    800046c0:	c50080e7          	jalr	-944(ra) # 8000430c <write_head>
    800046c4:	bdf5                	j	800045c0 <end_op+0x52>

00000000800046c6 <log_write>:
//   modify bp->data[]
//   log_write(bp)
//   brelse(bp)
void
log_write(struct buf *b)
{
    800046c6:	1101                	addi	sp,sp,-32
    800046c8:	ec06                	sd	ra,24(sp)
    800046ca:	e822                	sd	s0,16(sp)
    800046cc:	e426                	sd	s1,8(sp)
    800046ce:	e04a                	sd	s2,0(sp)
    800046d0:	1000                	addi	s0,sp,32
    800046d2:	84aa                	mv	s1,a0
  int i;

  acquire(&log.lock);
    800046d4:	0001c917          	auipc	s2,0x1c
    800046d8:	5dc90913          	addi	s2,s2,1500 # 80020cb0 <log>
    800046dc:	854a                	mv	a0,s2
    800046de:	ffffc097          	auipc	ra,0xffffc
    800046e2:	5b8080e7          	jalr	1464(ra) # 80000c96 <acquire>
  if (log.lh.n >= LOGSIZE || log.lh.n >= log.size - 1)
    800046e6:	02c92603          	lw	a2,44(s2)
    800046ea:	47f5                	li	a5,29
    800046ec:	06c7c563          	blt	a5,a2,80004756 <log_write+0x90>
    800046f0:	0001c797          	auipc	a5,0x1c
    800046f4:	5dc7a783          	lw	a5,1500(a5) # 80020ccc <log+0x1c>
    800046f8:	37fd                	addiw	a5,a5,-1
    800046fa:	04f65e63          	bge	a2,a5,80004756 <log_write+0x90>
    panic("too big a transaction");
  if (log.outstanding < 1)
    800046fe:	0001c797          	auipc	a5,0x1c
    80004702:	5d27a783          	lw	a5,1490(a5) # 80020cd0 <log+0x20>
    80004706:	06f05063          	blez	a5,80004766 <log_write+0xa0>
    panic("log_write outside of trans");

  for (i = 0; i < log.lh.n; i++) {
    8000470a:	4781                	li	a5,0
    8000470c:	06c05563          	blez	a2,80004776 <log_write+0xb0>
    if (log.lh.block[i] == b->blockno)   // log absorption
    80004710:	44cc                	lw	a1,12(s1)
    80004712:	0001c717          	auipc	a4,0x1c
    80004716:	5ce70713          	addi	a4,a4,1486 # 80020ce0 <log+0x30>
  for (i = 0; i < log.lh.n; i++) {
    8000471a:	4781                	li	a5,0
    if (log.lh.block[i] == b->blockno)   // log absorption
    8000471c:	4314                	lw	a3,0(a4)
    8000471e:	04b68c63          	beq	a3,a1,80004776 <log_write+0xb0>
  for (i = 0; i < log.lh.n; i++) {
    80004722:	2785                	addiw	a5,a5,1
    80004724:	0711                	addi	a4,a4,4
    80004726:	fef61be3          	bne	a2,a5,8000471c <log_write+0x56>
      break;
  }
  log.lh.block[i] = b->blockno;
    8000472a:	0621                	addi	a2,a2,8
    8000472c:	060a                	slli	a2,a2,0x2
    8000472e:	0001c797          	auipc	a5,0x1c
    80004732:	58278793          	addi	a5,a5,1410 # 80020cb0 <log>
    80004736:	963e                	add	a2,a2,a5
    80004738:	44dc                	lw	a5,12(s1)
    8000473a:	ca1c                	sw	a5,16(a2)
  if (i == log.lh.n) {  // Add new block to log?
    bpin(b);
    8000473c:	8526                	mv	a0,s1
    8000473e:	fffff097          	auipc	ra,0xfffff
    80004742:	da2080e7          	jalr	-606(ra) # 800034e0 <bpin>
    log.lh.n++;
    80004746:	0001c717          	auipc	a4,0x1c
    8000474a:	56a70713          	addi	a4,a4,1386 # 80020cb0 <log>
    8000474e:	575c                	lw	a5,44(a4)
    80004750:	2785                	addiw	a5,a5,1
    80004752:	d75c                	sw	a5,44(a4)
    80004754:	a835                	j	80004790 <log_write+0xca>
    panic("too big a transaction");
    80004756:	00004517          	auipc	a0,0x4
    8000475a:	03250513          	addi	a0,a0,50 # 80008788 <syscalls+0x218>
    8000475e:	ffffc097          	auipc	ra,0xffffc
    80004762:	dca080e7          	jalr	-566(ra) # 80000528 <panic>
    panic("log_write outside of trans");
    80004766:	00004517          	auipc	a0,0x4
    8000476a:	03a50513          	addi	a0,a0,58 # 800087a0 <syscalls+0x230>
    8000476e:	ffffc097          	auipc	ra,0xffffc
    80004772:	dba080e7          	jalr	-582(ra) # 80000528 <panic>
  log.lh.block[i] = b->blockno;
    80004776:	00878713          	addi	a4,a5,8
    8000477a:	00271693          	slli	a3,a4,0x2
    8000477e:	0001c717          	auipc	a4,0x1c
    80004782:	53270713          	addi	a4,a4,1330 # 80020cb0 <log>
    80004786:	9736                	add	a4,a4,a3
    80004788:	44d4                	lw	a3,12(s1)
    8000478a:	cb14                	sw	a3,16(a4)
  if (i == log.lh.n) {  // Add new block to log?
    8000478c:	faf608e3          	beq	a2,a5,8000473c <log_write+0x76>
  }
  release(&log.lock);
    80004790:	0001c517          	auipc	a0,0x1c
    80004794:	52050513          	addi	a0,a0,1312 # 80020cb0 <log>
    80004798:	ffffc097          	auipc	ra,0xffffc
    8000479c:	5b2080e7          	jalr	1458(ra) # 80000d4a <release>
}
    800047a0:	60e2                	ld	ra,24(sp)
    800047a2:	6442                	ld	s0,16(sp)
    800047a4:	64a2                	ld	s1,8(sp)
    800047a6:	6902                	ld	s2,0(sp)
    800047a8:	6105                	addi	sp,sp,32
    800047aa:	8082                	ret

00000000800047ac <initsleeplock>:
#include "proc.h"
#include "sleeplock.h"

void
initsleeplock(struct sleeplock *lk, char *name)
{
    800047ac:	1101                	addi	sp,sp,-32
    800047ae:	ec06                	sd	ra,24(sp)
    800047b0:	e822                	sd	s0,16(sp)
    800047b2:	e426                	sd	s1,8(sp)
    800047b4:	e04a                	sd	s2,0(sp)
    800047b6:	1000                	addi	s0,sp,32
    800047b8:	84aa                	mv	s1,a0
    800047ba:	892e                	mv	s2,a1
  initlock(&lk->lk, "sleep lock");
    800047bc:	00004597          	auipc	a1,0x4
    800047c0:	00458593          	addi	a1,a1,4 # 800087c0 <syscalls+0x250>
    800047c4:	0521                	addi	a0,a0,8
    800047c6:	ffffc097          	auipc	ra,0xffffc
    800047ca:	440080e7          	jalr	1088(ra) # 80000c06 <initlock>
  lk->name = name;
    800047ce:	0324b023          	sd	s2,32(s1)
  lk->locked = 0;
    800047d2:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    800047d6:	0204a423          	sw	zero,40(s1)
}
    800047da:	60e2                	ld	ra,24(sp)
    800047dc:	6442                	ld	s0,16(sp)
    800047de:	64a2                	ld	s1,8(sp)
    800047e0:	6902                	ld	s2,0(sp)
    800047e2:	6105                	addi	sp,sp,32
    800047e4:	8082                	ret

00000000800047e6 <acquiresleep>:

void
acquiresleep(struct sleeplock *lk)
{
    800047e6:	1101                	addi	sp,sp,-32
    800047e8:	ec06                	sd	ra,24(sp)
    800047ea:	e822                	sd	s0,16(sp)
    800047ec:	e426                	sd	s1,8(sp)
    800047ee:	e04a                	sd	s2,0(sp)
    800047f0:	1000                	addi	s0,sp,32
    800047f2:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    800047f4:	00850913          	addi	s2,a0,8
    800047f8:	854a                	mv	a0,s2
    800047fa:	ffffc097          	auipc	ra,0xffffc
    800047fe:	49c080e7          	jalr	1180(ra) # 80000c96 <acquire>
  while (lk->locked) {
    80004802:	409c                	lw	a5,0(s1)
    80004804:	cb89                	beqz	a5,80004816 <acquiresleep+0x30>
    sleep(lk, &lk->lk);
    80004806:	85ca                	mv	a1,s2
    80004808:	8526                	mv	a0,s1
    8000480a:	ffffe097          	auipc	ra,0xffffe
    8000480e:	aca080e7          	jalr	-1334(ra) # 800022d4 <sleep>
  while (lk->locked) {
    80004812:	409c                	lw	a5,0(s1)
    80004814:	fbed                	bnez	a5,80004806 <acquiresleep+0x20>
  }
  lk->locked = 1;
    80004816:	4785                	li	a5,1
    80004818:	c09c                	sw	a5,0(s1)
  lk->pid = myproc()->pid;
    8000481a:	ffffd097          	auipc	ra,0xffffd
    8000481e:	356080e7          	jalr	854(ra) # 80001b70 <myproc>
    80004822:	591c                	lw	a5,48(a0)
    80004824:	d49c                	sw	a5,40(s1)
  release(&lk->lk);
    80004826:	854a                	mv	a0,s2
    80004828:	ffffc097          	auipc	ra,0xffffc
    8000482c:	522080e7          	jalr	1314(ra) # 80000d4a <release>
}
    80004830:	60e2                	ld	ra,24(sp)
    80004832:	6442                	ld	s0,16(sp)
    80004834:	64a2                	ld	s1,8(sp)
    80004836:	6902                	ld	s2,0(sp)
    80004838:	6105                	addi	sp,sp,32
    8000483a:	8082                	ret

000000008000483c <releasesleep>:

void
releasesleep(struct sleeplock *lk)
{
    8000483c:	1101                	addi	sp,sp,-32
    8000483e:	ec06                	sd	ra,24(sp)
    80004840:	e822                	sd	s0,16(sp)
    80004842:	e426                	sd	s1,8(sp)
    80004844:	e04a                	sd	s2,0(sp)
    80004846:	1000                	addi	s0,sp,32
    80004848:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    8000484a:	00850913          	addi	s2,a0,8
    8000484e:	854a                	mv	a0,s2
    80004850:	ffffc097          	auipc	ra,0xffffc
    80004854:	446080e7          	jalr	1094(ra) # 80000c96 <acquire>
  lk->locked = 0;
    80004858:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    8000485c:	0204a423          	sw	zero,40(s1)
  wakeup(lk);
    80004860:	8526                	mv	a0,s1
    80004862:	ffffe097          	auipc	ra,0xffffe
    80004866:	ad6080e7          	jalr	-1322(ra) # 80002338 <wakeup>
  release(&lk->lk);
    8000486a:	854a                	mv	a0,s2
    8000486c:	ffffc097          	auipc	ra,0xffffc
    80004870:	4de080e7          	jalr	1246(ra) # 80000d4a <release>
}
    80004874:	60e2                	ld	ra,24(sp)
    80004876:	6442                	ld	s0,16(sp)
    80004878:	64a2                	ld	s1,8(sp)
    8000487a:	6902                	ld	s2,0(sp)
    8000487c:	6105                	addi	sp,sp,32
    8000487e:	8082                	ret

0000000080004880 <holdingsleep>:

int
holdingsleep(struct sleeplock *lk)
{
    80004880:	7179                	addi	sp,sp,-48
    80004882:	f406                	sd	ra,40(sp)
    80004884:	f022                	sd	s0,32(sp)
    80004886:	ec26                	sd	s1,24(sp)
    80004888:	e84a                	sd	s2,16(sp)
    8000488a:	e44e                	sd	s3,8(sp)
    8000488c:	1800                	addi	s0,sp,48
    8000488e:	84aa                	mv	s1,a0
  int r;
  
  acquire(&lk->lk);
    80004890:	00850913          	addi	s2,a0,8
    80004894:	854a                	mv	a0,s2
    80004896:	ffffc097          	auipc	ra,0xffffc
    8000489a:	400080e7          	jalr	1024(ra) # 80000c96 <acquire>
  r = lk->locked && (lk->pid == myproc()->pid);
    8000489e:	409c                	lw	a5,0(s1)
    800048a0:	ef99                	bnez	a5,800048be <holdingsleep+0x3e>
    800048a2:	4481                	li	s1,0
  release(&lk->lk);
    800048a4:	854a                	mv	a0,s2
    800048a6:	ffffc097          	auipc	ra,0xffffc
    800048aa:	4a4080e7          	jalr	1188(ra) # 80000d4a <release>
  return r;
}
    800048ae:	8526                	mv	a0,s1
    800048b0:	70a2                	ld	ra,40(sp)
    800048b2:	7402                	ld	s0,32(sp)
    800048b4:	64e2                	ld	s1,24(sp)
    800048b6:	6942                	ld	s2,16(sp)
    800048b8:	69a2                	ld	s3,8(sp)
    800048ba:	6145                	addi	sp,sp,48
    800048bc:	8082                	ret
  r = lk->locked && (lk->pid == myproc()->pid);
    800048be:	0284a983          	lw	s3,40(s1)
    800048c2:	ffffd097          	auipc	ra,0xffffd
    800048c6:	2ae080e7          	jalr	686(ra) # 80001b70 <myproc>
    800048ca:	5904                	lw	s1,48(a0)
    800048cc:	413484b3          	sub	s1,s1,s3
    800048d0:	0014b493          	seqz	s1,s1
    800048d4:	bfc1                	j	800048a4 <holdingsleep+0x24>

00000000800048d6 <fileinit>:
  struct file file[NFILE];
} ftable;

void
fileinit(void)
{
    800048d6:	1141                	addi	sp,sp,-16
    800048d8:	e406                	sd	ra,8(sp)
    800048da:	e022                	sd	s0,0(sp)
    800048dc:	0800                	addi	s0,sp,16
  initlock(&ftable.lock, "ftable");
    800048de:	00004597          	auipc	a1,0x4
    800048e2:	ef258593          	addi	a1,a1,-270 # 800087d0 <syscalls+0x260>
    800048e6:	0001c517          	auipc	a0,0x1c
    800048ea:	51250513          	addi	a0,a0,1298 # 80020df8 <ftable>
    800048ee:	ffffc097          	auipc	ra,0xffffc
    800048f2:	318080e7          	jalr	792(ra) # 80000c06 <initlock>
}
    800048f6:	60a2                	ld	ra,8(sp)
    800048f8:	6402                	ld	s0,0(sp)
    800048fa:	0141                	addi	sp,sp,16
    800048fc:	8082                	ret

00000000800048fe <filealloc>:

// Allocate a file structure.
struct file*
filealloc(void)
{
    800048fe:	1101                	addi	sp,sp,-32
    80004900:	ec06                	sd	ra,24(sp)
    80004902:	e822                	sd	s0,16(sp)
    80004904:	e426                	sd	s1,8(sp)
    80004906:	1000                	addi	s0,sp,32
  struct file *f;

  acquire(&ftable.lock);
    80004908:	0001c517          	auipc	a0,0x1c
    8000490c:	4f050513          	addi	a0,a0,1264 # 80020df8 <ftable>
    80004910:	ffffc097          	auipc	ra,0xffffc
    80004914:	386080e7          	jalr	902(ra) # 80000c96 <acquire>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    80004918:	0001c497          	auipc	s1,0x1c
    8000491c:	4f848493          	addi	s1,s1,1272 # 80020e10 <ftable+0x18>
    80004920:	0001d717          	auipc	a4,0x1d
    80004924:	49070713          	addi	a4,a4,1168 # 80021db0 <disk>
    if(f->ref == 0){
    80004928:	40dc                	lw	a5,4(s1)
    8000492a:	cf99                	beqz	a5,80004948 <filealloc+0x4a>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    8000492c:	02848493          	addi	s1,s1,40
    80004930:	fee49ce3          	bne	s1,a4,80004928 <filealloc+0x2a>
      f->ref = 1;
      release(&ftable.lock);
      return f;
    }
  }
  release(&ftable.lock);
    80004934:	0001c517          	auipc	a0,0x1c
    80004938:	4c450513          	addi	a0,a0,1220 # 80020df8 <ftable>
    8000493c:	ffffc097          	auipc	ra,0xffffc
    80004940:	40e080e7          	jalr	1038(ra) # 80000d4a <release>
  return 0;
    80004944:	4481                	li	s1,0
    80004946:	a819                	j	8000495c <filealloc+0x5e>
      f->ref = 1;
    80004948:	4785                	li	a5,1
    8000494a:	c0dc                	sw	a5,4(s1)
      release(&ftable.lock);
    8000494c:	0001c517          	auipc	a0,0x1c
    80004950:	4ac50513          	addi	a0,a0,1196 # 80020df8 <ftable>
    80004954:	ffffc097          	auipc	ra,0xffffc
    80004958:	3f6080e7          	jalr	1014(ra) # 80000d4a <release>
}
    8000495c:	8526                	mv	a0,s1
    8000495e:	60e2                	ld	ra,24(sp)
    80004960:	6442                	ld	s0,16(sp)
    80004962:	64a2                	ld	s1,8(sp)
    80004964:	6105                	addi	sp,sp,32
    80004966:	8082                	ret

0000000080004968 <filedup>:

// Increment ref count for file f.
struct file*
filedup(struct file *f)
{
    80004968:	1101                	addi	sp,sp,-32
    8000496a:	ec06                	sd	ra,24(sp)
    8000496c:	e822                	sd	s0,16(sp)
    8000496e:	e426                	sd	s1,8(sp)
    80004970:	1000                	addi	s0,sp,32
    80004972:	84aa                	mv	s1,a0
  acquire(&ftable.lock);
    80004974:	0001c517          	auipc	a0,0x1c
    80004978:	48450513          	addi	a0,a0,1156 # 80020df8 <ftable>
    8000497c:	ffffc097          	auipc	ra,0xffffc
    80004980:	31a080e7          	jalr	794(ra) # 80000c96 <acquire>
  if(f->ref < 1)
    80004984:	40dc                	lw	a5,4(s1)
    80004986:	02f05263          	blez	a5,800049aa <filedup+0x42>
    panic("filedup");
  f->ref++;
    8000498a:	2785                	addiw	a5,a5,1
    8000498c:	c0dc                	sw	a5,4(s1)
  release(&ftable.lock);
    8000498e:	0001c517          	auipc	a0,0x1c
    80004992:	46a50513          	addi	a0,a0,1130 # 80020df8 <ftable>
    80004996:	ffffc097          	auipc	ra,0xffffc
    8000499a:	3b4080e7          	jalr	948(ra) # 80000d4a <release>
  return f;
}
    8000499e:	8526                	mv	a0,s1
    800049a0:	60e2                	ld	ra,24(sp)
    800049a2:	6442                	ld	s0,16(sp)
    800049a4:	64a2                	ld	s1,8(sp)
    800049a6:	6105                	addi	sp,sp,32
    800049a8:	8082                	ret
    panic("filedup");
    800049aa:	00004517          	auipc	a0,0x4
    800049ae:	e2e50513          	addi	a0,a0,-466 # 800087d8 <syscalls+0x268>
    800049b2:	ffffc097          	auipc	ra,0xffffc
    800049b6:	b76080e7          	jalr	-1162(ra) # 80000528 <panic>

00000000800049ba <fileclose>:

// Close file f.  (Decrement ref count, close when reaches 0.)
void
fileclose(struct file *f)
{
    800049ba:	7139                	addi	sp,sp,-64
    800049bc:	fc06                	sd	ra,56(sp)
    800049be:	f822                	sd	s0,48(sp)
    800049c0:	f426                	sd	s1,40(sp)
    800049c2:	f04a                	sd	s2,32(sp)
    800049c4:	ec4e                	sd	s3,24(sp)
    800049c6:	e852                	sd	s4,16(sp)
    800049c8:	e456                	sd	s5,8(sp)
    800049ca:	0080                	addi	s0,sp,64
    800049cc:	84aa                	mv	s1,a0
  struct file ff;

  acquire(&ftable.lock);
    800049ce:	0001c517          	auipc	a0,0x1c
    800049d2:	42a50513          	addi	a0,a0,1066 # 80020df8 <ftable>
    800049d6:	ffffc097          	auipc	ra,0xffffc
    800049da:	2c0080e7          	jalr	704(ra) # 80000c96 <acquire>
  if(f->ref < 1)
    800049de:	40dc                	lw	a5,4(s1)
    800049e0:	06f05163          	blez	a5,80004a42 <fileclose+0x88>
    panic("fileclose");
  if(--f->ref > 0){
    800049e4:	37fd                	addiw	a5,a5,-1
    800049e6:	0007871b          	sext.w	a4,a5
    800049ea:	c0dc                	sw	a5,4(s1)
    800049ec:	06e04363          	bgtz	a4,80004a52 <fileclose+0x98>
    release(&ftable.lock);
    return;
  }
  ff = *f;
    800049f0:	0004a903          	lw	s2,0(s1)
    800049f4:	0094ca83          	lbu	s5,9(s1)
    800049f8:	0104ba03          	ld	s4,16(s1)
    800049fc:	0184b983          	ld	s3,24(s1)
  f->ref = 0;
    80004a00:	0004a223          	sw	zero,4(s1)
  f->type = FD_NONE;
    80004a04:	0004a023          	sw	zero,0(s1)
  release(&ftable.lock);
    80004a08:	0001c517          	auipc	a0,0x1c
    80004a0c:	3f050513          	addi	a0,a0,1008 # 80020df8 <ftable>
    80004a10:	ffffc097          	auipc	ra,0xffffc
    80004a14:	33a080e7          	jalr	826(ra) # 80000d4a <release>

  if(ff.type == FD_PIPE){
    80004a18:	4785                	li	a5,1
    80004a1a:	04f90d63          	beq	s2,a5,80004a74 <fileclose+0xba>
    pipeclose(ff.pipe, ff.writable);
  } else if(ff.type == FD_INODE || ff.type == FD_DEVICE){
    80004a1e:	3979                	addiw	s2,s2,-2
    80004a20:	4785                	li	a5,1
    80004a22:	0527e063          	bltu	a5,s2,80004a62 <fileclose+0xa8>
    begin_op();
    80004a26:	00000097          	auipc	ra,0x0
    80004a2a:	ac8080e7          	jalr	-1336(ra) # 800044ee <begin_op>
    iput(ff.ip);
    80004a2e:	854e                	mv	a0,s3
    80004a30:	fffff097          	auipc	ra,0xfffff
    80004a34:	2b6080e7          	jalr	694(ra) # 80003ce6 <iput>
    end_op();
    80004a38:	00000097          	auipc	ra,0x0
    80004a3c:	b36080e7          	jalr	-1226(ra) # 8000456e <end_op>
    80004a40:	a00d                	j	80004a62 <fileclose+0xa8>
    panic("fileclose");
    80004a42:	00004517          	auipc	a0,0x4
    80004a46:	d9e50513          	addi	a0,a0,-610 # 800087e0 <syscalls+0x270>
    80004a4a:	ffffc097          	auipc	ra,0xffffc
    80004a4e:	ade080e7          	jalr	-1314(ra) # 80000528 <panic>
    release(&ftable.lock);
    80004a52:	0001c517          	auipc	a0,0x1c
    80004a56:	3a650513          	addi	a0,a0,934 # 80020df8 <ftable>
    80004a5a:	ffffc097          	auipc	ra,0xffffc
    80004a5e:	2f0080e7          	jalr	752(ra) # 80000d4a <release>
  }
}
    80004a62:	70e2                	ld	ra,56(sp)
    80004a64:	7442                	ld	s0,48(sp)
    80004a66:	74a2                	ld	s1,40(sp)
    80004a68:	7902                	ld	s2,32(sp)
    80004a6a:	69e2                	ld	s3,24(sp)
    80004a6c:	6a42                	ld	s4,16(sp)
    80004a6e:	6aa2                	ld	s5,8(sp)
    80004a70:	6121                	addi	sp,sp,64
    80004a72:	8082                	ret
    pipeclose(ff.pipe, ff.writable);
    80004a74:	85d6                	mv	a1,s5
    80004a76:	8552                	mv	a0,s4
    80004a78:	00000097          	auipc	ra,0x0
    80004a7c:	34c080e7          	jalr	844(ra) # 80004dc4 <pipeclose>
    80004a80:	b7cd                	j	80004a62 <fileclose+0xa8>

0000000080004a82 <filestat>:

// Get metadata about file f.
// addr is a user virtual address, pointing to a struct stat.
int
filestat(struct file *f, uint64 addr)
{
    80004a82:	715d                	addi	sp,sp,-80
    80004a84:	e486                	sd	ra,72(sp)
    80004a86:	e0a2                	sd	s0,64(sp)
    80004a88:	fc26                	sd	s1,56(sp)
    80004a8a:	f84a                	sd	s2,48(sp)
    80004a8c:	f44e                	sd	s3,40(sp)
    80004a8e:	0880                	addi	s0,sp,80
    80004a90:	84aa                	mv	s1,a0
    80004a92:	89ae                	mv	s3,a1
  struct proc *p = myproc();
    80004a94:	ffffd097          	auipc	ra,0xffffd
    80004a98:	0dc080e7          	jalr	220(ra) # 80001b70 <myproc>
  struct stat st;
  
  if(f->type == FD_INODE || f->type == FD_DEVICE){
    80004a9c:	409c                	lw	a5,0(s1)
    80004a9e:	37f9                	addiw	a5,a5,-2
    80004aa0:	4705                	li	a4,1
    80004aa2:	04f76763          	bltu	a4,a5,80004af0 <filestat+0x6e>
    80004aa6:	892a                	mv	s2,a0
    ilock(f->ip);
    80004aa8:	6c88                	ld	a0,24(s1)
    80004aaa:	fffff097          	auipc	ra,0xfffff
    80004aae:	082080e7          	jalr	130(ra) # 80003b2c <ilock>
    stati(f->ip, &st);
    80004ab2:	fb840593          	addi	a1,s0,-72
    80004ab6:	6c88                	ld	a0,24(s1)
    80004ab8:	fffff097          	auipc	ra,0xfffff
    80004abc:	2fe080e7          	jalr	766(ra) # 80003db6 <stati>
    iunlock(f->ip);
    80004ac0:	6c88                	ld	a0,24(s1)
    80004ac2:	fffff097          	auipc	ra,0xfffff
    80004ac6:	12c080e7          	jalr	300(ra) # 80003bee <iunlock>
    if(copyout(p->pagetable, addr, (char *)&st, sizeof(st)) < 0)
    80004aca:	46e1                	li	a3,24
    80004acc:	fb840613          	addi	a2,s0,-72
    80004ad0:	85ce                	mv	a1,s3
    80004ad2:	05093503          	ld	a0,80(s2)
    80004ad6:	ffffd097          	auipc	ra,0xffffd
    80004ada:	c5a080e7          	jalr	-934(ra) # 80001730 <copyout>
    80004ade:	41f5551b          	sraiw	a0,a0,0x1f
      return -1;
    return 0;
  }
  return -1;
}
    80004ae2:	60a6                	ld	ra,72(sp)
    80004ae4:	6406                	ld	s0,64(sp)
    80004ae6:	74e2                	ld	s1,56(sp)
    80004ae8:	7942                	ld	s2,48(sp)
    80004aea:	79a2                	ld	s3,40(sp)
    80004aec:	6161                	addi	sp,sp,80
    80004aee:	8082                	ret
  return -1;
    80004af0:	557d                	li	a0,-1
    80004af2:	bfc5                	j	80004ae2 <filestat+0x60>

0000000080004af4 <fileread>:

// Read from file f.
// addr is a user virtual address.
int
fileread(struct file *f, uint64 addr, int n)
{
    80004af4:	7179                	addi	sp,sp,-48
    80004af6:	f406                	sd	ra,40(sp)
    80004af8:	f022                	sd	s0,32(sp)
    80004afa:	ec26                	sd	s1,24(sp)
    80004afc:	e84a                	sd	s2,16(sp)
    80004afe:	e44e                	sd	s3,8(sp)
    80004b00:	1800                	addi	s0,sp,48
  int r = 0;

  if(f->readable == 0)
    80004b02:	00854783          	lbu	a5,8(a0)
    80004b06:	c3d5                	beqz	a5,80004baa <fileread+0xb6>
    80004b08:	84aa                	mv	s1,a0
    80004b0a:	89ae                	mv	s3,a1
    80004b0c:	8932                	mv	s2,a2
    return -1;

  if(f->type == FD_PIPE){
    80004b0e:	411c                	lw	a5,0(a0)
    80004b10:	4705                	li	a4,1
    80004b12:	04e78963          	beq	a5,a4,80004b64 <fileread+0x70>
    r = piperead(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    80004b16:	470d                	li	a4,3
    80004b18:	04e78d63          	beq	a5,a4,80004b72 <fileread+0x7e>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
      return -1;
    r = devsw[f->major].read(1, addr, n);
  } else if(f->type == FD_INODE){
    80004b1c:	4709                	li	a4,2
    80004b1e:	06e79e63          	bne	a5,a4,80004b9a <fileread+0xa6>
    ilock(f->ip);
    80004b22:	6d08                	ld	a0,24(a0)
    80004b24:	fffff097          	auipc	ra,0xfffff
    80004b28:	008080e7          	jalr	8(ra) # 80003b2c <ilock>
    if((r = readi(f->ip, 1, addr, f->off, n)) > 0)
    80004b2c:	874a                	mv	a4,s2
    80004b2e:	5094                	lw	a3,32(s1)
    80004b30:	864e                	mv	a2,s3
    80004b32:	4585                	li	a1,1
    80004b34:	6c88                	ld	a0,24(s1)
    80004b36:	fffff097          	auipc	ra,0xfffff
    80004b3a:	2aa080e7          	jalr	682(ra) # 80003de0 <readi>
    80004b3e:	892a                	mv	s2,a0
    80004b40:	00a05563          	blez	a0,80004b4a <fileread+0x56>
      f->off += r;
    80004b44:	509c                	lw	a5,32(s1)
    80004b46:	9fa9                	addw	a5,a5,a0
    80004b48:	d09c                	sw	a5,32(s1)
    iunlock(f->ip);
    80004b4a:	6c88                	ld	a0,24(s1)
    80004b4c:	fffff097          	auipc	ra,0xfffff
    80004b50:	0a2080e7          	jalr	162(ra) # 80003bee <iunlock>
  } else {
    panic("fileread");
  }

  return r;
}
    80004b54:	854a                	mv	a0,s2
    80004b56:	70a2                	ld	ra,40(sp)
    80004b58:	7402                	ld	s0,32(sp)
    80004b5a:	64e2                	ld	s1,24(sp)
    80004b5c:	6942                	ld	s2,16(sp)
    80004b5e:	69a2                	ld	s3,8(sp)
    80004b60:	6145                	addi	sp,sp,48
    80004b62:	8082                	ret
    r = piperead(f->pipe, addr, n);
    80004b64:	6908                	ld	a0,16(a0)
    80004b66:	00000097          	auipc	ra,0x0
    80004b6a:	3ce080e7          	jalr	974(ra) # 80004f34 <piperead>
    80004b6e:	892a                	mv	s2,a0
    80004b70:	b7d5                	j	80004b54 <fileread+0x60>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
    80004b72:	02451783          	lh	a5,36(a0)
    80004b76:	03079693          	slli	a3,a5,0x30
    80004b7a:	92c1                	srli	a3,a3,0x30
    80004b7c:	4725                	li	a4,9
    80004b7e:	02d76863          	bltu	a4,a3,80004bae <fileread+0xba>
    80004b82:	0792                	slli	a5,a5,0x4
    80004b84:	0001c717          	auipc	a4,0x1c
    80004b88:	1d470713          	addi	a4,a4,468 # 80020d58 <devsw>
    80004b8c:	97ba                	add	a5,a5,a4
    80004b8e:	639c                	ld	a5,0(a5)
    80004b90:	c38d                	beqz	a5,80004bb2 <fileread+0xbe>
    r = devsw[f->major].read(1, addr, n);
    80004b92:	4505                	li	a0,1
    80004b94:	9782                	jalr	a5
    80004b96:	892a                	mv	s2,a0
    80004b98:	bf75                	j	80004b54 <fileread+0x60>
    panic("fileread");
    80004b9a:	00004517          	auipc	a0,0x4
    80004b9e:	c5650513          	addi	a0,a0,-938 # 800087f0 <syscalls+0x280>
    80004ba2:	ffffc097          	auipc	ra,0xffffc
    80004ba6:	986080e7          	jalr	-1658(ra) # 80000528 <panic>
    return -1;
    80004baa:	597d                	li	s2,-1
    80004bac:	b765                	j	80004b54 <fileread+0x60>
      return -1;
    80004bae:	597d                	li	s2,-1
    80004bb0:	b755                	j	80004b54 <fileread+0x60>
    80004bb2:	597d                	li	s2,-1
    80004bb4:	b745                	j	80004b54 <fileread+0x60>

0000000080004bb6 <filewrite>:

// Write to file f.
// addr is a user virtual address.
int
filewrite(struct file *f, uint64 addr, int n)
{
    80004bb6:	715d                	addi	sp,sp,-80
    80004bb8:	e486                	sd	ra,72(sp)
    80004bba:	e0a2                	sd	s0,64(sp)
    80004bbc:	fc26                	sd	s1,56(sp)
    80004bbe:	f84a                	sd	s2,48(sp)
    80004bc0:	f44e                	sd	s3,40(sp)
    80004bc2:	f052                	sd	s4,32(sp)
    80004bc4:	ec56                	sd	s5,24(sp)
    80004bc6:	e85a                	sd	s6,16(sp)
    80004bc8:	e45e                	sd	s7,8(sp)
    80004bca:	e062                	sd	s8,0(sp)
    80004bcc:	0880                	addi	s0,sp,80
  int r, ret = 0;

  if(f->writable == 0)
    80004bce:	00954783          	lbu	a5,9(a0)
    80004bd2:	10078663          	beqz	a5,80004cde <filewrite+0x128>
    80004bd6:	892a                	mv	s2,a0
    80004bd8:	8aae                	mv	s5,a1
    80004bda:	8a32                	mv	s4,a2
    return -1;

  if(f->type == FD_PIPE){
    80004bdc:	411c                	lw	a5,0(a0)
    80004bde:	4705                	li	a4,1
    80004be0:	02e78263          	beq	a5,a4,80004c04 <filewrite+0x4e>
    ret = pipewrite(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    80004be4:	470d                	li	a4,3
    80004be6:	02e78663          	beq	a5,a4,80004c12 <filewrite+0x5c>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
      return -1;
    ret = devsw[f->major].write(1, addr, n);
  } else if(f->type == FD_INODE){
    80004bea:	4709                	li	a4,2
    80004bec:	0ee79163          	bne	a5,a4,80004cce <filewrite+0x118>
    // and 2 blocks of slop for non-aligned writes.
    // this really belongs lower down, since writei()
    // might be writing a device like the console.
    int max = ((MAXOPBLOCKS-1-1-2) / 2) * BSIZE;
    int i = 0;
    while(i < n){
    80004bf0:	0ac05d63          	blez	a2,80004caa <filewrite+0xf4>
    int i = 0;
    80004bf4:	4981                	li	s3,0
    80004bf6:	6b05                	lui	s6,0x1
    80004bf8:	c00b0b13          	addi	s6,s6,-1024 # c00 <_entry-0x7ffff400>
    80004bfc:	6b85                	lui	s7,0x1
    80004bfe:	c00b8b9b          	addiw	s7,s7,-1024
    80004c02:	a861                	j	80004c9a <filewrite+0xe4>
    ret = pipewrite(f->pipe, addr, n);
    80004c04:	6908                	ld	a0,16(a0)
    80004c06:	00000097          	auipc	ra,0x0
    80004c0a:	22e080e7          	jalr	558(ra) # 80004e34 <pipewrite>
    80004c0e:	8a2a                	mv	s4,a0
    80004c10:	a045                	j	80004cb0 <filewrite+0xfa>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
    80004c12:	02451783          	lh	a5,36(a0)
    80004c16:	03079693          	slli	a3,a5,0x30
    80004c1a:	92c1                	srli	a3,a3,0x30
    80004c1c:	4725                	li	a4,9
    80004c1e:	0cd76263          	bltu	a4,a3,80004ce2 <filewrite+0x12c>
    80004c22:	0792                	slli	a5,a5,0x4
    80004c24:	0001c717          	auipc	a4,0x1c
    80004c28:	13470713          	addi	a4,a4,308 # 80020d58 <devsw>
    80004c2c:	97ba                	add	a5,a5,a4
    80004c2e:	679c                	ld	a5,8(a5)
    80004c30:	cbdd                	beqz	a5,80004ce6 <filewrite+0x130>
    ret = devsw[f->major].write(1, addr, n);
    80004c32:	4505                	li	a0,1
    80004c34:	9782                	jalr	a5
    80004c36:	8a2a                	mv	s4,a0
    80004c38:	a8a5                	j	80004cb0 <filewrite+0xfa>
    80004c3a:	00048c1b          	sext.w	s8,s1
      int n1 = n - i;
      if(n1 > max)
        n1 = max;

      begin_op();
    80004c3e:	00000097          	auipc	ra,0x0
    80004c42:	8b0080e7          	jalr	-1872(ra) # 800044ee <begin_op>
      ilock(f->ip);
    80004c46:	01893503          	ld	a0,24(s2)
    80004c4a:	fffff097          	auipc	ra,0xfffff
    80004c4e:	ee2080e7          	jalr	-286(ra) # 80003b2c <ilock>
      if ((r = writei(f->ip, 1, addr + i, f->off, n1)) > 0)
    80004c52:	8762                	mv	a4,s8
    80004c54:	02092683          	lw	a3,32(s2)
    80004c58:	01598633          	add	a2,s3,s5
    80004c5c:	4585                	li	a1,1
    80004c5e:	01893503          	ld	a0,24(s2)
    80004c62:	fffff097          	auipc	ra,0xfffff
    80004c66:	276080e7          	jalr	630(ra) # 80003ed8 <writei>
    80004c6a:	84aa                	mv	s1,a0
    80004c6c:	00a05763          	blez	a0,80004c7a <filewrite+0xc4>
        f->off += r;
    80004c70:	02092783          	lw	a5,32(s2)
    80004c74:	9fa9                	addw	a5,a5,a0
    80004c76:	02f92023          	sw	a5,32(s2)
      iunlock(f->ip);
    80004c7a:	01893503          	ld	a0,24(s2)
    80004c7e:	fffff097          	auipc	ra,0xfffff
    80004c82:	f70080e7          	jalr	-144(ra) # 80003bee <iunlock>
      end_op();
    80004c86:	00000097          	auipc	ra,0x0
    80004c8a:	8e8080e7          	jalr	-1816(ra) # 8000456e <end_op>

      if(r != n1){
    80004c8e:	009c1f63          	bne	s8,s1,80004cac <filewrite+0xf6>
        // error from writei
        break;
      }
      i += r;
    80004c92:	013489bb          	addw	s3,s1,s3
    while(i < n){
    80004c96:	0149db63          	bge	s3,s4,80004cac <filewrite+0xf6>
      int n1 = n - i;
    80004c9a:	413a07bb          	subw	a5,s4,s3
      if(n1 > max)
    80004c9e:	84be                	mv	s1,a5
    80004ca0:	2781                	sext.w	a5,a5
    80004ca2:	f8fb5ce3          	bge	s6,a5,80004c3a <filewrite+0x84>
    80004ca6:	84de                	mv	s1,s7
    80004ca8:	bf49                	j	80004c3a <filewrite+0x84>
    int i = 0;
    80004caa:	4981                	li	s3,0
    }
    ret = (i == n ? n : -1);
    80004cac:	013a1f63          	bne	s4,s3,80004cca <filewrite+0x114>
  } else {
    panic("filewrite");
  }

  return ret;
}
    80004cb0:	8552                	mv	a0,s4
    80004cb2:	60a6                	ld	ra,72(sp)
    80004cb4:	6406                	ld	s0,64(sp)
    80004cb6:	74e2                	ld	s1,56(sp)
    80004cb8:	7942                	ld	s2,48(sp)
    80004cba:	79a2                	ld	s3,40(sp)
    80004cbc:	7a02                	ld	s4,32(sp)
    80004cbe:	6ae2                	ld	s5,24(sp)
    80004cc0:	6b42                	ld	s6,16(sp)
    80004cc2:	6ba2                	ld	s7,8(sp)
    80004cc4:	6c02                	ld	s8,0(sp)
    80004cc6:	6161                	addi	sp,sp,80
    80004cc8:	8082                	ret
    ret = (i == n ? n : -1);
    80004cca:	5a7d                	li	s4,-1
    80004ccc:	b7d5                	j	80004cb0 <filewrite+0xfa>
    panic("filewrite");
    80004cce:	00004517          	auipc	a0,0x4
    80004cd2:	b3250513          	addi	a0,a0,-1230 # 80008800 <syscalls+0x290>
    80004cd6:	ffffc097          	auipc	ra,0xffffc
    80004cda:	852080e7          	jalr	-1966(ra) # 80000528 <panic>
    return -1;
    80004cde:	5a7d                	li	s4,-1
    80004ce0:	bfc1                	j	80004cb0 <filewrite+0xfa>
      return -1;
    80004ce2:	5a7d                	li	s4,-1
    80004ce4:	b7f1                	j	80004cb0 <filewrite+0xfa>
    80004ce6:	5a7d                	li	s4,-1
    80004ce8:	b7e1                	j	80004cb0 <filewrite+0xfa>

0000000080004cea <pipealloc>:
  int writeopen;  // write fd is still open
};

int
pipealloc(struct file **f0, struct file **f1)
{
    80004cea:	7179                	addi	sp,sp,-48
    80004cec:	f406                	sd	ra,40(sp)
    80004cee:	f022                	sd	s0,32(sp)
    80004cf0:	ec26                	sd	s1,24(sp)
    80004cf2:	e84a                	sd	s2,16(sp)
    80004cf4:	e44e                	sd	s3,8(sp)
    80004cf6:	e052                	sd	s4,0(sp)
    80004cf8:	1800                	addi	s0,sp,48
    80004cfa:	84aa                	mv	s1,a0
    80004cfc:	8a2e                	mv	s4,a1
  struct pipe *pi;

  pi = 0;
  *f0 = *f1 = 0;
    80004cfe:	0005b023          	sd	zero,0(a1)
    80004d02:	00053023          	sd	zero,0(a0)
  if((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
    80004d06:	00000097          	auipc	ra,0x0
    80004d0a:	bf8080e7          	jalr	-1032(ra) # 800048fe <filealloc>
    80004d0e:	e088                	sd	a0,0(s1)
    80004d10:	c551                	beqz	a0,80004d9c <pipealloc+0xb2>
    80004d12:	00000097          	auipc	ra,0x0
    80004d16:	bec080e7          	jalr	-1044(ra) # 800048fe <filealloc>
    80004d1a:	00aa3023          	sd	a0,0(s4)
    80004d1e:	c92d                	beqz	a0,80004d90 <pipealloc+0xa6>
    goto bad;
  if((pi = (struct pipe*)kalloc()) == 0)
    80004d20:	ffffc097          	auipc	ra,0xffffc
    80004d24:	e3a080e7          	jalr	-454(ra) # 80000b5a <kalloc>
    80004d28:	892a                	mv	s2,a0
    80004d2a:	c125                	beqz	a0,80004d8a <pipealloc+0xa0>
    goto bad;
  pi->readopen = 1;
    80004d2c:	4985                	li	s3,1
    80004d2e:	23352023          	sw	s3,544(a0)
  pi->writeopen = 1;
    80004d32:	23352223          	sw	s3,548(a0)
  pi->nwrite = 0;
    80004d36:	20052e23          	sw	zero,540(a0)
  pi->nread = 0;
    80004d3a:	20052c23          	sw	zero,536(a0)
  initlock(&pi->lock, "pipe");
    80004d3e:	00004597          	auipc	a1,0x4
    80004d42:	ad258593          	addi	a1,a1,-1326 # 80008810 <syscalls+0x2a0>
    80004d46:	ffffc097          	auipc	ra,0xffffc
    80004d4a:	ec0080e7          	jalr	-320(ra) # 80000c06 <initlock>
  (*f0)->type = FD_PIPE;
    80004d4e:	609c                	ld	a5,0(s1)
    80004d50:	0137a023          	sw	s3,0(a5)
  (*f0)->readable = 1;
    80004d54:	609c                	ld	a5,0(s1)
    80004d56:	01378423          	sb	s3,8(a5)
  (*f0)->writable = 0;
    80004d5a:	609c                	ld	a5,0(s1)
    80004d5c:	000784a3          	sb	zero,9(a5)
  (*f0)->pipe = pi;
    80004d60:	609c                	ld	a5,0(s1)
    80004d62:	0127b823          	sd	s2,16(a5)
  (*f1)->type = FD_PIPE;
    80004d66:	000a3783          	ld	a5,0(s4)
    80004d6a:	0137a023          	sw	s3,0(a5)
  (*f1)->readable = 0;
    80004d6e:	000a3783          	ld	a5,0(s4)
    80004d72:	00078423          	sb	zero,8(a5)
  (*f1)->writable = 1;
    80004d76:	000a3783          	ld	a5,0(s4)
    80004d7a:	013784a3          	sb	s3,9(a5)
  (*f1)->pipe = pi;
    80004d7e:	000a3783          	ld	a5,0(s4)
    80004d82:	0127b823          	sd	s2,16(a5)
  return 0;
    80004d86:	4501                	li	a0,0
    80004d88:	a025                	j	80004db0 <pipealloc+0xc6>

 bad:
  if(pi)
    kfree((char*)pi);
  if(*f0)
    80004d8a:	6088                	ld	a0,0(s1)
    80004d8c:	e501                	bnez	a0,80004d94 <pipealloc+0xaa>
    80004d8e:	a039                	j	80004d9c <pipealloc+0xb2>
    80004d90:	6088                	ld	a0,0(s1)
    80004d92:	c51d                	beqz	a0,80004dc0 <pipealloc+0xd6>
    fileclose(*f0);
    80004d94:	00000097          	auipc	ra,0x0
    80004d98:	c26080e7          	jalr	-986(ra) # 800049ba <fileclose>
  if(*f1)
    80004d9c:	000a3783          	ld	a5,0(s4)
    fileclose(*f1);
  return -1;
    80004da0:	557d                	li	a0,-1
  if(*f1)
    80004da2:	c799                	beqz	a5,80004db0 <pipealloc+0xc6>
    fileclose(*f1);
    80004da4:	853e                	mv	a0,a5
    80004da6:	00000097          	auipc	ra,0x0
    80004daa:	c14080e7          	jalr	-1004(ra) # 800049ba <fileclose>
  return -1;
    80004dae:	557d                	li	a0,-1
}
    80004db0:	70a2                	ld	ra,40(sp)
    80004db2:	7402                	ld	s0,32(sp)
    80004db4:	64e2                	ld	s1,24(sp)
    80004db6:	6942                	ld	s2,16(sp)
    80004db8:	69a2                	ld	s3,8(sp)
    80004dba:	6a02                	ld	s4,0(sp)
    80004dbc:	6145                	addi	sp,sp,48
    80004dbe:	8082                	ret
  return -1;
    80004dc0:	557d                	li	a0,-1
    80004dc2:	b7fd                	j	80004db0 <pipealloc+0xc6>

0000000080004dc4 <pipeclose>:

void
pipeclose(struct pipe *pi, int writable)
{
    80004dc4:	1101                	addi	sp,sp,-32
    80004dc6:	ec06                	sd	ra,24(sp)
    80004dc8:	e822                	sd	s0,16(sp)
    80004dca:	e426                	sd	s1,8(sp)
    80004dcc:	e04a                	sd	s2,0(sp)
    80004dce:	1000                	addi	s0,sp,32
    80004dd0:	84aa                	mv	s1,a0
    80004dd2:	892e                	mv	s2,a1
  acquire(&pi->lock);
    80004dd4:	ffffc097          	auipc	ra,0xffffc
    80004dd8:	ec2080e7          	jalr	-318(ra) # 80000c96 <acquire>
  if(writable){
    80004ddc:	02090d63          	beqz	s2,80004e16 <pipeclose+0x52>
    pi->writeopen = 0;
    80004de0:	2204a223          	sw	zero,548(s1)
    wakeup(&pi->nread);
    80004de4:	21848513          	addi	a0,s1,536
    80004de8:	ffffd097          	auipc	ra,0xffffd
    80004dec:	550080e7          	jalr	1360(ra) # 80002338 <wakeup>
  } else {
    pi->readopen = 0;
    wakeup(&pi->nwrite);
  }
  if(pi->readopen == 0 && pi->writeopen == 0){
    80004df0:	2204b783          	ld	a5,544(s1)
    80004df4:	eb95                	bnez	a5,80004e28 <pipeclose+0x64>
    release(&pi->lock);
    80004df6:	8526                	mv	a0,s1
    80004df8:	ffffc097          	auipc	ra,0xffffc
    80004dfc:	f52080e7          	jalr	-174(ra) # 80000d4a <release>
    kfree((char*)pi);
    80004e00:	8526                	mv	a0,s1
    80004e02:	ffffc097          	auipc	ra,0xffffc
    80004e06:	bf2080e7          	jalr	-1038(ra) # 800009f4 <kfree>
  } else
    release(&pi->lock);
}
    80004e0a:	60e2                	ld	ra,24(sp)
    80004e0c:	6442                	ld	s0,16(sp)
    80004e0e:	64a2                	ld	s1,8(sp)
    80004e10:	6902                	ld	s2,0(sp)
    80004e12:	6105                	addi	sp,sp,32
    80004e14:	8082                	ret
    pi->readopen = 0;
    80004e16:	2204a023          	sw	zero,544(s1)
    wakeup(&pi->nwrite);
    80004e1a:	21c48513          	addi	a0,s1,540
    80004e1e:	ffffd097          	auipc	ra,0xffffd
    80004e22:	51a080e7          	jalr	1306(ra) # 80002338 <wakeup>
    80004e26:	b7e9                	j	80004df0 <pipeclose+0x2c>
    release(&pi->lock);
    80004e28:	8526                	mv	a0,s1
    80004e2a:	ffffc097          	auipc	ra,0xffffc
    80004e2e:	f20080e7          	jalr	-224(ra) # 80000d4a <release>
}
    80004e32:	bfe1                	j	80004e0a <pipeclose+0x46>

0000000080004e34 <pipewrite>:

int
pipewrite(struct pipe *pi, uint64 addr, int n)
{
    80004e34:	7159                	addi	sp,sp,-112
    80004e36:	f486                	sd	ra,104(sp)
    80004e38:	f0a2                	sd	s0,96(sp)
    80004e3a:	eca6                	sd	s1,88(sp)
    80004e3c:	e8ca                	sd	s2,80(sp)
    80004e3e:	e4ce                	sd	s3,72(sp)
    80004e40:	e0d2                	sd	s4,64(sp)
    80004e42:	fc56                	sd	s5,56(sp)
    80004e44:	f85a                	sd	s6,48(sp)
    80004e46:	f45e                	sd	s7,40(sp)
    80004e48:	f062                	sd	s8,32(sp)
    80004e4a:	ec66                	sd	s9,24(sp)
    80004e4c:	1880                	addi	s0,sp,112
    80004e4e:	84aa                	mv	s1,a0
    80004e50:	8aae                	mv	s5,a1
    80004e52:	8a32                	mv	s4,a2
  int i = 0;
  struct proc *pr = myproc();
    80004e54:	ffffd097          	auipc	ra,0xffffd
    80004e58:	d1c080e7          	jalr	-740(ra) # 80001b70 <myproc>
    80004e5c:	89aa                	mv	s3,a0

  acquire(&pi->lock);
    80004e5e:	8526                	mv	a0,s1
    80004e60:	ffffc097          	auipc	ra,0xffffc
    80004e64:	e36080e7          	jalr	-458(ra) # 80000c96 <acquire>
  while(i < n){
    80004e68:	0d405463          	blez	s4,80004f30 <pipewrite+0xfc>
    80004e6c:	8ba6                	mv	s7,s1
  int i = 0;
    80004e6e:	4901                	li	s2,0
    if(pi->nwrite == pi->nread + PIPESIZE){ //DOC: pipewrite-full
      wakeup(&pi->nread);
      sleep(&pi->nwrite, &pi->lock);
    } else {
      char ch;
      if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    80004e70:	5b7d                	li	s6,-1
      wakeup(&pi->nread);
    80004e72:	21848c93          	addi	s9,s1,536
      sleep(&pi->nwrite, &pi->lock);
    80004e76:	21c48c13          	addi	s8,s1,540
    80004e7a:	a08d                	j	80004edc <pipewrite+0xa8>
      release(&pi->lock);
    80004e7c:	8526                	mv	a0,s1
    80004e7e:	ffffc097          	auipc	ra,0xffffc
    80004e82:	ecc080e7          	jalr	-308(ra) # 80000d4a <release>
      return -1;
    80004e86:	597d                	li	s2,-1
  }
  wakeup(&pi->nread);
  release(&pi->lock);

  return i;
}
    80004e88:	854a                	mv	a0,s2
    80004e8a:	70a6                	ld	ra,104(sp)
    80004e8c:	7406                	ld	s0,96(sp)
    80004e8e:	64e6                	ld	s1,88(sp)
    80004e90:	6946                	ld	s2,80(sp)
    80004e92:	69a6                	ld	s3,72(sp)
    80004e94:	6a06                	ld	s4,64(sp)
    80004e96:	7ae2                	ld	s5,56(sp)
    80004e98:	7b42                	ld	s6,48(sp)
    80004e9a:	7ba2                	ld	s7,40(sp)
    80004e9c:	7c02                	ld	s8,32(sp)
    80004e9e:	6ce2                	ld	s9,24(sp)
    80004ea0:	6165                	addi	sp,sp,112
    80004ea2:	8082                	ret
      wakeup(&pi->nread);
    80004ea4:	8566                	mv	a0,s9
    80004ea6:	ffffd097          	auipc	ra,0xffffd
    80004eaa:	492080e7          	jalr	1170(ra) # 80002338 <wakeup>
      sleep(&pi->nwrite, &pi->lock);
    80004eae:	85de                	mv	a1,s7
    80004eb0:	8562                	mv	a0,s8
    80004eb2:	ffffd097          	auipc	ra,0xffffd
    80004eb6:	422080e7          	jalr	1058(ra) # 800022d4 <sleep>
    80004eba:	a839                	j	80004ed8 <pipewrite+0xa4>
      pi->data[pi->nwrite++ % PIPESIZE] = ch;
    80004ebc:	21c4a783          	lw	a5,540(s1)
    80004ec0:	0017871b          	addiw	a4,a5,1
    80004ec4:	20e4ae23          	sw	a4,540(s1)
    80004ec8:	1ff7f793          	andi	a5,a5,511
    80004ecc:	97a6                	add	a5,a5,s1
    80004ece:	f9f44703          	lbu	a4,-97(s0)
    80004ed2:	00e78c23          	sb	a4,24(a5)
      i++;
    80004ed6:	2905                	addiw	s2,s2,1
  while(i < n){
    80004ed8:	05495063          	bge	s2,s4,80004f18 <pipewrite+0xe4>
    if(pi->readopen == 0 || killed(pr)){
    80004edc:	2204a783          	lw	a5,544(s1)
    80004ee0:	dfd1                	beqz	a5,80004e7c <pipewrite+0x48>
    80004ee2:	854e                	mv	a0,s3
    80004ee4:	ffffd097          	auipc	ra,0xffffd
    80004ee8:	698080e7          	jalr	1688(ra) # 8000257c <killed>
    80004eec:	f941                	bnez	a0,80004e7c <pipewrite+0x48>
    if(pi->nwrite == pi->nread + PIPESIZE){ //DOC: pipewrite-full
    80004eee:	2184a783          	lw	a5,536(s1)
    80004ef2:	21c4a703          	lw	a4,540(s1)
    80004ef6:	2007879b          	addiw	a5,a5,512
    80004efa:	faf705e3          	beq	a4,a5,80004ea4 <pipewrite+0x70>
      if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    80004efe:	4685                	li	a3,1
    80004f00:	01590633          	add	a2,s2,s5
    80004f04:	f9f40593          	addi	a1,s0,-97
    80004f08:	0509b503          	ld	a0,80(s3)
    80004f0c:	ffffd097          	auipc	ra,0xffffd
    80004f10:	8b0080e7          	jalr	-1872(ra) # 800017bc <copyin>
    80004f14:	fb6514e3          	bne	a0,s6,80004ebc <pipewrite+0x88>
  wakeup(&pi->nread);
    80004f18:	21848513          	addi	a0,s1,536
    80004f1c:	ffffd097          	auipc	ra,0xffffd
    80004f20:	41c080e7          	jalr	1052(ra) # 80002338 <wakeup>
  release(&pi->lock);
    80004f24:	8526                	mv	a0,s1
    80004f26:	ffffc097          	auipc	ra,0xffffc
    80004f2a:	e24080e7          	jalr	-476(ra) # 80000d4a <release>
  return i;
    80004f2e:	bfa9                	j	80004e88 <pipewrite+0x54>
  int i = 0;
    80004f30:	4901                	li	s2,0
    80004f32:	b7dd                	j	80004f18 <pipewrite+0xe4>

0000000080004f34 <piperead>:

int
piperead(struct pipe *pi, uint64 addr, int n)
{
    80004f34:	715d                	addi	sp,sp,-80
    80004f36:	e486                	sd	ra,72(sp)
    80004f38:	e0a2                	sd	s0,64(sp)
    80004f3a:	fc26                	sd	s1,56(sp)
    80004f3c:	f84a                	sd	s2,48(sp)
    80004f3e:	f44e                	sd	s3,40(sp)
    80004f40:	f052                	sd	s4,32(sp)
    80004f42:	ec56                	sd	s5,24(sp)
    80004f44:	e85a                	sd	s6,16(sp)
    80004f46:	0880                	addi	s0,sp,80
    80004f48:	84aa                	mv	s1,a0
    80004f4a:	892e                	mv	s2,a1
    80004f4c:	8ab2                	mv	s5,a2
  int i;
  struct proc *pr = myproc();
    80004f4e:	ffffd097          	auipc	ra,0xffffd
    80004f52:	c22080e7          	jalr	-990(ra) # 80001b70 <myproc>
    80004f56:	8a2a                	mv	s4,a0
  char ch;

  acquire(&pi->lock);
    80004f58:	8b26                	mv	s6,s1
    80004f5a:	8526                	mv	a0,s1
    80004f5c:	ffffc097          	auipc	ra,0xffffc
    80004f60:	d3a080e7          	jalr	-710(ra) # 80000c96 <acquire>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80004f64:	2184a703          	lw	a4,536(s1)
    80004f68:	21c4a783          	lw	a5,540(s1)
    if(killed(pr)){
      release(&pi->lock);
      return -1;
    }
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    80004f6c:	21848993          	addi	s3,s1,536
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80004f70:	02f71763          	bne	a4,a5,80004f9e <piperead+0x6a>
    80004f74:	2244a783          	lw	a5,548(s1)
    80004f78:	c39d                	beqz	a5,80004f9e <piperead+0x6a>
    if(killed(pr)){
    80004f7a:	8552                	mv	a0,s4
    80004f7c:	ffffd097          	auipc	ra,0xffffd
    80004f80:	600080e7          	jalr	1536(ra) # 8000257c <killed>
    80004f84:	e941                	bnez	a0,80005014 <piperead+0xe0>
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    80004f86:	85da                	mv	a1,s6
    80004f88:	854e                	mv	a0,s3
    80004f8a:	ffffd097          	auipc	ra,0xffffd
    80004f8e:	34a080e7          	jalr	842(ra) # 800022d4 <sleep>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80004f92:	2184a703          	lw	a4,536(s1)
    80004f96:	21c4a783          	lw	a5,540(s1)
    80004f9a:	fcf70de3          	beq	a4,a5,80004f74 <piperead+0x40>
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80004f9e:	09505263          	blez	s5,80005022 <piperead+0xee>
    80004fa2:	4981                	li	s3,0
    if(pi->nread == pi->nwrite)
      break;
    ch = pi->data[pi->nread++ % PIPESIZE];
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1)
    80004fa4:	5b7d                	li	s6,-1
    if(pi->nread == pi->nwrite)
    80004fa6:	2184a783          	lw	a5,536(s1)
    80004faa:	21c4a703          	lw	a4,540(s1)
    80004fae:	02f70d63          	beq	a4,a5,80004fe8 <piperead+0xb4>
    ch = pi->data[pi->nread++ % PIPESIZE];
    80004fb2:	0017871b          	addiw	a4,a5,1
    80004fb6:	20e4ac23          	sw	a4,536(s1)
    80004fba:	1ff7f793          	andi	a5,a5,511
    80004fbe:	97a6                	add	a5,a5,s1
    80004fc0:	0187c783          	lbu	a5,24(a5)
    80004fc4:	faf40fa3          	sb	a5,-65(s0)
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1)
    80004fc8:	4685                	li	a3,1
    80004fca:	fbf40613          	addi	a2,s0,-65
    80004fce:	85ca                	mv	a1,s2
    80004fd0:	050a3503          	ld	a0,80(s4)
    80004fd4:	ffffc097          	auipc	ra,0xffffc
    80004fd8:	75c080e7          	jalr	1884(ra) # 80001730 <copyout>
    80004fdc:	01650663          	beq	a0,s6,80004fe8 <piperead+0xb4>
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80004fe0:	2985                	addiw	s3,s3,1
    80004fe2:	0905                	addi	s2,s2,1
    80004fe4:	fd3a91e3          	bne	s5,s3,80004fa6 <piperead+0x72>
      break;
  }
  wakeup(&pi->nwrite);  //DOC: piperead-wakeup
    80004fe8:	21c48513          	addi	a0,s1,540
    80004fec:	ffffd097          	auipc	ra,0xffffd
    80004ff0:	34c080e7          	jalr	844(ra) # 80002338 <wakeup>
  release(&pi->lock);
    80004ff4:	8526                	mv	a0,s1
    80004ff6:	ffffc097          	auipc	ra,0xffffc
    80004ffa:	d54080e7          	jalr	-684(ra) # 80000d4a <release>
  return i;
}
    80004ffe:	854e                	mv	a0,s3
    80005000:	60a6                	ld	ra,72(sp)
    80005002:	6406                	ld	s0,64(sp)
    80005004:	74e2                	ld	s1,56(sp)
    80005006:	7942                	ld	s2,48(sp)
    80005008:	79a2                	ld	s3,40(sp)
    8000500a:	7a02                	ld	s4,32(sp)
    8000500c:	6ae2                	ld	s5,24(sp)
    8000500e:	6b42                	ld	s6,16(sp)
    80005010:	6161                	addi	sp,sp,80
    80005012:	8082                	ret
      release(&pi->lock);
    80005014:	8526                	mv	a0,s1
    80005016:	ffffc097          	auipc	ra,0xffffc
    8000501a:	d34080e7          	jalr	-716(ra) # 80000d4a <release>
      return -1;
    8000501e:	59fd                	li	s3,-1
    80005020:	bff9                	j	80004ffe <piperead+0xca>
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80005022:	4981                	li	s3,0
    80005024:	b7d1                	j	80004fe8 <piperead+0xb4>

0000000080005026 <flags2perm>:
#include "elf.h"

static int loadseg(pde_t *, uint64, struct inode *, uint, uint);

int flags2perm(int flags)
{
    80005026:	1141                	addi	sp,sp,-16
    80005028:	e422                	sd	s0,8(sp)
    8000502a:	0800                	addi	s0,sp,16
    8000502c:	87aa                	mv	a5,a0
    int perm = 0;
    if(flags & 0x1)
    8000502e:	8905                	andi	a0,a0,1
    80005030:	c111                	beqz	a0,80005034 <flags2perm+0xe>
      perm = PTE_X;
    80005032:	4521                	li	a0,8
    if(flags & 0x2)
    80005034:	8b89                	andi	a5,a5,2
    80005036:	c399                	beqz	a5,8000503c <flags2perm+0x16>
      perm |= PTE_W;
    80005038:	00456513          	ori	a0,a0,4
    return perm;
}
    8000503c:	6422                	ld	s0,8(sp)
    8000503e:	0141                	addi	sp,sp,16
    80005040:	8082                	ret

0000000080005042 <exec>:

int
exec(char *path, char **argv)
{
    80005042:	df010113          	addi	sp,sp,-528
    80005046:	20113423          	sd	ra,520(sp)
    8000504a:	20813023          	sd	s0,512(sp)
    8000504e:	ffa6                	sd	s1,504(sp)
    80005050:	fbca                	sd	s2,496(sp)
    80005052:	f7ce                	sd	s3,488(sp)
    80005054:	f3d2                	sd	s4,480(sp)
    80005056:	efd6                	sd	s5,472(sp)
    80005058:	ebda                	sd	s6,464(sp)
    8000505a:	e7de                	sd	s7,456(sp)
    8000505c:	e3e2                	sd	s8,448(sp)
    8000505e:	ff66                	sd	s9,440(sp)
    80005060:	fb6a                	sd	s10,432(sp)
    80005062:	f76e                	sd	s11,424(sp)
    80005064:	0c00                	addi	s0,sp,528
    80005066:	84aa                	mv	s1,a0
    80005068:	dea43c23          	sd	a0,-520(s0)
    8000506c:	e0b43023          	sd	a1,-512(s0)
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
  struct elfhdr elf;
  struct inode *ip;
  struct proghdr ph;
  pagetable_t pagetable = 0, oldpagetable;
  struct proc *p = myproc();
    80005070:	ffffd097          	auipc	ra,0xffffd
    80005074:	b00080e7          	jalr	-1280(ra) # 80001b70 <myproc>
    80005078:	892a                	mv	s2,a0

  begin_op();
    8000507a:	fffff097          	auipc	ra,0xfffff
    8000507e:	474080e7          	jalr	1140(ra) # 800044ee <begin_op>

  if((ip = namei(path)) == 0){
    80005082:	8526                	mv	a0,s1
    80005084:	fffff097          	auipc	ra,0xfffff
    80005088:	24e080e7          	jalr	590(ra) # 800042d2 <namei>
    8000508c:	c92d                	beqz	a0,800050fe <exec+0xbc>
    8000508e:	84aa                	mv	s1,a0
    end_op();
    return -1;
  }
  ilock(ip);
    80005090:	fffff097          	auipc	ra,0xfffff
    80005094:	a9c080e7          	jalr	-1380(ra) # 80003b2c <ilock>

  // Check ELF header
  if(readi(ip, 0, (uint64)&elf, 0, sizeof(elf)) != sizeof(elf))
    80005098:	04000713          	li	a4,64
    8000509c:	4681                	li	a3,0
    8000509e:	e5040613          	addi	a2,s0,-432
    800050a2:	4581                	li	a1,0
    800050a4:	8526                	mv	a0,s1
    800050a6:	fffff097          	auipc	ra,0xfffff
    800050aa:	d3a080e7          	jalr	-710(ra) # 80003de0 <readi>
    800050ae:	04000793          	li	a5,64
    800050b2:	00f51a63          	bne	a0,a5,800050c6 <exec+0x84>
    goto bad;

  if(elf.magic != ELF_MAGIC)
    800050b6:	e5042703          	lw	a4,-432(s0)
    800050ba:	464c47b7          	lui	a5,0x464c4
    800050be:	57f78793          	addi	a5,a5,1407 # 464c457f <_entry-0x39b3ba81>
    800050c2:	04f70463          	beq	a4,a5,8000510a <exec+0xc8>

 bad:
  if(pagetable)
    proc_freepagetable(pagetable, sz);
  if(ip){
    iunlockput(ip);
    800050c6:	8526                	mv	a0,s1
    800050c8:	fffff097          	auipc	ra,0xfffff
    800050cc:	cc6080e7          	jalr	-826(ra) # 80003d8e <iunlockput>
    end_op();
    800050d0:	fffff097          	auipc	ra,0xfffff
    800050d4:	49e080e7          	jalr	1182(ra) # 8000456e <end_op>
  }
  return -1;
    800050d8:	557d                	li	a0,-1
}
    800050da:	20813083          	ld	ra,520(sp)
    800050de:	20013403          	ld	s0,512(sp)
    800050e2:	74fe                	ld	s1,504(sp)
    800050e4:	795e                	ld	s2,496(sp)
    800050e6:	79be                	ld	s3,488(sp)
    800050e8:	7a1e                	ld	s4,480(sp)
    800050ea:	6afe                	ld	s5,472(sp)
    800050ec:	6b5e                	ld	s6,464(sp)
    800050ee:	6bbe                	ld	s7,456(sp)
    800050f0:	6c1e                	ld	s8,448(sp)
    800050f2:	7cfa                	ld	s9,440(sp)
    800050f4:	7d5a                	ld	s10,432(sp)
    800050f6:	7dba                	ld	s11,424(sp)
    800050f8:	21010113          	addi	sp,sp,528
    800050fc:	8082                	ret
    end_op();
    800050fe:	fffff097          	auipc	ra,0xfffff
    80005102:	470080e7          	jalr	1136(ra) # 8000456e <end_op>
    return -1;
    80005106:	557d                	li	a0,-1
    80005108:	bfc9                	j	800050da <exec+0x98>
  if((pagetable = proc_pagetable(p)) == 0)
    8000510a:	854a                	mv	a0,s2
    8000510c:	ffffd097          	auipc	ra,0xffffd
    80005110:	b28080e7          	jalr	-1240(ra) # 80001c34 <proc_pagetable>
    80005114:	8baa                	mv	s7,a0
    80005116:	d945                	beqz	a0,800050c6 <exec+0x84>
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80005118:	e7042983          	lw	s3,-400(s0)
    8000511c:	e8845783          	lhu	a5,-376(s0)
    80005120:	c7ad                	beqz	a5,8000518a <exec+0x148>
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
    80005122:	4a01                	li	s4,0
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80005124:	4b01                	li	s6,0
    if(ph.vaddr % PGSIZE != 0)
    80005126:	6c85                	lui	s9,0x1
    80005128:	fffc8793          	addi	a5,s9,-1 # fff <_entry-0x7ffff001>
    8000512c:	def43823          	sd	a5,-528(s0)
    80005130:	ac0d                	j	80005362 <exec+0x320>
  uint64 pa;

  for(i = 0; i < sz; i += PGSIZE){
    pa = walkaddr(pagetable, va + i);
    if(pa == 0)
      panic("loadseg: address should exist");
    80005132:	00003517          	auipc	a0,0x3
    80005136:	6e650513          	addi	a0,a0,1766 # 80008818 <syscalls+0x2a8>
    8000513a:	ffffb097          	auipc	ra,0xffffb
    8000513e:	3ee080e7          	jalr	1006(ra) # 80000528 <panic>
    if(sz - i < PGSIZE)
      n = sz - i;
    else
      n = PGSIZE;
    if(readi(ip, 0, (uint64)pa, offset+i, n) != n)
    80005142:	8756                	mv	a4,s5
    80005144:	012d86bb          	addw	a3,s11,s2
    80005148:	4581                	li	a1,0
    8000514a:	8526                	mv	a0,s1
    8000514c:	fffff097          	auipc	ra,0xfffff
    80005150:	c94080e7          	jalr	-876(ra) # 80003de0 <readi>
    80005154:	2501                	sext.w	a0,a0
    80005156:	1aaa9a63          	bne	s5,a0,8000530a <exec+0x2c8>
  for(i = 0; i < sz; i += PGSIZE){
    8000515a:	6785                	lui	a5,0x1
    8000515c:	0127893b          	addw	s2,a5,s2
    80005160:	77fd                	lui	a5,0xfffff
    80005162:	01478a3b          	addw	s4,a5,s4
    80005166:	1f897563          	bgeu	s2,s8,80005350 <exec+0x30e>
    pa = walkaddr(pagetable, va + i);
    8000516a:	02091593          	slli	a1,s2,0x20
    8000516e:	9181                	srli	a1,a1,0x20
    80005170:	95ea                	add	a1,a1,s10
    80005172:	855e                	mv	a0,s7
    80005174:	ffffc097          	auipc	ra,0xffffc
    80005178:	fb0080e7          	jalr	-80(ra) # 80001124 <walkaddr>
    8000517c:	862a                	mv	a2,a0
    if(pa == 0)
    8000517e:	d955                	beqz	a0,80005132 <exec+0xf0>
      n = PGSIZE;
    80005180:	8ae6                	mv	s5,s9
    if(sz - i < PGSIZE)
    80005182:	fd9a70e3          	bgeu	s4,s9,80005142 <exec+0x100>
      n = sz - i;
    80005186:	8ad2                	mv	s5,s4
    80005188:	bf6d                	j	80005142 <exec+0x100>
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
    8000518a:	4a01                	li	s4,0
  iunlockput(ip);
    8000518c:	8526                	mv	a0,s1
    8000518e:	fffff097          	auipc	ra,0xfffff
    80005192:	c00080e7          	jalr	-1024(ra) # 80003d8e <iunlockput>
  end_op();
    80005196:	fffff097          	auipc	ra,0xfffff
    8000519a:	3d8080e7          	jalr	984(ra) # 8000456e <end_op>
  p = myproc();
    8000519e:	ffffd097          	auipc	ra,0xffffd
    800051a2:	9d2080e7          	jalr	-1582(ra) # 80001b70 <myproc>
    800051a6:	8aaa                	mv	s5,a0
  uint64 oldsz = p->sz;
    800051a8:	04853d03          	ld	s10,72(a0)
  sz = PGROUNDUP(sz);
    800051ac:	6785                	lui	a5,0x1
    800051ae:	17fd                	addi	a5,a5,-1
    800051b0:	9a3e                	add	s4,s4,a5
    800051b2:	757d                	lui	a0,0xfffff
    800051b4:	00aa77b3          	and	a5,s4,a0
    800051b8:	e0f43423          	sd	a5,-504(s0)
  if((sz1 = uvmalloc(pagetable, sz, sz + 2*PGSIZE, PTE_W)) == 0)
    800051bc:	4691                	li	a3,4
    800051be:	6609                	lui	a2,0x2
    800051c0:	963e                	add	a2,a2,a5
    800051c2:	85be                	mv	a1,a5
    800051c4:	855e                	mv	a0,s7
    800051c6:	ffffc097          	auipc	ra,0xffffc
    800051ca:	312080e7          	jalr	786(ra) # 800014d8 <uvmalloc>
    800051ce:	8b2a                	mv	s6,a0
  ip = 0;
    800051d0:	4481                	li	s1,0
  if((sz1 = uvmalloc(pagetable, sz, sz + 2*PGSIZE, PTE_W)) == 0)
    800051d2:	12050c63          	beqz	a0,8000530a <exec+0x2c8>
  uvmclear(pagetable, sz-2*PGSIZE);
    800051d6:	75f9                	lui	a1,0xffffe
    800051d8:	95aa                	add	a1,a1,a0
    800051da:	855e                	mv	a0,s7
    800051dc:	ffffc097          	auipc	ra,0xffffc
    800051e0:	522080e7          	jalr	1314(ra) # 800016fe <uvmclear>
  stackbase = sp - PGSIZE;
    800051e4:	7c7d                	lui	s8,0xfffff
    800051e6:	9c5a                	add	s8,s8,s6
  for(argc = 0; argv[argc]; argc++) {
    800051e8:	e0043783          	ld	a5,-512(s0)
    800051ec:	6388                	ld	a0,0(a5)
    800051ee:	c535                	beqz	a0,8000525a <exec+0x218>
    800051f0:	e9040993          	addi	s3,s0,-368
    800051f4:	f9040c93          	addi	s9,s0,-112
  sp = sz;
    800051f8:	895a                	mv	s2,s6
    sp -= strlen(argv[argc]) + 1;
    800051fa:	ffffc097          	auipc	ra,0xffffc
    800051fe:	d1c080e7          	jalr	-740(ra) # 80000f16 <strlen>
    80005202:	2505                	addiw	a0,a0,1
    80005204:	40a90933          	sub	s2,s2,a0
    sp -= sp % 16; // riscv sp must be 16-byte aligned
    80005208:	ff097913          	andi	s2,s2,-16
    if(sp < stackbase)
    8000520c:	13896663          	bltu	s2,s8,80005338 <exec+0x2f6>
    if(copyout(pagetable, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
    80005210:	e0043d83          	ld	s11,-512(s0)
    80005214:	000dba03          	ld	s4,0(s11)
    80005218:	8552                	mv	a0,s4
    8000521a:	ffffc097          	auipc	ra,0xffffc
    8000521e:	cfc080e7          	jalr	-772(ra) # 80000f16 <strlen>
    80005222:	0015069b          	addiw	a3,a0,1
    80005226:	8652                	mv	a2,s4
    80005228:	85ca                	mv	a1,s2
    8000522a:	855e                	mv	a0,s7
    8000522c:	ffffc097          	auipc	ra,0xffffc
    80005230:	504080e7          	jalr	1284(ra) # 80001730 <copyout>
    80005234:	10054663          	bltz	a0,80005340 <exec+0x2fe>
    ustack[argc] = sp;
    80005238:	0129b023          	sd	s2,0(s3)
  for(argc = 0; argv[argc]; argc++) {
    8000523c:	0485                	addi	s1,s1,1
    8000523e:	008d8793          	addi	a5,s11,8
    80005242:	e0f43023          	sd	a5,-512(s0)
    80005246:	008db503          	ld	a0,8(s11)
    8000524a:	c911                	beqz	a0,8000525e <exec+0x21c>
    if(argc >= MAXARG)
    8000524c:	09a1                	addi	s3,s3,8
    8000524e:	fb3c96e3          	bne	s9,s3,800051fa <exec+0x1b8>
  sz = sz1;
    80005252:	e1643423          	sd	s6,-504(s0)
  ip = 0;
    80005256:	4481                	li	s1,0
    80005258:	a84d                	j	8000530a <exec+0x2c8>
  sp = sz;
    8000525a:	895a                	mv	s2,s6
  for(argc = 0; argv[argc]; argc++) {
    8000525c:	4481                	li	s1,0
  ustack[argc] = 0;
    8000525e:	00349793          	slli	a5,s1,0x3
    80005262:	f9040713          	addi	a4,s0,-112
    80005266:	97ba                	add	a5,a5,a4
    80005268:	f007b023          	sd	zero,-256(a5) # f00 <_entry-0x7ffff100>
  sp -= (argc+1) * sizeof(uint64);
    8000526c:	00148693          	addi	a3,s1,1
    80005270:	068e                	slli	a3,a3,0x3
    80005272:	40d90933          	sub	s2,s2,a3
  sp -= sp % 16;
    80005276:	ff097913          	andi	s2,s2,-16
  if(sp < stackbase)
    8000527a:	01897663          	bgeu	s2,s8,80005286 <exec+0x244>
  sz = sz1;
    8000527e:	e1643423          	sd	s6,-504(s0)
  ip = 0;
    80005282:	4481                	li	s1,0
    80005284:	a059                	j	8000530a <exec+0x2c8>
  if(copyout(pagetable, sp, (char *)ustack, (argc+1)*sizeof(uint64)) < 0)
    80005286:	e9040613          	addi	a2,s0,-368
    8000528a:	85ca                	mv	a1,s2
    8000528c:	855e                	mv	a0,s7
    8000528e:	ffffc097          	auipc	ra,0xffffc
    80005292:	4a2080e7          	jalr	1186(ra) # 80001730 <copyout>
    80005296:	0a054963          	bltz	a0,80005348 <exec+0x306>
  p->trapframe->a1 = sp;
    8000529a:	058ab783          	ld	a5,88(s5)
    8000529e:	0727bc23          	sd	s2,120(a5)
  for(last=s=path; *s; s++)
    800052a2:	df843783          	ld	a5,-520(s0)
    800052a6:	0007c703          	lbu	a4,0(a5)
    800052aa:	cf11                	beqz	a4,800052c6 <exec+0x284>
    800052ac:	0785                	addi	a5,a5,1
    if(*s == '/')
    800052ae:	02f00693          	li	a3,47
    800052b2:	a039                	j	800052c0 <exec+0x27e>
      last = s+1;
    800052b4:	def43c23          	sd	a5,-520(s0)
  for(last=s=path; *s; s++)
    800052b8:	0785                	addi	a5,a5,1
    800052ba:	fff7c703          	lbu	a4,-1(a5)
    800052be:	c701                	beqz	a4,800052c6 <exec+0x284>
    if(*s == '/')
    800052c0:	fed71ce3          	bne	a4,a3,800052b8 <exec+0x276>
    800052c4:	bfc5                	j	800052b4 <exec+0x272>
  safestrcpy(p->name, last, sizeof(p->name));
    800052c6:	4641                	li	a2,16
    800052c8:	df843583          	ld	a1,-520(s0)
    800052cc:	158a8513          	addi	a0,s5,344
    800052d0:	ffffc097          	auipc	ra,0xffffc
    800052d4:	c14080e7          	jalr	-1004(ra) # 80000ee4 <safestrcpy>
  oldpagetable = p->pagetable;
    800052d8:	050ab503          	ld	a0,80(s5)
  p->pagetable = pagetable;
    800052dc:	057ab823          	sd	s7,80(s5)
  p->sz = sz;
    800052e0:	056ab423          	sd	s6,72(s5)
  p->trapframe->epc = elf.entry;  // initial program counter = main
    800052e4:	058ab783          	ld	a5,88(s5)
    800052e8:	e6843703          	ld	a4,-408(s0)
    800052ec:	ef98                	sd	a4,24(a5)
  p->trapframe->sp = sp; // initial stack pointer
    800052ee:	058ab783          	ld	a5,88(s5)
    800052f2:	0327b823          	sd	s2,48(a5)
  proc_freepagetable(oldpagetable, oldsz);
    800052f6:	85ea                	mv	a1,s10
    800052f8:	ffffd097          	auipc	ra,0xffffd
    800052fc:	9d8080e7          	jalr	-1576(ra) # 80001cd0 <proc_freepagetable>
  return argc; // this ends up in a0, the first argument to main(argc, argv)
    80005300:	0004851b          	sext.w	a0,s1
    80005304:	bbd9                	j	800050da <exec+0x98>
    80005306:	e1443423          	sd	s4,-504(s0)
    proc_freepagetable(pagetable, sz);
    8000530a:	e0843583          	ld	a1,-504(s0)
    8000530e:	855e                	mv	a0,s7
    80005310:	ffffd097          	auipc	ra,0xffffd
    80005314:	9c0080e7          	jalr	-1600(ra) # 80001cd0 <proc_freepagetable>
  if(ip){
    80005318:	da0497e3          	bnez	s1,800050c6 <exec+0x84>
  return -1;
    8000531c:	557d                	li	a0,-1
    8000531e:	bb75                	j	800050da <exec+0x98>
    80005320:	e1443423          	sd	s4,-504(s0)
    80005324:	b7dd                	j	8000530a <exec+0x2c8>
    80005326:	e1443423          	sd	s4,-504(s0)
    8000532a:	b7c5                	j	8000530a <exec+0x2c8>
    8000532c:	e1443423          	sd	s4,-504(s0)
    80005330:	bfe9                	j	8000530a <exec+0x2c8>
    80005332:	e1443423          	sd	s4,-504(s0)
    80005336:	bfd1                	j	8000530a <exec+0x2c8>
  sz = sz1;
    80005338:	e1643423          	sd	s6,-504(s0)
  ip = 0;
    8000533c:	4481                	li	s1,0
    8000533e:	b7f1                	j	8000530a <exec+0x2c8>
  sz = sz1;
    80005340:	e1643423          	sd	s6,-504(s0)
  ip = 0;
    80005344:	4481                	li	s1,0
    80005346:	b7d1                	j	8000530a <exec+0x2c8>
  sz = sz1;
    80005348:	e1643423          	sd	s6,-504(s0)
  ip = 0;
    8000534c:	4481                	li	s1,0
    8000534e:	bf75                	j	8000530a <exec+0x2c8>
    if((sz1 = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz, flags2perm(ph.flags))) == 0)
    80005350:	e0843a03          	ld	s4,-504(s0)
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80005354:	2b05                	addiw	s6,s6,1
    80005356:	0389899b          	addiw	s3,s3,56
    8000535a:	e8845783          	lhu	a5,-376(s0)
    8000535e:	e2fb57e3          	bge	s6,a5,8000518c <exec+0x14a>
    if(readi(ip, 0, (uint64)&ph, off, sizeof(ph)) != sizeof(ph))
    80005362:	2981                	sext.w	s3,s3
    80005364:	03800713          	li	a4,56
    80005368:	86ce                	mv	a3,s3
    8000536a:	e1840613          	addi	a2,s0,-488
    8000536e:	4581                	li	a1,0
    80005370:	8526                	mv	a0,s1
    80005372:	fffff097          	auipc	ra,0xfffff
    80005376:	a6e080e7          	jalr	-1426(ra) # 80003de0 <readi>
    8000537a:	03800793          	li	a5,56
    8000537e:	f8f514e3          	bne	a0,a5,80005306 <exec+0x2c4>
    if(ph.type != ELF_PROG_LOAD)
    80005382:	e1842783          	lw	a5,-488(s0)
    80005386:	4705                	li	a4,1
    80005388:	fce796e3          	bne	a5,a4,80005354 <exec+0x312>
    if(ph.memsz < ph.filesz)
    8000538c:	e4043903          	ld	s2,-448(s0)
    80005390:	e3843783          	ld	a5,-456(s0)
    80005394:	f8f966e3          	bltu	s2,a5,80005320 <exec+0x2de>
    if(ph.vaddr + ph.memsz < ph.vaddr)
    80005398:	e2843783          	ld	a5,-472(s0)
    8000539c:	993e                	add	s2,s2,a5
    8000539e:	f8f964e3          	bltu	s2,a5,80005326 <exec+0x2e4>
    if(ph.vaddr % PGSIZE != 0)
    800053a2:	df043703          	ld	a4,-528(s0)
    800053a6:	8ff9                	and	a5,a5,a4
    800053a8:	f3d1                	bnez	a5,8000532c <exec+0x2ea>
    if((sz1 = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz, flags2perm(ph.flags))) == 0)
    800053aa:	e1c42503          	lw	a0,-484(s0)
    800053ae:	00000097          	auipc	ra,0x0
    800053b2:	c78080e7          	jalr	-904(ra) # 80005026 <flags2perm>
    800053b6:	86aa                	mv	a3,a0
    800053b8:	864a                	mv	a2,s2
    800053ba:	85d2                	mv	a1,s4
    800053bc:	855e                	mv	a0,s7
    800053be:	ffffc097          	auipc	ra,0xffffc
    800053c2:	11a080e7          	jalr	282(ra) # 800014d8 <uvmalloc>
    800053c6:	e0a43423          	sd	a0,-504(s0)
    800053ca:	d525                	beqz	a0,80005332 <exec+0x2f0>
    if(loadseg(pagetable, ph.vaddr, ip, ph.off, ph.filesz) < 0)
    800053cc:	e2843d03          	ld	s10,-472(s0)
    800053d0:	e2042d83          	lw	s11,-480(s0)
    800053d4:	e3842c03          	lw	s8,-456(s0)
  for(i = 0; i < sz; i += PGSIZE){
    800053d8:	f60c0ce3          	beqz	s8,80005350 <exec+0x30e>
    800053dc:	8a62                	mv	s4,s8
    800053de:	4901                	li	s2,0
    800053e0:	b369                	j	8000516a <exec+0x128>

00000000800053e2 <argfd>:

// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.
static int
argfd(int n, int *pfd, struct file **pf)
{
    800053e2:	7179                	addi	sp,sp,-48
    800053e4:	f406                	sd	ra,40(sp)
    800053e6:	f022                	sd	s0,32(sp)
    800053e8:	ec26                	sd	s1,24(sp)
    800053ea:	e84a                	sd	s2,16(sp)
    800053ec:	1800                	addi	s0,sp,48
    800053ee:	892e                	mv	s2,a1
    800053f0:	84b2                	mv	s1,a2
  int fd;
  struct file *f;

  argint(n, &fd);
    800053f2:	fdc40593          	addi	a1,s0,-36
    800053f6:	ffffe097          	auipc	ra,0xffffe
    800053fa:	af6080e7          	jalr	-1290(ra) # 80002eec <argint>
  if(fd < 0 || fd >= NOFILE || (f=myproc()->ofile[fd]) == 0)
    800053fe:	fdc42703          	lw	a4,-36(s0)
    80005402:	47bd                	li	a5,15
    80005404:	02e7eb63          	bltu	a5,a4,8000543a <argfd+0x58>
    80005408:	ffffc097          	auipc	ra,0xffffc
    8000540c:	768080e7          	jalr	1896(ra) # 80001b70 <myproc>
    80005410:	fdc42703          	lw	a4,-36(s0)
    80005414:	01a70793          	addi	a5,a4,26
    80005418:	078e                	slli	a5,a5,0x3
    8000541a:	953e                	add	a0,a0,a5
    8000541c:	611c                	ld	a5,0(a0)
    8000541e:	c385                	beqz	a5,8000543e <argfd+0x5c>
    return -1;
  if(pfd)
    80005420:	00090463          	beqz	s2,80005428 <argfd+0x46>
    *pfd = fd;
    80005424:	00e92023          	sw	a4,0(s2)
  if(pf)
    *pf = f;
  return 0;
    80005428:	4501                	li	a0,0
  if(pf)
    8000542a:	c091                	beqz	s1,8000542e <argfd+0x4c>
    *pf = f;
    8000542c:	e09c                	sd	a5,0(s1)
}
    8000542e:	70a2                	ld	ra,40(sp)
    80005430:	7402                	ld	s0,32(sp)
    80005432:	64e2                	ld	s1,24(sp)
    80005434:	6942                	ld	s2,16(sp)
    80005436:	6145                	addi	sp,sp,48
    80005438:	8082                	ret
    return -1;
    8000543a:	557d                	li	a0,-1
    8000543c:	bfcd                	j	8000542e <argfd+0x4c>
    8000543e:	557d                	li	a0,-1
    80005440:	b7fd                	j	8000542e <argfd+0x4c>

0000000080005442 <fdalloc>:

// Allocate a file descriptor for the given file.
// Takes over file reference from caller on success.
static int
fdalloc(struct file *f)
{
    80005442:	1101                	addi	sp,sp,-32
    80005444:	ec06                	sd	ra,24(sp)
    80005446:	e822                	sd	s0,16(sp)
    80005448:	e426                	sd	s1,8(sp)
    8000544a:	1000                	addi	s0,sp,32
    8000544c:	84aa                	mv	s1,a0
  int fd;
  struct proc *p = myproc();
    8000544e:	ffffc097          	auipc	ra,0xffffc
    80005452:	722080e7          	jalr	1826(ra) # 80001b70 <myproc>
    80005456:	862a                	mv	a2,a0

  for(fd = 0; fd < NOFILE; fd++){
    80005458:	0d050793          	addi	a5,a0,208 # fffffffffffff0d0 <end+0xffffffff7ffdd1e0>
    8000545c:	4501                	li	a0,0
    8000545e:	46c1                	li	a3,16
    if(p->ofile[fd] == 0){
    80005460:	6398                	ld	a4,0(a5)
    80005462:	cb19                	beqz	a4,80005478 <fdalloc+0x36>
  for(fd = 0; fd < NOFILE; fd++){
    80005464:	2505                	addiw	a0,a0,1
    80005466:	07a1                	addi	a5,a5,8
    80005468:	fed51ce3          	bne	a0,a3,80005460 <fdalloc+0x1e>
      p->ofile[fd] = f;
      return fd;
    }
  }
  return -1;
    8000546c:	557d                	li	a0,-1
}
    8000546e:	60e2                	ld	ra,24(sp)
    80005470:	6442                	ld	s0,16(sp)
    80005472:	64a2                	ld	s1,8(sp)
    80005474:	6105                	addi	sp,sp,32
    80005476:	8082                	ret
      p->ofile[fd] = f;
    80005478:	01a50793          	addi	a5,a0,26
    8000547c:	078e                	slli	a5,a5,0x3
    8000547e:	963e                	add	a2,a2,a5
    80005480:	e204                	sd	s1,0(a2)
      return fd;
    80005482:	b7f5                	j	8000546e <fdalloc+0x2c>

0000000080005484 <create>:
  return -1;
}

static struct inode*
create(char *path, short type, short major, short minor)
{
    80005484:	715d                	addi	sp,sp,-80
    80005486:	e486                	sd	ra,72(sp)
    80005488:	e0a2                	sd	s0,64(sp)
    8000548a:	fc26                	sd	s1,56(sp)
    8000548c:	f84a                	sd	s2,48(sp)
    8000548e:	f44e                	sd	s3,40(sp)
    80005490:	f052                	sd	s4,32(sp)
    80005492:	ec56                	sd	s5,24(sp)
    80005494:	e85a                	sd	s6,16(sp)
    80005496:	0880                	addi	s0,sp,80
    80005498:	8b2e                	mv	s6,a1
    8000549a:	89b2                	mv	s3,a2
    8000549c:	8936                	mv	s2,a3
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if((dp = nameiparent(path, name)) == 0)
    8000549e:	fb040593          	addi	a1,s0,-80
    800054a2:	fffff097          	auipc	ra,0xfffff
    800054a6:	e4e080e7          	jalr	-434(ra) # 800042f0 <nameiparent>
    800054aa:	84aa                	mv	s1,a0
    800054ac:	16050063          	beqz	a0,8000560c <create+0x188>
    return 0;

  ilock(dp);
    800054b0:	ffffe097          	auipc	ra,0xffffe
    800054b4:	67c080e7          	jalr	1660(ra) # 80003b2c <ilock>

  if((ip = dirlookup(dp, name, 0)) != 0){
    800054b8:	4601                	li	a2,0
    800054ba:	fb040593          	addi	a1,s0,-80
    800054be:	8526                	mv	a0,s1
    800054c0:	fffff097          	auipc	ra,0xfffff
    800054c4:	b50080e7          	jalr	-1200(ra) # 80004010 <dirlookup>
    800054c8:	8aaa                	mv	s5,a0
    800054ca:	c931                	beqz	a0,8000551e <create+0x9a>
    iunlockput(dp);
    800054cc:	8526                	mv	a0,s1
    800054ce:	fffff097          	auipc	ra,0xfffff
    800054d2:	8c0080e7          	jalr	-1856(ra) # 80003d8e <iunlockput>
    ilock(ip);
    800054d6:	8556                	mv	a0,s5
    800054d8:	ffffe097          	auipc	ra,0xffffe
    800054dc:	654080e7          	jalr	1620(ra) # 80003b2c <ilock>
    if(type == T_FILE && (ip->type == T_FILE || ip->type == T_DEVICE))
    800054e0:	000b059b          	sext.w	a1,s6
    800054e4:	4789                	li	a5,2
    800054e6:	02f59563          	bne	a1,a5,80005510 <create+0x8c>
    800054ea:	044ad783          	lhu	a5,68(s5)
    800054ee:	37f9                	addiw	a5,a5,-2
    800054f0:	17c2                	slli	a5,a5,0x30
    800054f2:	93c1                	srli	a5,a5,0x30
    800054f4:	4705                	li	a4,1
    800054f6:	00f76d63          	bltu	a4,a5,80005510 <create+0x8c>
  ip->nlink = 0;
  iupdate(ip);
  iunlockput(ip);
  iunlockput(dp);
  return 0;
}
    800054fa:	8556                	mv	a0,s5
    800054fc:	60a6                	ld	ra,72(sp)
    800054fe:	6406                	ld	s0,64(sp)
    80005500:	74e2                	ld	s1,56(sp)
    80005502:	7942                	ld	s2,48(sp)
    80005504:	79a2                	ld	s3,40(sp)
    80005506:	7a02                	ld	s4,32(sp)
    80005508:	6ae2                	ld	s5,24(sp)
    8000550a:	6b42                	ld	s6,16(sp)
    8000550c:	6161                	addi	sp,sp,80
    8000550e:	8082                	ret
    iunlockput(ip);
    80005510:	8556                	mv	a0,s5
    80005512:	fffff097          	auipc	ra,0xfffff
    80005516:	87c080e7          	jalr	-1924(ra) # 80003d8e <iunlockput>
    return 0;
    8000551a:	4a81                	li	s5,0
    8000551c:	bff9                	j	800054fa <create+0x76>
  if((ip = ialloc(dp->dev, type)) == 0){
    8000551e:	85da                	mv	a1,s6
    80005520:	4088                	lw	a0,0(s1)
    80005522:	ffffe097          	auipc	ra,0xffffe
    80005526:	46e080e7          	jalr	1134(ra) # 80003990 <ialloc>
    8000552a:	8a2a                	mv	s4,a0
    8000552c:	c921                	beqz	a0,8000557c <create+0xf8>
  ilock(ip);
    8000552e:	ffffe097          	auipc	ra,0xffffe
    80005532:	5fe080e7          	jalr	1534(ra) # 80003b2c <ilock>
  ip->major = major;
    80005536:	053a1323          	sh	s3,70(s4)
  ip->minor = minor;
    8000553a:	052a1423          	sh	s2,72(s4)
  ip->nlink = 1;
    8000553e:	4785                	li	a5,1
    80005540:	04fa1523          	sh	a5,74(s4)
  iupdate(ip);
    80005544:	8552                	mv	a0,s4
    80005546:	ffffe097          	auipc	ra,0xffffe
    8000554a:	51c080e7          	jalr	1308(ra) # 80003a62 <iupdate>
  if(type == T_DIR){  // Create . and .. entries.
    8000554e:	000b059b          	sext.w	a1,s6
    80005552:	4785                	li	a5,1
    80005554:	02f58b63          	beq	a1,a5,8000558a <create+0x106>
  if(dirlink(dp, name, ip->inum) < 0)
    80005558:	004a2603          	lw	a2,4(s4)
    8000555c:	fb040593          	addi	a1,s0,-80
    80005560:	8526                	mv	a0,s1
    80005562:	fffff097          	auipc	ra,0xfffff
    80005566:	cbe080e7          	jalr	-834(ra) # 80004220 <dirlink>
    8000556a:	06054f63          	bltz	a0,800055e8 <create+0x164>
  iunlockput(dp);
    8000556e:	8526                	mv	a0,s1
    80005570:	fffff097          	auipc	ra,0xfffff
    80005574:	81e080e7          	jalr	-2018(ra) # 80003d8e <iunlockput>
  return ip;
    80005578:	8ad2                	mv	s5,s4
    8000557a:	b741                	j	800054fa <create+0x76>
    iunlockput(dp);
    8000557c:	8526                	mv	a0,s1
    8000557e:	fffff097          	auipc	ra,0xfffff
    80005582:	810080e7          	jalr	-2032(ra) # 80003d8e <iunlockput>
    return 0;
    80005586:	8ad2                	mv	s5,s4
    80005588:	bf8d                	j	800054fa <create+0x76>
    if(dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
    8000558a:	004a2603          	lw	a2,4(s4)
    8000558e:	00003597          	auipc	a1,0x3
    80005592:	2aa58593          	addi	a1,a1,682 # 80008838 <syscalls+0x2c8>
    80005596:	8552                	mv	a0,s4
    80005598:	fffff097          	auipc	ra,0xfffff
    8000559c:	c88080e7          	jalr	-888(ra) # 80004220 <dirlink>
    800055a0:	04054463          	bltz	a0,800055e8 <create+0x164>
    800055a4:	40d0                	lw	a2,4(s1)
    800055a6:	00003597          	auipc	a1,0x3
    800055aa:	29a58593          	addi	a1,a1,666 # 80008840 <syscalls+0x2d0>
    800055ae:	8552                	mv	a0,s4
    800055b0:	fffff097          	auipc	ra,0xfffff
    800055b4:	c70080e7          	jalr	-912(ra) # 80004220 <dirlink>
    800055b8:	02054863          	bltz	a0,800055e8 <create+0x164>
  if(dirlink(dp, name, ip->inum) < 0)
    800055bc:	004a2603          	lw	a2,4(s4)
    800055c0:	fb040593          	addi	a1,s0,-80
    800055c4:	8526                	mv	a0,s1
    800055c6:	fffff097          	auipc	ra,0xfffff
    800055ca:	c5a080e7          	jalr	-934(ra) # 80004220 <dirlink>
    800055ce:	00054d63          	bltz	a0,800055e8 <create+0x164>
    dp->nlink++;  // for ".."
    800055d2:	04a4d783          	lhu	a5,74(s1)
    800055d6:	2785                	addiw	a5,a5,1
    800055d8:	04f49523          	sh	a5,74(s1)
    iupdate(dp);
    800055dc:	8526                	mv	a0,s1
    800055de:	ffffe097          	auipc	ra,0xffffe
    800055e2:	484080e7          	jalr	1156(ra) # 80003a62 <iupdate>
    800055e6:	b761                	j	8000556e <create+0xea>
  ip->nlink = 0;
    800055e8:	040a1523          	sh	zero,74(s4)
  iupdate(ip);
    800055ec:	8552                	mv	a0,s4
    800055ee:	ffffe097          	auipc	ra,0xffffe
    800055f2:	474080e7          	jalr	1140(ra) # 80003a62 <iupdate>
  iunlockput(ip);
    800055f6:	8552                	mv	a0,s4
    800055f8:	ffffe097          	auipc	ra,0xffffe
    800055fc:	796080e7          	jalr	1942(ra) # 80003d8e <iunlockput>
  iunlockput(dp);
    80005600:	8526                	mv	a0,s1
    80005602:	ffffe097          	auipc	ra,0xffffe
    80005606:	78c080e7          	jalr	1932(ra) # 80003d8e <iunlockput>
  return 0;
    8000560a:	bdc5                	j	800054fa <create+0x76>
    return 0;
    8000560c:	8aaa                	mv	s5,a0
    8000560e:	b5f5                	j	800054fa <create+0x76>

0000000080005610 <sys_dup>:
{
    80005610:	7179                	addi	sp,sp,-48
    80005612:	f406                	sd	ra,40(sp)
    80005614:	f022                	sd	s0,32(sp)
    80005616:	ec26                	sd	s1,24(sp)
    80005618:	1800                	addi	s0,sp,48
  if(argfd(0, 0, &f) < 0)
    8000561a:	fd840613          	addi	a2,s0,-40
    8000561e:	4581                	li	a1,0
    80005620:	4501                	li	a0,0
    80005622:	00000097          	auipc	ra,0x0
    80005626:	dc0080e7          	jalr	-576(ra) # 800053e2 <argfd>
    return -1;
    8000562a:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0)
    8000562c:	02054363          	bltz	a0,80005652 <sys_dup+0x42>
  if((fd=fdalloc(f)) < 0)
    80005630:	fd843503          	ld	a0,-40(s0)
    80005634:	00000097          	auipc	ra,0x0
    80005638:	e0e080e7          	jalr	-498(ra) # 80005442 <fdalloc>
    8000563c:	84aa                	mv	s1,a0
    return -1;
    8000563e:	57fd                	li	a5,-1
  if((fd=fdalloc(f)) < 0)
    80005640:	00054963          	bltz	a0,80005652 <sys_dup+0x42>
  filedup(f);
    80005644:	fd843503          	ld	a0,-40(s0)
    80005648:	fffff097          	auipc	ra,0xfffff
    8000564c:	320080e7          	jalr	800(ra) # 80004968 <filedup>
  return fd;
    80005650:	87a6                	mv	a5,s1
}
    80005652:	853e                	mv	a0,a5
    80005654:	70a2                	ld	ra,40(sp)
    80005656:	7402                	ld	s0,32(sp)
    80005658:	64e2                	ld	s1,24(sp)
    8000565a:	6145                	addi	sp,sp,48
    8000565c:	8082                	ret

000000008000565e <sys_read>:
{
    8000565e:	7179                	addi	sp,sp,-48
    80005660:	f406                	sd	ra,40(sp)
    80005662:	f022                	sd	s0,32(sp)
    80005664:	1800                	addi	s0,sp,48
  argaddr(1, &p);
    80005666:	fd840593          	addi	a1,s0,-40
    8000566a:	4505                	li	a0,1
    8000566c:	ffffe097          	auipc	ra,0xffffe
    80005670:	8a0080e7          	jalr	-1888(ra) # 80002f0c <argaddr>
  argint(2, &n);
    80005674:	fe440593          	addi	a1,s0,-28
    80005678:	4509                	li	a0,2
    8000567a:	ffffe097          	auipc	ra,0xffffe
    8000567e:	872080e7          	jalr	-1934(ra) # 80002eec <argint>
  if(argfd(0, 0, &f) < 0)
    80005682:	fe840613          	addi	a2,s0,-24
    80005686:	4581                	li	a1,0
    80005688:	4501                	li	a0,0
    8000568a:	00000097          	auipc	ra,0x0
    8000568e:	d58080e7          	jalr	-680(ra) # 800053e2 <argfd>
    80005692:	87aa                	mv	a5,a0
    return -1;
    80005694:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    80005696:	0007cc63          	bltz	a5,800056ae <sys_read+0x50>
  return fileread(f, p, n);
    8000569a:	fe442603          	lw	a2,-28(s0)
    8000569e:	fd843583          	ld	a1,-40(s0)
    800056a2:	fe843503          	ld	a0,-24(s0)
    800056a6:	fffff097          	auipc	ra,0xfffff
    800056aa:	44e080e7          	jalr	1102(ra) # 80004af4 <fileread>
}
    800056ae:	70a2                	ld	ra,40(sp)
    800056b0:	7402                	ld	s0,32(sp)
    800056b2:	6145                	addi	sp,sp,48
    800056b4:	8082                	ret

00000000800056b6 <sys_write>:
{
    800056b6:	7179                	addi	sp,sp,-48
    800056b8:	f406                	sd	ra,40(sp)
    800056ba:	f022                	sd	s0,32(sp)
    800056bc:	1800                	addi	s0,sp,48
  argaddr(1, &p);
    800056be:	fd840593          	addi	a1,s0,-40
    800056c2:	4505                	li	a0,1
    800056c4:	ffffe097          	auipc	ra,0xffffe
    800056c8:	848080e7          	jalr	-1976(ra) # 80002f0c <argaddr>
  argint(2, &n);
    800056cc:	fe440593          	addi	a1,s0,-28
    800056d0:	4509                	li	a0,2
    800056d2:	ffffe097          	auipc	ra,0xffffe
    800056d6:	81a080e7          	jalr	-2022(ra) # 80002eec <argint>
  if(argfd(0, 0, &f) < 0)
    800056da:	fe840613          	addi	a2,s0,-24
    800056de:	4581                	li	a1,0
    800056e0:	4501                	li	a0,0
    800056e2:	00000097          	auipc	ra,0x0
    800056e6:	d00080e7          	jalr	-768(ra) # 800053e2 <argfd>
    800056ea:	87aa                	mv	a5,a0
    return -1;
    800056ec:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    800056ee:	0007cc63          	bltz	a5,80005706 <sys_write+0x50>
  return filewrite(f, p, n);
    800056f2:	fe442603          	lw	a2,-28(s0)
    800056f6:	fd843583          	ld	a1,-40(s0)
    800056fa:	fe843503          	ld	a0,-24(s0)
    800056fe:	fffff097          	auipc	ra,0xfffff
    80005702:	4b8080e7          	jalr	1208(ra) # 80004bb6 <filewrite>
}
    80005706:	70a2                	ld	ra,40(sp)
    80005708:	7402                	ld	s0,32(sp)
    8000570a:	6145                	addi	sp,sp,48
    8000570c:	8082                	ret

000000008000570e <sys_close>:
{
    8000570e:	1101                	addi	sp,sp,-32
    80005710:	ec06                	sd	ra,24(sp)
    80005712:	e822                	sd	s0,16(sp)
    80005714:	1000                	addi	s0,sp,32
  if(argfd(0, &fd, &f) < 0)
    80005716:	fe040613          	addi	a2,s0,-32
    8000571a:	fec40593          	addi	a1,s0,-20
    8000571e:	4501                	li	a0,0
    80005720:	00000097          	auipc	ra,0x0
    80005724:	cc2080e7          	jalr	-830(ra) # 800053e2 <argfd>
    return -1;
    80005728:	57fd                	li	a5,-1
  if(argfd(0, &fd, &f) < 0)
    8000572a:	02054463          	bltz	a0,80005752 <sys_close+0x44>
  myproc()->ofile[fd] = 0;
    8000572e:	ffffc097          	auipc	ra,0xffffc
    80005732:	442080e7          	jalr	1090(ra) # 80001b70 <myproc>
    80005736:	fec42783          	lw	a5,-20(s0)
    8000573a:	07e9                	addi	a5,a5,26
    8000573c:	078e                	slli	a5,a5,0x3
    8000573e:	97aa                	add	a5,a5,a0
    80005740:	0007b023          	sd	zero,0(a5)
  fileclose(f);
    80005744:	fe043503          	ld	a0,-32(s0)
    80005748:	fffff097          	auipc	ra,0xfffff
    8000574c:	272080e7          	jalr	626(ra) # 800049ba <fileclose>
  return 0;
    80005750:	4781                	li	a5,0
}
    80005752:	853e                	mv	a0,a5
    80005754:	60e2                	ld	ra,24(sp)
    80005756:	6442                	ld	s0,16(sp)
    80005758:	6105                	addi	sp,sp,32
    8000575a:	8082                	ret

000000008000575c <sys_fstat>:
{
    8000575c:	1101                	addi	sp,sp,-32
    8000575e:	ec06                	sd	ra,24(sp)
    80005760:	e822                	sd	s0,16(sp)
    80005762:	1000                	addi	s0,sp,32
  argaddr(1, &st);
    80005764:	fe040593          	addi	a1,s0,-32
    80005768:	4505                	li	a0,1
    8000576a:	ffffd097          	auipc	ra,0xffffd
    8000576e:	7a2080e7          	jalr	1954(ra) # 80002f0c <argaddr>
  if(argfd(0, 0, &f) < 0)
    80005772:	fe840613          	addi	a2,s0,-24
    80005776:	4581                	li	a1,0
    80005778:	4501                	li	a0,0
    8000577a:	00000097          	auipc	ra,0x0
    8000577e:	c68080e7          	jalr	-920(ra) # 800053e2 <argfd>
    80005782:	87aa                	mv	a5,a0
    return -1;
    80005784:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    80005786:	0007ca63          	bltz	a5,8000579a <sys_fstat+0x3e>
  return filestat(f, st);
    8000578a:	fe043583          	ld	a1,-32(s0)
    8000578e:	fe843503          	ld	a0,-24(s0)
    80005792:	fffff097          	auipc	ra,0xfffff
    80005796:	2f0080e7          	jalr	752(ra) # 80004a82 <filestat>
}
    8000579a:	60e2                	ld	ra,24(sp)
    8000579c:	6442                	ld	s0,16(sp)
    8000579e:	6105                	addi	sp,sp,32
    800057a0:	8082                	ret

00000000800057a2 <sys_link>:
{
    800057a2:	7169                	addi	sp,sp,-304
    800057a4:	f606                	sd	ra,296(sp)
    800057a6:	f222                	sd	s0,288(sp)
    800057a8:	ee26                	sd	s1,280(sp)
    800057aa:	ea4a                	sd	s2,272(sp)
    800057ac:	1a00                	addi	s0,sp,304
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    800057ae:	08000613          	li	a2,128
    800057b2:	ed040593          	addi	a1,s0,-304
    800057b6:	4501                	li	a0,0
    800057b8:	ffffd097          	auipc	ra,0xffffd
    800057bc:	774080e7          	jalr	1908(ra) # 80002f2c <argstr>
    return -1;
    800057c0:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    800057c2:	10054e63          	bltz	a0,800058de <sys_link+0x13c>
    800057c6:	08000613          	li	a2,128
    800057ca:	f5040593          	addi	a1,s0,-176
    800057ce:	4505                	li	a0,1
    800057d0:	ffffd097          	auipc	ra,0xffffd
    800057d4:	75c080e7          	jalr	1884(ra) # 80002f2c <argstr>
    return -1;
    800057d8:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    800057da:	10054263          	bltz	a0,800058de <sys_link+0x13c>
  begin_op();
    800057de:	fffff097          	auipc	ra,0xfffff
    800057e2:	d10080e7          	jalr	-752(ra) # 800044ee <begin_op>
  if((ip = namei(old)) == 0){
    800057e6:	ed040513          	addi	a0,s0,-304
    800057ea:	fffff097          	auipc	ra,0xfffff
    800057ee:	ae8080e7          	jalr	-1304(ra) # 800042d2 <namei>
    800057f2:	84aa                	mv	s1,a0
    800057f4:	c551                	beqz	a0,80005880 <sys_link+0xde>
  ilock(ip);
    800057f6:	ffffe097          	auipc	ra,0xffffe
    800057fa:	336080e7          	jalr	822(ra) # 80003b2c <ilock>
  if(ip->type == T_DIR){
    800057fe:	04449703          	lh	a4,68(s1)
    80005802:	4785                	li	a5,1
    80005804:	08f70463          	beq	a4,a5,8000588c <sys_link+0xea>
  ip->nlink++;
    80005808:	04a4d783          	lhu	a5,74(s1)
    8000580c:	2785                	addiw	a5,a5,1
    8000580e:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    80005812:	8526                	mv	a0,s1
    80005814:	ffffe097          	auipc	ra,0xffffe
    80005818:	24e080e7          	jalr	590(ra) # 80003a62 <iupdate>
  iunlock(ip);
    8000581c:	8526                	mv	a0,s1
    8000581e:	ffffe097          	auipc	ra,0xffffe
    80005822:	3d0080e7          	jalr	976(ra) # 80003bee <iunlock>
  if((dp = nameiparent(new, name)) == 0)
    80005826:	fd040593          	addi	a1,s0,-48
    8000582a:	f5040513          	addi	a0,s0,-176
    8000582e:	fffff097          	auipc	ra,0xfffff
    80005832:	ac2080e7          	jalr	-1342(ra) # 800042f0 <nameiparent>
    80005836:	892a                	mv	s2,a0
    80005838:	c935                	beqz	a0,800058ac <sys_link+0x10a>
  ilock(dp);
    8000583a:	ffffe097          	auipc	ra,0xffffe
    8000583e:	2f2080e7          	jalr	754(ra) # 80003b2c <ilock>
  if(dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0){
    80005842:	00092703          	lw	a4,0(s2)
    80005846:	409c                	lw	a5,0(s1)
    80005848:	04f71d63          	bne	a4,a5,800058a2 <sys_link+0x100>
    8000584c:	40d0                	lw	a2,4(s1)
    8000584e:	fd040593          	addi	a1,s0,-48
    80005852:	854a                	mv	a0,s2
    80005854:	fffff097          	auipc	ra,0xfffff
    80005858:	9cc080e7          	jalr	-1588(ra) # 80004220 <dirlink>
    8000585c:	04054363          	bltz	a0,800058a2 <sys_link+0x100>
  iunlockput(dp);
    80005860:	854a                	mv	a0,s2
    80005862:	ffffe097          	auipc	ra,0xffffe
    80005866:	52c080e7          	jalr	1324(ra) # 80003d8e <iunlockput>
  iput(ip);
    8000586a:	8526                	mv	a0,s1
    8000586c:	ffffe097          	auipc	ra,0xffffe
    80005870:	47a080e7          	jalr	1146(ra) # 80003ce6 <iput>
  end_op();
    80005874:	fffff097          	auipc	ra,0xfffff
    80005878:	cfa080e7          	jalr	-774(ra) # 8000456e <end_op>
  return 0;
    8000587c:	4781                	li	a5,0
    8000587e:	a085                	j	800058de <sys_link+0x13c>
    end_op();
    80005880:	fffff097          	auipc	ra,0xfffff
    80005884:	cee080e7          	jalr	-786(ra) # 8000456e <end_op>
    return -1;
    80005888:	57fd                	li	a5,-1
    8000588a:	a891                	j	800058de <sys_link+0x13c>
    iunlockput(ip);
    8000588c:	8526                	mv	a0,s1
    8000588e:	ffffe097          	auipc	ra,0xffffe
    80005892:	500080e7          	jalr	1280(ra) # 80003d8e <iunlockput>
    end_op();
    80005896:	fffff097          	auipc	ra,0xfffff
    8000589a:	cd8080e7          	jalr	-808(ra) # 8000456e <end_op>
    return -1;
    8000589e:	57fd                	li	a5,-1
    800058a0:	a83d                	j	800058de <sys_link+0x13c>
    iunlockput(dp);
    800058a2:	854a                	mv	a0,s2
    800058a4:	ffffe097          	auipc	ra,0xffffe
    800058a8:	4ea080e7          	jalr	1258(ra) # 80003d8e <iunlockput>
  ilock(ip);
    800058ac:	8526                	mv	a0,s1
    800058ae:	ffffe097          	auipc	ra,0xffffe
    800058b2:	27e080e7          	jalr	638(ra) # 80003b2c <ilock>
  ip->nlink--;
    800058b6:	04a4d783          	lhu	a5,74(s1)
    800058ba:	37fd                	addiw	a5,a5,-1
    800058bc:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    800058c0:	8526                	mv	a0,s1
    800058c2:	ffffe097          	auipc	ra,0xffffe
    800058c6:	1a0080e7          	jalr	416(ra) # 80003a62 <iupdate>
  iunlockput(ip);
    800058ca:	8526                	mv	a0,s1
    800058cc:	ffffe097          	auipc	ra,0xffffe
    800058d0:	4c2080e7          	jalr	1218(ra) # 80003d8e <iunlockput>
  end_op();
    800058d4:	fffff097          	auipc	ra,0xfffff
    800058d8:	c9a080e7          	jalr	-870(ra) # 8000456e <end_op>
  return -1;
    800058dc:	57fd                	li	a5,-1
}
    800058de:	853e                	mv	a0,a5
    800058e0:	70b2                	ld	ra,296(sp)
    800058e2:	7412                	ld	s0,288(sp)
    800058e4:	64f2                	ld	s1,280(sp)
    800058e6:	6952                	ld	s2,272(sp)
    800058e8:	6155                	addi	sp,sp,304
    800058ea:	8082                	ret

00000000800058ec <sys_unlink>:
{
    800058ec:	7151                	addi	sp,sp,-240
    800058ee:	f586                	sd	ra,232(sp)
    800058f0:	f1a2                	sd	s0,224(sp)
    800058f2:	eda6                	sd	s1,216(sp)
    800058f4:	e9ca                	sd	s2,208(sp)
    800058f6:	e5ce                	sd	s3,200(sp)
    800058f8:	1980                	addi	s0,sp,240
  if(argstr(0, path, MAXPATH) < 0)
    800058fa:	08000613          	li	a2,128
    800058fe:	f3040593          	addi	a1,s0,-208
    80005902:	4501                	li	a0,0
    80005904:	ffffd097          	auipc	ra,0xffffd
    80005908:	628080e7          	jalr	1576(ra) # 80002f2c <argstr>
    8000590c:	18054163          	bltz	a0,80005a8e <sys_unlink+0x1a2>
  begin_op();
    80005910:	fffff097          	auipc	ra,0xfffff
    80005914:	bde080e7          	jalr	-1058(ra) # 800044ee <begin_op>
  if((dp = nameiparent(path, name)) == 0){
    80005918:	fb040593          	addi	a1,s0,-80
    8000591c:	f3040513          	addi	a0,s0,-208
    80005920:	fffff097          	auipc	ra,0xfffff
    80005924:	9d0080e7          	jalr	-1584(ra) # 800042f0 <nameiparent>
    80005928:	84aa                	mv	s1,a0
    8000592a:	c979                	beqz	a0,80005a00 <sys_unlink+0x114>
  ilock(dp);
    8000592c:	ffffe097          	auipc	ra,0xffffe
    80005930:	200080e7          	jalr	512(ra) # 80003b2c <ilock>
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
    80005934:	00003597          	auipc	a1,0x3
    80005938:	f0458593          	addi	a1,a1,-252 # 80008838 <syscalls+0x2c8>
    8000593c:	fb040513          	addi	a0,s0,-80
    80005940:	ffffe097          	auipc	ra,0xffffe
    80005944:	6b6080e7          	jalr	1718(ra) # 80003ff6 <namecmp>
    80005948:	14050a63          	beqz	a0,80005a9c <sys_unlink+0x1b0>
    8000594c:	00003597          	auipc	a1,0x3
    80005950:	ef458593          	addi	a1,a1,-268 # 80008840 <syscalls+0x2d0>
    80005954:	fb040513          	addi	a0,s0,-80
    80005958:	ffffe097          	auipc	ra,0xffffe
    8000595c:	69e080e7          	jalr	1694(ra) # 80003ff6 <namecmp>
    80005960:	12050e63          	beqz	a0,80005a9c <sys_unlink+0x1b0>
  if((ip = dirlookup(dp, name, &off)) == 0)
    80005964:	f2c40613          	addi	a2,s0,-212
    80005968:	fb040593          	addi	a1,s0,-80
    8000596c:	8526                	mv	a0,s1
    8000596e:	ffffe097          	auipc	ra,0xffffe
    80005972:	6a2080e7          	jalr	1698(ra) # 80004010 <dirlookup>
    80005976:	892a                	mv	s2,a0
    80005978:	12050263          	beqz	a0,80005a9c <sys_unlink+0x1b0>
  ilock(ip);
    8000597c:	ffffe097          	auipc	ra,0xffffe
    80005980:	1b0080e7          	jalr	432(ra) # 80003b2c <ilock>
  if(ip->nlink < 1)
    80005984:	04a91783          	lh	a5,74(s2)
    80005988:	08f05263          	blez	a5,80005a0c <sys_unlink+0x120>
  if(ip->type == T_DIR && !isdirempty(ip)){
    8000598c:	04491703          	lh	a4,68(s2)
    80005990:	4785                	li	a5,1
    80005992:	08f70563          	beq	a4,a5,80005a1c <sys_unlink+0x130>
  memset(&de, 0, sizeof(de));
    80005996:	4641                	li	a2,16
    80005998:	4581                	li	a1,0
    8000599a:	fc040513          	addi	a0,s0,-64
    8000599e:	ffffb097          	auipc	ra,0xffffb
    800059a2:	3f4080e7          	jalr	1012(ra) # 80000d92 <memset>
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    800059a6:	4741                	li	a4,16
    800059a8:	f2c42683          	lw	a3,-212(s0)
    800059ac:	fc040613          	addi	a2,s0,-64
    800059b0:	4581                	li	a1,0
    800059b2:	8526                	mv	a0,s1
    800059b4:	ffffe097          	auipc	ra,0xffffe
    800059b8:	524080e7          	jalr	1316(ra) # 80003ed8 <writei>
    800059bc:	47c1                	li	a5,16
    800059be:	0af51563          	bne	a0,a5,80005a68 <sys_unlink+0x17c>
  if(ip->type == T_DIR){
    800059c2:	04491703          	lh	a4,68(s2)
    800059c6:	4785                	li	a5,1
    800059c8:	0af70863          	beq	a4,a5,80005a78 <sys_unlink+0x18c>
  iunlockput(dp);
    800059cc:	8526                	mv	a0,s1
    800059ce:	ffffe097          	auipc	ra,0xffffe
    800059d2:	3c0080e7          	jalr	960(ra) # 80003d8e <iunlockput>
  ip->nlink--;
    800059d6:	04a95783          	lhu	a5,74(s2)
    800059da:	37fd                	addiw	a5,a5,-1
    800059dc:	04f91523          	sh	a5,74(s2)
  iupdate(ip);
    800059e0:	854a                	mv	a0,s2
    800059e2:	ffffe097          	auipc	ra,0xffffe
    800059e6:	080080e7          	jalr	128(ra) # 80003a62 <iupdate>
  iunlockput(ip);
    800059ea:	854a                	mv	a0,s2
    800059ec:	ffffe097          	auipc	ra,0xffffe
    800059f0:	3a2080e7          	jalr	930(ra) # 80003d8e <iunlockput>
  end_op();
    800059f4:	fffff097          	auipc	ra,0xfffff
    800059f8:	b7a080e7          	jalr	-1158(ra) # 8000456e <end_op>
  return 0;
    800059fc:	4501                	li	a0,0
    800059fe:	a84d                	j	80005ab0 <sys_unlink+0x1c4>
    end_op();
    80005a00:	fffff097          	auipc	ra,0xfffff
    80005a04:	b6e080e7          	jalr	-1170(ra) # 8000456e <end_op>
    return -1;
    80005a08:	557d                	li	a0,-1
    80005a0a:	a05d                	j	80005ab0 <sys_unlink+0x1c4>
    panic("unlink: nlink < 1");
    80005a0c:	00003517          	auipc	a0,0x3
    80005a10:	e3c50513          	addi	a0,a0,-452 # 80008848 <syscalls+0x2d8>
    80005a14:	ffffb097          	auipc	ra,0xffffb
    80005a18:	b14080e7          	jalr	-1260(ra) # 80000528 <panic>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    80005a1c:	04c92703          	lw	a4,76(s2)
    80005a20:	02000793          	li	a5,32
    80005a24:	f6e7f9e3          	bgeu	a5,a4,80005996 <sys_unlink+0xaa>
    80005a28:	02000993          	li	s3,32
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80005a2c:	4741                	li	a4,16
    80005a2e:	86ce                	mv	a3,s3
    80005a30:	f1840613          	addi	a2,s0,-232
    80005a34:	4581                	li	a1,0
    80005a36:	854a                	mv	a0,s2
    80005a38:	ffffe097          	auipc	ra,0xffffe
    80005a3c:	3a8080e7          	jalr	936(ra) # 80003de0 <readi>
    80005a40:	47c1                	li	a5,16
    80005a42:	00f51b63          	bne	a0,a5,80005a58 <sys_unlink+0x16c>
    if(de.inum != 0)
    80005a46:	f1845783          	lhu	a5,-232(s0)
    80005a4a:	e7a1                	bnez	a5,80005a92 <sys_unlink+0x1a6>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    80005a4c:	29c1                	addiw	s3,s3,16
    80005a4e:	04c92783          	lw	a5,76(s2)
    80005a52:	fcf9ede3          	bltu	s3,a5,80005a2c <sys_unlink+0x140>
    80005a56:	b781                	j	80005996 <sys_unlink+0xaa>
      panic("isdirempty: readi");
    80005a58:	00003517          	auipc	a0,0x3
    80005a5c:	e0850513          	addi	a0,a0,-504 # 80008860 <syscalls+0x2f0>
    80005a60:	ffffb097          	auipc	ra,0xffffb
    80005a64:	ac8080e7          	jalr	-1336(ra) # 80000528 <panic>
    panic("unlink: writei");
    80005a68:	00003517          	auipc	a0,0x3
    80005a6c:	e1050513          	addi	a0,a0,-496 # 80008878 <syscalls+0x308>
    80005a70:	ffffb097          	auipc	ra,0xffffb
    80005a74:	ab8080e7          	jalr	-1352(ra) # 80000528 <panic>
    dp->nlink--;
    80005a78:	04a4d783          	lhu	a5,74(s1)
    80005a7c:	37fd                	addiw	a5,a5,-1
    80005a7e:	04f49523          	sh	a5,74(s1)
    iupdate(dp);
    80005a82:	8526                	mv	a0,s1
    80005a84:	ffffe097          	auipc	ra,0xffffe
    80005a88:	fde080e7          	jalr	-34(ra) # 80003a62 <iupdate>
    80005a8c:	b781                	j	800059cc <sys_unlink+0xe0>
    return -1;
    80005a8e:	557d                	li	a0,-1
    80005a90:	a005                	j	80005ab0 <sys_unlink+0x1c4>
    iunlockput(ip);
    80005a92:	854a                	mv	a0,s2
    80005a94:	ffffe097          	auipc	ra,0xffffe
    80005a98:	2fa080e7          	jalr	762(ra) # 80003d8e <iunlockput>
  iunlockput(dp);
    80005a9c:	8526                	mv	a0,s1
    80005a9e:	ffffe097          	auipc	ra,0xffffe
    80005aa2:	2f0080e7          	jalr	752(ra) # 80003d8e <iunlockput>
  end_op();
    80005aa6:	fffff097          	auipc	ra,0xfffff
    80005aaa:	ac8080e7          	jalr	-1336(ra) # 8000456e <end_op>
  return -1;
    80005aae:	557d                	li	a0,-1
}
    80005ab0:	70ae                	ld	ra,232(sp)
    80005ab2:	740e                	ld	s0,224(sp)
    80005ab4:	64ee                	ld	s1,216(sp)
    80005ab6:	694e                	ld	s2,208(sp)
    80005ab8:	69ae                	ld	s3,200(sp)
    80005aba:	616d                	addi	sp,sp,240
    80005abc:	8082                	ret

0000000080005abe <sys_open>:

uint64
sys_open(void)
{
    80005abe:	7131                	addi	sp,sp,-192
    80005ac0:	fd06                	sd	ra,184(sp)
    80005ac2:	f922                	sd	s0,176(sp)
    80005ac4:	f526                	sd	s1,168(sp)
    80005ac6:	f14a                	sd	s2,160(sp)
    80005ac8:	ed4e                	sd	s3,152(sp)
    80005aca:	0180                	addi	s0,sp,192
  int fd, omode;
  struct file *f;
  struct inode *ip;
  int n;

  argint(1, &omode);
    80005acc:	f4c40593          	addi	a1,s0,-180
    80005ad0:	4505                	li	a0,1
    80005ad2:	ffffd097          	auipc	ra,0xffffd
    80005ad6:	41a080e7          	jalr	1050(ra) # 80002eec <argint>
  if((n = argstr(0, path, MAXPATH)) < 0)
    80005ada:	08000613          	li	a2,128
    80005ade:	f5040593          	addi	a1,s0,-176
    80005ae2:	4501                	li	a0,0
    80005ae4:	ffffd097          	auipc	ra,0xffffd
    80005ae8:	448080e7          	jalr	1096(ra) # 80002f2c <argstr>
    80005aec:	87aa                	mv	a5,a0
    return -1;
    80005aee:	557d                	li	a0,-1
  if((n = argstr(0, path, MAXPATH)) < 0)
    80005af0:	0a07c963          	bltz	a5,80005ba2 <sys_open+0xe4>

  begin_op();
    80005af4:	fffff097          	auipc	ra,0xfffff
    80005af8:	9fa080e7          	jalr	-1542(ra) # 800044ee <begin_op>

  if(omode & O_CREATE){
    80005afc:	f4c42783          	lw	a5,-180(s0)
    80005b00:	2007f793          	andi	a5,a5,512
    80005b04:	cfc5                	beqz	a5,80005bbc <sys_open+0xfe>
    ip = create(path, T_FILE, 0, 0);
    80005b06:	4681                	li	a3,0
    80005b08:	4601                	li	a2,0
    80005b0a:	4589                	li	a1,2
    80005b0c:	f5040513          	addi	a0,s0,-176
    80005b10:	00000097          	auipc	ra,0x0
    80005b14:	974080e7          	jalr	-1676(ra) # 80005484 <create>
    80005b18:	84aa                	mv	s1,a0
    if(ip == 0){
    80005b1a:	c959                	beqz	a0,80005bb0 <sys_open+0xf2>
      end_op();
      return -1;
    }
  }

  if(ip->type == T_DEVICE && (ip->major < 0 || ip->major >= NDEV)){
    80005b1c:	04449703          	lh	a4,68(s1)
    80005b20:	478d                	li	a5,3
    80005b22:	00f71763          	bne	a4,a5,80005b30 <sys_open+0x72>
    80005b26:	0464d703          	lhu	a4,70(s1)
    80005b2a:	47a5                	li	a5,9
    80005b2c:	0ce7ed63          	bltu	a5,a4,80005c06 <sys_open+0x148>
    iunlockput(ip);
    end_op();
    return -1;
  }

  if((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0){
    80005b30:	fffff097          	auipc	ra,0xfffff
    80005b34:	dce080e7          	jalr	-562(ra) # 800048fe <filealloc>
    80005b38:	89aa                	mv	s3,a0
    80005b3a:	10050363          	beqz	a0,80005c40 <sys_open+0x182>
    80005b3e:	00000097          	auipc	ra,0x0
    80005b42:	904080e7          	jalr	-1788(ra) # 80005442 <fdalloc>
    80005b46:	892a                	mv	s2,a0
    80005b48:	0e054763          	bltz	a0,80005c36 <sys_open+0x178>
    iunlockput(ip);
    end_op();
    return -1;
  }

  if(ip->type == T_DEVICE){
    80005b4c:	04449703          	lh	a4,68(s1)
    80005b50:	478d                	li	a5,3
    80005b52:	0cf70563          	beq	a4,a5,80005c1c <sys_open+0x15e>
    f->type = FD_DEVICE;
    f->major = ip->major;
  } else {
    f->type = FD_INODE;
    80005b56:	4789                	li	a5,2
    80005b58:	00f9a023          	sw	a5,0(s3)
    f->off = 0;
    80005b5c:	0209a023          	sw	zero,32(s3)
  }
  f->ip = ip;
    80005b60:	0099bc23          	sd	s1,24(s3)
  f->readable = !(omode & O_WRONLY);
    80005b64:	f4c42783          	lw	a5,-180(s0)
    80005b68:	0017c713          	xori	a4,a5,1
    80005b6c:	8b05                	andi	a4,a4,1
    80005b6e:	00e98423          	sb	a4,8(s3)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
    80005b72:	0037f713          	andi	a4,a5,3
    80005b76:	00e03733          	snez	a4,a4
    80005b7a:	00e984a3          	sb	a4,9(s3)

  if((omode & O_TRUNC) && ip->type == T_FILE){
    80005b7e:	4007f793          	andi	a5,a5,1024
    80005b82:	c791                	beqz	a5,80005b8e <sys_open+0xd0>
    80005b84:	04449703          	lh	a4,68(s1)
    80005b88:	4789                	li	a5,2
    80005b8a:	0af70063          	beq	a4,a5,80005c2a <sys_open+0x16c>
    itrunc(ip);
  }

  iunlock(ip);
    80005b8e:	8526                	mv	a0,s1
    80005b90:	ffffe097          	auipc	ra,0xffffe
    80005b94:	05e080e7          	jalr	94(ra) # 80003bee <iunlock>
  end_op();
    80005b98:	fffff097          	auipc	ra,0xfffff
    80005b9c:	9d6080e7          	jalr	-1578(ra) # 8000456e <end_op>

  return fd;
    80005ba0:	854a                	mv	a0,s2
}
    80005ba2:	70ea                	ld	ra,184(sp)
    80005ba4:	744a                	ld	s0,176(sp)
    80005ba6:	74aa                	ld	s1,168(sp)
    80005ba8:	790a                	ld	s2,160(sp)
    80005baa:	69ea                	ld	s3,152(sp)
    80005bac:	6129                	addi	sp,sp,192
    80005bae:	8082                	ret
      end_op();
    80005bb0:	fffff097          	auipc	ra,0xfffff
    80005bb4:	9be080e7          	jalr	-1602(ra) # 8000456e <end_op>
      return -1;
    80005bb8:	557d                	li	a0,-1
    80005bba:	b7e5                	j	80005ba2 <sys_open+0xe4>
    if((ip = namei(path)) == 0){
    80005bbc:	f5040513          	addi	a0,s0,-176
    80005bc0:	ffffe097          	auipc	ra,0xffffe
    80005bc4:	712080e7          	jalr	1810(ra) # 800042d2 <namei>
    80005bc8:	84aa                	mv	s1,a0
    80005bca:	c905                	beqz	a0,80005bfa <sys_open+0x13c>
    ilock(ip);
    80005bcc:	ffffe097          	auipc	ra,0xffffe
    80005bd0:	f60080e7          	jalr	-160(ra) # 80003b2c <ilock>
    if(ip->type == T_DIR && omode != O_RDONLY){
    80005bd4:	04449703          	lh	a4,68(s1)
    80005bd8:	4785                	li	a5,1
    80005bda:	f4f711e3          	bne	a4,a5,80005b1c <sys_open+0x5e>
    80005bde:	f4c42783          	lw	a5,-180(s0)
    80005be2:	d7b9                	beqz	a5,80005b30 <sys_open+0x72>
      iunlockput(ip);
    80005be4:	8526                	mv	a0,s1
    80005be6:	ffffe097          	auipc	ra,0xffffe
    80005bea:	1a8080e7          	jalr	424(ra) # 80003d8e <iunlockput>
      end_op();
    80005bee:	fffff097          	auipc	ra,0xfffff
    80005bf2:	980080e7          	jalr	-1664(ra) # 8000456e <end_op>
      return -1;
    80005bf6:	557d                	li	a0,-1
    80005bf8:	b76d                	j	80005ba2 <sys_open+0xe4>
      end_op();
    80005bfa:	fffff097          	auipc	ra,0xfffff
    80005bfe:	974080e7          	jalr	-1676(ra) # 8000456e <end_op>
      return -1;
    80005c02:	557d                	li	a0,-1
    80005c04:	bf79                	j	80005ba2 <sys_open+0xe4>
    iunlockput(ip);
    80005c06:	8526                	mv	a0,s1
    80005c08:	ffffe097          	auipc	ra,0xffffe
    80005c0c:	186080e7          	jalr	390(ra) # 80003d8e <iunlockput>
    end_op();
    80005c10:	fffff097          	auipc	ra,0xfffff
    80005c14:	95e080e7          	jalr	-1698(ra) # 8000456e <end_op>
    return -1;
    80005c18:	557d                	li	a0,-1
    80005c1a:	b761                	j	80005ba2 <sys_open+0xe4>
    f->type = FD_DEVICE;
    80005c1c:	00f9a023          	sw	a5,0(s3)
    f->major = ip->major;
    80005c20:	04649783          	lh	a5,70(s1)
    80005c24:	02f99223          	sh	a5,36(s3)
    80005c28:	bf25                	j	80005b60 <sys_open+0xa2>
    itrunc(ip);
    80005c2a:	8526                	mv	a0,s1
    80005c2c:	ffffe097          	auipc	ra,0xffffe
    80005c30:	00e080e7          	jalr	14(ra) # 80003c3a <itrunc>
    80005c34:	bfa9                	j	80005b8e <sys_open+0xd0>
      fileclose(f);
    80005c36:	854e                	mv	a0,s3
    80005c38:	fffff097          	auipc	ra,0xfffff
    80005c3c:	d82080e7          	jalr	-638(ra) # 800049ba <fileclose>
    iunlockput(ip);
    80005c40:	8526                	mv	a0,s1
    80005c42:	ffffe097          	auipc	ra,0xffffe
    80005c46:	14c080e7          	jalr	332(ra) # 80003d8e <iunlockput>
    end_op();
    80005c4a:	fffff097          	auipc	ra,0xfffff
    80005c4e:	924080e7          	jalr	-1756(ra) # 8000456e <end_op>
    return -1;
    80005c52:	557d                	li	a0,-1
    80005c54:	b7b9                	j	80005ba2 <sys_open+0xe4>

0000000080005c56 <sys_mkdir>:

uint64
sys_mkdir(void)
{
    80005c56:	7175                	addi	sp,sp,-144
    80005c58:	e506                	sd	ra,136(sp)
    80005c5a:	e122                	sd	s0,128(sp)
    80005c5c:	0900                	addi	s0,sp,144
  char path[MAXPATH];
  struct inode *ip;

  begin_op();
    80005c5e:	fffff097          	auipc	ra,0xfffff
    80005c62:	890080e7          	jalr	-1904(ra) # 800044ee <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0){
    80005c66:	08000613          	li	a2,128
    80005c6a:	f7040593          	addi	a1,s0,-144
    80005c6e:	4501                	li	a0,0
    80005c70:	ffffd097          	auipc	ra,0xffffd
    80005c74:	2bc080e7          	jalr	700(ra) # 80002f2c <argstr>
    80005c78:	02054963          	bltz	a0,80005caa <sys_mkdir+0x54>
    80005c7c:	4681                	li	a3,0
    80005c7e:	4601                	li	a2,0
    80005c80:	4585                	li	a1,1
    80005c82:	f7040513          	addi	a0,s0,-144
    80005c86:	fffff097          	auipc	ra,0xfffff
    80005c8a:	7fe080e7          	jalr	2046(ra) # 80005484 <create>
    80005c8e:	cd11                	beqz	a0,80005caa <sys_mkdir+0x54>
    end_op();
    return -1;
  }
  iunlockput(ip);
    80005c90:	ffffe097          	auipc	ra,0xffffe
    80005c94:	0fe080e7          	jalr	254(ra) # 80003d8e <iunlockput>
  end_op();
    80005c98:	fffff097          	auipc	ra,0xfffff
    80005c9c:	8d6080e7          	jalr	-1834(ra) # 8000456e <end_op>
  return 0;
    80005ca0:	4501                	li	a0,0
}
    80005ca2:	60aa                	ld	ra,136(sp)
    80005ca4:	640a                	ld	s0,128(sp)
    80005ca6:	6149                	addi	sp,sp,144
    80005ca8:	8082                	ret
    end_op();
    80005caa:	fffff097          	auipc	ra,0xfffff
    80005cae:	8c4080e7          	jalr	-1852(ra) # 8000456e <end_op>
    return -1;
    80005cb2:	557d                	li	a0,-1
    80005cb4:	b7fd                	j	80005ca2 <sys_mkdir+0x4c>

0000000080005cb6 <sys_mknod>:

uint64
sys_mknod(void)
{
    80005cb6:	7135                	addi	sp,sp,-160
    80005cb8:	ed06                	sd	ra,152(sp)
    80005cba:	e922                	sd	s0,144(sp)
    80005cbc:	1100                	addi	s0,sp,160
  struct inode *ip;
  char path[MAXPATH];
  int major, minor;

  begin_op();
    80005cbe:	fffff097          	auipc	ra,0xfffff
    80005cc2:	830080e7          	jalr	-2000(ra) # 800044ee <begin_op>
  argint(1, &major);
    80005cc6:	f6c40593          	addi	a1,s0,-148
    80005cca:	4505                	li	a0,1
    80005ccc:	ffffd097          	auipc	ra,0xffffd
    80005cd0:	220080e7          	jalr	544(ra) # 80002eec <argint>
  argint(2, &minor);
    80005cd4:	f6840593          	addi	a1,s0,-152
    80005cd8:	4509                	li	a0,2
    80005cda:	ffffd097          	auipc	ra,0xffffd
    80005cde:	212080e7          	jalr	530(ra) # 80002eec <argint>
  if((argstr(0, path, MAXPATH)) < 0 ||
    80005ce2:	08000613          	li	a2,128
    80005ce6:	f7040593          	addi	a1,s0,-144
    80005cea:	4501                	li	a0,0
    80005cec:	ffffd097          	auipc	ra,0xffffd
    80005cf0:	240080e7          	jalr	576(ra) # 80002f2c <argstr>
    80005cf4:	02054b63          	bltz	a0,80005d2a <sys_mknod+0x74>
     (ip = create(path, T_DEVICE, major, minor)) == 0){
    80005cf8:	f6841683          	lh	a3,-152(s0)
    80005cfc:	f6c41603          	lh	a2,-148(s0)
    80005d00:	458d                	li	a1,3
    80005d02:	f7040513          	addi	a0,s0,-144
    80005d06:	fffff097          	auipc	ra,0xfffff
    80005d0a:	77e080e7          	jalr	1918(ra) # 80005484 <create>
  if((argstr(0, path, MAXPATH)) < 0 ||
    80005d0e:	cd11                	beqz	a0,80005d2a <sys_mknod+0x74>
    end_op();
    return -1;
  }
  iunlockput(ip);
    80005d10:	ffffe097          	auipc	ra,0xffffe
    80005d14:	07e080e7          	jalr	126(ra) # 80003d8e <iunlockput>
  end_op();
    80005d18:	fffff097          	auipc	ra,0xfffff
    80005d1c:	856080e7          	jalr	-1962(ra) # 8000456e <end_op>
  return 0;
    80005d20:	4501                	li	a0,0
}
    80005d22:	60ea                	ld	ra,152(sp)
    80005d24:	644a                	ld	s0,144(sp)
    80005d26:	610d                	addi	sp,sp,160
    80005d28:	8082                	ret
    end_op();
    80005d2a:	fffff097          	auipc	ra,0xfffff
    80005d2e:	844080e7          	jalr	-1980(ra) # 8000456e <end_op>
    return -1;
    80005d32:	557d                	li	a0,-1
    80005d34:	b7fd                	j	80005d22 <sys_mknod+0x6c>

0000000080005d36 <sys_chdir>:

uint64
sys_chdir(void)
{
    80005d36:	7135                	addi	sp,sp,-160
    80005d38:	ed06                	sd	ra,152(sp)
    80005d3a:	e922                	sd	s0,144(sp)
    80005d3c:	e526                	sd	s1,136(sp)
    80005d3e:	e14a                	sd	s2,128(sp)
    80005d40:	1100                	addi	s0,sp,160
  char path[MAXPATH];
  struct inode *ip;
  struct proc *p = myproc();
    80005d42:	ffffc097          	auipc	ra,0xffffc
    80005d46:	e2e080e7          	jalr	-466(ra) # 80001b70 <myproc>
    80005d4a:	892a                	mv	s2,a0
  
  begin_op();
    80005d4c:	ffffe097          	auipc	ra,0xffffe
    80005d50:	7a2080e7          	jalr	1954(ra) # 800044ee <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = namei(path)) == 0){
    80005d54:	08000613          	li	a2,128
    80005d58:	f6040593          	addi	a1,s0,-160
    80005d5c:	4501                	li	a0,0
    80005d5e:	ffffd097          	auipc	ra,0xffffd
    80005d62:	1ce080e7          	jalr	462(ra) # 80002f2c <argstr>
    80005d66:	04054b63          	bltz	a0,80005dbc <sys_chdir+0x86>
    80005d6a:	f6040513          	addi	a0,s0,-160
    80005d6e:	ffffe097          	auipc	ra,0xffffe
    80005d72:	564080e7          	jalr	1380(ra) # 800042d2 <namei>
    80005d76:	84aa                	mv	s1,a0
    80005d78:	c131                	beqz	a0,80005dbc <sys_chdir+0x86>
    end_op();
    return -1;
  }
  ilock(ip);
    80005d7a:	ffffe097          	auipc	ra,0xffffe
    80005d7e:	db2080e7          	jalr	-590(ra) # 80003b2c <ilock>
  if(ip->type != T_DIR){
    80005d82:	04449703          	lh	a4,68(s1)
    80005d86:	4785                	li	a5,1
    80005d88:	04f71063          	bne	a4,a5,80005dc8 <sys_chdir+0x92>
    iunlockput(ip);
    end_op();
    return -1;
  }
  iunlock(ip);
    80005d8c:	8526                	mv	a0,s1
    80005d8e:	ffffe097          	auipc	ra,0xffffe
    80005d92:	e60080e7          	jalr	-416(ra) # 80003bee <iunlock>
  iput(p->cwd);
    80005d96:	15093503          	ld	a0,336(s2)
    80005d9a:	ffffe097          	auipc	ra,0xffffe
    80005d9e:	f4c080e7          	jalr	-180(ra) # 80003ce6 <iput>
  end_op();
    80005da2:	ffffe097          	auipc	ra,0xffffe
    80005da6:	7cc080e7          	jalr	1996(ra) # 8000456e <end_op>
  p->cwd = ip;
    80005daa:	14993823          	sd	s1,336(s2)
  return 0;
    80005dae:	4501                	li	a0,0
}
    80005db0:	60ea                	ld	ra,152(sp)
    80005db2:	644a                	ld	s0,144(sp)
    80005db4:	64aa                	ld	s1,136(sp)
    80005db6:	690a                	ld	s2,128(sp)
    80005db8:	610d                	addi	sp,sp,160
    80005dba:	8082                	ret
    end_op();
    80005dbc:	ffffe097          	auipc	ra,0xffffe
    80005dc0:	7b2080e7          	jalr	1970(ra) # 8000456e <end_op>
    return -1;
    80005dc4:	557d                	li	a0,-1
    80005dc6:	b7ed                	j	80005db0 <sys_chdir+0x7a>
    iunlockput(ip);
    80005dc8:	8526                	mv	a0,s1
    80005dca:	ffffe097          	auipc	ra,0xffffe
    80005dce:	fc4080e7          	jalr	-60(ra) # 80003d8e <iunlockput>
    end_op();
    80005dd2:	ffffe097          	auipc	ra,0xffffe
    80005dd6:	79c080e7          	jalr	1948(ra) # 8000456e <end_op>
    return -1;
    80005dda:	557d                	li	a0,-1
    80005ddc:	bfd1                	j	80005db0 <sys_chdir+0x7a>

0000000080005dde <sys_exec>:

uint64
sys_exec(void)
{
    80005dde:	7145                	addi	sp,sp,-464
    80005de0:	e786                	sd	ra,456(sp)
    80005de2:	e3a2                	sd	s0,448(sp)
    80005de4:	ff26                	sd	s1,440(sp)
    80005de6:	fb4a                	sd	s2,432(sp)
    80005de8:	f74e                	sd	s3,424(sp)
    80005dea:	f352                	sd	s4,416(sp)
    80005dec:	ef56                	sd	s5,408(sp)
    80005dee:	0b80                	addi	s0,sp,464
  char path[MAXPATH], *argv[MAXARG];
  int i;
  uint64 uargv, uarg;

  argaddr(1, &uargv);
    80005df0:	e3840593          	addi	a1,s0,-456
    80005df4:	4505                	li	a0,1
    80005df6:	ffffd097          	auipc	ra,0xffffd
    80005dfa:	116080e7          	jalr	278(ra) # 80002f0c <argaddr>
  if(argstr(0, path, MAXPATH) < 0) {
    80005dfe:	08000613          	li	a2,128
    80005e02:	f4040593          	addi	a1,s0,-192
    80005e06:	4501                	li	a0,0
    80005e08:	ffffd097          	auipc	ra,0xffffd
    80005e0c:	124080e7          	jalr	292(ra) # 80002f2c <argstr>
    80005e10:	87aa                	mv	a5,a0
    return -1;
    80005e12:	557d                	li	a0,-1
  if(argstr(0, path, MAXPATH) < 0) {
    80005e14:	0c07c263          	bltz	a5,80005ed8 <sys_exec+0xfa>
  }
  memset(argv, 0, sizeof(argv));
    80005e18:	10000613          	li	a2,256
    80005e1c:	4581                	li	a1,0
    80005e1e:	e4040513          	addi	a0,s0,-448
    80005e22:	ffffb097          	auipc	ra,0xffffb
    80005e26:	f70080e7          	jalr	-144(ra) # 80000d92 <memset>
  for(i=0;; i++){
    if(i >= NELEM(argv)){
    80005e2a:	e4040493          	addi	s1,s0,-448
  memset(argv, 0, sizeof(argv));
    80005e2e:	89a6                	mv	s3,s1
    80005e30:	4901                	li	s2,0
    if(i >= NELEM(argv)){
    80005e32:	02000a13          	li	s4,32
    80005e36:	00090a9b          	sext.w	s5,s2
      goto bad;
    }
    if(fetchaddr(uargv+sizeof(uint64)*i, (uint64*)&uarg) < 0){
    80005e3a:	00391513          	slli	a0,s2,0x3
    80005e3e:	e3040593          	addi	a1,s0,-464
    80005e42:	e3843783          	ld	a5,-456(s0)
    80005e46:	953e                	add	a0,a0,a5
    80005e48:	ffffd097          	auipc	ra,0xffffd
    80005e4c:	006080e7          	jalr	6(ra) # 80002e4e <fetchaddr>
    80005e50:	02054a63          	bltz	a0,80005e84 <sys_exec+0xa6>
      goto bad;
    }
    if(uarg == 0){
    80005e54:	e3043783          	ld	a5,-464(s0)
    80005e58:	c3b9                	beqz	a5,80005e9e <sys_exec+0xc0>
      argv[i] = 0;
      break;
    }
    argv[i] = kalloc();
    80005e5a:	ffffb097          	auipc	ra,0xffffb
    80005e5e:	d00080e7          	jalr	-768(ra) # 80000b5a <kalloc>
    80005e62:	85aa                	mv	a1,a0
    80005e64:	00a9b023          	sd	a0,0(s3)
    if(argv[i] == 0)
    80005e68:	cd11                	beqz	a0,80005e84 <sys_exec+0xa6>
      goto bad;
    if(fetchstr(uarg, argv[i], PGSIZE) < 0)
    80005e6a:	6605                	lui	a2,0x1
    80005e6c:	e3043503          	ld	a0,-464(s0)
    80005e70:	ffffd097          	auipc	ra,0xffffd
    80005e74:	030080e7          	jalr	48(ra) # 80002ea0 <fetchstr>
    80005e78:	00054663          	bltz	a0,80005e84 <sys_exec+0xa6>
    if(i >= NELEM(argv)){
    80005e7c:	0905                	addi	s2,s2,1
    80005e7e:	09a1                	addi	s3,s3,8
    80005e80:	fb491be3          	bne	s2,s4,80005e36 <sys_exec+0x58>
    kfree(argv[i]);

  return ret;

 bad:
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005e84:	10048913          	addi	s2,s1,256
    80005e88:	6088                	ld	a0,0(s1)
    80005e8a:	c531                	beqz	a0,80005ed6 <sys_exec+0xf8>
    kfree(argv[i]);
    80005e8c:	ffffb097          	auipc	ra,0xffffb
    80005e90:	b68080e7          	jalr	-1176(ra) # 800009f4 <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005e94:	04a1                	addi	s1,s1,8
    80005e96:	ff2499e3          	bne	s1,s2,80005e88 <sys_exec+0xaa>
  return -1;
    80005e9a:	557d                	li	a0,-1
    80005e9c:	a835                	j	80005ed8 <sys_exec+0xfa>
      argv[i] = 0;
    80005e9e:	0a8e                	slli	s5,s5,0x3
    80005ea0:	fc040793          	addi	a5,s0,-64
    80005ea4:	9abe                	add	s5,s5,a5
    80005ea6:	e80ab023          	sd	zero,-384(s5)
  int ret = exec(path, argv);
    80005eaa:	e4040593          	addi	a1,s0,-448
    80005eae:	f4040513          	addi	a0,s0,-192
    80005eb2:	fffff097          	auipc	ra,0xfffff
    80005eb6:	190080e7          	jalr	400(ra) # 80005042 <exec>
    80005eba:	892a                	mv	s2,a0
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005ebc:	10048993          	addi	s3,s1,256
    80005ec0:	6088                	ld	a0,0(s1)
    80005ec2:	c901                	beqz	a0,80005ed2 <sys_exec+0xf4>
    kfree(argv[i]);
    80005ec4:	ffffb097          	auipc	ra,0xffffb
    80005ec8:	b30080e7          	jalr	-1232(ra) # 800009f4 <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005ecc:	04a1                	addi	s1,s1,8
    80005ece:	ff3499e3          	bne	s1,s3,80005ec0 <sys_exec+0xe2>
  return ret;
    80005ed2:	854a                	mv	a0,s2
    80005ed4:	a011                	j	80005ed8 <sys_exec+0xfa>
  return -1;
    80005ed6:	557d                	li	a0,-1
}
    80005ed8:	60be                	ld	ra,456(sp)
    80005eda:	641e                	ld	s0,448(sp)
    80005edc:	74fa                	ld	s1,440(sp)
    80005ede:	795a                	ld	s2,432(sp)
    80005ee0:	79ba                	ld	s3,424(sp)
    80005ee2:	7a1a                	ld	s4,416(sp)
    80005ee4:	6afa                	ld	s5,408(sp)
    80005ee6:	6179                	addi	sp,sp,464
    80005ee8:	8082                	ret

0000000080005eea <sys_pipe>:

uint64
sys_pipe(void)
{
    80005eea:	7139                	addi	sp,sp,-64
    80005eec:	fc06                	sd	ra,56(sp)
    80005eee:	f822                	sd	s0,48(sp)
    80005ef0:	f426                	sd	s1,40(sp)
    80005ef2:	0080                	addi	s0,sp,64
  uint64 fdarray; // user pointer to array of two integers
  struct file *rf, *wf;
  int fd0, fd1;
  struct proc *p = myproc();
    80005ef4:	ffffc097          	auipc	ra,0xffffc
    80005ef8:	c7c080e7          	jalr	-900(ra) # 80001b70 <myproc>
    80005efc:	84aa                	mv	s1,a0

  argaddr(0, &fdarray);
    80005efe:	fd840593          	addi	a1,s0,-40
    80005f02:	4501                	li	a0,0
    80005f04:	ffffd097          	auipc	ra,0xffffd
    80005f08:	008080e7          	jalr	8(ra) # 80002f0c <argaddr>
  if(pipealloc(&rf, &wf) < 0)
    80005f0c:	fc840593          	addi	a1,s0,-56
    80005f10:	fd040513          	addi	a0,s0,-48
    80005f14:	fffff097          	auipc	ra,0xfffff
    80005f18:	dd6080e7          	jalr	-554(ra) # 80004cea <pipealloc>
    return -1;
    80005f1c:	57fd                	li	a5,-1
  if(pipealloc(&rf, &wf) < 0)
    80005f1e:	0c054463          	bltz	a0,80005fe6 <sys_pipe+0xfc>
  fd0 = -1;
    80005f22:	fcf42223          	sw	a5,-60(s0)
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
    80005f26:	fd043503          	ld	a0,-48(s0)
    80005f2a:	fffff097          	auipc	ra,0xfffff
    80005f2e:	518080e7          	jalr	1304(ra) # 80005442 <fdalloc>
    80005f32:	fca42223          	sw	a0,-60(s0)
    80005f36:	08054b63          	bltz	a0,80005fcc <sys_pipe+0xe2>
    80005f3a:	fc843503          	ld	a0,-56(s0)
    80005f3e:	fffff097          	auipc	ra,0xfffff
    80005f42:	504080e7          	jalr	1284(ra) # 80005442 <fdalloc>
    80005f46:	fca42023          	sw	a0,-64(s0)
    80005f4a:	06054863          	bltz	a0,80005fba <sys_pipe+0xd0>
      p->ofile[fd0] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    80005f4e:	4691                	li	a3,4
    80005f50:	fc440613          	addi	a2,s0,-60
    80005f54:	fd843583          	ld	a1,-40(s0)
    80005f58:	68a8                	ld	a0,80(s1)
    80005f5a:	ffffb097          	auipc	ra,0xffffb
    80005f5e:	7d6080e7          	jalr	2006(ra) # 80001730 <copyout>
    80005f62:	02054063          	bltz	a0,80005f82 <sys_pipe+0x98>
     copyout(p->pagetable, fdarray+sizeof(fd0), (char *)&fd1, sizeof(fd1)) < 0){
    80005f66:	4691                	li	a3,4
    80005f68:	fc040613          	addi	a2,s0,-64
    80005f6c:	fd843583          	ld	a1,-40(s0)
    80005f70:	0591                	addi	a1,a1,4
    80005f72:	68a8                	ld	a0,80(s1)
    80005f74:	ffffb097          	auipc	ra,0xffffb
    80005f78:	7bc080e7          	jalr	1980(ra) # 80001730 <copyout>
    p->ofile[fd1] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  return 0;
    80005f7c:	4781                	li	a5,0
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    80005f7e:	06055463          	bgez	a0,80005fe6 <sys_pipe+0xfc>
    p->ofile[fd0] = 0;
    80005f82:	fc442783          	lw	a5,-60(s0)
    80005f86:	07e9                	addi	a5,a5,26
    80005f88:	078e                	slli	a5,a5,0x3
    80005f8a:	97a6                	add	a5,a5,s1
    80005f8c:	0007b023          	sd	zero,0(a5)
    p->ofile[fd1] = 0;
    80005f90:	fc042503          	lw	a0,-64(s0)
    80005f94:	0569                	addi	a0,a0,26
    80005f96:	050e                	slli	a0,a0,0x3
    80005f98:	94aa                	add	s1,s1,a0
    80005f9a:	0004b023          	sd	zero,0(s1)
    fileclose(rf);
    80005f9e:	fd043503          	ld	a0,-48(s0)
    80005fa2:	fffff097          	auipc	ra,0xfffff
    80005fa6:	a18080e7          	jalr	-1512(ra) # 800049ba <fileclose>
    fileclose(wf);
    80005faa:	fc843503          	ld	a0,-56(s0)
    80005fae:	fffff097          	auipc	ra,0xfffff
    80005fb2:	a0c080e7          	jalr	-1524(ra) # 800049ba <fileclose>
    return -1;
    80005fb6:	57fd                	li	a5,-1
    80005fb8:	a03d                	j	80005fe6 <sys_pipe+0xfc>
    if(fd0 >= 0)
    80005fba:	fc442783          	lw	a5,-60(s0)
    80005fbe:	0007c763          	bltz	a5,80005fcc <sys_pipe+0xe2>
      p->ofile[fd0] = 0;
    80005fc2:	07e9                	addi	a5,a5,26
    80005fc4:	078e                	slli	a5,a5,0x3
    80005fc6:	94be                	add	s1,s1,a5
    80005fc8:	0004b023          	sd	zero,0(s1)
    fileclose(rf);
    80005fcc:	fd043503          	ld	a0,-48(s0)
    80005fd0:	fffff097          	auipc	ra,0xfffff
    80005fd4:	9ea080e7          	jalr	-1558(ra) # 800049ba <fileclose>
    fileclose(wf);
    80005fd8:	fc843503          	ld	a0,-56(s0)
    80005fdc:	fffff097          	auipc	ra,0xfffff
    80005fe0:	9de080e7          	jalr	-1570(ra) # 800049ba <fileclose>
    return -1;
    80005fe4:	57fd                	li	a5,-1
}
    80005fe6:	853e                	mv	a0,a5
    80005fe8:	70e2                	ld	ra,56(sp)
    80005fea:	7442                	ld	s0,48(sp)
    80005fec:	74a2                	ld	s1,40(sp)
    80005fee:	6121                	addi	sp,sp,64
    80005ff0:	8082                	ret
	...

0000000080006000 <kernelvec>:
    80006000:	7111                	addi	sp,sp,-256
    80006002:	e006                	sd	ra,0(sp)
    80006004:	e40a                	sd	sp,8(sp)
    80006006:	e80e                	sd	gp,16(sp)
    80006008:	ec12                	sd	tp,24(sp)
    8000600a:	f016                	sd	t0,32(sp)
    8000600c:	f41a                	sd	t1,40(sp)
    8000600e:	f81e                	sd	t2,48(sp)
    80006010:	fc22                	sd	s0,56(sp)
    80006012:	e0a6                	sd	s1,64(sp)
    80006014:	e4aa                	sd	a0,72(sp)
    80006016:	e8ae                	sd	a1,80(sp)
    80006018:	ecb2                	sd	a2,88(sp)
    8000601a:	f0b6                	sd	a3,96(sp)
    8000601c:	f4ba                	sd	a4,104(sp)
    8000601e:	f8be                	sd	a5,112(sp)
    80006020:	fcc2                	sd	a6,120(sp)
    80006022:	e146                	sd	a7,128(sp)
    80006024:	e54a                	sd	s2,136(sp)
    80006026:	e94e                	sd	s3,144(sp)
    80006028:	ed52                	sd	s4,152(sp)
    8000602a:	f156                	sd	s5,160(sp)
    8000602c:	f55a                	sd	s6,168(sp)
    8000602e:	f95e                	sd	s7,176(sp)
    80006030:	fd62                	sd	s8,184(sp)
    80006032:	e1e6                	sd	s9,192(sp)
    80006034:	e5ea                	sd	s10,200(sp)
    80006036:	e9ee                	sd	s11,208(sp)
    80006038:	edf2                	sd	t3,216(sp)
    8000603a:	f1f6                	sd	t4,224(sp)
    8000603c:	f5fa                	sd	t5,232(sp)
    8000603e:	f9fe                	sd	t6,240(sp)
    80006040:	cdbfc0ef          	jal	ra,80002d1a <kerneltrap>
    80006044:	6082                	ld	ra,0(sp)
    80006046:	6122                	ld	sp,8(sp)
    80006048:	61c2                	ld	gp,16(sp)
    8000604a:	7282                	ld	t0,32(sp)
    8000604c:	7322                	ld	t1,40(sp)
    8000604e:	73c2                	ld	t2,48(sp)
    80006050:	7462                	ld	s0,56(sp)
    80006052:	6486                	ld	s1,64(sp)
    80006054:	6526                	ld	a0,72(sp)
    80006056:	65c6                	ld	a1,80(sp)
    80006058:	6666                	ld	a2,88(sp)
    8000605a:	7686                	ld	a3,96(sp)
    8000605c:	7726                	ld	a4,104(sp)
    8000605e:	77c6                	ld	a5,112(sp)
    80006060:	7866                	ld	a6,120(sp)
    80006062:	688a                	ld	a7,128(sp)
    80006064:	692a                	ld	s2,136(sp)
    80006066:	69ca                	ld	s3,144(sp)
    80006068:	6a6a                	ld	s4,152(sp)
    8000606a:	7a8a                	ld	s5,160(sp)
    8000606c:	7b2a                	ld	s6,168(sp)
    8000606e:	7bca                	ld	s7,176(sp)
    80006070:	7c6a                	ld	s8,184(sp)
    80006072:	6c8e                	ld	s9,192(sp)
    80006074:	6d2e                	ld	s10,200(sp)
    80006076:	6dce                	ld	s11,208(sp)
    80006078:	6e6e                	ld	t3,216(sp)
    8000607a:	7e8e                	ld	t4,224(sp)
    8000607c:	7f2e                	ld	t5,232(sp)
    8000607e:	7fce                	ld	t6,240(sp)
    80006080:	6111                	addi	sp,sp,256
    80006082:	10200073          	sret
    80006086:	00000013          	nop
    8000608a:	00000013          	nop
    8000608e:	0001                	nop

0000000080006090 <timervec>:
    80006090:	34051573          	csrrw	a0,mscratch,a0
    80006094:	e10c                	sd	a1,0(a0)
    80006096:	e510                	sd	a2,8(a0)
    80006098:	e914                	sd	a3,16(a0)
    8000609a:	6d0c                	ld	a1,24(a0)
    8000609c:	7110                	ld	a2,32(a0)
    8000609e:	6194                	ld	a3,0(a1)
    800060a0:	96b2                	add	a3,a3,a2
    800060a2:	e194                	sd	a3,0(a1)
    800060a4:	4589                	li	a1,2
    800060a6:	14459073          	csrw	sip,a1
    800060aa:	6914                	ld	a3,16(a0)
    800060ac:	6510                	ld	a2,8(a0)
    800060ae:	610c                	ld	a1,0(a0)
    800060b0:	34051573          	csrrw	a0,mscratch,a0
    800060b4:	30200073          	mret
	...

00000000800060ba <plicinit>:
// the riscv Platform Level Interrupt Controller (PLIC).
//

void
plicinit(void)
{
    800060ba:	1141                	addi	sp,sp,-16
    800060bc:	e422                	sd	s0,8(sp)
    800060be:	0800                	addi	s0,sp,16
  // set desired IRQ priorities non-zero (otherwise disabled).
  *(uint32*)(PLIC + UART0_IRQ*4) = 1;
    800060c0:	0c0007b7          	lui	a5,0xc000
    800060c4:	4705                	li	a4,1
    800060c6:	d798                	sw	a4,40(a5)
  *(uint32*)(PLIC + VIRTIO0_IRQ*4) = 1;
    800060c8:	c3d8                	sw	a4,4(a5)
}
    800060ca:	6422                	ld	s0,8(sp)
    800060cc:	0141                	addi	sp,sp,16
    800060ce:	8082                	ret

00000000800060d0 <plicinithart>:

void
plicinithart(void)
{
    800060d0:	1141                	addi	sp,sp,-16
    800060d2:	e406                	sd	ra,8(sp)
    800060d4:	e022                	sd	s0,0(sp)
    800060d6:	0800                	addi	s0,sp,16
  int hart = cpuid();
    800060d8:	ffffc097          	auipc	ra,0xffffc
    800060dc:	a6c080e7          	jalr	-1428(ra) # 80001b44 <cpuid>
  
  // set enable bits for this hart's S-mode
  // for the uart and virtio disk.
  *(uint32*)PLIC_SENABLE(hart) = (1 << UART0_IRQ) | (1 << VIRTIO0_IRQ);
    800060e0:	0085171b          	slliw	a4,a0,0x8
    800060e4:	0c0027b7          	lui	a5,0xc002
    800060e8:	97ba                	add	a5,a5,a4
    800060ea:	40200713          	li	a4,1026
    800060ee:	08e7a023          	sw	a4,128(a5) # c002080 <_entry-0x73ffdf80>

  // set this hart's S-mode priority threshold to 0.
  *(uint32*)PLIC_SPRIORITY(hart) = 0;
    800060f2:	00d5151b          	slliw	a0,a0,0xd
    800060f6:	0c2017b7          	lui	a5,0xc201
    800060fa:	953e                	add	a0,a0,a5
    800060fc:	00052023          	sw	zero,0(a0)
}
    80006100:	60a2                	ld	ra,8(sp)
    80006102:	6402                	ld	s0,0(sp)
    80006104:	0141                	addi	sp,sp,16
    80006106:	8082                	ret

0000000080006108 <plic_claim>:

// ask the PLIC what interrupt we should serve.
int
plic_claim(void)
{
    80006108:	1141                	addi	sp,sp,-16
    8000610a:	e406                	sd	ra,8(sp)
    8000610c:	e022                	sd	s0,0(sp)
    8000610e:	0800                	addi	s0,sp,16
  int hart = cpuid();
    80006110:	ffffc097          	auipc	ra,0xffffc
    80006114:	a34080e7          	jalr	-1484(ra) # 80001b44 <cpuid>
  int irq = *(uint32*)PLIC_SCLAIM(hart);
    80006118:	00d5179b          	slliw	a5,a0,0xd
    8000611c:	0c201537          	lui	a0,0xc201
    80006120:	953e                	add	a0,a0,a5
  return irq;
}
    80006122:	4148                	lw	a0,4(a0)
    80006124:	60a2                	ld	ra,8(sp)
    80006126:	6402                	ld	s0,0(sp)
    80006128:	0141                	addi	sp,sp,16
    8000612a:	8082                	ret

000000008000612c <plic_complete>:

// tell the PLIC we've served this IRQ.
void
plic_complete(int irq)
{
    8000612c:	1101                	addi	sp,sp,-32
    8000612e:	ec06                	sd	ra,24(sp)
    80006130:	e822                	sd	s0,16(sp)
    80006132:	e426                	sd	s1,8(sp)
    80006134:	1000                	addi	s0,sp,32
    80006136:	84aa                	mv	s1,a0
  int hart = cpuid();
    80006138:	ffffc097          	auipc	ra,0xffffc
    8000613c:	a0c080e7          	jalr	-1524(ra) # 80001b44 <cpuid>
  *(uint32*)PLIC_SCLAIM(hart) = irq;
    80006140:	00d5151b          	slliw	a0,a0,0xd
    80006144:	0c2017b7          	lui	a5,0xc201
    80006148:	97aa                	add	a5,a5,a0
    8000614a:	c3c4                	sw	s1,4(a5)
}
    8000614c:	60e2                	ld	ra,24(sp)
    8000614e:	6442                	ld	s0,16(sp)
    80006150:	64a2                	ld	s1,8(sp)
    80006152:	6105                	addi	sp,sp,32
    80006154:	8082                	ret

0000000080006156 <free_desc>:
}

// mark a descriptor as free.
static void
free_desc(int i)
{
    80006156:	1141                	addi	sp,sp,-16
    80006158:	e406                	sd	ra,8(sp)
    8000615a:	e022                	sd	s0,0(sp)
    8000615c:	0800                	addi	s0,sp,16
  if(i >= NUM)
    8000615e:	479d                	li	a5,7
    80006160:	04a7cc63          	blt	a5,a0,800061b8 <free_desc+0x62>
    panic("free_desc 1");
  if(disk.free[i])
    80006164:	0001c797          	auipc	a5,0x1c
    80006168:	c4c78793          	addi	a5,a5,-948 # 80021db0 <disk>
    8000616c:	97aa                	add	a5,a5,a0
    8000616e:	0187c783          	lbu	a5,24(a5)
    80006172:	ebb9                	bnez	a5,800061c8 <free_desc+0x72>
    panic("free_desc 2");
  disk.desc[i].addr = 0;
    80006174:	00451613          	slli	a2,a0,0x4
    80006178:	0001c797          	auipc	a5,0x1c
    8000617c:	c3878793          	addi	a5,a5,-968 # 80021db0 <disk>
    80006180:	6394                	ld	a3,0(a5)
    80006182:	96b2                	add	a3,a3,a2
    80006184:	0006b023          	sd	zero,0(a3)
  disk.desc[i].len = 0;
    80006188:	6398                	ld	a4,0(a5)
    8000618a:	9732                	add	a4,a4,a2
    8000618c:	00072423          	sw	zero,8(a4)
  disk.desc[i].flags = 0;
    80006190:	00071623          	sh	zero,12(a4)
  disk.desc[i].next = 0;
    80006194:	00071723          	sh	zero,14(a4)
  disk.free[i] = 1;
    80006198:	953e                	add	a0,a0,a5
    8000619a:	4785                	li	a5,1
    8000619c:	00f50c23          	sb	a5,24(a0) # c201018 <_entry-0x73dfefe8>
  wakeup(&disk.free[0]);
    800061a0:	0001c517          	auipc	a0,0x1c
    800061a4:	c2850513          	addi	a0,a0,-984 # 80021dc8 <disk+0x18>
    800061a8:	ffffc097          	auipc	ra,0xffffc
    800061ac:	190080e7          	jalr	400(ra) # 80002338 <wakeup>
}
    800061b0:	60a2                	ld	ra,8(sp)
    800061b2:	6402                	ld	s0,0(sp)
    800061b4:	0141                	addi	sp,sp,16
    800061b6:	8082                	ret
    panic("free_desc 1");
    800061b8:	00002517          	auipc	a0,0x2
    800061bc:	6d050513          	addi	a0,a0,1744 # 80008888 <syscalls+0x318>
    800061c0:	ffffa097          	auipc	ra,0xffffa
    800061c4:	368080e7          	jalr	872(ra) # 80000528 <panic>
    panic("free_desc 2");
    800061c8:	00002517          	auipc	a0,0x2
    800061cc:	6d050513          	addi	a0,a0,1744 # 80008898 <syscalls+0x328>
    800061d0:	ffffa097          	auipc	ra,0xffffa
    800061d4:	358080e7          	jalr	856(ra) # 80000528 <panic>

00000000800061d8 <virtio_disk_init>:
{
    800061d8:	1101                	addi	sp,sp,-32
    800061da:	ec06                	sd	ra,24(sp)
    800061dc:	e822                	sd	s0,16(sp)
    800061de:	e426                	sd	s1,8(sp)
    800061e0:	e04a                	sd	s2,0(sp)
    800061e2:	1000                	addi	s0,sp,32
  initlock(&disk.vdisk_lock, "virtio_disk");
    800061e4:	00002597          	auipc	a1,0x2
    800061e8:	6c458593          	addi	a1,a1,1732 # 800088a8 <syscalls+0x338>
    800061ec:	0001c517          	auipc	a0,0x1c
    800061f0:	cec50513          	addi	a0,a0,-788 # 80021ed8 <disk+0x128>
    800061f4:	ffffb097          	auipc	ra,0xffffb
    800061f8:	a12080e7          	jalr	-1518(ra) # 80000c06 <initlock>
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    800061fc:	100017b7          	lui	a5,0x10001
    80006200:	4398                	lw	a4,0(a5)
    80006202:	2701                	sext.w	a4,a4
    80006204:	747277b7          	lui	a5,0x74727
    80006208:	97678793          	addi	a5,a5,-1674 # 74726976 <_entry-0xb8d968a>
    8000620c:	14f71e63          	bne	a4,a5,80006368 <virtio_disk_init+0x190>
     *R(VIRTIO_MMIO_VERSION) != 2 ||
    80006210:	100017b7          	lui	a5,0x10001
    80006214:	43dc                	lw	a5,4(a5)
    80006216:	2781                	sext.w	a5,a5
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    80006218:	4709                	li	a4,2
    8000621a:	14e79763          	bne	a5,a4,80006368 <virtio_disk_init+0x190>
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    8000621e:	100017b7          	lui	a5,0x10001
    80006222:	479c                	lw	a5,8(a5)
    80006224:	2781                	sext.w	a5,a5
     *R(VIRTIO_MMIO_VERSION) != 2 ||
    80006226:	14e79163          	bne	a5,a4,80006368 <virtio_disk_init+0x190>
     *R(VIRTIO_MMIO_VENDOR_ID) != 0x554d4551){
    8000622a:	100017b7          	lui	a5,0x10001
    8000622e:	47d8                	lw	a4,12(a5)
    80006230:	2701                	sext.w	a4,a4
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    80006232:	554d47b7          	lui	a5,0x554d4
    80006236:	55178793          	addi	a5,a5,1361 # 554d4551 <_entry-0x2ab2baaf>
    8000623a:	12f71763          	bne	a4,a5,80006368 <virtio_disk_init+0x190>
  *R(VIRTIO_MMIO_STATUS) = status;
    8000623e:	100017b7          	lui	a5,0x10001
    80006242:	0607a823          	sw	zero,112(a5) # 10001070 <_entry-0x6fffef90>
  *R(VIRTIO_MMIO_STATUS) = status;
    80006246:	4705                	li	a4,1
    80006248:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    8000624a:	470d                	li	a4,3
    8000624c:	dbb8                	sw	a4,112(a5)
  uint64 features = *R(VIRTIO_MMIO_DEVICE_FEATURES);
    8000624e:	4b94                	lw	a3,16(a5)
  features &= ~(1 << VIRTIO_RING_F_INDIRECT_DESC);
    80006250:	c7ffe737          	lui	a4,0xc7ffe
    80006254:	75f70713          	addi	a4,a4,1887 # ffffffffc7ffe75f <end+0xffffffff47fdc86f>
    80006258:	8f75                	and	a4,a4,a3
  *R(VIRTIO_MMIO_DRIVER_FEATURES) = features;
    8000625a:	2701                	sext.w	a4,a4
    8000625c:	d398                	sw	a4,32(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    8000625e:	472d                	li	a4,11
    80006260:	dbb8                	sw	a4,112(a5)
  status = *R(VIRTIO_MMIO_STATUS);
    80006262:	0707a903          	lw	s2,112(a5)
    80006266:	2901                	sext.w	s2,s2
  if(!(status & VIRTIO_CONFIG_S_FEATURES_OK))
    80006268:	00897793          	andi	a5,s2,8
    8000626c:	10078663          	beqz	a5,80006378 <virtio_disk_init+0x1a0>
  *R(VIRTIO_MMIO_QUEUE_SEL) = 0;
    80006270:	100017b7          	lui	a5,0x10001
    80006274:	0207a823          	sw	zero,48(a5) # 10001030 <_entry-0x6fffefd0>
  if(*R(VIRTIO_MMIO_QUEUE_READY))
    80006278:	43fc                	lw	a5,68(a5)
    8000627a:	2781                	sext.w	a5,a5
    8000627c:	10079663          	bnez	a5,80006388 <virtio_disk_init+0x1b0>
  uint32 max = *R(VIRTIO_MMIO_QUEUE_NUM_MAX);
    80006280:	100017b7          	lui	a5,0x10001
    80006284:	5bdc                	lw	a5,52(a5)
    80006286:	2781                	sext.w	a5,a5
  if(max == 0)
    80006288:	10078863          	beqz	a5,80006398 <virtio_disk_init+0x1c0>
  if(max < NUM)
    8000628c:	471d                	li	a4,7
    8000628e:	10f77d63          	bgeu	a4,a5,800063a8 <virtio_disk_init+0x1d0>
  disk.desc = kalloc();
    80006292:	ffffb097          	auipc	ra,0xffffb
    80006296:	8c8080e7          	jalr	-1848(ra) # 80000b5a <kalloc>
    8000629a:	0001c497          	auipc	s1,0x1c
    8000629e:	b1648493          	addi	s1,s1,-1258 # 80021db0 <disk>
    800062a2:	e088                	sd	a0,0(s1)
  disk.avail = kalloc();
    800062a4:	ffffb097          	auipc	ra,0xffffb
    800062a8:	8b6080e7          	jalr	-1866(ra) # 80000b5a <kalloc>
    800062ac:	e488                	sd	a0,8(s1)
  disk.used = kalloc();
    800062ae:	ffffb097          	auipc	ra,0xffffb
    800062b2:	8ac080e7          	jalr	-1876(ra) # 80000b5a <kalloc>
    800062b6:	87aa                	mv	a5,a0
    800062b8:	e888                	sd	a0,16(s1)
  if(!disk.desc || !disk.avail || !disk.used)
    800062ba:	6088                	ld	a0,0(s1)
    800062bc:	cd75                	beqz	a0,800063b8 <virtio_disk_init+0x1e0>
    800062be:	0001c717          	auipc	a4,0x1c
    800062c2:	afa73703          	ld	a4,-1286(a4) # 80021db8 <disk+0x8>
    800062c6:	cb6d                	beqz	a4,800063b8 <virtio_disk_init+0x1e0>
    800062c8:	cbe5                	beqz	a5,800063b8 <virtio_disk_init+0x1e0>
  memset(disk.desc, 0, PGSIZE);
    800062ca:	6605                	lui	a2,0x1
    800062cc:	4581                	li	a1,0
    800062ce:	ffffb097          	auipc	ra,0xffffb
    800062d2:	ac4080e7          	jalr	-1340(ra) # 80000d92 <memset>
  memset(disk.avail, 0, PGSIZE);
    800062d6:	0001c497          	auipc	s1,0x1c
    800062da:	ada48493          	addi	s1,s1,-1318 # 80021db0 <disk>
    800062de:	6605                	lui	a2,0x1
    800062e0:	4581                	li	a1,0
    800062e2:	6488                	ld	a0,8(s1)
    800062e4:	ffffb097          	auipc	ra,0xffffb
    800062e8:	aae080e7          	jalr	-1362(ra) # 80000d92 <memset>
  memset(disk.used, 0, PGSIZE);
    800062ec:	6605                	lui	a2,0x1
    800062ee:	4581                	li	a1,0
    800062f0:	6888                	ld	a0,16(s1)
    800062f2:	ffffb097          	auipc	ra,0xffffb
    800062f6:	aa0080e7          	jalr	-1376(ra) # 80000d92 <memset>
  *R(VIRTIO_MMIO_QUEUE_NUM) = NUM;
    800062fa:	100017b7          	lui	a5,0x10001
    800062fe:	4721                	li	a4,8
    80006300:	df98                	sw	a4,56(a5)
  *R(VIRTIO_MMIO_QUEUE_DESC_LOW) = (uint64)disk.desc;
    80006302:	4098                	lw	a4,0(s1)
    80006304:	08e7a023          	sw	a4,128(a5) # 10001080 <_entry-0x6fffef80>
  *R(VIRTIO_MMIO_QUEUE_DESC_HIGH) = (uint64)disk.desc >> 32;
    80006308:	40d8                	lw	a4,4(s1)
    8000630a:	08e7a223          	sw	a4,132(a5)
  *R(VIRTIO_MMIO_DRIVER_DESC_LOW) = (uint64)disk.avail;
    8000630e:	6498                	ld	a4,8(s1)
    80006310:	0007069b          	sext.w	a3,a4
    80006314:	08d7a823          	sw	a3,144(a5)
  *R(VIRTIO_MMIO_DRIVER_DESC_HIGH) = (uint64)disk.avail >> 32;
    80006318:	9701                	srai	a4,a4,0x20
    8000631a:	08e7aa23          	sw	a4,148(a5)
  *R(VIRTIO_MMIO_DEVICE_DESC_LOW) = (uint64)disk.used;
    8000631e:	6898                	ld	a4,16(s1)
    80006320:	0007069b          	sext.w	a3,a4
    80006324:	0ad7a023          	sw	a3,160(a5)
  *R(VIRTIO_MMIO_DEVICE_DESC_HIGH) = (uint64)disk.used >> 32;
    80006328:	9701                	srai	a4,a4,0x20
    8000632a:	0ae7a223          	sw	a4,164(a5)
  *R(VIRTIO_MMIO_QUEUE_READY) = 0x1;
    8000632e:	4685                	li	a3,1
    80006330:	c3f4                	sw	a3,68(a5)
    disk.free[i] = 1;
    80006332:	4705                	li	a4,1
    80006334:	00d48c23          	sb	a3,24(s1)
    80006338:	00e48ca3          	sb	a4,25(s1)
    8000633c:	00e48d23          	sb	a4,26(s1)
    80006340:	00e48da3          	sb	a4,27(s1)
    80006344:	00e48e23          	sb	a4,28(s1)
    80006348:	00e48ea3          	sb	a4,29(s1)
    8000634c:	00e48f23          	sb	a4,30(s1)
    80006350:	00e48fa3          	sb	a4,31(s1)
  status |= VIRTIO_CONFIG_S_DRIVER_OK;
    80006354:	00496913          	ori	s2,s2,4
  *R(VIRTIO_MMIO_STATUS) = status;
    80006358:	0727a823          	sw	s2,112(a5)
}
    8000635c:	60e2                	ld	ra,24(sp)
    8000635e:	6442                	ld	s0,16(sp)
    80006360:	64a2                	ld	s1,8(sp)
    80006362:	6902                	ld	s2,0(sp)
    80006364:	6105                	addi	sp,sp,32
    80006366:	8082                	ret
    panic("could not find virtio disk");
    80006368:	00002517          	auipc	a0,0x2
    8000636c:	55050513          	addi	a0,a0,1360 # 800088b8 <syscalls+0x348>
    80006370:	ffffa097          	auipc	ra,0xffffa
    80006374:	1b8080e7          	jalr	440(ra) # 80000528 <panic>
    panic("virtio disk FEATURES_OK unset");
    80006378:	00002517          	auipc	a0,0x2
    8000637c:	56050513          	addi	a0,a0,1376 # 800088d8 <syscalls+0x368>
    80006380:	ffffa097          	auipc	ra,0xffffa
    80006384:	1a8080e7          	jalr	424(ra) # 80000528 <panic>
    panic("virtio disk should not be ready");
    80006388:	00002517          	auipc	a0,0x2
    8000638c:	57050513          	addi	a0,a0,1392 # 800088f8 <syscalls+0x388>
    80006390:	ffffa097          	auipc	ra,0xffffa
    80006394:	198080e7          	jalr	408(ra) # 80000528 <panic>
    panic("virtio disk has no queue 0");
    80006398:	00002517          	auipc	a0,0x2
    8000639c:	58050513          	addi	a0,a0,1408 # 80008918 <syscalls+0x3a8>
    800063a0:	ffffa097          	auipc	ra,0xffffa
    800063a4:	188080e7          	jalr	392(ra) # 80000528 <panic>
    panic("virtio disk max queue too short");
    800063a8:	00002517          	auipc	a0,0x2
    800063ac:	59050513          	addi	a0,a0,1424 # 80008938 <syscalls+0x3c8>
    800063b0:	ffffa097          	auipc	ra,0xffffa
    800063b4:	178080e7          	jalr	376(ra) # 80000528 <panic>
    panic("virtio disk kalloc");
    800063b8:	00002517          	auipc	a0,0x2
    800063bc:	5a050513          	addi	a0,a0,1440 # 80008958 <syscalls+0x3e8>
    800063c0:	ffffa097          	auipc	ra,0xffffa
    800063c4:	168080e7          	jalr	360(ra) # 80000528 <panic>

00000000800063c8 <virtio_disk_rw>:
  return 0;
}

void
virtio_disk_rw(struct buf *b, int write)
{
    800063c8:	7159                	addi	sp,sp,-112
    800063ca:	f486                	sd	ra,104(sp)
    800063cc:	f0a2                	sd	s0,96(sp)
    800063ce:	eca6                	sd	s1,88(sp)
    800063d0:	e8ca                	sd	s2,80(sp)
    800063d2:	e4ce                	sd	s3,72(sp)
    800063d4:	e0d2                	sd	s4,64(sp)
    800063d6:	fc56                	sd	s5,56(sp)
    800063d8:	f85a                	sd	s6,48(sp)
    800063da:	f45e                	sd	s7,40(sp)
    800063dc:	f062                	sd	s8,32(sp)
    800063de:	ec66                	sd	s9,24(sp)
    800063e0:	e86a                	sd	s10,16(sp)
    800063e2:	1880                	addi	s0,sp,112
    800063e4:	892a                	mv	s2,a0
    800063e6:	8d2e                	mv	s10,a1
  uint64 sector = b->blockno * (BSIZE / 512);
    800063e8:	00c52c83          	lw	s9,12(a0)
    800063ec:	001c9c9b          	slliw	s9,s9,0x1
    800063f0:	1c82                	slli	s9,s9,0x20
    800063f2:	020cdc93          	srli	s9,s9,0x20

  acquire(&disk.vdisk_lock);
    800063f6:	0001c517          	auipc	a0,0x1c
    800063fa:	ae250513          	addi	a0,a0,-1310 # 80021ed8 <disk+0x128>
    800063fe:	ffffb097          	auipc	ra,0xffffb
    80006402:	898080e7          	jalr	-1896(ra) # 80000c96 <acquire>
  for(int i = 0; i < 3; i++){
    80006406:	4981                	li	s3,0
  for(int i = 0; i < NUM; i++){
    80006408:	4ba1                	li	s7,8
      disk.free[i] = 0;
    8000640a:	0001cb17          	auipc	s6,0x1c
    8000640e:	9a6b0b13          	addi	s6,s6,-1626 # 80021db0 <disk>
  for(int i = 0; i < 3; i++){
    80006412:	4a8d                	li	s5,3
  for(int i = 0; i < NUM; i++){
    80006414:	8a4e                	mv	s4,s3
  int idx[3];
  while(1){
    if(alloc3_desc(idx) == 0) {
      break;
    }
    sleep(&disk.free[0], &disk.vdisk_lock);
    80006416:	0001cc17          	auipc	s8,0x1c
    8000641a:	ac2c0c13          	addi	s8,s8,-1342 # 80021ed8 <disk+0x128>
    8000641e:	a8b5                	j	8000649a <virtio_disk_rw+0xd2>
      disk.free[i] = 0;
    80006420:	00fb06b3          	add	a3,s6,a5
    80006424:	00068c23          	sb	zero,24(a3)
    idx[i] = alloc_desc();
    80006428:	c21c                	sw	a5,0(a2)
    if(idx[i] < 0){
    8000642a:	0207c563          	bltz	a5,80006454 <virtio_disk_rw+0x8c>
  for(int i = 0; i < 3; i++){
    8000642e:	2485                	addiw	s1,s1,1
    80006430:	0711                	addi	a4,a4,4
    80006432:	1f548a63          	beq	s1,s5,80006626 <virtio_disk_rw+0x25e>
    idx[i] = alloc_desc();
    80006436:	863a                	mv	a2,a4
  for(int i = 0; i < NUM; i++){
    80006438:	0001c697          	auipc	a3,0x1c
    8000643c:	97868693          	addi	a3,a3,-1672 # 80021db0 <disk>
    80006440:	87d2                	mv	a5,s4
    if(disk.free[i]){
    80006442:	0186c583          	lbu	a1,24(a3)
    80006446:	fde9                	bnez	a1,80006420 <virtio_disk_rw+0x58>
  for(int i = 0; i < NUM; i++){
    80006448:	2785                	addiw	a5,a5,1
    8000644a:	0685                	addi	a3,a3,1
    8000644c:	ff779be3          	bne	a5,s7,80006442 <virtio_disk_rw+0x7a>
    idx[i] = alloc_desc();
    80006450:	57fd                	li	a5,-1
    80006452:	c21c                	sw	a5,0(a2)
      for(int j = 0; j < i; j++)
    80006454:	02905a63          	blez	s1,80006488 <virtio_disk_rw+0xc0>
        free_desc(idx[j]);
    80006458:	f9042503          	lw	a0,-112(s0)
    8000645c:	00000097          	auipc	ra,0x0
    80006460:	cfa080e7          	jalr	-774(ra) # 80006156 <free_desc>
      for(int j = 0; j < i; j++)
    80006464:	4785                	li	a5,1
    80006466:	0297d163          	bge	a5,s1,80006488 <virtio_disk_rw+0xc0>
        free_desc(idx[j]);
    8000646a:	f9442503          	lw	a0,-108(s0)
    8000646e:	00000097          	auipc	ra,0x0
    80006472:	ce8080e7          	jalr	-792(ra) # 80006156 <free_desc>
      for(int j = 0; j < i; j++)
    80006476:	4789                	li	a5,2
    80006478:	0097d863          	bge	a5,s1,80006488 <virtio_disk_rw+0xc0>
        free_desc(idx[j]);
    8000647c:	f9842503          	lw	a0,-104(s0)
    80006480:	00000097          	auipc	ra,0x0
    80006484:	cd6080e7          	jalr	-810(ra) # 80006156 <free_desc>
    sleep(&disk.free[0], &disk.vdisk_lock);
    80006488:	85e2                	mv	a1,s8
    8000648a:	0001c517          	auipc	a0,0x1c
    8000648e:	93e50513          	addi	a0,a0,-1730 # 80021dc8 <disk+0x18>
    80006492:	ffffc097          	auipc	ra,0xffffc
    80006496:	e42080e7          	jalr	-446(ra) # 800022d4 <sleep>
  for(int i = 0; i < 3; i++){
    8000649a:	f9040713          	addi	a4,s0,-112
    8000649e:	84ce                	mv	s1,s3
    800064a0:	bf59                	j	80006436 <virtio_disk_rw+0x6e>
  // qemu's virtio-blk.c reads them.

  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];

  if(write)
    buf0->type = VIRTIO_BLK_T_OUT; // write the disk
    800064a2:	00a60793          	addi	a5,a2,10 # 100a <_entry-0x7fffeff6>
    800064a6:	00479693          	slli	a3,a5,0x4
    800064aa:	0001c797          	auipc	a5,0x1c
    800064ae:	90678793          	addi	a5,a5,-1786 # 80021db0 <disk>
    800064b2:	97b6                	add	a5,a5,a3
    800064b4:	4685                	li	a3,1
    800064b6:	c794                	sw	a3,8(a5)
  else
    buf0->type = VIRTIO_BLK_T_IN; // read the disk
  buf0->reserved = 0;
    800064b8:	0001c597          	auipc	a1,0x1c
    800064bc:	8f858593          	addi	a1,a1,-1800 # 80021db0 <disk>
    800064c0:	00a60793          	addi	a5,a2,10
    800064c4:	0792                	slli	a5,a5,0x4
    800064c6:	97ae                	add	a5,a5,a1
    800064c8:	0007a623          	sw	zero,12(a5)
  buf0->sector = sector;
    800064cc:	0197b823          	sd	s9,16(a5)

  disk.desc[idx[0]].addr = (uint64) buf0;
    800064d0:	f6070693          	addi	a3,a4,-160
    800064d4:	619c                	ld	a5,0(a1)
    800064d6:	97b6                	add	a5,a5,a3
    800064d8:	e388                	sd	a0,0(a5)
  disk.desc[idx[0]].len = sizeof(struct virtio_blk_req);
    800064da:	6188                	ld	a0,0(a1)
    800064dc:	96aa                	add	a3,a3,a0
    800064de:	47c1                	li	a5,16
    800064e0:	c69c                	sw	a5,8(a3)
  disk.desc[idx[0]].flags = VRING_DESC_F_NEXT;
    800064e2:	4785                	li	a5,1
    800064e4:	00f69623          	sh	a5,12(a3)
  disk.desc[idx[0]].next = idx[1];
    800064e8:	f9442783          	lw	a5,-108(s0)
    800064ec:	00f69723          	sh	a5,14(a3)

  disk.desc[idx[1]].addr = (uint64) b->data;
    800064f0:	0792                	slli	a5,a5,0x4
    800064f2:	953e                	add	a0,a0,a5
    800064f4:	05890693          	addi	a3,s2,88
    800064f8:	e114                	sd	a3,0(a0)
  disk.desc[idx[1]].len = BSIZE;
    800064fa:	6188                	ld	a0,0(a1)
    800064fc:	97aa                	add	a5,a5,a0
    800064fe:	40000693          	li	a3,1024
    80006502:	c794                	sw	a3,8(a5)
  if(write)
    80006504:	100d0d63          	beqz	s10,8000661e <virtio_disk_rw+0x256>
    disk.desc[idx[1]].flags = 0; // device reads b->data
    80006508:	00079623          	sh	zero,12(a5)
  else
    disk.desc[idx[1]].flags = VRING_DESC_F_WRITE; // device writes b->data
  disk.desc[idx[1]].flags |= VRING_DESC_F_NEXT;
    8000650c:	00c7d683          	lhu	a3,12(a5)
    80006510:	0016e693          	ori	a3,a3,1
    80006514:	00d79623          	sh	a3,12(a5)
  disk.desc[idx[1]].next = idx[2];
    80006518:	f9842583          	lw	a1,-104(s0)
    8000651c:	00b79723          	sh	a1,14(a5)

  disk.info[idx[0]].status = 0xff; // device writes 0 on success
    80006520:	0001c697          	auipc	a3,0x1c
    80006524:	89068693          	addi	a3,a3,-1904 # 80021db0 <disk>
    80006528:	00260793          	addi	a5,a2,2
    8000652c:	0792                	slli	a5,a5,0x4
    8000652e:	97b6                	add	a5,a5,a3
    80006530:	587d                	li	a6,-1
    80006532:	01078823          	sb	a6,16(a5)
  disk.desc[idx[2]].addr = (uint64) &disk.info[idx[0]].status;
    80006536:	0592                	slli	a1,a1,0x4
    80006538:	952e                	add	a0,a0,a1
    8000653a:	f9070713          	addi	a4,a4,-112
    8000653e:	9736                	add	a4,a4,a3
    80006540:	e118                	sd	a4,0(a0)
  disk.desc[idx[2]].len = 1;
    80006542:	6298                	ld	a4,0(a3)
    80006544:	972e                	add	a4,a4,a1
    80006546:	4585                	li	a1,1
    80006548:	c70c                	sw	a1,8(a4)
  disk.desc[idx[2]].flags = VRING_DESC_F_WRITE; // device writes the status
    8000654a:	4509                	li	a0,2
    8000654c:	00a71623          	sh	a0,12(a4)
  disk.desc[idx[2]].next = 0;
    80006550:	00071723          	sh	zero,14(a4)

  // record struct buf for virtio_disk_intr().
  b->disk = 1;
    80006554:	00b92223          	sw	a1,4(s2)
  disk.info[idx[0]].b = b;
    80006558:	0127b423          	sd	s2,8(a5)

  // tell the device the first index in our chain of descriptors.
  disk.avail->ring[disk.avail->idx % NUM] = idx[0];
    8000655c:	6698                	ld	a4,8(a3)
    8000655e:	00275783          	lhu	a5,2(a4)
    80006562:	8b9d                	andi	a5,a5,7
    80006564:	0786                	slli	a5,a5,0x1
    80006566:	97ba                	add	a5,a5,a4
    80006568:	00c79223          	sh	a2,4(a5)

  __sync_synchronize();
    8000656c:	0ff0000f          	fence

  // tell the device another avail ring entry is available.
  disk.avail->idx += 1; // not % NUM ...
    80006570:	6698                	ld	a4,8(a3)
    80006572:	00275783          	lhu	a5,2(a4)
    80006576:	2785                	addiw	a5,a5,1
    80006578:	00f71123          	sh	a5,2(a4)

  __sync_synchronize();
    8000657c:	0ff0000f          	fence

  *R(VIRTIO_MMIO_QUEUE_NOTIFY) = 0; // value is queue number
    80006580:	100017b7          	lui	a5,0x10001
    80006584:	0407a823          	sw	zero,80(a5) # 10001050 <_entry-0x6fffefb0>

  // Wait for virtio_disk_intr() to say request has finished.
  while(b->disk == 1) {
    80006588:	00492703          	lw	a4,4(s2)
    8000658c:	4785                	li	a5,1
    8000658e:	02f71163          	bne	a4,a5,800065b0 <virtio_disk_rw+0x1e8>
    sleep(b, &disk.vdisk_lock);
    80006592:	0001c997          	auipc	s3,0x1c
    80006596:	94698993          	addi	s3,s3,-1722 # 80021ed8 <disk+0x128>
  while(b->disk == 1) {
    8000659a:	4485                	li	s1,1
    sleep(b, &disk.vdisk_lock);
    8000659c:	85ce                	mv	a1,s3
    8000659e:	854a                	mv	a0,s2
    800065a0:	ffffc097          	auipc	ra,0xffffc
    800065a4:	d34080e7          	jalr	-716(ra) # 800022d4 <sleep>
  while(b->disk == 1) {
    800065a8:	00492783          	lw	a5,4(s2)
    800065ac:	fe9788e3          	beq	a5,s1,8000659c <virtio_disk_rw+0x1d4>
  }

  disk.info[idx[0]].b = 0;
    800065b0:	f9042903          	lw	s2,-112(s0)
    800065b4:	00290793          	addi	a5,s2,2
    800065b8:	00479713          	slli	a4,a5,0x4
    800065bc:	0001b797          	auipc	a5,0x1b
    800065c0:	7f478793          	addi	a5,a5,2036 # 80021db0 <disk>
    800065c4:	97ba                	add	a5,a5,a4
    800065c6:	0007b423          	sd	zero,8(a5)
    int flag = disk.desc[i].flags;
    800065ca:	0001b997          	auipc	s3,0x1b
    800065ce:	7e698993          	addi	s3,s3,2022 # 80021db0 <disk>
    800065d2:	00491713          	slli	a4,s2,0x4
    800065d6:	0009b783          	ld	a5,0(s3)
    800065da:	97ba                	add	a5,a5,a4
    800065dc:	00c7d483          	lhu	s1,12(a5)
    int nxt = disk.desc[i].next;
    800065e0:	854a                	mv	a0,s2
    800065e2:	00e7d903          	lhu	s2,14(a5)
    free_desc(i);
    800065e6:	00000097          	auipc	ra,0x0
    800065ea:	b70080e7          	jalr	-1168(ra) # 80006156 <free_desc>
    if(flag & VRING_DESC_F_NEXT)
    800065ee:	8885                	andi	s1,s1,1
    800065f0:	f0ed                	bnez	s1,800065d2 <virtio_disk_rw+0x20a>
  free_chain(idx[0]);

  release(&disk.vdisk_lock);
    800065f2:	0001c517          	auipc	a0,0x1c
    800065f6:	8e650513          	addi	a0,a0,-1818 # 80021ed8 <disk+0x128>
    800065fa:	ffffa097          	auipc	ra,0xffffa
    800065fe:	750080e7          	jalr	1872(ra) # 80000d4a <release>
}
    80006602:	70a6                	ld	ra,104(sp)
    80006604:	7406                	ld	s0,96(sp)
    80006606:	64e6                	ld	s1,88(sp)
    80006608:	6946                	ld	s2,80(sp)
    8000660a:	69a6                	ld	s3,72(sp)
    8000660c:	6a06                	ld	s4,64(sp)
    8000660e:	7ae2                	ld	s5,56(sp)
    80006610:	7b42                	ld	s6,48(sp)
    80006612:	7ba2                	ld	s7,40(sp)
    80006614:	7c02                	ld	s8,32(sp)
    80006616:	6ce2                	ld	s9,24(sp)
    80006618:	6d42                	ld	s10,16(sp)
    8000661a:	6165                	addi	sp,sp,112
    8000661c:	8082                	ret
    disk.desc[idx[1]].flags = VRING_DESC_F_WRITE; // device writes b->data
    8000661e:	4689                	li	a3,2
    80006620:	00d79623          	sh	a3,12(a5)
    80006624:	b5e5                	j	8000650c <virtio_disk_rw+0x144>
  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    80006626:	f9042603          	lw	a2,-112(s0)
    8000662a:	00a60713          	addi	a4,a2,10
    8000662e:	0712                	slli	a4,a4,0x4
    80006630:	0001b517          	auipc	a0,0x1b
    80006634:	78850513          	addi	a0,a0,1928 # 80021db8 <disk+0x8>
    80006638:	953a                	add	a0,a0,a4
  if(write)
    8000663a:	e60d14e3          	bnez	s10,800064a2 <virtio_disk_rw+0xda>
    buf0->type = VIRTIO_BLK_T_IN; // read the disk
    8000663e:	00a60793          	addi	a5,a2,10
    80006642:	00479693          	slli	a3,a5,0x4
    80006646:	0001b797          	auipc	a5,0x1b
    8000664a:	76a78793          	addi	a5,a5,1898 # 80021db0 <disk>
    8000664e:	97b6                	add	a5,a5,a3
    80006650:	0007a423          	sw	zero,8(a5)
    80006654:	b595                	j	800064b8 <virtio_disk_rw+0xf0>

0000000080006656 <virtio_disk_intr>:

void
virtio_disk_intr()
{
    80006656:	1101                	addi	sp,sp,-32
    80006658:	ec06                	sd	ra,24(sp)
    8000665a:	e822                	sd	s0,16(sp)
    8000665c:	e426                	sd	s1,8(sp)
    8000665e:	1000                	addi	s0,sp,32
  acquire(&disk.vdisk_lock);
    80006660:	0001b497          	auipc	s1,0x1b
    80006664:	75048493          	addi	s1,s1,1872 # 80021db0 <disk>
    80006668:	0001c517          	auipc	a0,0x1c
    8000666c:	87050513          	addi	a0,a0,-1936 # 80021ed8 <disk+0x128>
    80006670:	ffffa097          	auipc	ra,0xffffa
    80006674:	626080e7          	jalr	1574(ra) # 80000c96 <acquire>
  // we've seen this interrupt, which the following line does.
  // this may race with the device writing new entries to
  // the "used" ring, in which case we may process the new
  // completion entries in this interrupt, and have nothing to do
  // in the next interrupt, which is harmless.
  *R(VIRTIO_MMIO_INTERRUPT_ACK) = *R(VIRTIO_MMIO_INTERRUPT_STATUS) & 0x3;
    80006678:	10001737          	lui	a4,0x10001
    8000667c:	533c                	lw	a5,96(a4)
    8000667e:	8b8d                	andi	a5,a5,3
    80006680:	d37c                	sw	a5,100(a4)

  __sync_synchronize();
    80006682:	0ff0000f          	fence

  // the device increments disk.used->idx when it
  // adds an entry to the used ring.

  while(disk.used_idx != disk.used->idx){
    80006686:	689c                	ld	a5,16(s1)
    80006688:	0204d703          	lhu	a4,32(s1)
    8000668c:	0027d783          	lhu	a5,2(a5)
    80006690:	04f70863          	beq	a4,a5,800066e0 <virtio_disk_intr+0x8a>
    __sync_synchronize();
    80006694:	0ff0000f          	fence
    int id = disk.used->ring[disk.used_idx % NUM].id;
    80006698:	6898                	ld	a4,16(s1)
    8000669a:	0204d783          	lhu	a5,32(s1)
    8000669e:	8b9d                	andi	a5,a5,7
    800066a0:	078e                	slli	a5,a5,0x3
    800066a2:	97ba                	add	a5,a5,a4
    800066a4:	43dc                	lw	a5,4(a5)

    if(disk.info[id].status != 0)
    800066a6:	00278713          	addi	a4,a5,2
    800066aa:	0712                	slli	a4,a4,0x4
    800066ac:	9726                	add	a4,a4,s1
    800066ae:	01074703          	lbu	a4,16(a4) # 10001010 <_entry-0x6fffeff0>
    800066b2:	e721                	bnez	a4,800066fa <virtio_disk_intr+0xa4>
      panic("virtio_disk_intr status");

    struct buf *b = disk.info[id].b;
    800066b4:	0789                	addi	a5,a5,2
    800066b6:	0792                	slli	a5,a5,0x4
    800066b8:	97a6                	add	a5,a5,s1
    800066ba:	6788                	ld	a0,8(a5)
    b->disk = 0;   // disk is done with buf
    800066bc:	00052223          	sw	zero,4(a0)
    wakeup(b);
    800066c0:	ffffc097          	auipc	ra,0xffffc
    800066c4:	c78080e7          	jalr	-904(ra) # 80002338 <wakeup>

    disk.used_idx += 1;
    800066c8:	0204d783          	lhu	a5,32(s1)
    800066cc:	2785                	addiw	a5,a5,1
    800066ce:	17c2                	slli	a5,a5,0x30
    800066d0:	93c1                	srli	a5,a5,0x30
    800066d2:	02f49023          	sh	a5,32(s1)
  while(disk.used_idx != disk.used->idx){
    800066d6:	6898                	ld	a4,16(s1)
    800066d8:	00275703          	lhu	a4,2(a4)
    800066dc:	faf71ce3          	bne	a4,a5,80006694 <virtio_disk_intr+0x3e>
  }

  release(&disk.vdisk_lock);
    800066e0:	0001b517          	auipc	a0,0x1b
    800066e4:	7f850513          	addi	a0,a0,2040 # 80021ed8 <disk+0x128>
    800066e8:	ffffa097          	auipc	ra,0xffffa
    800066ec:	662080e7          	jalr	1634(ra) # 80000d4a <release>
}
    800066f0:	60e2                	ld	ra,24(sp)
    800066f2:	6442                	ld	s0,16(sp)
    800066f4:	64a2                	ld	s1,8(sp)
    800066f6:	6105                	addi	sp,sp,32
    800066f8:	8082                	ret
      panic("virtio_disk_intr status");
    800066fa:	00002517          	auipc	a0,0x2
    800066fe:	27650513          	addi	a0,a0,630 # 80008970 <syscalls+0x400>
    80006702:	ffffa097          	auipc	ra,0xffffa
    80006706:	e26080e7          	jalr	-474(ra) # 80000528 <panic>
	...

0000000080007000 <_trampoline>:
    80007000:	14051073          	csrw	sscratch,a0
    80007004:	02000537          	lui	a0,0x2000
    80007008:	357d                	addiw	a0,a0,-1
    8000700a:	0536                	slli	a0,a0,0xd
    8000700c:	02153423          	sd	ra,40(a0) # 2000028 <_entry-0x7dffffd8>
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
    800070ac:	357d                	addiw	a0,a0,-1
    800070ae:	0536                	slli	a0,a0,0xd
    800070b0:	02853083          	ld	ra,40(a0) # 2000028 <_entry-0x7dffffd8>
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
