PROBE_NAME="System"
PROBE_KEYS=(SYS_OS SYS_VERSION SYS_ARCH SYS_CPU SYS_RAM_GB)

probe_run() {
  # Auto-detect cross-platform defaults
  local _os _ver _arch _cpu _ram

  if command -v sw_vers &>/dev/null; then
    _os=$(sw_vers -productName 2>/dev/null || true)
    _ver=$(sw_vers -productVersion 2>/dev/null || true)
  else
    _os=$(uname -s)
    _ver=$(uname -r)
  fi

  _arch=$(uname -m)

  _cpu=$(sysctl -n machdep.cpu.brand_string 2>/dev/null \
    || grep -m1 "model name" /proc/cpuinfo 2>/dev/null | cut -d: -f2 | xargs \
    || echo "")

  if sysctl -n hw.memsize &>/dev/null 2>&1; then
    _ram=$(( $(sysctl -n hw.memsize) / 1073741824 ))
  elif [ -f /proc/meminfo ]; then
    _ram=$(( $(grep MemTotal /proc/meminfo | awk '{print $2}') / 1048576 ))
  else
    _ram=""
  fi

  ask SYS_OS      "Operating system"  "$_os"
  ask SYS_VERSION "OS version"        "$_ver"
  ask SYS_ARCH    "Architecture"      "$_arch"
  ask SYS_CPU     "CPU"               "$_cpu"
  ask SYS_RAM_GB  "RAM (GB)"          "$_ram"
}
