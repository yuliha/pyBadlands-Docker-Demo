# Pull base image.
FROM badlandsmodel/pybadlands-dependencies

MAINTAINER Ian Howson

WORKDIR /build
RUN git clone https://github.com/badlands-model/pyBadlands.git
WORKDIR /build/pyBadlands/pyBadlands/libUtils
RUN make
RUN pip install -e /build/pyBadlands

WORKDIR /build
ENV TINI_VERSION v0.8.4
ADD https://github.com/krallin/tini/releases/download/${TINI_VERSION}/tini /usr/local/bin/tini
RUN chmod +x /usr/local/bin/tini

RUN mkdir /workspace && \
    mkdir /workspace/volume

# Copy test files to workspace
RUN cp -av /build/pyBadlands/test/* /workspace/

# setup space for working in
VOLUME /workspace/volume

# launch notebook
WORKDIR /workspace
EXPOSE 8888
ENTRYPOINT ["/usr/local/bin/tini", "--"]

ENV LD_LIBRARY_PATH=/build/pyBadlands/pyBadlands/libUtils
CMD jupyter notebook --ip=0.0.0.0 --no-browser

