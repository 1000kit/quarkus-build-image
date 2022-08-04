ARG VERSION

FROM ghcr.io/lorislab/samo:3.0.0 as samo

FROM maven:3.8.6 as maven

FROM quay.io/quarkus/ubi-quarkus-native-image:$VERSION

USER root

RUN microdnf update && \
    microdnf install dnf git tar gzip unzip libcurl-devel openssl-devel && \
    dnf upgrade -y && \
    dnf -y install dnf-plugins-core && \
    dnf config-manager --add-repo https://download.docker.com/linux/fedora/docker-ce.repo && \
    sed -i -e 's/baseurl=https:\/\/download\.docker\.com\/linux\/\(fedora\|rhel\)\/$releasever/baseurl\=https:\/\/download.docker.com\/linux\/centos\/$releasever/g' /etc/yum.repos.d/docker-ce.repo && \
    dnf -y install docker-ce docker-ce-cli containerd.io docker-compose-plugin

COPY --from=maven /usr/share/maven /usr/share/maven

ENV MAVEN_OPTS=-XX:+TieredCompilation -XX:TieredStopAtLevel=1
ENV MAVEN_HOME=/usr/share/maven
RUN ln -s ${MAVEN_HOME}/bin/mvn /usr/bin/mvn

COPY --from=samo /usr/bin/samo /usr/local/bin/samo

USER quarkus

