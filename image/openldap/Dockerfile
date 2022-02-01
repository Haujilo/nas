ARG BASE_IMAGE
FROM ${BASE_IMAGE}
ARG DEBIAN_FRONTEND=noninteractive

RUN apt-get -y update &&  apt-get -y upgrade && \
  apt-get -y install slapd ldap-utils ldapscripts && \
  rm -rf /var/lib/apt/lists/*

EXPOSE 389 636
ADD ./run.sh /bin/ldapd
CMD ["/bin/ldapd"]