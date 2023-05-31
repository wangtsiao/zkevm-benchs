#!/bin/sh

should_install_go=false
# Check if Go is installed
if ! command -v go >/dev/null; then
  should_install_go=true
fi

if [ "$should_install_go" = false ]; then
  # Get the current Go version
  go_version=$(go version | awk '{print $3}')

  # Check if the go version is larger than or equal to 1.19
  if [[ "$(printf '%s\n' "$go_version" "go1.19" | sort -V | tail -n 1)" = "go1.19" ]]; then
    echo "[+] go already installed."
  else
    should_install_go=true
  fi
fi

if [ "$should_install_go" = true ]; then
  wget https://go.dev/dl/go1.20.4.linux-amd64.tar.gz
  rm -rf /usr/local/go && tar -C /usr/local -xzf go1.20.4.linux-amd64.tar.gz
  echo 'export PATH=$PATH:/usr/local/go/bin' >> ~/.bashrc
  source ~/.bashrc
fi
