# cpufreq

Display current CPU frequencies from `/proc/cpuinfo`. This is a sample of the Nim language.

```
Usage: cpufreq [-b|--brief] [-t|--table] [-h|--help] [-v|--version]
```

# Build from source

First install Nim language compiler. See instructions on [Nim site](https://nim-lang.org/install.html). You need Nim v1.2.0 or newer.

Compile programm:

```
nim c cpufreq.nim
```

Done! You can place `cpufreq` executable to your PATH, e.g. `/urs/local/bin`.
