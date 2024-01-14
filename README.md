# gpu-based-password-generator

# you need the cuda toolkit to compile the code
```bash
sudo apt install nvidia-cuda-toolkit -y
```
# to compile the code type this:
```bash
nvcc -arch=sm_80 -o passwordGenerator passwordGenerator.cu
```
# if you want to execute the program you need to have a min and max password length for examle
```bash
./passwordGenerator 4 12
```
# this will make a password bitween 4 and 12 characters long

# if you want the passwords to be safed in a file type this:
```bash
./passwordGenerator 4 12 > passwords.txt
```
