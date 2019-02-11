FROM golang:1.11.3

RUN apt-get update \
  && apt-get -y upgrade \
  && apt-get install -y build-essential gcc git wget vim make openvpn sudo bash

RUN git clone https://github.com/policypalnet/go-pal.git
RUN cd go-pal \
  && make install

# Run stupid patch for one of the vendor's code
RUN GO111MODULE=off go get github.com/karalabe/hid
RUN cp -r $GOPATH/src/github.com/karalabe/ go-pal/vendor/github.com/

# Build pal binaries and add to /usr/local/bin
RUN cd go-pal \
  && make pal \
  && cp build/bin/pal /usr/local/bin/

# Copy .env file with masternode address into app
COPY ./fixtures/.env $GOPATH/go-pal

# Need to mount volume for chaindata and credentials in go-pal/datadir
# CP .env file (not secret)
EXPOSE 8545 8546 30303 30303/udp
WORKDIR go-pal

# RUN pwd
# RUN ls -l
# RUN make node 2>/root/go-pal.log