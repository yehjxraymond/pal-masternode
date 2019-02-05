FROM golang:1.11.3

RUN apt-get update \
  && apt-get -y upgrade \
  && apt-get install -y build-essential gcc git wget vim make bash

RUN git clone https://github.com/policypalnet/go-pal.git
RUN cd go-pal \
  && make install

# Run stupid patch for one of the vendor's code
RUN GO111MODULE=off go get github.com/karalabe/hid
RUN cp -r $GOPATH/src/github.com/karalabe/ go-pal/vendor/github.com/

RUN cd go-pal && make pal
COPY --from=builder go-pal/build/bin/pal /usr/local/bin/

# Need to mount volume for chaindata at ~/.ethereum and account stuffs in go-pal/datadir
# CP .env file (not secret)
EXPOSE 8545 8546 30303 30303/udp
RUN /bin/bash