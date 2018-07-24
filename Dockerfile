# Copyright IBM Corporation 2018.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#    http://www.apache.org/licenses/LICENSE-2.0

# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

FROM ubuntu:16.04

USER root
RUN dpkg --add-architecture i386
RUN apt-get update --fix-missing && apt-get install -y net-tools libc6:i386 libncurses5:i386 libstdc++6:i386 ksh gawk procps gcc-multilib libncurses5-dev:i386 libpam0g:i386 libpam-modules:i386 locales xinetd gdb make wget --fix-missing

#  Get the TXSeries beta image and install TXSeries
RUN set -x && TXSERIES_BETA_URL=http://public.dhe.ibm.com/ibmdl/export/pub/software/htp/txseries/TXSeriesV92_Open_Beta_Linux.tar.gz \
    && echo $TXSERIES_BETA_URL \
    && wget -q $TXSERIES_BETA_URL -O /tmp/TXSeriesV92_Open_Beta_Linux.tar.gz \
    && tar -xf /tmp/TXSeriesV92_Open_Beta_Linux.tar.gz -C / \
    && rm /tmp/TXSeriesV92_Open_Beta_Linux.tar.gz \
    && /opt/ibm/cics/etc/txseries-post-install.sh

ENV LANG en_US
ENV CICSPATH /opt/ibm/cics
ENV PATH ${PATH}:${CICSPATH}/bin
ENV NLSPATH=${NLSPATH}:${CICSPATH}/msg/%L/%N:${CICSPATH}/msg/C/%N
ENV LD_LIBRARY_PATH ${LD_LIBRARY_PATH}:${CICSPATH}/lib
RUN mkdir -p /work/autoinstall-dropin/ && chown -R cics:cics /work/autoinstall-dropin/ && chmod 775 /work/autoinstall-dropin/
ENV CICS_PROGRAM_PATH /work/autoinstall-dropin/

# Default IPIC Port
EXPOSE 1435

# TXSeries Admin Console Port
EXPOSE 9443

ADD ./create_and_start /work/

ENTRYPOINT ["/work/create_and_start"]
