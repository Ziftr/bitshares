FROM myvbo/cloudserver-53.154
MAINTAINER Scott Spangenberg
RUN sudo apt-get update

# install the additional libraries specific to bitshares
RUN sudo apt-get -y install cmake libreadline-dev uuid-dev zip python-dev

# create the make and config files appropriate for this environment
ADD . /home/myvbo/cloudwallets/bitshares
WORKDIR /home/myvbo/cloudwallets/bitshares
RUN git submodule init
RUN git submodule update
RUN cmake .
RUN find . -type f -exec touch {} ";"
RUN make

# Steps to make the QT wallet
# start by installing more libraries for the GUI version of the wallet (QY Wallet)
#RUN sudo apt-get -y install npm nodejs-legacy
# Now build everything
#RUN cmake -DINCLUDE_QT_WALLET=ON .
#RUN cd programs/web_wallet
#RUN sudo npm install -g lineman
# Building the GUI version of the wallet fails here; can't find package.json in bitshares
#RUN npm install
#RUN cd -
#RUN make buildweb
#RUN make BitShares

# dev_tests has two failures and then errors out: fatal error in "fork_testing": unknown type
# (probably because no wallet has been configured.)
#RUN tests/dev_tests
# We can run the signature test even on an unconfigured system
RUN tests/deterministic_signature_test
# nathan_tests have one error in get_interest_owed
#RUN tests/nathan_tests
# run_regression_tests.sh fails because it depends on launchctl and launchd
# which don't seem to be available for Ubuntu
#RUN tests/run_regression_tests.sh
# All the wallet import tests fail (no wallets or dat files)
#RUN tests/bitcoin/wallet_import_tests
# and the remaining wallet tests never get going for the same reason
#RUN tests/wallet_tests
# need a configured server to run the serial tests
#RUN tests/drltc_tests/serial/serial_tests

# CLEAN UP THE SOURCE CODE AND THE COMPILED OBJECT FILES
#RUN find . -name \*.cpp -exec rm {} ";"
#RUN find . -name \*.o -exec rm {} ";"

ENTRYPOINT ["/home/myvbo/cloudwallets/bitshares/programs/client/bitshares_client"]
CMD ["-conf=/coin/bitshares/bitshares.conf", "-datadir=/coin/bitshares"]
EXPOSE 3000
