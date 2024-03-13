#include <stdio.h>

extern "C" char *convert (int, int);

int main ()
{
        char *a = convert (16, 2);

        printf ("123\n%s\n", a);

        return 0;
}
