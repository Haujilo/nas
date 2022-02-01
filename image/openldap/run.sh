#! /bin/bash

tmp_ldif=/tmp/tmp.ldif
sys_num=0
people_num=0

function add_ldap_user() {
    cn=$1
    password=`slappasswd -s $2`
    sn=$3
    displayName=$4
    if [ "$5" == 0 ]
    then
        group=sys
        sys_num=$((sys_num+1))
        num=$sys_num
    else
        group=people
        people_num=$((people_num+1))
        num=$people_num
    fi
    cat << EOF >> $tmp_ldif
dn: cn=${cn},ou=user,${rdc}
changetype: add
objectClass: inetOrgPerson
cn: ${cn}
userPassword: ${password}
departmentNumber: ${num}
sn: ${sn}
title: ${cn}
mail: ${cn}@${DOMAIN}
uid: ${cn}
displayName: ${displayName}

dn: cn=${group},ou=account,ou=group,${rdc}
changetype: modify
add: member
member: cn=${cn},ou=user,${rdc}

EOF
    if [ "$6" == 1 ]
    then
        cat << EOF >> $tmp_ldif
dn: cn=admin,ou=account,ou=group,${rdc}
changetype: modify
add: member
member: cn=${cn},ou=user,${rdc}

EOF
    fi
}

rdc=""
for dc in $(echo $DOMAIN | xargs -d'.')
do
    rdc="${rdc},dc=${dc}"
done
rdc=${rdc:1}

cat << EOF | debconf-set-selections
slapd slapd/password1 password $PASSWORD
slapd slapd/password2 password $PASSWORD
slapd slapd/domain string $DOMAIN
slapd shared/organization string $DOMAIN
EOF

dpkg-reconfigure -f noninteractive -plow slapd

/usr/sbin/slapd -h ldapi:/// -g openldap -u openldap -F /etc/ldap/slapd.d

ldapadd -Y EXTERNAL -H ldapi:/// -f /etc/ldap/schema/core.ldif
ldapadd -Y EXTERNAL -H ldapi:/// -f /etc/ldap/schema/cosine.ldif
ldapadd -Y EXTERNAL -H ldapi:/// -f /etc/ldap/schema/inetorgperson.ldif
ldapadd -Y EXTERNAL -H ldapi:/// -f /etc/ldap/schema/nis.ldif
ldapadd -Q -Y EXTERNAL -H ldapi:/// << EOF
dn: cn=module,cn=config
cn: module
objectClass: olcModuleList
olcModulePath: /usr/lib/ldap

dn: cn=module{0},cn=config
changetype: modify
add: olcModuleLoad
olcModuleLoad: memberof.la

dn: olcOverlay=memberof,olcDatabase={1}mdb,cn=config
objectClass: olcConfig
objectClass: olcMemberOf
objectClass: olcOverlayConfig
objectClass: top
olcOverlay: memberof
olcMemberOfDangling: ignore
olcMemberOfRefInt: TRUE
olcMemberOfGroupOC: groupOfNames
olcMemberOfMemberAD: member
olcMemberOfMemberOfAD: memberOf
EOF

URLS="ldapi:/// ldap:///"
if [ "$TLS_ENABLE" == "true" ]
then
    ldapmodify -H ldapi:/// -Y EXTERNAL << EOF
dn: cn=config
changetype: modify
replace: olcTLSCertificateFile
olcTLSCertificateFile: /opt/ssl/certs/certificate.pem
-
replace: olcTLSCertificateKeyFile
olcTLSCertificateKeyFile: /opt/ssl/certs/key.pem
-
replace: olcTLSCACertificateFile
olcTLSCACertificateFile: /opt/ssl/certs/ca.pem

EOF
    URLS="${URLS} ldaps:///"
fi

cat << EOF > $tmp_ldif
dn: ou=user,${rdc}
objectClass: organizationalUnit
ou: user

dn: ou=group,${rdc}
objectClass: organizationalUnit
ou: group

dn: ou=account,ou=group,${rdc}
changetype: add
objectClass: organizationalUnit
ou: account

dn: cn=sys,ou=account,ou=group,${rdc}
objectClass: groupOfNames
cn: sys
member: cn=admin,${rdc}

dn: cn=admin,ou=account,ou=group,${rdc}
objectClass: groupOfNames
cn: admin
member: cn=admin,${rdc}

dn: cn=people,ou=account,ou=group,${rdc}
objectClass: groupOfNames
cn: people
member: cn=admin,${rdc}

EOF

for user in $(echo $USERS | xargs -d':')
do
    add_ldap_user $(echo $user | xargs -d',')
done

ldapadd -H ldapi:/// -x -D "cn=admin,${rdc}" -w "$PASSWORD" -f $tmp_ldif
ldapmodify -H ldapi:/// -x -D "cn=admin,${rdc}" -w "$PASSWORD" << EOF
dn: cn=sys,ou=account,ou=group,${rdc}
changetype: modify
delete: member
member: cn=admin,${rdc}
EOF
ldapmodify -H ldapi:/// -x -D "cn=admin,${rdc}" -w "$PASSWORD" << EOF
dn: cn=admin,ou=account,ou=group,${rdc}
changetype: modify
delete: member
member: cn=admin,${rdc}
EOF
ldapmodify -H ldapi:/// -x -D "cn=admin,${rdc}" -w "$PASSWORD" << EOF
dn: cn=people,ou=account,ou=group,${rdc}
changetype: modify
delete: member
member: cn=admin,${rdc}
EOF

rm -rf $tmp_ldif /var/backups/*

killall slapd

exec /usr/sbin/slapd -d 32768 -h "$URLS" -g openldap -u openldap -F /etc/ldap/slapd.d