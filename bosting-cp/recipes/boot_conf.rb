dest_path = '/boot/loader.conf'

%w(
cc_htcp_load="YES"
accf_http_load="YES"
accf_data_load="YES"

net.inet.tcp.syncache.hashsize=1024
net.inet.tcp.syncache.bucketlimit=100
net.inet.tcp.tcbhashsize=4096
kern.ipc.nsfbufs=10240

kern.ipc.semmni=256
kern.ipc.semmns=512
kern.ipc.semmnu=256

kern.maxproc=10000
).each do |line|
  append_if_no_line "add #{line} to #{dest_path}" do
    path dest_path
    line line
  end
end
