
gp-instance-create -c simple-ec2-rhadoop.conf

GPI=gpi-5a866587


# Currently the stock recipe installs Hadoop 0.21.
# We need 0.20 because of RHadoop dependencies.
# The -x flag overwrites the recipes for the cluster
# before they are applied

gp-instance-start -x simple-ec2-rhadoop.files $GPI

gp-instance-describe $GPI

# Extract node names from gp-instance-describe output
SERVER=ec2-50-17-174-55.compute-1.amazonaws.com
LOGIN=ec2-107-22-92-255.compute-1.amazonaws.com


# Set Unix password and push to nodes
# Assumes ssh user matches cluster user

ssh -t $SERVER 'sudo passwd $USER'
ssh $SERVER sudo make -C /var/yp


# edit simple-ec2-rstudio-login.sh to match AMI architecture

###

# . . . then install RStudio
ssh $LOGIN 'bash -s' < simple-ec2-rstudio-login.sh

# Go into the AWS Management Console and open port 8787
# under "Security Groups", "globus-provision", "Inbound"
#
# Borja will have to do this for now.

###

# RStudio is now running at

echo "http://${LOGIN}:8787"

