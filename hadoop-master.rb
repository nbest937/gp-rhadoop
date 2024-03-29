# -------------------------------------------------------------------------- #
# Copyright 2010-2011, University of Chicago                                      #
#                                                                            #
# Licensed under the Apache License, Version 2.0 (the "License"); you may    #
# not use this file except in compliance with the License. You may obtain    #
# a copy of the License at                                                   #
#                                                                            #
# http://www.apache.org/licenses/LICENSE-2.0                                 #
#                                                                            #
# Unless required by applicable law or agreed to in writing, software        #
# distributed under the License is distributed on an "AS IS" BASIS,          #
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.   #
# See the License for the specific language governing permissions and        #
# limitations under the License.                                             #
# -------------------------------------------------------------------------- #

##~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
##
## RECIPE: Hadoop master node
##
## Set up a Hadoop master node.
##
##~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

gp_domain = node[:topology][:domains][node[:domain_id]]
homedirs  = gp_domain[:filesystem][:dir_homes]
softdir   = gp_domain[:filesystem][:dir_software]

# The hadoop_master attribute is part of the generated topology.rb file,
# and contains the FQDN of the master node.
server = gp_domain[:hadoop_master]

hadoop_dir = "#{softdir}/hadoop"
hadoop_conf_dir = "#{homedirs}/hduser/conf/"

directory "/ephemeral/0/hadoop" do
  owner "hduser"
  group "hadoop"
  mode "0750"
  recursive true
  action :create
end

# Force host key to be added to known_hosts
execute "ssh-localhost" do
  user "hduser"
  command "ssh -o StrictHostKeyChecking=no `hostname --fqdn` echo"
  action :run
end

#execute "#{hadoop_dir}/bin/hdfs namenode -format" do
execute "#{hadoop_dir}/bin/hadoop namenode -format" do
  not_if do File.exists?("/ephemeral/0/hadoop/dfs") end
  user "hduser"
  environment ({
  	'HADOOP_CONF_DIR' => hadoop_conf_dir,
  	'HADOOP_HOME' => hadoop_dir
  })
  action :run
end

execute "#{hadoop_dir}/bin/start-dfs.sh" do
  user "hduser"
  environment ({
  	'HADOOP_CONF_DIR' => hadoop_conf_dir,
  	'HADOOP_HOME' => hadoop_dir
  })
  action :run
end

execute "#{hadoop_dir}/bin/start-mapred.sh" do
  user "hduser"
  environment ({
  	'HADOOP_CONF_DIR' => hadoop_conf_dir,
  	'HADOOP_HOME' => hadoop_dir
  })
  action :run
end
