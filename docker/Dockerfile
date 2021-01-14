FROM ruby:2.7.0

RUN git clone https://github.com/lobsters/lobsters.git --depth=1

WORKDIR /lobsters

RUN gem install bundler && bundle install

SHELL ["/bin/bash", "-c"]

RUN curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.37.2/install.sh | bash

COPY config /lobsters/config

RUN source /root/.nvm/nvm.sh \
    && nvm install 14 \
    && nvm alias default 14 \
    && nvm use default

COPY docker-entrypoint.sh ./

ENTRYPOINT ["/lobsters/docker-entrypoint.sh"]