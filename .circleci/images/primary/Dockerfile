FROM circleci/ruby:2.6.5-node-browsers

USER circleci

# Set environment variables:
# ===================================================================================
ENV YARN_VERSION=1.21.1
ENV YARN_CACHE_FOLDER=~/.yarn-cache
ENV NVM_DIR /usr/local/nvm
ENV NODE_VERSION 12.16.1
ENV ZAPPIFEST_VERSION 0.65.0
ENV TYPESCRIPT_VERSION 3.8.3


# Install yarn $YARN_VERSION
# ===================================================================================
RUN curl -o- -L https://yarnpkg.com/install.sh | bash -s -- --version ${YARN_VERSION}


# Install nvm and set node version to $NODE_VERSION
# ===================================================================================
USER root
RUN curl https://raw.githubusercontent.com/creationix/nvm/v0.33.8/install.sh | bash \
  && . $NVM_DIR/nvm.sh \
  && nvm install $NODE_VERSION \
  && nvm alias default $NODE_VERSION \
  && nvm use default
ENV NODE_PATH $NVM_DIR/v$NODE_VERSION/lib/node_modules
ENV PATH $NVM_DIR/versions/node/v$NODE_VERSION/bin:$PATH
USER circleci

# Install brew
USER root
RUN pwd
RUN curl -L https://github.com/applicaster/zappifest/archive/${ZAPPIFEST_VERSION}.tar.gz | tar zx
RUN mv zappifest-${ZAPPIFEST_VERSION} /usr/local/zappifest
WORKDIR /usr/local/zappifest
RUN bundle install
RUN echo "#!/bin/bash\nruby /usr/local/zappifest/lib/zappifest.rb \$@\n" > zappifest
RUN chmod +x zappifest
RUN ln -s /usr/local/zappifest/zappifest /usr/local/bin
ENV PATH /usr/local/zappifest:$PATH

# Add typescript
USER root
RUN npm i -g typescript
