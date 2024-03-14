# :muscle: MyPrintf :muscle:

Данный проект является моей реализацией **"Сишной"** функции `printf(const char*, ...)`. Моя функция `MyPrintf(const char *, ...)` поддерживает некоторые спецификаторы вывода, которые поддерживает обычный `printf`, а именно:
1. `%d` - выводит числа в десятичной системе счисления;
2. `%b` - выводит числа в двоичной системе счисления;
3. `%o` - выводит числа в восьмеричной системе счисления;
4. `%x` - выводит числа в шестнадцатеричной системе счисления;
5. `%c` - выводит символ;
6. `%s` - выводит строку;
7. `%%` - выведет `%`;

# Принцип работы моей функции

## Вывод на экран

Чтобы повысить скорость своей программы, я создал буфер длиной **32** байта. Функция записывает символы в него. Как только свободное пространство в буфере заканчивается, он выводится в консоль при помощи системной функции:

``` nasm
mov rax, 1
syscall
```

Данный метод позволяет реже обращаться к системной функции вывода, что повышает скорость выполнения программы.

## Возвращаемое значение

Моя функция возвращает целое число, которое является кодом ошибки. Если возвращаемое значение равно **0**, то функция сработала без ошибок, но если оно равно **1**, это значит, что вы ввели спецификатор, который моя функция не знает. Как только функция заметит ошибку, она сохранит код ошибки в регистр и продолжит свою работу.

## Пример работы моей функции

Пример вызова функции:

``` C
int a = MyPrintf ("%d\n%b\n%c\n%s\n%%\n%x\n%c\n%o\n%o\n"
                  "%d %s %x %d %% %b\n", 123456, 5, 'c',
                  "STRING", 0xA1B2C3DE, 'f', -1234, 05555,
                  1, "love", 3802, 100, 31);
```

Для данного вызова будет такой вывод:

``` C
123456
101
c
STRING
%
A1B2C3DE
f
1777777777777777775456
5555
1 love EDA 100 % 11111
```

# Установка и запуск программы

1. Для начала склонируй мой репозиторий на свой компьютер, при помощи команды:

        git clone https://github.com/EntryFrager/My-Printf.git

2. Чтобы собрать мой проект, пропиши в командной строке данную команду:

        make

3. Для запуска программы пропиши в командной строке:

        ./my_printf

4. Для удаления файлов, созданных на шаге 2, пропиши в командной строке:

        make clean
