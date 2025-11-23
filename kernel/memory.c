#include "kernel.h"

/* Simple memory allocator using bump pointer */
#define HEAP_SIZE (1024 * 1024)  /* 1 MB heap */
#define HEAP_START 0x100000      /* After kernel */

static uint8_t heap[HEAP_SIZE];
static size_t heap_used = 0;

/* Memory block header for tracking allocations */
typedef struct {
    size_t size;
    int free;
} block_header_t;

#define HEADER_SIZE sizeof(block_header_t)

/* Initialize memory manager */
void memory_init(void) {
    heap_used = 0;
    kputs("Memory manager initialized.\n");
}

/* Simple malloc - bump pointer allocator with stats */
void *kmalloc(size_t size) {
    if (size == 0) return 0;

    /* Align to 4 bytes */
    size_t aligned_size = (size + 3) & ~3;
    
    /* Check if we have enough space */
    if (heap_used + aligned_size + HEADER_SIZE > HEAP_SIZE) {
        return 0;  /* Return NULL on failure */
    }

    /* Add header */
    block_header_t *header = (block_header_t *)(heap + heap_used);
    header->size = aligned_size;
    header->free = 0;

    void *ptr = (void *)(heap + heap_used + HEADER_SIZE);
    heap_used += aligned_size + HEADER_SIZE;

    return ptr;
}

/* Simple free - does nothing for bump allocator */
void kfree(void *ptr) {
    /* Bump pointer allocator doesn't support free */
    (void)ptr;
}

/* Get memory statistics */
size_t memory_get_used(void) {
    return heap_used;
}

size_t memory_get_total(void) {
    return HEAP_SIZE;
}

/* Display memory info */
void memory_info(void) {
    kputs("Memory Information:\n");
    kputs("- Heap Start: 0x");
    char buf[16];
    itoa(HEAP_START, buf, 16);
    kputs(buf);
    kputs("\n");
    
    kputs("- Heap Size: ");
    itoa(HEAP_SIZE / 1024, buf, 10);
    kputs(buf);
    kputs(" KB\n");
    
    kputs("- Used: ");
    itoa(heap_used / 1024, buf, 10);
    kputs(buf);
    kputs(" KB\n");
    
    kputs("- Available: ");
    itoa((HEAP_SIZE - heap_used) / 1024, buf, 10);
    kputs(buf);
    kputs(" KB\n");
}

/* String utility functions */
int strcmp(const char *a, const char *b) {
    while (*a && *b) {
        if (*a != *b) return *a - *b;
        a++;
        b++;
    }
    return *a - *b;
}

void strcpy(char *dst, const char *src) {
    while (*src) {
        *dst++ = *src++;
    }
    *dst = 0;
}

int strlen(const char *str) {
    int len = 0;
    while (str[len]) len++;
    return len;
}

/* Convert integer to string */
void itoa(int num, char *buffer, int base) {
    if (base < 2 || base > 36) return;

    char *p = buffer;
    int n = num;
    int len = 0;

    if (num < 0 && base == 10) {
        *p++ = '-';
        n = -num;
        len = 1;
    }

    char digits[] = "0123456789abcdefghijklmnopqrstuvwxyz";
    char temp[32];
    int i = 0;

    do {
        temp[i++] = digits[n % base];
        n /= base;
    } while (n > 0);

    while (i > 0) {
        *p++ = temp[--i];
    }
    *p = 0;
}
