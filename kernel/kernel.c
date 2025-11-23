#include "kernel.h"

/* VGA memory address */
unsigned short *vga_buffer = (unsigned short *)0xB8000;

/* Cursor position */
int cursor_x = 0, cursor_y = 0;

/* Current text color */
static uint8_t current_color = 0x0F;  /* White on black */

/* VGA Color codes */
#define VGA_COLOR_BLACK 0
#define VGA_COLOR_BLUE 1
#define VGA_COLOR_GREEN 2
#define VGA_COLOR_CYAN 3
#define VGA_COLOR_RED 4
#define VGA_COLOR_MAGENTA 5
#define VGA_COLOR_YELLOW 6   /* Brown/Yellow */
#define VGA_COLOR_BROWN 6
#define VGA_COLOR_WHITE 7

void clear_screen(void) {
    unsigned short blank = (current_color << 8) | 0x20;
    for (int i = 0; i < 80 * 25; i++) {
        vga_buffer[i] = blank;
    }
    cursor_x = 0;
    cursor_y = 0;
}

/* Scroll screen up by one line */
static inline void scroll_screen(void) {
    unsigned short blank = (current_color << 8) | 0x20;
    /* Copy lines 1-24 to lines 0-23 */
    for (int i = 0; i < 80 * 24; i++) {
        vga_buffer[i] = vga_buffer[i + 80];
    }
    /* Clear last line */
    for (int i = 80 * 24; i < 80 * 25; i++) {
        vga_buffer[i] = blank;
    }
}

void set_text_color(uint8_t foreground, uint8_t background) {
    current_color = (background << 4) | (foreground & 0x0F);
}

void kputs(const char *str) {
    unsigned short char_attr = (current_color << 8);
    
    for (int i = 0; str[i] != '\0'; i++) {
        if (str[i] == '\n') {
            cursor_y++;
            cursor_x = 0;
            if (cursor_y >= 25) {
                cursor_y = 24;
                scroll_screen();
            }
        } else if (str[i] == '\r') {
            cursor_x = 0;
        } else {
            if (cursor_x >= 80) {
                cursor_x = 0;
                cursor_y++;
                if (cursor_y >= 25) {
                    cursor_y = 24;
                    scroll_screen();
                }
            }
            int offset = cursor_y * 80 + cursor_x;
            vga_buffer[offset] = char_attr | str[i];
            cursor_x++;
        }
    }
}

void cpu_info(void) {
    kputs("CPU Information:\n");
    kputs("- Architecture: x86 (32-bit)\n");
    kputs("- Mode: Protected Mode\n");
    kputs("- Features: Basic support\n");
}

void display_string(const char *str) {
    kputs(str);
}

void display_hex(int num, int digits) {
    char hex_buf[16];
    itoa(num, hex_buf, 16);
    
    // Pad with zeros
    int len = strlen(hex_buf);
    for (int i = len; i < digits; i++) {
        kputs("0");
    }
    kputs(hex_buf);
}

void show_stats(void) {
    kputs("System Statistics:\n");
    kputs("- Uptime: ");
    char buf[16];
    itoa(timer_get_ticks(), buf, 10);
    kputs(buf);
    kputs(" ticks\n");
    
    kputs("- Memory: ");
    size_t used = memory_get_used();
    itoa(used / 1024, buf, 10);
    kputs(buf);
    kputs(" KB / ");
    size_t total = memory_get_total();
    itoa(total / 1024, buf, 10);
    kputs(buf);
    kputs(" KB\n");
    
    kputs("- Utilization: ");
    int percent = (used * 100) / total;
    itoa(percent, buf, 10);
    kputs(buf);
    kputs("%\n");
}

void kernel_main(void) {
    /* Simple direct test first */
    vga_buffer[0] = (0x0F << 8) | 'T';  /* Write 'T' directly */
    vga_buffer[1] = (0x0F << 8) | 'E';
    vga_buffer[2] = (0x0F << 8) | 'S';
    vga_buffer[3] = (0x0F << 8) | 'T';
    
    clear_screen();
    
    /* Welcome banner */
    set_text_color(VGA_COLOR_CYAN, VGA_COLOR_BLACK);
    kputs("╔════════════════════════════════════════════════════╗\n");
    kputs("║          Welcome to SimpleOS!                     ║\n");
    kputs("║     A Minimal x86 Operating System                ║\n");
    kputs("╚════════════════════════════════════════════════════╝\n");
    
    set_text_color(VGA_COLOR_WHITE, VGA_COLOR_BLACK);
    kputs("\n");
    
    /* Initialize all subsystems */
    kputs("Initializing subsystems...\n");
    kputs("  ");
    set_text_color(VGA_COLOR_GREEN, VGA_COLOR_BLACK);
    kputs("✓");
    set_text_color(VGA_COLOR_WHITE, VGA_COLOR_BLACK);
    kputs(" Memory Manager\n");
    
    kputs("  ");
    set_text_color(VGA_COLOR_GREEN, VGA_COLOR_BLACK);
    kputs("✓");
    set_text_color(VGA_COLOR_WHITE, VGA_COLOR_BLACK);
    kputs(" Keyboard Driver\n");
    
    kputs("  ");
    set_text_color(VGA_COLOR_GREEN, VGA_COLOR_BLACK);
    kputs("✓");
    set_text_color(VGA_COLOR_WHITE, VGA_COLOR_BLACK);
    kputs(" Timer\n");
    
    kputs("  ");
    set_text_color(VGA_COLOR_GREEN, VGA_COLOR_BLACK);
    kputs("✓");
    set_text_color(VGA_COLOR_WHITE, VGA_COLOR_BLACK);
    kputs(" Disk Controller\n");
    
    kputs("\n");
    set_text_color(VGA_COLOR_YELLOW, VGA_COLOR_BLACK);
    kputs("System Information:\n");
    set_text_color(VGA_COLOR_WHITE, VGA_COLOR_BLACK);
    kputs("- Architecture: x86\n");
    kputs("- Memory: 1 MB heap\n");
    kputs("- Display: 80x25 text mode (VGA)\n");
    kputs("- Features: Keyboard, Timer, Disk I/O\n");
    
    kputs("\n");
    set_text_color(VGA_COLOR_MAGENTA, VGA_COLOR_BLACK);
    kputs("Type 'help' for available commands.\n");
    set_text_color(VGA_COLOR_WHITE, VGA_COLOR_BLACK);
    
    /* Initialize subsystems */
    memory_init();
    keyboard_init();
    timer_init(100);  /* 100 Hz */
    disk_init();
    devices_init();
    
    /* Start shell */
    shell_init();
    
    /* Main command loop */
    char cmd_buffer[256];
    int cmd_len = 0;
    
    while (1) {
        shell_prompt();
        cmd_len = 0;
        
        /* Read command line */
        while (1) {
            if (!keyboard_buffer_empty()) {
                char c = keyboard_read();
                if (c == '\n') {
                    kputs("\n");
                    cmd_buffer[cmd_len] = 0;
                    break;
                } else if (c == '\b' && cmd_len > 0) {
                    cmd_len--;
                    kputs("\b \b");
                } else if (c >= 32 && c < 127 && cmd_len < 255) {
                    cmd_buffer[cmd_len++] = c;
                    char buf[2] = {c, 0};
                    kputs(buf);
                }
            }
            __asm__ __volatile__("hlt");
        }
        
        /* Execute command */
        if (cmd_len > 0) {
            shell_execute(cmd_buffer);
        }
    }
}
