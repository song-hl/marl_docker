FROM nvidia/cuda:11.3.1-cudnn8-devel-ubuntu20.04
################################
# Install apt-get Requirements #
################################
ENV LANG C.UTF-8
ENV APT_INSTALL="apt-get install -y --no-install-recommends"
ENV PIP_INSTALL="python -m pip --no-cache-dir install --upgrade --default-timeout 100"

RUN sed -i "s/archive.ubuntu.com/mirrors.ustc.edu.cn/g" /etc/apt/sources.list && \
    rm -rf /var/lib/apt/lists/* \
    /etc/apt/sources.list.d/cuda.list \
    /etc/apt/sources.list.d/nvidia-ml.list && \
    apt-get update && \
    apt-get upgrade -y
RUN DEBIAN_FRONTEND=noninteractive $APT_INSTALL \
    apt-utils build-essential ca-certificates cifs-utils cmake curl dpkg-dev g++ 
RUN DEBIAN_FRONTEND=noninteractive $APT_INSTALL \
    git htop rar sudo swig tar tmux tzdata unrar unzip wget xvfb zip zsh software-properties-common vim
RUN DEBIAN_FRONTEND=noninteractive $APT_INSTALL \
    x11vnc xpra xserver-xorg-dev iproute2 iputils-ping locales net-tools qt5-default
RUN DEBIAN_FRONTEND=noninteractive $APT_INSTALL \
    nfs-common openmpi-bin openmpi-doc openssh-client openssh-server openssl patchelf pkg-config 
RUN DEBIAN_FRONTEND=noninteractive $APT_INSTALL \
    libevent-dev  libgl1-mesa-glx libglew-dev libglfw3 \
    libglib2.0-0 libncurses5-dev libncursesw5-dev libopenmpi-dev libosmesa6-dev   \ 
    libsm6  libxext6 libxrender-dev 
RUN DEBIAN_FRONTEND=noninteractive $APT_INSTALL \
    zlib1g-dev libgdbm-dev libnss3-dev libssl-dev \
    libreadline-dev libffi-dev libsqlite3-dev libbz2-dev liblzma-dev

################################
#        Install conda         #
################################
# can be changed to py39_23.3.1-0 or py38_23.3.1-0
ENV CONDA_VERSION=py38_23.5.2-0

RUN wget https://repo.anaconda.com/miniconda/Miniconda3-${CONDA_VERSION}-Linux-x86_64.sh && \
    bash Miniconda3-${CONDA_VERSION}-Linux-x86_64.sh -b -p /opt/conda && \
    /opt/conda/bin/conda init bash&& \
    rm Miniconda3-${CONDA_VERSION}-Linux-x86_64.sh
ENV PATH /opt/conda/bin:${PATH}

################################
#  change conda & pip sources  #
################################
RUN conda config --set show_channel_urls yes && \
    # 清华大学的源
    conda config --add channels https://mirrors.tuna.tsinghua.edu.cn/anaconda/cloud/pytorch/ && \
    conda config --add channels https://mirrors.tuna.tsinghua.edu.cn/anaconda/cloud/simpleitk/ && \
    conda config --add channels https://mirrors.tuna.tsinghua.edu.cn/anaconda/cloud/menpo/ && \
    conda config --add channels https://mirrors.tuna.tsinghua.edu.cn/anaconda/cloud/bioconda/ && \
    conda config --add channels https://mirrors.tuna.tsinghua.edu.cn/anaconda/cloud/msys2/ && \
    conda config --add channels https://mirrors.tuna.tsinghua.edu.cn/anaconda/cloud/conda-forge/ && \
    conda config --add channels https://mirrors.tuna.tsinghua.edu.cn/anaconda/pkgs/main/ && \
    conda config --add channels https://mirrors.tuna.tsinghua.edu.cn/anaconda/pkgs/r/ 

RUN ${PIP_INSTALL} -i https://mirrors.ustc.edu.cn/pypi/web/simple pip -U && \
    pip config set global.index-url https://mirrors.ustc.edu.cn/pypi/web/simple


################################
#        Set Timezone          #
################################
RUN sed -i -e 's/# en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.gen && \
    locale-gen en_US.UTF-8 && \
    dpkg-reconfigure --frontend=noninteractive locales && \
    update-locale LANG=en_US.UTF-8 && \
    echo "Asia/Shanghai" > /etc/timezone && \
    rm -f /etc/localtime && \
    rm -rf /usr/share/zoneinfo/UTC && \
    dpkg-reconfigure --frontend=noninteractive tzdata

# ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

################################
#    gcc  GLIBCXX_3.4.30       #
################################
# RUN conda install -c conda-forge libstdcxx-ng=12.1.0 && \
#     rm -rf /usr/lib/x86_64-linux-gnu/libstdc++.so.6 && \
#     cp /opt/conda/lib/libstdc++.so.6.0.30 /usr/lib/x86_64-linux-gnu/libstdc++.so.6.0.30 && \
#     ln -s /usr/lib/x86_64-linux-gnu/libstdc++.so.6.0.30 /usr/lib/x86_64-linux-gnu/libstdc++.so.6

################################
#            pytorch           #
################################
# args from https://github.com/cnstark/pytorch-docker.git
ENV PYTORCH_VERSION=1.11.0
ARG PYTORCH_VERSION_SUFFIX=+cu113
ARG TORCHVISION_VERSION=0.12.0
ARG TORCHVISION_VERSION_SUFFIX=+cu113
ARG TORCHAUDIO_VERSION=0.11.0
ARG TORCHAUDIO_VERSION_SUFFIX=+cu113
ARG PYTORCH_DOWNLOAD_URL=https://download.pytorch.org/whl/cu113/torch_stable.html
RUN if [ ! $TORCHAUDIO_VERSION ]; \
    then \
    TORCHAUDIO=; \
    else \
    TORCHAUDIO=torchaudio==${TORCHAUDIO_VERSION}${TORCHAUDIO_VERSION_SUFFIX}; \
    fi 
RUN if [ ! $PYTORCH_DOWNLOAD_URL ]; \
    then \
    ${PIP_INSTALL} \
    torch==${PYTORCH_VERSION}${PYTORCH_VERSION_SUFFIX} \
    torchvision==${TORCHVISION_VERSION}${TORCHVISION_VERSION_SUFFIX} \
    ${TORCHAUDIO}; \
    else \
    ${PIP_INSTALL} \
    torch==${PYTORCH_VERSION}${PYTORCH_VERSION_SUFFIX} \
    torchvision==${TORCHVISION_VERSION}${TORCHVISION_VERSION_SUFFIX} \
    ${TORCHAUDIO} \
    -f ${PYTORCH_DOWNLOAD_URL}; \
    fi

################################
#        python packages       #
################################
RUN conda update -n base conda && \
    ${PIP_INSTALL} --upgrade pip
RUN conda install ruamel.yaml -y && \
    conda install -c conda-forge -y \
    gym \
    scikit-learn scikit-video \
    tensorboard tensorboardX pandas seaborn matplotlib && \
    ${PIP_INSTALL} setuptools psutil wheel nvitop&& \
    ${PIP_INSTALL} nvitop && \
    ${PIP_INSTALL} scikit-image termcolor wandb hydra-core kornia

# ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

################################
#        Apt auto clean        #
################################
RUN ldconfig && \
    conda clean -y -all && \
    apt-get clean && \
    apt-get autoremove && \
    rm -rf /var/lib/apt/lists/* /tmp/* /root/.cache/pip

################################
#           add user           #
################################
# ARG user=docker
# ARG userid=1000
# RUN chsh -s /bin/zsh && \
#     useradd --create-home --no-log-init --shell /bin/zsh ${user} && \
#     adduser ${user} sudo && \
#     echo "${user}:123456" | chpasswd
# RUN usermod -u ${userid} ${user} && groupmod -g ${userid} ${user}

# add user to conda
# # Anaconda environment
# RUN echo "export ANACONDA_HOME=/opt/conda" >> /etc/profile && \
#     echo "export PATH=\$ANACONDA_HOME/bin:\$PATH" >> /etc/profile 
# RUN groupadd conda && \
#     chgrp -R conda /opt/conda && \
#     chmod 770 -R /opt/conda && \
#     usermod -a -G conda ${user}

# WORKDIR /home/${user}
# USER ${user}

################################
#           zsh & tmux         #
################################
RUN cd ~ && \
    git clone https://ghproxy.com/https://github.com/ohmyzsh/ohmyzsh.git ~/.oh-my-zsh && \
    cp ~/.oh-my-zsh/templates/zshrc.zsh-template ~/.zshrc && \
    sed -i "s/ZSH_THEME=\"robbyrussell\"/ZSH_THEME=\"ys\"/g" ~/.zshrc && \
    sed -i "s/plugins=(git)/plugins=(git zsh-autosuggestions zsh-syntax-highlighting tmux z extract sudo)/g" ~/.zshrc && \
    git clone https://ghproxy.com/https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions && \
    git clone https://ghproxy.com/https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting && \
    git clone https://ghproxy.com/https://github.com/gpakosz/.tmux.git ~/.tmux&& \
    ln -s -f .tmux/.tmux.conf && \
    cp .tmux/.tmux.conf.local . &&\
    /opt/conda/bin/conda init zsh

################################
#            Set Shell         # 
################################
ENV SHELL /bin/zsh
RUN echo "if [ -t 1 ]; then" >> ~/.bashrc && \
    echo "exec zsh" >> ~/.bashrc && \
    echo "fi" >> ~/.bashrc

################################
#   zsh Theme powerlevel10k    #
################################
RUN git clone --depth=1 https://ghproxy.com/https://github.com/romkatv/powerlevel10k.git ~/powerlevel10k && \
    echo 'source ~/powerlevel10k/powerlevel10k.zsh-theme' >>~/.zshrc
# may need to install fonts to support full use of powerlevel10k,follow the link below
# https://github.com/romkatv/powerlevel10k#meslo-nerd-font-patched-for-powerlevel10k

# can also set the TERM and COLORTERM when run docker with "docker run -e TERM -e COLORTERM -e LC_ALL=C.UTF-8 ${tag}"
ENV LC_ALL=C.UTF-8 \
    COLORTERM=truecolor \
    TERM=xterm-256color
################################
#           open ssh           #
################################
# add env for ssh conect
RUN sed -i '$a\export $(cat /proc/1/environ |tr "\\0" "\\n" | grep -E "SHELL|LD_LIBRARY_PATH|LD_PRELOAD|SC2PATH|LC_ALL|LANG|PATH" | xargs)' ~/.zshrc && \
    sed -i '$a\export NUMEXPR_MAX_THREADS=64' ~/.zshrc

## root ##
COPY ./id_rsa.docker.pub /root/.ssh/authorized_keys
RUN chmod 600 /root/.ssh/authorized_keys && \
    service ssh start && \
    sed -i "s/#PermitRootLogin prohibit-password/PermitRootLogin yes/g" /etc/ssh/sshd_config && \
    sed -i "s/UsePAM yes/UsePAM no/g" /etc/ssh/sshd_config && \
    sed -i "s/#PasswordAuthentication yes/PasswordAuthentication yes/g" /etc/ssh/sshd_config && \
    sed -i "s/#Port 22/Port 10624/g" /etc/ssh/sshd_config && \
    sed -i "s/#X11Forwarding yes/X11Forwarding yes/g" /etc/ssh/sshd_config && \
    sed -i "s/#X11UseLocalhost yes/X11UseLocalhost no/g" /etc/ssh/sshd_config && \
    sed -i "s/#X11DisplayOffset 10/X11DisplayOffset 10/g" /etc/ssh/sshd_config && \
    echo "root:123456" | chpasswd
## user ##
# COPY --chown=${user}:${user} ./id_rsa.docker.pub /home/${user}/.ssh/authorized_keys
# RUN chmod 600 /home/${user}/.ssh/authorized_keys 
# USER root
# RUN service ssh start && \
#     sed -i "s/#PasswordAuthentication yes/PasswordAuthentication yes/g" /etc/ssh/sshd_config && \
#     sed -i "s/#Port 22/Port 12958/g" /etc/ssh/sshd_config && \
#     sed -i "s/#X11Forwarding yes/X11Forwarding yes/g" /etc/ssh/sshd_config && \
#     sed -i "s/#X11UseLocalhost yes/X11UseLocalhost no/g" /etc/ssh/sshd_config && \
#     sed -i "s/#X11DisplayOffset 10/X11DisplayOffset 10/g" /etc/ssh/sshd_config
# USER ${user}
# RUN torch start_ssh.sh && \
#     echo "echo '123456' |sudo -S service ssh start" >> ./start_ssh.sh && \
#     chmod +x ./start_ssh.sh
# ENTRYPOINT [ "/bin/zsh", "-c", "./start_ssh.sh" ]
ENTRYPOINT service ssh start && /bin/zsh

WORKDIR /workspace
