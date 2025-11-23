#include "kernel.h"

/* IDE/PATA Port definitions */
#define IDE_PRIMARY_DATA 0x1F0
#define IDE_PRIMARY_ERROR 0x1F1
#define IDE_PRIMARY_NSECTOR 0x1F2
#define IDE_PRIMARY_SECTOR 0x1F3
#define IDE_PRIMARY_LCYL 0x1F4
#define IDE_PRIMARY_HCYL 0x1F5
#define IDE_PRIMARY_HEAD 0x1F6
#define IDE_PRIMARY_STATUS 0x1F7
#define IDE_PRIMARY_COMMAND 0x1F7

/* Status bits */
#define IDE_STATUS_ERR 0x01
#define IDE_STATUS_DRQ 0x08
#define IDE_STATUS_DF 0x20
#define IDE_STATUS_RDY 0x40
#define IDE_STATUS_BSY 0x80

/* Commands */
#define IDE_CMD_READ_SECTORS 0x20
#define IDE_CMD_WRITE_SECTORS 0x30
#define IDE_CMD_IDENTIFY 0xEC

/* I/O port functions */
static inline uint8_t inb(uint16_t port) {
    uint8_t result;
    __asm__ __volatile__("inb %1, %0" : "=a" (result) : "dN" (port));
    return result;
}

static inline uint16_t inw(uint16_t port) {
    uint16_t result;
    __asm__ __volatile__("inw %1, %0" : "=a" (result) : "dN" (port));
    return result;
}

static inline void outb(uint16_t port, uint8_t value) {
    __asm__ __volatile__("outb %1, %0" : : "dN" (port), "a" (value));
}

/* Wait for disk ready */
static int disk_wait_ready(void) {
    for (int i = 0; i < 10000; i++) {
        uint8_t status = inb(IDE_PRIMARY_STATUS);
        if ((status & IDE_STATUS_BSY) == 0) {
            return 1;
        }
        /* Small delay */
        for (volatile int j = 0; j < 100; j++);
    }
    return 0;
}

/* Initialize disk */
void disk_init(void) {
    kputs("Disk controller initialized.\n");
}

/* Read sector from disk (LBA mode) */
int disk_read_sector(uint32_t lba, uint8_t *buffer) {
    if (!disk_wait_ready()) {
        kputs("ERROR: Disk not ready\n");
        return 0;
    }

    /* Set up LBA mode parameters */
    outb(IDE_PRIMARY_NSECTOR, 1);           /* Read 1 sector */
    outb(IDE_PRIMARY_SECTOR, (lba & 0xFF));
    outb(IDE_PRIMARY_LCYL, ((lba >> 8) & 0xFF));
    outb(IDE_PRIMARY_HCYL, ((lba >> 16) & 0xFF));
    outb(IDE_PRIMARY_HEAD, 0xE0 | ((lba >> 24) & 0x0F));  /* LBA mode, master drive */

    /* Issue read command */
    outb(IDE_PRIMARY_COMMAND, IDE_CMD_READ_SECTORS);

    /* Wait for data ready */
    for (int i = 0; i < 10000; i++) {
        uint8_t status = inb(IDE_PRIMARY_STATUS);
        if ((status & IDE_STATUS_DRQ) != 0) {
            /* Data is ready, read it */
            for (int j = 0; j < 256; j++) {
                uint16_t word = inw(IDE_PRIMARY_DATA);
                buffer[j * 2] = word & 0xFF;
                buffer[j * 2 + 1] = (word >> 8) & 0xFF;
            }
            return 1;
        }
        if ((status & IDE_STATUS_ERR) != 0) {
            kputs("ERROR: Disk read error\n");
            return 0;
        }
        /* Small delay */
        for (volatile int k = 0; k < 100; k++);
    }

    return 0;
}

/* Write sector to disk (LBA mode) */
int disk_write_sector(uint32_t lba, uint8_t *buffer) {
    if (!disk_wait_ready()) {
        kputs("ERROR: Disk not ready\n");
        return 0;
    }

    /* Set up LBA mode parameters */
    outb(IDE_PRIMARY_NSECTOR, 1);           /* Write 1 sector */
    outb(IDE_PRIMARY_SECTOR, (lba & 0xFF));
    outb(IDE_PRIMARY_LCYL, ((lba >> 8) & 0xFF));
    outb(IDE_PRIMARY_HCYL, ((lba >> 16) & 0xFF));
    outb(IDE_PRIMARY_HEAD, 0xE0 | ((lba >> 24) & 0x0F));  /* LBA mode, master drive */

    /* Issue write command */
    outb(IDE_PRIMARY_COMMAND, IDE_CMD_WRITE_SECTORS);

    /* Wait for drive ready to accept data */
    for (int i = 0; i < 10000; i++) {
        uint8_t status = inb(IDE_PRIMARY_STATUS);
        if ((status & IDE_STATUS_DRQ) != 0) {
            /* Drive is ready, write data */
            for (int j = 0; j < 256; j++) {
                uint16_t word = (buffer[j * 2 + 1] << 8) | buffer[j * 2];
                outb(IDE_PRIMARY_DATA, word & 0xFF);
                outb(IDE_PRIMARY_DATA, (word >> 8) & 0xFF);
            }
            return 1;
        }
        if ((status & IDE_STATUS_ERR) != 0) {
            kputs("ERROR: Disk write error\n");
            return 0;
        }
        /* Small delay */
        for (volatile int k = 0; k < 100; k++);
    }

    return 0;
}
