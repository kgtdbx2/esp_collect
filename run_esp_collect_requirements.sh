####begin####
echo "Begin esp_collect_requirements."
rm -f esp_requirements.zip
for INST in $(ps axo cmd | grep ora_pmo[n] | sed 's/^ora_pmon_//' | grep -v 'sed '); do
        if [ $INST = "$( cat /etc/oratab | grep -v ^# | grep -v ^$ | awk -F: '{ print $1 }' | grep $INST )" ]; then
                echo "instance name = db_unique_name"
                export ORACLE_SID=$INST; export ORAENV_ASK=NO; . oraenv
        else
                # remove last char (instance nr) and look for name again
                LAST_REMOVED=$(echo "${INST:0:$(echo ${#INST}-1 | bc)}")
                if [ $LAST_REMOVED = "$( cat /etc/oratab | grep -v ^# | grep -v ^$ | awk -F: '{ print $1 }' | grep $LAST_REMOVED )" ]; then
                        echo "instance name with last char removed = db_unique_name"
                        export ORACLE_SID=$LAST_REMOVED; export ORAENV_ASK=NO; . oraenv; export ORACLE_SID=$INST
                else
                        echo "couldn't find name in oratab"
                        continue
                fi
        fi
        # insert sqlplus things here
        sqlplus -s /nolog <<EOF
        connect / as sysdba
        @sql/esp_collect_requirements.sql
EOF
done
zip -qmT esp_requirements.zip esp_requirements.csv esp_requirements.log
echo "End esp_collect_requirements. Output: esp_requirements.zip"
####end####

