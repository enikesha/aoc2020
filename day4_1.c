// gcc day4_1.c -o day4_1
// ./day4_1 < day4_input.txt

#include <stdio.h>
#include <string.h>

char* fields[] = {"cid", "byr", "iyr", "eyr", "hgt", "hcl", "ecl", "pid"};
int find_field(const char *str) {
  for (int i=0; i < 8; i++) {
    if (!strcmp(fields[i], str)) return i;
  }

  return -1;
}

int main() {
  char buf[1024], fields = 0, *str, *sep;
  int valid = 0;

  while(fgets(buf, sizeof(buf), stdin) != NULL) {
    if (strlen(buf) == 1) {
      if ((fields & 0xFE) == 0xFE) valid++;
      fields = 0;
      continue;
    }
    str = buf-1;
    do {
      sep = strchr(str+1, ':'); *sep = '\0';
      fields |= (1 << find_field(str+1));
    } while (str = strchr(sep+1, ' '));
  }
  if ((fields & 0xFE) == 0xFE) valid++;

  printf("%d\n", valid);

  return 0;
}
