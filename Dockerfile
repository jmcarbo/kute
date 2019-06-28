FROM docker
RUN apk update && apk add curl bash openssl make
ADD kind /usr/local/bin
ADD Makefile /Makefile
RUN chmod +x /usr/local/bin/kind
RUN curl -LO https://storage.googleapis.com/kubernetes-release/release/$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/linux/amd64/kubectl && \
	cp kubectl /usr/local/bin && chmod +x /usr/local/bin/kubectl
RUN  curl -L https://git.io/get_helm.sh | bash 
COPY examples /examples
