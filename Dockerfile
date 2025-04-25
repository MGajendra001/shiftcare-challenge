# Use the official Ruby slim image to keep the image size small
FROM ruby:3.2-slim

# Set the working directory inside the container
WORKDIR /app

# Copy the project files into the container
COPY . .

# Install dependencies (gems)
RUN gem install rspec webmock

RUN chmod +x entrypoint.sh

# Use the entrypoint script
ENTRYPOINT ["./entrypoint.sh"]