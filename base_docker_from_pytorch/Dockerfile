FROM pytorch/pytorch:1.13.1-cuda11.6-cudnn8-runtime
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

################################
#  change conda & pip sources  #
################################
COPY ./.condarc /root/.condarc
RUN ${PIP_INSTALL} -i https://pypi.tuna.tsinghua.edu.cn/simple pip -U && \
    pip config set global.index-url https://pypi.tuna.tsinghua.edu.cn/simple
RUN conda update -n base --all -y && \
    conda clean -ya

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
#        python packages       #
################################
### use pip install ###
# RUN ${PIP_INSTALL} psutil wheel nvitop wandb hydra-core omegaconf
### use conda install ###
# 定义要安装的软件包列表y
# ARG CONDA_PACKAGES="psutil wheel nvitop wandb hydra-core omegaconf"
# 使用Conda尝试安装软件包
# RUN conda install -y $CONDA_PACKAGES || true && \ 
#     conda clean -ya
# 使用Pip安装找不到的软件包
# RUN for package in $CONDA_PACKAGES; do \
#     conda list | grep -q $package || pip install $package; \
#     done

################################
#        requirement.txt       #
################################
# COPY ./requirements.txt /tmp/requirements.txt
### use pip install ###
# RUN ${PIP_INSTALL} -r /tmp/requirements.txt
### use conda install ###
# RUN while read requirement; do conda install --yes $requirement || ${PIP_INSTALL} $requirement; done < /tmp/requirements.txt && \
#     conda clean -ya
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
ENTRYPOINT service ssh start && /bin/zsh


WORKDIR /workspace
