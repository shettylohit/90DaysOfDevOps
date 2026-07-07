Task 
Creating a file
Writing text to a file
Appending new lines
Reading the file back



root@ubuntu-host ~ ➜  touch notes.txt

root@ubuntu-host ~ ➜  echo "Linux is based on the UNIX operating system, a multi-user and multitasking platform developed in the 1970s at AT&T Bell Labs that became the foundation for many modern operating systems." > notes.txt 

root@ubuntu-host ~ ➜  echo "Linux is free and open-source, encouraging global collaboration and innovation while providing strong security, flexibility, and reliable performance across different devices and industries." >> notes.txt 

root@ubuntu-host ~ ➜  echo "Linux combines a wide range of open-source tools and components to form a complete computing environment. These components include file systems, user interfaces, system utilities and application programs, all working together to manage hardware and enable users to interact with their computer systems." >> notes.txt 

root@ubuntu-host ~ ➜  cat notes.txt 
Linux is based on the UNIX operating system, a multi-user and multitasking platform developed in the 1970s at AT&T Bell Labs that became the foundation for many modern operating systems.
Linux is free and open-source, encouraging global collaboration and innovation while providing strong security, flexibility, and reliable performance across different devices and industries.
Linux combines a wide range of open-source tools and components to form a complete computing environment. These components include file systems, user interfaces, system utilities and application programs, all working together to manage hardware and enable users to interact with their computer systems.

root@ubuntu-host ~ ➜  head -n 2 notes.txt 
Linux is based on the UNIX operating system, a multi-user and multitasking platform developed in the 1970s at AT&T Bell Labs that became the foundation for many modern operating systems.
Linux is free and open-source, encouraging global collaboration and innovation while providing strong security, flexibility, and reliable performance across different devices and industries.

root@ubuntu-host ~ ➜  tail -n 2 notes.txt 
Linux is free and open-source, encouraging global collaboration and innovation while providing strong security, flexibility, and reliable performance across different devices and industries.
Linux combines a wide range of open-source tools and components to form a complete computing environment. These components include file systems, user interfaces, system utilities and application programs, all working together to manage hardware and enable users to interact with their computer systems.
