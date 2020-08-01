# Use ubuntu 20.04
FROM ubuntu:18.04
LABEL maintainer="Julian Narr"
ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update -q && \
    apt-get upgrade -yq && \
    apt-get install -yq wget curl git build-essential vim sudo lsb-release locales bash-completion tzdata &&\
    apt-get install -yq apt-transport-https

# Run and install ros2: eluqent
RUN apt install -y curl gnupg lsb-release
RUN curl -Ls https://raw.githubusercontent.com/ros/rosdistro/master/ros.asc | sudo apt-key add -
RUN sh -c 'echo "deb [arch=amd64,arm64] http://packages.ros.org/ros2/ubuntu $(lsb_release -cs) main" > /etc/apt/sources.list.d/ros2-latest.list'
RUN apt update
RUN apt install -y ros-eloquent-desktop
RUN apt install -y python3-argcomplete
RUN apt install -y python3-rosdep python3-vcstool # https://index.ros.org/doc/ros2/Installation/Linux-Development-Setup/
RUN grep -F "source /opt/ros/eloquent/setup.bash" ~/.bashrc || echo "source /opt/ros/eloquent/setup.bash" >> ~/.bashrc
RUN grep -F ". /opt/ros/eloquent/setup.bash" ~/.bashrc || echo ". /opt/ros/eloquent/setup.bash" >> ~/.bashrc
RUN set +u

# Source ros foxy setup-file
RUN /bin/bash -c "source /opt/ros/eloquent/setup.bash"
RUN echo "Success installing ROS2 eloquent"
RUN git config --global http.postBuffer 524288000

# Install doxygen, cpplint + python packages
RUN apt-get install -y doxygen
RUN apt-get install -y python3 python3-pip libboost-dev lcov
RUN pip3 install colcon-lcov-result
RUN apt-get -y install cmake python-catkin-pkg python-empy python-nose python-setuptools libgtest-dev build-essential
RUN pip3 install cpplint

# Finish colcon-common-extensions
RUN pip3 install colcon-common-extensions
RUN pip3 install pytest==5.0
RUN pip3 install setuptools==40.0
RUN pip3 install colcon-common-extensions
RUN pip3 install -U PyYAML   
RUN pip3 install numpy
RUN pip3 install natsort
RUN pip3 install opencv-python 
# install opencv
WORKDIR /root
RUN mkdir opencv_build
WORKDIR /root/opencv_build
RUN git clone https://github.com/opencv/opencv.git
RUN git clone https://github.com/opencv/opencv_contrib.git
WORKDIR /root/opencv_build/opencv
RUN mkdir build
WORKDIR /root/opencv_build/opencv/build
RUN cmake -D CMAKE_BUILD_TYPE=RELEASE \
    -D CMAKE_INSTALL_PREFIX=/usr/local \
    -D INSTALL_C_EXAMPLES=ON \
    -D INSTALL_PYTHON_EXAMPLES=ON \
    -D OPENCV_GENERATE_PKGCONFIG=ON \
    -D OPENCV_EXTRA_MODULES_PATH=~/opencv_build/opencv_contrib/modules \
    -D BUILD_EXAMPLES=ON ..
RUN make -j $(nproc)
RUN make install

#Install OpenCV bridge
WORKDIR /root
RUN git clone https://github.com/ros-perception/vision_opencv.git
WORKDIR /root/vision_opencv
RUN git checkout ros2
Run git branch
#RUN sudo apt install libboost-python1.58.0
#RUN /bin/bash -c "source /opt/ros/eloquent/setup.bash"
#RUN  /bin/bash -c "colcon build --symlink-install"
#RUN /bin/bash -c "source ./install/setup.bash"

#Install video stream
WORKDIR /root
RUN git clone https://github.com/julian533/ros2_video_streamer.git
Run cd ros2_video_streamer
#Run colcon build --symlink-install
#RUN /bin/bash -c "source ./install/setup.bash"


# Get example pics
WORKDIR /root
RUN mkdir pics
WORKDIR /root/pics
RUN wget https://www.stuttgarter-zeitung.de/media.media.f6639fa1-647a-46aa-ae14-434492c48009.16x9_1024.jpg
RUN wget https://yt3.ggpht.com/a/AGF-l78ut3ZR_b5nEKjyfgFf0oa3jeuyC2yx40rGHg=s288-c-k-c0xffffffff-no-rj-mo
RUN wget https://images.pexels.com/photos/736230/pexels-photo-736230.jpeg?auto=compress&cs=tinysrgb&dpr=1&w=500

# Reset workdir to home-folder
WORKDIR /root

# Source again
RUN /bin/bash -c "source /opt/ros/eloquent/setup.bash"

# Remove apt lists (for storage efficiency)
#RUN rm -rf /var/lib/apt/lists/*

CMD ["bash"]
