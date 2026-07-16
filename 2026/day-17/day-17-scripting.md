Task 1: For Loop
Create for_loop.sh that:
Loops through a list of 5 fruits and prints each one
Create count.sh that:
Prints numbers 1 to 10 using a for loop


root@ubuntu-host ~/scripts ➜  cat for_loop.sh 
#!/bin/bash 


fruits=("Apple" "Banana" "Watermelon" "Papaya")


for i in "${fruits[@]}"; do
        echo $i
done


root@ubuntu-host ~/scripts ➜  ./for_loop.sh 
Apple
Banana
Watermelon
Papaya


root@ubuntu-host ~/scripts ➜  cat count.sh 
#!/bin/bash 

for i in {1..10}; do 
        echo $i
done

root@ubuntu-host ~/scripts ➜  ./count.sh 
1
2
3
4
5
6
7
8
9
10


Task 2: While Loop
Create countdown.sh that:
Takes a number from the user
Counts down to 0 using a while loop
Prints "Done!" at the end

root@ubuntu-host ~ ➜  cat countdown.sh 
#!/bin/bash

read -p "Please enter a number: " number


while [[ "$number" -gt 0 ]]; do
    echo $number
    number=$(( number - 1 ))
done


root@ubuntu-host ~ ➜  ./countdown.sh 
Please enter a number: 5
5
4
3
2
1



Task 3: Command-Line Arguments
Create greet.sh that:

Accepts a name as $1
Prints Hello, <name>!
If no argument is passed, prints "Usage: ./greet.sh "
Create args_demo.sh that:

Prints total number of arguments ($#)
Prints all arguments ($@)
Prints the script name ($0)



root@ubuntu-host ~ ➜  cat greet.sh 
#!/bin/bash 


if [[ -z "$1" ]]; then 
        echo "Usage: ./greet.sh <name>"
else
    echo "Hello, $1!"
fi

root@ubuntu-host ~ ➜  cat greet.sh 
#!/bin/bash 


if [[ -z "$1" ]]; then 
        echo "Usage: ./greet.sh <name>"
else
    echo "Hello, $1!"
fi



root@ubuntu-host ~ ➜  cat args_demo.sh 
#!/bin/bash

echo "Script Name (\$0):      $0"
echo "Total Arguments (\$#):  $#"
echo "All Arguments (\$@):    $@"


root@ubuntu-host ~ ➜  ./args_demo.sh hello mark 
Script Name ($0):      ./args_demo.sh
Total Arguments ($#):  2
All Arguments ($@):    hello mark

root@ubuntu-host ~ ➜  

