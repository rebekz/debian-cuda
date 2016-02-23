FROM debian:wheezy

MAINTAINER Ozzy Johnson <docker@ozzy.io>

ENV DEBIAN_FRONTEND noninteractive

ENV CUDA_DRIVER 352.55
ENV CUDA_INSTALL http://us.download.nvidia.com/XFree86/Linux-x86_64/${CUDA_DRIVER}/NVIDIA-Linux-x86_64-${CUDA_DRIVER}.run
ENV CUDA_RUNTIME http://developer.download.nvidia.com/compute/cuda/7_0/Prod/local_installers/cuda_7.0.28_linux.run

# Update and install minimal.
RUN \
  apt-get update \
            --quiet \
  && apt-get install \
            --yes \
            --no-install-recommends \
            --no-install-suggests \
       build-essential=11.5 \
       module-init-tools=9-3 \
       wget \ 

# Clean up packages.
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/*

# Install CUDA.
RUN wget \
      $CUDA_INSTALL \
        -P /tmp \
        --no-verbose \
      && chmod +x /tmp/NVIDIA-Linux-x86_64-${CUDA_DRIVER}.run \
      && /tmp/NVIDIA-Linux-x86_64-${CUDA_DRIVER}.run \
        -s \
        -N \
        --no-kernel-module \
      && rm -rf /tmp/*

RUN wget \
    $CUDA_RUNTIME \
    -P /root \
    --no-verbose \
    && chmod +x /root/cuda_7.0.28_linux.run \
    && cd /root \
    && ./cuda_7.0.28_linux.run -extract=`pwd`/nvidia_installers

RUN cd /root/nvidia_installers \
    && ./cuda-linux64-rel-7.0.28-19326674.run -noprompt

RUN rm /root/nvidia_installers/cuda-linux64-rel-7.0.28-19326674.run 

ENV LIBRARY_PATH=$LD_LIBRARY_PATH:/usr/local/cuda/lib64
ENV PATH=$PATH:/usr/local/cuda/bin

#install ssh
RUN apt-get update && apt-get install -y openssh-server

RUN mkdir /var/run/sshd

RUN echo 'root:screencast' | chpasswd
RUN sed -i 's/PermitRootLogin without-password/PermitRootLogin yes/' /etc/ssh/sshd_config
# SSH login fix. Otherwise user is kicked off after login
RUN sed 's@session\s*required\s*pam_loginuid.so@session optional pam_loginuid.so@g' -i /etc/pam.d/sshd

ENV NOTVISIBLE "in users profile"
RUN echo "export VISIBLE=now" >> /etc/profile

EXPOSE  22
CMD ["/usr/sbin/sshd", "-D"]

