#include "kernel.h"

/* Keyboard buffer */
#define KEYBOARD_BUFFER_SIZE 256
static char keyboard_buffer[KEYBOARD_BUFFER_SIZE];
static int buffer_head = 0;
static int buffer_tail = 0;

/* Keyboard scan codes to ASCII conversion table */
static const char scancode_to_ascii[128] = {
    0,    0x1b, '1', '2', '3', '4', '5', '6', '7', '8', '9', '0', '-', '=', '\b', '\t',
    'q',  'w',  'e', 'r', 't', 'y', 'u', 'i', 'o', 'p', '[', ']', '\n', 0,   'a',  's',
    'd',  'f',  'g', 'h', 'j', 'k', 'l', ';', '\'', '`', 0, '\\', 'z', 'x', 'c',  'v',
    'b',  'n',  'm', ',', '.', '/', 0,   '*', 0,   ' ', 0,   0,    0,   0,    0,    0,
    0,    0,    0,  0,   0,   0,   0,   0,   0,   0,   0,   0,    0,   0,    0,    0,
    0,    0,    0,  0,   0,   0,   0,   0,   0,   0,   0,   0,    0,   0,    0,    0,
    0,    0,    0,  0,   0,   0,   0,   0,   0,   0,   0,   0,    0,   0,    0,    0,
    0,    0,    0,  0,   0,   0,   0,   0,   0,   0,   0,   0,    0,   0,    0,    0
};

/* Port definitions for keyboard */
#define KEYBOARD_DATA_PORT 0x60
#define KEYBOARD_STATUS_PORT 0x64

/* I/O port read/write functions */
static inline uint8_t inb(uint16_t port) {
    uint8_t result;
    __asm__ __volatile__("inb %1, %0" : "=a" (result) : "dN" (port));
    return result;
}

static inline void outb(uint16_t port, uint8_t value) {
    __asm__ __volatile__("outb %1, %0" : : "dN" (port), "a" (value));
}

/* Initialize keyboard */
void keyboard_init(void) {
    buffer_head = 0;
    buffer_tail = 0;
    kputs("Keyboard initialized.\n");
}

/* Add character to keyboard buffer */
void keyboard_buffer_add(char c) {
    int next_head = (buffer_head + 1) % KEYBOARD_BUFFER_SIZE;
    if (next_head != buffer_tail) {
        keyboard_buffer[buffer_head] = c;
        buffer_head = next_head;
    }
}

/* Check if keyboard buffer is empty */
int keyboard_buffer_empty(void) {
    return buffer_head == buffer_tail;
}

/* Read character from keyboard buffer */
char keyboard_read(void) {
    while (keyboard_buffer_empty()) {
        __asm__ __volatile__("hlt");
    }
    char c = keyboard_buffer[buffer_tail];
    buffer_tail = (buffer_tail + 1) % KEYBOARD_BUFFER_SIZE;
    return c;
}

/* Keyboard interrupt handler */
void keyboard_interrupt_handler(void) {
    uint8_t status = inb(KEYBOARD_STATUS_PORT);
    if ((status & 0x01) == 0) return;

    uint8_t scancode = inb(KEYBOARD_DATA_PORT);
    
    /* Only process key press (bit 7 = 0) */
    if (scancode < 128) {
        char ascii = scancode_to_ascii[scancode];
        if (ascii != 0) {
            keyboard_buffer_add(ascii);
        }
    }
}
