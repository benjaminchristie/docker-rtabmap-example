FROM ubuntu:20.04
LABEL maintainer="Benjamin Christie"
WORKDIR $HOME/Documents/projects/docker-tutorials/ros-image/workdir

# environment variables
ARG DEBIAN_FRONTEND=noninteractive
ARG DEBCONF_NONINTERACTIVE_SEEN=true
ARG ROS_DISTRO=noetic
# SHELL ["/bin/bash", "-c"]

# install ROS
RUN apt-get update -yqq && apt-get install -y --no-install-recommends \
    apt-utils \
    build-essential \
    curl \
    git \
    gnupg \
    lsb-release
RUN echo "deb http://packages.ros.org/ros/ubuntu $(lsb_release -sc) main" > /etc/apt/sources.list.d/ros-latest.list
RUN sh -c 'curl -s https://raw.githubusercontent.com/ros/rosdistro/master/ros.asc | apt-key add -'
RUN apt-get update -yqq && apt-get install -y --no-install-recommends \
    python3-catkin-tools \
    ros-$ROS_DISTRO-ros-base
RUN source /opt/ros/noetic/setup.bash
RUN mkdir /root/ros_ws/src -p
RUN cd /root/ros_ws && \
    catkin init

# install rtabmap
RUN apt-get install -y --no-install-recommends ros-$ROS_DISTRO-rtabmap ros-$ROS_DISTRO-rtabmap-ros 
RUN apt-get remove -y ros-$ROS_DISTRO-rtabmap ros-$ROS_DISTRO-rtabmap-ros
RUN cd /root && \
    git clone https://github.com/introlab/rtabmap.git rtabmap && \
    cd rtabmap/build && \
    cmake .. && \
    make -j$(nproc) && \
    make install
RUN cd /root/ros_ws/src && \
    git clone https://github.com/introlab/rtabmap_ros.git src/rtabmap_ros && \
    catkin build -DRTABMAP_SYNC_MULTI_RGBD=ON 
