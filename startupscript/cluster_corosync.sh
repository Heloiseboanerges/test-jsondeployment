token=$(cat /etc/corosync/corosync.conf | grep token:)
echo $token
# si el valor no es 30000
sudo sed -i "s/$token/token: 30000/g" /etc/corosync/corosync.conf
token=$(cat /etc/corosync/corosync.conf | grep token:)
echo $token

retransmits=$(cat /etc/corosync/corosync.conf | grep token_retransmits_before_loss_const: )
echo $retransmits
# si el valor no es 10
sudo sed -i "s/$retransmits/token_retransmits_before_loss_const:  10/g" /etc/corosync/corosync.conf
retransmits=$(cat /etc/corosync/corosync.conf | grep token_retransmits_before_loss_const: )
echo $retransmits

join=$(cat /etc/corosync/corosync.conf | grep join: )
echo $join
# si el valor no es 60
sudo sed -i "s/$join/join:  60/g" /etc/corosync/corosync.conf
join=$(cat /etc/corosync/corosync.conf | grep join: )
echo $join

consensus=$(cat /etc/corosync/corosync.conf | grep consensus: )
echo $consensus
# si el valor no es 36000
sudo sed -i "s/$consensus/consensus:  36000/g" /etc/corosync/corosync.conf
consensus=$(cat /etc/corosync/corosync.conf | grep consensus: )
echo $consensus

max_messages=$(cat /etc/corosync/corosync.conf | grep max_messages: )
echo $max_messages
# si el valor no es 20
sudo sed -i "s/$max_messages/max_messages:  20/g" /etc/corosync/corosync.conf
max_messages=$(cat /etc/corosync/corosync.conf | grep max_messages: )
echo $max_messages

expected_votes=$(cat /etc/corosync/corosync.conf | grep expected_votes: )
echo $expected_votes
# si el valor no es 2
sudo sed -i "s/$expected_votes/expected_votes:  20/g" /etc/corosync/corosync.conf
expected_votes=$(cat /etc/corosync/corosync.conf | grep expected_votes: )
echo $expected_votes

two_node=$(cat /etc/corosync/corosync.conf | grep two_node: )
echo $two_node
# si el valor no es 1
sudo sed -i "s/$two_node/two_node:  1/g" /etc/corosync/corosync.conf
two_node=$(cat /etc/corosync/corosync.conf | grep two_node: )
echo $two_node

