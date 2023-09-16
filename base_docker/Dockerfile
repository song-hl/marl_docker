FROM nvidia/cuda:11.7.1-cudnn8-devel-ubuntu20.04
################################
# Install apt-get Requirements #
################################
ENV LANG C.UTF-8
ENV APT_INSTALL="apt-get install -y --no-install-recommends"
ENV PIP_INSTALL="python -m pip --no-cache-dir install --upgrade --default-timeout 100"

RUN sed -i "s/archive.ubuntu.com/mirrors.ustc.edu.cn/g" /etc/apt/sources.list && \
    sed -i "s/security.ubuntu.com/mirrors.ustc.edu.cn/g" /etc/apt/sources.list && \
    sed -i "s/extras.ubuntu.com/mirrors.ustc.edu.cn/g" /etc/apt/sources.list && \
    rm -rf /var/lib/apt/lists/* \
    /etc/apt/sources.list.d/cuda.list \
    /etc/apt/sources.list.d/nvidia-ml.list && \
    apt-get clean && apt-get update && apt-get upgrade -y 

RUN DEBIAN_FRONTEND=noninteractive $APT_INSTALL \
    git htop rar sudo swig tar tmux tzdata unrar unzip wget curl zip zsh vim \
    openssh-client openssh-server openssl net-tools locales iputils-ping
# RUN DEBIAN_FRONTEND=noninteractive $APT_INSTALL \
#     apt-utils build-essential ca-certificates cifs-utils cmake dpkg-dev g++
# RUN DEBIAN_FRONTEND=noninteractive $APT_INSTALL \
#     x11vnc xpra xserver-xorg-dev iproute2  qt5-default software-properties-common
# RUN DEBIAN_FRONTEND=noninteractive $APT_INSTALL \
#     nfs-common openmpi-bin openmpi-doc patchelf xvfb 
# RUN DEBIAN_FRONTEND=noninteractive $APT_INSTALL \
#     libevent-dev  libgl1-mesa-glx libglew-dev libglfw3 \
#     libglib2.0-0 libncurses5-dev libncursesw5-dev libopenmpi-dev libosmesa6-dev   \ 
#     libsm6  libxext6 libxrender-dev 
# RUN DEBIAN_FRONTEND=noninteractive $APT_INSTALL \
#     zlib1g-dev libgdbm-dev libnss3-dev libssl-dev \
#     libreadline-dev libffi-dev libsqlite3-dev libbz2-dev liblzma-dev

################################
#        Install conda         #
################################
# can be changed to py39_23.5.2-0 or py38_23.5.2-0
ENV CONDA_VERSION=py310_23.5.2-0
RUN curl https://repo.anaconda.com/miniconda/Miniconda3-${CONDA_VERSION}-Linux-x86_64.sh -o ./miniconda.sh && \
    bash miniconda.sh -b -p /opt/conda && \
    /opt/conda/bin/conda init bash&& \
    rm miniconda.sh
ENV PATH /opt/conda/bin:${PATH}

################################
#  change conda & pip sources  #
################################
COPY ./.condarc /root/.condarc

RUN ${PIP_INSTALL} -i https://pypi.tuna.tsinghua.edu.cn/simple pip -U && \
    pip config set global.index-url https://pypi.tuna.tsinghua.edu.cn/simple && \
    conda update -n base conda -y

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

#############################################################################
#                           pytorch                                        #
# 对应版本 ：  https://pytorch.org/get-started/previous-versions/           #

###########################     pip 镜像     ################################
# 上交镜像：  直接将 PyTorch 安装指引 中的 https://download.pytorch.org/whl   #  
#            替换为 https://mirror.sjtu.edu.cn/pytorch-wheels 即可。        #
#  使用镜像问题 problem : torch.version.cuda 与 系统cuda版本不同，                   # 
# RUN ${PIP_INSTALL} 'torch==1.13.1' 'torchvision==0.14.1' 'torchaudio==0.13.1' -f https://mirror.sjtu.edu.cn/pytorch-wheels/cu117/       
############################  pip install  ##################################
# RUN ${PIP_INSTALL} torch==1.13.1+cu117 torchvision==0.14.1+cu117 torchaudio==0.13.1 --extra-index-url https://download.pytorch.org/whl/cu117
###########################   conda install (recommend)  ################################
RUN conda install pytorch==1.13.1 torchvision==0.14.1 torchaudio==0.13.1 pytorch-cuda=11.7 -c nvidia -c https://mirrors.tuna.tsinghua.edu.cn/anaconda/cloud/pytorch/

################################
#        python packages       #
################################
# RUN ${PIP_INSTALL} psutil wheel nvitop wandb hydra-core omegaconf

################################
#        requirement.txt       #
################################
# COPY ./requirements.txt /tmp/requirements.txt
# RUN ${PIP_INSTALL} -r /tmp/requirements.txt

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
#     Set Shell  zsh & tmux    #
################################
RUN cd ~ && \
    chsh -s /bin/zsh && \
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
    sed -i "s/#Port 22/Port 11199/g" /etc/ssh/sshd_config && \
    echo "root:123456" | chpasswd
## user ##
# COPY --chown=${user}:${user} ./id_rsa.docker.pub /home/${user}/.ssh/authorized_keys
# RUN chmod 600 /home/${user}/.ssh/authorized_keys 
# USER root
# RUN service ssh start && \
#     sed -i "s/#PasswordAuthentication yes/PasswordAuthentication yes/g" /etc/ssh/sshd_config && \
#     sed -i "s/#Port 22/Port 12958/g" /etc/ssh/sshd_config && \
# USER ${user}
# RUN torch start_ssh.sh && \
#     echo "echo '123456' |sudo -S service ssh start" >> ./start_ssh.sh && \
#     chmod +x ./start_ssh.sh
# ENTRYPOINT [ "/bin/zsh", "-c", "./start_ssh.sh" ]
ENTRYPOINT service ssh start && /bin/zsh


WORKDIR /workspace
