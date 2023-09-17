FROM hlsong/tky_jcls:base
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
    git htop rar sudo swig tar tmux tzdata unrar unzip wget xvfb zip zsh vim 
RUN DEBIAN_FRONTEND=noninteractive $APT_INSTALL \
    openssh-client openssh-server openssl locales


RUN ${PIP_INSTALL} -i https://pypi.tuna.tsinghua.edu.cn/simple pip -U && \
    pip config set global.index-url https://pypi.tuna.tsinghua.edu.cn/simple
RUN ${PIP_INSTALL} scikit-learn  hydra-core wandb nvitop 
RUN ${PIP_INSTALL} torch==1.7.1+cu110 torchvision==0.8.2+cu110 torchaudio===0.7.2 -f https://download.pytorch.org/whl/torch_stable.html # buildkit

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

################################
#        Apt auto clean        #
################################
RUN ldconfig && \
    apt-get clean && \
    apt-get autoremove && \
    rm -rf /var/lib/apt/lists/* /tmp/* /root/.cache/pip

################################
#           zsh & tmux         #
################################
RUN cd ~ && \
    chsh -s /bin/zsh && \
    git clone https://ghproxy.com/https://github.com/ohmyzsh/ohmyzsh.git ~/.oh-my-zsh && \
    cp ~/.oh-my-zsh/templates/zshrc.zsh-template ~/.zshrc && \
    sed -i 's/ZSH_THEME=[^[:space:]]*/ZSH_THEME="ys"/g' ~/.zshrc && \
    sed -i '/PROMPT=/,$d' ~/.oh-my-zsh/themes/ys.zsh-theme && \
    echo 'PROMPT="%{$terminfo[bold]$fg[blue]%}#%{$reset_color%} \\\n%{$terminfo[bold]$fg[yellow]%}%~%{$reset_color%}\\\n${hg_info}${git_info}${svn_info}${venv_info} \\\n[%*] $exit_code\n%(?:%{$fg_bold[green]%}# :%{$fg_bold[red]%}# )"\nRPROMPT='\''%B%F{208}%n%f%{$fg_bold[white]%}@%F{039}%m%f%{$reset_color%}'\' >> ~/.oh-my-zsh/themes/ys.zsh-theme && \
    sed -i "s/plugins=(git)/plugins=(git zsh-autosuggestions zsh-syntax-highlighting tmux z extract sudo)/g" ~/.zshrc && \
    git clone https://ghproxy.com/https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions && \
    git clone https://ghproxy.com/https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting && \
    git clone https://ghproxy.com/https://github.com/gpakosz/.tmux.git ~/.tmux&& \
    ln -s -f .tmux/.tmux.conf && \
    cp .tmux/.tmux.conf.local .

################################
#            Set Shell         # 
################################
ENV SHELL /bin/zsh
RUN echo "if [ -t 1 ]; then" >> ~/.bashrc && \
    echo "exec zsh" >> ~/.bashrc && \
    echo "fi" >> ~/.bashrc

COPY ./id_rsa.docker.pub /root/.ssh/authorized_keys
RUN chmod 600 /root/.ssh/authorized_keys && \
    service ssh start && \
    sed -i "s/#PermitRootLogin prohibit-password/PermitRootLogin yes/g" /etc/ssh/sshd_config && \
    sed -i "s/UsePAM yes/UsePAM no/g" /etc/ssh/sshd_config && \
    sed -i "s/#PasswordAuthentication yes/PasswordAuthentication yes/g" /etc/ssh/sshd_config && \
    sed -i "s/#Port 22/Port 10193/g" /etc/ssh/sshd_config && \
    echo "root:123456" | chpasswd

RUN git config --global user.name KeyuTu && \
    git config --global user.email tky2017ustc_dx@mail.ustc.edu.cn && \
    git config --global --add safe.directory "*"
RUN wandb login 05b9b99909f6a1ba5fac917178924898d0cd9dbd
ENTRYPOINT service ssh start && /bin/zsh