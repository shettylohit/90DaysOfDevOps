1. Launch Cloud Instance & SSH Access

Connected to the ec2 instance via ssh 

commands: 
ssh -i "day8_key_file.pem" ec2-user@ec2-32-199-172-62.compute-1.amazonaws.com

<img width="935" height="300" alt="image" src="https://github.com/user-attachments/assets/8ac709bb-9518-40d2-8fd5-29477b3d7c3e" />

Install Docker & Nginx

Nginx

commands:
sudo yum update 
sudo yum install nginx -y


<img width="980" height="299" alt="image" src="https://github.com/user-attachments/assets/1cc8d9ec-831e-4fbd-81de-ded7fb153c0a" />

Docker

commands:
sudo yum install docker -y 

<img width="1632" height="409" alt="image" src="https://github.com/user-attachments/assets/3ac9015c-f0ba-4509-a4c9-1357c158a2e2" />


Security Group Configuration

Added port 80 to the security group

<img width="1367" height="361" alt="image" src="https://github.com/user-attachments/assets/f9e81c03-170f-4844-a098-49874751ff93" />

Acessing nginx via browser 

<img width="1193" height="430" alt="image" src="https://github.com/user-attachments/assets/72998d0e-3101-4c2a-94bf-1dcaec2394c9" />


Extract Nginx Logs

<img width="1752" height="494" alt="image" src="https://github.com/user-attachments/assets/ec44ecf7-da96-4008-8965-f90e2ef38886" />
