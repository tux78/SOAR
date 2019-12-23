# Use an official Python runtime as a parent image
# currently: 3.8
FROM python:3.8 AS intelmqbase

# Install redis, nginx, php and sudo
RUN echo "Installing necessary OS packages..." \
  && apt update \
  && apt install -y less nano openssl redis-server nginx php-fpm sudo \
  && echo "Finished."

# Install any needed pip packages and dxlclient && pymisp
RUN echo "Installing pip requirement and dxlclient..." \
  && pip install --upgrade pip setuptools wheel \
  && pip install intelmq \
  && pip install dxlclient \
  && pip install dxltieclient \
  && pip install pymisp \
  && echo "Finished."

# Finalize intelMQ installation
RUN echo "Finalizing intelMQ setup..." \
  && useradd -d /opt/intelmq -U -s /bin/bash intelmq \
  && intelmqsetup \
  && echo "Finished."

# Copy content
COPY ./etc/ /etc/

# Setup intelMQ Manager
COPY ./var/ /var/
RUN echo "Finalizing intelMQ Manager setup..." \
  && mkdir /opt/intelmq/etc/manager \
  && touch /opt/intelmq/etc/manager/positions.conf \
  && chown www-data:www-data /opt/intelmq/etc/manager/positions.conf \
  && echo "Finished."


# Setting permissions
RUN echo "Setting permissions..." \
  && echo "www-data ALL=(intelmq) NOPASSWD: /usr/local/bin/intelmqctl" >> /etc/sudoers \
  && chown intelmq:intelmq /etc/intelmq/customer -R \
  && chown www-data:www-data /opt/intelmq/etc -R \
  && echo "Finished."

# Default command to be executed when starting image
CMD ["/bin/sh", "-c", "service nginx restart && service php7.3-fpm start && service redis-server restart && tail -f /dev/null"]
