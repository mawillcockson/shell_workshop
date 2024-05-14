## topics

- shell is way to interact with OS/platform
- most of that functionality is encapsulated in programs
- common interface is text-based
- every program is run by calling it with a program name and arguments
- the shell expedites that
- the output is "text" (kind of)
- what is text? newline delimited strings (stack overflow "why does file have to end with newline?")
- common tools with common conventions around command line arguments, stdout, and stdin
  - bsd vs GNU
- shell (usually) helps multitasking
- teletype terminals led to terse names and inspired some conventions (`getopts` short- and long-opts)

## questions

- shell script vs programming language
- why multitasking?

## shell design goals

The shell is designed for calling commands that encapsulate some functionality, frequently that which is provided by the operating system or platform.

It's designed for primarily interactive, iterative use.

## commands

The command `cat` is kind of a wrapper around `open()` and a few other system calls. Why have both an API and commands? Because the command takes the error codes and provides meaning to them without having to reference a manual, converts input into the form the system calls can use, and possibly formats the output in a human-readable fashion.

That extra work requires work, and may not be needed by every program. But basically every human will want that.

## activities

write `cp` or something similar.

## outline

First a "hello world":

```sh
echo hello world
```

Probably in [Git Bash][]. Then, editing a script to introduce the [shebang][], and to ensure a script can be edited in an external editor:

```sh
#!/bin/sh
echo hello world
```

change to

```sh
#!/bin/sh
echo hello mars
```

### structure of a command

Each line is likely going to mainly be calling a command. The command in question here is `echo`. This can be confirmed with another command: `which`. In the line `which echo`, `echo` is now an argument. In the file, `echo` is the command and it's being passed some arguments: `hello` and `mars`.

How does the shell know what the command and the arguments are?

Let's try writing our own program that prints out its arguments. Each language has a convention for fetching the arguments passed to the program. For example, this is `lua`: [`print_args.lua`](./print_args.lua).

Running the command:

```sh
luajit print_args.lua
```

This doesn't produce much. In Lua, the indices start at 1, so anything before 1 isn't automatically shown when doing `ipairs(arg)`.

A command using shell builtins would be:

```sh
print_args() {
    printf -- '->%s<-\n' "$@"
}
```

How about `hello world`?

Topics to cover:

- `--flag=` and other conventions
- parameters vs arguments
- word splitting
- quoting
- file globbing
- You can glob and not need to worry about escaping!

Then focus on commands more:

- collections
    - GNU coreutils
    - BSD
    - BusyBox
- Useful/common commands
- pipelines
- variables
  - Can a variable be a `{ ... ; }` code thingy?
- control flow
- functions

### Commands

Syntax of a command.

Important definitions:

[line][]
: A sequence of zero or more non- <newline> characters plus a terminating <newline> character.


## Pitfalls and incongruencies

- flags
  - why `-`?
  - Windows uses `/`, and that is an illegal character in Windows paths
  - confusion in `-` convention and need for things like `=` and `--`
- `printf` over `echo` every time: `read -r FIRST;read -r LAST;echo "${FIRST}" "${LAST}"` with first name of `-e`

### quoting examples

```text
nu$ : powershell-safe -c `cmd /c '.\print_args.exe "a\"" a"\'`
╭───────────┬───────────────────────╮
│ stdout    │ 0 -> .\print_args.exe │
│           │ 1 -> a"               │
│           │ 2 -> a\\              │
│           │                       │
│ stderr    │                       │
│ exit_code │ 0                     │
╰───────────┴───────────────────────╯

nu$ : cmd /c '.\print_args.exe "a\"" a"\'
0 -> .\print_args.exe
1 -> "a\""
2 -> a"\\

nu$ : cmd
Microsoft Windows [Version 10.0.22000.2538]
(c) Microsoft Corporation. All rights reserved.
> .\print_args.exe "a\"" a"\
0 -> .\print_args.exe
1 -> a"
2 -> a\
```


[shell doc]: <https://people.csail.mit.edu/saltzer/Multics/Multics-Documents/MDN/MDN-4.pdf>
[shell history]: <https://multicians.org/shell.html>
[shell wiki]: <https://en.wikipedia.org/wiki/Shell_(computing)>
[thoughtbot]: <https://thoughtbot.com/blog/the-unix-shells-humble-if>
[phoenix cheatsheet]: <https://phoenixnap.com/kb/linux-commands-cheat-sheet>
[rich's tricks]: <https://www.etalabs.net/sh_tricks.html>
[shellhaters]: <https://shellhaters.org/>
[pure sh bible]: <https://github.com/dylanaraps/pure-sh-bible>
[Unix filesystem]: <https://en.wikipedia.org/wiki/Unix_filesystem>
[grymoire sh]: <https://www.grymoire.com/Unix/Sh.html>
[whynot csh]: <http://www.faqs.org/faqs/unix-faq/shell/csh-whynot/>
[grymoire no csh]: <https://www.grymoire.com/Unix/CshTop10.txt>
[grymoire csh]: <https://www.grymoire.com/Unix/Csh.html>
[csh wiki]: <https://en.wikipedia.org/wiki/C_shell#Design_objectives_and_features>
[posix spec]: <https://pubs.opengroup.org/onlinepubs/9699919799/toc.htm>
[line]: <https://pubs.opengroup.org/onlinepubs/9699919799/basedefs/V1_chap03.html#tag_03_206>
[text file]: <https://pubs.opengroup.org/onlinepubs/9699919799/basedefs/V1_chap03.html#tag_03_403>
