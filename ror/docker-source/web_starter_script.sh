#!/bin/bash

# Start the rails app
bundle exec rails server -b 0.0.0.0 &

# Start Sidekiq
bundle exec sidekiq