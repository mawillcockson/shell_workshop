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


[shell doc]: <https://people.csail.mit.edu/saltzer/Multics/Multics-Documents/MDN/MDN-4.pdf>
[shell history]: <https://multicians.org/shell.html>
[shell wiki]: <https://en.wikipedia.org/wiki/Shell_(computing)>
