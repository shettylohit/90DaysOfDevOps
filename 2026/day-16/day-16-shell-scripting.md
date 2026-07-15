Task 1: Your First Script
Create a file hello.sh
Add the shebang line #!/bin/bash at the top
Print Hello, DevOps! using echo
Make it executable and run it
Document: What happens if you remove the shebang line?


root@ubuntu-host ~/scripts ➜  cat hello.sh 
#!/bin/bash

echo "Hello, DevOps!"

root@ubuntu-host ~/scripts ➜  ./hello.sh 
Hello, DevOps!

root@ubuntu-host ~/scripts ➜  cat hello.sh 


echo "Hello, DevOps!"


root@ubuntu-host ~/scripts ➜  ./hello.sh 
Hello, DevOps!


Task 2: Variables
Create variables.sh with:
A variable for your NAME
A variable for your ROLE (e.g., "DevOps Engineer")
Print: Hello, I am <NAME> and I am a <ROLE>
Try using single quotes vs double quotes — what's the difference?


root@ubuntu-host ~/scripts ➜  cat variables.sh 
#!/bin/bash 

NAME="Lohit"
ROLE="Sr. Devops Engineer"

echo "Hello I'm ${NAME} and I'm a ${ROLE}"

root@ubuntu-host ~/scripts ➜  ./variables.sh 
Hello I'm Lohit and I'm a Sr. Devops Engineer


For variable assignment, both are commonly used:

Use double quotes by default when storing strings that may contain variables or special characters.
Use single quotes when you want the value stored exactly as typed.


Task 3: User Input with read
Create greet.sh that:
Asks the user for their name using read
Asks for their favourite tool
Prints: Hello <name>, your favourite tool is <tool>

root@ubuntu-host ~/scripts ➜  cat greet.sh 
#!/bin/bash 


read  -p "Enter your name: " name
read -p "Enter your favourite tool: " tool 


echo "Hello ${name}, your favourite tool is ${tool}"

root@ubuntu-host ~/scripts ➜  ./greet.sh 
Enter your name: Lohit
Enter your favourite tool: VsCode
Hello Lohit, your favourite tool is VsCode


Task 4: If-Else Conditions
Create check_number.sh that:

Takes a number using read
Prints whether it is positive, negative, or zero
Create file_check.sh that:

Asks for a filename
Checks if the file exists using -f
Prints appropriate message



root@ubuntu-host ~/scripts ➜  cat check_number.sh 
#!/bin/bash 


echo '''

Number checker that will check if the given number is Positive, Negative or Zero

'''



read -p "Enter your number :" number 

if [ $number -gt 0 ]; then
     echo "${number} is positive number"
elif [ $number -lt 0  ]; then
     echo "${number} is negative number"
else
        echo "${number} is a zero number"
fi




root@ubuntu-host ~/scripts ➜  ./check_number.sh 


Number checker that will check if the given number is Positive, Negative or Zero


Enter your number :2
2 is positive number

root@ubuntu-host ~/scripts ➜  ./check_number.sh 


Number checker that will check if the given number is Positive, Negative or Zero


Enter your number :-2
-2 is negative number

root@ubuntu-host ~/scripts ➜  ./check_number.sh 


Number checker that will check if the given number is Positive, Negative or Zero


Enter your number :0
0 is a zero number




root@ubuntu-host ~/scripts ➜  cat file_check.sh 
#!/bin/bash

echo '''

To check if the give file exists or not

'''

read -p "Enter file name: "  filename


if [ -f  ${filename} ]; then
        echo "${filename} exists"
else 
        echo "${filename} does not exists"
fi



root@ubuntu-host ~/scripts ➜  cat file_check.sh 
#!/bin/bash

echo '''

To check if the give file exists or not

'''

read -p "Enter file name: "  filename


if [ -f  ${filename} ]; then
        echo "${filename} exists"
else 
        echo "${filename} does not exists"
fi


