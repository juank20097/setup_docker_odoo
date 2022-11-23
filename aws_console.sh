read -p "Introduce el nombre de la Instancia en AWS: " instanceName
public_key=aws_personal
echo "-------------------------------------------------------"
echo "-------------1. Verification of Credentials------------"
echo "-------------------------------------------------------"
aws configure list
echo "-------------------------------------------------------"
echo "-------------1. Create Instance------------------------"
echo "-------------------------------------------------------"
aws ec2 run-instances --image-id ami-097a2df4ac947655f --instance-type t2.micro --count 1 --security-groups launch-wizard-3 --key-name $public_key  > instance.json
cat instance.json
echo "-------------------------------------------------------"
echo "-------------2. get ID Instance------------------------"
echo "-------------------------------------------------------"
jq '.Instances[].InstanceId' instance.json > instance.txt
sed -i -e 's/"//g' instance.txt
instanceId=$(cat instance.txt)
echo $instanceId
echo "-------------------------------------------------------"
echo "-----------3. Add tag Name to Instance-----------------"
echo "-------------------------------------------------------"
aws ec2 create-tags --resources $instanceId --tags Key=Name,Value=$instanceName
echo changed name to $instanceName
echo "-------------------------------------------------------"
echo "-----------4. Get Public DNS-------- ------------------"
echo "-------------------------------------------------------"
aws ec2 describe-instances --instance-ids $instanceId  > instance.json
jq '.Reservations[].Instances[].PublicDnsName' instance.json > instance_dns.txt
sed -i -e 's/"//g' instance_dns.txt
instanceDns=$(cat instance_dns.txt)
echo $instanceDns 
echo "-------------------------------------------------------"
echo "---------5. Get Public IP------------------------------"
echo "-------------------------------------------------------"
jq '.Reservations[].Instances[].PublicIpAddress' instance.json > instance_ip.txt
sed -i -e 's/"//g' instance_ip.txt
instanceIP=$(cat instance_ip.txt)
echo $instanceIP
cat instance.txt >> instance_info.txt
cat instance_dns.txt >> instance_info.txt
cat instance_ip.txt >> instance_info.txt
rm instance_dns.txt instance_ip.txt instance.txt
echo "-------------------------------------------------------"
echo "---------6. Open URl remote to deploy------------------"
echo "-------------------------------------------------------"
echo click in this url: http://$instanceIP:8069/
echo "-------------------------------------------------------"
echo "--------5. Conection with instance AWS with FTP-----"
echo "-------------------------------------------------------"
sftp -i "$public_key.pem" ubuntu@$instanceDns
echo "-------------------------------------------------------"
echo "--------6. Conection with instance AWS with SSH--------"
echo "-------------------------------------------------------"
ssh -i "$public_key.pem" ubuntu@$instanceDns
