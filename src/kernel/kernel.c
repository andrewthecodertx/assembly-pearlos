void kernel_main(void) {
  const char *str = "HELLO, KERNEL";
  char *video_memory = (char *)0xb8000;

  while (*str) {
    *video_memory++ = *str++;
    *video_memory++ = 0x07;
  }
}
