#!/bin/bash

# Function to calculate mean
calc() { awk "BEGIN {print $*}"; }

# Function to calculate standard deviation
std_dev() { awk -v mean=$1 '{sum+=($0-mean)*($0-mean)} END {print sqrt(sum/NR)}'; }

# Define the number of iterations
iterations=5

# Define the values for threads, k (array_size)
k_values=(2**10 2**11 2**12 2**13 2**14 2**15 2**16 2**17)
threads_values=(1 2 4)

# Initialize arrays to store mean and standard deviation values
mean_array=()
std_dev_array=()

# Loop through the values for threads, k
for threads in "${threads_values[@]}"
do
    for k in "${k_values[@]}"
    do
        echo "Running with threads=$threads, k=$k"

        # Initialize time_sum and times array for each set of parameters
        time_sum=0
        times=()

        # Loop for the given number of iterations
        for (( i=0; i<$iterations; i++ ))
        do
            # Run the command and capture the output
            time=$(mpirun --use-hwthread-cpus --oversubscribe -np $threads ./broadcast --array_size $k --root 0 --custom)

            # Add the time to the times array and add to time_sum
            times+=($time)
            time_sum=$(calc $time_sum+$time)
        done

        # Calculate the mean time
        mean_time=$(calc $time_sum/$iterations)

        # Calculate the standard deviation
        deviation=$(for time in "${times[@]}"; do echo "$time"; done | std_dev $mean_time)

        # Store mean and standard deviation values in arrays
        mean_array+=($mean_time)
        std_dev_array+=($deviation)

        echo "Mean time for threads=$threads, k=$k: $mean_time"
        echo "Standard deviation for threads=$threads, k=$k: $deviation"
        printf "\n\n"
    done

    # Print the array of mean values
    echo "Mean values for threads=$threads:"
    echo "${mean_array[@]}"
    printf "\n"

    # Print the array of standard deviation values
    echo "Standard deviation values for threads=$threads:"
    echo "${std_dev_array[@]}"
    printf "\n"

    # Reset the arrays for the next combination
    mean_array=()
    std_dev_array=()
done
