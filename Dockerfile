FROM ubuntu:20.04
LABEL maintainer="Benjamin Christie"

# environment variables
ARG DEBIAN_FRONTEND=noninteractive
ARG DEBCONF_NONINTERACTIVE_SEEN=true
ARG ROS_DISTRO=noetic
SHELL ["/bin/bash", "-c"]

# install ROS
RUN apt-get update -yqq && apt-get install -y \
    apt-utils \
    build-essential \
    curl \
    git \
    gnupg \
    lsb-release \
    software-properties-common \
    vim 
RUN echo "deb http://packages.ros.org/ros/ubuntu $(lsb_release -sc) main" > /etc/apt/sources.list.d/ros-latest.list
RUN curl -s https://raw.githubusercontent.com/ros/rosdistro/master/ros.asc | apt-key add - 2>/dev/null
RUN apt-get update -yqq && apt-get install -y --no-install-recommends \
    python3-catkin-tools \
    ros-$ROS_DISTRO-ros-base
RUN source /opt/ros/$ROS_DISTRO/setup.bash
RUN mkdir /root/ros_ws/src -p
RUN cd /root/ros_ws && \
    catkin init && \
    catkin config  --extend /opt/ros/$ROS_DISTRO

# install rtabmap
RUN add-apt-repository ppa:borglab/gtsam-develop
RUN apt-get install -y --no-install-recommends \
    libgtsam-dev \
    libgtsam-unstable-dev \
    ros-$ROS_DISTRO-libg2o \
    ros-$ROS_DISTRO-libpointmatcher \
    ros-$ROS_DISTRO-realsense2-camera \
    ros-$ROS_DISTRO-rtabmap \
    ros-$ROS_DISTRO-rtabmap-ros 
RUN apt-get remove -y \
    ros-$ROS_DISTRO-rtabmap \
    ros-$ROS_DISTRO-rtabmap-ros
RUN cd /root && \
    git clone https://github.com/introlab/rtabmap.git rtabmap && \
    cd rtabmap/build && \
    cmake .. && \
    make -j$(nproc) && \
    make install
RUN cd /root/ros_ws/src && \
    git clone https://github.com/introlab/rtabmap_ros.git rtabmap_ros && \
    catkin build -DRTABMAP_SYNC_MULTI_RGBD=ON -DRTABMAP_SYNC_USER_DATA=ON
RUN echo 'export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/opt/ros/$ROS_DISTRO/lib/x86_64-linux-gnu' > $HOME/.bashrc
RUN echo 'source /opt/ros/$ROS_DISTRO/setup.bash' > $HOME/.bashrc
RUN echo 'source $HOME/ros_ws/devel/setup.bash' > $HOME/.bashrc
RUN source $HOME/.bashrc

WORKDIR /root/ros_ws/src
RUN echo "Run docker in interactive tty mode with './run.sh'"
