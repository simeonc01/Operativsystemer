
user/_time:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <main>:
#include "kernel/types.h"
#include "user/user.h"

int main(int argc, char *argv[])
{
   0:	1101                	addi	sp,sp,-32
   2:	ec06                	sd	ra,24(sp)
   4:	e822                	sd	s0,16(sp)
   6:	e426                	sd	s1,8(sp)
   8:	e04a                	sd	s2,0(sp)
   a:	1000                	addi	s0,sp,32
    if (argc < 2)
   c:	4785                	li	a5,1
   e:	02a7db63          	bge	a5,a0,44 <main+0x44>
  12:	84ae                	mv	s1,a1
        printf("Time took 0 ticks\n");
        printf("Usage: time [exec] [arg1 arg2 ...]\n");
        exit(1);
    }

    int startticks = uptime();
  14:	00000097          	auipc	ra,0x0
  18:	3c8080e7          	jalr	968(ra) # 3dc <uptime>
  1c:	892a                	mv	s2,a0

    // we now start the program in a separate process:
    int uutPid = fork();
  1e:	00000097          	auipc	ra,0x0
  22:	31e080e7          	jalr	798(ra) # 33c <fork>

    // check if fork worked:
    if (uutPid < 0)
  26:	04054463          	bltz	a0,6e <main+0x6e>
    {
        printf("fork failed... couldn't start %s", argv[1]);
        exit(1);
    }

    if (uutPid == 0)
  2a:	e125                	bnez	a0,8a <main+0x8a>
    {
        // we are the unit under test part of the program - execute the program immediately
        exec(argv[1], argv + 1); // pass rest of the command line to the executable as args
  2c:	00848593          	addi	a1,s1,8
  30:	6488                	ld	a0,8(s1)
  32:	00000097          	auipc	ra,0x0
  36:	34a080e7          	jalr	842(ra) # 37c <exec>
        // wait for the uut to finish
        wait(0);
        int endticks = uptime();
        printf("Executing %s took %d ticks\n", argv[1], endticks - startticks);
    }
    exit(0);
  3a:	4501                	li	a0,0
  3c:	00000097          	auipc	ra,0x0
  40:	308080e7          	jalr	776(ra) # 344 <exit>
        printf("Time took 0 ticks\n");
  44:	00001517          	auipc	a0,0x1
  48:	84c50513          	addi	a0,a0,-1972 # 890 <malloc+0xee>
  4c:	00000097          	auipc	ra,0x0
  50:	698080e7          	jalr	1688(ra) # 6e4 <printf>
        printf("Usage: time [exec] [arg1 arg2 ...]\n");
  54:	00001517          	auipc	a0,0x1
  58:	85450513          	addi	a0,a0,-1964 # 8a8 <malloc+0x106>
  5c:	00000097          	auipc	ra,0x0
  60:	688080e7          	jalr	1672(ra) # 6e4 <printf>
        exit(1);
  64:	4505                	li	a0,1
  66:	00000097          	auipc	ra,0x0
  6a:	2de080e7          	jalr	734(ra) # 344 <exit>
        printf("fork failed... couldn't start %s", argv[1]);
  6e:	648c                	ld	a1,8(s1)
  70:	00001517          	auipc	a0,0x1
  74:	86050513          	addi	a0,a0,-1952 # 8d0 <malloc+0x12e>
  78:	00000097          	auipc	ra,0x0
  7c:	66c080e7          	jalr	1644(ra) # 6e4 <printf>
        exit(1);
  80:	4505                	li	a0,1
  82:	00000097          	auipc	ra,0x0
  86:	2c2080e7          	jalr	706(ra) # 344 <exit>
        wait(0);
  8a:	4501                	li	a0,0
  8c:	00000097          	auipc	ra,0x0
  90:	2c0080e7          	jalr	704(ra) # 34c <wait>
        int endticks = uptime();
  94:	00000097          	auipc	ra,0x0
  98:	348080e7          	jalr	840(ra) # 3dc <uptime>
        printf("Executing %s took %d ticks\n", argv[1], endticks - startticks);
  9c:	4125063b          	subw	a2,a0,s2
  a0:	648c                	ld	a1,8(s1)
  a2:	00001517          	auipc	a0,0x1
  a6:	85650513          	addi	a0,a0,-1962 # 8f8 <malloc+0x156>
  aa:	00000097          	auipc	ra,0x0
  ae:	63a080e7          	jalr	1594(ra) # 6e4 <printf>
  b2:	b761                	j	3a <main+0x3a>

00000000000000b4 <_main>:
//
// wrapper so that it's OK if main() does not call exit().
//
void
_main()
{
  b4:	1141                	addi	sp,sp,-16
  b6:	e406                	sd	ra,8(sp)
  b8:	e022                	sd	s0,0(sp)
  ba:	0800                	addi	s0,sp,16
  extern int main();
  main();
  bc:	00000097          	auipc	ra,0x0
  c0:	f44080e7          	jalr	-188(ra) # 0 <main>
  exit(0);
  c4:	4501                	li	a0,0
  c6:	00000097          	auipc	ra,0x0
  ca:	27e080e7          	jalr	638(ra) # 344 <exit>

00000000000000ce <strcpy>:
}

char*
strcpy(char *s, const char *t)
{
  ce:	1141                	addi	sp,sp,-16
  d0:	e422                	sd	s0,8(sp)
  d2:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
  d4:	87aa                	mv	a5,a0
  d6:	0585                	addi	a1,a1,1
  d8:	0785                	addi	a5,a5,1
  da:	fff5c703          	lbu	a4,-1(a1)
  de:	fee78fa3          	sb	a4,-1(a5)
  e2:	fb75                	bnez	a4,d6 <strcpy+0x8>
    ;
  return os;
}
  e4:	6422                	ld	s0,8(sp)
  e6:	0141                	addi	sp,sp,16
  e8:	8082                	ret

00000000000000ea <strcmp>:

int
strcmp(const char *p, const char *q)
{
  ea:	1141                	addi	sp,sp,-16
  ec:	e422                	sd	s0,8(sp)
  ee:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
  f0:	00054783          	lbu	a5,0(a0)
  f4:	cb91                	beqz	a5,108 <strcmp+0x1e>
  f6:	0005c703          	lbu	a4,0(a1)
  fa:	00f71763          	bne	a4,a5,108 <strcmp+0x1e>
    p++, q++;
  fe:	0505                	addi	a0,a0,1
 100:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
 102:	00054783          	lbu	a5,0(a0)
 106:	fbe5                	bnez	a5,f6 <strcmp+0xc>
  return (uchar)*p - (uchar)*q;
 108:	0005c503          	lbu	a0,0(a1)
}
 10c:	40a7853b          	subw	a0,a5,a0
 110:	6422                	ld	s0,8(sp)
 112:	0141                	addi	sp,sp,16
 114:	8082                	ret

0000000000000116 <strlen>:

uint
strlen(const char *s)
{
 116:	1141                	addi	sp,sp,-16
 118:	e422                	sd	s0,8(sp)
 11a:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
 11c:	00054783          	lbu	a5,0(a0)
 120:	cf91                	beqz	a5,13c <strlen+0x26>
 122:	0505                	addi	a0,a0,1
 124:	87aa                	mv	a5,a0
 126:	4685                	li	a3,1
 128:	9e89                	subw	a3,a3,a0
 12a:	00f6853b          	addw	a0,a3,a5
 12e:	0785                	addi	a5,a5,1
 130:	fff7c703          	lbu	a4,-1(a5)
 134:	fb7d                	bnez	a4,12a <strlen+0x14>
    ;
  return n;
}
 136:	6422                	ld	s0,8(sp)
 138:	0141                	addi	sp,sp,16
 13a:	8082                	ret
  for(n = 0; s[n]; n++)
 13c:	4501                	li	a0,0
 13e:	bfe5                	j	136 <strlen+0x20>

0000000000000140 <memset>:

void*
memset(void *dst, int c, uint n)
{
 140:	1141                	addi	sp,sp,-16
 142:	e422                	sd	s0,8(sp)
 144:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
 146:	ce09                	beqz	a2,160 <memset+0x20>
 148:	87aa                	mv	a5,a0
 14a:	fff6071b          	addiw	a4,a2,-1
 14e:	1702                	slli	a4,a4,0x20
 150:	9301                	srli	a4,a4,0x20
 152:	0705                	addi	a4,a4,1
 154:	972a                	add	a4,a4,a0
    cdst[i] = c;
 156:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
 15a:	0785                	addi	a5,a5,1
 15c:	fee79de3          	bne	a5,a4,156 <memset+0x16>
  }
  return dst;
}
 160:	6422                	ld	s0,8(sp)
 162:	0141                	addi	sp,sp,16
 164:	8082                	ret

0000000000000166 <strchr>:

char*
strchr(const char *s, char c)
{
 166:	1141                	addi	sp,sp,-16
 168:	e422                	sd	s0,8(sp)
 16a:	0800                	addi	s0,sp,16
  for(; *s; s++)
 16c:	00054783          	lbu	a5,0(a0)
 170:	cb99                	beqz	a5,186 <strchr+0x20>
    if(*s == c)
 172:	00f58763          	beq	a1,a5,180 <strchr+0x1a>
  for(; *s; s++)
 176:	0505                	addi	a0,a0,1
 178:	00054783          	lbu	a5,0(a0)
 17c:	fbfd                	bnez	a5,172 <strchr+0xc>
      return (char*)s;
  return 0;
 17e:	4501                	li	a0,0
}
 180:	6422                	ld	s0,8(sp)
 182:	0141                	addi	sp,sp,16
 184:	8082                	ret
  return 0;
 186:	4501                	li	a0,0
 188:	bfe5                	j	180 <strchr+0x1a>

000000000000018a <gets>:

char*
gets(char *buf, int max)
{
 18a:	711d                	addi	sp,sp,-96
 18c:	ec86                	sd	ra,88(sp)
 18e:	e8a2                	sd	s0,80(sp)
 190:	e4a6                	sd	s1,72(sp)
 192:	e0ca                	sd	s2,64(sp)
 194:	fc4e                	sd	s3,56(sp)
 196:	f852                	sd	s4,48(sp)
 198:	f456                	sd	s5,40(sp)
 19a:	f05a                	sd	s6,32(sp)
 19c:	ec5e                	sd	s7,24(sp)
 19e:	1080                	addi	s0,sp,96
 1a0:	8baa                	mv	s7,a0
 1a2:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 1a4:	892a                	mv	s2,a0
 1a6:	4481                	li	s1,0
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
 1a8:	4aa9                	li	s5,10
 1aa:	4b35                	li	s6,13
  for(i=0; i+1 < max; ){
 1ac:	89a6                	mv	s3,s1
 1ae:	2485                	addiw	s1,s1,1
 1b0:	0344d863          	bge	s1,s4,1e0 <gets+0x56>
    cc = read(0, &c, 1);
 1b4:	4605                	li	a2,1
 1b6:	faf40593          	addi	a1,s0,-81
 1ba:	4501                	li	a0,0
 1bc:	00000097          	auipc	ra,0x0
 1c0:	1a0080e7          	jalr	416(ra) # 35c <read>
    if(cc < 1)
 1c4:	00a05e63          	blez	a0,1e0 <gets+0x56>
    buf[i++] = c;
 1c8:	faf44783          	lbu	a5,-81(s0)
 1cc:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
 1d0:	01578763          	beq	a5,s5,1de <gets+0x54>
 1d4:	0905                	addi	s2,s2,1
 1d6:	fd679be3          	bne	a5,s6,1ac <gets+0x22>
  for(i=0; i+1 < max; ){
 1da:	89a6                	mv	s3,s1
 1dc:	a011                	j	1e0 <gets+0x56>
 1de:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
 1e0:	99de                	add	s3,s3,s7
 1e2:	00098023          	sb	zero,0(s3)
  return buf;
}
 1e6:	855e                	mv	a0,s7
 1e8:	60e6                	ld	ra,88(sp)
 1ea:	6446                	ld	s0,80(sp)
 1ec:	64a6                	ld	s1,72(sp)
 1ee:	6906                	ld	s2,64(sp)
 1f0:	79e2                	ld	s3,56(sp)
 1f2:	7a42                	ld	s4,48(sp)
 1f4:	7aa2                	ld	s5,40(sp)
 1f6:	7b02                	ld	s6,32(sp)
 1f8:	6be2                	ld	s7,24(sp)
 1fa:	6125                	addi	sp,sp,96
 1fc:	8082                	ret

00000000000001fe <stat>:

int
stat(const char *n, struct stat *st)
{
 1fe:	1101                	addi	sp,sp,-32
 200:	ec06                	sd	ra,24(sp)
 202:	e822                	sd	s0,16(sp)
 204:	e426                	sd	s1,8(sp)
 206:	e04a                	sd	s2,0(sp)
 208:	1000                	addi	s0,sp,32
 20a:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 20c:	4581                	li	a1,0
 20e:	00000097          	auipc	ra,0x0
 212:	176080e7          	jalr	374(ra) # 384 <open>
  if(fd < 0)
 216:	02054563          	bltz	a0,240 <stat+0x42>
 21a:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 21c:	85ca                	mv	a1,s2
 21e:	00000097          	auipc	ra,0x0
 222:	17e080e7          	jalr	382(ra) # 39c <fstat>
 226:	892a                	mv	s2,a0
  close(fd);
 228:	8526                	mv	a0,s1
 22a:	00000097          	auipc	ra,0x0
 22e:	142080e7          	jalr	322(ra) # 36c <close>
  return r;
}
 232:	854a                	mv	a0,s2
 234:	60e2                	ld	ra,24(sp)
 236:	6442                	ld	s0,16(sp)
 238:	64a2                	ld	s1,8(sp)
 23a:	6902                	ld	s2,0(sp)
 23c:	6105                	addi	sp,sp,32
 23e:	8082                	ret
    return -1;
 240:	597d                	li	s2,-1
 242:	bfc5                	j	232 <stat+0x34>

0000000000000244 <atoi>:

int
atoi(const char *s)
{
 244:	1141                	addi	sp,sp,-16
 246:	e422                	sd	s0,8(sp)
 248:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 24a:	00054603          	lbu	a2,0(a0)
 24e:	fd06079b          	addiw	a5,a2,-48
 252:	0ff7f793          	andi	a5,a5,255
 256:	4725                	li	a4,9
 258:	02f76963          	bltu	a4,a5,28a <atoi+0x46>
 25c:	86aa                	mv	a3,a0
  n = 0;
 25e:	4501                	li	a0,0
  while('0' <= *s && *s <= '9')
 260:	45a5                	li	a1,9
    n = n*10 + *s++ - '0';
 262:	0685                	addi	a3,a3,1
 264:	0025179b          	slliw	a5,a0,0x2
 268:	9fa9                	addw	a5,a5,a0
 26a:	0017979b          	slliw	a5,a5,0x1
 26e:	9fb1                	addw	a5,a5,a2
 270:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 274:	0006c603          	lbu	a2,0(a3)
 278:	fd06071b          	addiw	a4,a2,-48
 27c:	0ff77713          	andi	a4,a4,255
 280:	fee5f1e3          	bgeu	a1,a4,262 <atoi+0x1e>
  return n;
}
 284:	6422                	ld	s0,8(sp)
 286:	0141                	addi	sp,sp,16
 288:	8082                	ret
  n = 0;
 28a:	4501                	li	a0,0
 28c:	bfe5                	j	284 <atoi+0x40>

000000000000028e <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 28e:	1141                	addi	sp,sp,-16
 290:	e422                	sd	s0,8(sp)
 292:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 294:	02b57663          	bgeu	a0,a1,2c0 <memmove+0x32>
    while(n-- > 0)
 298:	02c05163          	blez	a2,2ba <memmove+0x2c>
 29c:	fff6079b          	addiw	a5,a2,-1
 2a0:	1782                	slli	a5,a5,0x20
 2a2:	9381                	srli	a5,a5,0x20
 2a4:	0785                	addi	a5,a5,1
 2a6:	97aa                	add	a5,a5,a0
  dst = vdst;
 2a8:	872a                	mv	a4,a0
      *dst++ = *src++;
 2aa:	0585                	addi	a1,a1,1
 2ac:	0705                	addi	a4,a4,1
 2ae:	fff5c683          	lbu	a3,-1(a1)
 2b2:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
 2b6:	fee79ae3          	bne	a5,a4,2aa <memmove+0x1c>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 2ba:	6422                	ld	s0,8(sp)
 2bc:	0141                	addi	sp,sp,16
 2be:	8082                	ret
    dst += n;
 2c0:	00c50733          	add	a4,a0,a2
    src += n;
 2c4:	95b2                	add	a1,a1,a2
    while(n-- > 0)
 2c6:	fec05ae3          	blez	a2,2ba <memmove+0x2c>
 2ca:	fff6079b          	addiw	a5,a2,-1
 2ce:	1782                	slli	a5,a5,0x20
 2d0:	9381                	srli	a5,a5,0x20
 2d2:	fff7c793          	not	a5,a5
 2d6:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 2d8:	15fd                	addi	a1,a1,-1
 2da:	177d                	addi	a4,a4,-1
 2dc:	0005c683          	lbu	a3,0(a1)
 2e0:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
 2e4:	fee79ae3          	bne	a5,a4,2d8 <memmove+0x4a>
 2e8:	bfc9                	j	2ba <memmove+0x2c>

00000000000002ea <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 2ea:	1141                	addi	sp,sp,-16
 2ec:	e422                	sd	s0,8(sp)
 2ee:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 2f0:	ca05                	beqz	a2,320 <memcmp+0x36>
 2f2:	fff6069b          	addiw	a3,a2,-1
 2f6:	1682                	slli	a3,a3,0x20
 2f8:	9281                	srli	a3,a3,0x20
 2fa:	0685                	addi	a3,a3,1
 2fc:	96aa                	add	a3,a3,a0
    if (*p1 != *p2) {
 2fe:	00054783          	lbu	a5,0(a0)
 302:	0005c703          	lbu	a4,0(a1)
 306:	00e79863          	bne	a5,a4,316 <memcmp+0x2c>
      return *p1 - *p2;
    }
    p1++;
 30a:	0505                	addi	a0,a0,1
    p2++;
 30c:	0585                	addi	a1,a1,1
  while (n-- > 0) {
 30e:	fed518e3          	bne	a0,a3,2fe <memcmp+0x14>
  }
  return 0;
 312:	4501                	li	a0,0
 314:	a019                	j	31a <memcmp+0x30>
      return *p1 - *p2;
 316:	40e7853b          	subw	a0,a5,a4
}
 31a:	6422                	ld	s0,8(sp)
 31c:	0141                	addi	sp,sp,16
 31e:	8082                	ret
  return 0;
 320:	4501                	li	a0,0
 322:	bfe5                	j	31a <memcmp+0x30>

0000000000000324 <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 324:	1141                	addi	sp,sp,-16
 326:	e406                	sd	ra,8(sp)
 328:	e022                	sd	s0,0(sp)
 32a:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
 32c:	00000097          	auipc	ra,0x0
 330:	f62080e7          	jalr	-158(ra) # 28e <memmove>
}
 334:	60a2                	ld	ra,8(sp)
 336:	6402                	ld	s0,0(sp)
 338:	0141                	addi	sp,sp,16
 33a:	8082                	ret

000000000000033c <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 33c:	4885                	li	a7,1
 ecall
 33e:	00000073          	ecall
 ret
 342:	8082                	ret

0000000000000344 <exit>:
.global exit
exit:
 li a7, SYS_exit
 344:	4889                	li	a7,2
 ecall
 346:	00000073          	ecall
 ret
 34a:	8082                	ret

000000000000034c <wait>:
.global wait
wait:
 li a7, SYS_wait
 34c:	488d                	li	a7,3
 ecall
 34e:	00000073          	ecall
 ret
 352:	8082                	ret

0000000000000354 <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 354:	4891                	li	a7,4
 ecall
 356:	00000073          	ecall
 ret
 35a:	8082                	ret

000000000000035c <read>:
.global read
read:
 li a7, SYS_read
 35c:	4895                	li	a7,5
 ecall
 35e:	00000073          	ecall
 ret
 362:	8082                	ret

0000000000000364 <write>:
.global write
write:
 li a7, SYS_write
 364:	48c1                	li	a7,16
 ecall
 366:	00000073          	ecall
 ret
 36a:	8082                	ret

000000000000036c <close>:
.global close
close:
 li a7, SYS_close
 36c:	48d5                	li	a7,21
 ecall
 36e:	00000073          	ecall
 ret
 372:	8082                	ret

0000000000000374 <kill>:
.global kill
kill:
 li a7, SYS_kill
 374:	4899                	li	a7,6
 ecall
 376:	00000073          	ecall
 ret
 37a:	8082                	ret

000000000000037c <exec>:
.global exec
exec:
 li a7, SYS_exec
 37c:	489d                	li	a7,7
 ecall
 37e:	00000073          	ecall
 ret
 382:	8082                	ret

0000000000000384 <open>:
.global open
open:
 li a7, SYS_open
 384:	48bd                	li	a7,15
 ecall
 386:	00000073          	ecall
 ret
 38a:	8082                	ret

000000000000038c <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 38c:	48c5                	li	a7,17
 ecall
 38e:	00000073          	ecall
 ret
 392:	8082                	ret

0000000000000394 <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 394:	48c9                	li	a7,18
 ecall
 396:	00000073          	ecall
 ret
 39a:	8082                	ret

000000000000039c <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 39c:	48a1                	li	a7,8
 ecall
 39e:	00000073          	ecall
 ret
 3a2:	8082                	ret

00000000000003a4 <link>:
.global link
link:
 li a7, SYS_link
 3a4:	48cd                	li	a7,19
 ecall
 3a6:	00000073          	ecall
 ret
 3aa:	8082                	ret

00000000000003ac <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 3ac:	48d1                	li	a7,20
 ecall
 3ae:	00000073          	ecall
 ret
 3b2:	8082                	ret

00000000000003b4 <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 3b4:	48a5                	li	a7,9
 ecall
 3b6:	00000073          	ecall
 ret
 3ba:	8082                	ret

00000000000003bc <dup>:
.global dup
dup:
 li a7, SYS_dup
 3bc:	48a9                	li	a7,10
 ecall
 3be:	00000073          	ecall
 ret
 3c2:	8082                	ret

00000000000003c4 <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 3c4:	48ad                	li	a7,11
 ecall
 3c6:	00000073          	ecall
 ret
 3ca:	8082                	ret

00000000000003cc <sbrk>:
.global sbrk
sbrk:
 li a7, SYS_sbrk
 3cc:	48b1                	li	a7,12
 ecall
 3ce:	00000073          	ecall
 ret
 3d2:	8082                	ret

00000000000003d4 <sleep>:
.global sleep
sleep:
 li a7, SYS_sleep
 3d4:	48b5                	li	a7,13
 ecall
 3d6:	00000073          	ecall
 ret
 3da:	8082                	ret

00000000000003dc <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 3dc:	48b9                	li	a7,14
 ecall
 3de:	00000073          	ecall
 ret
 3e2:	8082                	ret

00000000000003e4 <ps>:
.global ps
ps:
 li a7, SYS_ps
 3e4:	48d9                	li	a7,22
 ecall
 3e6:	00000073          	ecall
 ret
 3ea:	8082                	ret

00000000000003ec <schedls>:
.global schedls
schedls:
 li a7, SYS_schedls
 3ec:	48dd                	li	a7,23
 ecall
 3ee:	00000073          	ecall
 ret
 3f2:	8082                	ret

00000000000003f4 <schedset>:
.global schedset
schedset:
 li a7, SYS_schedset
 3f4:	48e1                	li	a7,24
 ecall
 3f6:	00000073          	ecall
 ret
 3fa:	8082                	ret

00000000000003fc <va2pa>:
.global va2pa
va2pa:
 li a7, SYS_va2pa
 3fc:	48e9                	li	a7,26
 ecall
 3fe:	00000073          	ecall
 ret
 402:	8082                	ret

0000000000000404 <pfreepages>:
.global pfreepages
pfreepages:
 li a7, SYS_pfreepages
 404:	48e5                	li	a7,25
 ecall
 406:	00000073          	ecall
 ret
 40a:	8082                	ret

000000000000040c <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 40c:	1101                	addi	sp,sp,-32
 40e:	ec06                	sd	ra,24(sp)
 410:	e822                	sd	s0,16(sp)
 412:	1000                	addi	s0,sp,32
 414:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 418:	4605                	li	a2,1
 41a:	fef40593          	addi	a1,s0,-17
 41e:	00000097          	auipc	ra,0x0
 422:	f46080e7          	jalr	-186(ra) # 364 <write>
}
 426:	60e2                	ld	ra,24(sp)
 428:	6442                	ld	s0,16(sp)
 42a:	6105                	addi	sp,sp,32
 42c:	8082                	ret

000000000000042e <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 42e:	7139                	addi	sp,sp,-64
 430:	fc06                	sd	ra,56(sp)
 432:	f822                	sd	s0,48(sp)
 434:	f426                	sd	s1,40(sp)
 436:	f04a                	sd	s2,32(sp)
 438:	ec4e                	sd	s3,24(sp)
 43a:	0080                	addi	s0,sp,64
 43c:	84aa                	mv	s1,a0
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
 43e:	c299                	beqz	a3,444 <printint+0x16>
 440:	0805c863          	bltz	a1,4d0 <printint+0xa2>
    neg = 1;
    x = -xx;
  } else {
    x = xx;
 444:	2581                	sext.w	a1,a1
  neg = 0;
 446:	4881                	li	a7,0
 448:	fc040693          	addi	a3,s0,-64
  }

  i = 0;
 44c:	4701                	li	a4,0
  do{
    buf[i++] = digits[x % base];
 44e:	2601                	sext.w	a2,a2
 450:	00000517          	auipc	a0,0x0
 454:	4d050513          	addi	a0,a0,1232 # 920 <digits>
 458:	883a                	mv	a6,a4
 45a:	2705                	addiw	a4,a4,1
 45c:	02c5f7bb          	remuw	a5,a1,a2
 460:	1782                	slli	a5,a5,0x20
 462:	9381                	srli	a5,a5,0x20
 464:	97aa                	add	a5,a5,a0
 466:	0007c783          	lbu	a5,0(a5)
 46a:	00f68023          	sb	a5,0(a3)
  }while((x /= base) != 0);
 46e:	0005879b          	sext.w	a5,a1
 472:	02c5d5bb          	divuw	a1,a1,a2
 476:	0685                	addi	a3,a3,1
 478:	fec7f0e3          	bgeu	a5,a2,458 <printint+0x2a>
  if(neg)
 47c:	00088b63          	beqz	a7,492 <printint+0x64>
    buf[i++] = '-';
 480:	fd040793          	addi	a5,s0,-48
 484:	973e                	add	a4,a4,a5
 486:	02d00793          	li	a5,45
 48a:	fef70823          	sb	a5,-16(a4)
 48e:	0028071b          	addiw	a4,a6,2

  while(--i >= 0)
 492:	02e05863          	blez	a4,4c2 <printint+0x94>
 496:	fc040793          	addi	a5,s0,-64
 49a:	00e78933          	add	s2,a5,a4
 49e:	fff78993          	addi	s3,a5,-1
 4a2:	99ba                	add	s3,s3,a4
 4a4:	377d                	addiw	a4,a4,-1
 4a6:	1702                	slli	a4,a4,0x20
 4a8:	9301                	srli	a4,a4,0x20
 4aa:	40e989b3          	sub	s3,s3,a4
    putc(fd, buf[i]);
 4ae:	fff94583          	lbu	a1,-1(s2)
 4b2:	8526                	mv	a0,s1
 4b4:	00000097          	auipc	ra,0x0
 4b8:	f58080e7          	jalr	-168(ra) # 40c <putc>
  while(--i >= 0)
 4bc:	197d                	addi	s2,s2,-1
 4be:	ff3918e3          	bne	s2,s3,4ae <printint+0x80>
}
 4c2:	70e2                	ld	ra,56(sp)
 4c4:	7442                	ld	s0,48(sp)
 4c6:	74a2                	ld	s1,40(sp)
 4c8:	7902                	ld	s2,32(sp)
 4ca:	69e2                	ld	s3,24(sp)
 4cc:	6121                	addi	sp,sp,64
 4ce:	8082                	ret
    x = -xx;
 4d0:	40b005bb          	negw	a1,a1
    neg = 1;
 4d4:	4885                	li	a7,1
    x = -xx;
 4d6:	bf8d                	j	448 <printint+0x1a>

00000000000004d8 <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 4d8:	7119                	addi	sp,sp,-128
 4da:	fc86                	sd	ra,120(sp)
 4dc:	f8a2                	sd	s0,112(sp)
 4de:	f4a6                	sd	s1,104(sp)
 4e0:	f0ca                	sd	s2,96(sp)
 4e2:	ecce                	sd	s3,88(sp)
 4e4:	e8d2                	sd	s4,80(sp)
 4e6:	e4d6                	sd	s5,72(sp)
 4e8:	e0da                	sd	s6,64(sp)
 4ea:	fc5e                	sd	s7,56(sp)
 4ec:	f862                	sd	s8,48(sp)
 4ee:	f466                	sd	s9,40(sp)
 4f0:	f06a                	sd	s10,32(sp)
 4f2:	ec6e                	sd	s11,24(sp)
 4f4:	0100                	addi	s0,sp,128
  char *s;
  int c, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 4f6:	0005c903          	lbu	s2,0(a1)
 4fa:	18090f63          	beqz	s2,698 <vprintf+0x1c0>
 4fe:	8aaa                	mv	s5,a0
 500:	8b32                	mv	s6,a2
 502:	00158493          	addi	s1,a1,1
  state = 0;
 506:	4981                	li	s3,0
      if(c == '%'){
        state = '%';
      } else {
        putc(fd, c);
      }
    } else if(state == '%'){
 508:	02500a13          	li	s4,37
      if(c == 'd'){
 50c:	06400c13          	li	s8,100
        printint(fd, va_arg(ap, int), 10, 1);
      } else if(c == 'l') {
 510:	06c00c93          	li	s9,108
        printint(fd, va_arg(ap, uint64), 10, 0);
      } else if(c == 'x') {
 514:	07800d13          	li	s10,120
        printint(fd, va_arg(ap, int), 16, 0);
      } else if(c == 'p') {
 518:	07000d93          	li	s11,112
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 51c:	00000b97          	auipc	s7,0x0
 520:	404b8b93          	addi	s7,s7,1028 # 920 <digits>
 524:	a839                	j	542 <vprintf+0x6a>
        putc(fd, c);
 526:	85ca                	mv	a1,s2
 528:	8556                	mv	a0,s5
 52a:	00000097          	auipc	ra,0x0
 52e:	ee2080e7          	jalr	-286(ra) # 40c <putc>
 532:	a019                	j	538 <vprintf+0x60>
    } else if(state == '%'){
 534:	01498f63          	beq	s3,s4,552 <vprintf+0x7a>
  for(i = 0; fmt[i]; i++){
 538:	0485                	addi	s1,s1,1
 53a:	fff4c903          	lbu	s2,-1(s1)
 53e:	14090d63          	beqz	s2,698 <vprintf+0x1c0>
    c = fmt[i] & 0xff;
 542:	0009079b          	sext.w	a5,s2
    if(state == 0){
 546:	fe0997e3          	bnez	s3,534 <vprintf+0x5c>
      if(c == '%'){
 54a:	fd479ee3          	bne	a5,s4,526 <vprintf+0x4e>
        state = '%';
 54e:	89be                	mv	s3,a5
 550:	b7e5                	j	538 <vprintf+0x60>
      if(c == 'd'){
 552:	05878063          	beq	a5,s8,592 <vprintf+0xba>
      } else if(c == 'l') {
 556:	05978c63          	beq	a5,s9,5ae <vprintf+0xd6>
      } else if(c == 'x') {
 55a:	07a78863          	beq	a5,s10,5ca <vprintf+0xf2>
      } else if(c == 'p') {
 55e:	09b78463          	beq	a5,s11,5e6 <vprintf+0x10e>
        printptr(fd, va_arg(ap, uint64));
      } else if(c == 's'){
 562:	07300713          	li	a4,115
 566:	0ce78663          	beq	a5,a4,632 <vprintf+0x15a>
          s = "(null)";
        while(*s != 0){
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
 56a:	06300713          	li	a4,99
 56e:	0ee78e63          	beq	a5,a4,66a <vprintf+0x192>
        putc(fd, va_arg(ap, uint));
      } else if(c == '%'){
 572:	11478863          	beq	a5,s4,682 <vprintf+0x1aa>
        putc(fd, c);
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 576:	85d2                	mv	a1,s4
 578:	8556                	mv	a0,s5
 57a:	00000097          	auipc	ra,0x0
 57e:	e92080e7          	jalr	-366(ra) # 40c <putc>
        putc(fd, c);
 582:	85ca                	mv	a1,s2
 584:	8556                	mv	a0,s5
 586:	00000097          	auipc	ra,0x0
 58a:	e86080e7          	jalr	-378(ra) # 40c <putc>
      }
      state = 0;
 58e:	4981                	li	s3,0
 590:	b765                	j	538 <vprintf+0x60>
        printint(fd, va_arg(ap, int), 10, 1);
 592:	008b0913          	addi	s2,s6,8
 596:	4685                	li	a3,1
 598:	4629                	li	a2,10
 59a:	000b2583          	lw	a1,0(s6)
 59e:	8556                	mv	a0,s5
 5a0:	00000097          	auipc	ra,0x0
 5a4:	e8e080e7          	jalr	-370(ra) # 42e <printint>
 5a8:	8b4a                	mv	s6,s2
      state = 0;
 5aa:	4981                	li	s3,0
 5ac:	b771                	j	538 <vprintf+0x60>
        printint(fd, va_arg(ap, uint64), 10, 0);
 5ae:	008b0913          	addi	s2,s6,8
 5b2:	4681                	li	a3,0
 5b4:	4629                	li	a2,10
 5b6:	000b2583          	lw	a1,0(s6)
 5ba:	8556                	mv	a0,s5
 5bc:	00000097          	auipc	ra,0x0
 5c0:	e72080e7          	jalr	-398(ra) # 42e <printint>
 5c4:	8b4a                	mv	s6,s2
      state = 0;
 5c6:	4981                	li	s3,0
 5c8:	bf85                	j	538 <vprintf+0x60>
        printint(fd, va_arg(ap, int), 16, 0);
 5ca:	008b0913          	addi	s2,s6,8
 5ce:	4681                	li	a3,0
 5d0:	4641                	li	a2,16
 5d2:	000b2583          	lw	a1,0(s6)
 5d6:	8556                	mv	a0,s5
 5d8:	00000097          	auipc	ra,0x0
 5dc:	e56080e7          	jalr	-426(ra) # 42e <printint>
 5e0:	8b4a                	mv	s6,s2
      state = 0;
 5e2:	4981                	li	s3,0
 5e4:	bf91                	j	538 <vprintf+0x60>
        printptr(fd, va_arg(ap, uint64));
 5e6:	008b0793          	addi	a5,s6,8
 5ea:	f8f43423          	sd	a5,-120(s0)
 5ee:	000b3983          	ld	s3,0(s6)
  putc(fd, '0');
 5f2:	03000593          	li	a1,48
 5f6:	8556                	mv	a0,s5
 5f8:	00000097          	auipc	ra,0x0
 5fc:	e14080e7          	jalr	-492(ra) # 40c <putc>
  putc(fd, 'x');
 600:	85ea                	mv	a1,s10
 602:	8556                	mv	a0,s5
 604:	00000097          	auipc	ra,0x0
 608:	e08080e7          	jalr	-504(ra) # 40c <putc>
 60c:	4941                	li	s2,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 60e:	03c9d793          	srli	a5,s3,0x3c
 612:	97de                	add	a5,a5,s7
 614:	0007c583          	lbu	a1,0(a5)
 618:	8556                	mv	a0,s5
 61a:	00000097          	auipc	ra,0x0
 61e:	df2080e7          	jalr	-526(ra) # 40c <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 622:	0992                	slli	s3,s3,0x4
 624:	397d                	addiw	s2,s2,-1
 626:	fe0914e3          	bnez	s2,60e <vprintf+0x136>
        printptr(fd, va_arg(ap, uint64));
 62a:	f8843b03          	ld	s6,-120(s0)
      state = 0;
 62e:	4981                	li	s3,0
 630:	b721                	j	538 <vprintf+0x60>
        s = va_arg(ap, char*);
 632:	008b0993          	addi	s3,s6,8
 636:	000b3903          	ld	s2,0(s6)
        if(s == 0)
 63a:	02090163          	beqz	s2,65c <vprintf+0x184>
        while(*s != 0){
 63e:	00094583          	lbu	a1,0(s2)
 642:	c9a1                	beqz	a1,692 <vprintf+0x1ba>
          putc(fd, *s);
 644:	8556                	mv	a0,s5
 646:	00000097          	auipc	ra,0x0
 64a:	dc6080e7          	jalr	-570(ra) # 40c <putc>
          s++;
 64e:	0905                	addi	s2,s2,1
        while(*s != 0){
 650:	00094583          	lbu	a1,0(s2)
 654:	f9e5                	bnez	a1,644 <vprintf+0x16c>
        s = va_arg(ap, char*);
 656:	8b4e                	mv	s6,s3
      state = 0;
 658:	4981                	li	s3,0
 65a:	bdf9                	j	538 <vprintf+0x60>
          s = "(null)";
 65c:	00000917          	auipc	s2,0x0
 660:	2bc90913          	addi	s2,s2,700 # 918 <malloc+0x176>
        while(*s != 0){
 664:	02800593          	li	a1,40
 668:	bff1                	j	644 <vprintf+0x16c>
        putc(fd, va_arg(ap, uint));
 66a:	008b0913          	addi	s2,s6,8
 66e:	000b4583          	lbu	a1,0(s6)
 672:	8556                	mv	a0,s5
 674:	00000097          	auipc	ra,0x0
 678:	d98080e7          	jalr	-616(ra) # 40c <putc>
 67c:	8b4a                	mv	s6,s2
      state = 0;
 67e:	4981                	li	s3,0
 680:	bd65                	j	538 <vprintf+0x60>
        putc(fd, c);
 682:	85d2                	mv	a1,s4
 684:	8556                	mv	a0,s5
 686:	00000097          	auipc	ra,0x0
 68a:	d86080e7          	jalr	-634(ra) # 40c <putc>
      state = 0;
 68e:	4981                	li	s3,0
 690:	b565                	j	538 <vprintf+0x60>
        s = va_arg(ap, char*);
 692:	8b4e                	mv	s6,s3
      state = 0;
 694:	4981                	li	s3,0
 696:	b54d                	j	538 <vprintf+0x60>
    }
  }
}
 698:	70e6                	ld	ra,120(sp)
 69a:	7446                	ld	s0,112(sp)
 69c:	74a6                	ld	s1,104(sp)
 69e:	7906                	ld	s2,96(sp)
 6a0:	69e6                	ld	s3,88(sp)
 6a2:	6a46                	ld	s4,80(sp)
 6a4:	6aa6                	ld	s5,72(sp)
 6a6:	6b06                	ld	s6,64(sp)
 6a8:	7be2                	ld	s7,56(sp)
 6aa:	7c42                	ld	s8,48(sp)
 6ac:	7ca2                	ld	s9,40(sp)
 6ae:	7d02                	ld	s10,32(sp)
 6b0:	6de2                	ld	s11,24(sp)
 6b2:	6109                	addi	sp,sp,128
 6b4:	8082                	ret

00000000000006b6 <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 6b6:	715d                	addi	sp,sp,-80
 6b8:	ec06                	sd	ra,24(sp)
 6ba:	e822                	sd	s0,16(sp)
 6bc:	1000                	addi	s0,sp,32
 6be:	e010                	sd	a2,0(s0)
 6c0:	e414                	sd	a3,8(s0)
 6c2:	e818                	sd	a4,16(s0)
 6c4:	ec1c                	sd	a5,24(s0)
 6c6:	03043023          	sd	a6,32(s0)
 6ca:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 6ce:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 6d2:	8622                	mv	a2,s0
 6d4:	00000097          	auipc	ra,0x0
 6d8:	e04080e7          	jalr	-508(ra) # 4d8 <vprintf>
}
 6dc:	60e2                	ld	ra,24(sp)
 6de:	6442                	ld	s0,16(sp)
 6e0:	6161                	addi	sp,sp,80
 6e2:	8082                	ret

00000000000006e4 <printf>:

void
printf(const char *fmt, ...)
{
 6e4:	711d                	addi	sp,sp,-96
 6e6:	ec06                	sd	ra,24(sp)
 6e8:	e822                	sd	s0,16(sp)
 6ea:	1000                	addi	s0,sp,32
 6ec:	e40c                	sd	a1,8(s0)
 6ee:	e810                	sd	a2,16(s0)
 6f0:	ec14                	sd	a3,24(s0)
 6f2:	f018                	sd	a4,32(s0)
 6f4:	f41c                	sd	a5,40(s0)
 6f6:	03043823          	sd	a6,48(s0)
 6fa:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 6fe:	00840613          	addi	a2,s0,8
 702:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 706:	85aa                	mv	a1,a0
 708:	4505                	li	a0,1
 70a:	00000097          	auipc	ra,0x0
 70e:	dce080e7          	jalr	-562(ra) # 4d8 <vprintf>
}
 712:	60e2                	ld	ra,24(sp)
 714:	6442                	ld	s0,16(sp)
 716:	6125                	addi	sp,sp,96
 718:	8082                	ret

000000000000071a <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 71a:	1141                	addi	sp,sp,-16
 71c:	e422                	sd	s0,8(sp)
 71e:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 720:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 724:	00001797          	auipc	a5,0x1
 728:	8dc7b783          	ld	a5,-1828(a5) # 1000 <freep>
 72c:	a805                	j	75c <free+0x42>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
 72e:	4618                	lw	a4,8(a2)
 730:	9db9                	addw	a1,a1,a4
 732:	feb52c23          	sw	a1,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 736:	6398                	ld	a4,0(a5)
 738:	6318                	ld	a4,0(a4)
 73a:	fee53823          	sd	a4,-16(a0)
 73e:	a091                	j	782 <free+0x68>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
 740:	ff852703          	lw	a4,-8(a0)
 744:	9e39                	addw	a2,a2,a4
 746:	c790                	sw	a2,8(a5)
    p->s.ptr = bp->s.ptr;
 748:	ff053703          	ld	a4,-16(a0)
 74c:	e398                	sd	a4,0(a5)
 74e:	a099                	j	794 <free+0x7a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 750:	6398                	ld	a4,0(a5)
 752:	00e7e463          	bltu	a5,a4,75a <free+0x40>
 756:	00e6ea63          	bltu	a3,a4,76a <free+0x50>
{
 75a:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 75c:	fed7fae3          	bgeu	a5,a3,750 <free+0x36>
 760:	6398                	ld	a4,0(a5)
 762:	00e6e463          	bltu	a3,a4,76a <free+0x50>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 766:	fee7eae3          	bltu	a5,a4,75a <free+0x40>
  if(bp + bp->s.size == p->s.ptr){
 76a:	ff852583          	lw	a1,-8(a0)
 76e:	6390                	ld	a2,0(a5)
 770:	02059713          	slli	a4,a1,0x20
 774:	9301                	srli	a4,a4,0x20
 776:	0712                	slli	a4,a4,0x4
 778:	9736                	add	a4,a4,a3
 77a:	fae60ae3          	beq	a2,a4,72e <free+0x14>
    bp->s.ptr = p->s.ptr;
 77e:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
 782:	4790                	lw	a2,8(a5)
 784:	02061713          	slli	a4,a2,0x20
 788:	9301                	srli	a4,a4,0x20
 78a:	0712                	slli	a4,a4,0x4
 78c:	973e                	add	a4,a4,a5
 78e:	fae689e3          	beq	a3,a4,740 <free+0x26>
  } else
    p->s.ptr = bp;
 792:	e394                	sd	a3,0(a5)
  freep = p;
 794:	00001717          	auipc	a4,0x1
 798:	86f73623          	sd	a5,-1940(a4) # 1000 <freep>
}
 79c:	6422                	ld	s0,8(sp)
 79e:	0141                	addi	sp,sp,16
 7a0:	8082                	ret

00000000000007a2 <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 7a2:	7139                	addi	sp,sp,-64
 7a4:	fc06                	sd	ra,56(sp)
 7a6:	f822                	sd	s0,48(sp)
 7a8:	f426                	sd	s1,40(sp)
 7aa:	f04a                	sd	s2,32(sp)
 7ac:	ec4e                	sd	s3,24(sp)
 7ae:	e852                	sd	s4,16(sp)
 7b0:	e456                	sd	s5,8(sp)
 7b2:	e05a                	sd	s6,0(sp)
 7b4:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 7b6:	02051493          	slli	s1,a0,0x20
 7ba:	9081                	srli	s1,s1,0x20
 7bc:	04bd                	addi	s1,s1,15
 7be:	8091                	srli	s1,s1,0x4
 7c0:	0014899b          	addiw	s3,s1,1
 7c4:	0485                	addi	s1,s1,1
  if((prevp = freep) == 0){
 7c6:	00001517          	auipc	a0,0x1
 7ca:	83a53503          	ld	a0,-1990(a0) # 1000 <freep>
 7ce:	c515                	beqz	a0,7fa <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 7d0:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 7d2:	4798                	lw	a4,8(a5)
 7d4:	02977f63          	bgeu	a4,s1,812 <malloc+0x70>
 7d8:	8a4e                	mv	s4,s3
 7da:	0009871b          	sext.w	a4,s3
 7de:	6685                	lui	a3,0x1
 7e0:	00d77363          	bgeu	a4,a3,7e6 <malloc+0x44>
 7e4:	6a05                	lui	s4,0x1
 7e6:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 7ea:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 7ee:	00001917          	auipc	s2,0x1
 7f2:	81290913          	addi	s2,s2,-2030 # 1000 <freep>
  if(p == (char*)-1)
 7f6:	5afd                	li	s5,-1
 7f8:	a88d                	j	86a <malloc+0xc8>
    base.s.ptr = freep = prevp = &base;
 7fa:	00001797          	auipc	a5,0x1
 7fe:	81678793          	addi	a5,a5,-2026 # 1010 <base>
 802:	00000717          	auipc	a4,0x0
 806:	7ef73f23          	sd	a5,2046(a4) # 1000 <freep>
 80a:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 80c:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 810:	b7e1                	j	7d8 <malloc+0x36>
      if(p->s.size == nunits)
 812:	02e48b63          	beq	s1,a4,848 <malloc+0xa6>
        p->s.size -= nunits;
 816:	4137073b          	subw	a4,a4,s3
 81a:	c798                	sw	a4,8(a5)
        p += p->s.size;
 81c:	1702                	slli	a4,a4,0x20
 81e:	9301                	srli	a4,a4,0x20
 820:	0712                	slli	a4,a4,0x4
 822:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 824:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 828:	00000717          	auipc	a4,0x0
 82c:	7ca73c23          	sd	a0,2008(a4) # 1000 <freep>
      return (void*)(p + 1);
 830:	01078513          	addi	a0,a5,16
      if((p = morecore(nunits)) == 0)
        return 0;
  }
}
 834:	70e2                	ld	ra,56(sp)
 836:	7442                	ld	s0,48(sp)
 838:	74a2                	ld	s1,40(sp)
 83a:	7902                	ld	s2,32(sp)
 83c:	69e2                	ld	s3,24(sp)
 83e:	6a42                	ld	s4,16(sp)
 840:	6aa2                	ld	s5,8(sp)
 842:	6b02                	ld	s6,0(sp)
 844:	6121                	addi	sp,sp,64
 846:	8082                	ret
        prevp->s.ptr = p->s.ptr;
 848:	6398                	ld	a4,0(a5)
 84a:	e118                	sd	a4,0(a0)
 84c:	bff1                	j	828 <malloc+0x86>
  hp->s.size = nu;
 84e:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
 852:	0541                	addi	a0,a0,16
 854:	00000097          	auipc	ra,0x0
 858:	ec6080e7          	jalr	-314(ra) # 71a <free>
  return freep;
 85c:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
 860:	d971                	beqz	a0,834 <malloc+0x92>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 862:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 864:	4798                	lw	a4,8(a5)
 866:	fa9776e3          	bgeu	a4,s1,812 <malloc+0x70>
    if(p == freep)
 86a:	00093703          	ld	a4,0(s2)
 86e:	853e                	mv	a0,a5
 870:	fef719e3          	bne	a4,a5,862 <malloc+0xc0>
  p = sbrk(nu * sizeof(Header));
 874:	8552                	mv	a0,s4
 876:	00000097          	auipc	ra,0x0
 87a:	b56080e7          	jalr	-1194(ra) # 3cc <sbrk>
  if(p == (char*)-1)
 87e:	fd5518e3          	bne	a0,s5,84e <malloc+0xac>
        return 0;
 882:	4501                	li	a0,0
 884:	bf45                	j	834 <malloc+0x92>
