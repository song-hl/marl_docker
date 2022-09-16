FROM hlsong/pytorch:1.12.0-py3.8-cuda11.3.1-runtime-ubuntu20.04
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
    git htop rar sudo swig tar tmux tzdata unrar unzip vim wget xvfb zip zsh software-properties-common
RUN DEBIAN_FRONTEND=noninteractive $APT_INSTALL \
    x11vnc xpra xserver-xorg-dev iproute2 iputils-ping locales mesa-utils net-tools qt5-default
RUN DEBIAN_FRONTEND=noninteractive $APT_INSTALL \
    nfs-common openmpi-bin openmpi-doc openssh-client openssh-server openssl patchelf pkg-config 
RUN DEBIAN_FRONTEND=noninteractive $APT_INSTALL \
    libboost-all-dev libdirectfb-dev libevent-dev libgl1-mesa-dev libgl1-mesa-glx libglew-dev libglfw3 \
    libglib2.0-0 libncurses5-dev libncursesw5-dev libopenmpi-dev libosmesa6-dev libsdl2-dev libsdl2-gfx-dev \ 
    libsdl2-image-dev libsdl2-ttf-dev libsm6 libst-dev libxext6 libxrender-dev 

################################
#            NVTOP             #
################################
RUN git clone https://ghproxy.com/https://github.com/Syllo/nvtop.git && \
    mkdir -p nvtop/build && cd nvtop/build && \
    cmake .. -DNVIDIA_SUPPORT=ON -DAMDGPU_SUPPORT=ON && \
    make && make install

################################
#        Install conda         #
################################
# ENV CONDA_VERSION=py38_4.12.0
# RUN wget https://repo.anaconda.com/miniconda/Miniconda3-${CONDA_VERSION}-Linux-x86_64.sh && \
#     /bin/zsh Miniconda3-${CONDA_VERSION}-Linux-x86_64.sh -b -p /opt/conda && \
#     /opt/conda/bin/conda init zsh&& \
#     rm Miniconda3-${CONDA_VERSION}-Linux-x86_64.sh
# ENV PATH /opt/conda/bin:$PATH

################################
#  change conda & pip sources  #
################################
RUN conda config --add channels https://mirrors.ustc.edu.cn/anaconda/cloud/conda-forge/ && \
    conda config --add channels https://mirrors.ustc.edu.cn/anaconda/pkgs/main/ && \
    conda config --add channels https://mirrors.ustc.edu.cn/anaconda/pkgs/free/ && \
    conda config --add channels https://mirrors.ustc.edu.cn/anaconda/cloud/menpo/ && \
    conda config --add channels https://mirrors.ustc.edu.cn/anaconda/cloud/bioconda/ && \
    conda config --add channels https://mirrors.ustc.edu.cn/anaconda/cloud/msys2/ && \
    conda config --set show_channel_urls yes 

RUN ${PIP_INSTALL} -i https://mirrors.ustc.edu.cn/pypi/web/simple pip -U && \
    pip config set global.index-url https://mirrors.ustc.edu.cn/pypi/web/simple

################################
#           zsh & tmux         #
################################
ENV SHELL /bin/zsh
RUN cd /root && \
    git clone https://ghproxy.com/https://github.com/robbyrussell/oh-my-zsh.git ~/.oh-my-zsh && \
    cp ~/.oh-my-zsh/templates/zshrc.zsh-template ~/.zshrc && \
    sed -i "s/ZSH_THEME=\"robbyrussell\"/ZSH_THEME=\"ys\"/g" ~/.zshrc && \
    sed -i "s/plugins=(git)/plugins=(git zsh-autosuggestions zsh-syntax-highlighting tmux z extract sudo)/g" ~/.zshrc && \
    git clone https://ghproxy.com/https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions && \
    git clone https://ghproxy.com/https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting && \
    git clone https://ghproxy.com/https://github.com/gpakosz/.tmux.git && \
    ln -s -f .tmux/.tmux.conf && \
    cp .tmux/.tmux.conf.local . &&\
    /opt/conda/bin/conda init zsh &&\
    chsh -s /bin/zsh 

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
#            Set Shell         # 
################################
RUN echo "if [ -t 1 ]; then" >> /root/.bashrc
RUN echo "exec zsh" >> /root/.bashrc
RUN echo "fi" >> /root/.bashrc
RUN conda update --all -y 
# ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

################################
#        python packages       #
################################
RUN conda install ruamel.yaml -y
RUN conda install -c conda-forge -y \
    scikit-learn scikit-video \
    gym tensorboard tensorboardX pandas seaborn matplotlib
RUN ${PIP_INSTALL} setuptools psutil wheel && \
    ${PIP_INSTALL} scikit-image termcolor wandb hydra-core kornia  \
    git+https://ghproxy.com/https://github.com/oxwhirl/smac.git \
    gfootball mujoco mujoco-py

################################
#           MARL ENVS          #
################################
WORKDIR /marl_envs
ADD *.tar.gz ./
ADD *.zip ./

#          StarCraftII         #
RUN unzip -P iagreetotheeula SC2.4.10.zip && \
    mkdir -p StarCraftII/Maps/ && \
    unzip SMAC_Maps.zip && mv SMAC_Maps StarCraftII/Maps/ && \
    rm -rf SC2.4.10.zip && rm -rf SMAC_Maps.zip && rm -rf __MACOSX/ 
ENV SC2PATH /marl_envs/StarCraftII

#          isaacgym            #
RUN ${PIP_INSTALL} -e ./isaacgym/python
RUN unzip IsaacGymEnvs.zip && rm -rf IsaacGymEnvs.zip && \
    ${PIP_INSTALL} -e ./IsaacGymEnvs

# Mujoco 
RUN mkdir -p /root/.mujoco && cp -r mujoco210 /root/.mujoco/ && \
    rm -rf mujoco210

# Multi-Agent Mujoco 
RUN unzip multiagent_mujoco.zip && rm -rf multiagent_mujoco.zip && \
    ${PIP_INSTALL} -e ./multiagent_mujoco && \
    ${PIP_INSTALL} gym==0.21.0
ENV LD_LIBRARY_PATH /root/.mujoco/mujoco210/bin:$LD_LIBRARY_PATH
ENV LD_PRELOAD /usr/lib/x86_64-linux-gnu/libGLEW.so

# DexterousHands
RUN unzip DexterousHands.zip && rm -rf DexterousHands.zip && \
    ${PIP_INSTALL} -e ./DexterousHands

# fix tensorboard
RUN pip uninstall tb-nightly tensorboard tensorflow \
    tensorflow-estimator tf-estimator-nightly tf-nightly -y && \
    ${PIP_INSTALL} tensorflow

################################
#    gcc  GLIBCXX_3.4.30       #
################################
RUN conda install libstdcxx-ng=12.1.0 && \
    rm -rf /usr/lib/x86_64-linux-gnu/libstdc++.so.6 && \
    ln -s /opt/conda/lib/libstdc++.so.6 /usr/lib/x86_64-linux-gnu/libstdc++.so.6

# ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

################################
#   zsh Theme powerlevel10k    #
################################

#             fonts            #
# RUN DEBIAN_FRONTEND=noninteractive $APT_INSTALL ttf-mscorefonts-installer
# RUN mkdir /usr/share/fonts/zshfont && \
#     cd /usr/share/fonts/zshfont && \
#     wget https://ghproxy.com/https://github.com/romkatv/powerlevel10k-media/raw/master/MesloLGS%20NF%20Regular.ttf && \
#     wget https://ghproxy.com/https://github.com/romkatv/powerlevel10k-media/raw/master/MesloLGS%20NF%20Bold.ttf && \
#     wget https://ghproxy.com/https://github.com/romkatv/powerlevel10k-media/raw/master/MesloLGS%20NF%20Bold%20Italic.ttf && \
#     wget https://ghproxy.com/https://github.com/romkatv/powerlevel10k-media/raw/master/MesloLGS%20NF%20Italic.ttf && \
#     chmod 755 ./*.ttf && \
#     mkfontscale && mkfontdir && fc-cache -fv 

#            theme             #
RUN git clone --depth=1 https://gitee.com/romkatv/powerlevel10k.git ~/powerlevel10k && \
    echo 'source ~/powerlevel10k/powerlevel10k.zsh-theme' >>~/.zshrc

# can also set the TERM and COLORTERM when run docker with "docker run -e TERM -e COLORTERM -e LC_ALL=C.UTF-8 ${tag}"
ENV LC_ALL=C.UTF-8 \
    COLORTERM=truecolor \
    TERM=xterm-256color

################################
#        Apt auto clean        #
################################
RUN ldconfig && \
    conda clean -y -all && \
    apt-get clean && \
    apt-get autoremove && \
    rm -rf /var/lib/apt/lists/* /tmp/* /root/.cache/pip

WORKDIR /workspace
EXPOSE 6006
ENTRYPOINT ["zsh"]