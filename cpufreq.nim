#[
  cpufreq - display currrent CPU frequencies from /proc/cpuinfo

  This is free and unencumbered software released into the public domain.

  Anyone is free to copy, modify, publish, use, compile, sell, or
  distribute this software, either in source code form or as a compiled
  binary, for any purpose, commercial or non-commercial, and by any
  means.

  In jurisdictions that recognize copyright laws, the author or authors
  of this software dedicate any and all copyright interest in the
  software to the public domain. We make this dedication for the benefit
  of the public at large and to the detriment of our heirs and
  successors. We intend this dedication to be an overt act of
  relinquishment in perpetuity of all present and future rights to this
  software under copyright law.

  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
  EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
  MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
  IN NO EVENT SHALL THE AUTHORS BE LIABLE FOR ANY CLAIM, DAMAGES OR
  OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE,
  ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
  OTHER DEALINGS IN THE SOFTWARE.

  For more information, please refer to <http://unlicense.org/>
]#

import std/nre
import std/sequtils
import std/strutils
import std/parseopt

const Version: string = "0.1.0"
const Usage: string ="""
Display current CPU frequencies from /proc/cpuinfo

Usage: cpufreq [-b|--brief] [-t|--table] [-h|--help] [-v|--version]"""

proc countCPU(CPUInfo: string): int =
  # Count CPU cores. Return integer value, e.g. 8.
  var processors = CPUInfo.findAll(re"processor")
  result = count(processors, "processor")

proc getModelName(CPUInfo: string): string =
  # Return processor manufacturer and model name.
  var model = CPUInfo.find(re"(?<=model name)(.*)").get.captures[-1]
  result = model.find(re"(?<=: )(.*)").get.captures[-1]

proc getCPUFreq(CPUInfo: string): seq[string] =
  # Return sequence of stings with CPU frequencies. For example output:
  # @["1400.000", "1400.000", "2100.000", "1790.073"]
  var raw_freqs: seq[string] = CPUInfo.findAll(re"(?<=cpu MHz)(.*)(?i)")
  var freqs: seq[string] = @[]
  for freq in raw_freqs:
    freqs.add(freq.replace("\t\t: ", ""))
  result = freqs

iterator countTo(n: int): int =
  var i = 0
  while i <= n:
    yield i
    inc i

proc displayFreqsAsList(CPUFreqs: seq[string], CPUs: int) =
  for cpu in countTo(CPUs - 1):
    echo "CPU", cpu, ": ", CPUFreqs[cpu]

proc displayFreqsAsTable(CPUFreqs: seq[string], CPUs: int) =
  for cpu in countTo(CPUs - 1):
    stdout.write "CPU", cpu, "\t\t"
  echo "\n", CPUFreqs.join("\t")

# Toggles for '--brief' and '--table' options
var brief: bool = false
var table: bool = false

# Parse command line options
var optparser = initOptParser()
while true:
  optparser.next()
  case optparser.kind
  of cmdEnd: break
  of cmdShortOption, cmdLongOption:
    case optparser.key
    of "help", "h": echo Usage; system.quit(0)
    of "version", "v": echo Version; system.quit(0)
    of "brief", "b": brief = true
    of "table", "t": table = true
    else:
      echo "Unknown option: ", optparser.key
      echo Usage
      system.quit(1)
  of cmdArgument:
    discard

# Read /proc/cpuinfo and display info
let CPUInfo = readFile("/proc/cpuinfo")
let CPUModel: string = getModelName(CPUInfo)
let CPUs: int = countCPU(CPUInfo)
let CPUFreqs: seq[string] = getCPUFreq(CPUInfo)

if brief == false:
  echo "CPU model: ", CPUModel
  echo "CPU cores: ", CPUs
  echo ""

if isEmptyOrWhitespace(CPUFreqs.join) == true:
  echo "Sorry, frequencies info is not available for your CPU :("
  system.quit(1)

if table == false:
  displayFreqsAsList(CPUFreqs, CPUs)
else:
  displayFreqsAsTable(CPUFreqs, CPUs)
