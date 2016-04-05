# Pull base image.
FROM ubuntu:trusty

MAINTAINER Ian Howson

RUN apt-get update -y

RUN apt-get install -y git python-pip python-dev libzmq3 libzmq3-dev pkg-config libfreetype6-dev libpng3 libopenmpi-dev openmpi-bin libhdf5-dev liblapack-dev llvm-3.6 libedit-dev gfortran

RUN pip install -U setuptools
RUN pip install -U pip  # fixes AssertionError in Ubuntu pip
RUN pip install enum34
RUN LLVM_CONFIG=llvm-config-3.6 pip install llvmlite==0.8.0
RUN pip install jupyter markupsafe zmq singledispatch backports_abc certifi jsonschema ipyparallel path.py matplotlib mpi4py==1.3.1 git+https://github.com/badlands-model/triangle pandas plotly
RUN pip install Cython==0.20
RUN pip install h5py
RUN pip install scipy
RUN pip install numpy
RUN pip install numba==0.23.1

RUN apt-get install -y wget

WORKDIR /build
RUN git clone https://github.com/badlands-model/pyBadlands.git
WORKDIR /build/pyBadlands/pyBadlands
RUN git checkout 2c1f789d9fcf39ac80873552fb1fb4dde0f14e57
WORKDIR /build/pyBadlands/pyBadlands/libUtils
RUN make
RUN pip install -e /build/pyBadlands

WORKDIR /build
ENV TINI_VERSION v0.8.4
ADD https://github.com/krallin/tini/releases/download/${TINI_VERSION}/tini /usr/local/bin/tini
RUN chmod +x /usr/local/bin/tini

RUN mkdir /workspace && \
    mkdir /workspace/volume

# Copy local directory to image
COPY badlands-demo /workspace

# setup space for working in
VOLUME /workspace/volume

# launch notebook
WORKDIR /workspace
EXPOSE 8888
ENTRYPOINT ["/usr/local/bin/tini", "--"]

ENV LD_LIBRARY_PATH=/build/pyBadlands/pyBadlands/libUtils
CMD jupyter notebook --ip=0.0.0.0 --no-browser
# --NotebookApp.default_url='test.ipynb'
