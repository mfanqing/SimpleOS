#include "kernel.h"

#define COMMAND_BUFFER_SIZE 256
static char command_buffer[COMMAND_BUFFER_SIZE];
static int cmd_len = 0;

/* Shell commands */
void shell_init(void) {
    kputs("\n");
    kputs("═════════════════════════════════════════════════\n");
    kputs("SimpleOS Shell - Type 'help' for commands\n");
    kputs("═════════════════════════════════════════════════\n");
    kputs("\n");
}

void shell_prompt(void) {
    kputs("SimpleOS> ");
}

/* Handle built-in commands */
void shell_execute(const char *cmd) {
    if (cmd[0] == 0) return;  /* Empty command */
    
    /* Use hash-like comparison for better performance */
    if (strcmp(cmd, "help") == 0) {
        kputs("Available commands:\n");
        kputs("  help      - Show this help message\n");
        kputs("  clear     - Clear screen\n");
        kputs("  time      - Show system ticks\n");
        kputs("  memory    - Show memory info\n");
        kputs("  cpu       - Show CPU info\n");
        kputs("  devices   - List devices\n");
        kputs("  stats     - Show system statistics\n");
        kputs("  graphics  - Show graphics demo\n");
        kputs("  echo      - Echo a message\n");
        kputs("  halt      - Halt CPU\n");
    }
    else if (strcmp(cmd, "clear") == 0) {
        clear_screen();
    }
    else if (strcmp(cmd, "time") == 0) {
        kputs("System ticks: ");
        char buf[16];
        itoa(timer_get_ticks(), buf, 10);
        kputs(buf);
        kputs("\n");
    }
    else if (strcmp(cmd, "memory") == 0) {
        memory_info();
    }
    else if (strcmp(cmd, "cpu") == 0) {
        cpu_info();
    }
    else if (strcmp(cmd, "devices") == 0) {
        devices_list();
    }
    else if (strcmp(cmd, "stats") == 0) {
        show_stats();
    }
    else if (strcmp(cmd, "graphics") == 0) {
        kputs("Loading graphics mode...\n");
        graphics_init();
        graphics_demo();
        kputs("Graphics demo running. Press any key to continue...\n");
        keyboard_read();  /* Wait for key press */
        graphics_exit();
        kputs("Back to text mode.\n");
    }
    else if (strcmp(cmd, "halt") == 0) {
        kputs("Halting CPU...\n");
        __asm__ __volatile__("cli; hlt");
    }
    else if (cmd[0] == 'e' && cmd[1] == 'c' && cmd[2] == 'h' && cmd[3] == 'o' && cmd[4] == ' ') {
        kputs(cmd + 5);
        kputs("\n");
    }
    else {
        kputs("Unknown command: ");
        kputs(cmd);
        kputs("\n");
    }
}
