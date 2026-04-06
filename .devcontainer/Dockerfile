ARG BASE_IMAGE="ubuntu:latest"
FROM ${BASE_IMAGE}

ARG GCC_VERSION_MAJOR
ARG CLANG_VERSION_MAJOR
ARG CUDA_VERSION
ARG CMAKE_VERSION
ARG XMAKE_VERSION

ARG USER=devcontainer
ARG PASSWD=""
ARG UID=1000
ARG GID=1000
ARG SHELL=/bin/zsh
ARG TZ="UTC"

ARG UBUNTU_APT_REPOSITORY_URL="http://archive.ubuntu.com"
# ARG UBUNTU_APT_REPOSITORY_URL="https://mirrors.tuna.tsinghua.edu.cn"
ARG LLVM_APT_REPOSITORY_URL="https://apt.llvm.org"
# ARG LLVM_APT_REPOSITORY_URL="https://mirrors.tuna.tsinghua.edu.cn/llvm-apt"
ARG PYPI_REPOSITORY_URL="https://pypi.org/simple"
# ARG PYPI_REPOSITORY_URL="https://pypi.tuna.tsinghua.edu.cn/simple"

ARG CUDA_TOOLKIT_URL="https://developer.download.nvidia.com/compute/cuda"

RUN export DEBIAN_FRONTEND="noninteractive" \
    && sed -i "s|http://archive.ubuntu.com|${UBUNTU_APT_REPOSITORY_URL}|g" /etc/apt/sources.list.d/ubuntu.sources \
    && sed -i "/^Components:/ s/$/ restricted universe multiverse/" /etc/apt/sources.list.d/ubuntu.sources

RUN apt-get update \
    && apt-get -y upgrade \
    && apt-get -y install --no-install-recommends lsb-release software-properties-common \
    build-essential python-dev-is-python3 pinentry-curses netcat-openbsd ninja-build cppcheck gdb \
    ccache valgrind autoconf-archive rsync openssh-client gpg gpg-agent dialog locales tzdata \
    ca-certificates curl wget zip unzip tar git git-lfs sudo vim zsh libxcb-cursor0 xauth gnuplot \
    libreadline-dev \
    && apt-get autoremove -y && apt-get clean -y && rm -rf /var/lib/apt/lists/* \
    && sed -i '/en_US.UTF-8/s/^# //g' /etc/locale.gen && sed -i '/zh_CN.UTF-8/s/^# //g' /etc/locale.gen \
    && locale-gen && update-locale LANG=en_US.UTF-8 LC_ALL=en_US.UTF-8 \
    && sed -i "$ a\export TERM=\"xterm-256color\"" /etc/bash.bashrc \
    && sed -i "$ a\export TERM=\"xterm-256color\"" /etc/zsh/zshrc

RUN if [ -n "${GCC_VERSION_MAJOR}" ]; then \
    apt-get update \
    && apt-get -y install --no-install-recommends gcc-${GCC_VERSION_MAJOR} g++-${GCC_VERSION_MAJOR} \
    gfortran-${GCC_VERSION_MAJOR} libstdc++-${GCC_VERSION_MAJOR}-dev libgfortran-${GCC_VERSION_MAJOR}-dev \
    && apt-get autoremove -y && apt-get clean -y && rm -rf /var/lib/apt/lists/* \
    && for tool in gcc g++ gfortran cpp gcc-ar gcc-nm gcc-ranlib gcov gcov-tool gcov-dump lto-dump; do \
    update-alternatives --remove-all ${tool} 2>/dev/null || true; \
    done \
    && update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-${GCC_VERSION_MAJOR} ${GCC_VERSION_MAJOR} \
    --slave /usr/bin/g++ g++ /usr/bin/g++-${GCC_VERSION_MAJOR} \
    --slave /usr/bin/gfortran gfortran /usr/bin/gfortran-${GCC_VERSION_MAJOR} \
    --slave /usr/bin/cpp cpp /usr/bin/cpp-${GCC_VERSION_MAJOR} \
    --slave /usr/bin/gcc-ar gcc-ar /usr/bin/gcc-ar-${GCC_VERSION_MAJOR} \
    --slave /usr/bin/gcc-nm gcc-nm /usr/bin/gcc-nm-${GCC_VERSION_MAJOR} \
    --slave /usr/bin/gcc-ranlib gcc-ranlib /usr/bin/gcc-ranlib-${GCC_VERSION_MAJOR} \
    --slave /usr/bin/gcov gcov /usr/bin/gcov-${GCC_VERSION_MAJOR} \
    --slave /usr/bin/gcov-tool gcov-tool /usr/bin/gcov-tool-${GCC_VERSION_MAJOR} \
    --slave /usr/bin/gcov-dump gcov-dump /usr/bin/gcov-dump-${GCC_VERSION_MAJOR} \
    --slave /usr/bin/lto-dump lto-dump /usr/bin/lto-dump-${GCC_VERSION_MAJOR} \
    && update-alternatives --set gcc /usr/bin/gcc-${GCC_VERSION_MAJOR}; \
    fi

# Add LLVM-APT ppa and install LLVM compilers and libraries.
RUN if [ -n "${CLANG_VERSION_MAJOR}" ]; then \
    apt-get update \
    && bash -c "$(curl -fsSL ${LLVM_APT_REPOSITORY_URL}/llvm.sh)" "" ${CLANG_VERSION_MAJOR} all -m ${LLVM_APT_REPOSITORY_URL} \
    && apt-get -y install --no-install-recommends flang-${CLANG_VERSION_MAJOR} libflang-${CLANG_VERSION_MAJOR}-dev \
    && apt-get autoremove -y && apt-get clean -y && rm -rf /var/lib/apt/lists/* \
    && sed -i "$ a\export PATH=\"/usr/lib/llvm-${CLANG_VERSION_MAJOR}/bin:\$\{PATH\}\"" /etc/bash.bashrc \
    && sed -i "$ a\export PATH=\"/usr/lib/llvm-${CLANG_VERSION_MAJOR}/bin:\$\{PATH\}\"" /etc/zsh/zshrc; \
    fi

# Install NVIDIA CUDA Toolkit from the official network deb repository (matches the
# Ubuntu flow on developer.nvidia.com/cuda-downloads). Installs the keyring package
# to configure the apt source, then the versioned toolkit meta-package
# (cuda-toolkit-${CUDA_VERSION}, e.g. cuda-toolkit-13-3, not the cuda meta-package, to
# avoid pulling the host kernel driver into the image) and exposes /usr/local/cuda/bin
# on PATH for all interactive shells. The cuda-keyring repo path is derived from
# /etc/os-release at build time (e.g. "ubuntu2404") since ubuntu:latest rolls forward
# to newer LTS releases over time and a hard-coded path would go stale.
RUN if [ -n "${CUDA_VERSION}" ]; then \
    export CUDA_UBUNTU_REPO="ubuntu$(. /etc/os-release && echo ${VERSION_ID} | tr -d '.')" \
    && curl -fsSL -o /tmp/cuda-keyring.deb "${CUDA_TOOLKIT_URL}/repos/${CUDA_UBUNTU_REPO}/x86_64/cuda-keyring_1.1-1_all.deb" \
    && apt-get install -y /tmp/cuda-keyring.deb \
    && rm -f /tmp/cuda-keyring.deb \
    && apt-get update \
    && apt-get -y install --no-install-recommends cuda-toolkit-${CUDA_VERSION} cuda-compat-${CUDA_VERSION} \
    && apt-get autoremove -y && apt-get clean -y && rm -rf /var/lib/apt/lists/* \
    && sed -i "$ a\export PATH=\"\/usr\/local\/cuda\/bin\:\$\{PATH\}\"" /etc/bash.bashrc \
    && sed -i "$ a\export PATH=\"\/usr\/local\/cuda\/bin\:\$\{PATH\}\"" /etc/zsh/zshrc; \
    fi

# Install specific version of cmake.
RUN if [ -n "${CMAKE_VERSION}" ]; then \
    apt-get update \
    && bash -c "$(curl -fsSL https://raw.githubusercontent.com/devcontainers/templates/main/src/cpp/.devcontainer/reinstall-cmake.sh)" "" ${CMAKE_VERSION} \
    && rm -rf /var/lib/apt/lists/*; \
    fi

# Install specific version of xmake.
RUN if [ -n "${XMAKE_VERSION}" ]; then \
    env XMAKE_ROOT=y prefix=/usr/local bash -c "$(curl -fsSL https://xmake.io/shget.text)" "" v${XMAKE_VERSION}; \
    fi

RUN export UV_INSTALL_DIR=/usr/local/bin UV_TOOL_BIN_DIR=/usr/local/bin UV_TOOL_DIR=/usr/local/share/uv/tools UV_NO_CACHE=1 UV_DEFAULT_INDEX=${PYPI_REPOSITORY_URL} \
    && sh -c "$(curl -fsSL https://astral.sh/uv/install.sh)" \
    && uv tool install pyright@latest \
    && uv tool install ruff@latest \
    && uv tool install ty@latest \
    && sed -i "$ a\export UV_TOOL_BIN_DIR=\"/usr/local/bin\"\nexport UV_TOOL_DIR=\"/usr/local/share/uv/tools\"\nexport UV_NO_CACHE=\"1\"\nexport UV_DEFAULT_INDEX=\"${PYPI_REPOSITORY_URL}\"" /etc/bash.bashrc \
    && sed -i "$ a\export UV_TOOL_BIN_DIR=\"/usr/local/bin\"\nexport UV_TOOL_DIR=\"/usr/local/share/uv/tools\"\nexport UV_NO_CACHE=\"1\"\nexport UV_DEFAULT_INDEX=\"${PYPI_REPOSITORY_URL}\"" /etc/zsh/zshrc

RUN { id ubuntu >/dev/null 2>&1 && userdel -f -r ubuntu || true; } \
    && { groupdel ubuntu >/dev/null 2>&1 || true; } \
    && groupadd -g ${GID} ${USER} \
    && useradd -s ${SHELL} -u ${UID} -g ${GID} -G sudo -m ${USER} \
    && if [ -n "${PASSWD}" ]; then \
    echo "root:${PASSWD}" | chpasswd; \
    echo "${USER}:${PASSWD}" | chpasswd; \
    else \
    passwd -d root; \
    passwd -d "${USER}"; \
    fi

USER ${USER}
RUN zsh -c "$(curl -fsSL https://raw.githubusercontent.com/houchen-li/kosy/master/.devcontainer/configure-user.zsh)"
