// gcc day4_2.c -o day4_2
// ./day4_2 < day4_input.txt

#include <stdio.h>
#include <string.h>

char* all_fields[] = {"cid", "byr", "iyr", "eyr", "hgt", "hcl", "ecl", "pid"};
char* all_colors[] = {"amb", "blu", "brn", "gry", "grn", "hzl", "oth"};
char find_field(const char *str, char **fields, char size) {
  for (char i=0; i < size; i++) {
    if (!strcmp(fields[i], str)) return i;
  }

  return -1;
}
char validate(char field, const char *value) {
  if (field < 0) return -1;
  int year;

  switch(field) {
  case 1:
    if (!sscanf(value, "%d", &year)) return -1;
    return (year >= 1920 && year <= 2002) ? field : -1;
  case 2:
    if (!sscanf(value, "%d", &year)) return -1;
    return (year >= 2010 && year <= 2020) ? field : -1;
  case 3:
    if (!sscanf(value, "%d", &year)) return -1;
    return (year >= 2020 && year <= 2030) ? field : -1;
  case 4:
    if (!sscanf(value, "%d", &year)) return -1;
    if (strstr(value, "cm")) return (year >= 150 && year <= 193) ? field : -1;
    if (strstr(value, "in")) return (year >= 59 && year <= 76)   ? field : -1;
    return -1;
  case 5:
    if (strlen(value) != 7) return -1;
    return sscanf(value, "#%x", &year) ? field : -1;
  case 6:
    return (find_field(value, all_colors, 7) >= 0) ? field : -1;
  case 7:
    if (strlen(value) != 9) return -1;
    return sscanf(value, "%d", &year) ? field : -1;
  }

  return field;
}


int main() {
  char buf[1024], *del, *start, *end;
  unsigned char fields = 0;
  int valid = 0;

  while(fgets(buf, sizeof(buf), stdin) != NULL) {
    if (strlen(buf) == 1) {
      if ((fields & 0xFE) == 0xFE) valid++;
      fields = 0;
      continue;
    }
    start = buf-1;
    do {
      del = strchr(start+1, ':'); *del = '\0';
      end = strchr(del+1, ' ');
      if (!end) end = strchr(del+1, '\n');
      if (end) *end = '\0';
      fields |= (1 << validate(find_field(start+1, all_fields, 8), del+1));
      start = end;
    } while (start && *(start+1));
  }
  if ((fields & 0xFE) == 0xFE) valid++;

  printf("%d\n", valid);

  return 0;
}
