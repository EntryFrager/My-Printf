#include <stdio.h>

extern "C" int MyPrintf (char *str);

int main ()
{
    char str[4] = "123";
    MyPrintf (str);
    return 0;
}
