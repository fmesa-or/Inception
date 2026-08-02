<!--
The README.md must include at least:
• The very first line must be italicized and read: This project has been created as part
of the 42 curriculum by <login1>[, <login2>[, <login3>[...]]].
• A “Description” section that clearly presents the project, including its goal and a
brief overview.
• An “Instructions” section containing any relevant information about compilation,
installation, and/or execution.
• A “Resources” section listing classic references related to the topic (documentation, articles, tutorials, etc.), as well as a description of how AI was used —
specifying for which tasks and which parts of the project.
➠ Additional sections may be required depending on the project (e.g., usage
examples, feature list, technical choices, etc.).
Any required additions will be explicitly listed below.
• A Project description section must also explain the use of Docker and the sources
included in the project. It must indicate the main design choices, as well as a
comparison between:
◦ Virtual Machines vs Docker
◦ Secrets vs Environment Variables
◦ Docker Network vs Host Network
◦ Docker Volumes vs Bind Mounts
-->


<div align="center">

*This project has been created as part of the 42 curriculum by [**fmesa-or**](https://github.com/fmesa-or)*

---

# INCEPTION
<!--
![C++](https://img.shields.io/badge/C%2B%2B-98-00599C?style=flat-square&logo=cplusplus) ![Makefile](https://img.shields.io/badge/Makefile-427819?style=flat-square) ![IRC](https://img.shields.io/badge/IRC-Server-blue?style=flat-square) ![Poll](https://img.shields.io/badge/Poll-Async-brightgreen?style=flat-square) ![Linux](https://img.shields.io/badge/Linux-FCC624?style=flat-square&logo=linux&logoColor=black) ![42 School](https://img.shields.io/badge/42-School-000000?style=flat-square)


*A fully-featured Inception server implementation in C++98*
-->
</div>

---

## Description
<!--
**ft_irc** is a C++98 IRC server that allows multiple clients to connect and communicate in real-time via channels and private messages. It implements the core IRC protocol functionality with support for channel operators and advanced channel management features.
-->

---

## Instructions

### Requirements
<!--Do I need this?-->
- **Compiler**: ``
- **Standard**: ``
- **Compilation Flags**: ``
- **VM_OS**: Debian 12.15

### Compilation
<!--
```bash
# Clone the repository
git clone git@github.com:fmesa-or/Ft_IRC.git
cd ft_irc

# Compile the project
make

# Clean build artifacts
make clean

# Remove all generated files
make fclean

# Rebuild everything
make re
```
-->

### Execution
<!--
```bash
./ircserv <port> <password>
```

**Arguments:**
- `<port>`: The listening port for incoming IRC connections (e.g., 6667)
- `<password>`: The connection password required by IRC clients

**Example:**
```bash
./ircserv 6667 mySecretPassword
```
-->

### Testing
<!--
Test the server using `nc` (netcat) to verify proper command processing:

```bash
$ nc -C 127.0.0.1 6667
com^Dman^Dd
$
```

Use `Ctrl+D` to send commands in separate packets (simulating low bandwidth or partial data).
-->
---

## Project Structure

```
inception/
├── docs/
│   └── en.subject.pdf
├── srcs/
│   ├── requirements/
│   ├── .env
│   └── docker-compose.yml
├── Makefile
└── README.md
```

---

## Resources & References

- [The Only Docker Tutorial You Need To Get Started](https://www.youtube.com/watch?v=DQdB7wFEygo)
- [Inception - 42 Common Core](https://www.youtube.com/watch?v=wGJFx-H6KX8)
- [Docker Crash Course for Absolute Beginners [NEW]](https://www.youtube.com/watch?v=pg19Z8LL06w)
- [42Kocaeli Inception Projesi](https://www.youtube.com/watch?v=BjbhxtUjkhg)
<!--
- []()
- []()
- []()
-->

### AI Usage

- 

---

# Project Decisions

- **Virtual Machines vs Docker**: ` `
- **Secrets vs Environment Variables**: ` `
- **Docker Network vs Host Network**: ` `
- **Docker Volumes vs Bind Mounts**: ` `

<div align="center">

Made with ☕ at **42 School**

</div>