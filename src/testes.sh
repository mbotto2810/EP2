#!/bin/bash

# Function to calculate mean
calc() { awk "BEGIN {print $*}"; }

# Define the number of iterations
iterations=10

# Define the values for threads, k (array_size)
k_values=(2^10 2^11 2^12 2^13 2^14 2^15 2^16 2^16)
threads_values=(1 2 4)

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

        # Print the mean time
        echo "Mean time for threads=$threads, k=$k: $mean_time"
        printf "\n\n"
    done
done
