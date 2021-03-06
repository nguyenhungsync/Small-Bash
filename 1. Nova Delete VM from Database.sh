ID=$4
MYSQL_HOST=$1
MYSQL_USER=$2
MYSQL_PASSWORD=$3


 
if [ -z "$4" ]; then echo "VM ID not given"; exit 1; fi

Q=`cat <<EOF
SELECT display_name FROM nova.instances WHERE instances.id = '$ID';
SELECT uuid FROM nova.instances WHERE instances.id = '$ID';
EOF`
RQ=`mysql -h $MYSQL_HOST -u $MYSQL_USER -p$MYSQL_PASSWORD --batch --skip-column-names -e "$Q"`
 
VMNAME=`echo $RQ | cut -d' ' -f1`
UUID=`echo $RQ | cut -d' ' -f2`
 
if [ -z "$VMNAME" ]; then VMNAME="No Name";fi
if [ -z "$UUID" ]; then echo "UUID for $VNAME not found"; exit 1; fi
echo "VMNAME: $VMNAME"
echo "ID: $ID"
echo "UUID: $UUID"
 
echo "Delete $VMNAME? (y/n)"
read -e YN
if [ "$YN" != 'y' ]; then echo "Exiting...";exit 1;fi
 
Q=`cat <<EOF
DELETE FROM nova.instance_faults WHERE instance_faults.instance_uuid = '$UUID';
DELETE FROM nova.instance_id_mappings WHERE instance_id_mappings.uuid = '$UUID';
DELETE FROM nova.instance_info_caches WHERE instance_info_caches.instance_uuid = '$UUID';
DELETE FROM nova.instance_system_metadata WHERE instance_system_metadata.instance_uuid = '$UUID';
DELETE FROM nova.security_group_instance_association WHERE security_group_instance_association.instance_uuid = '$UUID';
DELETE FROM nova.block_device_mapping WHERE block_device_mapping.instance_uuid = '$UUID';
DELETE FROM nova.fixed_ips WHERE fixed_ips.instance_uuid = '$UUID';
DELETE FROM nova.instance_actions_events WHERE instance_actions_events.action_id in (SELECT id from nova.instance_actions where instance_actions.instance_uuid = '$UUID');
DELETE FROM nova.instance_actions WHERE instance_actions.instance_uuid = '$UUID';
DELETE FROM nova.virtual_interfaces WHERE virtual_interfaces.instance_uuid = '$UUID';
DELETE from nova.instance_extra where instance_extra.instance_uuid = '$UUID';
DELETE FROM nova.instance_metadata WHERE instance_metadata.instance_uuid = '$UUID';
DELETE FROM nova.migrations WHERE migrations.instance_uuid = '$UUID';
DELETE FROM nova.instances WHERE instances.uuid = '$UUID';
EOF`
RQ=`mysql -h $MYSQL_HOST -u $MYSQL_USER -p$MYSQL_PASSWORD --batch --skip-column-names -e "$Q"`
echo "$RQ"
