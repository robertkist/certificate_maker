Creates Certificates for Self Hosting
-------------------------------------

source: https://deliciousbrains.com/ssl-certificate-authority-for-local-https-development/

### How does it work?
There are 2 certificates:
1. A certificate that is sent by the server when a client connects to it (aka server certificate).
2. A certificate that is used to sign the server certificate (signing certificate). 
   The organization that signs server certificates is known as certificate authority (CA).

The server certificate is installed on the (web)server. The CA's signing certificate is installed on the client.
When the client connects to the server, it inspects the server's certificate. Since the server's certificate
was signed with the signing certificate that is installed on the client, the client automatically trusts the server.

### How to use
1. edit localhost.ext
   1. set DNS.1 and IP.1 to the host name and IP of the server. Note: the client must have this hostname in 
      its /etc/hosts file if the server is on a local network.
2. run ./makecert.sh
3. you will be asked to enter a pass-phrase -&gt; that's the password for the root key for the signing certificate.
4. you will be asked to enter information for the signing certificate - example:
   1. Country Name: SG
   2. State or Province Name: SG
   3. Locality Name: Singapore
   4. Organization Name: FooBar
   5. Organizational Unit name: &lt;blank&gt;
   6. Common name: myCA
   7. email: &lt;blank&gt;
5. you will be asked to enter information for the server certificate. This should mostly
   be the same as for the signing certificate. NOTE: that the common name should match the 
   host name in the localhost.ext file.
   1. Country Name: SG
   2. State or Province Name: SG
   3. Locality Name: Singapore
   4. Organization Name: FooBar
   5. Organizational Unit name: &lt;blank&gt;
   6. Common name: isengard
   7. email: &lt;blank&gt;
6. You will be asked for a 'challenge password' - leave it blank.

You will get the following files:
* localhost.cert.pem - server certificate. rename to &lt;hostname&gt;.crt
* localhost.key.pem - server certificate key. rename to &lt;hostname&gt;.key
* localhost.csr.pem - server certificate request. can be deleted
* dev_cert_ca.cert.pem - signing certificate. rename to myCA.pem
* dev_cert_ca.key.pem - signing certificate key.
* dev_cert_ca.srl - signing serial (can be reused)

### Installing Server Certificate and Key on the Host
Webservers will require:
* localhost.cert.pem, renamed to &lt;hostname&gt;.crt
* localhost.key.pem, renamed to &lt;hostname&gt;.key

### Installing Signing Certificate on MAC Client
Installing the certificate:
* Open the macOS Keychain app
* Make sure you’ve selected the System Keychain (older macOS versions default to this keychain)
* Go to File &gt; Import Items…
* Select myCA.pem (aka dev_cert_ca.cert.pem)
* The certificate will show up as whatever you entered as the “Common Name” name (e.g. myCA)
* Double-click on your root certificate in the list
* Expand the Trust section
* Change the “When using this certificate:” select box to Always Trust
* Close the certificate window (you may have to enter your password)

Verification:
* (Re)start Safari
* Go to the website (using https://) - you should not get any errors. If you get errors, try restarting your Mac before troubleshooting.

### Installing Signing Certificate on WINDOWS Client
Installing the certificate:
* Open the “Microsoft Management Console” by using the Windows + R keyboard combination, typing mmc and clicking Open
* Go to File &gt; Add/Remove Snap-in
* Click Certificates and Add
* Select Computer Account and click Next
* Select Local Computer then click Finish
* Click OK to go back to the MMC window
* Double-click Certificates (local computer) to expand the view
* Select Trusted Root Certification Authorities, right-click on Certificates in the middle column under “Object Type” and select All Tasks then Import
* Click Next then Browse. Change the certificate extension dropdown next to the filename field to All Files (*.*) and locate the myCA.pem file, click Open, then Next
* Select Place all certificates in the following store. “Trusted Root Certification Authorities store” is the default. Click Next then click Finish to complete the wizard.
* If everything went according to plan, you should see your CA certificate listed under Trusted Root Certification Authorities &gt; Certificates.

Verification:
* (Re)start Edge
* Go to the website (using https://) - you should not get any errors. If you get errors, try restarting your Mac before troubleshooting.

### Installing Signing Certificate on UBUNTU Client
Installing the certificate:
* If it isn’t already installed, install the ca-certificates package. ```sudo apt-get install -y ca-certificates```
* copy and rename myCA.pem file ```sudo cp ~/myCA.pem /usr/local/share/ca-certificates/myCA.crt```
* update certificates: ```sudo update-ca-certificates```

Verify:
* run curl to access the site. There should be no SSL errors: ```curl https://&lt;servername&gt;```

Chrome:
* from the 3-dots menu on the top right choose 'Settings'
* from the hamburger menu on the top left choose 'Privacy and Security'
* click on the 3rd entry from the bottom labeled "Security"
* scroll down and click the 2nd entry from the bottom labeled "Manage certificates"
* choose the "Authorities" tab.
* Press the import button to import myCA.pem and check "Trust this certificate for identifying websites"
* The certificatge should show up in the list under "org-&lt;what-you-chose-as-common-name&gt;" (e.g. org-myCA)
* Restart Chrome and visit the website (https://&lt;servername&gt;)

Firefox:
* run ```sudo apt install libnss3-tools```
* Make sure to run Firefox at least once after installing, so it creates ~/.mozilla
* run ./cert_inst.sh
* Restart Firefox and visit the website (https://&lt;servername&gt;)