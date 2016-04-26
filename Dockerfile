# Pull base image.
FROM badlandsmodel/pybadlands-dependencies

MAINTAINER Ian Howson

RUN pip install git+https://github.com/badlands-model/pyBadlands.git
RUN pip install git+https://github.com/badlands-model/pyBadlands-Companion.git

WORKDIR /build
ENV TINI_VERSION v0.8.4
ADD https://github.com/krallin/tini/releases/download/${TINI_VERSION}/tini /usr/local/bin/tini
RUN chmod +x /usr/local/bin/tini

# Copy cluster configuration
RUN mkdir /root/.ipython
COPY profile_mpi /root/.ipython/profile_mpi

RUN mkdir /workspace && \
    mkdir /workspace/volume

# Copy test files to workspace
RUN cp -av /build/pyBadlands/Examples/* /workspace/

COPY run.sh /build
RUN chmod +x /build/run.sh

# setup space for working in
VOLUME /workspace/volume

# launch notebook
WORKDIR /workspace
EXPOSE 8888
ENTRYPOINT ["/usr/local/bin/tini", "--"]

CMD /build/run.sh

