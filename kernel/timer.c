#include "kernel.h"

/* PIT (Programmable Interval Timer) port definitions */
#define PIT_CHANNEL_0 0x40
#define PIT_CHANNEL_1 0x41
#define PIT_CHANNEL_2 0x42
#define PIT_CONTROL   0x43

#define PIT_FREQUENCY 1193180  /* Base frequency in Hz */

/* Ticks since system start */
static uint32_t ticks = 0;

/* I/O port functions */
static inline uint8_t inb(uint16_t port) {
    uint8_t result;
    __asm__ __volatile__("inb %1, %0" : "=a" (result) : "dN" (port));
    return result;
}

static inline void outb(uint16_t port, uint8_t value) {
    __asm__ __volatile__("outb %1, %0" : : "dN" (port), "a" (value));
}

/* Initialize PIT for timer interrupt */
void timer_init(uint32_t freq) {
    uint32_t divisor = PIT_FREQUENCY / freq;

    /* Set PIT channel 0 to rate generator mode */
    outb(PIT_CONTROL, 0x36);  /* 0x36 = channel 0, lobyte/hibyte, mode 3 */

    /* Send divisor (LSB first, then MSB) */
    outb(PIT_CHANNEL_0, (uint8_t)(divisor & 0xFF));
    outb(PIT_CHANNEL_0, (uint8_t)((divisor >> 8) & 0xFF));

    ticks = 0;
    kputs("Timer initialized at ");
    char buf[16];
    itoa(freq, buf, 10);
    kputs(buf);
    kputs(" Hz.\n");
}

/* Timer interrupt handler - called by IRQ0 */
void timer_interrupt_handler(void) {
    ticks++;
}

/* Get current tick count */
uint32_t timer_get_ticks(void) {
    return ticks;
}

/* Simple busy-wait sleep in milliseconds */
void timer_sleep(uint32_t ms) {
    uint32_t start_ticks = ticks;
    uint32_t delay_ticks = (ms * 1000) / 1193180;  /* Simplified calculation */

    while ((ticks - start_ticks) < delay_ticks) {
        __asm__ __volatile__("hlt");
    }
}
