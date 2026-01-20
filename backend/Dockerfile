FROM ruby:3.4.7-bookworm

RUN apt-get update -qq && apt-get install -y \
  build-essential \
  libpq-dev \
  nodejs \
  yarn \
  wkhtmltopdf \
  fontconfig \
  libxrender1 \
  libxext6 \
  ca-certificates && rm -rf /var/lib/apt/lists/*

WORKDIR /app

COPY Gemfile Gemfile.lock ./
RUN bundle install

COPY . .

EXPOSE 3000
