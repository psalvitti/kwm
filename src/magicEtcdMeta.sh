. src/nodeValue.sh
. src/findNodes.sh

##
# This "magic" function somewhat violates the premise of this project and may be
# removed at a future date.
#
# Populates etcd values based on configuration for any Node with a KWM_ROLE that
# contains "etcd".
#
# During PKI generation, etcd cluster bootstrapping, and configuring
# kube-apiserver, a full list of IPs and hostnames for etcd Nodes in various
# formats is needed.
#
magicEtcdMeta() {
  export KWM_ETCD_INITIAL_CLUSTER=${KWM_ETCD_INITIAL_CLUSTER:-$(magicEtcdInitialCluster)}
  export KWM_ETCD_CLIENT_SANS=${KWM_ETCD_CLIENT_SANS:-$(magicEtcdClientSans)}
  export KWM_ETCD_SERVERS=${KWM_ETCD_SERVERS:-$(magicEtcdServers)}
}
##
# This "magic" function somewhat violates the premise of this project and may be
# removed at a future date.
#
# Generate all valid Subject Alternative Names for securing communication from
# the apiserver to etcd.
#
magicEtcdClientSans() {
  local output
  for node in $(findNodes etcd); do
    output+=",IP:$(nodeValue $node PRIVATE_IP),DNS:$(nodeValue $node HOSTNAME)"
  done
  [[ -n $output ]] && echo ${output:1}
}

##
# This "magic" function somewhat violates the premise of this project and may be
# removed at a future date.
#
# Generate the value passed to etcd's "--initial-cluster" flag when spinning up
# a new cluster.
#
magicEtcdInitialCluster() {
  local output=""
  for node in $(findNodes etcd); do
    output+=",$(nodeValue $node HOSTNAME)=https://$(nodeValue $node PRIVATE_IP):2380"
  done
  [[ -n $output ]] && echo ${output:1}

}

##
# Generate the value passed to kube-apiserver's "--etcd-servers" flag.
#
magicEtcdServers() {
  local output
  for node in $(findNodes etcd); do
    output+=",https://$(nodeValue $node PRIVATE_IP):2379"
  done
  [[ -n $output ]] && echo ${output:1}
}
