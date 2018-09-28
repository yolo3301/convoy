FROM fedora

RUN dnf -y update && dnf install -y skopeo jq curl

WORKDIR /

COPY migrate.sh .

CMD ["/bin/bash"]
