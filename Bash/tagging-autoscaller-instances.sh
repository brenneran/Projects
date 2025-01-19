#!/bin/bash

# Define a list of random animal names
animals=(
  "lion"
  "tiger"
  "bear"
  "elephant"
  "giraffe"
  "zebra"
  "kangaroo"
  "panda"
  "penguin"
  "dolphin"
)

# Randomly select an animal from the list
random_animal=${animals[RANDOM % ${#animals[@]}]}

# Construct the tags with a unique Value for
tags=(
  "Key=Owner,Value=devops/department-name"
  "Key=Role,Value=eks/compute"
  "Key=Environment,Value=prod"
  "Key=Project,Value=cloudbees"
  "Key=Requestor,Value=devops"
  "Key=code.envtype,Value=prod"
  "Key=code.name,Value=cloudbees/eks/stg/$random_animal"
  "Key=Name,Value=cloudbees/eks/stg/$random_animal"
  "Key=CreatedBy,Value=terraform"
)

# Find all Auto Scaling Groups starting with 'eks-cloudbees-prod-mng-'
asg_names=$(aws autoscaling describe-auto-scaling-groups --query "AutoScalingGroups[?starts_with(AutoScalingGroupName, 'jenkins-mng-')].AutoScalingGroupName" --output text)

# Iterate over each ASG to find the associated EC2 instance IDs
for asg in $asg_names; do
  instance_ids=$(aws autoscaling describe-auto-scaling-groups --auto-scaling-group-names "$asg" --query "AutoScalingGroups[].Instances[].InstanceId" --output text)
  
  if [ -n "$instance_ids" ]; then
    echo "Tagging instances in Auto Scaling Group: $asg"
    
    # Apply tags to the instances
    aws ec2 create-tags --resources $instance_ids --tags "${tags[@]}"
    
    echo "Tagged instances: $instance_ids"
  else
    echo "No instances found in Auto Scaling Group: $asg"
  fi
done
