#!/bin/bash
if [ $# -ne 4 ]; then 
    echo " enter File name for the process and Priority value of New queue and proiority value of Accepted queue and Quantam value"
    exit
fi

if [ -f $1 ]; then
    echo " file format correct"
else
    echo " file format not correct"
    exit
fi


echo "1. Standard Output Only"
echo "2. output to a named text file (if the file exists then it should be overwritten) "
echo "3. output to both standard output and a named text file"
echo 
read -p "option : " Option
read -p "Filename For the Output : " Output

tempA=(` cat $1 `) 

if test ${#tempA} -eq 0           
then 
    echo "process file empty " 
    exit
fi

len=${#tempA[*]}

((condition = $len % 3  ))
if [ $condition -ne 0 ]; then   
    echo " not correct values for the procecss label"
    echo 
    
    exit
fi

i=0
while test $i -lt ${#tempA[*]}                     
do
    if [[ ! ${tempA[i+1]} =~ ^[0-9]+$ ]]
    then 
        echo " Process Nut Value should be an integer"
    exit   
    fi
    if [[ ! ${tempA[i+2]} =~ ^[0-9]+$ ]]
    then 
        echo " Process Arrival time should be an integer"
    exit   
    fi
     ((i = $i + 3 ))
done
   

arr=()
(( len = $len -1))
i=0

while [ $i -lt $len ];do    
    temp=${tempA[i]}
    temp1=${tempA[i+1]}
    temp2=${tempA[i+2]}
    temp3=-                     
    temp4=0                     
    arr+=($temp $temp1 $temp2 $temp3 $temp4)
    ((i = $i +3))

done


len=${#arr[*]}
((len = $len - 5))
i=0
while test $i -le $len          
do
    temp=${arr[i]}   
    temp1=${arr[i+3]}

    processStatus+=($temp $temp1)
    ((i = $i + 5))
done
echo 
echo " The processStatus array before Loop is ${processStatus[*]}"

proLen=${#processStatus[*]}

echo -e " T    \c"
p=0

while test $p -le $proLen
do
    
    echo -e " ${processStatus[p]}   \c"
    
    ((p = $p + 2 ))
done
echo 
new=()      
accepted=() 
Pnew=$2     
Pacc=$3     
Q=$4        
if [[ ! $Pnew =~ ^[0-9]+$ ]]                      
    then 
        echo " Priority value for new Queue should be an integer"
    exit   
fi

if [[ ! $Pacc =~ ^[0-9]+$ ]]
    then 
echo " Priority value for accepted Queue should be an integer" 
fi

echo " priority value for accepted queue is $Pacc new Queue is $Pnew"
flag=0


len=${#arr[*]}



((len = $len - 5))
i=0
while test $i -lt $len
do
    j=0
    while test $j -lt $len
    do
    if test ${arr[j+2]} -gt ${arr[j+7]}
    then
        temp1=${arr[j]}
        temp2=${arr[j+1]}
        temp3=${arr[j+2]}
        temp4=${arr[j+3]}
        temp5=${arr[j+4]}

        arr[j]=${arr[j+5]}
        arr[j+1]=${arr[j+6]}
        arr[j+2]=${arr[j+7]}
        arr[j+3]=${arr[j+8]}
        arr[j+4]=${arr[j+9]}

        arr[j+5]=$temp1
        arr[j+6]=$temp2
        arr[j+7]=$temp3
        arr[j+8]=$temp4
        arr[j+9]=$temp5
    fi
        ((j = $j + 5))
    done
    ((i = $i + 5))
done
echo " The Following Processes  are waiting for their time on CPU : ${arr[*]} "


flag=0   
t=0     

while [ $flag -eq 0 ]; do          
    if [ ${#arr[*]} -eq 0 ] && [ ${#new[*]} -eq 0 ] && [ ${#accepted[*]} -eq 0 ]; then  
        break                                                                           
    fi
  
        while [ ${#arr[*]} -gt 0 ] && [ $t -eq ${arr[2]} ]; do      
          
            
            if [ ${#accepted[*]} -eq 0 ]
            then          
                temp=${arr[0]}
                temp1=${arr[1]}
                temp2=${arr[2]}
                temp3=R
                temp4=${arr[4]}
                accepted+=($temp $temp1 $temp2 $temp3 $temp4)  
                arr=(${arr[*]:5})
                echo "Updated accepted array is ${accepted[*]}"
            elif  [ ${#accepted[*]} -gt 0 ]
            then                                        
                temp=${arr[0]}
                temp1=${arr[1]}
                temp2=${arr[2]}
                temp3="W"
                temp4=${arr[4]}
                new+=($temp $temp1 $temp2 $temp3 $temp4)        
                arr=(${arr[*]:5})
            fi
        done
  


    if [ ${#new[*]} -gt 0 ]; then                 
        if [ ${#accepted[*]} -eq 0 ]; then       
            temp=${new[0]}
            temp1=${new[1]}
            temp2=${new[2]}
            temp3=R
            temp4=${new[4]}
            accepted+=($temp $temp1 $temp2 $temp3 $temp4)
           
            new=(${new[*]:5})
        
        elif [ ${#new[*]} -gt 0 ] && [ ${#accepted[*]} -gt 0 ] && [ ${new[4]} -ge ${accepted[4]} ]; then  
            temp=${new[0]}
            temp1=${new[1]}
            temp2=${new[2]}
            temp3=${new[3]}
            temp4=${new[4]}
            accepted=(${accepted[*]:0} $temp $temp1 $temp2 $temp3 $temp4) 
            new=(${new[*]:5})              
        fi
     fi

    lAcc=${#accepted[*]}
    ((lAcc = $lAcc - 1))
    for ((i = 4; i <= $lAcc; i += 5)); do     
        ((accepted[i] = ${accepted[i]} + $Pacc))
    done

    lNew=${#new[*]}
    ((lNew = $lNew - 1))
    for ((i = 4; i <= $lNew; i += 5)); do    
        ((new[i] = ${new[i]} + $Pnew))
    done

    if [ ${#accepted[*]} -gt 0 ]; then       
        if [ ${accepted[1]} -eq 0 ]; then     
            for ((i=0; i<${#processStatus[*]}; i+=2));do
       
            if [[ ${processStatus[i]} == ${accepted[0]} ]];then
               
                processStatus[i+1]="F"
                
            
            fi
            done
            accepted=(${accepted[*]:5})       
            if [ ${#accepted[*]} -gt 0 ]
            then  
                ((accepted[1] = ${accepted[1]} - $Q))
                accepted[3]=R
            fi
        else                                
            temp=${accepted[0]}
            temp1=${accepted[1]}
            temp2=${accepted[2]}
            temp3=W
            temp4=${accepted[4]}
            accepted=(${accepted[*]:5} $temp $temp1 $temp2 $temp3 $temp4)
            ((accepted[1] = ${accepted[1]} - $Q))   
            accepted[3]=R                           
        fi
    fi

p=0

while test $p -lt $proLen   
do 
    a=5
    
    while test $a -le ${#accepted[*]}
    do
    
     if [[ ${processStatus[p]} ==  ${accepted[0]} ]]   
        then
        processStatus[p+1]=R
       
   
    fi
  
    if [[ ${processStatus[p]} ==  ${accepted[a]} ]]  
        then
       
        processStatus[p+1]=${accepted[a+3]}
   
    fi
    ((a = $a + 5))
    done
    ((p = $p + 2))
done

p=0

while test $p -lt $proLen  
do 
    
    k=0
    
    while test $k -lt $lNew                       
    do

    if [[ ${processStatus[p]} ==  ${new[k]} ]]   
    then
         processStatus[p+1]=${new[k+3]}
   
    fi
    ((k = $k + 5))
    done
    ((p = $p + 2))
done

times="Time stamp is  $t"
Acc=" Accepted array is is  ${accepted[*]} "
New=" New array is is  ${new[*]} "
echo  $times >> $Output       
echo  
echo $Acc >> $Output 
echo
echo $New >> $Output 
echo

 if test $Option -eq 1   
then

echo
echo -e "$t     \c" 
i=1
while test $i -le ${#processStatus[*]}   
do   
    echo -e  "${processStatus[i]}    \c"
    
    ((i = $i + 2))
done
echo
elif test $Option -eq 2
then
    nano $Output
 
    
elif test $Option -eq 3
then 
    
    echo -e "$t     \c" 
    i=1
    while test $i -le ${#processStatus[*]}   
    do   
        echo -e  "${processStatus[i]}    \c"
        ((i = $i + 2))
    done
    echo
nano $Output              
echo
fi

    ((t = $t + 1))      
done
