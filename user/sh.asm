
user/_sh:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <getcmd>:
    }
    exit(0);
}

int getcmd(char *buf, int nbuf)
{
       0:	1101                	addi	sp,sp,-32
       2:	ec06                	sd	ra,24(sp)
       4:	e822                	sd	s0,16(sp)
       6:	e426                	sd	s1,8(sp)
       8:	e04a                	sd	s2,0(sp)
       a:	1000                	addi	s0,sp,32
       c:	84aa                	mv	s1,a0
       e:	892e                	mv	s2,a1
    write(2, "$ ", 2);
      10:	4609                	li	a2,2
      12:	00001597          	auipc	a1,0x1
      16:	3de58593          	addi	a1,a1,990 # 13f0 <malloc+0xe8>
      1a:	4509                	li	a0,2
      1c:	00001097          	auipc	ra,0x1
      20:	eae080e7          	jalr	-338(ra) # eca <write>
    memset(buf, 0, nbuf);
      24:	864a                	mv	a2,s2
      26:	4581                	li	a1,0
      28:	8526                	mv	a0,s1
      2a:	00001097          	auipc	ra,0x1
      2e:	c7c080e7          	jalr	-900(ra) # ca6 <memset>
    gets(buf, nbuf);
      32:	85ca                	mv	a1,s2
      34:	8526                	mv	a0,s1
      36:	00001097          	auipc	ra,0x1
      3a:	cba080e7          	jalr	-838(ra) # cf0 <gets>
    if (buf[0] == 0) // EOF
      3e:	0004c503          	lbu	a0,0(s1)
      42:	00153513          	seqz	a0,a0
        return -1;
    return 0;
}
      46:	40a00533          	neg	a0,a0
      4a:	60e2                	ld	ra,24(sp)
      4c:	6442                	ld	s0,16(sp)
      4e:	64a2                	ld	s1,8(sp)
      50:	6902                	ld	s2,0(sp)
      52:	6105                	addi	sp,sp,32
      54:	8082                	ret

0000000000000056 <panic>:
    }
    exit(0);
}

void panic(char *s)
{
      56:	1141                	addi	sp,sp,-16
      58:	e406                	sd	ra,8(sp)
      5a:	e022                	sd	s0,0(sp)
      5c:	0800                	addi	s0,sp,16
      5e:	862a                	mv	a2,a0
    fprintf(2, "%s\n", s);
      60:	00001597          	auipc	a1,0x1
      64:	39858593          	addi	a1,a1,920 # 13f8 <malloc+0xf0>
      68:	4509                	li	a0,2
      6a:	00001097          	auipc	ra,0x1
      6e:	1b2080e7          	jalr	434(ra) # 121c <fprintf>
    exit(1);
      72:	4505                	li	a0,1
      74:	00001097          	auipc	ra,0x1
      78:	e36080e7          	jalr	-458(ra) # eaa <exit>

000000000000007c <fork1>:
}

int fork1(void)
{
      7c:	1141                	addi	sp,sp,-16
      7e:	e406                	sd	ra,8(sp)
      80:	e022                	sd	s0,0(sp)
      82:	0800                	addi	s0,sp,16
    int pid;

    pid = fork();
      84:	00001097          	auipc	ra,0x1
      88:	e1e080e7          	jalr	-482(ra) # ea2 <fork>
    if (pid == -1)
      8c:	57fd                	li	a5,-1
      8e:	00f50663          	beq	a0,a5,9a <fork1+0x1e>
        panic("fork");
    return pid;
}
      92:	60a2                	ld	ra,8(sp)
      94:	6402                	ld	s0,0(sp)
      96:	0141                	addi	sp,sp,16
      98:	8082                	ret
        panic("fork");
      9a:	00001517          	auipc	a0,0x1
      9e:	36650513          	addi	a0,a0,870 # 1400 <malloc+0xf8>
      a2:	00000097          	auipc	ra,0x0
      a6:	fb4080e7          	jalr	-76(ra) # 56 <panic>

00000000000000aa <runcmd>:
{
      aa:	7179                	addi	sp,sp,-48
      ac:	f406                	sd	ra,40(sp)
      ae:	f022                	sd	s0,32(sp)
      b0:	ec26                	sd	s1,24(sp)
      b2:	1800                	addi	s0,sp,48
    if (cmd == 0)
      b4:	c10d                	beqz	a0,d6 <runcmd+0x2c>
      b6:	84aa                	mv	s1,a0
    switch (cmd->type)
      b8:	4118                	lw	a4,0(a0)
      ba:	4795                	li	a5,5
      bc:	02e7e263          	bltu	a5,a4,e0 <runcmd+0x36>
      c0:	00056783          	lwu	a5,0(a0)
      c4:	078a                	slli	a5,a5,0x2
      c6:	00001717          	auipc	a4,0x1
      ca:	44e70713          	addi	a4,a4,1102 # 1514 <malloc+0x20c>
      ce:	97ba                	add	a5,a5,a4
      d0:	439c                	lw	a5,0(a5)
      d2:	97ba                	add	a5,a5,a4
      d4:	8782                	jr	a5
        exit(1);
      d6:	4505                	li	a0,1
      d8:	00001097          	auipc	ra,0x1
      dc:	dd2080e7          	jalr	-558(ra) # eaa <exit>
        panic("runcmd");
      e0:	00001517          	auipc	a0,0x1
      e4:	32850513          	addi	a0,a0,808 # 1408 <malloc+0x100>
      e8:	00000097          	auipc	ra,0x0
      ec:	f6e080e7          	jalr	-146(ra) # 56 <panic>
        if (ecmd->argv[0] == 0)
      f0:	6508                	ld	a0,8(a0)
      f2:	c515                	beqz	a0,11e <runcmd+0x74>
        exec(ecmd->argv[0], ecmd->argv);
      f4:	00848593          	addi	a1,s1,8
      f8:	00001097          	auipc	ra,0x1
      fc:	dea080e7          	jalr	-534(ra) # ee2 <exec>
        fprintf(2, "exec %s failed\n", ecmd->argv[0]);
     100:	6490                	ld	a2,8(s1)
     102:	00001597          	auipc	a1,0x1
     106:	30e58593          	addi	a1,a1,782 # 1410 <malloc+0x108>
     10a:	4509                	li	a0,2
     10c:	00001097          	auipc	ra,0x1
     110:	110080e7          	jalr	272(ra) # 121c <fprintf>
    exit(0);
     114:	4501                	li	a0,0
     116:	00001097          	auipc	ra,0x1
     11a:	d94080e7          	jalr	-620(ra) # eaa <exit>
            exit(1);
     11e:	4505                	li	a0,1
     120:	00001097          	auipc	ra,0x1
     124:	d8a080e7          	jalr	-630(ra) # eaa <exit>
        close(rcmd->fd);
     128:	5148                	lw	a0,36(a0)
     12a:	00001097          	auipc	ra,0x1
     12e:	da8080e7          	jalr	-600(ra) # ed2 <close>
        if (open(rcmd->file, rcmd->mode) < 0)
     132:	508c                	lw	a1,32(s1)
     134:	6888                	ld	a0,16(s1)
     136:	00001097          	auipc	ra,0x1
     13a:	db4080e7          	jalr	-588(ra) # eea <open>
     13e:	00054763          	bltz	a0,14c <runcmd+0xa2>
        runcmd(rcmd->cmd);
     142:	6488                	ld	a0,8(s1)
     144:	00000097          	auipc	ra,0x0
     148:	f66080e7          	jalr	-154(ra) # aa <runcmd>
            fprintf(2, "open %s failed\n", rcmd->file);
     14c:	6890                	ld	a2,16(s1)
     14e:	00001597          	auipc	a1,0x1
     152:	2d258593          	addi	a1,a1,722 # 1420 <malloc+0x118>
     156:	4509                	li	a0,2
     158:	00001097          	auipc	ra,0x1
     15c:	0c4080e7          	jalr	196(ra) # 121c <fprintf>
            exit(1);
     160:	4505                	li	a0,1
     162:	00001097          	auipc	ra,0x1
     166:	d48080e7          	jalr	-696(ra) # eaa <exit>
        if (fork1() == 0)
     16a:	00000097          	auipc	ra,0x0
     16e:	f12080e7          	jalr	-238(ra) # 7c <fork1>
     172:	e511                	bnez	a0,17e <runcmd+0xd4>
            runcmd(lcmd->left);
     174:	6488                	ld	a0,8(s1)
     176:	00000097          	auipc	ra,0x0
     17a:	f34080e7          	jalr	-204(ra) # aa <runcmd>
        wait(0);
     17e:	4501                	li	a0,0
     180:	00001097          	auipc	ra,0x1
     184:	d32080e7          	jalr	-718(ra) # eb2 <wait>
        runcmd(lcmd->right);
     188:	6888                	ld	a0,16(s1)
     18a:	00000097          	auipc	ra,0x0
     18e:	f20080e7          	jalr	-224(ra) # aa <runcmd>
        if (pipe(p) < 0)
     192:	fd840513          	addi	a0,s0,-40
     196:	00001097          	auipc	ra,0x1
     19a:	d24080e7          	jalr	-732(ra) # eba <pipe>
     19e:	04054363          	bltz	a0,1e4 <runcmd+0x13a>
        if (fork1() == 0)
     1a2:	00000097          	auipc	ra,0x0
     1a6:	eda080e7          	jalr	-294(ra) # 7c <fork1>
     1aa:	e529                	bnez	a0,1f4 <runcmd+0x14a>
            close(1);
     1ac:	4505                	li	a0,1
     1ae:	00001097          	auipc	ra,0x1
     1b2:	d24080e7          	jalr	-732(ra) # ed2 <close>
            dup(p[1]);
     1b6:	fdc42503          	lw	a0,-36(s0)
     1ba:	00001097          	auipc	ra,0x1
     1be:	d68080e7          	jalr	-664(ra) # f22 <dup>
            close(p[0]);
     1c2:	fd842503          	lw	a0,-40(s0)
     1c6:	00001097          	auipc	ra,0x1
     1ca:	d0c080e7          	jalr	-756(ra) # ed2 <close>
            close(p[1]);
     1ce:	fdc42503          	lw	a0,-36(s0)
     1d2:	00001097          	auipc	ra,0x1
     1d6:	d00080e7          	jalr	-768(ra) # ed2 <close>
            runcmd(pcmd->left);
     1da:	6488                	ld	a0,8(s1)
     1dc:	00000097          	auipc	ra,0x0
     1e0:	ece080e7          	jalr	-306(ra) # aa <runcmd>
            panic("pipe");
     1e4:	00001517          	auipc	a0,0x1
     1e8:	24c50513          	addi	a0,a0,588 # 1430 <malloc+0x128>
     1ec:	00000097          	auipc	ra,0x0
     1f0:	e6a080e7          	jalr	-406(ra) # 56 <panic>
        if (fork1() == 0)
     1f4:	00000097          	auipc	ra,0x0
     1f8:	e88080e7          	jalr	-376(ra) # 7c <fork1>
     1fc:	ed05                	bnez	a0,234 <runcmd+0x18a>
            close(0);
     1fe:	00001097          	auipc	ra,0x1
     202:	cd4080e7          	jalr	-812(ra) # ed2 <close>
            dup(p[0]);
     206:	fd842503          	lw	a0,-40(s0)
     20a:	00001097          	auipc	ra,0x1
     20e:	d18080e7          	jalr	-744(ra) # f22 <dup>
            close(p[0]);
     212:	fd842503          	lw	a0,-40(s0)
     216:	00001097          	auipc	ra,0x1
     21a:	cbc080e7          	jalr	-836(ra) # ed2 <close>
            close(p[1]);
     21e:	fdc42503          	lw	a0,-36(s0)
     222:	00001097          	auipc	ra,0x1
     226:	cb0080e7          	jalr	-848(ra) # ed2 <close>
            runcmd(pcmd->right);
     22a:	6888                	ld	a0,16(s1)
     22c:	00000097          	auipc	ra,0x0
     230:	e7e080e7          	jalr	-386(ra) # aa <runcmd>
        close(p[0]);
     234:	fd842503          	lw	a0,-40(s0)
     238:	00001097          	auipc	ra,0x1
     23c:	c9a080e7          	jalr	-870(ra) # ed2 <close>
        close(p[1]);
     240:	fdc42503          	lw	a0,-36(s0)
     244:	00001097          	auipc	ra,0x1
     248:	c8e080e7          	jalr	-882(ra) # ed2 <close>
        wait(0);
     24c:	4501                	li	a0,0
     24e:	00001097          	auipc	ra,0x1
     252:	c64080e7          	jalr	-924(ra) # eb2 <wait>
        wait(0);
     256:	4501                	li	a0,0
     258:	00001097          	auipc	ra,0x1
     25c:	c5a080e7          	jalr	-934(ra) # eb2 <wait>
        break;
     260:	bd55                	j	114 <runcmd+0x6a>
        if (fork1() == 0)
     262:	00000097          	auipc	ra,0x0
     266:	e1a080e7          	jalr	-486(ra) # 7c <fork1>
     26a:	ea0515e3          	bnez	a0,114 <runcmd+0x6a>
            runcmd(bcmd->cmd);
     26e:	6488                	ld	a0,8(s1)
     270:	00000097          	auipc	ra,0x0
     274:	e3a080e7          	jalr	-454(ra) # aa <runcmd>

0000000000000278 <execcmd>:
// PAGEBREAK!
//  Constructors

struct cmd *
execcmd(void)
{
     278:	1101                	addi	sp,sp,-32
     27a:	ec06                	sd	ra,24(sp)
     27c:	e822                	sd	s0,16(sp)
     27e:	e426                	sd	s1,8(sp)
     280:	1000                	addi	s0,sp,32
    struct execcmd *cmd;

    cmd = malloc(sizeof(*cmd));
     282:	0a800513          	li	a0,168
     286:	00001097          	auipc	ra,0x1
     28a:	082080e7          	jalr	130(ra) # 1308 <malloc>
     28e:	84aa                	mv	s1,a0
    memset(cmd, 0, sizeof(*cmd));
     290:	0a800613          	li	a2,168
     294:	4581                	li	a1,0
     296:	00001097          	auipc	ra,0x1
     29a:	a10080e7          	jalr	-1520(ra) # ca6 <memset>
    cmd->type = EXEC;
     29e:	4785                	li	a5,1
     2a0:	c09c                	sw	a5,0(s1)
    return (struct cmd *)cmd;
}
     2a2:	8526                	mv	a0,s1
     2a4:	60e2                	ld	ra,24(sp)
     2a6:	6442                	ld	s0,16(sp)
     2a8:	64a2                	ld	s1,8(sp)
     2aa:	6105                	addi	sp,sp,32
     2ac:	8082                	ret

00000000000002ae <redircmd>:

struct cmd *
redircmd(struct cmd *subcmd, char *file, char *efile, int mode, int fd)
{
     2ae:	7139                	addi	sp,sp,-64
     2b0:	fc06                	sd	ra,56(sp)
     2b2:	f822                	sd	s0,48(sp)
     2b4:	f426                	sd	s1,40(sp)
     2b6:	f04a                	sd	s2,32(sp)
     2b8:	ec4e                	sd	s3,24(sp)
     2ba:	e852                	sd	s4,16(sp)
     2bc:	e456                	sd	s5,8(sp)
     2be:	e05a                	sd	s6,0(sp)
     2c0:	0080                	addi	s0,sp,64
     2c2:	8b2a                	mv	s6,a0
     2c4:	8aae                	mv	s5,a1
     2c6:	8a32                	mv	s4,a2
     2c8:	89b6                	mv	s3,a3
     2ca:	893a                	mv	s2,a4
    struct redircmd *cmd;

    cmd = malloc(sizeof(*cmd));
     2cc:	02800513          	li	a0,40
     2d0:	00001097          	auipc	ra,0x1
     2d4:	038080e7          	jalr	56(ra) # 1308 <malloc>
     2d8:	84aa                	mv	s1,a0
    memset(cmd, 0, sizeof(*cmd));
     2da:	02800613          	li	a2,40
     2de:	4581                	li	a1,0
     2e0:	00001097          	auipc	ra,0x1
     2e4:	9c6080e7          	jalr	-1594(ra) # ca6 <memset>
    cmd->type = REDIR;
     2e8:	4789                	li	a5,2
     2ea:	c09c                	sw	a5,0(s1)
    cmd->cmd = subcmd;
     2ec:	0164b423          	sd	s6,8(s1)
    cmd->file = file;
     2f0:	0154b823          	sd	s5,16(s1)
    cmd->efile = efile;
     2f4:	0144bc23          	sd	s4,24(s1)
    cmd->mode = mode;
     2f8:	0334a023          	sw	s3,32(s1)
    cmd->fd = fd;
     2fc:	0324a223          	sw	s2,36(s1)
    return (struct cmd *)cmd;
}
     300:	8526                	mv	a0,s1
     302:	70e2                	ld	ra,56(sp)
     304:	7442                	ld	s0,48(sp)
     306:	74a2                	ld	s1,40(sp)
     308:	7902                	ld	s2,32(sp)
     30a:	69e2                	ld	s3,24(sp)
     30c:	6a42                	ld	s4,16(sp)
     30e:	6aa2                	ld	s5,8(sp)
     310:	6b02                	ld	s6,0(sp)
     312:	6121                	addi	sp,sp,64
     314:	8082                	ret

0000000000000316 <pipecmd>:

struct cmd *
pipecmd(struct cmd *left, struct cmd *right)
{
     316:	7179                	addi	sp,sp,-48
     318:	f406                	sd	ra,40(sp)
     31a:	f022                	sd	s0,32(sp)
     31c:	ec26                	sd	s1,24(sp)
     31e:	e84a                	sd	s2,16(sp)
     320:	e44e                	sd	s3,8(sp)
     322:	1800                	addi	s0,sp,48
     324:	89aa                	mv	s3,a0
     326:	892e                	mv	s2,a1
    struct pipecmd *cmd;

    cmd = malloc(sizeof(*cmd));
     328:	4561                	li	a0,24
     32a:	00001097          	auipc	ra,0x1
     32e:	fde080e7          	jalr	-34(ra) # 1308 <malloc>
     332:	84aa                	mv	s1,a0
    memset(cmd, 0, sizeof(*cmd));
     334:	4661                	li	a2,24
     336:	4581                	li	a1,0
     338:	00001097          	auipc	ra,0x1
     33c:	96e080e7          	jalr	-1682(ra) # ca6 <memset>
    cmd->type = PIPE;
     340:	478d                	li	a5,3
     342:	c09c                	sw	a5,0(s1)
    cmd->left = left;
     344:	0134b423          	sd	s3,8(s1)
    cmd->right = right;
     348:	0124b823          	sd	s2,16(s1)
    return (struct cmd *)cmd;
}
     34c:	8526                	mv	a0,s1
     34e:	70a2                	ld	ra,40(sp)
     350:	7402                	ld	s0,32(sp)
     352:	64e2                	ld	s1,24(sp)
     354:	6942                	ld	s2,16(sp)
     356:	69a2                	ld	s3,8(sp)
     358:	6145                	addi	sp,sp,48
     35a:	8082                	ret

000000000000035c <listcmd>:

struct cmd *
listcmd(struct cmd *left, struct cmd *right)
{
     35c:	7179                	addi	sp,sp,-48
     35e:	f406                	sd	ra,40(sp)
     360:	f022                	sd	s0,32(sp)
     362:	ec26                	sd	s1,24(sp)
     364:	e84a                	sd	s2,16(sp)
     366:	e44e                	sd	s3,8(sp)
     368:	1800                	addi	s0,sp,48
     36a:	89aa                	mv	s3,a0
     36c:	892e                	mv	s2,a1
    struct listcmd *cmd;

    cmd = malloc(sizeof(*cmd));
     36e:	4561                	li	a0,24
     370:	00001097          	auipc	ra,0x1
     374:	f98080e7          	jalr	-104(ra) # 1308 <malloc>
     378:	84aa                	mv	s1,a0
    memset(cmd, 0, sizeof(*cmd));
     37a:	4661                	li	a2,24
     37c:	4581                	li	a1,0
     37e:	00001097          	auipc	ra,0x1
     382:	928080e7          	jalr	-1752(ra) # ca6 <memset>
    cmd->type = LIST;
     386:	4791                	li	a5,4
     388:	c09c                	sw	a5,0(s1)
    cmd->left = left;
     38a:	0134b423          	sd	s3,8(s1)
    cmd->right = right;
     38e:	0124b823          	sd	s2,16(s1)
    return (struct cmd *)cmd;
}
     392:	8526                	mv	a0,s1
     394:	70a2                	ld	ra,40(sp)
     396:	7402                	ld	s0,32(sp)
     398:	64e2                	ld	s1,24(sp)
     39a:	6942                	ld	s2,16(sp)
     39c:	69a2                	ld	s3,8(sp)
     39e:	6145                	addi	sp,sp,48
     3a0:	8082                	ret

00000000000003a2 <backcmd>:

struct cmd *
backcmd(struct cmd *subcmd)
{
     3a2:	1101                	addi	sp,sp,-32
     3a4:	ec06                	sd	ra,24(sp)
     3a6:	e822                	sd	s0,16(sp)
     3a8:	e426                	sd	s1,8(sp)
     3aa:	e04a                	sd	s2,0(sp)
     3ac:	1000                	addi	s0,sp,32
     3ae:	892a                	mv	s2,a0
    struct backcmd *cmd;

    cmd = malloc(sizeof(*cmd));
     3b0:	4541                	li	a0,16
     3b2:	00001097          	auipc	ra,0x1
     3b6:	f56080e7          	jalr	-170(ra) # 1308 <malloc>
     3ba:	84aa                	mv	s1,a0
    memset(cmd, 0, sizeof(*cmd));
     3bc:	4641                	li	a2,16
     3be:	4581                	li	a1,0
     3c0:	00001097          	auipc	ra,0x1
     3c4:	8e6080e7          	jalr	-1818(ra) # ca6 <memset>
    cmd->type = BACK;
     3c8:	4795                	li	a5,5
     3ca:	c09c                	sw	a5,0(s1)
    cmd->cmd = subcmd;
     3cc:	0124b423          	sd	s2,8(s1)
    return (struct cmd *)cmd;
}
     3d0:	8526                	mv	a0,s1
     3d2:	60e2                	ld	ra,24(sp)
     3d4:	6442                	ld	s0,16(sp)
     3d6:	64a2                	ld	s1,8(sp)
     3d8:	6902                	ld	s2,0(sp)
     3da:	6105                	addi	sp,sp,32
     3dc:	8082                	ret

00000000000003de <gettoken>:

char whitespace[] = " \t\r\n\v";
char symbols[] = "<|>&;()";

int gettoken(char **ps, char *es, char **q, char **eq)
{
     3de:	7139                	addi	sp,sp,-64
     3e0:	fc06                	sd	ra,56(sp)
     3e2:	f822                	sd	s0,48(sp)
     3e4:	f426                	sd	s1,40(sp)
     3e6:	f04a                	sd	s2,32(sp)
     3e8:	ec4e                	sd	s3,24(sp)
     3ea:	e852                	sd	s4,16(sp)
     3ec:	e456                	sd	s5,8(sp)
     3ee:	e05a                	sd	s6,0(sp)
     3f0:	0080                	addi	s0,sp,64
     3f2:	8a2a                	mv	s4,a0
     3f4:	892e                	mv	s2,a1
     3f6:	8ab2                	mv	s5,a2
     3f8:	8b36                	mv	s6,a3
    char *s;
    int ret;

    s = *ps;
     3fa:	6104                	ld	s1,0(a0)
    while (s < es && strchr(whitespace, *s))
     3fc:	00002997          	auipc	s3,0x2
     400:	c0c98993          	addi	s3,s3,-1012 # 2008 <whitespace>
     404:	00b4fd63          	bgeu	s1,a1,41e <gettoken+0x40>
     408:	0004c583          	lbu	a1,0(s1)
     40c:	854e                	mv	a0,s3
     40e:	00001097          	auipc	ra,0x1
     412:	8be080e7          	jalr	-1858(ra) # ccc <strchr>
     416:	c501                	beqz	a0,41e <gettoken+0x40>
        s++;
     418:	0485                	addi	s1,s1,1
    while (s < es && strchr(whitespace, *s))
     41a:	fe9917e3          	bne	s2,s1,408 <gettoken+0x2a>
    if (q)
     41e:	000a8463          	beqz	s5,426 <gettoken+0x48>
        *q = s;
     422:	009ab023          	sd	s1,0(s5)
    ret = *s;
     426:	0004c783          	lbu	a5,0(s1)
     42a:	00078a9b          	sext.w	s5,a5
    switch (*s)
     42e:	03c00713          	li	a4,60
     432:	06f76563          	bltu	a4,a5,49c <gettoken+0xbe>
     436:	03a00713          	li	a4,58
     43a:	00f76e63          	bltu	a4,a5,456 <gettoken+0x78>
     43e:	cf89                	beqz	a5,458 <gettoken+0x7a>
     440:	02600713          	li	a4,38
     444:	00e78963          	beq	a5,a4,456 <gettoken+0x78>
     448:	fd87879b          	addiw	a5,a5,-40
     44c:	0ff7f793          	andi	a5,a5,255
     450:	4705                	li	a4,1
     452:	06f76c63          	bltu	a4,a5,4ca <gettoken+0xec>
    case '(':
    case ')':
    case ';':
    case '&':
    case '<':
        s++;
     456:	0485                	addi	s1,s1,1
        ret = 'a';
        while (s < es && !strchr(whitespace, *s) && !strchr(symbols, *s))
            s++;
        break;
    }
    if (eq)
     458:	000b0463          	beqz	s6,460 <gettoken+0x82>
        *eq = s;
     45c:	009b3023          	sd	s1,0(s6)

    while (s < es && strchr(whitespace, *s))
     460:	00002997          	auipc	s3,0x2
     464:	ba898993          	addi	s3,s3,-1112 # 2008 <whitespace>
     468:	0124fd63          	bgeu	s1,s2,482 <gettoken+0xa4>
     46c:	0004c583          	lbu	a1,0(s1)
     470:	854e                	mv	a0,s3
     472:	00001097          	auipc	ra,0x1
     476:	85a080e7          	jalr	-1958(ra) # ccc <strchr>
     47a:	c501                	beqz	a0,482 <gettoken+0xa4>
        s++;
     47c:	0485                	addi	s1,s1,1
    while (s < es && strchr(whitespace, *s))
     47e:	fe9917e3          	bne	s2,s1,46c <gettoken+0x8e>
    *ps = s;
     482:	009a3023          	sd	s1,0(s4)
    return ret;
}
     486:	8556                	mv	a0,s5
     488:	70e2                	ld	ra,56(sp)
     48a:	7442                	ld	s0,48(sp)
     48c:	74a2                	ld	s1,40(sp)
     48e:	7902                	ld	s2,32(sp)
     490:	69e2                	ld	s3,24(sp)
     492:	6a42                	ld	s4,16(sp)
     494:	6aa2                	ld	s5,8(sp)
     496:	6b02                	ld	s6,0(sp)
     498:	6121                	addi	sp,sp,64
     49a:	8082                	ret
    switch (*s)
     49c:	03e00713          	li	a4,62
     4a0:	02e79163          	bne	a5,a4,4c2 <gettoken+0xe4>
        s++;
     4a4:	00148693          	addi	a3,s1,1
        if (*s == '>')
     4a8:	0014c703          	lbu	a4,1(s1)
     4ac:	03e00793          	li	a5,62
            s++;
     4b0:	0489                	addi	s1,s1,2
            ret = '+';
     4b2:	02b00a93          	li	s5,43
        if (*s == '>')
     4b6:	faf701e3          	beq	a4,a5,458 <gettoken+0x7a>
        s++;
     4ba:	84b6                	mv	s1,a3
    ret = *s;
     4bc:	03e00a93          	li	s5,62
     4c0:	bf61                	j	458 <gettoken+0x7a>
    switch (*s)
     4c2:	07c00713          	li	a4,124
     4c6:	f8e788e3          	beq	a5,a4,456 <gettoken+0x78>
        while (s < es && !strchr(whitespace, *s) && !strchr(symbols, *s))
     4ca:	00002997          	auipc	s3,0x2
     4ce:	b3e98993          	addi	s3,s3,-1218 # 2008 <whitespace>
     4d2:	00002a97          	auipc	s5,0x2
     4d6:	b2ea8a93          	addi	s5,s5,-1234 # 2000 <symbols>
     4da:	0324f563          	bgeu	s1,s2,504 <gettoken+0x126>
     4de:	0004c583          	lbu	a1,0(s1)
     4e2:	854e                	mv	a0,s3
     4e4:	00000097          	auipc	ra,0x0
     4e8:	7e8080e7          	jalr	2024(ra) # ccc <strchr>
     4ec:	e505                	bnez	a0,514 <gettoken+0x136>
     4ee:	0004c583          	lbu	a1,0(s1)
     4f2:	8556                	mv	a0,s5
     4f4:	00000097          	auipc	ra,0x0
     4f8:	7d8080e7          	jalr	2008(ra) # ccc <strchr>
     4fc:	e909                	bnez	a0,50e <gettoken+0x130>
            s++;
     4fe:	0485                	addi	s1,s1,1
        while (s < es && !strchr(whitespace, *s) && !strchr(symbols, *s))
     500:	fc991fe3          	bne	s2,s1,4de <gettoken+0x100>
    if (eq)
     504:	06100a93          	li	s5,97
     508:	f40b1ae3          	bnez	s6,45c <gettoken+0x7e>
     50c:	bf9d                	j	482 <gettoken+0xa4>
        ret = 'a';
     50e:	06100a93          	li	s5,97
     512:	b799                	j	458 <gettoken+0x7a>
     514:	06100a93          	li	s5,97
     518:	b781                	j	458 <gettoken+0x7a>

000000000000051a <peek>:

int peek(char **ps, char *es, char *toks)
{
     51a:	7139                	addi	sp,sp,-64
     51c:	fc06                	sd	ra,56(sp)
     51e:	f822                	sd	s0,48(sp)
     520:	f426                	sd	s1,40(sp)
     522:	f04a                	sd	s2,32(sp)
     524:	ec4e                	sd	s3,24(sp)
     526:	e852                	sd	s4,16(sp)
     528:	e456                	sd	s5,8(sp)
     52a:	0080                	addi	s0,sp,64
     52c:	8a2a                	mv	s4,a0
     52e:	892e                	mv	s2,a1
     530:	8ab2                	mv	s5,a2
    char *s;

    s = *ps;
     532:	6104                	ld	s1,0(a0)
    while (s < es && strchr(whitespace, *s))
     534:	00002997          	auipc	s3,0x2
     538:	ad498993          	addi	s3,s3,-1324 # 2008 <whitespace>
     53c:	00b4fd63          	bgeu	s1,a1,556 <peek+0x3c>
     540:	0004c583          	lbu	a1,0(s1)
     544:	854e                	mv	a0,s3
     546:	00000097          	auipc	ra,0x0
     54a:	786080e7          	jalr	1926(ra) # ccc <strchr>
     54e:	c501                	beqz	a0,556 <peek+0x3c>
        s++;
     550:	0485                	addi	s1,s1,1
    while (s < es && strchr(whitespace, *s))
     552:	fe9917e3          	bne	s2,s1,540 <peek+0x26>
    *ps = s;
     556:	009a3023          	sd	s1,0(s4)
    return *s && strchr(toks, *s);
     55a:	0004c583          	lbu	a1,0(s1)
     55e:	4501                	li	a0,0
     560:	e991                	bnez	a1,574 <peek+0x5a>
}
     562:	70e2                	ld	ra,56(sp)
     564:	7442                	ld	s0,48(sp)
     566:	74a2                	ld	s1,40(sp)
     568:	7902                	ld	s2,32(sp)
     56a:	69e2                	ld	s3,24(sp)
     56c:	6a42                	ld	s4,16(sp)
     56e:	6aa2                	ld	s5,8(sp)
     570:	6121                	addi	sp,sp,64
     572:	8082                	ret
    return *s && strchr(toks, *s);
     574:	8556                	mv	a0,s5
     576:	00000097          	auipc	ra,0x0
     57a:	756080e7          	jalr	1878(ra) # ccc <strchr>
     57e:	00a03533          	snez	a0,a0
     582:	b7c5                	j	562 <peek+0x48>

0000000000000584 <parseredirs>:
    return cmd;
}

struct cmd *
parseredirs(struct cmd *cmd, char **ps, char *es)
{
     584:	7159                	addi	sp,sp,-112
     586:	f486                	sd	ra,104(sp)
     588:	f0a2                	sd	s0,96(sp)
     58a:	eca6                	sd	s1,88(sp)
     58c:	e8ca                	sd	s2,80(sp)
     58e:	e4ce                	sd	s3,72(sp)
     590:	e0d2                	sd	s4,64(sp)
     592:	fc56                	sd	s5,56(sp)
     594:	f85a                	sd	s6,48(sp)
     596:	f45e                	sd	s7,40(sp)
     598:	f062                	sd	s8,32(sp)
     59a:	ec66                	sd	s9,24(sp)
     59c:	1880                	addi	s0,sp,112
     59e:	8a2a                	mv	s4,a0
     5a0:	89ae                	mv	s3,a1
     5a2:	8932                	mv	s2,a2
    int tok;
    char *q, *eq;

    while (peek(ps, es, "<>"))
     5a4:	00001b97          	auipc	s7,0x1
     5a8:	eb4b8b93          	addi	s7,s7,-332 # 1458 <malloc+0x150>
    {
        tok = gettoken(ps, es, 0, 0);
        if (gettoken(ps, es, &q, &eq) != 'a')
     5ac:	06100c13          	li	s8,97
            panic("missing file for redirection");
        switch (tok)
     5b0:	03c00c93          	li	s9,60
    while (peek(ps, es, "<>"))
     5b4:	a02d                	j	5de <parseredirs+0x5a>
            panic("missing file for redirection");
     5b6:	00001517          	auipc	a0,0x1
     5ba:	e8250513          	addi	a0,a0,-382 # 1438 <malloc+0x130>
     5be:	00000097          	auipc	ra,0x0
     5c2:	a98080e7          	jalr	-1384(ra) # 56 <panic>
        {
        case '<':
            cmd = redircmd(cmd, q, eq, O_RDONLY, 0);
     5c6:	4701                	li	a4,0
     5c8:	4681                	li	a3,0
     5ca:	f9043603          	ld	a2,-112(s0)
     5ce:	f9843583          	ld	a1,-104(s0)
     5d2:	8552                	mv	a0,s4
     5d4:	00000097          	auipc	ra,0x0
     5d8:	cda080e7          	jalr	-806(ra) # 2ae <redircmd>
     5dc:	8a2a                	mv	s4,a0
        switch (tok)
     5de:	03e00b13          	li	s6,62
     5e2:	02b00a93          	li	s5,43
    while (peek(ps, es, "<>"))
     5e6:	865e                	mv	a2,s7
     5e8:	85ca                	mv	a1,s2
     5ea:	854e                	mv	a0,s3
     5ec:	00000097          	auipc	ra,0x0
     5f0:	f2e080e7          	jalr	-210(ra) # 51a <peek>
     5f4:	c925                	beqz	a0,664 <parseredirs+0xe0>
        tok = gettoken(ps, es, 0, 0);
     5f6:	4681                	li	a3,0
     5f8:	4601                	li	a2,0
     5fa:	85ca                	mv	a1,s2
     5fc:	854e                	mv	a0,s3
     5fe:	00000097          	auipc	ra,0x0
     602:	de0080e7          	jalr	-544(ra) # 3de <gettoken>
     606:	84aa                	mv	s1,a0
        if (gettoken(ps, es, &q, &eq) != 'a')
     608:	f9040693          	addi	a3,s0,-112
     60c:	f9840613          	addi	a2,s0,-104
     610:	85ca                	mv	a1,s2
     612:	854e                	mv	a0,s3
     614:	00000097          	auipc	ra,0x0
     618:	dca080e7          	jalr	-566(ra) # 3de <gettoken>
     61c:	f9851de3          	bne	a0,s8,5b6 <parseredirs+0x32>
        switch (tok)
     620:	fb9483e3          	beq	s1,s9,5c6 <parseredirs+0x42>
     624:	03648263          	beq	s1,s6,648 <parseredirs+0xc4>
     628:	fb549fe3          	bne	s1,s5,5e6 <parseredirs+0x62>
            break;
        case '>':
            cmd = redircmd(cmd, q, eq, O_WRONLY | O_CREATE | O_TRUNC, 1);
            break;
        case '+': // >>
            cmd = redircmd(cmd, q, eq, O_WRONLY | O_CREATE, 1);
     62c:	4705                	li	a4,1
     62e:	20100693          	li	a3,513
     632:	f9043603          	ld	a2,-112(s0)
     636:	f9843583          	ld	a1,-104(s0)
     63a:	8552                	mv	a0,s4
     63c:	00000097          	auipc	ra,0x0
     640:	c72080e7          	jalr	-910(ra) # 2ae <redircmd>
     644:	8a2a                	mv	s4,a0
            break;
     646:	bf61                	j	5de <parseredirs+0x5a>
            cmd = redircmd(cmd, q, eq, O_WRONLY | O_CREATE | O_TRUNC, 1);
     648:	4705                	li	a4,1
     64a:	60100693          	li	a3,1537
     64e:	f9043603          	ld	a2,-112(s0)
     652:	f9843583          	ld	a1,-104(s0)
     656:	8552                	mv	a0,s4
     658:	00000097          	auipc	ra,0x0
     65c:	c56080e7          	jalr	-938(ra) # 2ae <redircmd>
     660:	8a2a                	mv	s4,a0
            break;
     662:	bfb5                	j	5de <parseredirs+0x5a>
        }
    }
    return cmd;
}
     664:	8552                	mv	a0,s4
     666:	70a6                	ld	ra,104(sp)
     668:	7406                	ld	s0,96(sp)
     66a:	64e6                	ld	s1,88(sp)
     66c:	6946                	ld	s2,80(sp)
     66e:	69a6                	ld	s3,72(sp)
     670:	6a06                	ld	s4,64(sp)
     672:	7ae2                	ld	s5,56(sp)
     674:	7b42                	ld	s6,48(sp)
     676:	7ba2                	ld	s7,40(sp)
     678:	7c02                	ld	s8,32(sp)
     67a:	6ce2                	ld	s9,24(sp)
     67c:	6165                	addi	sp,sp,112
     67e:	8082                	ret

0000000000000680 <parseexec>:
    return cmd;
}

struct cmd *
parseexec(char **ps, char *es)
{
     680:	7159                	addi	sp,sp,-112
     682:	f486                	sd	ra,104(sp)
     684:	f0a2                	sd	s0,96(sp)
     686:	eca6                	sd	s1,88(sp)
     688:	e8ca                	sd	s2,80(sp)
     68a:	e4ce                	sd	s3,72(sp)
     68c:	e0d2                	sd	s4,64(sp)
     68e:	fc56                	sd	s5,56(sp)
     690:	f85a                	sd	s6,48(sp)
     692:	f45e                	sd	s7,40(sp)
     694:	f062                	sd	s8,32(sp)
     696:	ec66                	sd	s9,24(sp)
     698:	1880                	addi	s0,sp,112
     69a:	8a2a                	mv	s4,a0
     69c:	8aae                	mv	s5,a1
    char *q, *eq;
    int tok, argc;
    struct execcmd *cmd;
    struct cmd *ret;

    if (peek(ps, es, "("))
     69e:	00001617          	auipc	a2,0x1
     6a2:	dc260613          	addi	a2,a2,-574 # 1460 <malloc+0x158>
     6a6:	00000097          	auipc	ra,0x0
     6aa:	e74080e7          	jalr	-396(ra) # 51a <peek>
     6ae:	e905                	bnez	a0,6de <parseexec+0x5e>
     6b0:	89aa                	mv	s3,a0
        return parseblock(ps, es);

    ret = execcmd();
     6b2:	00000097          	auipc	ra,0x0
     6b6:	bc6080e7          	jalr	-1082(ra) # 278 <execcmd>
     6ba:	8c2a                	mv	s8,a0
    cmd = (struct execcmd *)ret;

    argc = 0;
    ret = parseredirs(ret, ps, es);
     6bc:	8656                	mv	a2,s5
     6be:	85d2                	mv	a1,s4
     6c0:	00000097          	auipc	ra,0x0
     6c4:	ec4080e7          	jalr	-316(ra) # 584 <parseredirs>
     6c8:	84aa                	mv	s1,a0
    while (!peek(ps, es, "|)&;"))
     6ca:	008c0913          	addi	s2,s8,8
     6ce:	00001b17          	auipc	s6,0x1
     6d2:	db2b0b13          	addi	s6,s6,-590 # 1480 <malloc+0x178>
    {
        if ((tok = gettoken(ps, es, &q, &eq)) == 0)
            break;
        if (tok != 'a')
     6d6:	06100c93          	li	s9,97
            panic("syntax");
        cmd->argv[argc] = q;
        cmd->eargv[argc] = eq;
        argc++;
        if (argc >= MAXARGS)
     6da:	4ba9                	li	s7,10
    while (!peek(ps, es, "|)&;"))
     6dc:	a0b1                	j	728 <parseexec+0xa8>
        return parseblock(ps, es);
     6de:	85d6                	mv	a1,s5
     6e0:	8552                	mv	a0,s4
     6e2:	00000097          	auipc	ra,0x0
     6e6:	1bc080e7          	jalr	444(ra) # 89e <parseblock>
     6ea:	84aa                	mv	s1,a0
        ret = parseredirs(ret, ps, es);
    }
    cmd->argv[argc] = 0;
    cmd->eargv[argc] = 0;
    return ret;
}
     6ec:	8526                	mv	a0,s1
     6ee:	70a6                	ld	ra,104(sp)
     6f0:	7406                	ld	s0,96(sp)
     6f2:	64e6                	ld	s1,88(sp)
     6f4:	6946                	ld	s2,80(sp)
     6f6:	69a6                	ld	s3,72(sp)
     6f8:	6a06                	ld	s4,64(sp)
     6fa:	7ae2                	ld	s5,56(sp)
     6fc:	7b42                	ld	s6,48(sp)
     6fe:	7ba2                	ld	s7,40(sp)
     700:	7c02                	ld	s8,32(sp)
     702:	6ce2                	ld	s9,24(sp)
     704:	6165                	addi	sp,sp,112
     706:	8082                	ret
            panic("syntax");
     708:	00001517          	auipc	a0,0x1
     70c:	d6050513          	addi	a0,a0,-672 # 1468 <malloc+0x160>
     710:	00000097          	auipc	ra,0x0
     714:	946080e7          	jalr	-1722(ra) # 56 <panic>
        ret = parseredirs(ret, ps, es);
     718:	8656                	mv	a2,s5
     71a:	85d2                	mv	a1,s4
     71c:	8526                	mv	a0,s1
     71e:	00000097          	auipc	ra,0x0
     722:	e66080e7          	jalr	-410(ra) # 584 <parseredirs>
     726:	84aa                	mv	s1,a0
    while (!peek(ps, es, "|)&;"))
     728:	865a                	mv	a2,s6
     72a:	85d6                	mv	a1,s5
     72c:	8552                	mv	a0,s4
     72e:	00000097          	auipc	ra,0x0
     732:	dec080e7          	jalr	-532(ra) # 51a <peek>
     736:	e131                	bnez	a0,77a <parseexec+0xfa>
        if ((tok = gettoken(ps, es, &q, &eq)) == 0)
     738:	f9040693          	addi	a3,s0,-112
     73c:	f9840613          	addi	a2,s0,-104
     740:	85d6                	mv	a1,s5
     742:	8552                	mv	a0,s4
     744:	00000097          	auipc	ra,0x0
     748:	c9a080e7          	jalr	-870(ra) # 3de <gettoken>
     74c:	c51d                	beqz	a0,77a <parseexec+0xfa>
        if (tok != 'a')
     74e:	fb951de3          	bne	a0,s9,708 <parseexec+0x88>
        cmd->argv[argc] = q;
     752:	f9843783          	ld	a5,-104(s0)
     756:	00f93023          	sd	a5,0(s2)
        cmd->eargv[argc] = eq;
     75a:	f9043783          	ld	a5,-112(s0)
     75e:	04f93823          	sd	a5,80(s2)
        argc++;
     762:	2985                	addiw	s3,s3,1
        if (argc >= MAXARGS)
     764:	0921                	addi	s2,s2,8
     766:	fb7999e3          	bne	s3,s7,718 <parseexec+0x98>
            panic("too many args");
     76a:	00001517          	auipc	a0,0x1
     76e:	d0650513          	addi	a0,a0,-762 # 1470 <malloc+0x168>
     772:	00000097          	auipc	ra,0x0
     776:	8e4080e7          	jalr	-1820(ra) # 56 <panic>
    cmd->argv[argc] = 0;
     77a:	098e                	slli	s3,s3,0x3
     77c:	99e2                	add	s3,s3,s8
     77e:	0009b423          	sd	zero,8(s3)
    cmd->eargv[argc] = 0;
     782:	0409bc23          	sd	zero,88(s3)
    return ret;
     786:	b79d                	j	6ec <parseexec+0x6c>

0000000000000788 <parsepipe>:
{
     788:	7179                	addi	sp,sp,-48
     78a:	f406                	sd	ra,40(sp)
     78c:	f022                	sd	s0,32(sp)
     78e:	ec26                	sd	s1,24(sp)
     790:	e84a                	sd	s2,16(sp)
     792:	e44e                	sd	s3,8(sp)
     794:	1800                	addi	s0,sp,48
     796:	892a                	mv	s2,a0
     798:	89ae                	mv	s3,a1
    cmd = parseexec(ps, es);
     79a:	00000097          	auipc	ra,0x0
     79e:	ee6080e7          	jalr	-282(ra) # 680 <parseexec>
     7a2:	84aa                	mv	s1,a0
    if (peek(ps, es, "|"))
     7a4:	00001617          	auipc	a2,0x1
     7a8:	ce460613          	addi	a2,a2,-796 # 1488 <malloc+0x180>
     7ac:	85ce                	mv	a1,s3
     7ae:	854a                	mv	a0,s2
     7b0:	00000097          	auipc	ra,0x0
     7b4:	d6a080e7          	jalr	-662(ra) # 51a <peek>
     7b8:	e909                	bnez	a0,7ca <parsepipe+0x42>
}
     7ba:	8526                	mv	a0,s1
     7bc:	70a2                	ld	ra,40(sp)
     7be:	7402                	ld	s0,32(sp)
     7c0:	64e2                	ld	s1,24(sp)
     7c2:	6942                	ld	s2,16(sp)
     7c4:	69a2                	ld	s3,8(sp)
     7c6:	6145                	addi	sp,sp,48
     7c8:	8082                	ret
        gettoken(ps, es, 0, 0);
     7ca:	4681                	li	a3,0
     7cc:	4601                	li	a2,0
     7ce:	85ce                	mv	a1,s3
     7d0:	854a                	mv	a0,s2
     7d2:	00000097          	auipc	ra,0x0
     7d6:	c0c080e7          	jalr	-1012(ra) # 3de <gettoken>
        cmd = pipecmd(cmd, parsepipe(ps, es));
     7da:	85ce                	mv	a1,s3
     7dc:	854a                	mv	a0,s2
     7de:	00000097          	auipc	ra,0x0
     7e2:	faa080e7          	jalr	-86(ra) # 788 <parsepipe>
     7e6:	85aa                	mv	a1,a0
     7e8:	8526                	mv	a0,s1
     7ea:	00000097          	auipc	ra,0x0
     7ee:	b2c080e7          	jalr	-1236(ra) # 316 <pipecmd>
     7f2:	84aa                	mv	s1,a0
    return cmd;
     7f4:	b7d9                	j	7ba <parsepipe+0x32>

00000000000007f6 <parseline>:
{
     7f6:	7179                	addi	sp,sp,-48
     7f8:	f406                	sd	ra,40(sp)
     7fa:	f022                	sd	s0,32(sp)
     7fc:	ec26                	sd	s1,24(sp)
     7fe:	e84a                	sd	s2,16(sp)
     800:	e44e                	sd	s3,8(sp)
     802:	e052                	sd	s4,0(sp)
     804:	1800                	addi	s0,sp,48
     806:	892a                	mv	s2,a0
     808:	89ae                	mv	s3,a1
    cmd = parsepipe(ps, es);
     80a:	00000097          	auipc	ra,0x0
     80e:	f7e080e7          	jalr	-130(ra) # 788 <parsepipe>
     812:	84aa                	mv	s1,a0
    while (peek(ps, es, "&"))
     814:	00001a17          	auipc	s4,0x1
     818:	c7ca0a13          	addi	s4,s4,-900 # 1490 <malloc+0x188>
     81c:	8652                	mv	a2,s4
     81e:	85ce                	mv	a1,s3
     820:	854a                	mv	a0,s2
     822:	00000097          	auipc	ra,0x0
     826:	cf8080e7          	jalr	-776(ra) # 51a <peek>
     82a:	c105                	beqz	a0,84a <parseline+0x54>
        gettoken(ps, es, 0, 0);
     82c:	4681                	li	a3,0
     82e:	4601                	li	a2,0
     830:	85ce                	mv	a1,s3
     832:	854a                	mv	a0,s2
     834:	00000097          	auipc	ra,0x0
     838:	baa080e7          	jalr	-1110(ra) # 3de <gettoken>
        cmd = backcmd(cmd);
     83c:	8526                	mv	a0,s1
     83e:	00000097          	auipc	ra,0x0
     842:	b64080e7          	jalr	-1180(ra) # 3a2 <backcmd>
     846:	84aa                	mv	s1,a0
     848:	bfd1                	j	81c <parseline+0x26>
    if (peek(ps, es, ";"))
     84a:	00001617          	auipc	a2,0x1
     84e:	c4e60613          	addi	a2,a2,-946 # 1498 <malloc+0x190>
     852:	85ce                	mv	a1,s3
     854:	854a                	mv	a0,s2
     856:	00000097          	auipc	ra,0x0
     85a:	cc4080e7          	jalr	-828(ra) # 51a <peek>
     85e:	e911                	bnez	a0,872 <parseline+0x7c>
}
     860:	8526                	mv	a0,s1
     862:	70a2                	ld	ra,40(sp)
     864:	7402                	ld	s0,32(sp)
     866:	64e2                	ld	s1,24(sp)
     868:	6942                	ld	s2,16(sp)
     86a:	69a2                	ld	s3,8(sp)
     86c:	6a02                	ld	s4,0(sp)
     86e:	6145                	addi	sp,sp,48
     870:	8082                	ret
        gettoken(ps, es, 0, 0);
     872:	4681                	li	a3,0
     874:	4601                	li	a2,0
     876:	85ce                	mv	a1,s3
     878:	854a                	mv	a0,s2
     87a:	00000097          	auipc	ra,0x0
     87e:	b64080e7          	jalr	-1180(ra) # 3de <gettoken>
        cmd = listcmd(cmd, parseline(ps, es));
     882:	85ce                	mv	a1,s3
     884:	854a                	mv	a0,s2
     886:	00000097          	auipc	ra,0x0
     88a:	f70080e7          	jalr	-144(ra) # 7f6 <parseline>
     88e:	85aa                	mv	a1,a0
     890:	8526                	mv	a0,s1
     892:	00000097          	auipc	ra,0x0
     896:	aca080e7          	jalr	-1334(ra) # 35c <listcmd>
     89a:	84aa                	mv	s1,a0
    return cmd;
     89c:	b7d1                	j	860 <parseline+0x6a>

000000000000089e <parseblock>:
{
     89e:	7179                	addi	sp,sp,-48
     8a0:	f406                	sd	ra,40(sp)
     8a2:	f022                	sd	s0,32(sp)
     8a4:	ec26                	sd	s1,24(sp)
     8a6:	e84a                	sd	s2,16(sp)
     8a8:	e44e                	sd	s3,8(sp)
     8aa:	1800                	addi	s0,sp,48
     8ac:	84aa                	mv	s1,a0
     8ae:	892e                	mv	s2,a1
    if (!peek(ps, es, "("))
     8b0:	00001617          	auipc	a2,0x1
     8b4:	bb060613          	addi	a2,a2,-1104 # 1460 <malloc+0x158>
     8b8:	00000097          	auipc	ra,0x0
     8bc:	c62080e7          	jalr	-926(ra) # 51a <peek>
     8c0:	c12d                	beqz	a0,922 <parseblock+0x84>
    gettoken(ps, es, 0, 0);
     8c2:	4681                	li	a3,0
     8c4:	4601                	li	a2,0
     8c6:	85ca                	mv	a1,s2
     8c8:	8526                	mv	a0,s1
     8ca:	00000097          	auipc	ra,0x0
     8ce:	b14080e7          	jalr	-1260(ra) # 3de <gettoken>
    cmd = parseline(ps, es);
     8d2:	85ca                	mv	a1,s2
     8d4:	8526                	mv	a0,s1
     8d6:	00000097          	auipc	ra,0x0
     8da:	f20080e7          	jalr	-224(ra) # 7f6 <parseline>
     8de:	89aa                	mv	s3,a0
    if (!peek(ps, es, ")"))
     8e0:	00001617          	auipc	a2,0x1
     8e4:	bd060613          	addi	a2,a2,-1072 # 14b0 <malloc+0x1a8>
     8e8:	85ca                	mv	a1,s2
     8ea:	8526                	mv	a0,s1
     8ec:	00000097          	auipc	ra,0x0
     8f0:	c2e080e7          	jalr	-978(ra) # 51a <peek>
     8f4:	cd1d                	beqz	a0,932 <parseblock+0x94>
    gettoken(ps, es, 0, 0);
     8f6:	4681                	li	a3,0
     8f8:	4601                	li	a2,0
     8fa:	85ca                	mv	a1,s2
     8fc:	8526                	mv	a0,s1
     8fe:	00000097          	auipc	ra,0x0
     902:	ae0080e7          	jalr	-1312(ra) # 3de <gettoken>
    cmd = parseredirs(cmd, ps, es);
     906:	864a                	mv	a2,s2
     908:	85a6                	mv	a1,s1
     90a:	854e                	mv	a0,s3
     90c:	00000097          	auipc	ra,0x0
     910:	c78080e7          	jalr	-904(ra) # 584 <parseredirs>
}
     914:	70a2                	ld	ra,40(sp)
     916:	7402                	ld	s0,32(sp)
     918:	64e2                	ld	s1,24(sp)
     91a:	6942                	ld	s2,16(sp)
     91c:	69a2                	ld	s3,8(sp)
     91e:	6145                	addi	sp,sp,48
     920:	8082                	ret
        panic("parseblock");
     922:	00001517          	auipc	a0,0x1
     926:	b7e50513          	addi	a0,a0,-1154 # 14a0 <malloc+0x198>
     92a:	fffff097          	auipc	ra,0xfffff
     92e:	72c080e7          	jalr	1836(ra) # 56 <panic>
        panic("syntax - missing )");
     932:	00001517          	auipc	a0,0x1
     936:	b8650513          	addi	a0,a0,-1146 # 14b8 <malloc+0x1b0>
     93a:	fffff097          	auipc	ra,0xfffff
     93e:	71c080e7          	jalr	1820(ra) # 56 <panic>

0000000000000942 <nulterminate>:

// NUL-terminate all the counted strings.
struct cmd *
nulterminate(struct cmd *cmd)
{
     942:	1101                	addi	sp,sp,-32
     944:	ec06                	sd	ra,24(sp)
     946:	e822                	sd	s0,16(sp)
     948:	e426                	sd	s1,8(sp)
     94a:	1000                	addi	s0,sp,32
     94c:	84aa                	mv	s1,a0
    struct execcmd *ecmd;
    struct listcmd *lcmd;
    struct pipecmd *pcmd;
    struct redircmd *rcmd;

    if (cmd == 0)
     94e:	c521                	beqz	a0,996 <nulterminate+0x54>
        return 0;

    switch (cmd->type)
     950:	4118                	lw	a4,0(a0)
     952:	4795                	li	a5,5
     954:	04e7e163          	bltu	a5,a4,996 <nulterminate+0x54>
     958:	00056783          	lwu	a5,0(a0)
     95c:	078a                	slli	a5,a5,0x2
     95e:	00001717          	auipc	a4,0x1
     962:	bce70713          	addi	a4,a4,-1074 # 152c <malloc+0x224>
     966:	97ba                	add	a5,a5,a4
     968:	439c                	lw	a5,0(a5)
     96a:	97ba                	add	a5,a5,a4
     96c:	8782                	jr	a5
    {
    case EXEC:
        ecmd = (struct execcmd *)cmd;
        for (i = 0; ecmd->argv[i]; i++)
     96e:	651c                	ld	a5,8(a0)
     970:	c39d                	beqz	a5,996 <nulterminate+0x54>
     972:	01050793          	addi	a5,a0,16
            *ecmd->eargv[i] = 0;
     976:	67b8                	ld	a4,72(a5)
     978:	00070023          	sb	zero,0(a4)
        for (i = 0; ecmd->argv[i]; i++)
     97c:	07a1                	addi	a5,a5,8
     97e:	ff87b703          	ld	a4,-8(a5)
     982:	fb75                	bnez	a4,976 <nulterminate+0x34>
     984:	a809                	j	996 <nulterminate+0x54>
        break;

    case REDIR:
        rcmd = (struct redircmd *)cmd;
        nulterminate(rcmd->cmd);
     986:	6508                	ld	a0,8(a0)
     988:	00000097          	auipc	ra,0x0
     98c:	fba080e7          	jalr	-70(ra) # 942 <nulterminate>
        *rcmd->efile = 0;
     990:	6c9c                	ld	a5,24(s1)
     992:	00078023          	sb	zero,0(a5)
        bcmd = (struct backcmd *)cmd;
        nulterminate(bcmd->cmd);
        break;
    }
    return cmd;
}
     996:	8526                	mv	a0,s1
     998:	60e2                	ld	ra,24(sp)
     99a:	6442                	ld	s0,16(sp)
     99c:	64a2                	ld	s1,8(sp)
     99e:	6105                	addi	sp,sp,32
     9a0:	8082                	ret
        nulterminate(pcmd->left);
     9a2:	6508                	ld	a0,8(a0)
     9a4:	00000097          	auipc	ra,0x0
     9a8:	f9e080e7          	jalr	-98(ra) # 942 <nulterminate>
        nulterminate(pcmd->right);
     9ac:	6888                	ld	a0,16(s1)
     9ae:	00000097          	auipc	ra,0x0
     9b2:	f94080e7          	jalr	-108(ra) # 942 <nulterminate>
        break;
     9b6:	b7c5                	j	996 <nulterminate+0x54>
        nulterminate(lcmd->left);
     9b8:	6508                	ld	a0,8(a0)
     9ba:	00000097          	auipc	ra,0x0
     9be:	f88080e7          	jalr	-120(ra) # 942 <nulterminate>
        nulterminate(lcmd->right);
     9c2:	6888                	ld	a0,16(s1)
     9c4:	00000097          	auipc	ra,0x0
     9c8:	f7e080e7          	jalr	-130(ra) # 942 <nulterminate>
        break;
     9cc:	b7e9                	j	996 <nulterminate+0x54>
        nulterminate(bcmd->cmd);
     9ce:	6508                	ld	a0,8(a0)
     9d0:	00000097          	auipc	ra,0x0
     9d4:	f72080e7          	jalr	-142(ra) # 942 <nulterminate>
        break;
     9d8:	bf7d                	j	996 <nulterminate+0x54>

00000000000009da <parsecmd>:
{
     9da:	7179                	addi	sp,sp,-48
     9dc:	f406                	sd	ra,40(sp)
     9de:	f022                	sd	s0,32(sp)
     9e0:	ec26                	sd	s1,24(sp)
     9e2:	e84a                	sd	s2,16(sp)
     9e4:	1800                	addi	s0,sp,48
     9e6:	fca43c23          	sd	a0,-40(s0)
    es = s + strlen(s);
     9ea:	84aa                	mv	s1,a0
     9ec:	00000097          	auipc	ra,0x0
     9f0:	290080e7          	jalr	656(ra) # c7c <strlen>
     9f4:	1502                	slli	a0,a0,0x20
     9f6:	9101                	srli	a0,a0,0x20
     9f8:	94aa                	add	s1,s1,a0
    cmd = parseline(&s, es);
     9fa:	85a6                	mv	a1,s1
     9fc:	fd840513          	addi	a0,s0,-40
     a00:	00000097          	auipc	ra,0x0
     a04:	df6080e7          	jalr	-522(ra) # 7f6 <parseline>
     a08:	892a                	mv	s2,a0
    peek(&s, es, "");
     a0a:	00001617          	auipc	a2,0x1
     a0e:	ac660613          	addi	a2,a2,-1338 # 14d0 <malloc+0x1c8>
     a12:	85a6                	mv	a1,s1
     a14:	fd840513          	addi	a0,s0,-40
     a18:	00000097          	auipc	ra,0x0
     a1c:	b02080e7          	jalr	-1278(ra) # 51a <peek>
    if (s != es)
     a20:	fd843603          	ld	a2,-40(s0)
     a24:	00961e63          	bne	a2,s1,a40 <parsecmd+0x66>
    nulterminate(cmd);
     a28:	854a                	mv	a0,s2
     a2a:	00000097          	auipc	ra,0x0
     a2e:	f18080e7          	jalr	-232(ra) # 942 <nulterminate>
}
     a32:	854a                	mv	a0,s2
     a34:	70a2                	ld	ra,40(sp)
     a36:	7402                	ld	s0,32(sp)
     a38:	64e2                	ld	s1,24(sp)
     a3a:	6942                	ld	s2,16(sp)
     a3c:	6145                	addi	sp,sp,48
     a3e:	8082                	ret
        fprintf(2, "leftovers: %s\n", s);
     a40:	00001597          	auipc	a1,0x1
     a44:	a9858593          	addi	a1,a1,-1384 # 14d8 <malloc+0x1d0>
     a48:	4509                	li	a0,2
     a4a:	00000097          	auipc	ra,0x0
     a4e:	7d2080e7          	jalr	2002(ra) # 121c <fprintf>
        panic("syntax");
     a52:	00001517          	auipc	a0,0x1
     a56:	a1650513          	addi	a0,a0,-1514 # 1468 <malloc+0x160>
     a5a:	fffff097          	auipc	ra,0xfffff
     a5e:	5fc080e7          	jalr	1532(ra) # 56 <panic>

0000000000000a62 <parse_buffer>:
{
     a62:	1101                	addi	sp,sp,-32
     a64:	ec06                	sd	ra,24(sp)
     a66:	e822                	sd	s0,16(sp)
     a68:	e426                	sd	s1,8(sp)
     a6a:	1000                	addi	s0,sp,32
     a6c:	84aa                	mv	s1,a0
    if (buf[0] == 'c' && buf[1] == 'd' && buf[2] == ' ')
     a6e:	00054783          	lbu	a5,0(a0)
     a72:	06300713          	li	a4,99
     a76:	02e78b63          	beq	a5,a4,aac <parse_buffer+0x4a>
    if (buf[0] == 'e' &&
     a7a:	06500713          	li	a4,101
     a7e:	00e79863          	bne	a5,a4,a8e <parse_buffer+0x2c>
     a82:	00154703          	lbu	a4,1(a0)
     a86:	07800793          	li	a5,120
     a8a:	06f70b63          	beq	a4,a5,b00 <parse_buffer+0x9e>
    if (fork1() == 0)
     a8e:	fffff097          	auipc	ra,0xfffff
     a92:	5ee080e7          	jalr	1518(ra) # 7c <fork1>
     a96:	c551                	beqz	a0,b22 <parse_buffer+0xc0>
    wait(0);
     a98:	4501                	li	a0,0
     a9a:	00000097          	auipc	ra,0x0
     a9e:	418080e7          	jalr	1048(ra) # eb2 <wait>
}
     aa2:	60e2                	ld	ra,24(sp)
     aa4:	6442                	ld	s0,16(sp)
     aa6:	64a2                	ld	s1,8(sp)
     aa8:	6105                	addi	sp,sp,32
     aaa:	8082                	ret
    if (buf[0] == 'c' && buf[1] == 'd' && buf[2] == ' ')
     aac:	00154703          	lbu	a4,1(a0)
     ab0:	06400793          	li	a5,100
     ab4:	fcf71de3          	bne	a4,a5,a8e <parse_buffer+0x2c>
     ab8:	00254703          	lbu	a4,2(a0)
     abc:	02000793          	li	a5,32
     ac0:	fcf717e3          	bne	a4,a5,a8e <parse_buffer+0x2c>
        buf[strlen(buf) - 1] = 0; // chop \n
     ac4:	00000097          	auipc	ra,0x0
     ac8:	1b8080e7          	jalr	440(ra) # c7c <strlen>
     acc:	fff5079b          	addiw	a5,a0,-1
     ad0:	1782                	slli	a5,a5,0x20
     ad2:	9381                	srli	a5,a5,0x20
     ad4:	97a6                	add	a5,a5,s1
     ad6:	00078023          	sb	zero,0(a5)
        if (chdir(buf + 3) < 0)
     ada:	048d                	addi	s1,s1,3
     adc:	8526                	mv	a0,s1
     ade:	00000097          	auipc	ra,0x0
     ae2:	43c080e7          	jalr	1084(ra) # f1a <chdir>
     ae6:	fa055ee3          	bgez	a0,aa2 <parse_buffer+0x40>
            fprintf(2, "cannot cd %s\n", buf + 3);
     aea:	8626                	mv	a2,s1
     aec:	00001597          	auipc	a1,0x1
     af0:	9fc58593          	addi	a1,a1,-1540 # 14e8 <malloc+0x1e0>
     af4:	4509                	li	a0,2
     af6:	00000097          	auipc	ra,0x0
     afa:	726080e7          	jalr	1830(ra) # 121c <fprintf>
     afe:	b755                	j	aa2 <parse_buffer+0x40>
        buf[1] == 'x' &&
     b00:	00254703          	lbu	a4,2(a0)
     b04:	06900793          	li	a5,105
     b08:	f8f713e3          	bne	a4,a5,a8e <parse_buffer+0x2c>
        buf[2] == 'i' &&
     b0c:	00354703          	lbu	a4,3(a0)
     b10:	07400793          	li	a5,116
     b14:	f6f71de3          	bne	a4,a5,a8e <parse_buffer+0x2c>
        exit(0);
     b18:	4501                	li	a0,0
     b1a:	00000097          	auipc	ra,0x0
     b1e:	390080e7          	jalr	912(ra) # eaa <exit>
        runcmd(parsecmd(buf));
     b22:	8526                	mv	a0,s1
     b24:	00000097          	auipc	ra,0x0
     b28:	eb6080e7          	jalr	-330(ra) # 9da <parsecmd>
     b2c:	fffff097          	auipc	ra,0xfffff
     b30:	57e080e7          	jalr	1406(ra) # aa <runcmd>

0000000000000b34 <main>:
{
     b34:	7179                	addi	sp,sp,-48
     b36:	f406                	sd	ra,40(sp)
     b38:	f022                	sd	s0,32(sp)
     b3a:	ec26                	sd	s1,24(sp)
     b3c:	e84a                	sd	s2,16(sp)
     b3e:	e44e                	sd	s3,8(sp)
     b40:	1800                	addi	s0,sp,48
     b42:	892a                	mv	s2,a0
     b44:	89ae                	mv	s3,a1
    while ((fd = open("console", O_RDWR)) >= 0)
     b46:	00001497          	auipc	s1,0x1
     b4a:	9b248493          	addi	s1,s1,-1614 # 14f8 <malloc+0x1f0>
     b4e:	4589                	li	a1,2
     b50:	8526                	mv	a0,s1
     b52:	00000097          	auipc	ra,0x0
     b56:	398080e7          	jalr	920(ra) # eea <open>
     b5a:	00054963          	bltz	a0,b6c <main+0x38>
        if (fd >= 3)
     b5e:	4789                	li	a5,2
     b60:	fea7d7e3          	bge	a5,a0,b4e <main+0x1a>
            close(fd);
     b64:	00000097          	auipc	ra,0x0
     b68:	36e080e7          	jalr	878(ra) # ed2 <close>
    if (argc == 2)
     b6c:	4789                	li	a5,2
    while (getcmd(buf, sizeof(buf)) >= 0)
     b6e:	00001497          	auipc	s1,0x1
     b72:	4b248493          	addi	s1,s1,1202 # 2020 <buf.1164>
    if (argc == 2)
     b76:	08f91463          	bne	s2,a5,bfe <main+0xca>
        char *shell_script_file = argv[1];
     b7a:	0089b483          	ld	s1,8(s3)
        int shfd = open(shell_script_file, O_RDWR);
     b7e:	4589                	li	a1,2
     b80:	8526                	mv	a0,s1
     b82:	00000097          	auipc	ra,0x0
     b86:	368080e7          	jalr	872(ra) # eea <open>
     b8a:	892a                	mv	s2,a0
        if (shfd < 0)
     b8c:	04054663          	bltz	a0,bd8 <main+0xa4>
        read(shfd, buf, sizeof(buf));
     b90:	07800613          	li	a2,120
     b94:	00001597          	auipc	a1,0x1
     b98:	48c58593          	addi	a1,a1,1164 # 2020 <buf.1164>
     b9c:	00000097          	auipc	ra,0x0
     ba0:	326080e7          	jalr	806(ra) # ec2 <read>
            parse_buffer(buf);
     ba4:	00001497          	auipc	s1,0x1
     ba8:	47c48493          	addi	s1,s1,1148 # 2020 <buf.1164>
     bac:	8526                	mv	a0,s1
     bae:	00000097          	auipc	ra,0x0
     bb2:	eb4080e7          	jalr	-332(ra) # a62 <parse_buffer>
        } while (read(shfd, buf, sizeof(buf)) == sizeof(buf));
     bb6:	07800613          	li	a2,120
     bba:	85a6                	mv	a1,s1
     bbc:	854a                	mv	a0,s2
     bbe:	00000097          	auipc	ra,0x0
     bc2:	304080e7          	jalr	772(ra) # ec2 <read>
     bc6:	07800793          	li	a5,120
     bca:	fef501e3          	beq	a0,a5,bac <main+0x78>
        exit(0);
     bce:	4501                	li	a0,0
     bd0:	00000097          	auipc	ra,0x0
     bd4:	2da080e7          	jalr	730(ra) # eaa <exit>
            printf("Failed to open %s\n", shell_script_file);
     bd8:	85a6                	mv	a1,s1
     bda:	00001517          	auipc	a0,0x1
     bde:	92650513          	addi	a0,a0,-1754 # 1500 <malloc+0x1f8>
     be2:	00000097          	auipc	ra,0x0
     be6:	668080e7          	jalr	1640(ra) # 124a <printf>
            exit(1);
     bea:	4505                	li	a0,1
     bec:	00000097          	auipc	ra,0x0
     bf0:	2be080e7          	jalr	702(ra) # eaa <exit>
        parse_buffer(buf);
     bf4:	8526                	mv	a0,s1
     bf6:	00000097          	auipc	ra,0x0
     bfa:	e6c080e7          	jalr	-404(ra) # a62 <parse_buffer>
    while (getcmd(buf, sizeof(buf)) >= 0)
     bfe:	07800593          	li	a1,120
     c02:	8526                	mv	a0,s1
     c04:	fffff097          	auipc	ra,0xfffff
     c08:	3fc080e7          	jalr	1020(ra) # 0 <getcmd>
     c0c:	fe0554e3          	bgez	a0,bf4 <main+0xc0>
    exit(0);
     c10:	4501                	li	a0,0
     c12:	00000097          	auipc	ra,0x0
     c16:	298080e7          	jalr	664(ra) # eaa <exit>

0000000000000c1a <_main>:
//
// wrapper so that it's OK if main() does not call exit().
//
void
_main()
{
     c1a:	1141                	addi	sp,sp,-16
     c1c:	e406                	sd	ra,8(sp)
     c1e:	e022                	sd	s0,0(sp)
     c20:	0800                	addi	s0,sp,16
  extern int main();
  main();
     c22:	00000097          	auipc	ra,0x0
     c26:	f12080e7          	jalr	-238(ra) # b34 <main>
  exit(0);
     c2a:	4501                	li	a0,0
     c2c:	00000097          	auipc	ra,0x0
     c30:	27e080e7          	jalr	638(ra) # eaa <exit>

0000000000000c34 <strcpy>:
}

char*
strcpy(char *s, const char *t)
{
     c34:	1141                	addi	sp,sp,-16
     c36:	e422                	sd	s0,8(sp)
     c38:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
     c3a:	87aa                	mv	a5,a0
     c3c:	0585                	addi	a1,a1,1
     c3e:	0785                	addi	a5,a5,1
     c40:	fff5c703          	lbu	a4,-1(a1)
     c44:	fee78fa3          	sb	a4,-1(a5)
     c48:	fb75                	bnez	a4,c3c <strcpy+0x8>
    ;
  return os;
}
     c4a:	6422                	ld	s0,8(sp)
     c4c:	0141                	addi	sp,sp,16
     c4e:	8082                	ret

0000000000000c50 <strcmp>:

int
strcmp(const char *p, const char *q)
{
     c50:	1141                	addi	sp,sp,-16
     c52:	e422                	sd	s0,8(sp)
     c54:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
     c56:	00054783          	lbu	a5,0(a0)
     c5a:	cb91                	beqz	a5,c6e <strcmp+0x1e>
     c5c:	0005c703          	lbu	a4,0(a1)
     c60:	00f71763          	bne	a4,a5,c6e <strcmp+0x1e>
    p++, q++;
     c64:	0505                	addi	a0,a0,1
     c66:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
     c68:	00054783          	lbu	a5,0(a0)
     c6c:	fbe5                	bnez	a5,c5c <strcmp+0xc>
  return (uchar)*p - (uchar)*q;
     c6e:	0005c503          	lbu	a0,0(a1)
}
     c72:	40a7853b          	subw	a0,a5,a0
     c76:	6422                	ld	s0,8(sp)
     c78:	0141                	addi	sp,sp,16
     c7a:	8082                	ret

0000000000000c7c <strlen>:

uint
strlen(const char *s)
{
     c7c:	1141                	addi	sp,sp,-16
     c7e:	e422                	sd	s0,8(sp)
     c80:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
     c82:	00054783          	lbu	a5,0(a0)
     c86:	cf91                	beqz	a5,ca2 <strlen+0x26>
     c88:	0505                	addi	a0,a0,1
     c8a:	87aa                	mv	a5,a0
     c8c:	4685                	li	a3,1
     c8e:	9e89                	subw	a3,a3,a0
     c90:	00f6853b          	addw	a0,a3,a5
     c94:	0785                	addi	a5,a5,1
     c96:	fff7c703          	lbu	a4,-1(a5)
     c9a:	fb7d                	bnez	a4,c90 <strlen+0x14>
    ;
  return n;
}
     c9c:	6422                	ld	s0,8(sp)
     c9e:	0141                	addi	sp,sp,16
     ca0:	8082                	ret
  for(n = 0; s[n]; n++)
     ca2:	4501                	li	a0,0
     ca4:	bfe5                	j	c9c <strlen+0x20>

0000000000000ca6 <memset>:

void*
memset(void *dst, int c, uint n)
{
     ca6:	1141                	addi	sp,sp,-16
     ca8:	e422                	sd	s0,8(sp)
     caa:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
     cac:	ce09                	beqz	a2,cc6 <memset+0x20>
     cae:	87aa                	mv	a5,a0
     cb0:	fff6071b          	addiw	a4,a2,-1
     cb4:	1702                	slli	a4,a4,0x20
     cb6:	9301                	srli	a4,a4,0x20
     cb8:	0705                	addi	a4,a4,1
     cba:	972a                	add	a4,a4,a0
    cdst[i] = c;
     cbc:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
     cc0:	0785                	addi	a5,a5,1
     cc2:	fee79de3          	bne	a5,a4,cbc <memset+0x16>
  }
  return dst;
}
     cc6:	6422                	ld	s0,8(sp)
     cc8:	0141                	addi	sp,sp,16
     cca:	8082                	ret

0000000000000ccc <strchr>:

char*
strchr(const char *s, char c)
{
     ccc:	1141                	addi	sp,sp,-16
     cce:	e422                	sd	s0,8(sp)
     cd0:	0800                	addi	s0,sp,16
  for(; *s; s++)
     cd2:	00054783          	lbu	a5,0(a0)
     cd6:	cb99                	beqz	a5,cec <strchr+0x20>
    if(*s == c)
     cd8:	00f58763          	beq	a1,a5,ce6 <strchr+0x1a>
  for(; *s; s++)
     cdc:	0505                	addi	a0,a0,1
     cde:	00054783          	lbu	a5,0(a0)
     ce2:	fbfd                	bnez	a5,cd8 <strchr+0xc>
      return (char*)s;
  return 0;
     ce4:	4501                	li	a0,0
}
     ce6:	6422                	ld	s0,8(sp)
     ce8:	0141                	addi	sp,sp,16
     cea:	8082                	ret
  return 0;
     cec:	4501                	li	a0,0
     cee:	bfe5                	j	ce6 <strchr+0x1a>

0000000000000cf0 <gets>:

char*
gets(char *buf, int max)
{
     cf0:	711d                	addi	sp,sp,-96
     cf2:	ec86                	sd	ra,88(sp)
     cf4:	e8a2                	sd	s0,80(sp)
     cf6:	e4a6                	sd	s1,72(sp)
     cf8:	e0ca                	sd	s2,64(sp)
     cfa:	fc4e                	sd	s3,56(sp)
     cfc:	f852                	sd	s4,48(sp)
     cfe:	f456                	sd	s5,40(sp)
     d00:	f05a                	sd	s6,32(sp)
     d02:	ec5e                	sd	s7,24(sp)
     d04:	1080                	addi	s0,sp,96
     d06:	8baa                	mv	s7,a0
     d08:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
     d0a:	892a                	mv	s2,a0
     d0c:	4481                	li	s1,0
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
     d0e:	4aa9                	li	s5,10
     d10:	4b35                	li	s6,13
  for(i=0; i+1 < max; ){
     d12:	89a6                	mv	s3,s1
     d14:	2485                	addiw	s1,s1,1
     d16:	0344d863          	bge	s1,s4,d46 <gets+0x56>
    cc = read(0, &c, 1);
     d1a:	4605                	li	a2,1
     d1c:	faf40593          	addi	a1,s0,-81
     d20:	4501                	li	a0,0
     d22:	00000097          	auipc	ra,0x0
     d26:	1a0080e7          	jalr	416(ra) # ec2 <read>
    if(cc < 1)
     d2a:	00a05e63          	blez	a0,d46 <gets+0x56>
    buf[i++] = c;
     d2e:	faf44783          	lbu	a5,-81(s0)
     d32:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
     d36:	01578763          	beq	a5,s5,d44 <gets+0x54>
     d3a:	0905                	addi	s2,s2,1
     d3c:	fd679be3          	bne	a5,s6,d12 <gets+0x22>
  for(i=0; i+1 < max; ){
     d40:	89a6                	mv	s3,s1
     d42:	a011                	j	d46 <gets+0x56>
     d44:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
     d46:	99de                	add	s3,s3,s7
     d48:	00098023          	sb	zero,0(s3)
  return buf;
}
     d4c:	855e                	mv	a0,s7
     d4e:	60e6                	ld	ra,88(sp)
     d50:	6446                	ld	s0,80(sp)
     d52:	64a6                	ld	s1,72(sp)
     d54:	6906                	ld	s2,64(sp)
     d56:	79e2                	ld	s3,56(sp)
     d58:	7a42                	ld	s4,48(sp)
     d5a:	7aa2                	ld	s5,40(sp)
     d5c:	7b02                	ld	s6,32(sp)
     d5e:	6be2                	ld	s7,24(sp)
     d60:	6125                	addi	sp,sp,96
     d62:	8082                	ret

0000000000000d64 <stat>:

int
stat(const char *n, struct stat *st)
{
     d64:	1101                	addi	sp,sp,-32
     d66:	ec06                	sd	ra,24(sp)
     d68:	e822                	sd	s0,16(sp)
     d6a:	e426                	sd	s1,8(sp)
     d6c:	e04a                	sd	s2,0(sp)
     d6e:	1000                	addi	s0,sp,32
     d70:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
     d72:	4581                	li	a1,0
     d74:	00000097          	auipc	ra,0x0
     d78:	176080e7          	jalr	374(ra) # eea <open>
  if(fd < 0)
     d7c:	02054563          	bltz	a0,da6 <stat+0x42>
     d80:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
     d82:	85ca                	mv	a1,s2
     d84:	00000097          	auipc	ra,0x0
     d88:	17e080e7          	jalr	382(ra) # f02 <fstat>
     d8c:	892a                	mv	s2,a0
  close(fd);
     d8e:	8526                	mv	a0,s1
     d90:	00000097          	auipc	ra,0x0
     d94:	142080e7          	jalr	322(ra) # ed2 <close>
  return r;
}
     d98:	854a                	mv	a0,s2
     d9a:	60e2                	ld	ra,24(sp)
     d9c:	6442                	ld	s0,16(sp)
     d9e:	64a2                	ld	s1,8(sp)
     da0:	6902                	ld	s2,0(sp)
     da2:	6105                	addi	sp,sp,32
     da4:	8082                	ret
    return -1;
     da6:	597d                	li	s2,-1
     da8:	bfc5                	j	d98 <stat+0x34>

0000000000000daa <atoi>:

int
atoi(const char *s)
{
     daa:	1141                	addi	sp,sp,-16
     dac:	e422                	sd	s0,8(sp)
     dae:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
     db0:	00054603          	lbu	a2,0(a0)
     db4:	fd06079b          	addiw	a5,a2,-48
     db8:	0ff7f793          	andi	a5,a5,255
     dbc:	4725                	li	a4,9
     dbe:	02f76963          	bltu	a4,a5,df0 <atoi+0x46>
     dc2:	86aa                	mv	a3,a0
  n = 0;
     dc4:	4501                	li	a0,0
  while('0' <= *s && *s <= '9')
     dc6:	45a5                	li	a1,9
    n = n*10 + *s++ - '0';
     dc8:	0685                	addi	a3,a3,1
     dca:	0025179b          	slliw	a5,a0,0x2
     dce:	9fa9                	addw	a5,a5,a0
     dd0:	0017979b          	slliw	a5,a5,0x1
     dd4:	9fb1                	addw	a5,a5,a2
     dd6:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
     dda:	0006c603          	lbu	a2,0(a3)
     dde:	fd06071b          	addiw	a4,a2,-48
     de2:	0ff77713          	andi	a4,a4,255
     de6:	fee5f1e3          	bgeu	a1,a4,dc8 <atoi+0x1e>
  return n;
}
     dea:	6422                	ld	s0,8(sp)
     dec:	0141                	addi	sp,sp,16
     dee:	8082                	ret
  n = 0;
     df0:	4501                	li	a0,0
     df2:	bfe5                	j	dea <atoi+0x40>

0000000000000df4 <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
     df4:	1141                	addi	sp,sp,-16
     df6:	e422                	sd	s0,8(sp)
     df8:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
     dfa:	02b57663          	bgeu	a0,a1,e26 <memmove+0x32>
    while(n-- > 0)
     dfe:	02c05163          	blez	a2,e20 <memmove+0x2c>
     e02:	fff6079b          	addiw	a5,a2,-1
     e06:	1782                	slli	a5,a5,0x20
     e08:	9381                	srli	a5,a5,0x20
     e0a:	0785                	addi	a5,a5,1
     e0c:	97aa                	add	a5,a5,a0
  dst = vdst;
     e0e:	872a                	mv	a4,a0
      *dst++ = *src++;
     e10:	0585                	addi	a1,a1,1
     e12:	0705                	addi	a4,a4,1
     e14:	fff5c683          	lbu	a3,-1(a1)
     e18:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
     e1c:	fee79ae3          	bne	a5,a4,e10 <memmove+0x1c>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
     e20:	6422                	ld	s0,8(sp)
     e22:	0141                	addi	sp,sp,16
     e24:	8082                	ret
    dst += n;
     e26:	00c50733          	add	a4,a0,a2
    src += n;
     e2a:	95b2                	add	a1,a1,a2
    while(n-- > 0)
     e2c:	fec05ae3          	blez	a2,e20 <memmove+0x2c>
     e30:	fff6079b          	addiw	a5,a2,-1
     e34:	1782                	slli	a5,a5,0x20
     e36:	9381                	srli	a5,a5,0x20
     e38:	fff7c793          	not	a5,a5
     e3c:	97ba                	add	a5,a5,a4
      *--dst = *--src;
     e3e:	15fd                	addi	a1,a1,-1
     e40:	177d                	addi	a4,a4,-1
     e42:	0005c683          	lbu	a3,0(a1)
     e46:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
     e4a:	fee79ae3          	bne	a5,a4,e3e <memmove+0x4a>
     e4e:	bfc9                	j	e20 <memmove+0x2c>

0000000000000e50 <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
     e50:	1141                	addi	sp,sp,-16
     e52:	e422                	sd	s0,8(sp)
     e54:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
     e56:	ca05                	beqz	a2,e86 <memcmp+0x36>
     e58:	fff6069b          	addiw	a3,a2,-1
     e5c:	1682                	slli	a3,a3,0x20
     e5e:	9281                	srli	a3,a3,0x20
     e60:	0685                	addi	a3,a3,1
     e62:	96aa                	add	a3,a3,a0
    if (*p1 != *p2) {
     e64:	00054783          	lbu	a5,0(a0)
     e68:	0005c703          	lbu	a4,0(a1)
     e6c:	00e79863          	bne	a5,a4,e7c <memcmp+0x2c>
      return *p1 - *p2;
    }
    p1++;
     e70:	0505                	addi	a0,a0,1
    p2++;
     e72:	0585                	addi	a1,a1,1
  while (n-- > 0) {
     e74:	fed518e3          	bne	a0,a3,e64 <memcmp+0x14>
  }
  return 0;
     e78:	4501                	li	a0,0
     e7a:	a019                	j	e80 <memcmp+0x30>
      return *p1 - *p2;
     e7c:	40e7853b          	subw	a0,a5,a4
}
     e80:	6422                	ld	s0,8(sp)
     e82:	0141                	addi	sp,sp,16
     e84:	8082                	ret
  return 0;
     e86:	4501                	li	a0,0
     e88:	bfe5                	j	e80 <memcmp+0x30>

0000000000000e8a <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
     e8a:	1141                	addi	sp,sp,-16
     e8c:	e406                	sd	ra,8(sp)
     e8e:	e022                	sd	s0,0(sp)
     e90:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
     e92:	00000097          	auipc	ra,0x0
     e96:	f62080e7          	jalr	-158(ra) # df4 <memmove>
}
     e9a:	60a2                	ld	ra,8(sp)
     e9c:	6402                	ld	s0,0(sp)
     e9e:	0141                	addi	sp,sp,16
     ea0:	8082                	ret

0000000000000ea2 <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
     ea2:	4885                	li	a7,1
 ecall
     ea4:	00000073          	ecall
 ret
     ea8:	8082                	ret

0000000000000eaa <exit>:
.global exit
exit:
 li a7, SYS_exit
     eaa:	4889                	li	a7,2
 ecall
     eac:	00000073          	ecall
 ret
     eb0:	8082                	ret

0000000000000eb2 <wait>:
.global wait
wait:
 li a7, SYS_wait
     eb2:	488d                	li	a7,3
 ecall
     eb4:	00000073          	ecall
 ret
     eb8:	8082                	ret

0000000000000eba <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
     eba:	4891                	li	a7,4
 ecall
     ebc:	00000073          	ecall
 ret
     ec0:	8082                	ret

0000000000000ec2 <read>:
.global read
read:
 li a7, SYS_read
     ec2:	4895                	li	a7,5
 ecall
     ec4:	00000073          	ecall
 ret
     ec8:	8082                	ret

0000000000000eca <write>:
.global write
write:
 li a7, SYS_write
     eca:	48c1                	li	a7,16
 ecall
     ecc:	00000073          	ecall
 ret
     ed0:	8082                	ret

0000000000000ed2 <close>:
.global close
close:
 li a7, SYS_close
     ed2:	48d5                	li	a7,21
 ecall
     ed4:	00000073          	ecall
 ret
     ed8:	8082                	ret

0000000000000eda <kill>:
.global kill
kill:
 li a7, SYS_kill
     eda:	4899                	li	a7,6
 ecall
     edc:	00000073          	ecall
 ret
     ee0:	8082                	ret

0000000000000ee2 <exec>:
.global exec
exec:
 li a7, SYS_exec
     ee2:	489d                	li	a7,7
 ecall
     ee4:	00000073          	ecall
 ret
     ee8:	8082                	ret

0000000000000eea <open>:
.global open
open:
 li a7, SYS_open
     eea:	48bd                	li	a7,15
 ecall
     eec:	00000073          	ecall
 ret
     ef0:	8082                	ret

0000000000000ef2 <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
     ef2:	48c5                	li	a7,17
 ecall
     ef4:	00000073          	ecall
 ret
     ef8:	8082                	ret

0000000000000efa <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
     efa:	48c9                	li	a7,18
 ecall
     efc:	00000073          	ecall
 ret
     f00:	8082                	ret

0000000000000f02 <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
     f02:	48a1                	li	a7,8
 ecall
     f04:	00000073          	ecall
 ret
     f08:	8082                	ret

0000000000000f0a <link>:
.global link
link:
 li a7, SYS_link
     f0a:	48cd                	li	a7,19
 ecall
     f0c:	00000073          	ecall
 ret
     f10:	8082                	ret

0000000000000f12 <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
     f12:	48d1                	li	a7,20
 ecall
     f14:	00000073          	ecall
 ret
     f18:	8082                	ret

0000000000000f1a <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
     f1a:	48a5                	li	a7,9
 ecall
     f1c:	00000073          	ecall
 ret
     f20:	8082                	ret

0000000000000f22 <dup>:
.global dup
dup:
 li a7, SYS_dup
     f22:	48a9                	li	a7,10
 ecall
     f24:	00000073          	ecall
 ret
     f28:	8082                	ret

0000000000000f2a <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
     f2a:	48ad                	li	a7,11
 ecall
     f2c:	00000073          	ecall
 ret
     f30:	8082                	ret

0000000000000f32 <sbrk>:
.global sbrk
sbrk:
 li a7, SYS_sbrk
     f32:	48b1                	li	a7,12
 ecall
     f34:	00000073          	ecall
 ret
     f38:	8082                	ret

0000000000000f3a <sleep>:
.global sleep
sleep:
 li a7, SYS_sleep
     f3a:	48b5                	li	a7,13
 ecall
     f3c:	00000073          	ecall
 ret
     f40:	8082                	ret

0000000000000f42 <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
     f42:	48b9                	li	a7,14
 ecall
     f44:	00000073          	ecall
 ret
     f48:	8082                	ret

0000000000000f4a <ps>:
.global ps
ps:
 li a7, SYS_ps
     f4a:	48d9                	li	a7,22
 ecall
     f4c:	00000073          	ecall
 ret
     f50:	8082                	ret

0000000000000f52 <schedls>:
.global schedls
schedls:
 li a7, SYS_schedls
     f52:	48dd                	li	a7,23
 ecall
     f54:	00000073          	ecall
 ret
     f58:	8082                	ret

0000000000000f5a <schedset>:
.global schedset
schedset:
 li a7, SYS_schedset
     f5a:	48e1                	li	a7,24
 ecall
     f5c:	00000073          	ecall
 ret
     f60:	8082                	ret

0000000000000f62 <va2pa>:
.global va2pa
va2pa:
 li a7, SYS_va2pa
     f62:	48e9                	li	a7,26
 ecall
     f64:	00000073          	ecall
 ret
     f68:	8082                	ret

0000000000000f6a <pfreepages>:
.global pfreepages
pfreepages:
 li a7, SYS_pfreepages
     f6a:	48e5                	li	a7,25
 ecall
     f6c:	00000073          	ecall
 ret
     f70:	8082                	ret

0000000000000f72 <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
     f72:	1101                	addi	sp,sp,-32
     f74:	ec06                	sd	ra,24(sp)
     f76:	e822                	sd	s0,16(sp)
     f78:	1000                	addi	s0,sp,32
     f7a:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
     f7e:	4605                	li	a2,1
     f80:	fef40593          	addi	a1,s0,-17
     f84:	00000097          	auipc	ra,0x0
     f88:	f46080e7          	jalr	-186(ra) # eca <write>
}
     f8c:	60e2                	ld	ra,24(sp)
     f8e:	6442                	ld	s0,16(sp)
     f90:	6105                	addi	sp,sp,32
     f92:	8082                	ret

0000000000000f94 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
     f94:	7139                	addi	sp,sp,-64
     f96:	fc06                	sd	ra,56(sp)
     f98:	f822                	sd	s0,48(sp)
     f9a:	f426                	sd	s1,40(sp)
     f9c:	f04a                	sd	s2,32(sp)
     f9e:	ec4e                	sd	s3,24(sp)
     fa0:	0080                	addi	s0,sp,64
     fa2:	84aa                	mv	s1,a0
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
     fa4:	c299                	beqz	a3,faa <printint+0x16>
     fa6:	0805c863          	bltz	a1,1036 <printint+0xa2>
    neg = 1;
    x = -xx;
  } else {
    x = xx;
     faa:	2581                	sext.w	a1,a1
  neg = 0;
     fac:	4881                	li	a7,0
     fae:	fc040693          	addi	a3,s0,-64
  }

  i = 0;
     fb2:	4701                	li	a4,0
  do{
    buf[i++] = digits[x % base];
     fb4:	2601                	sext.w	a2,a2
     fb6:	00000517          	auipc	a0,0x0
     fba:	59a50513          	addi	a0,a0,1434 # 1550 <digits>
     fbe:	883a                	mv	a6,a4
     fc0:	2705                	addiw	a4,a4,1
     fc2:	02c5f7bb          	remuw	a5,a1,a2
     fc6:	1782                	slli	a5,a5,0x20
     fc8:	9381                	srli	a5,a5,0x20
     fca:	97aa                	add	a5,a5,a0
     fcc:	0007c783          	lbu	a5,0(a5)
     fd0:	00f68023          	sb	a5,0(a3)
  }while((x /= base) != 0);
     fd4:	0005879b          	sext.w	a5,a1
     fd8:	02c5d5bb          	divuw	a1,a1,a2
     fdc:	0685                	addi	a3,a3,1
     fde:	fec7f0e3          	bgeu	a5,a2,fbe <printint+0x2a>
  if(neg)
     fe2:	00088b63          	beqz	a7,ff8 <printint+0x64>
    buf[i++] = '-';
     fe6:	fd040793          	addi	a5,s0,-48
     fea:	973e                	add	a4,a4,a5
     fec:	02d00793          	li	a5,45
     ff0:	fef70823          	sb	a5,-16(a4)
     ff4:	0028071b          	addiw	a4,a6,2

  while(--i >= 0)
     ff8:	02e05863          	blez	a4,1028 <printint+0x94>
     ffc:	fc040793          	addi	a5,s0,-64
    1000:	00e78933          	add	s2,a5,a4
    1004:	fff78993          	addi	s3,a5,-1
    1008:	99ba                	add	s3,s3,a4
    100a:	377d                	addiw	a4,a4,-1
    100c:	1702                	slli	a4,a4,0x20
    100e:	9301                	srli	a4,a4,0x20
    1010:	40e989b3          	sub	s3,s3,a4
    putc(fd, buf[i]);
    1014:	fff94583          	lbu	a1,-1(s2)
    1018:	8526                	mv	a0,s1
    101a:	00000097          	auipc	ra,0x0
    101e:	f58080e7          	jalr	-168(ra) # f72 <putc>
  while(--i >= 0)
    1022:	197d                	addi	s2,s2,-1
    1024:	ff3918e3          	bne	s2,s3,1014 <printint+0x80>
}
    1028:	70e2                	ld	ra,56(sp)
    102a:	7442                	ld	s0,48(sp)
    102c:	74a2                	ld	s1,40(sp)
    102e:	7902                	ld	s2,32(sp)
    1030:	69e2                	ld	s3,24(sp)
    1032:	6121                	addi	sp,sp,64
    1034:	8082                	ret
    x = -xx;
    1036:	40b005bb          	negw	a1,a1
    neg = 1;
    103a:	4885                	li	a7,1
    x = -xx;
    103c:	bf8d                	j	fae <printint+0x1a>

000000000000103e <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
    103e:	7119                	addi	sp,sp,-128
    1040:	fc86                	sd	ra,120(sp)
    1042:	f8a2                	sd	s0,112(sp)
    1044:	f4a6                	sd	s1,104(sp)
    1046:	f0ca                	sd	s2,96(sp)
    1048:	ecce                	sd	s3,88(sp)
    104a:	e8d2                	sd	s4,80(sp)
    104c:	e4d6                	sd	s5,72(sp)
    104e:	e0da                	sd	s6,64(sp)
    1050:	fc5e                	sd	s7,56(sp)
    1052:	f862                	sd	s8,48(sp)
    1054:	f466                	sd	s9,40(sp)
    1056:	f06a                	sd	s10,32(sp)
    1058:	ec6e                	sd	s11,24(sp)
    105a:	0100                	addi	s0,sp,128
  char *s;
  int c, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
    105c:	0005c903          	lbu	s2,0(a1)
    1060:	18090f63          	beqz	s2,11fe <vprintf+0x1c0>
    1064:	8aaa                	mv	s5,a0
    1066:	8b32                	mv	s6,a2
    1068:	00158493          	addi	s1,a1,1
  state = 0;
    106c:	4981                	li	s3,0
      if(c == '%'){
        state = '%';
      } else {
        putc(fd, c);
      }
    } else if(state == '%'){
    106e:	02500a13          	li	s4,37
      if(c == 'd'){
    1072:	06400c13          	li	s8,100
        printint(fd, va_arg(ap, int), 10, 1);
      } else if(c == 'l') {
    1076:	06c00c93          	li	s9,108
        printint(fd, va_arg(ap, uint64), 10, 0);
      } else if(c == 'x') {
    107a:	07800d13          	li	s10,120
        printint(fd, va_arg(ap, int), 16, 0);
      } else if(c == 'p') {
    107e:	07000d93          	li	s11,112
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
    1082:	00000b97          	auipc	s7,0x0
    1086:	4ceb8b93          	addi	s7,s7,1230 # 1550 <digits>
    108a:	a839                	j	10a8 <vprintf+0x6a>
        putc(fd, c);
    108c:	85ca                	mv	a1,s2
    108e:	8556                	mv	a0,s5
    1090:	00000097          	auipc	ra,0x0
    1094:	ee2080e7          	jalr	-286(ra) # f72 <putc>
    1098:	a019                	j	109e <vprintf+0x60>
    } else if(state == '%'){
    109a:	01498f63          	beq	s3,s4,10b8 <vprintf+0x7a>
  for(i = 0; fmt[i]; i++){
    109e:	0485                	addi	s1,s1,1
    10a0:	fff4c903          	lbu	s2,-1(s1)
    10a4:	14090d63          	beqz	s2,11fe <vprintf+0x1c0>
    c = fmt[i] & 0xff;
    10a8:	0009079b          	sext.w	a5,s2
    if(state == 0){
    10ac:	fe0997e3          	bnez	s3,109a <vprintf+0x5c>
      if(c == '%'){
    10b0:	fd479ee3          	bne	a5,s4,108c <vprintf+0x4e>
        state = '%';
    10b4:	89be                	mv	s3,a5
    10b6:	b7e5                	j	109e <vprintf+0x60>
      if(c == 'd'){
    10b8:	05878063          	beq	a5,s8,10f8 <vprintf+0xba>
      } else if(c == 'l') {
    10bc:	05978c63          	beq	a5,s9,1114 <vprintf+0xd6>
      } else if(c == 'x') {
    10c0:	07a78863          	beq	a5,s10,1130 <vprintf+0xf2>
      } else if(c == 'p') {
    10c4:	09b78463          	beq	a5,s11,114c <vprintf+0x10e>
        printptr(fd, va_arg(ap, uint64));
      } else if(c == 's'){
    10c8:	07300713          	li	a4,115
    10cc:	0ce78663          	beq	a5,a4,1198 <vprintf+0x15a>
          s = "(null)";
        while(*s != 0){
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
    10d0:	06300713          	li	a4,99
    10d4:	0ee78e63          	beq	a5,a4,11d0 <vprintf+0x192>
        putc(fd, va_arg(ap, uint));
      } else if(c == '%'){
    10d8:	11478863          	beq	a5,s4,11e8 <vprintf+0x1aa>
        putc(fd, c);
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
    10dc:	85d2                	mv	a1,s4
    10de:	8556                	mv	a0,s5
    10e0:	00000097          	auipc	ra,0x0
    10e4:	e92080e7          	jalr	-366(ra) # f72 <putc>
        putc(fd, c);
    10e8:	85ca                	mv	a1,s2
    10ea:	8556                	mv	a0,s5
    10ec:	00000097          	auipc	ra,0x0
    10f0:	e86080e7          	jalr	-378(ra) # f72 <putc>
      }
      state = 0;
    10f4:	4981                	li	s3,0
    10f6:	b765                	j	109e <vprintf+0x60>
        printint(fd, va_arg(ap, int), 10, 1);
    10f8:	008b0913          	addi	s2,s6,8
    10fc:	4685                	li	a3,1
    10fe:	4629                	li	a2,10
    1100:	000b2583          	lw	a1,0(s6)
    1104:	8556                	mv	a0,s5
    1106:	00000097          	auipc	ra,0x0
    110a:	e8e080e7          	jalr	-370(ra) # f94 <printint>
    110e:	8b4a                	mv	s6,s2
      state = 0;
    1110:	4981                	li	s3,0
    1112:	b771                	j	109e <vprintf+0x60>
        printint(fd, va_arg(ap, uint64), 10, 0);
    1114:	008b0913          	addi	s2,s6,8
    1118:	4681                	li	a3,0
    111a:	4629                	li	a2,10
    111c:	000b2583          	lw	a1,0(s6)
    1120:	8556                	mv	a0,s5
    1122:	00000097          	auipc	ra,0x0
    1126:	e72080e7          	jalr	-398(ra) # f94 <printint>
    112a:	8b4a                	mv	s6,s2
      state = 0;
    112c:	4981                	li	s3,0
    112e:	bf85                	j	109e <vprintf+0x60>
        printint(fd, va_arg(ap, int), 16, 0);
    1130:	008b0913          	addi	s2,s6,8
    1134:	4681                	li	a3,0
    1136:	4641                	li	a2,16
    1138:	000b2583          	lw	a1,0(s6)
    113c:	8556                	mv	a0,s5
    113e:	00000097          	auipc	ra,0x0
    1142:	e56080e7          	jalr	-426(ra) # f94 <printint>
    1146:	8b4a                	mv	s6,s2
      state = 0;
    1148:	4981                	li	s3,0
    114a:	bf91                	j	109e <vprintf+0x60>
        printptr(fd, va_arg(ap, uint64));
    114c:	008b0793          	addi	a5,s6,8
    1150:	f8f43423          	sd	a5,-120(s0)
    1154:	000b3983          	ld	s3,0(s6)
  putc(fd, '0');
    1158:	03000593          	li	a1,48
    115c:	8556                	mv	a0,s5
    115e:	00000097          	auipc	ra,0x0
    1162:	e14080e7          	jalr	-492(ra) # f72 <putc>
  putc(fd, 'x');
    1166:	85ea                	mv	a1,s10
    1168:	8556                	mv	a0,s5
    116a:	00000097          	auipc	ra,0x0
    116e:	e08080e7          	jalr	-504(ra) # f72 <putc>
    1172:	4941                	li	s2,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
    1174:	03c9d793          	srli	a5,s3,0x3c
    1178:	97de                	add	a5,a5,s7
    117a:	0007c583          	lbu	a1,0(a5)
    117e:	8556                	mv	a0,s5
    1180:	00000097          	auipc	ra,0x0
    1184:	df2080e7          	jalr	-526(ra) # f72 <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
    1188:	0992                	slli	s3,s3,0x4
    118a:	397d                	addiw	s2,s2,-1
    118c:	fe0914e3          	bnez	s2,1174 <vprintf+0x136>
        printptr(fd, va_arg(ap, uint64));
    1190:	f8843b03          	ld	s6,-120(s0)
      state = 0;
    1194:	4981                	li	s3,0
    1196:	b721                	j	109e <vprintf+0x60>
        s = va_arg(ap, char*);
    1198:	008b0993          	addi	s3,s6,8
    119c:	000b3903          	ld	s2,0(s6)
        if(s == 0)
    11a0:	02090163          	beqz	s2,11c2 <vprintf+0x184>
        while(*s != 0){
    11a4:	00094583          	lbu	a1,0(s2)
    11a8:	c9a1                	beqz	a1,11f8 <vprintf+0x1ba>
          putc(fd, *s);
    11aa:	8556                	mv	a0,s5
    11ac:	00000097          	auipc	ra,0x0
    11b0:	dc6080e7          	jalr	-570(ra) # f72 <putc>
          s++;
    11b4:	0905                	addi	s2,s2,1
        while(*s != 0){
    11b6:	00094583          	lbu	a1,0(s2)
    11ba:	f9e5                	bnez	a1,11aa <vprintf+0x16c>
        s = va_arg(ap, char*);
    11bc:	8b4e                	mv	s6,s3
      state = 0;
    11be:	4981                	li	s3,0
    11c0:	bdf9                	j	109e <vprintf+0x60>
          s = "(null)";
    11c2:	00000917          	auipc	s2,0x0
    11c6:	38690913          	addi	s2,s2,902 # 1548 <malloc+0x240>
        while(*s != 0){
    11ca:	02800593          	li	a1,40
    11ce:	bff1                	j	11aa <vprintf+0x16c>
        putc(fd, va_arg(ap, uint));
    11d0:	008b0913          	addi	s2,s6,8
    11d4:	000b4583          	lbu	a1,0(s6)
    11d8:	8556                	mv	a0,s5
    11da:	00000097          	auipc	ra,0x0
    11de:	d98080e7          	jalr	-616(ra) # f72 <putc>
    11e2:	8b4a                	mv	s6,s2
      state = 0;
    11e4:	4981                	li	s3,0
    11e6:	bd65                	j	109e <vprintf+0x60>
        putc(fd, c);
    11e8:	85d2                	mv	a1,s4
    11ea:	8556                	mv	a0,s5
    11ec:	00000097          	auipc	ra,0x0
    11f0:	d86080e7          	jalr	-634(ra) # f72 <putc>
      state = 0;
    11f4:	4981                	li	s3,0
    11f6:	b565                	j	109e <vprintf+0x60>
        s = va_arg(ap, char*);
    11f8:	8b4e                	mv	s6,s3
      state = 0;
    11fa:	4981                	li	s3,0
    11fc:	b54d                	j	109e <vprintf+0x60>
    }
  }
}
    11fe:	70e6                	ld	ra,120(sp)
    1200:	7446                	ld	s0,112(sp)
    1202:	74a6                	ld	s1,104(sp)
    1204:	7906                	ld	s2,96(sp)
    1206:	69e6                	ld	s3,88(sp)
    1208:	6a46                	ld	s4,80(sp)
    120a:	6aa6                	ld	s5,72(sp)
    120c:	6b06                	ld	s6,64(sp)
    120e:	7be2                	ld	s7,56(sp)
    1210:	7c42                	ld	s8,48(sp)
    1212:	7ca2                	ld	s9,40(sp)
    1214:	7d02                	ld	s10,32(sp)
    1216:	6de2                	ld	s11,24(sp)
    1218:	6109                	addi	sp,sp,128
    121a:	8082                	ret

000000000000121c <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
    121c:	715d                	addi	sp,sp,-80
    121e:	ec06                	sd	ra,24(sp)
    1220:	e822                	sd	s0,16(sp)
    1222:	1000                	addi	s0,sp,32
    1224:	e010                	sd	a2,0(s0)
    1226:	e414                	sd	a3,8(s0)
    1228:	e818                	sd	a4,16(s0)
    122a:	ec1c                	sd	a5,24(s0)
    122c:	03043023          	sd	a6,32(s0)
    1230:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
    1234:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
    1238:	8622                	mv	a2,s0
    123a:	00000097          	auipc	ra,0x0
    123e:	e04080e7          	jalr	-508(ra) # 103e <vprintf>
}
    1242:	60e2                	ld	ra,24(sp)
    1244:	6442                	ld	s0,16(sp)
    1246:	6161                	addi	sp,sp,80
    1248:	8082                	ret

000000000000124a <printf>:

void
printf(const char *fmt, ...)
{
    124a:	711d                	addi	sp,sp,-96
    124c:	ec06                	sd	ra,24(sp)
    124e:	e822                	sd	s0,16(sp)
    1250:	1000                	addi	s0,sp,32
    1252:	e40c                	sd	a1,8(s0)
    1254:	e810                	sd	a2,16(s0)
    1256:	ec14                	sd	a3,24(s0)
    1258:	f018                	sd	a4,32(s0)
    125a:	f41c                	sd	a5,40(s0)
    125c:	03043823          	sd	a6,48(s0)
    1260:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
    1264:	00840613          	addi	a2,s0,8
    1268:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
    126c:	85aa                	mv	a1,a0
    126e:	4505                	li	a0,1
    1270:	00000097          	auipc	ra,0x0
    1274:	dce080e7          	jalr	-562(ra) # 103e <vprintf>
}
    1278:	60e2                	ld	ra,24(sp)
    127a:	6442                	ld	s0,16(sp)
    127c:	6125                	addi	sp,sp,96
    127e:	8082                	ret

0000000000001280 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
    1280:	1141                	addi	sp,sp,-16
    1282:	e422                	sd	s0,8(sp)
    1284:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
    1286:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
    128a:	00001797          	auipc	a5,0x1
    128e:	d867b783          	ld	a5,-634(a5) # 2010 <freep>
    1292:	a805                	j	12c2 <free+0x42>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
    1294:	4618                	lw	a4,8(a2)
    1296:	9db9                	addw	a1,a1,a4
    1298:	feb52c23          	sw	a1,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
    129c:	6398                	ld	a4,0(a5)
    129e:	6318                	ld	a4,0(a4)
    12a0:	fee53823          	sd	a4,-16(a0)
    12a4:	a091                	j	12e8 <free+0x68>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
    12a6:	ff852703          	lw	a4,-8(a0)
    12aa:	9e39                	addw	a2,a2,a4
    12ac:	c790                	sw	a2,8(a5)
    p->s.ptr = bp->s.ptr;
    12ae:	ff053703          	ld	a4,-16(a0)
    12b2:	e398                	sd	a4,0(a5)
    12b4:	a099                	j	12fa <free+0x7a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
    12b6:	6398                	ld	a4,0(a5)
    12b8:	00e7e463          	bltu	a5,a4,12c0 <free+0x40>
    12bc:	00e6ea63          	bltu	a3,a4,12d0 <free+0x50>
{
    12c0:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
    12c2:	fed7fae3          	bgeu	a5,a3,12b6 <free+0x36>
    12c6:	6398                	ld	a4,0(a5)
    12c8:	00e6e463          	bltu	a3,a4,12d0 <free+0x50>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
    12cc:	fee7eae3          	bltu	a5,a4,12c0 <free+0x40>
  if(bp + bp->s.size == p->s.ptr){
    12d0:	ff852583          	lw	a1,-8(a0)
    12d4:	6390                	ld	a2,0(a5)
    12d6:	02059713          	slli	a4,a1,0x20
    12da:	9301                	srli	a4,a4,0x20
    12dc:	0712                	slli	a4,a4,0x4
    12de:	9736                	add	a4,a4,a3
    12e0:	fae60ae3          	beq	a2,a4,1294 <free+0x14>
    bp->s.ptr = p->s.ptr;
    12e4:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
    12e8:	4790                	lw	a2,8(a5)
    12ea:	02061713          	slli	a4,a2,0x20
    12ee:	9301                	srli	a4,a4,0x20
    12f0:	0712                	slli	a4,a4,0x4
    12f2:	973e                	add	a4,a4,a5
    12f4:	fae689e3          	beq	a3,a4,12a6 <free+0x26>
  } else
    p->s.ptr = bp;
    12f8:	e394                	sd	a3,0(a5)
  freep = p;
    12fa:	00001717          	auipc	a4,0x1
    12fe:	d0f73b23          	sd	a5,-746(a4) # 2010 <freep>
}
    1302:	6422                	ld	s0,8(sp)
    1304:	0141                	addi	sp,sp,16
    1306:	8082                	ret

0000000000001308 <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
    1308:	7139                	addi	sp,sp,-64
    130a:	fc06                	sd	ra,56(sp)
    130c:	f822                	sd	s0,48(sp)
    130e:	f426                	sd	s1,40(sp)
    1310:	f04a                	sd	s2,32(sp)
    1312:	ec4e                	sd	s3,24(sp)
    1314:	e852                	sd	s4,16(sp)
    1316:	e456                	sd	s5,8(sp)
    1318:	e05a                	sd	s6,0(sp)
    131a:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
    131c:	02051493          	slli	s1,a0,0x20
    1320:	9081                	srli	s1,s1,0x20
    1322:	04bd                	addi	s1,s1,15
    1324:	8091                	srli	s1,s1,0x4
    1326:	0014899b          	addiw	s3,s1,1
    132a:	0485                	addi	s1,s1,1
  if((prevp = freep) == 0){
    132c:	00001517          	auipc	a0,0x1
    1330:	ce453503          	ld	a0,-796(a0) # 2010 <freep>
    1334:	c515                	beqz	a0,1360 <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
    1336:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
    1338:	4798                	lw	a4,8(a5)
    133a:	02977f63          	bgeu	a4,s1,1378 <malloc+0x70>
    133e:	8a4e                	mv	s4,s3
    1340:	0009871b          	sext.w	a4,s3
    1344:	6685                	lui	a3,0x1
    1346:	00d77363          	bgeu	a4,a3,134c <malloc+0x44>
    134a:	6a05                	lui	s4,0x1
    134c:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
    1350:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
    1354:	00001917          	auipc	s2,0x1
    1358:	cbc90913          	addi	s2,s2,-836 # 2010 <freep>
  if(p == (char*)-1)
    135c:	5afd                	li	s5,-1
    135e:	a88d                	j	13d0 <malloc+0xc8>
    base.s.ptr = freep = prevp = &base;
    1360:	00001797          	auipc	a5,0x1
    1364:	d3878793          	addi	a5,a5,-712 # 2098 <base>
    1368:	00001717          	auipc	a4,0x1
    136c:	caf73423          	sd	a5,-856(a4) # 2010 <freep>
    1370:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
    1372:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
    1376:	b7e1                	j	133e <malloc+0x36>
      if(p->s.size == nunits)
    1378:	02e48b63          	beq	s1,a4,13ae <malloc+0xa6>
        p->s.size -= nunits;
    137c:	4137073b          	subw	a4,a4,s3
    1380:	c798                	sw	a4,8(a5)
        p += p->s.size;
    1382:	1702                	slli	a4,a4,0x20
    1384:	9301                	srli	a4,a4,0x20
    1386:	0712                	slli	a4,a4,0x4
    1388:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
    138a:	0137a423          	sw	s3,8(a5)
      freep = prevp;
    138e:	00001717          	auipc	a4,0x1
    1392:	c8a73123          	sd	a0,-894(a4) # 2010 <freep>
      return (void*)(p + 1);
    1396:	01078513          	addi	a0,a5,16
      if((p = morecore(nunits)) == 0)
        return 0;
  }
}
    139a:	70e2                	ld	ra,56(sp)
    139c:	7442                	ld	s0,48(sp)
    139e:	74a2                	ld	s1,40(sp)
    13a0:	7902                	ld	s2,32(sp)
    13a2:	69e2                	ld	s3,24(sp)
    13a4:	6a42                	ld	s4,16(sp)
    13a6:	6aa2                	ld	s5,8(sp)
    13a8:	6b02                	ld	s6,0(sp)
    13aa:	6121                	addi	sp,sp,64
    13ac:	8082                	ret
        prevp->s.ptr = p->s.ptr;
    13ae:	6398                	ld	a4,0(a5)
    13b0:	e118                	sd	a4,0(a0)
    13b2:	bff1                	j	138e <malloc+0x86>
  hp->s.size = nu;
    13b4:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
    13b8:	0541                	addi	a0,a0,16
    13ba:	00000097          	auipc	ra,0x0
    13be:	ec6080e7          	jalr	-314(ra) # 1280 <free>
  return freep;
    13c2:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
    13c6:	d971                	beqz	a0,139a <malloc+0x92>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
    13c8:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
    13ca:	4798                	lw	a4,8(a5)
    13cc:	fa9776e3          	bgeu	a4,s1,1378 <malloc+0x70>
    if(p == freep)
    13d0:	00093703          	ld	a4,0(s2)
    13d4:	853e                	mv	a0,a5
    13d6:	fef719e3          	bne	a4,a5,13c8 <malloc+0xc0>
  p = sbrk(nu * sizeof(Header));
    13da:	8552                	mv	a0,s4
    13dc:	00000097          	auipc	ra,0x0
    13e0:	b56080e7          	jalr	-1194(ra) # f32 <sbrk>
  if(p == (char*)-1)
    13e4:	fd5518e3          	bne	a0,s5,13b4 <malloc+0xac>
        return 0;
    13e8:	4501                	li	a0,0
    13ea:	bf45                	j	139a <malloc+0x92>
