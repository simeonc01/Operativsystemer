#include "kernel/types.h"
#include "kernel/stat.h"
#include "user/user.h"

int main(int argc, char *argv[])
{
    if (argc < 2 || argc > 3) {
        printf("Usage: vatopa virtual_address [pid]\n");
        exit(1);
    }
    
    uint64 va = strlen(argv[1]);
    int pid = atoi(argv[2]);

    if (argc == 2) {
        va2pa(va, -1);
        exit(1);
    }


    va2pa(va, pid);
    // printf("%d\n", va2pa(0, 0));
    // printf("%d\n", argc);
    exit(0);
}
