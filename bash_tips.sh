# Sjekke innhold i store filer:
# Vis 100 linjer før (-B) og 100 linjer etter (-A) match
grep -B 100 -A 100 searchpattern filename.xml

# Søk rekursivt etter streng i filer
grep -Rnw '/some/path/' --exclude-dir={venv,Logs,OLD}  -e 'pattern'


# Kan lage en sjekkliste med m5d-summer på en server, og sjekke at alle filer på en annen server matcher denne:
#https://askubuntu.com/questions/318530/generate-md5-checksum-for-all-files-in-a-directory
$ find -type f -exec md5sum "{}" + > checklist.chk # på server 1
$ md5sum -c checklist.chk # på server 2


# Sjekk hva som skjer på en port (f.eks. start en applikasjon på port 6006 i en annen terminal og følg med)
# NB: Kan også bruke wireshark hvis det er tilgjengelig
$ sudo tcpdump -i any port 6006


# --- Netcat ----
# https://linux.die.net/man/1/nc

# Sjekke om port 2484 er åpen
$ nc -zv my-server.no 2484

# It is quite simple to build a very basic client/server model using nc. On one console, start nc listening on a specific port for a connection. For example:
$ nc -l 1234
# nc is now listening on port 1234 for a connection. On a second console (or a second machine), connect to the machine and port being listened on:
$ nc 127.0.0.1 1234
# There should now be a connection between the ports. Anything typed at the second console will be concatenated to the first, and vice-versa. 
# After the connection has been set up, nc does not really care which side is being used as a 'server' and which side is being used as a 'client'. 
# The connection may be terminated using an EOF ('^D').

# It may be useful to know which ports are open and running services on a target machine.
# The -z flag can be used to tell nc to report open ports, rather than initiate a connection.
# For example:
$ nc -z host.example.com 20-30
# Connection to host.example.com 22 port [tcp/ssh] succeeded!
# Connection to host.example.com 25 port [tcp/smtp] succeeded!
# (Kan også bruke -zv for mer verbose output)


# Backup/kopi som tar vare på rettigheter
$ tar --exclude='venv' -czf ~/backups/MyFolder_20240903.tar.gz /path/MyFolder

# Sjekk innhold:
$ tar -ztvf ~/backups/MyFolder_20240903.tar.gz


# Kopier filer som har blitt endret de siste 4 dager til en annen server
# (endrer midlertidig rettighetene på mappen det skal synces til)
# Husk å stå i riktig mappe (finnes nok bedre måter å gjøre dette på)
myuser@server2 $ sudo chown -R myuser:myuser /myPath/myFolder/
myuser@server1 myFolder$ find . -type f -mtime -4 > ~/filelist.txt
myuser@server1 myFolder$ rsync -avR --files-from=/home/myuser/filelist.txt . myuser@server2:/myPath/myFolder/
myuser@server2 $ sudo chown -R anotheruser:anotheruser /myPath/myFolder/

# Kan sjekke tidsstempel på filene som synces (må kjøres fra mappen hvor find-kommandoen ble kjørt):
$ cat ~/filelist.txt | tail | xargs ls -lrth


# Finn filer med visse rettigheter og endre disse
find /foo/ -type f -perm 600 -exec chmod 644 {} \;


# Følg med på endringer i fil
# https://stackoverflow.com/questions/41756525/using-tail-f-to-see-a-file-changing-in-real-time
while [ 1 ]; do sleep 1; clear; tail log.txt; done


# --- XML-validering ---
#validate_xml.sh:

#!/bin/bash
# Check if the correct number of arguments is provided
if [ $# -ne 2 ]; then
  echo "Usage: $0 <xsd_file> <xml_file>"
    exit 1
    fi

    xsd_file="$1"
    xml_file="$2"
    error_file="error_${xml_file%.*}.txt"

    time xmllint --schema "$xsd_file" "$xml_file" --noout >"$error_file" 2>&1