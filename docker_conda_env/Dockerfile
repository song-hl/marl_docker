FROM hlsong/base:1.11.0-py3.8-cuda11.3.1-devel
################################
#        python env       #
################################
ADD conda_env.yml .
RUN conda env create -f conda_env.yml
# ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

################################
#        Apt auto clean        #
################################
RUN ldconfig && \
    conda clean -y -all && \
    apt-get clean && \
    apt-get autoremove && \
    rm -rf /var/lib/apt/lists/* /tmp/* /root/.cache/pip

# ################################
# #   zsh Theme powerlevel10k    #
# ################################
# RUN git clone --depth=1 https://gh.api.99988866.xyz/https://github.com/romkatv/powerlevel10k.git ~/powerlevel10k && \
#     echo 'source ~/powerlevel10k/powerlevel10k.zsh-theme' >>~/.zshrc
# # can also set the TERM and COLORTERM when run docker with "docker run -e TERM -e COLORTERM -e LC_ALL=C.UTF-8 ${tag}"
# ENV LC_ALL=C.UTF-8 \
#     COLORTERM=truecolor \
#     TERM=xterm-256color

# ################################
# #           open ssh           #
# ################################
# COPY ./id_rsa.docker.pub /root/.ssh/authorized_keys
# RUN chmod 600 /root/.ssh/authorized_keys && \
#     service ssh start && \
#     sed -i "s/#PermitRootLogin prohibit-password/PermitRootLogin yes/g" /etc/ssh/sshd_config && \
#     sed -i "s/UsePAM yes/UsePAM no/g" /etc/ssh/sshd_config && \
#     sed -i "s/#PermitEmptyPasswords no/PermitEmptyPasswords yes/g" /etc/ssh/sshd_config && \
#     sed -i "s/#PasswordAuthentication yes/PasswordAuthentication yes/g" /etc/ssh/sshd_config && \
#     sed -i "s/#Port 22/Port 11958/g" /etc/ssh/sshd_config && \
#     echo "root:123456" | chpasswd
# # add env for ssh conect
# RUN sed -i '$a\export $(cat /proc/1/environ |tr "\\0" "\\n" | grep -E "SHELL|LD_LIBRARY_PATH|LD_PRELOAD|SC2PATH|LC_ALL|LANG|PATH" | xargs)' ~/.zshrc && \
#     sed -i '$a\export NUMEXPR_MAX_THREADS=64' ~/.zshrc
# ENTRYPOINT service ssh start && /bin/zsh

WORKDIR /home
